library ieee;
use ieee.numeric_bit.all;

-- ENT DIVISOR
entity divisor is
    generic(
        word_size: positive
    );
    port (
        clock, reset, vai: in bit;
        pronto: out bit;
        A, B: in bit_vector(word_size-1 downto 0);
        resultado, resto: out bit_vector(word_size-1 downto 0)
    );
end entity;

-- ENT REGISTRADOR
library ieee;
use ieee.numeric_bit.all;

entity registrador_universal is
    generic (
        word_size: positive := 4
    );
    port (
        clock, clear, set, enable: in bit;
        control: in bit_vector(1 downto 0);
        serial_input: in bit;
        parallel_input: in bit_vector(word_size-1 downto 0);
        parallel_output: out bit_vector(word_size-1 downto 0)
    );
end entity;

library ieee;
use ieee.numeric_bit.all;

-- ENT CONTADOR
entity CompCount is
    generic (
        n: positive := 4
    );
    port (
      clock, reset, enable: in bit;
      Res, B: in bit_vector(n-1 downto 0);
      saida: out bit_vector(n-1 downto 0);
      fim: out bit
    );
end entity;

library ieee;
use ieee.numeric_bit.all;

-- ENT SUBTRATOR
entity subtrator is
    generic(
        N: positive := 4
    );
    port (
        enable: in bit;
        X, Y: in bit_vector(N-1 downto 0);
        subt: out bit_vector(N-1 downto 0)
    );
end subtrator;

-- ARCH SUBTRATOR
architecture rtl of subtrator is

    signal b, result: bit_vector(N-1 downto 0);

begin
    
    process(X, Y)
    begin
        if enable = '1' then
            result <= bit_vector(unsigned(X) - unsigned(Y));
        end if;
    end process;

    subt <= result;

end rtl;

-- ARCH CONTADOR
architecture arch of CompCount is

    signal tmp: bit_vector(n-1 downto 0) := (others => '0');
    signal RmB: bit := '0';

begin

    process(clock, reset, enable, Res, B)
    begin

      if reset='1' then
        tmp <= (others => '0');
      elsif rising_edge(clock) then
        if enable='1' then
            if unsigned(Res) < unsigned(B) then
                RmB <= '1';
            else 
                tmp <= bit_vector(unsigned(tmp)+1);
            end if;
        end if;
      end if;

    end process;

    fim <= '1' when RmB = '1' else '0';
    saida <= tmp;

end architecture;

-- ARCH REGISTRADOR
architecture funcionamento of registrador_universal is

    signal ea, pe: bit_vector(word_size-1 downto 0);

begin

    process(clock, clear, set)
    begin
        if clear = '1' then
            ea <= (others => '0');
        elsif set = '1' then
            ea <= (others => '1');
        elsif rising_edge(clock) and enable = '1' then
            ea <= pe;
        end if;
    end process;

    -- proximo estado
    with control select 
        pe <=
            ea                                      when "00", -- nao faz nada
            serial_input & ea(word_size-1 downto 1) when "01", -- desloc direita
            ea(word_size-2 downto 0) & serial_input when "10", -- desloc esquerda
            parallel_input                          when others; -- ent paralela
    
    -- saida
    parallel_output <= ea;
end funcionamento; 

-- ARCH DIVISOR
architecture behavior of divisor is

    component registrador_universal is
        generic (
            word_size: positive := 4
        );
        port (
            clock, clear, set, enable: in bit;
            control: in bit_vector(1 downto 0);
            serial_input: in bit;
            parallel_input: in bit_vector(word_size-1 downto 0);
            parallel_output: out bit_vector(word_size-1 downto 0)
        );
    end component;

    component CompCount is
        generic (
            n: positive := 4
        );
        port (
            clock, reset, enable: in bit;
            Res, B: in bit_vector(n-1 downto 0);
            saida: out bit_vector(n-1 downto 0);
            fim: out bit
        );
    end component;

    component subtrator is
        generic(
            N: positive := 4
        );
        port (
            enable: in bit;
            X, Y: in bit_vector(N-1 downto 0);
            subt: out bit_vector(N-1 downto 0)
        );
    end component;

    type states is (ini, foi, sub, fim);
    signal ea, pe: states;

    signal enableSub: bit; -- enables do subtrator e comparador/contador
    signal clearR: bit; -- reseta o registrador no começo da conta
    signal loadMux: bit; -- seleciona entrada do MUX (1 = A / 0 = R)
    signal loadR: bit; -- enable do registrador
    signal ready: bit; -- indica se o comparador acusou o fim
    signal res, R, saidaMux, resul: bit_vector(word_size-1 downto 0); -- saida do registrador

begin

    -- descreve estados da uc
    estado: process(clock, reset)
    begin
        if reset = '1' then
            ea <= ini;
        elsif rising_edge(clock) then
            ea <= pe;
        end if;
    end process;

    -- logica de proximo estado da uc
    prox_estado: process(ea, vai, ready)
    begin
        loadMux <= '0';
        loadR <= '0';
        enableSub <= '0';
        clearR <= '0';
        pronto <= '0';

        case ea is 
            when ini =>
                if vai = '1' then
                    pe <= foi;
                else 
                    pe <= ini;
                end if;

            when foi =>
                loadMux <= '1';
                clearR <= '1';
                
                pe <= sub;

            when sub =>
                if ready = '1' then
                    enableSub <= '0';
                    pe <= fim;
                else 
                    pe <= sub;
                    loadR <= '1';
                    enableSub <= '1';
                end if;

            when fim =>
                pronto <= '1';
                pe <= ini;
            
            when others =>
                pe <= ini;
        end case;
    end process;

    -- fluxo de dados
    regR: registrador_universal 
        generic map(word_size)
        port map (clock, clearR, '0', loadR, "11", '0', res, R);

    comp_conta: CompCount 
        generic map(word_size)
        port map (clock, '0', enableSub, B, res, resul, ready);

    -- Mux 2x1
    saidaMux <= A when loadMux = '1' else R;

    subs: subtrator
        generic map(word_size)
        port map (enableSub, saidaMux, B, res);

    resultado <= resul;
    resto <= res;

end behavior;



  