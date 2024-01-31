defmodule BookingsBot.Utils do
  def normalize_string(string) do
    string
    |> String.downcase()
    |> String.normalize(:nfd)
    |> String.replace(~r/[^A-z\s]/u, "")
  end

  def format_date(date) do
    Timex.lformat(date, "{WDfull} {D}, {Mfull} {YYYY}", "es")
    |> elem(1)
  end

  defp search_next_day(day_name, date) do
    {:ok, day} = format_date(date) |> String.split(" ") |> Enum.fetch(0)

    if !String.equivalent?(normalize_string(day_name), normalize_string(day)),
      do: search_next_day(day_name, Date.add(date, 1)),
      else: date
  end

  def search_next_day(day_name) do
    if Enum.any?(
         Map.values(Timex.Translator.get_weekdays("es")),
         fn day ->
           String.equivalent?(normalize_string(day_name), normalize_string(day))
         end
       ),
       do: {:ok, search_next_day(day_name, Date.add(Timex.now(), 1))},
       else: {:error, "Not a weekday"}
  end

  def select_button_text(text, number, from, chat_id) do
    if String.contains?(text, "Plaza Libre") do
      number <> " " <> from.first_name <> " (@" <> from.username <> ")"
    else
      {:ok, member} = ExGram.get_chat_member(chat_id, from.id)

      if String.contains?(text, from.username) or
           (member.status == "creator" or member.status == "administrator"),
         do: number <> " Plaza Libre",
         else: text
    end
  end

  def inline_button(text, callback) do
    %{
      text: text,
      callback_data: callback
    }
  end

  def inline_single_button_row(text, callback) do
    [
      inline_button(text, callback)
    ]
  end

  def inline_multi_button_row([text | texts], [callback | callbacks])
      when length(texts) == length(callbacks) do
    [
      inline_button(text, callback)
      | if length(texts) == 0 and length(callbacks) == 0 do
          []
        else
          inline_multi_button_row(texts, callbacks)
        end
    ]
  end

  defp generate_initial_keyboard(buttons, 0), do: buttons

  defp generate_initial_keyboard(buttons, button_num) do
    number =
      Enum.reduce(
        String.codepoints(Integer.to_string(button_num)),
        "",
        fn s, acc -> acc <> s <> "⃣" end
      )

    generate_initial_keyboard(
      [
        inline_single_button_row(
          number <> " Plaza Libre",
          "place" <> Integer.to_string(button_num - 1)
        )
        | buttons
      ],
      button_num - 1
    )
  end

  def generate_initial_keyboard do
    generate_initial_keyboard([], ExGram.Config.get(:bookings_bot, :max_bookings))
  end

  defp count_free_places([], count), do: count

  defp count_free_places([[button] | buttons], count) do
    if String.contains?(button.text, "Plaza Libre"),
      do: count_free_places(buttons, count + 1),
      else: count_free_places(buttons, count)
  end

  def count_free_places(inline_keyboard) do
    count_free_places(inline_keyboard, 0)
  end

  def generate_message(date, kb) do
    free_places = count_free_places(kb)

    "PLAZAS PARA: " <>
      case is_binary(date) do
        true -> date
        false -> format_date(date)
      end <>
      " \nPLAZAS LIBRES: " <>
      Integer.to_string(count_free_places(kb)) <>
      "\n[" <>
      case free_places do
        x when x in 0..1 -> "🔴"
        x when x in 2..3 -> "🟡"
        _ -> "🟢"
      end <>
      "] - " <>
      case free_places do
        0 -> "COMPLETO"
        1 -> "ÚLTIMA PLAZA"
        _ -> "DISPONIBLE"
      end
  end
  
  def convert_kb_to_map(msg) do
	msg.reply_markup.inline_keyboard |> Enum.reduce(%{}, fn [e], acc -> Map.merge(acc, %{e.callback_data => e.text}) end)
  end
  
  def convert_map_to_kb(map) do
	for key <- Map.keys map do [%{text: map[key], callback_data: key}] end
  end

end

