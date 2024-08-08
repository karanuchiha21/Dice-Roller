
Conversation opened. 1 read message.

Skip to content
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity dice_roller is
    Port (
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        roll : in STD_LOGIC;
		  select_faces: in std_LOGIC_VECTOR(2 downto 0);
        dice1 : out STD_LOGIC_VECTOR(2 DOWNTO 0);
        dice2 : out STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
end dice_roller;

architecture Behaviour of dice_roller is
    type state_type is (resetting, rolling, holding);
    signal current_state, next_state : state_type;
    signal lfsr_out1, lfsr_out2 : std_logic_vector(2 downto 0);
    signal lfsr_out3, lfsr_out4 : std_logic_vector(2 downto 0);
    signal lfsr_enable: std_logic;
	 signal selected_faces: std_LOGIC_VECTOR(2 downto 0);
    signal seed1 : std_logic_vector(2 downto 0) := "001";
    signal seed2 : std_logic_vector(2 downto 0) := "011";
    signal half_second : std_logic;

    component LFSR
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enable : in STD_LOGIC;
            lfsr_seed: in std_logic_vector(2 downto 0);
				num_faces: std_LOGIC_VECTOR(2 downto 0);
            lfsr_out : out STD_LOGIC_VECTOR(2 downto 0)
        );
    end component;

begin

    obj1: LFSR
        Port map (
            clk => clk,
            reset => reset,
            enable => lfsr_enable,
            lfsr_seed => seed1,
				num_faces => selected_faces,
            lfsr_out => lfsr_out3
        );

    obj2: LFSR
        Port map (
            clk => clk,
            reset => reset,
            enable => lfsr_enable,
            lfsr_seed => seed2,
				num_faces => selected_faces,
            lfsr_out => lfsr_out4
        );

    -- Finite State Machine
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= resetting;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;

    process(current_state, roll)
    begin
        case current_state is
            when resetting =>
                lfsr_enable <= '0';
                if roll = '1' then
                    next_state <= rolling;
                else
                    next_state <= resetting;
                end if;

            when rolling =>
                lfsr_enable <= '1';
                if roll = '0' then
                    next_state <= holding;
                else
                    next_state <= rolling;
                end if;

            when holding =>
                lfsr_enable <= '0';
                if roll = '1' then
                    next_state <= rolling;
                else
                    next_state <= holding;
                end if;
        end case;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if current_state = rolling then
					 selected_faces<= select_faces;
                lfsr_out1 <= lfsr_out3;
                lfsr_out2 <= lfsr_out4;
				elsif current_state = resetting then
					 lfsr_out1 <= (others => '0');
                lfsr_out2 <= (others => '0');
            end if;
        end if;
    end process;

    dice1 <= lfsr_out1;
    dice2 <= lfsr_out2;

end Behaviour;
