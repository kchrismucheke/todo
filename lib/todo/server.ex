defmodule Todo.Server do
    use GenServer

    #Client
    def start_link(opts) do
        GenServer.start_link(__MODULE__, :ok, opts)
    end

    def list() do
        GenServer.call(__MODULE__, {:list})
    end
        
    def add(todo) do
        GenServer.call(__MODULE__, {:add, todo})
    end

    def  remove(id) do
        GenServer.call(__MODULE__,  {:delete, id})
    end

    def  toggle(id) do
        GenServer.call(__MODULE__,  {:toggle, id})
    end

    def  handle_call({:toggle, id},  _from, state) do
        [todo]  =  Enum.filter(state,  fn x -> x.id == id end)
        toggled_todo = %{todo |  done:  !todo.done}
        new_state =
            state
            |>  Enum.map(fn x ->
                    if is_id?(x, id) do 
                        toggled_todo 
                    else 
                        x
                    end
                end)
        {:reply, new_state, new_state}
    end
    
    def  handle_call({:delete, id},  _from, state) do
        new_state =
        state
        |>  Enum.filter(fn x ->
                !is_id?(x, id)
            end)
        {:reply, new_state, new_state}
    end


    #Server
    def init(:ok) do
        {:ok, []}
    end

    def  handle_call({:list},  _from, state) do
        {:reply, state, state}
    end
    
    def handle_call({:add, todo}, _from, state) do
        new_todo = %{name: todo, done: false, id: generate_id()}
        new_state = state ++ [new_todo]
        {:reply, new_state, new_state}
    end

    #Private
    defp generate_id() do
        :crypto.strong_rand_bytes(64)
        |> Base.url_encode64()
        |> binary_part(0, 64)
    end

    defp is_id?(x, id), do: x.id == id

end