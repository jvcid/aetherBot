# MeuBot — Bot do Discord em Elixir

Bot desenvolvido em Elixir com o framework Nostrum para a disciplina T300 - Programação Funcional (UNIFOR).

## Comandos disponíveis

| Comando | Descrição | API utilizada |
|---|---|---|
| `!ping` | Verifica se o bot está online | — |
| `!piada [categoria]` | Conta uma piada (general, programming, knock-knock) | Official Joke API |
| `!clima <cidade>` | Mostra temperatura, umidade e vento | Open-Meteo |
| `!traduzir <idioma> <texto>` | Traduz texto para outro idioma (en, es, fr...) | MyMemory API |
| `!conv <valor> <de> <para>` | Converte entre moedas (USD, BRL, EUR...) | ExchangeRate API |
| `!lembrar <texto>` | Salva um lembrete persistente | Arquivo local JSON |
| `!lembretes` | Lista seus lembretes salvos | Arquivo local JSON |
| `!curiosidade <cidade>` | Clima da cidade descrito em português e inglês | Open-Meteo + MyMemory |
| `!ajuda` | Lista todos os comandos | — |

## Pré-requisitos

- Elixir >= 1.14
- Erlang/OTP >= 25

## Configuração do Token

Antes de rodar o bot, exporte o token como variável de ambiente no terminal:

```bash
# Linux / macOS
export DISCORD_TOKEN="seu_token_aqui"

# Windows (PowerShell)
$env:DISCORD_TOKEN="seu_token_aqui"
```

## Instalação e execução

```bash
# 1. Clone o repositório
git clone <https://github.com/jvcid/aetherBot>
cd meu_bot

# 2. Instale as dependências
mix deps.get

# 3. Execute o bot (com o token já exportado)
mix run --no-halt
```

## Estrutura do projeto

```
lib/
├── meu_bot.ex              # Application + Supervisor principal
└── meu_bot/
    ├── consumer.ex         # Handler de eventos do Discord (pattern matching)
    ├── commands.ex         # Implementação de cada comando
    └── store.ex            # Persistência JSON via GenServer
config/
└── config.exs              # Configuração do Nostrum (lê token do ambiente)
```

## Arquitetura

- **MeuBot** — ponto de entrada da aplicação, inicializa o Supervisor
- **MeuBot.Consumer** — recebe eventos do Discord e despacha comandos via pattern matching
- **MeuBot.Commands** — funções puras para cada comando, chamadas HTTP com HTTPoison
- **MeuBot.Store** — GenServer que mantém estado em memória e persiste em `lembretes.json`

## APIs utilizadas

Todas as APIs são gratuitas e não exigem cadastro ou chave:

- [Open-Meteo](https://open-meteo.com/) — clima e geocodificação
- [Official Joke API](https://official-joke-api.appspot.com/) — piadas
- [MyMemory](https://mymemory.translated.net/) — tradução
- [ExchangeRate-API](https://open.er-api.com/) — câmbio de moedas
