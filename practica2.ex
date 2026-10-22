defmodule Palillo do
@doc "Inicia el proceso actor que representa a un palillo."
  def start() do
    spawn(fn -> loop(:libre) end)
  end

  # Bucle que mantiene el estado
  def loop(estado) do
    receive do
      # Si está libre, otorga el palillo y pasa a estar ocupado
      {:solicitar, filosofo} when estado == :libre ->
        send(filosofo, :recibido)
        loop(:ocupado)

      # Se libera el palillo
      :liberar ->
        loop(:libre)
    end
  end
end

defmodule Filosofo do
  @doc "Inicia el proceso actor que representa a un filósofo."

  def start(id, pid_palillo_izq, pid_palillo_der) do
    spawn(fn -> ciclo(id, pid_palillo_izq, pid_palillo_der) end)
  end

  # Se lleva a cabo los procesos de los filósofos
  defp ciclo(id, pid_palillo_izq, pid_palillo_der) do
    pensar(id)
    solicitar_palillos(id, pid_palillo_izq, pid_palillo_der)
    comer(id)
    liberar_palillos(pid_palillo_izq, pid_palillo_der)

    ciclo(id, pid_palillo_izq, pid_palillo_der)
  end
  # Los filósofos estan pensando
  defp pensar(id) do
    IO.puts("Filósofo #{id} está pensando.")
    Process.sleep(Enum.random(500..1500))
  end

  # Los filósofos tienen hambre y piden los palillos

  defp solicitar_palillos(id, pid_palillo_izq, pid_palillo_der) do
    IO.puts("Filósofo #{id} tiene hambre.")

    # Pide el palillo izquierdo y espera a recibirlo
    send(pid_palillo_izq, {:solicitar, self()})
    receive do
      :recibido -> IO.puts("Filósofo #{id} obtuvo el palillo izquierdo.")
    end

    # Pide el palillo derecho y espera a recibirlo
    send(pid_palillo_der, {:solicitar, self()})
    receive do
      :recibido -> IO.puts("Filósofo #{id} obtuvo el palillo derecho.")
    end
  end


  # Los filosofos comen
  defp comer(id) do
    IO.puts("Filósofo #{id} está comiendo.")
    Process.sleep(Enum.random(500..1500))
  end

  #Termina de comer y libera ambos palillos
  defp liberar_palillos(pid_palillo_izq, pid_palillo_der) do
    send(pid_palillo_izq, :liberar)
    send(pid_palillo_der, :liberar)
  end
end


defmodule Mesa do
  @doc "Inicializa la simulación creando los 5 palillos y los 5 filósofos en anillo."
  def start() do
    # Inicialización de los procesos de los palillos
    p1 = Palillo.start()
    p2 = Palillo.start()
    p3 = Palillo.start()
    p4 = Palillo.start()
    p5 = Palillo.start()

    # Asignación de palillos adyacentes a cada filósofo

    Filosofo.start(1, p5, p1)
    Filosofo.start(2, p1, p2)
    Filosofo.start(3, p2, p3)
    Filosofo.start(4, p3, p4)
    Filosofo.start(5, p4, p5)
  end
end
