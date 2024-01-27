library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity encoder7seg is
  port (
    signal Y0 : in std_logic_vector (3 downto 0);
    signal Y1 : in std_logic_vector (3 downto 0);
    signal Y2 : in std_logic_vector (3 downto 0);
    signal Y3 : in std_logic_vector (3 downto 0);
    signal Vec0 : out std_logic_vector (6 downto 0);
    signal Vec1 : out std_logic_vector (6 downto 0);
    signal Vec2 : out std_logic_vector (6 downto 0);
    signal Vec3 : out std_logic_vector (6 downto 0)
  );
end encoder7seg;

architecture secuencial of encoder7seg is
  type t_array_in is array (3 downto 0) of std_logic_vector (3 downto 0);
  type t_array_out is array (3 downto 0) of std_logic_vector (6 downto 0);
begin
  process (Y0, Y1, Y2, Y3)
    variable Y : t_array_in;
    variable Vec : t_array_out;
  begin
    Y(0) := Y0;
    Y(1) := Y1;
    Y(2) := Y2;
    Y(3) := Y3;

    for i in 0 to 3 loop
      case Y(i) is
        when "1111" => Vec(i) := "0111000";
        when "1110" => Vec(i) := "0110000";
        when "1101" => Vec(i) := "1000010";
        when "1100" => Vec(i) := "0110001";
        when "1011" => Vec(i) := "1100000";
        when "1010" => Vec(i) := "0001000";
        when "1001" => Vec(i) := "0001100";
        when "1000" => Vec(i) := "0000000";
        when "0111" => Vec(i) := "0001111";
        when "0110" => Vec(i) := "0100000";
        when "0101" => Vec(i) := "0100100";
        when "0100" => Vec(i) := "1001100";
        when "0011" => Vec(i) := "0000110";
        when "0010" => Vec(i) := "0010010";
        when "0001" => Vec(i) := "1001111";
        when others => Vec(i) := "0000001";
      end case;
    end loop;

    Vec0 <= Vec(0);
    Vec1 <= Vec(1);
    Vec2 <= Vec(2);
    Vec3 <= Vec(3);
  end process;
end secuencial;