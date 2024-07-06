import Config

config :battleship, BattleshipWeb.Endpoint,
  url: [host: "saulo.agp.app.br", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json",
  check_origin: ["https://saulo.agp.app.br"],
  force_ssl: [hsts: true],
  https: [
    port: 443,
    cipher_suite: :strong,
    keyfile: "/etc/letsencrypt/live/saulo.agp.app.br/privkey.pem",
    certfile: "/etc/letsencrypt/live/saulo.agp.app.br/cert.pem",
    cacertfile: "/etc/letsencrypt/live/saulo.agp.app.br/fullchain.pem"
  ]

config :logger, level: :info
