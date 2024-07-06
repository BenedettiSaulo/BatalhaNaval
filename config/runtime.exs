import Config

if System.get_env("PHX_SERVER") do
  config :battleship, BattleshipWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "saulo.agp.app.br"
  port = String.to_integer(System.get_env("PORT") || "4000")

  config :battleship, BattleshipWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    https: [
      port: 443,
      cipher_suite: :strong,
      keyfile: "/etc/letsencrypt/live/saulo.agp.app.br/privkey.pem",
      certfile: "/etc/letsencrypt/live/saulo.agp.app.br/cert.pem",
      cacertfile: "/etc/letsencrypt/live/saulo.agp.app.br/fullchain.pem"
    ],
    secret_key_base: secret_key_base
end
