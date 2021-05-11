entity incinerador is
    port(
        led: out bit;
        S: in bit_vector (2 downto 0);
        P: out bit
    );
end entity;

architecture arch of incinerador is
    signal temp: bit_vector (5 downto 0);
begin
    temp(5) <= S(0) and S(1);
    temp(4) <= S(0) and S(2);
    temp(3) <= S(1) and S(2);
    P <= temp(5) or temp(4) or temp(3);
    temp(2) <= S(0) or (not S(2));
    temp(1) <= (not S(1)) or S(2);
    temp(0) <=  (not S(0)) or S(1);
    led <= temp(2) or temp(1) or temp(0);
end arch;
