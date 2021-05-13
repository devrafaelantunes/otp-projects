defmodule Airports do

  alias NimbleCSV.RFC4180, as: CSV

  @spec airports_csv :: binary
  def airports_csv() do
    Application.app_dir(:airports, "/priv/airports.csv")
  end

  @spec open_airports :: list
  def open_airports() do
    airports_csv()
    |> File.stream!()
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
        [row] = CSV.parse_string(row, skip_headers: false)
      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
    |> Flow.reject(&(&1.type == "closed"))
    |> Flow.partition(key: {:key, :country})
    |> Flow.group_by(& &1.country)
    |> Flow.map(fn {country, data} -> {country, Enum.count(data)} end)
    |> Flow.take_sort(10, fn {_, a}, {_, b} -> a > b end)
    |> Enum.to_list()
    |> List.flatten()
  end

  def open_trigger() do
    window = Flow.Window.trigger_every(Flow.Window.global(), 1000)

    airports_csv()
    |> File.stream!()
    |> Stream.map(fn event ->
      Process.sleep(Enum.random([0,0,0,1]))
      event
    end)
    |> Flow.from_enumerable()
    |> Flow.map(fn row ->
        [row] = CSV.parse_string(row, skip_headers: false)
      %{
        id: Enum.at(row, 0),
        type: Enum.at(row, 2),
        name: Enum.at(row, 3),
        country: Enum.at(row, 8)
      }
    end)
    |> Flow.reject(&(&1.type == "closed"))
    |> Flow.partition(window: window, key: {:key, :country})
    |> Flow.group_by(& &1.country)
    |> Flow.on_trigger(fn acc, _partition_info, {_type, _id, trigger} ->
      events =
        acc
        |> Enum.map(fn {country, data} -> {country, Enum.count(data)} end)
        |> IO.inspect(label: inspect(self()))

      case trigger do
        :done ->
          {events, acc}
        {:every, 1000} ->
          {[], acc}
      end
    end)
    |> Enum.sort(fn {_, a}, {_, b} -> a > b end)
    |> Enum.take(10)
    |> List.flatten()
  end
end
