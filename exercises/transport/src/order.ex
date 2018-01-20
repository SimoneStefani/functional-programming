defmodule Order do

  def start(master, to) do
    {:ok, spawn(fn -> init(master, to) end)}
  end

  defp init(master, to) do
    receive do
      {:connect, net} ->
        order(master, to, 0, 0, [], net)
    end
  end

  defp order(master, to, n, i, [], net) do
    receive do
      %Datagram{id: ^i} = dgr ->
        send(net, {:send, to, %Ack{id: i}})
        send(master, dgr.data)
        order(master, to, n, i + 1, [], net)

      %Datagram{id: j} when j < i ->
        send(net, {:send, to, %Ack{id: j}})
        order(master, to, n, i, [], net)

      %Ack{} ->
        order(master, to, n, i, [], net)

      {:send, msg} ->
        send(net, {:send, to, %Datagram{id: n, data: msg}})
        order(master, to, n + 1, i, [{n, msg}], net)

      {:master, new} ->
        order(new, to, n, i, [], net)
    end
  end

  defp order(master, to, n, i, [{a, res} | rest] = buffer, net) do
    receive do
      %Datagram{id: ^i} = dgr ->
        send(net, {:send, to, %Ack{id: i}})
        send(master, dgr.data)
        order(master, to, n, i + 1, buffer, net)

      %Datagram{id: j} when j < i ->
        send(net, {:send, to, %Ack{id: j}})
        order(master, to, n, i, buffer, net)

      %Ack{id: ^a} ->
        order(master, to, n, i, rest, net)

      %Ack{id: b} when b < a ->
        order(master, to, n, i, buffer, net)

      {:send, msg} ->
        send(net, {:send, to, %Datagram{id: n, data: msg}})
        order(master, to, n + 1, i, buffer ++ [{n, msg}], net)

      {:master, new} ->
        order(new, to, n, i, buffer, net)
    after
      10 ->
        dgr = %Datagram{id: a, data: res}
        IO.puts("Order resending #{dgr}")
        send(net, {:send, to, dgr})
        order(master, to, n, i, buffer, net)
    end
  end

end
