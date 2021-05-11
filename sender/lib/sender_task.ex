defmodule Sender.Task do
  @emails [
    "rafaelantunes@live.com",
    "antuneslari@hotmail.com",
    "marinhapa@hotmail.com",
    "dev@rafaelantun.es",
    "foo@bar.com"
  ]

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email sent to #{email}")

    {:ok, :email_sent}
  end

  def notify_all() do
    Enum.map(@emails, fn email ->
      # Task.Start
      Task.async(fn ->
        send_email(email)
      end)
    end)
    # same as Task.await(task)
    |> Enum.map(&Task.await/1)
  end
end
