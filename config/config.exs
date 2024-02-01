import Config

config :ex_gram,
  token: "TOKEN"

config :ex_gram, ExGram.Adapter.Tesla,
  middlewares: [
    {TeslaMiddlewares, :retry, []}
  ]

config :bookings_bot,
  # default value
  max_bookings: 10,
  # add users here to not depend just on chat group admins
  admins: []
