defmodule Network do

  def start(master, id) do
    con = spawn(fn -> init(master, id) end)
    {:ok, con}
  end

  defp init(master, id) do
    receive do
      {:connect, link} ->
        IO.puts("Network layer #{id} connected!")
        network(master, id, link)

      :quit ->
        :ok
    end
  end

  defp network(master, id, link) do
    receive do
      {:send, to, msg} ->
        IO.puts("Network layer #{id} sending: #{msg}")
        send(link, {:send, %Message{src: id, dst: to, data: msg}})
        network(master, id, link)

      %Message{dst: ^id} = msg ->
        IO.puts("Network layer #{id} received: #{msg.data}")
        send(master, msg)
        network(master, id, link)

      %Message{} ->
        network(master, id, link)

      {:master, new} ->
        network(new, id, link)

      :status ->
        IO.puts("Master: #{master}; Id: #{id}; Link: #{link}")
        network(master, id, link)

      :quit ->
        :ok
    end
  end

end
