entity incinerador is
    port(
        S: in bit_vector (2 downto 0);
        P: out bit
    );
end entity;

architecture arch of incinerador is
    signal temp: bit_vector (2 downto 0);
begin
    temp(2) <= S(0) and S(1);
    temp(1) <= S(0) and S(2);
    temp(0) <= S(1) and S(2);
    P <= temp(2) or temp(1) or temp(0);
end arch;
