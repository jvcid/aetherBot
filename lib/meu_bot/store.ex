defmodule MeuBot.Store do
  use GenServer

  @arquivo "lembretes.json"

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def salvar(usuario_id, texto) do
    GenServer.call(__MODULE__, {:salvar, usuario_id, texto})
  end

  def buscar(usuario_id) do
    GenServer.call(__MODULE__, {:buscar, usuario_id})
  end

  def init(_args) do
    {:ok, ler_arquivo()}
  end

  def handle_call({:salvar, usuario_id, texto}, _from, estado) do
    chave = Integer.to_string(usuario_id)

    lista =
      Map.get(estado, chave, [])

    novo_estado =
      Map.put(estado, chave, lista ++ [texto])

    gravar_arquivo(novo_estado)

    {:reply, :ok, novo_estado}
  end

  def handle_call({:buscar, usuario_id}, _from, estado) do
    chave = Integer.to_string(usuario_id)

    lista =
      Map.get(estado, chave, [])

    {:reply, lista, estado}
  end

  defp ler_arquivo do
    case File.read(@arquivo) do
      {:ok, conteudo} ->
        case Jason.decode(conteudo) do
          {:ok, dados} -> dados
          _ -> %{}
        end

      _ ->
        %{}
    end
  end

  defp gravar_arquivo(estado) do
    json =
      Jason.encode!(estado, pretty: true)

    File.write!(@arquivo, json)
  end
end
