defmodule BookingsBot.InlineKeyboards do
  import BookingsBot.Utils

  defp inline_stepback(atras) do
    [
      inline_button("↩ Atrás", atras),
      inline_button("❎ Cerrar", "close")
    ]
  end

  def search_booking_keyboard do
    [{_, chat_data}] = :ets.match_object(:chat_data, {:_, :_})

    for data <- Enum.sort_by(chat_data.bookings, & &1.date) do
	  [
        %{
		  text: format_date(data.date),
		  url: data.message_link
        }
	  ]
    end ++ [inline_stepback("menu_reservas")]
  end

  def create_booking_keyboard do
    [
      [
        inline_button("Elegir día individual", "plazas_individual"),
        inline_button("Elegir fecha concreta", "plazas_fecha")
      ],
      inline_single_button_row("Fin de semana", "plazas_finde"),
      inline_single_button_row("Fin de semana + Viernes", "plazas_completo"),
      inline_stepback("menu_reservas")
    ]
  end

  def arcade_cabs_keyboard do
    [
      inline_stepback("main_menu")
    ]
  end

  def how_to_play_keyboard do
    [
      inline_stepback("main_menu")
    ]
  end

  def contacts_keyboard do
    [
      inline_stepback("main_menu")
    ]
  end

  def bookings_menu_keyboard(user_id) do
    [{chat_id, _}] = :ets.match_object(:chat_data, {:_, :_})

    [
      [
        inline_button("Buscar reservas", "buscar_reservas")
        | case ExGram.get_chat_member(chat_id, user_id) do
            {:ok, member} ->
              if member.status == "creator" or member.status == "admininstrator" do
                inline_single_button_row("Crear reservas", "crear_reservas")
              else
                []
              end

            {:error, _} ->
              []
          end
      ],
      inline_stepback("main_menu")
    ]
  end

  def start_keyboard do
    [
      inline_single_button_row("Reservas", "menu_reservas"),
      inline_single_button_row("Máquinas arcade", "menu_maquinas"),
      inline_single_button_row("Cómo jugar", "menu_jugar"),
      inline_single_button_row("Contacto", "menu_contacto"),
      inline_single_button_row("❎ Cerrar", "close")
    ]
  end
end
