defmodule Sender.Stream do
  @emails [
    "rafaelantunes@live.com",
    "antuneslari@hotmail.com",
    "marinhapa@hotmail.com",
    "dev@rafaelantun.es",
    "foo@bar.com"
  ]

  def send_email("foo@bar.com" = email), do: raise("It cannot send an email to #{email}")

  def send_email(email) do
    Process.sleep(3000)
    IO.puts("Email sent to #{email}")

    {:ok, :email_sent}
  end

  def notify_all() do
    Sender.Stream.EmailTaskSupervisor
    # “It works just like Enum.map/2 and Task.async/2 combined” // max_concurrency // ordered: true is default
    |> Task.Supervisor.async_stream_nolink(@emails, &send_email/1, ordered: false)
    # this forces the stream to run. you can also use enum.reduce for example
    |> Enum.to_list()
  end
end
