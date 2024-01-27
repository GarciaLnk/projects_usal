#!/usr/bin/env python3
"""
Script de Roomba para moverlo en una secuencia y trazar su ubicación en tiempo real.
"""

import argparse
import math
import platform
import random
import signal
import time
from itertools import cycle

import matplotlib.pyplot as plt
from matplotlib import colors, colormaps
from matplotlib.axes import Axes
from pycreate2 import Create2
from pycreate2.packets import Sensors

DISTANCE_WHEELS_MM = 235  # distancia entre las ruedas del robot
WHEEL_DIAMETER_MM = 72  # diámetro de las ruedas del robot
COUNTS_PER_REVOLUTION = 508.8  # número de cuentas por revolución de las ruedas
CONVERSION_FACTOR_MM = (
    WHEEL_DIAMETER_MM * math.pi
) / COUNTS_PER_REVOLUTION  # factor de conversión de cuentas a mm
SENSOR_UPDATE_RATE_HZ = 10  # frecuencia de actualización de los sensores del Roomba


def init_bot(port: str) -> Create2:
    """
    Inicializa el Roomba en modo seguro.
    """
    bot = Create2(port)
    bot.start()
    bot.safe()
    bot.led(0, 127, 255)
    return bot


def restart_bot(bot: Create2, port: str) -> Create2:
    """
    Destruye la instancia actual del bot y crea una nueva.
    El destructor cerrará el puerto y realizará otras tareas de limpieza.
    """
    del bot
    return init_bot(port)


def stop_bot(bot: Create2):
    """
    Detiene el bot, apaga los LEDs y muestra el gráfico.
    """
    bot.drive_stop()
    bot.led(0, 0, 0)
    plt.show(block=True)


def calc_position(
    sensors: Sensors, sensors_prev: Sensors, angle: float, pos_x: float, pos_y: float
) -> tuple[float, float, float]:
    """
    Actualiza la posición del Roomba en función de las lecturas del sensor utilizando la odometría.
    """
    right_count = sensors.encoder_counts_right - sensors_prev.encoder_counts_right
    left_count = sensors.encoder_counts_left - sensors_prev.encoder_counts_left

    right_distance = right_count * CONVERSION_FACTOR_MM
    left_distance = left_count * CONVERSION_FACTOR_MM
    distance = (right_distance + left_distance) / 2

    angle += (right_distance - left_distance) / DISTANCE_WHEELS_MM
    angle = angle % (2 * math.pi)

    pos_x += distance * math.cos(angle)
    pos_y += distance * math.sin(angle)

    return angle, pos_x, pos_y


def update_plot(
    axis: Axes, x_coords: list[float], y_coords: list[float], t_coords: list[float]
):
    """
    Actualiza el gráfico en tiempo real con las coordenadas x, y y tiempo proporcionados.
    """
    max_val = max(max(x_coords), max(y_coords), 1000)
    min_val = min(min(x_coords), min(y_coords), -1000)
    axis.clear()
    axis.set(
        xlabel="Distancia X (mm)",
        ylabel="Distancia Y (mm)",
        title="Mapa de ubicación",
        xlim=(min_val, max_val),
        ylim=(min_val, max_val),
    )
    axis.grid(True)
    axis.axhline(0, color="black", linewidth=0.5)
    axis.axvline(0, color="black", linewidth=0.5)

    # Crea un mapa de colores
    cmap = colormaps["jet"]

    # Normaliza las coordenadas de tiempo al rango [0, 1]
    norm = colors.Normalize(min(t_coords, default=0), max(t_coords, default=1))

    # Traza la ruta con el color que representa el tiempo
    for i in range(1, len(x_coords)):
        axis.plot(
            x_coords[i - 1 : i + 1],
            y_coords[i - 1 : i + 1],
            color=cmap(norm(t_coords[i])),
        )

    plt.draw()


def wheel_speeds(min_speed=2, max_speed=4):
    """
    Genera velocidades aleatorias para las ruedas izquierda y derecha, para que el robot se mueva aleatoriamente.
    Esto se utiliza cuando se pasa -r como argumento.
    """
    while True:
        r_vel = random.randint(min_speed, max_speed)
        l_vel = random.randint(min_speed, max_speed)
        yield [r_vel * 100, l_vel * 100]


def wheel_speeds_path(path: list[list[int]]):
    """
    Itera sobre el path para que el robot siga el camino de forma cíclica, este es el modo por defecto.
    """
    for lft, rht, dt in cycle(path):
        yield lft, rht, dt


def main(rand: bool):
    """
    Función principal que ejecuta el script de Roomba.
    """
    # Inicializa el puerto serie del Roomba, intentando diferentes puertos si falla la inicialización
    try:
        port = "COM1" if platform.system() == "Windows" else "/dev/ttyUSB0"
        bot = init_bot(port)
    except Exception:
        try:
            port = "COM2" if platform.system() == "Windows" else "/dev/ttyUSB1"
            bot = init_bot(port)
        except Exception:
            try:
                port = "COM3" if platform.system() == "Windows" else "/dev/ttyUSB2"
                bot = init_bot(port)
            except Exception as e:
                print(f"No se pudo inicializar el bot: {e}")
                exit(1)
    print("Bot inicializado")

    pos_x, pos_y, angle = 0.0, 0.0, 0.0
    sensors_prev = bot.get_sensors()

    # Inicializa el gráfico del mapa
    _, axis = plt.subplots()
    plt.show(block=False)
    x_coords: list[float] = [pos_x]
    y_coords: list[float] = [pos_y]
    t_coords: list[float] = [0]
    update_plot(axis, x_coords, y_coords, t_coords)

    # Maneja la señal SIGINT (Ctrl + C) para detener el bot y mostrar el gráfico
    def signal_handler(*_):
        stop_bot(bot)
        exit(0)

    signal.signal(signal.SIGINT, signal_handler)

    # Camino a seguir por el robo (cuadrado)
    path = [
        [200, 200, 3],
        [0, 200, 1],
        [200, 200, 3],
        [0, 200, 1],
        [200, 200, 3],
        [0, 200, 1],
        [200, 200, 3],
        [0, 200, 1],
    ]

    # Inicializa la velocidad de las ruedas
    if rand:
        r_vel, l_vel = next(wheel_speeds())
    else:
        r_vel, l_vel, movement_duration = next(wheel_speeds_path(path))

    # Bucle principal
    while True:
        # Obtiene los sensores del Roomba
        sensors = bot.get_sensors()

        # Si no se reciben los sensores, reinicia el bot
        if sensors is None:
            bot = restart_bot(bot, port)
            break

        # Si se pulsa el botón CLEAN salimos del bucle principal
        if sensors.buttons.clean:
            break

        # Comprueba si hay obstáculos utilizando los parachoques y sus sensores IR
        bumpers = sensors.bumps_wheeldrops
        # si se detecta un obstáculo a la izquierda, gira a la derecha y atrás para evitarlo:
        if any(
            (
                sensors.light_bumper.left,
                sensors.light_bumper.front_left,
                sensors.light_bumper.center_left,
                bumpers.bump_right,  # bump_right y bump_left están intercambiados
            )
        ):
            bot.drive_direct(-500, 0)
            time.sleep(0.7)
            bot.drive_direct(r_vel, l_vel)
        # si se detecta un obstáculo a la derecha, gira a la izquierda y atrás para evitarlo:
        elif any(
            (
                sensors.light_bumper.right,
                sensors.light_bumper.front_right,
                sensors.light_bumper.center_right,
                bumpers.bump_left,
            )
        ):
            bot.drive_direct(0, -500)
            time.sleep(0.7)
            bot.drive_direct(r_vel, l_vel)

        # Actualiza la posición del Roomba
        angle, pos_x, pos_y = calc_position(sensors, sensors_prev, angle, pos_x, pos_y)

        # Reinicia el Roomba si se ha dado un gran salto en la posición (esto indica errores en el puerto serie)
        if abs(pos_x - x_coords[-1]) > 1000 or abs(pos_y - y_coords[-1]) > 1000:
            restart_bot(bot, port)
            break

        # Actualiza los conteos de encoders anteriores
        sensors_prev = sensors

        # Actualiza la ubicación y el gráfico
        x_coords.append(pos_x)
        y_coords.append(pos_y)
        update_plot(axis, x_coords, y_coords, t_coords)

        # Espera 1/SENSOR_UPDATE_RATE_HZ segundos antes de continuar
        time.sleep(1 / SENSOR_UPDATE_RATE_HZ)

        # Cambia de dirección según el path o aleatoriamente
        if rand:
            r_vel, l_vel, _ = next(wheel_speeds())
            bot.drive_direct(r_vel, l_vel)
        else:
            movement_duration -= 1 / SENSOR_UPDATE_RATE_HZ
            if movement_duration <= 0:
                r_vel, l_vel, movement_duration = next(wheel_speeds_path(path))
                bot.drive_direct(r_vel, l_vel)
    stop_bot(bot)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Ejecuta el script del Roomba")
    parser.add_argument("-r", action="store_true", help="Activa el modo aleatorio")
    args = parser.parse_args()
    main(rand=args.r)
