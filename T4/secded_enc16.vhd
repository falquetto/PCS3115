entity secded_enc16 is
  port (
    u_data: in bit_vector (15 downto 0);
    mem_data: out bit_vector (21 downto 0)
  );
end entity;

architecture arch of secded_enc16 is
  signal par: bit_vector (5 downto 0);
  signal temp: bit_vector (1 downto 0);
begin
  par(5) <=  temp(0) xor temp(1);
  par(4) <= u_data(15) xor u_data(14) xor u_data(13) xor u_data(12) xor u_data(11);
  par(3) <= u_data(10) xor u_data(9) xor u_data(8) xor u_data(7) xor u_data(6) xor u_data(5) xor u_data(4);
  par(2) <= u_data(15) xor u_data(14) xor u_data(10) xor u_data(9) xor u_data(8) xor u_data(7) xor u_data(3) xor u_data(2) xor u_data(1);
  par(1) <= u_data(13) xor u_data(12) xor u_data(10) xor u_data(9) xor u_data(6) xor u_data(5) xor u_data(3) xor u_data(2) xor u_data(0);
  par(0) <= u_data(15) xor u_data(13) xor u_data(11) xor u_data(10) xor u_data(8) xor u_data(6) xor u_data(4) xor u_data(3) xor u_data(1) xor u_data(0);

  temp(0) <= par(0) xor par(1) xor par(2) xor par(3) xor par(4);
  temp(1) <= u_data(15) xor u_data(14) xor u_data(13) xor u_data(12) xor u_data(11) xor u_data(10) xor u_data(9) xor u_data(8) xor u_data(7) xor u_data(6) xor u_data(5) xor u_data(4) xor u_data(3) xor u_data(2) xor u_data(1) xor u_data(0);

  mem_data(21) <= par(5);
  mem_data(20) <= u_data(15);
  mem_data(19) <= u_data(14);
  mem_data(18) <= u_data(13);
  mem_data(17) <= u_data(12);
  mem_data(16) <= u_data(11);
  mem_data(15) <= par(4);
  mem_data(14) <= u_data(10);
  mem_data(13) <= u_data(9);
  mem_data(12) <= u_data(8);
  mem_data(11) <= u_data(7);
  mem_data(10) <= u_data(6);
  mem_data(9) <= u_data(5);
  mem_data(8) <= u_data(4);
  mem_data(7) <= par(3);
  mem_data(6) <= u_data(3);
  mem_data(5) <= u_data(2);
  mem_data(4) <= u_data(1);
  mem_data(3) <= par(2);
  mem_data(2) <= u_data(0);
  mem_data(1) <= par(1);
  mem_data(0) <= par(0);
end arch;
