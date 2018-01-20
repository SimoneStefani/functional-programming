defmodule Link do

  def start(master) do
    lnk = spawn(fn -> init(master) end)
    {:ok, lnk}
  end

  defp init(master) do
    receive do
      {:connect, lnk} ->
        link(master, lnk)

      :quit ->
        :ok
    end
  end

  defp link(master, lnk) do
    receive do
      {:send, msg} ->
        send(lnk, %Frame{data: msg})
        link(master, lnk)

      %Frame{} = frame ->
        send(master, frame.data)
        link(master, lnk)

      {:master, new} ->
        link(new, lnk)

      :status ->
        IO.puts("Master: #{master}; Link: #{lnk}")
        link(master, lnk)

      :quit ->
        :ok
    end
  end

end
