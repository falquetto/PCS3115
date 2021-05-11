entity gray2bin is
    port (
        gray2, gray1, gray0: in bit;
        bin2, bin1, bin0: out bit
    );
end entity;

architecture gray2bin_ar of gray2bin is
begin
    bin2 <= gray2;
    bin1 <= gray2 xor gray1;
    bin0 <= gray1 xor gray2 xor gray0;
end architecture;