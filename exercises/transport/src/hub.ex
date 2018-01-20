defmodule Hub do

  def start(), do: {:ok, spawn(fn -> init() end)}

  defp init(), do: hub([])

  defp hub(connected) do
    receive do
      {:connected, pid} ->
        ref = Process.monitor(pid)
        hub([{ref, pid} | connected])

      {:disconnect, pid} ->
        {ref, pid} = List.keyfind(connected, pid, 1)
        Process.demonitor(ref)
        hub(List.keydelete(connected, pid, 1))

      {:DOWN, ref, :process, _, _} ->
        hub(List.keydelete(connected, ref, 0))

      %Frame{} = frm ->
        Enum.each(connected, fn({_, pid}) -> send(pid, frm) end)
        hub(connected)

      :status ->
        IO.puts("Connect to: #{connected}")
        hub(connected)

      :quit ->
        :ok
    end
  end

end
