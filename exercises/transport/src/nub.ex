defmodule Nub do

  def start(), do: {:ok, spawn(fn -> init(0) end)}

  def start(loss), do: {:ok, spawn(fn -> init(loss) end)}

  defp init(loss), do: hub(loss, [])

  defp hub(loss, connected) do
    receive do
      {:connected, pid} ->
        IO.puts("Connecting to #{pid}")
        ref = Process.monitor(pid)
        hub(loss, [{ref, pid} | connected])

      {:disconnect, pid} ->
        {ref, pid} = List.keyfind(connected, pid, 1)
        Process.demonitor(ref)
        hub(loss, List.keydelete(connected, pid, 1))

      {:DOWN, ref, :process, _, _} ->
        IO.puts("Died #{ref}")
        hub(loss, List.keydelete(connected, ref, 0))

      %Frame{} = frm ->
        lost = :rand.uniform(100) <= loss
        cond do
          lost ->
            IO.puts("Throwing away #{frm}")
            :ok
          true ->
            Enum.each(connected, fn({_, pid}) -> send(pid, frm) end)
        end
        hub(loss, connected)

      :status ->
        IO.puts("Connect to: #{connected}")
        hub(loss, connected)

      :quit ->
        :ok
    end
  end

end
