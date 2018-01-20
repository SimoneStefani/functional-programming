defmodule Flow do

  def start(size), do: {:ok, spawn(fn -> init(size) end)}

  defp init(size) do
    receive do
      {:connect, net} ->
        IO.puts("Flow connecting to #{net}")
        send(net, {:send, %Syn{add: size}})
        flow(size, 0, [], net)
    end
  end

  defp flow(s, 0, buffer, net) do
    receive do
      %Syn{} = syn ->
        flow(s, syn.add, buffer, net)
    end
  end
  defp flow(s, t, [], net) do
    receive do
      {:send, msg, pid} ->
        send(net, {:send, %Message{data: msg}})
        send(pid, :ok)
        flow(s, t - 1, [], net)

      %Message{} = msg ->
        flow(s - 1, t, [msg.data], net)

      %Syn{} = syn ->
        flow(s, t + syn.add, [], net)
    end
  end
  defp flow(s, t, buffer, net) do
    receive do
      {:send, msg, pid} ->
        send(net, {:send, %Message{data: msg}})
        send(pid, :ok)
        flow(s, t - 1, buffer, net)

      {:read, n, pid} ->
        {i, deliver, rest} = read(n, buffer)
        send(pid, {:ok, i, deliver})
        send(net, {:send, %Syn{add: i}})
        flow(s + i, t, rest, net)

      %Message{} = msg ->
        flow(s - 1, t, buffer ++ [msg.data], net)

      %Syn{} = syn ->
        flow(s, t + syn.add, buffer, net)
    end
  end

  defp read(n, buffer) do
    l = length(buffer)

    cond do
      n <= l ->
        {deliver, keep} = Enum.split(buffer, n)
        {n, deliver, keep}

      true ->
        {l, buffer, []}
    end
  end

end
