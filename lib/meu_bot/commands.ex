defmodule MeuBot.Commands do

  def ping do
    "Pong!"
  end

  def clima(cidade) do
    url =
      "https://geocoding-api.open-meteo.com/v1/search?name=#{URI.encode(cidade)}&count=1"

    case HTTPoison.get(url) do
      {:ok, resposta} ->

        json =
          Jason.decode!(resposta.body)

        cidade_info =
          hd(json["results"])

        lat =
          cidade_info["latitude"]

        lon =
          cidade_info["longitude"]

        nome =
          cidade_info["name"]

        clima_url =
          "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&current=temperature_2m"

        case HTTPoison.get(clima_url) do
          {:ok, clima_resposta} ->

            clima_json =
              Jason.decode!(clima_resposta.body)

            temperatura =
              clima_json["current"]["temperature_2m"]

            "Clima em #{nome}: #{temperatura}°C"

          _ ->
            "Erro ao buscar clima"
        end

      _ ->
        "Cidade não encontrada"
    end
  end

  def piada(categoria) do
    url =
      "https://official-joke-api.appspot.com/jokes/#{categoria}/random"

    case HTTPoison.get(url) do
      {:ok, resposta} ->

        json =
          Jason.decode!(resposta.body)

        piada =
          hd(json)

        "#{piada["setup"]}\n#{piada["punchline"]}"

      _ ->
        "Erro ao buscar piada"
    end
  end

  def converter(valor_str, de, para) do
    valor =
      String.to_float(valor_str)

    url =
      "https://open.er-api.com/v6/latest/#{String.upcase(de)}"

    case HTTPoison.get(url) do
      {:ok, resposta} ->

        json =
          Jason.decode!(resposta.body)

        taxa =
          json["rates"][String.upcase(para)]

        resultado =
          valor * taxa

        "#{Float.round(resultado, 2)} #{String.upcase(para)}"

      _ ->
        "Erro na conversão"
    end
  end

  def traduzir(idioma, texto) do
    url =
      "https://api.mymemory.translated.net/get?q=#{URI.encode(texto)}&langpair=pt|#{idioma}"

    case HTTPoison.get(url) do
      {:ok, resposta} ->

        json =
          Jason.decode!(resposta.body)

        json["responseData"]["translatedText"]

      _ ->
        "Erro na tradução"
    end
  end

  def lembrar(usuario_id, texto) do
    MeuBot.Store.salvar(usuario_id, texto)

    "Lembrete salvo"
  end

  def lembretes(usuario_id) do
    lista =
      MeuBot.Store.buscar(usuario_id)

    Enum.join(lista, "\n")
  end

  def curiosidade(cidade) do
    url =
      "https://geocoding-api.open-meteo.com/v1/search?name=#{URI.encode(cidade)}&count=1"

    case HTTPoison.get(url) do
      {:ok, resposta} ->

        json =
          Jason.decode!(resposta.body)

        cidade_info =
          hd(json["results"])

        lat =
          cidade_info["latitude"]

        lon =
          cidade_info["longitude"]

        nome =
          cidade_info["name"]

        clima_url =
          "https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{lon}&current=temperature_2m"

        case HTTPoison.get(clima_url) do
          {:ok, clima_resposta} ->

            clima_json =
              Jason.decode!(clima_resposta.body)

            temperatura =
              clima_json["current"]["temperature_2m"]

            texto =
              "A temperatura em #{nome} é #{temperatura} graus"

            traducao_url =
              "https://api.mymemory.translated.net/get?q=#{URI.encode(texto)}&langpair=pt|en"

            case HTTPoison.get(traducao_url) do
              {:ok, traducao_resposta} ->

                traducao_json =
                  Jason.decode!(traducao_resposta.body)

                traducao =
                  traducao_json["responseData"]["translatedText"]

                "#{texto}\n#{traducao}"

              _ ->
                "Erro na tradução"
            end

          _ ->
            "Erro ao buscar clima"
        end

      _ ->
        "Cidade não encontrada"
    end
  end
end
