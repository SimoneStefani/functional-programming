defmodule Bench do

  def bench() do
    bench(1,30)
  end	

  def bench(n,l) do
    {t, _} = :timer.tc(fn () -> eager(n,l) end)
    IO.puts("interpreter nreverse in #{t} us")
    {t, _} = :timer.tc(fn () -> native(n,l) end)
    IO.puts("native nreverse in #{t} us")    
  end


  def eager(n,l) do
    lst = list(l)
    seq = [
      {:match, {:var, :x},  lst},
      {:call, :nreverse, [{:var, :x}]}
    ]
    prgm = prg()
    rn = fn() -> Eager.eval(seq, prgm) end
    run(n, rn)
  end

  def native(n,l) do
    lst = :lists.seq(1,l)
    rn = fn() -> nreverse(lst) end
    run(n, rn)
  end	   

  def nreverse([]) do [] end
  def nreverse([h|t]) do
    nreverse(t) ++ [h]
  end		

  def run(0,_) do :ok end
  def run(n, f) do 
    f.()
    run(n-1, f)
  end

  def list(0) do
    {:atm, :nil}
  end
  def list(n) do
    {:cons, {:atm, n}, list(n-1)}
  end  


  def prg() do
    [
      {:nreverse, [:x],
       [
         {:case, {:var, :x},
          [
            {:clause, {:atm, []}, [{:atm, []}]},
            {:clause, {:cons, {:var, :hd}, {:var, :tl}},
             [
               {:call, :append,
                [{:call, :nreverse, [{:var, :tl}]}, {:cons, {:var, :hd}, {:atm, []}}]}
             ]}
          ]}
       ]},
      {:append, [:x, :y],
       [
         {:case, {:var, :x},
          [
            {:clause, {:atm, []}, [{:var, :y}]},
            {:clause, {:cons, {:var, :hd}, {:var, :tl}},
             [{:cons, {:var, :hd}, {:call, :append, [{:var, :tl}, {:var, :y}]}}]}
          ]}
       ]}
     ]
   end	
       
 



end



