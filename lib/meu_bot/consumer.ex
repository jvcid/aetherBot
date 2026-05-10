defmodule MeuBot.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias MeuBot.Commands

  # ── Despacho de comandos via pattern matching ──────────────────

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    despachar(msg)
  end

  def handle_event(_evento), do: :ok

  # Ignora mensagens de outros bots
  defp despachar(%{author: %{bot: true}}), do: :ok

  # !ping — sem parâmetro
  defp despachar(%{content: "!ping", channel_id: canal}) do
    resposta = Commands.ping()
    Api.create_message(canal, resposta)
  end

  # !piada — sem parâmetro (usa categoria padrão)
  defp despachar(%{content: "!piada", channel_id: canal}) do
    resposta = Commands.piada()
    Api.create_message(canal, resposta)
  end

  # !piada <categoria> — um parâmetro
  defp despachar(%{content: "!piada " <> categoria, channel_id: canal}) do
    resposta = Commands.piada(String.trim(categoria))
    Api.create_message(canal, resposta)
  end

  # !clima <cidade> — um parâmetro
  defp despachar(%{content: "!clima " <> cidade, channel_id: canal}) do
    resposta = Commands.clima(String.trim(cidade))
    Api.create_message(canal, resposta)
  end

  # !traduzir <idioma> <texto> — dois ou mais parâmetros
  defp despachar(%{content: "!traduzir " <> resto, channel_id: canal}) do
    resposta =
      case String.split(resto, " ", parts: 2) do
        [idioma, texto] -> Commands.traduzir(String.trim(idioma), String.trim(texto))
        _ -> "❌ Use assim: `!traduzir <idioma> <texto>` — ex: `!traduzir en Bom dia`"
      end

    Api.create_message(canal, resposta)
  end

  # !conv <valor> <de> <para> — dois ou mais parâmetros
  defp despachar(%{content: "!conv " <> resto, channel_id: canal}) do
    resposta =
      case String.split(String.trim(resto), " ") do
        [valor, de, para] -> Commands.converter(valor, de, para)
        _ -> "❌ Use assim: `!conv <valor> <moeda_origem> <moeda_destino>` — ex: `!conv 100 USD BRL`"
      end

    Api.create_message(canal, resposta)
  end

  # !lembrar <texto> — persistência (salvar)
  defp despachar(%{content: "!lembrar " <> texto, channel_id: canal, author: %{id: uid}}) do
    resposta = Commands.lembrar(uid, String.trim(texto))
    Api.create_message(canal, resposta)
  end

  # !lembretes — persistência (ler)
  defp despachar(%{content: "!lembretes", channel_id: canal, author: %{id: uid}}) do
    resposta = Commands.lembretes(uid)
    Api.create_message(canal, resposta)
  end

  # !curiosidade <cidade> — combina duas APIs
  defp despachar(%{content: "!curiosidade " <> cidade, channel_id: canal}) do
    resposta = Commands.curiosidade(String.trim(cidade))
    Api.create_message(canal, resposta)
  end

  # !ajuda — lista todos os comandos
  defp despachar(%{content: "!ajuda", channel_id: canal}) do
    resposta = """
    🤖 **Comandos disponíveis:**

    `!ping` — Verifica se o bot está online
    `!piada` — Conta uma piada aleatória (em inglês)
    `!piada <categoria>` — Piada de uma categoria (general, programming, knock-knock)
    `!clima <cidade>` — Mostra o clima atual de uma cidade
    `!traduzir <idioma> <texto>` — Traduz um texto (ex: `!traduzir en Bom dia`)
    `!conv <valor> <de> <para>` — Converte moedas (ex: `!conv 100 USD BRL`)
    `!lembrar <texto>` — Salva um lembrete para você
    `!lembretes` — Lista seus lembretes salvos
    `!curiosidade <cidade>` — Curiosidade climática sobre uma cidade em pt e en
    """

    Api.create_message(canal, resposta)
  end

  # Ignora qualquer outra mensagem
  defp despachar(_msg), do: :ok
end
