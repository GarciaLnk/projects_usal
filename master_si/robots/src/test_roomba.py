import unittest

from roomba import Sensors, calc_position

sensors_zero = Sensors(
    encoder_counts_right=0,
    encoder_counts_left=0,
    bumps_wheeldrops=(0, 0),
    wall=0,
    cliff_left=0,
    cliff_front_left=0,
    cliff_front_right=0,
    cliff_right=0,
    virtual_wall=0,
    overcurrents=0,
    dirt_detect=0,
    ir_opcode=0,
    buttons=0,
    distance=0,
    angle=0,
    charger_state=0,
    voltage=0,
    current=0,
    temperature=0,
    battery_charge=0,
    battery_capacity=0,
    wall_signal=0,
    cliff_left_signal=0,
    cliff_front_left_signal=0,
    cliff_front_right_signal=0,
    cliff_right_signal=0,
    charger_available=0,
    open_interface_mode=0,
    song_number=0,
    song_playing=0,
    oi_stream_num_packets=0,
    velocity=0,
    radius=0,
    velocity_right=0,
    velocity_left=0,
    light_bumper=(0, 0, 0, 0, 0, 0),
    light_bumper_left=0,
    light_bumper_front_left=0,
    light_bumper_center_left=0,
    light_bumper_center_right=0,
    light_bumper_front_right=0,
    light_bumper_right=0,
    ir_opcode_left=0,
    ir_opcode_right=0,
    left_motor_current=0,
    right_motor_current=0,
    main_brush_current=0,
    side_brush_current=0,
    statis=0,
)


class TestCalcPosition(unittest.TestCase):
    def test_calc_position(self):
        sensors_prev = sensors_zero._replace(
            encoder_counts_right=100, encoder_counts_left=150
        )
        sensors_current = sensors_zero._replace(
            encoder_counts_right=200, encoder_counts_left=200
        )

        angle = 0
        pos_x = 0
        pos_y = 0

        angle, pos_x, pos_y = calc_position(
            sensors_current, sensors_prev, angle, pos_x, pos_y
        )

        self.assertAlmostEqual(angle, 0.095, places=3)
        self.assertAlmostEqual(pos_x, 33.193, places=3)
        self.assertAlmostEqual(pos_y, 3.149, places=3)


if __name__ == "__main__":
    unittest.main()
