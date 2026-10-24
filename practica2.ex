defmodule Palillo do
@doc "Inicia el proceso actor que representa a un palillo."
  def start(id) do
    spawn(fn -> loop(id, :libre) end)
  end

  # Bucle que mantiene el estado
  def loop(id, estado) do
    receive do
      # Si está libre, otorga el palillo y pasa a estar ocupado
      {:solicitar, filosofo} when estado == :libre ->
        send(filosofo, :recibido)
        loop(id, :ocupado)

      # Se libera el palillo
      {:liberar, _ } ->
        loop(id, :libre)

      :liberar ->
        loop(id, :libre)
    end
  end
end

defmodule Filosofo do
  @doc "Inicia el proceso actor que representa a un filósofo."

  def start(id, pid_izq, pid_der, id_izq, id_der) do
    spawn(fn -> ciclo(id, pid_izq, pid_der, id_izq, id_der) end)
  end

  # Se lleva a cabo los procesos de los filósofos
  defp ciclo(id, pid_izq, pid_der, id_izq, id_der) do
    pensar(id)
    solicitar_palillos(id, pid_izq, pid_der, id_izq, id_der)
    comer(id)
    liberar_palillos(id, pid_izq, pid_der, id_izq, id_der)

    ciclo(id, pid_izq, pid_der, id_izq, id_der)
  end
  # Los filósofos estan pensando
  defp pensar(id) do
    IO.puts("Filósofo #{id} está pensando.")
    Process.sleep(Enum.random(3000..5000))
  end

  # Los filósofos tienen hambre y piden los palillos

  defp solicitar_palillos(id, pid_izq, pid_der, id_izq, id_der) do
    IO.puts("Filósofo #{id} tiene hambre.")
    IO.puts("Filósofo #{id} solicita los palillos #{id_izq} y #{id_der}.")


  # Se usa la asimetria para evitar un estado deadlock, si es par pedira el dercho primero y si es impar perdira el izquierdo
    {p1, p2, label1, label2} = if rem(id, 2) == 0 do
        {pid_der, pid_izq, "derecho", "izquierdo"}
      else
        {pid_izq, pid_der, "izquierdo", "derecho"}
      end


    # Pide el primer palillo
    send(p1, {:solicitar, self()})
    receive do
      :recibido -> IO.puts("Filósofo #{id} obtuvo el palillo #{label1}.")
    end

    # Pide el segundo palillo
    send(p2, {:solicitar, self()})
    receive do
      :recibido -> IO.puts("Filósofo #{id} obtuvo el palillo #{label2}.")
    end
  end


  # Los filosofos comen
  defp comer(id) do
    IO.puts("Filósofo #{id} está comiendo.")
    Process.sleep(Enum.random(3000..5000))
    IO.puts("Filósofo #{id} terminó de comer.")
  end

  #Termina de comer y libera ambos palillos
  defp liberar_palillos(id, pid_izq, pid_der, id_izq, id_der) do
    send(pid_izq, {:liberar, self()})
    IO.puts("Filósofo #{id} liberó el palillo #{id_izq}.")

    send(pid_der, {:liberar, self()})
    IO.puts("Filósofo #{id} liberó el palillo #{id_der}.")

  end
end


defmodule Mesa do
  @doc "Inicializa la simulación creando los 5 palillos y los 5 filósofos en anillo."
  def start() do
    # Inicialización de los procesos de los palillos
    p1 = Palillo.start(1)
    p2 = Palillo.start(2)
    p3 = Palillo.start(3)
    p4 = Palillo.start(4)
    p5 = Palillo.start(5)

    # Asignación de palillos adyacentes a cada filósofo

    Filosofo.start(1, p5, p1, 5, 1)
    Filosofo.start(2, p1, p2, 1, 2)
    Filosofo.start(3, p2, p3, 2, 3)
    Filosofo.start(4, p3, p4, 3, 4)
    Filosofo.start(5, p4, p5, 4, 5)

  end
end
