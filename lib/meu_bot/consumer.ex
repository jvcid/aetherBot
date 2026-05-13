defmodule MeuBot.Consumer do
  use Nostrum.Consumer

  alias Nostrum.Api
  alias MeuBot.Commands

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    responder(msg)
  end

  def handle_event(_evento) do
    :ok
  end

  defp responder(%{author: %{bot: true}}) do
    :ok
  end

  defp responder(%{content: "!salve", channel_id: canal}) do
    Api.create_message(canal, Commands.salve())
  end

  defp responder(%{content: "!piada " <> categoria, channel_id: canal}) do
    resposta =
      Commands.piada(String.trim(categoria))

    Api.create_message(canal, resposta)
  end

  defp responder(%{content: "!clima " <> cidade, channel_id: canal}) do
    resposta =
      Commands.clima(String.trim(cidade))

    Api.create_message(canal, resposta)
  end

  defp responder(%{content: "!conv " <> texto, channel_id: canal}) do
    case String.split(texto, " ") do
      [valor, de, para] ->
        resposta =
          Commands.converter(valor, de, para)

        Api.create_message(canal, resposta)

      _ ->
        Api.create_message(canal, "Use: !conv 100 USD BRL")
    end
  end

  defp responder(%{content: "!traduzir " <> texto, channel_id: canal}) do
    case String.split(texto, " ", parts: 2) do
      [idioma, frase] ->
        resposta =
          Commands.traduzir(idioma, frase)

        Api.create_message(canal, resposta)

      _ ->
        Api.create_message(canal, "Use: !traduzir en Bom dia")
    end
  end

  defp responder(%{
         content: "!lembrar " <> texto,
         channel_id: canal,
         author: %{id: usuario_id}
       }) do
    resposta =
      Commands.lembrar(usuario_id, texto)

    Api.create_message(canal, resposta)
  end

  defp responder(%{
         content: "!lembretes",
         channel_id: canal,
         author: %{id: usuario_id}
       }) do
    resposta =
      Commands.lembretes(usuario_id)

    Api.create_message(canal, resposta)
  end

  defp responder(%{content: "!curiosidade " <> cidade, channel_id: canal}) do
    resposta =
      Commands.curiosidade(cidade)

    Api.create_message(canal, resposta)
  end

  defp responder(%{content: "!ajuda", channel_id: canal}) do
    mensagem = """
    !salve
    !piada general
    !clima fortaleza
    !conv 100 USD BRL
    !traduzir en Bom dia
    !lembrar teste
    !lembretes
    !curiosidade fortaleza
    """

    Api.create_message(canal, mensagem)
  end

  defp responder(_msg) do
    :ok
  end
end
