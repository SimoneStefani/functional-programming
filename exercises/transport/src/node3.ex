defmodule Node3 do

  def start(id, hub) do
    {:ok, spawn(fn -> init(id, hub) end)}
  end

  defp init(id, hub) do
    {:ok, tcp} = Transport.start(self())
    {:ok, net} = Network.start(self(), id)

    {:ok, link} = Link.start(net)
    send(net, {:connect, link})
    send(hub, {:connect, link})
    send(link, {:connect, hub})
    node(id, net)
  end

  defp node(id, net) do
    receive do
      {:send, to, msg} ->
        send(net, {:send, to, msg})
        node(id, net)

      msg ->
        IO.puts("Node: #{id} received #{msg}")
        node(id, net)
    end
  end

end
