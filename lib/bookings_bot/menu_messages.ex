defmodule BookingsBot.MenuMessages do
  # This is where all messages for each menu are located
  # Add your own here to use it with the inline menus

  def bookings_menu_message do
    """
    *RESERVAS*
    Aquí puedes acceder a información relativa a las reservas del local de Nextage\\.
    """
  end

  def create_booking_message do
    """
    *CREACIÓN DE RESERVAS*
    Aquí puedes crear días de reserva según lo que decidas\\.
    Puedes usar las opciones predeterminadas para crear reservas para el fin de semana, o bien elegir un día individual\\.
    También puedes crear una reserva para una fecha en concreta\\.
    """
  end

  def search_booking_message do
    """
    *BUSCAR RESERVAS*
    Aquí puedes consultar los días de reserva disponibles\\.
    Si hay algún día disponible, se mostrará a continuación y al pincharlo se te redirigirá al mensaje de la reserva al pinchar en el día en concreto\\.
    """
  end

  def arcade_cabs_message do
    """
    *NUESTRAS MÁQUINAS*
    WIP
    """
  end

  def how_to_play_message do
    """
    *CÓMO JUGAR CON NUESTRAS MÁQUINAS*
    WIP
    """
  end

  def contacts_message do
    """
    *NUESTROS CONTACTOS*
    WIP
    """
  end

  def main_menu_message do
    """
     ¡Hola! Aquí puedes consultar información sobre la asociación Nextage Madrid.
     Pincha en los siguientes botones según lo que quieras consultar.
    """
  end

  def invalid_member_message() do
    """
    ¿No estás en el grupo de visitas?
    ¡Contacta con nosotros por Twitter!
    """
  end
end
