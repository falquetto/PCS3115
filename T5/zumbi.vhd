library ieee;
use ieee.numeric_bit.rising_edge;

entity zumbi is
  port (
    clock, reset: in bit;
    x: in bit_vector (1 downto 0);
    z: out bit
  );
end entity;

-- implemtentação estrutural usando 3 flipflops D
architecture estrutural of zumbi is
  component ffd is
    port (
      clock, clear, set: in bit;
      d: in bit;
      q, q_n: out bit
    );
  end component;
  signal d2, q2, q2_n, d1, q1, q1_n, d0, q0, q0_n: bit;
begin
  ffd2: ffd port map (clock, '0', reset, d2, q2, q2_n);
  ffd1: ffd port map (clock, '0', reset, d1, q1, q1_n);
  ffd0: ffd port map (clock, '0', reset, d0, q0, q0_n);

  d2 <= x(1) and x(0) and q2_n and q0;
  d1 <= (x(1) and (not x(0))) or (x(1) and q1 and q0_n) or (x(1) and q2 and q1_n);
  d0 <= ((not x(1)) and x(0)) or (x(0) and q2 and q1_n);
  z <= (q2_n and q1 and q0_n) or (q2 and q1_n and q0_n);

end architecture;

-- implementação comportamental usando uma maquina de estados finitos
architecture fsm of zumbi is 
  type estados_t is (ini, EA, EL, EVAI, EVAP);
  signal AE, NE: estados_t;
begin
  sincrono: process(clock, reset)
  begin
    if (reset = '1') then
      AE <= ini;
    elsif (rising_edge(clock)) then
      AE <= NE;
    end if;
  end process sincrono;

  NE <=
    ini when x = "00" else
    ini when AE = ini and x = "11" else
    EL when x = "10" else
    EL when AE = EL and x = "11" else
    EA when x = "01" else
    EVAI when AE = EA and x = "11" else
    EVAI when AE = EVAP and x = "11" else
    EVAP when AE = EVAI and x = "11" else
    ini;

  Z <= '1' when AE = EL or AE = EVAI else '0';

end architecture;
