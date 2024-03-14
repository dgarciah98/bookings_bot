defmodule BookingsBot.InlineKeyboards do
  import BookingsBot.Utils

  defp inline_stepback(atras),
    do:
      inline_multi_button_row(
        ["↩ Atrás", "❎ Cerrar"],
        [atras, "close"]
      )

  def search_booking_keyboard do
    [{:bookings_channel, chat_data}] = :ets.lookup(:chat_data, :bookings_channel)

    for data <- Enum.sort_by(chat_data.bookings, & &1.date) do
      [
        %{
          text: format_date(data.date),
          url: data.message_link
        }
      ]
    end ++ [inline_stepback("menu_reservas")]
  end

  def delete_booking_keyboard do
    [{:bookings_channel, chat_data}] = :ets.lookup(:chat_data, :bookings_channel)

    for data <- Enum.sort_by(chat_data.bookings, & &1.date) do
      [
        %{
          text: format_date(data.date),
          callback_data: data.message_link
        }
      ]
    end ++ [inline_stepback("crear_reservas")]
  end

  def create_booking_keyboard,
    do: [
      inline_single_button_row("Elegir día individual", "plazas_individual"),
      inline_single_button_row("Fin de semana", "plazas_finde"),
      inline_single_button_row("Fin de semana + Viernes", "plazas_completo"),
      inline_single_button_row("Borrar reserva", "borrar_reservas"),
      inline_stepback("menu_reservas")
    ]

  def commands_keyboard, do: [inline_stepback("main_menu")]

  def arcade_cabs_keyboard, do: [inline_stepback("main_menu")]

  def how_to_play_keyboard, do: [inline_stepback("main_menu")]

  def contacts_keyboard, do: [inline_stepback("main_menu")]

  def bookings_menu_keyboard(user_id) do
    [
      [
        inline_button("Buscar reservas", "buscar_reservas")
        | [inline_admin_button("Gestionar reservas", "crear_reservas", user_id)]
      ],
      inline_stepback("main_menu")
    ]
  end

  def start_keyboard(user_id),
    do: [
      inline_single_button_row("Reservas", "menu_reservas"),
      inline_single_button_row("Comandos de Admin", "menu_comandos", user_id),
      inline_single_button_row("Máquinas arcade", "menu_maquinas"),
      inline_single_button_row("Cómo jugar", "menu_jugar"),
      inline_single_button_row("Contacto", "menu_contacto"),
      inline_single_button_row("❎ Cerrar", "close")
    ]
end
