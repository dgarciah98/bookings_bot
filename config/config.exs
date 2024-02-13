import Config

config :ex_gram,
  token: "TOKEN"

config :ex_gram, ExGram.Adapter.Tesla,
  middlewares: [
    {BookingsBot.TeslaMiddlewares, :retry, []}
  ]

config :bookings_bot,
  # default value
  max_bookings: 10,
  # max amount of bookings that a user can select
  max_bookings_per_user: 3,
  # add users here to not depend just on chat group admins
  admins: []
