defmodule MeuBot.Commands do
  @moduledoc """
  Implementação de cada comando do bot.
  Cada função pública corresponde a um comando do Discord.
  """

  # ── !ping ──────────────────────────────────────────────────────
  # Tipo: sem parâmetro
  # API: nenhuma

  def ping do
    "🏓 Pong! Estou vivo e funcionando!"
  end

  # ── !clima <cidade> ────────────────────────────────────────────
  # Tipo: um parâmetro
  # API: Open-Meteo (geocoding + clima, grátis, sem chave)

  def clima(cidade) do
    with {:ok, {lat, lon, nome}} <- geocodificar(cidade),
         {:ok, dados} <- buscar_clima(lat, lon) do
      temperatura = dados["current"]["temperature_2m"]
      umidade = dados["current"]["relative_humidity_2m"]
      vento = dados["current"]["wind_speed_10m"]

      """
      🌤️ **Clima em #{nome}**
      🌡️ Temperatura: #{temperatura}°C
      💧 Umidade: #{umidade}%
      💨 Vento: #{vento} km/h
      """
    else
      {:erro, motivo} -> "❌ Não consegui buscar o clima: #{motivo}"
    end
  end

  defp geocodificar(cidade) do
    url = "https://geocoding-api.open-meteo.com/v1/search?name=#{URI.encode(cidade)}&count=1&language=pt"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"results" => [primeiro | _]}} ->
            lat = primeiro["latitude"]
            lon = primeiro["longitude"]
            nome = primeiro["name"]
            {:ok, {lat, lon, nome}}

          _ ->
            {:erro, "cidade não encontrada"}
        end

      _ ->
        {:erro, "falha na requisição"}
    end
  end

  defp buscar_clima(lat, lon) do
    url =
      "https://api.open-meteo.com/v1/forecast" <>
        "?latitude=#{lat}&longitude=#{lon}" <>
        "&current=temperature_2m,relative_humidity_2m,wind_speed_10m"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} -> Jason.decode(body)
      _ -> {:erro, "falha ao buscar dados meteorológicos"}
    end
  end

  # ── !piada ─────────────────────────────────────────────────────
  # Tipo: um parâmetro (categoria opcional, padrão "general")
  # API: Official Joke API (grátis, sem chave)

  def piada(categoria \\ "general") do
    url = "https://official-joke-api.appspot.com/jokes/#{URI.encode(categoria)}/random"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, [%{"setup" => pergunta, "punchline" => resposta} | _]} ->
            "😄 **#{pergunta}**\n||#{resposta}||"

          {:ok, %{"setup" => pergunta, "punchline" => resposta}} ->
            "😄 **#{pergunta}**\n||#{resposta}||"

          _ ->
            "❌ Não encontrei piadas nessa categoria. Tente: general, programming, knock-knock"
        end

      _ ->
        "❌ Não consegui buscar uma piada agora."
    end
  end

  # ── !conv <valor> <de> <para> ──────────────────────────────────
  # Tipo: dois ou mais parâmetros
  # API: ExchangeRate-API (grátis, sem chave para taxa básica)

  def converter(valor_str, moeda_de, moeda_para) do
    with {valor, _} <- Float.parse(valor_str),
         {:ok, taxa} <- buscar_taxa(String.upcase(moeda_de), String.upcase(moeda_para)) do
      resultado = valor * taxa
      resultado_formatado = :erlang.float_to_binary(resultado, decimals: 2)
      valor_formatado = :erlang.float_to_binary(valor, decimals: 2)

      "💱 #{valor_formatado} #{String.upcase(moeda_de)} = **#{resultado_formatado} #{String.upcase(moeda_para)}**"
    else
      :error -> "❌ Valor inválido. Use números, ex: `!conv 100 USD BRL`"
      {:erro, motivo} -> "❌ Erro na conversão: #{motivo}"
    end
  end

  defp buscar_taxa(de, para) do
    url = "https://open.er-api.com/v6/latest/#{de}"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"rates" => taxas}} ->
            case Map.fetch(taxas, para) do
              {:ok, taxa} -> {:ok, taxa}
              :error -> {:erro, "moeda #{para} não encontrada"}
            end

          _ ->
            {:erro, "resposta inválida da API"}
        end

      _ ->
        {:erro, "falha na requisição"}
    end
  end

  # ── !traduzir <idioma> <texto> ─────────────────────────────────
  # Tipo: dois ou mais parâmetros
  # API: MyMemory Translation API (grátis, sem chave)

  def traduzir(idioma_destino, texto) do
    par = "pt|#{idioma_destino}"
    url = "https://api.mymemory.translated.net/get?q=#{URI.encode(texto)}&langpair=#{par}"

    case HTTPoison.get(url) do
      {:ok, %{status_code: 200, body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"responseData" => %{"translatedText" => traducao}}} ->
            "🌐 **Tradução (#{idioma_destino}):**\n#{traducao}"

          _ ->
            "❌ Não consegui traduzir. Verifique o código do idioma (ex: en, es, fr, de, ja)"
        end

      _ ->
        "❌ Falha ao conectar com o serviço de tradução."
    end
  end

  # ── !lembrar <texto> ───────────────────────────────────────────
  # Tipo: persistência JSON
  # API: nenhuma (arquivo local via MeuBot.Store)

  def lembrar(usuario_id, texto) do
    case MeuBot.Store.salvar(usuario_id, texto) do
      :ok -> "📝 Anotado! Vou me lembrar disso para você."
      _ -> "❌ Não consegui salvar seu lembrete."
    end
  end

  def lembretes(usuario_id) do
    case MeuBot.Store.buscar(usuario_id) do
      [] ->
        "📭 Você não tem nenhum lembrete salvo. Use `!lembrar <texto>` para adicionar."

      lista ->
        itens =
          lista
          |> Enum.with_index(1)
          |> Enum.map(fn {item, i} -> "#{i}. #{item}" end)
          |> Enum.join("\n")

        "📋 **Seus lembretes:**\n#{itens}"
    end
  end

  # ── !curiosidade <cidade> ──────────────────────────────────────
  # Tipo: combina duas APIs
  # API 1: Open-Meteo (busca o clima atual)
  # API 2: MyMemory (traduz a descrição do clima para inglês)

  def curiosidade(cidade) do
    with {:ok, {lat, lon, nome}} <- geocodificar(cidade),
         {:ok, dados} <- buscar_clima(lat, lon) do
      temperatura = dados["current"]["temperature_2m"]
      umidade = dados["current"]["relative_humidity_2m"]

      descricao_pt = "Agora em #{nome} a temperatura é de #{temperatura} graus e a umidade é de #{umidade} porcento."

      url = "https://api.mymemory.translated.net/get?q=#{URI.encode(descricao_pt)}&langpair=pt|en"

      descricao_en =
        case HTTPoison.get(url) do
          {:ok, %{status_code: 200, body: body}} ->
            case Jason.decode(body) do
              {:ok, %{"responseData" => %{"translatedText" => trad}}} -> trad
              _ -> "Translation unavailable"
            end

          _ ->
            "Translation unavailable"
        end

      """
      🌍 **Curiosidade sobre #{nome}**
      🇧🇷 #{descricao_pt}
      🇬🇧 #{descricao_en}
      """
    else
      {:erro, motivo} -> "❌ Não encontrei informações sobre essa cidade: #{motivo}"
    end
  end
end
