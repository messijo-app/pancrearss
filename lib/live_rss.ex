defmodule PancreaRSS do
  defdelegate get(process_name), to: PancreaRSS.Poll
end
