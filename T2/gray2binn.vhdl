entity gray2bin is
    generic (
        size: natural := 3
    );
    port (
        gray: in bit_vector (size-1 downto 0);
        bin: out bit_vector (size-1 downto 0)
    );
end entity;

architecture gray2binn_ar of gray2bin is
    signal temp: bit_vector(size-1 downto 0);
begin
    temp(size-1) <= gray(size-1);
    bin(size-1) <= temp(size-1);
        
    gen_grays: for i in size-2 downto 0 generate
        temp(i) <= gray(i) xor temp(i + 1);
        bin(i) <= temp(i);
    end generate gen_grays;
end architecture;
