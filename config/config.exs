import Config

config :nostrum,
  token: "token",
  gateway_intents: [
    :guilds,
    :guild_messages,
    :message_content
  ]
