defmodule Node1 do

  # This node has a direct link to a hub. There is no network layer so
  # all messages that are sent to the hub will arrive at the node.

  def start(id, hub) do
    {:ok, spawn(fn -> init(id, hub) end)}
  end

  defp init(id, hub) do
    {:ok, link} = Link.start(self())
    send(hub, {:connect, link})
    send(link, {:connect, hub})
    node(id, link)
  end

  defp node(id, link) do
    receive do
      {:send, msg} ->
        send(link, {:send, msg})
        node(id, link)

      msg ->
        IO.puts("Node: #{id} received #{msg}")
        node(id, link)
    end
  end

end
