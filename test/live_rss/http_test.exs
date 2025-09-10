defmodule PancreaRSS.HTTPTest do
  use ExUnit.Case
  # import ExUnit.CaptureLog

  test "get/1 returns feed" do
    assert {:ok, feed} =
             PancreaRSS.HTTP.get("https://rss.nytimes.com/services/xml/rss/nyt/World.xml")

    assert feed
  end

  # test "get/1 when body is not rss returns error" do
  #   assert capture_log(fn ->
  #            assert :error = PancreaRSS.HTTP.get("https://google.com/")
  #          end) =~ "PancreaRSS: failed to get feed. Reason: {:fatal_error"
  # end

  # test "get/1 when request fails returns error" do
  #   assert capture_log(fn ->
  #            assert :error = PancreaRSS.HTTP.get("invalid domain")
  #          end) =~ "PancreaRSS: failed to get feed. Reason: {:error, :invalid_uri}"
  # end
end
