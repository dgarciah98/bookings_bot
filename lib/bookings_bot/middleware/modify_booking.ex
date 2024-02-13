defmodule BookingsBot.Middleware.ModifyBooking do
  use ExGram.Middleware
  alias ExGram.Cnt
  import ExGram.Dsl

  @admin_status ["creator", "administrator"]

  def call(
        %Cnt{update: %{callback_query: %{data: "place" <> number} = callback} = update} = cnt,
        _
      ) do
    case :ets.match_object(:chat_data, :_) do
      [] ->
        %{cnt | halted: true}

      [{_, data}] ->
        {:ok, %{id: id, username: user}} = extract_user(update)

        kb =
          Enum.find(data.bookings, fn b -> b.message_id == callback.message.message_id end).reply_markup

        key = "place" <> number

        with false <- String.contains?(kb[key], "Plaza Libre"),
             false <- String.contains?(kb[key], user),
             {:ok, %{status: status}} <- ExGram.get_chat_member(callback.message.chat.id, id) do
          [{:admins, admins}] = :ets.lookup(:bookings_config, :admins)

          with false <- user in admins,
               true <- status in @admin_status do
            cnt
          else
            _ -> %{cnt | halted: true}
          end
        else
          _ -> cnt
        end
    end
  end

  def call(cnt, _), do: cnt
end
