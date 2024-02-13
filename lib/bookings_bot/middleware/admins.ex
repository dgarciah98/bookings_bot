defmodule BookingsBot.Middleware.Admins do
  use ExGram.Middleware
  alias ExGram.Cnt
  import ExGram.Dsl

  @admin_commands ["/newlist", "/setbookingschannel", "/setmaxbookings", "/setmaxbookingsperuser"]
  @admin_status ["creator", "administrator"]

  def call(%Cnt{update: %{message: %{text: text} = msg} = update} = cnt, _)
      when not is_nil(msg) and not is_nil(text) do
    [text | _] = msg.text |> String.replace("@", " ") |> String.split(" ")

    case text in @admin_commands do
      false ->
        cnt

      _ ->
        [{:admins, admins}] = :ets.lookup(:bookings_config, :admins)
        {:ok, %{id: id, username: user}} = extract_user(update)

        with true <- user in admins,
             {:ok, %{status: status}} <- ExGram.get_chat_member(msg.chat.id, id),
             status in @admin_status do
          cnt
        else
          _ -> %{cnt | halted: true}
        end
    end
  end

  def call(cnt, _), do: cnt
end
