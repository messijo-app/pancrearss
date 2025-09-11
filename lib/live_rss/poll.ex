defmodule PancreaRSS.Poll do
  @moduledoc """
  PancreaRSS.Poll is a GenServer that polls a RSS feed periodically.

  ```elixir
  PancreaRSS.Poll.start_link(name: :live_rss_blog, url: "https://blog.test/feed.rss", refresh_every: :timer.hours(2))
  PancreaRSS.Poll.start_link(name: :live_rss_videos, url: "https://videos.test/feed.rss", refresh_every: :timer.hours(1))
  PancreaRSS.Poll.start_link(name: :live_rss_photos, url: "https://photos.test/feed.rss", refresh_every: :timer.minutes(10))

  feed = PancreaRSS.get(:live_rss_blog)
  ```

  Use `PancreaRSS.Poll.start_link/1` to start the GenServer. You can use the following
  options as the example:
  * `name`: the atom name of the process that will be used to retrieve the feed later
  * `url`: the URL of the RSS feed
  * `refresh_every`: the frequency the feed will be fetched by the GenServer

  You can use `PancreaRSS.get/1` to retrieve the feed as a `%FeederEx.Feed{}` struct.
  """

  require Logger
  use GenServer

  def start_link(opts) do
    with :ok <- validate_uri(opts),
         {:ok, name} <- validate_name(opts),
         {:ok, pid} <- GenServer.start_link(__MODULE__, opts, name: name),
         do: {:ok, pid}
  end

  defp validate_name(opts) do
    case opts[:name] do
      nil -> {:error, :invalid_name}
      name when is_atom(name) -> {:ok, name}
      _any -> {:error, :invalid_name}
    end
  end

  defp validate_uri(opts) do
    with url when is_binary(url) <- opts[:url],
         %URI{} = uri <- URI.parse(url),
         %URI{} = uri when is_binary(uri.scheme) and is_binary(uri.host) and is_binary(uri.path) <-
           uri do
      :ok
    else
      _any -> {:error, :invalid_url}
    end
  end

  @doc """
  Returns a `%FeederEx.Feed{}`. If the feed fails to be fetched, it returns nil and logs
  error.
  """
  # @spec get(atom()) :: %FeederEx.Feed{} | nil
  def get(process_name) do
    process_name
    |> Process.whereis()
    |> GenServer.call(:get_feed)
  end

  @default_state [refresh_every: :timer.hours(1), url: nil, feed: nil, callback: nil]

  @impl true
  def init(state) do
    Logger.info("PancreaRSS: Started #{state[:name]} polling every #{state[:refresh_every]}ms")

    state = Keyword.merge(@default_state, state)
    schedule_polling(state)

    {:ok, state}
  end

  @impl true
  def handle_call(:get_feed, _from, state) do
    case state[:feed] do
      nil ->
        state = put_feed(state)
        {:reply, state[:feed], state}

      _ ->
        {:reply, state[:feed], state}
    end
  end

  @impl true
  def handle_info(:poll, state) do
    state = put_feed(state)
    schedule_polling(state)

    {:noreply, state}
  end

  defp schedule_polling(state) do
    Process.send_after(self(), :poll, state[:refresh_every])
  end

  defp put_feed(state) do
    case PancreaRSS.HTTP.get(state[:url]) do
      {:ok, feed} ->
        Logger.info("PancreaRSS: Updated #{state[:name]} data")

        if not is_nil(state[:callback]) do
          state[:callback].(feed)
        end

        Keyword.put(state, :feed, feed)

      _any ->
        state
    end
  end
end
