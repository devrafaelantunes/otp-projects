defmodule Sender.Gen do
  use GenServer

  @emails [
    "rafaelantunes@live.com",
    "antuneslari@hotmail.com",
    "marinhapa@hotmail.com",
    "dev@rafaelantun.es",
    "foo@bar.com"
  ]

  def init(args) do
    max_retries = Keyword.get(args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}

    {:ok, state, {:continue, :fetch_from_database}}
  end

  def handle_continue(:fetch_from_database, state) do
    #get users from database
    {:noreply, Map.put(state, :emails, @emails)} # we can also return continue term on this one
  end



end
