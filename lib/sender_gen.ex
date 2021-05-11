defmodule Sender.Gen do
  use GenServer

  alias Sender.Stream

  @emails [
    %{email: "rafaelantunes@live.com", retries: 2, status: ""},
    %{email: "antuneslari@hotmail.com", retries: 2, status: ""},
    %{email: "foo@bar.com", retries: 2, status: ""},
  ]

  def init(args) do
    max_retries = Keyword.get(args, :max_retries, 5)
    state = %{emails: [], max_retries: max_retries}

    Process.send_after(self(), :retry, 5000)

    {:ok, state, {:continue, :fetch_from_database}}
  end

  def handle_continue(:fetch_from_database, state) do
    #get users from database
    {:noreply, Map.put(state, :emails, @emails)} # we can also return continue term on this one
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end


  def handle_cast(:send_emails, state) do
    Stream.notify_all(state.emails)

    {:noreply, state}
  end

  def handle_cast({:send_email, email}, state) do
    status =
      case Stream.send_email(email) do
        {:ok, :email_sent} -> "sent"
        :error -> "failed"
      end

      emails = [%{email: email, status: status, retries: 0}] ++ state.emails

      {:noreply, %{state | emails: emails}}
    end

  def handle_info(:retry, state) do
    {failed, done} =
      Enum.split_with(state.emails, fn item ->
        item.status == "failed" && item.retries < state.max_retries
      end)

    retried =
      Enum.map(failed, fn item ->
        IO.puts("Retrying email #{item.email}...")

        new_status =
          case Stream.send_email(item.email) do
            {:ok, :email_sent} -> "sent"
            :error -> "failed"
          end

        %{email: item.email, status: new_status, retries: item.retries + 1}
      end)
    Process.send_after(self(), :retry, 5000)
    {:noreply, %{state | emails: retried ++ done}}
  end

  def terminate(reason, _state) do
    IO.puts("Terminating with reason #{reason}")
  end

end
