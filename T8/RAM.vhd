library ieee;
use ieee.numeric_bit.all;

entity ram is
    generic (
        addressSize: natural := 4;
        wordSize: natural := 8
    );
    port (
        ck, wr: in bit;
        addr: in bit_vector(addressSize-1 downto 0);
        data_i: in bit_vector(wordSize-1 downto 0);
        data_o: out bit_vector(wordSize-1 downto 0)
    );
end ram;

architecture arch of ram is

    constant profund: natural := 2**addressSize;
    type mem_t is array (0 to profund-1) of bit_vector(wordSize-1 downto 0);
    
    signal mem: mem_t;

begin

    process(ck)
    begin
        if wr = '1' and rising_edge(ck) then
            mem(to_integer(unsigned(addr))) <= data_i;
        end if;
    end process;

    data_o <= mem(to_integer(unsigned(addr)));

end arch; 