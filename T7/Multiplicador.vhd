library ieee;
use ieee.numeric_bit.all;

-- ENT MULTIPLICADOR
entity multiplicador is
    generic(
        word_size: positive
    );
    port (
        clock, reset, vai: in bit;
        pronto: out bit;
        A, B: in bit_vector(word_size-1 downto 0);
        resultado: out bit_vector(2*word_size-1 downto 0)
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

-- ENT CONTADOR
entity count is
    generic (
        n: positive := 4
    );
    port (
      clock, reset, load, enable: in bit;
      carga: in bit_vector(n-1 downto 0);
      saida: out bit_vector(n-1 downto 0);
      rco: out bit
    );
end entity;

-- ENT SOMADOR
entity somador is
    generic(
        N: positive := 4
    );
    port (
        X, Y: in bit_vector(N-1 downto 0);
        sum: out bit_vector(N-1 downto 0)
    );
end somador;

-- ARCH SOMADOR
architecture rtl of somador is

    signal g, p, c, result: bit_vector(N-1 downto 0);

begin
    
    c(0) <= '0';
    clahead: for i in 0 to N-2 generate
        g(i) <= X(i) and Y(i);
        p(i) <= X(i) or Y(i);
        c(i+1) <= g(i) or (p(i) and c(i));
    end generate;

    res: for i in N-1 downto 0 generate
        result(i) <= X(i) xor Y(i) xor c(i);
    end generate;

    sum <= result;

end rtl;

library ieee;
use ieee.numeric_bit.all;

-- ARCH CONTADOR
architecture arch of count is

    signal tmp: bit_vector(n-1 downto 0);
    signal zeros: bit_vector(n-1 downto 0);
    signal zero: bit := '0';

begin

    process(clock, reset, load, enable)
    begin

      if reset='1' then
        tmp <= (others => '1');
      elsif rising_edge(clock) then
        if enable='1' then
          if load='1' then
            tmp <= carga;
          else
            tmp <= bit_vector(unsigned(tmp)-1);
          end if;
        end if;
      end if;

    end process;

    zeros(0) <= tmp(0);
    gen: for i in 1 to n-1 generate
        zeros(i) <= zeros(i-1) or tmp(i);
    end generate;

    zero <= not zeros(n-1);

    rco <= '1' when zero = '1' else '0';
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

-- ARCH MULTIPLICADOR
architecture behavior of multiplicador is

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

    component count is
        generic (
            n: positive := 4
        );
        port (
            clock, reset, load, enable: in bit;
            carga: in bit_vector(n-1 downto 0);
            saida: out bit_vector(n-1 downto 0);
            rco: out bit
        );
    end component;

    component somador is
        generic(
            N: positive := 4
        );
        port (
            X, Y: in bit_vector(N-1 downto 0);
            sum: out bit_vector(N-1 downto 0)
        );
    end component;

    type states is (ini, foi, temp, soma, fim);
    signal ea, pe: states;

    signal enableB, clearR: bit; -- clock e resets do fd
    signal loadA, loadB, loadR: bit; -- enables dos registradores
    signal zero: bit; -- indica se o contador esta em zero
    signal saida_A, saida_B: bit_vector(word_size-1 downto 0); -- saida do registrador
    signal A_maior, R, saida_R: bit_vector(2*word_size-1 downto 0); -- variaveis do somador
    signal vetorZeros: bit_vector(word_size-1 downto 0) := (others => '0'); -- concatenar com A

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
    prox_estado: process(ea, vai, zero)
    begin
        loadA <= '0';
        loadB <= '0';
        loadR <= '0';
        enableB <= '0';
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
                loadA <= '1';
                loadB <= '1';
                enableB <= '1';
                clearR <= '1';
                
                pe <= soma;

            when soma =>
                if zero = '1' then
                    pe <= fim;
                else 
                    pe <= soma;
                    loadR <= '1';
                    enableB <= '1';
                end if;

            when fim =>
                pronto <= '1';
                pe <= ini;
            
            when others =>
                pe <= ini;
        end case;
    end process;

    -- fluxo de dados
    regA: registrador_universal 
        generic map(word_size)
        port map (clock, '0', '0', loadA, "11", '0', A, saida_A);

    regR: registrador_universal 
        generic map(2*word_size)
        port map (clock, clearR, '0', loadR, "11", '0', R, saida_R);

    contB: count 
        generic map(word_size)
        port map (clock, '0', loadB, enableB, B, saida_B, zero);

    A_maior <= vetorZeros & saida_A;

    sum: somador
        generic map(2*word_size)
        port map (A_maior, saida_R, R);

    resultado <= saida_R;

end behavior;



  