defmodule BookingsBot.Bot do
  @bot :testing_bot

  use ExGram.Bot,
    name: @bot

  # setup_commands: true

  alias ExGram.Model.BotCommand
  alias ExGram.Model.BotCommandScopeAllChatAdministrators
  alias BookingsBot.Utils
  alias BookingsBot.InlineKeyboards
  alias BookingsBot.MenuMessages

  middleware(ExGram.Middleware.IgnoreUsername)

  command("somebodyscream", description: "Abre un menú en un chat privado")
  command("saibaiicecream", description: "Abre un menú en un chat privado")
  command("newlist", description: "Create a new list of places for a given day")

  command("setbookingschannel",
    description: "Set this channel to send new bookings announcements"
  )

  def bot(), do: @bot

  def init(_opts) do
    :ets.new(:chat_data, [:set, :public, :named_table])

    ExGram.set_my_commands!([
      %BotCommand{
        command: "somebodyscream",
        description: "Abre un menú en un chat privado"
      }
    ])

    ExGram.set_my_commands!(
      [
        %BotCommand{
          command: "newlist",
          description: "Create a new list of bookings for a given day"
        },
        %BotCommand{
          command: "setbookingschannel",
          description: "Set this channel to send new bookings announcements"
        }
      ],
      scope: %BotCommandScopeAllChatAdministrators{type: "all_chat_administrators"}
    )

    :ok
  end

  def send_start_message(user_id) do
    case :ets.match_object(:chat_data, {:_, :_, :_, :_, :_}) do
      [{chat_id, _, _, _, _}] ->
        case ExGram.get_chat_member(chat_id, user_id) do
          {:ok, _} ->
            ExGram.send_message(
              user_id,
              MenuMessages.main_menu_message(),
              reply_markup: create_inline(InlineKeyboards.start_keyboard()),
              protect_content: true
            )

          {:error, _} ->
            ExGram.send_message(
              user_id,
              MenuMessages.invalid_member_message(),
              protect_content: true
            )
        end

      _ ->
        ExGram.send_message(
          user_id,
          MenuMessages.invalid_member_message(),
          protect_content: true
        )
    end
  end

  def handle({:command, :somebodyscream, %{from: from}}, _) do
    send_start_message(from.id)
  end

  def handle({:command, "sanbaiicecream", %{from: from}}, _) do
    send_start_message(from.id)
  end

  def handle(
        {:command, :setbookingschannel,
         %{
           reply_to_message: %{message_thread_id: thread_id, forum_topic_created: topic}
         } = msg},
        _
      ) do
    ExGram.delete_message(msg.chat.id, msg.message_id)
    :ets.insert(:chat_data, {msg.chat.id, msg.chat.title, thread_id, topic.name, []})

    ExGram.send_message(
      msg.from.id,
      "Las reservas se mandarán al canal " <> topic.name <> " del grupo " <> msg.chat.title,
      protect_content: true
    )
  end

  def handle({:inline_query, %{query: _}}, context) do
    answer_inline_query(
      context,
      [
        %ExGram.Model.InlineQueryResultArticle{
          type: "article",
          id: "start_convo",
          title: "Hablar con Bot de Nextage Madrid",
          description: "Inicia una conversación conmigo para consultar información sobre Nextage",
          input_message_content: %ExGram.Model.InputTextMessageContent{
            message_text:
              case :rand.uniform(100) do
                n when n <= 30 -> "/sanbaiicecream"
                _ -> "/somebodyscream"
              end
          }
        }
      ],
      is_personal: true
    )
  end

  defp send_bookings_message(text, chat_id, msg_id, thread_id \\ nil) do
    ExGram.delete_message(chat_id, msg_id)

    text
    |> String.split(~r{[,\s]}, trim: true)
    |> Enum.each(
      &case Utils.search_next_day(&1) do
        {:ok, date} ->
          opts = [
            reply_markup: create_inline(Utils.generate_initial_keyboard()),
            protect_content: true
          ]

          [{chat_id, chat_name, thread_id, topic_name, chat_data}] =
            :ets.match_object(:chat_data, {:_, :_, :_, :_, :_})

          {:ok, msg} =
            ExGram.send_message(
              chat_id,
              Utils.generate_message(date, Utils.generate_initial_keyboard()),
              if thread_id != nil do
                [{:message_thread_id, thread_id} | opts]
              else
                opts
              end
            )

          new_data =
            %{
              day: Utils.format_date(date) |> String.split(" ") |> List.first(),
              message_id: msg.message_id,
              date: date,
              reply_markup: msg.reply_markup,
              message_link:
                if thread_id != nil do
                  "https://t.me/c/" <>
                    (Integer.to_string(chat_id)
                     |> String.slice(4..-1)) <>
                    "/" <>
                    Integer.to_string(msg.message_thread_id) <>
                    "/" <>
                    Integer.to_string(msg.message_id)
                end
            }

          chat_data =
            Enum.map(chat_data, fn elem ->
              if new_data.day == elem.day,
                do:
                  case(Date.compare(elem.date, date),
                    do:
                      (
                        :lt ->
                          new_data

                        :eq ->
                          if elem.message_id < new_data.message_id,
                            do: new_data,
                            else: elem

                        _ ->
                          elem
                      )
                  ),
                else: elem
            end)

          :ets.insert(
            :chat_data,
            {chat_id, chat_name, thread_id, topic_name,
             case Enum.find(chat_data, fn elem -> elem.date == new_data.date end) do
               nil -> [new_data | chat_data]
               _ -> chat_data
             end}
          )

          {:ok, msg}

        {:error, _} ->
          ExGram.send_message(
            chat_id,
            "El dia que has introducido (" <> &1 <> ") no es un día, al menos en España",
            if thread_id != nil do
              [{:message_thread_id, thread_id}, {:protect_content, true}]
            else
              [{:protect_content, true}]
            end
          )
      end
    )
  end

  def handle(
        {:command, :newlist,
         %{text: text, message_id: msg_id, message_thread_id: thread_id, chat: chat}},
        _
      ) do
    send_bookings_message(text, chat.id, msg_id, thread_id)
  end

  def handle({:command, :newlist, %{text: text, message_id: msg_id, chat: chat}}, _) do
    send_bookings_message(text, chat.id, msg_id)
  end

  # Main menu

  def handle({:callback_query, %{data: "main_menu"}}, context) do
    edit(context, :inline, MenuMessages.main_menu_message(),
      reply_markup: create_inline(InlineKeyboards.start_keyboard())
    )
  end

  def handle({:callback_query, %{data: "close", message: msg}}, context) do
    delete(context, msg)
  end

  # Bookings

  def handle({:callback_query, %{data: "menu_reservas", from: from}}, context) do
    edit(context, :inline, MenuMessages.bookings_menu_message(),
      parse_mode: "MarkdownV2",
      reply_markup: create_inline(InlineKeyboards.bookings_menu_keyboard(from.id))
    )
  end

  def handle({:callback_query, %{data: "crear_reservas"}}, context) do
    edit(context, :inline, MenuMessages.create_booking_message(),
      parse_mode: "MarkdownV2",
      reply_markup: create_inline(InlineKeyboards.create_booking_keyboard())
    )
  end

  def handle(
        {:callback_query, %{data: "plazas_finde", message: %{message_id: msg_id, chat: chat}}},
        _
      ) do
    send_bookings_message("sabado, domingo", chat.id, msg_id)
  end

  def handle({:callback_query, %{data: "buscar_reservas"}}, context) do
    edit(context, :inline, MenuMessages.search_booking_message(),
      parse_mode: "MarkdownV2",
      reply_markup: create_inline(InlineKeyboards.search_booking_keyboard())
    )
  end

  # Arcade cabs

  def handle({:callback_query, %{data: "menu_maquinas"}}, context) do
    edit(context, :inline, MenuMessages.arcade_cabs_message(),
      parse_mode: "MarkdownV2",
      reply_markup: create_inline(InlineKeyboards.arcade_cabs_keyboard())
    )
  end

  # How to play

  def handle({:callback_query, %{data: "menu_jugar"}}, context) do
    edit(context, :inline, MenuMessages.how_to_play_message(),
      parse_mode: "MarkdownV2",
      reply_markup: create_inline(InlineKeyboards.how_to_play_keyboard())
    )
  end

  # Contacts

  def handle({:callback_query, %{data: "menu_contacto"}}, context) do
    edit(context, :inline, MenuMessages.contacts_message(),
      parse_mode: "MarkdownV2",
      reply_markup: create_inline(InlineKeyboards.contacts_keyboard())
    )
  end

  # Bookings list 
  def handle(
        {:callback_query, %{data: "place" <> place_pos, message: msg, from: from}},
        context
      ) do
    "PLAZAS PARA: " <> date = msg.text
    [date | _] = date |> String.split(" \n")

    for [button] <- msg.reply_markup.inline_keyboard do
      [number | _] = button.text |> String.split(" ")

      if button.callback_data == "place" <> place_pos,
        do: [%{button | text: Utils.select_button_text(button.text, number, from, msg.chat.id)}],
        else: [button]
    end
    |> (&edit(context, :inline, Utils.generate_message(date, &1), reply_markup: create_inline(&1))).()
  end
end