library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity LFSR is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC;
        lfsr_seed: in std_logic_vector(2 downto 0);
		  num_faces: in std_LOGIC_VECTOR(2 downto 0);
        lfsr_out : out STD_LOGIC_VECTOR(2 downto 0)
    );
end LFSR;

architecture Behaviour of LFSR is
    signal lfsr_reg : STD_LOGIC_VECTOR(2 downto 0);
begin
    process(clk, reset)
    begin
        if reset = '1' then
            lfsr_reg <= lfsr_seed;
        elsif rising_edge(clk) then
            if enable = '1' then
                lfsr_reg <= lfsr_reg(1 downto 0) & (lfsr_reg(2) xor lfsr_reg(0));
            end if;
        end if;
    end process;
    lfsr_out <= std_logic_vector((unsigned(lfsr_reg) mod unsigned(num_faces)) + 1);
end Behaviour;
