# BookingsBot

A Telegram bot developed in Elixir to mainly manage bookings for open days in an association or organization.

This was developed for the association [Nextage Madrid](https://twitter.com/Nextage_madrid) in main therefore this bot will contain some specific utilities and features,
but the idea is to make this as customizable as possible.

## Installation

Create a bot with `@BotFather` in Telegram and copy the provided token within `config/config.exs`.

After setting the token, run:

```bash
mix deps.get
mix run --no-halt
# or iex -S mix
```
