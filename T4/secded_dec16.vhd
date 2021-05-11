library ieee;
use ieee.numeric_bit.all;
use ieee.math_real.all;

entity secded_dec16 is
  port (
    mem_data: in bit_vector (21 downto 0);
    u_data: out bit_vector (15 downto 0);
    syndrome: out natural;
    two_errors: out bit;
    one_error: out bit
  );
end entity;

architecture arch of secded_dec16 is

  signal temp: bit_vector (21 downto 0);
  signal synd_calc: bit_vector (5 downto 0);
  signal synd: bit_vector (4 downto 0);
  signal synd_value: natural;
  signal has_error: bit;
  signal temp1: bit_vector (1 downto 0);
  signal compare: bit;

begin
  temp1(1) <= synd_calc(4) xor synd_calc(3) xor synd_calc(2) xor synd_calc(1) xor synd_calc(0);
  temp(0) <= mem_data(20) xor mem_data(19) xor mem_data(18) xor mem_data(17) xor mem_data(16) xor mem_data(14) xor mem_data(13) xor mem_data(12) xor mem_data(11) xor mem_data(10) xor mem_data(9) xor mem_data(8) xor mem_data(6) xor mem_data(5) xor mem_data(4) xor mem_data(2);

  synd_calc(5) <= temp(1) xor temp(0);
  synd_calc(4) <= mem_data(20) xor mem_data(19) xor mem_data(18) xor mem_data(17) xor mem_data(16);
  synd_calc(3) <= mem_data(14) xor mem_data(13) xor mem_data(12) xor mem_data(11) xor mem_data(10) xor mem_data(9) xor mem_data(8);
  synd_calc(2) <= mem_data(20) xor mem_data(19) xor mem_data(14) xor mem_data(13) xor mem_data(12) xor mem_data(11) xor mem_data(6) xor mem_data(5) xor mem_data(4);
  synd_calc(1) <= mem_data(18) xor mem_data(17) xor mem_data(14) xor mem_data(13) xor mem_data(10) xor mem_data(9) xor mem_data(6) xor mem_data(5) xor mem_data(2);
  synd_calc(0) <= mem_data(20) xor mem_data(18) xor mem_data(16) xor mem_data(14) xor mem_data(12) xor mem_data(10) xor mem_data(8) xor mem_data(6) xor mem_data(4) xor mem_data(2);

  compare <= synd_calc(5) xor mem_data(21);
  synd(4) <= synd_calc(4) xor mem_data(15);
  synd(3) <= synd_calc(3) xor mem_data(7);
  synd(2) <= synd_calc(2) xor mem_data(3);
  synd(1) <= synd_calc(1) xor mem_data(1);
  synd(0) <= synd_calc(0) xor mem_data(0);

  synd_value <= to_integer(unsigned(synd));
  syndrome <= synd_value;

  has_error <= synd(0) or synd(1) or synd(2) or synd(3) or synd(4);

  gen_correction: for i in 21 downto 0 generate
     temp(i) <= not mem_data(i) when i = (synd_value - 1) else mem_data(i);
  end generate gen_correction;

  one_error <= '1' when compare = '1' and has_error = '1' else '0';
  two_errors <= '1' when has_error = '1' and compare = '0' else '0';

  u_data(15) <= temp(20);
  u_data(14) <= temp(19);
  u_data(13) <= temp(18);
  u_data(12) <= temp(17);
  u_data(11) <= temp(16);
  u_data(10) <= temp(14);
  u_data(9) <= temp(13);
  u_data(8) <= temp(12);
  u_data(7) <= temp(11);
  u_data(6) <= temp(10);
  u_data(5) <= temp(9);
  u_data(4) <= temp(8);
  u_data(3) <= temp(6);
  u_data(2) <= temp(5);
  u_data(1) <= temp(4);
  u_data(0) <= temp(2);

end arch;
