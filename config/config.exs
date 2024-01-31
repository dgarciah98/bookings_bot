import Config

config :ex_gram,
  token: "TOKEN"

config :bookings_bot,
  max_bookings: 10, # default value
  admins: [] # add users here to not depend just on chat group admins
