library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ClockDivider is
    Port ( 
        CLOCK_50     : in  STD_LOGIC;
        reset        : in  STD_LOGIC;
        half_second  : out STD_LOGIC
    );
end ClockDivider;

architecture Behavioral of ClockDivider is
    signal counter : STD_LOGIC_VECTOR(24 downto 0) := (others => '0');
    signal clk_1Hz : STD_LOGIC := '0';
begin
    process(CLOCK_50, reset)
    begin
        if reset = '1' then
            counter <= (others => '0');
            clk_1Hz <= '0';
        elsif rising_edge(CLOCK_50) then
            if counter = "0000111010011100001000000" then--clock can be made faster by reducing this number, but for proper simulation 
                counter <= (others => '0');					--im keeping it to approximately 0.5 seconds 0000111010011100001000000
                clk_1Hz <= not clk_1Hz;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;

    -- Generate the 0.5-second clock
    half_second <= clk_1Hz;

end Behavioral;
