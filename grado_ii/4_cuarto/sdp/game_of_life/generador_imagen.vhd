library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity generador_imagen is
  port (
    hctr : in std_logic_vector (10 downto 0);
    vctr : in std_logic_vector (10 downto 0);
    clear : in std_logic;
    clk50MHz : in std_logic;
    play : in std_logic;
    reset : in std_logic;
    xpos : in std_logic_vector(9 downto 0);
    ypos : in std_logic_vector(9 downto 0);
    left_click : in std_logic;
    right_click : in std_logic;
    slower : in std_logic;
    faster : in std_logic;
    def_speed : in std_logic;
    middle_click : in std_logic;
    glider : in std_logic;
    pentomino : in std_logic;
    puffer : in std_logic;
    lwss : in std_logic;
    pulsar : in std_logic;
    phoenix : in std_logic;
    eden : in std_logic;
    saved : in std_logic;
    zpos : in std_logic_vector(3 downto 0);
    R : out std_logic_vector (3 downto 0);
    G : out std_logic_vector (3 downto 0);
    B : out std_logic_vector (3 downto 0);
    Y0 : out std_logic_vector (3 downto 0);
    Y1 : out std_logic_vector (3 downto 0);
    Y2 : out std_logic_vector (3 downto 0);
    Y3 : out std_logic_vector (3 downto 0);
    S : out std_logic_vector (9 downto 0));
end generador_imagen;

architecture Behavioral of generador_imagen is
  component debounce
    generic (
      clk_freq : integer := 50_000_000;
      stable_time : integer := 10);
    port (
      clk : in std_logic;
      reset_n : in std_logic;
      button : in std_logic;
      result : out std_logic);
  end component;

  type time_array is array (0 to 9) of integer;

  -- log spaced time values from 1s to 16.67ms
  constant time_values : time_array := (
    50000000, 31724712, 20129146, 12771827, 8103651,
    5141720, 3262391, 2069969, 1313383, 833334
  );
  signal set_time : integer range 0 to 9 := 1;
  signal timectr : integer range time_values(0) downto 0 := 0;

  constant dim_x : integer := 40;
  constant dim_y : integer := 30;

  constant center_x : integer := dim_x / 2;
  constant center_y : integer := dim_y / 2;

  constant h_size : integer := integer(round(real(800 / dim_x)));
  constant v_size : integer := integer(round(real(600 / dim_y)));

  type t_matrix is array (0 to dim_y - 1, 0 to dim_x - 1) of std_logic;
  signal matrix : t_matrix := (others => (others => '0'));
  signal matrix_saved : t_matrix := (others => (others => '0'));

  type t_counter is array (3 downto 0) of std_logic_vector (3 downto 0);
  signal step_counter : t_counter := (others => "0000");

  signal clear_prev : std_logic := '0';
  signal middle_click_prev : std_logic := '0';
  signal glider_prev : std_logic := '0';
  signal pentomino_prev : std_logic := '0';
  signal puffer_prev : std_logic := '0';
  signal lwss_prev : std_logic := '0';
  signal pulsar_prev : std_logic := '0';
  signal phoenix_prev : std_logic := '0';
  signal eden_prev : std_logic := '0';
  signal saved_prev : std_logic := '0';

  signal play_d : std_logic := '0';
  signal clear_d : std_logic := '0';
  signal glider_d : std_logic := '0';
  signal pentomino_d : std_logic := '0';
  signal puffer_d : std_logic := '0';
  signal lwss_d : std_logic := '0';
  signal pulsar_d : std_logic := '0';
  signal phoenix_d : std_logic := '0';
  signal eden_d : std_logic := '0';
  signal saved_d : std_logic := '0';

  signal slower_prev : std_logic := '0';
  signal faster_prev : std_logic := '0';
  signal def_speed_prev : std_logic := '0';

  signal slower_d : std_logic := '0';
  signal faster_d : std_logic := '0';
  signal def_speed_d : std_logic := '0';

  signal play_prev : std_logic := '0';

  signal next_matrix : t_matrix := (others => (others => '0'));
  signal x_idx : integer range dim_x - 1 downto 0 := 0;
  signal y_idx : integer range dim_y - 1 downto 0 := 0;
  signal matrix_done : std_logic := '0';

  type zoom_array is array (0 to 9) of integer;
  constant zoom_values : zoom_array := (
    10, 11, 12, 13, 14, 15, 16, 17, 19, 20
  );
  signal zoom_level : integer range 0 to 9 := 0;
  signal zoom_x_offset : integer range 0 to 799 := 0;
  signal zoom_y_offset : integer range 0 to 599 := 0;
begin
  debounce_play : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => play,
    result => play_d);

  debounce_clear : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => clear,
    result => clear_d);

  debounce_glider : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => glider,
    result => glider_d);

  debounce_pentomino : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => pentomino,
    result => pentomino_d);

  debounce_puffer : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => puffer,
    result => puffer_d);

  debounce_lwss : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => lwss,
    result => lwss_d);

  debounce_pulsar : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => pulsar,
    result => pulsar_d);

  debounce_phoenix : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => phoenix,
    result => phoenix_d);

  debounce_eden : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => eden,
    result => eden_d);

  debounce_slower : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => slower,
    result => slower_d);

  debounce_faster : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => faster,
    result => faster_d);

  debounce_def_speed : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => def_speed,
    result => def_speed_d);

  debounce_saved : debounce
  port map(
    clk => clk50MHz,
    reset_n => '1',
    button => saved,
    result => saved_d);

  draw : process (hctr, vctr, matrix, zoom_level, zoom_x_offset, zoom_y_offset)
    variable curr_x : integer range 0 to dim_x - 1;
    variable curr_y : integer range 0 to dim_y - 1;
    variable hctr_int : integer range 1056 downto 0;
    variable vctr_int : integer range 628 downto 0;
  begin
    hctr_int := to_integer(unsigned(hctr));
    vctr_int := to_integer(unsigned(vctr));

    curr_x := (hctr_int + zoom_x_offset) / (h_size * zoom_values(zoom_level) / 10);
    curr_y := (vctr_int + zoom_y_offset) / (v_size * zoom_values(zoom_level) / 10);

    if (hctr_int = 1) or (vctr_int = 599)
      or (((hctr_int + zoom_x_offset) mod (h_size * zoom_values(zoom_level) / 10)) = 0)
      or (((vctr_int + zoom_y_offset) mod (v_size * zoom_values(zoom_level) / 10)) = 0) then
      -- grey border
      R <= "1000";
      G <= "1000";
      B <= "1000";
    elsif (matrix(curr_y, curr_x) = '1') then
      -- yellow cell
      R <= "1111";
      G <= "1111";
      B <= "0000";
    else
      -- black background
      R <= "0000";
      G <= "0000";
      B <= "0000";
    end if;
  end process draw;

  game_logic : process (clk50MHz)
    variable neighbors : integer range 8 downto 0;
    variable sel_x : integer range 0 to dim_x - 1;
    variable sel_y : integer range 0 to dim_y - 1;
    variable tmp_x : integer range 0 to dim_x - 1;
    variable tmp_y : integer range 0 to dim_y - 1;
    variable step_counter_tmp : t_counter;
  begin
    if (rising_edge(clk50MHz)) then
      middle_click_prev <= middle_click;
      clear_prev <= clear_d;
      glider_prev <= glider_d;
      pentomino_prev <= pentomino_d;
      puffer_prev <= puffer_d;
      lwss_prev <= lwss_d;
      pulsar_prev <= pulsar_d;
      phoenix_prev <= phoenix_d;
      eden_prev <= eden_d;
      saved_prev <= saved_d;

      slower_prev <= slower_d;
      faster_prev <= faster_d;
      def_speed_prev <= def_speed_d;

      play_prev <= play_d;

      if (timectr < time_values(set_time)) then
        timectr <= timectr + 1;
      end if;

      if (clear_d = '1' and clear_prev = '0') then
        matrix <= (others => (others => '0'));
        step_counter <= (others => "0000");
      elsif (glider_d = '1' and glider_prev = '0') then
        -- Glider pattern
        matrix <= (others => (others => '0'));
        matrix(center_y - 1, center_x) <= '1';
        matrix(center_y, center_x + 1) <= '1';
        matrix(center_y + 1, center_x - 1) <= '1';
        matrix(center_y + 1, center_x) <= '1';
        matrix(center_y + 1, center_x + 1) <= '1';
        step_counter <= (others => "0000");
      elsif (pentomino_d = '1' and pentomino_prev = '0') then
        -- R-pentomino pattern
        matrix <= (others => (others => '0'));
        matrix(center_y - 1, center_x) <= '1';
        matrix(center_y - 1, center_x + 1) <= '1';
        matrix(center_y, center_x - 1) <= '1';
        matrix(center_y, center_x) <= '1';
        matrix(center_y + 1, center_x) <= '1';
        step_counter <= (others => "0000");
      elsif (puffer_d = '1' and puffer_prev = '0') then
        -- Puffer pattern
        matrix <= (others => (others => '0'));
        matrix(center_y - 6, center_x - 8) <= '1';
        matrix(center_y - 6, center_x - 7) <= '1';
        matrix(center_y - 6, center_x - 6) <= '1';
        matrix(center_y - 6, center_x + 8) <= '1';
        matrix(center_y - 6, center_x + 7) <= '1';
        matrix(center_y - 6, center_x + 6) <= '1';
        matrix(center_y - 5, center_x - 8) <= '1';
        matrix(center_y - 5, center_x - 5) <= '1';
        matrix(center_y - 5, center_x + 9) <= '1';
        matrix(center_y - 5, center_x + 6) <= '1';
        matrix(center_y - 4, center_x - 8) <= '1';
        matrix(center_y - 4, center_x + 6) <= '1';
        matrix(center_y - 4, center_x) <= '1';
        matrix(center_y - 4, center_x + 1) <= '1';
        matrix(center_y - 4, center_x - 1) <= '1';
        matrix(center_y - 3, center_x - 8) <= '1';
        matrix(center_y - 3, center_x + 6) <= '1';
        matrix(center_y - 3, center_x + 1) <= '1';
        matrix(center_y - 3, center_x - 2) <= '1';
        matrix(center_y - 2, center_x - 2) <= '1';
        matrix(center_y - 2, center_x + 2) <= '1';
        matrix(center_y - 2, center_x - 5) <= '1';
        matrix(center_y - 2, center_x - 7) <= '1';
        matrix(center_y - 2, center_x + 7) <= '1';
        matrix(center_y - 2, center_x + 9) <= '1';
        matrix(center_y - 1, center_x - 1) <= '1';
        matrix(center_y - 1, center_x) <= '1';
        matrix(center_y - 1, center_x + 1) <= '1';
        matrix(center_y - 1, center_x + 2) <= '1';
        matrix(center_y, center_x + 1) <= '1';
        matrix(center_y + 4, center_x + 1) <= '1';
        matrix(center_y + 4, center_x) <= '1';
        matrix(center_y + 4, center_x - 1) <= '1';
        matrix(center_y + 5, center_x - 1) <= '1';
        matrix(center_y + 6, center_x) <= '1';
        step_counter <= (others => "0000");
      elsif (lwss_d = '1' and lwss_prev = '0') then
        -- Lightweight spaceship pattern
        matrix <= (others => (others => '0'));
        matrix(center_y - 1, center_x - 1) <= '1';
        matrix(center_y - 1, center_x + 2) <= '1';
        matrix(center_y, center_x - 2) <= '1';
        matrix(center_y + 1, center_x - 2) <= '1';
        matrix(center_y + 1, center_x + 2) <= '1';
        matrix(center_y + 2, center_x - 2) <= '1';
        matrix(center_y + 2, center_x - 1) <= '1';
        matrix(center_y + 2, center_x) <= '1';
        matrix(center_y + 2, center_x + 1) <= '1';
        step_counter <= (others => "0000");
      elsif (pulsar_d = '1' and pulsar_prev = '0') then
        -- Pulsar pattern
        matrix <= (others => (others => '0'));
        matrix(center_y - 6, center_x - 4) <= '1';
        matrix(center_y - 6, center_x - 3) <= '1';
        matrix(center_y - 6, center_x - 2) <= '1';
        matrix(center_y - 6, center_x + 2) <= '1';
        matrix(center_y - 6, center_x + 3) <= '1';
        matrix(center_y - 6, center_x + 4) <= '1';
        matrix(center_y - 4, center_x - 6) <= '1';
        matrix(center_y - 4, center_x - 1) <= '1';
        matrix(center_y - 3, center_x - 6) <= '1';
        matrix(center_y - 3, center_x - 1) <= '1';
        matrix(center_y - 2, center_x - 6) <= '1';
        matrix(center_y - 2, center_x - 1) <= '1';
        matrix(center_y - 4, center_x + 6) <= '1';
        matrix(center_y - 4, center_x + 1) <= '1';
        matrix(center_y - 3, center_x + 6) <= '1';
        matrix(center_y - 3, center_x + 1) <= '1';
        matrix(center_y - 2, center_x + 6) <= '1';
        matrix(center_y - 2, center_x + 1) <= '1';
        matrix(center_y - 1, center_x - 4) <= '1';
        matrix(center_y - 1, center_x - 3) <= '1';
        matrix(center_y - 1, center_x - 2) <= '1';
        matrix(center_y - 1, center_x + 2) <= '1';
        matrix(center_y - 1, center_x + 3) <= '1';
        matrix(center_y - 1, center_x + 4) <= '1';
        matrix(center_y + 6, center_x - 4) <= '1';
        matrix(center_y + 6, center_x - 3) <= '1';
        matrix(center_y + 6, center_x - 2) <= '1';
        matrix(center_y + 6, center_x + 2) <= '1';
        matrix(center_y + 6, center_x + 3) <= '1';
        matrix(center_y + 6, center_x + 4) <= '1';
        matrix(center_y + 4, center_x - 6) <= '1';
        matrix(center_y + 4, center_x - 1) <= '1';
        matrix(center_y + 3, center_x - 6) <= '1';
        matrix(center_y + 3, center_x - 1) <= '1';
        matrix(center_y + 2, center_x - 6) <= '1';
        matrix(center_y + 2, center_x - 1) <= '1';
        matrix(center_y + 4, center_x + 6) <= '1';
        matrix(center_y + 4, center_x + 1) <= '1';
        matrix(center_y + 3, center_x + 6) <= '1';
        matrix(center_y + 3, center_x + 1) <= '1';
        matrix(center_y + 2, center_x + 6) <= '1';
        matrix(center_y + 2, center_x + 1) <= '1';
        matrix(center_y + 1, center_x - 4) <= '1';
        matrix(center_y + 1, center_x - 3) <= '1';
        matrix(center_y + 1, center_x - 2) <= '1';
        matrix(center_y + 1, center_x + 2) <= '1';
        matrix(center_y + 1, center_x + 3) <= '1';
        matrix(center_y + 1, center_x + 4) <= '1';
        step_counter <= (others => "0000");
      elsif (phoenix_d = '1' and phoenix_prev = '0') then
        -- Phoenix pattern
        matrix <= (others => (others => '0'));
        matrix(center_y - 4, center_x) <= '1';
        matrix(center_y - 3, center_x - 2) <= '1';
        matrix(center_y - 3, center_x) <= '1';
        matrix(center_y - 2, center_x + 2) <= '1';
        matrix(center_y - 1, center_x - 3) <= '1';
        matrix(center_y - 1, center_x - 4) <= '1';
        matrix(center_y, center_x + 2) <= '1';
        matrix(center_y, center_x + 3) <= '1';
        matrix(center_y + 1, center_x - 3) <= '1';
        matrix(center_y + 2, center_x - 1) <= '1';
        matrix(center_y + 2, center_x + 1) <= '1';
        matrix(center_y + 3, center_x - 1) <= '1';
        step_counter <= (others => "0000");
      elsif (eden_d = '1' and eden_prev = '0') then
        -- Garden of Eden pattern
        matrix <= (others => (others => '0'));
        matrix(center_y - 5, center_x - 4) <= '1';
        matrix(center_y - 5, center_x - 3) <= '1';
        matrix(center_y - 5, center_x - 2) <= '1';
        matrix(center_y - 5, center_x + 1) <= '1';
        matrix(center_y - 5, center_x + 2) <= '1';
        matrix(center_y - 4, center_x - 4) <= '1';
        matrix(center_y - 4, center_x - 3) <= '1';
        matrix(center_y - 4, center_x - 1) <= '1';
        matrix(center_y - 4, center_x + 1) <= '1';
        matrix(center_y - 4, center_x + 3) <= '1';
        matrix(center_y - 4, center_x + 4) <= '1';
        matrix(center_y - 4, center_x + 5) <= '1';
        matrix(center_y - 3, center_x - 4) <= '1';
        matrix(center_y - 3, center_x - 3) <= '1';
        matrix(center_y - 3, center_x - 2) <= '1';
        matrix(center_y - 3, center_x + 1) <= '1';
        matrix(center_y - 3, center_x + 2) <= '1';
        matrix(center_y - 3, center_x + 3) <= '1';
        matrix(center_y - 3, center_x + 4) <= '1';
        matrix(center_y - 3, center_x + 5) <= '1';
        matrix(center_y - 2, center_x - 5) <= '1';
        matrix(center_y - 2, center_x - 3) <= '1';
        matrix(center_y - 2, center_x - 1) <= '1';
        matrix(center_y - 2, center_x + 1) <= '1';
        matrix(center_y - 2, center_x + 3) <= '1';
        matrix(center_y - 2, center_x + 5) <= '1';
        matrix(center_y - 1, center_x - 5) <= '1';
        matrix(center_y - 1, center_x - 4) <= '1';
        matrix(center_y - 1, center_x - 3) <= '1';
        matrix(center_y - 1, center_x - 2) <= '1';
        matrix(center_y - 1, center_x) <= '1';
        matrix(center_y - 1, center_x + 2) <= '1';
        matrix(center_y - 1, center_x + 4) <= '1';
        matrix(center_y, center_x - 1) <= '1';
        matrix(center_y, center_x) <= '1';
        matrix(center_y, center_x + 1) <= '1';
        matrix(center_y + 1, center_x - 4) <= '1';
        matrix(center_y + 1, center_x - 2) <= '1';
        matrix(center_y + 1, center_x) <= '1';
        matrix(center_y + 1, center_x + 2) <= '1';
        matrix(center_y + 1, center_x + 3) <= '1';
        matrix(center_y + 1, center_x + 4) <= '1';
        matrix(center_y + 1, center_x + 5) <= '1';
        matrix(center_y + 2, center_x - 5) <= '1';
        matrix(center_y + 2, center_x - 3) <= '1';
        matrix(center_y + 2, center_x - 1) <= '1';
        matrix(center_y + 2, center_x + 1) <= '1';
        matrix(center_y + 2, center_x + 3) <= '1';
        matrix(center_y + 2, center_x + 5) <= '1';
        matrix(center_y + 3, center_x + 4) <= '1';
        matrix(center_y + 3, center_x + 3) <= '1';
        matrix(center_y + 3, center_x + 2) <= '1';
        matrix(center_y + 3, center_x - 1) <= '1';
        matrix(center_y + 3, center_x - 2) <= '1';
        matrix(center_y + 3, center_x - 3) <= '1';
        matrix(center_y + 3, center_x - 4) <= '1';
        matrix(center_y + 3, center_x - 5) <= '1';
        matrix(center_y + 4, center_x + 4) <= '1';
        matrix(center_y + 4, center_x + 3) <= '1';
        matrix(center_y + 4, center_x + 1) <= '1';
        matrix(center_y + 4, center_x - 1) <= '1';
        matrix(center_y + 4, center_x - 3) <= '1';
        matrix(center_y + 4, center_x - 4) <= '1';
        matrix(center_y + 4, center_x - 5) <= '1';
        matrix(center_y + 5, center_x + 4) <= '1';
        matrix(center_y + 5, center_x + 3) <= '1';
        matrix(center_y + 5, center_x + 2) <= '1';
        matrix(center_y + 5, center_x - 1) <= '1';
        matrix(center_y + 5, center_x - 2) <= '1';
        step_counter <= (others => "0000");
      elsif (saved_d = '1' and saved_prev = '0') then
        matrix <= matrix_saved;
        step_counter <= (others => "0000");
      elsif (play_d = '1' and play_prev = '0') then
        matrix_saved <= matrix;
      elsif (left_click = '1' or right_click = '1') then
        sel_x := (to_integer(unsigned(xpos)) + zoom_x_offset) / (h_size * zoom_values(zoom_level) / 10);
        sel_y := (to_integer(unsigned(ypos)) + zoom_y_offset) / (v_size * zoom_values(zoom_level) / 10);
        matrix(sel_y, sel_x) <= left_click;
        x_idx <= 0;
        y_idx <= 0;
        matrix_done <= '0';
      elsif (matrix_done = '1' and
        ((play_d = '1' and timectr >= time_values(set_time)) or (middle_click = '1' and middle_click_prev = '0'))) then
        matrix <= next_matrix;
        x_idx <= 0;
        y_idx <= 0;
        matrix_done <= '0';

        step_counter_tmp := step_counter;
        for i in 0 to 3 loop
          -- if counter is not 9 (1001) then increment
          if (step_counter_tmp(i) /= "1001") then
            step_counter_tmp(i) := std_logic_vector(unsigned(step_counter_tmp(i)) + 1);
            exit;
          else
            step_counter_tmp(i) := "0000";
          end if;
        end loop;
        step_counter <= step_counter_tmp;

        timectr <= 0;
      else
        neighbors := 0;
        for y_shift in -1 to 1 loop
          for x_shift in -1 to 1 loop
            if (x_shift /= 0 or y_shift /= 0) then
              tmp_x := (x_idx + x_shift + dim_x) mod dim_x;
              tmp_y := (y_idx + y_shift + dim_y) mod dim_y;
              if (matrix(tmp_y, tmp_x) = '1') then
                neighbors := neighbors + 1;
              end if;
            end if;
          end loop;
        end loop;

        if (neighbors < 2 or neighbors > 3) then
          next_matrix(y_idx, x_idx) <= '0';
        elsif (matrix(y_idx, x_idx) = '0' and neighbors = 3) then
          next_matrix(y_idx, x_idx) <= '1';
        else
          next_matrix(y_idx, x_idx) <= matrix(y_idx, x_idx);
        end if;

        if (y_idx + 1 >= dim_y) then
          if (x_idx + 1 >= dim_x) then
            matrix_done <= '1';
            x_idx <= 0;
          else
            x_idx <= x_idx + 1;
          end if;
          y_idx <= 0;
        else
          y_idx <= y_idx + 1;
        end if;
      end if;

      if zpos /= "0000" then
        if zpos(3) = '0' and zoom_level > 0 then
          zoom_x_offset <= zoom_x_offset / (zoom_values(zoom_level) - 10) * (zoom_values(zoom_level - 1) - 10);
          zoom_y_offset <= zoom_y_offset / (zoom_values(zoom_level) - 10) * (zoom_values(zoom_level - 1) - 10);
          zoom_level <= zoom_level - 1;
        elsif zpos(3) = '1' and zoom_level < 9 then
          zoom_x_offset <= to_integer(unsigned(xpos)) / 10 * (zoom_values(zoom_level + 1) - 10);
          zoom_y_offset <= to_integer(unsigned(ypos)) / 10 * (zoom_values(zoom_level + 1) - 10);
          zoom_level <= zoom_level + 1;
        end if;
      end if;

      if play = '0' then
        S <= "0000000000";
      else
        case set_time is
          when 0 =>
            S <= "1000000000";
          when 1 =>
            S <= "1100000000";
          when 2 =>
            S <= "1110000000";
          when 3 =>
            S <= "1111000000";
          when 4 =>
            S <= "1111100000";
          when 5 =>
            S <= "1111110000";
          when 6 =>
            S <= "1111111000";
          when 7 =>
            S <= "1111111100";
          when 8 =>
            S <= "1111111110";
          when others =>
            S <= "1111111111";
        end case;

        if (def_speed_d = '0' and def_speed_prev = '1') then
          set_time <= 1;
        elsif (faster_d = '0' and faster_prev = '1' and set_time < 9) then
          set_time <= set_time + 1;
        elsif (slower_d = '0' and slower_prev = '1' and set_time > 0) then
          set_time <= set_time - 1;
        end if;
      end if;
    end if;
  end process game_logic;

  Y0 <= step_counter(0);
  Y1 <= step_counter(1);
  Y2 <= step_counter(2);
  Y3 <= step_counter(3);
end Behavioral;