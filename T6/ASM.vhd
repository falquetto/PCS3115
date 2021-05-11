library ieee;
use ieee.numeric_bit.rising_edge;

entity gcd_uc is
    port (
        clock, reset: in bit;
        vai, AigualB, AmaiorB: in bit;
        carregaA, carregaB, BmA, sub, fim: out bit
    );
end entity;

architecture uc of gcd_uc is

    type states is (ini, interm, igual, Amaior, Amenor);
    signal ea, pe: states;

begin

    process(clock, reset)
    begin
        if reset = '1' then
            ea <= ini;
        elsif rising_edge(clock) then
            ea <= pe;
        end if;
    end process;

    unidcont: process(ea, vai, AigualB, AmaiorB)
    begin

        carregaA <= '1';
        carregaB <= '1';
        BmA <= '0';
        fim <= '0';
        sub <= '0';
        
        case(ea) is
            when ini =>
                if vai = '1' then pe <= interm; 
                end if;
            
            when interm =>
                if AigualB = '1' then 
                    pe <= igual; 
                elsif AmaiorB = '1' then 
                    pe <= Amaior; 
                else
                    pe <= Amenor;
                end if;
                carregaA <= '0';
                carregaB <= '0';
            
            when igual =>
                pe <= ini;
                fim <= '1';
            
            when Amaior =>
                pe <= interm;
                carregaB <= '0';
                sub <= '1';
            
            when Amenor =>
                pe <= interm;
                sub <= '1';
                carregaA <= '0';
                BmA <= '1';
            
            when others =>
                pe <= ini;
        end case;
    end unidcont;          

end uc;