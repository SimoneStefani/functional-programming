defmodule Test do
  
  def link() do
    s = spawn(fn -> link_sender() end)
    r = spawn(fn -> link_receiver() end)
    {:ok, ls} = Link.start(s)
    {:ok, lr} = Link.start(r)
    send(ls, {:connect, lr})
    send(lr, {:connect, ls})
    send(s, {:connect, ls})
    send(r, {:connect, lr})
    :ok
  end

  def link_sender() do
    receive do
      {:connect, n} ->
        IO.puts("Sender connected, sending hello!")
        send(n, {:send, :hello})
        receive do
          msg ->
            IO.puts("Sender received #{msg}")
        end
    end
  end

  def link_receiver() do
    receive do
      {:connect, n} ->
        IO.puts("Receiver connected!")
        receive do
          msg ->
            IO.puts("Receiver received #{msg}")
        end
        send(n, {:send, :pew})
    end
  end

end