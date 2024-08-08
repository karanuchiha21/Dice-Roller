library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity DiceSystem is
    Port (
        CLOCK_50 : in std_logic;
        SW : in std_logic_vector(17 downto 0);
        KEY : in std_logic_vector(0 downto 0);
        HEX0, HEX1 : out std_logic_vector(6 downto 0)
    );
end DiceSystem;

architecture behaviour of DiceSystem is

    signal Final_dice1, Final_dice2 : std_logic_vector(2 downto 0);
    signal half_second : std_logic;
    signal roll_trigger1, roll_trigger2 : std_logic := '0';
	 signal rollCounter1, rollCounter2 : integer range 0 to 20 := 0;
	 signal selected_faces: Std_LOGIC_VECTOR(2 downto 0);
	 Signal iFinal_dice1,iFinal_dice2,iFinal_dice3, iFinal_dice4 : std_logic_vector(2 downto 0);
	 type state_type is (resetting, rolling1, rolling2, selecting);
    signal present_state, next_state: state_type;

    component dice_roller is
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            roll : in STD_LOGIC;
				select_faces: in Std_LOGIC_VECTOR(2 downto 0);
            dice1 : out STD_LOGIC_VECTOR(2 DOWNTO 0);
            dice2 : out STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    end component;
	 
    component dice_roller2 is
        Port (
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            roll : in STD_LOGIC;
				select_faces: in Std_LOGIC_VECTOR(2 downto 0);
            dice1 : out STD_LOGIC_VECTOR(2 DOWNTO 0);
            dice2 : out STD_LOGIC_VECTOR(2 DOWNTO 0)
        );
    end component;

    component SegDecoder is
        port (
            D : in std_logic_vector(2 downto 0);
            Y : out std_logic_vector(6 downto 0)
        );
    end component;

    component ClockDivider is
        Port (
            CLOCK_50 : in STD_LOGIC;
            reset : in STD_LOGIC;
            half_second : out STD_LOGIC
        );
    end component;

begin

    clk_divider: ClockDivider
        Port map (
            CLOCK_50 => CLOCK_50, --fpga clock
            reset    => SW(0),
            half_second => half_second
        );

    -- Instantiate the dice_roller
    obj1: dice_roller
        Port map (
            clk => half_second,  -- Use the half-second clock
            reset => SW(0),
            roll => roll_trigger1,
				select_faces => selected_faces,
            dice1 => iFinal_dice1,
            dice2 => iFinal_dice3
        );
	obj2: dice_roller2
        Port map (
            clk => half_second,  -- Use the half-second clock
            reset => SW(0),
            roll => roll_trigger2,
				select_faces => selected_faces,
            dice1 => iFinal_dice2,
            dice2 => iFinal_dice4
        );


    -- Instantiate the SegDecoders
    seg1: SegDecoder
        Port map (
            D => Final_dice1,
            Y => HEX0
        );

    seg2: SegDecoder
        Port map (
            D => Final_dice2,
            Y => HEX1
        );

    -- Roll trigger logic
    process(half_second, SW(0))
    begin
		 if SW(0) = '1' then
			present_state <= resetting;
		 elsif rising_edge(half_second) then
			present_state <= next_state;
		end if;
	end process;
	
	process(half_second, present_state, KEY, SW)
	begin
		case present_state is
			when resetting =>	-- reset state
				if SW(1) = '1' then
					next_state <= selecting;
				else 
					next_state <= resetting;
				end if;
				
			when selecting => -- selecting the number of dice state
				if SW(1) = '1' then
					selected_faces <= SW(5 downto 3);
					if SW(16) = '1' and SW(17) = '0' then
						next_state <= rolling1;
					elsif (SW(17) = '1' and SW(16) = '0') or (SW(17) = '1' and SW(16) = '1') then
						next_state <= rolling2;
					else
						next_state<= selecting;
					end if;
				else
						next_state<= selecting;
				end if;
			
			when rolling1 =>	--rolling 1 dice state
				if SW(1) ='1' then 
					next_state <= selecting;
				end if;

			when rolling2 =>	-- rolling 2 dice state
				if SW(1) = '1' then 
					next_state <= selecting;
				end if;
				
			when others =>
				next_state <= resetting;--changed from rolling1
			
			end case;
    end process;
	  process(half_second)
    begin
	 		  if SW(0) = '1' then
					roll_trigger1 <= '0';
					roll_trigger2 <= '0';
					Final_dice1 <= "000";
					Final_dice2 <= "000";
			else
        if rising_edge(half_second) then
				if SW(2) = '1' then
					if present_state = rolling1 then
						Final_dice1 <="000";
					elsif present_state = rolling2 then
						Final_dice2 <= "000";
					end if;
				
            elsif present_state = rolling2 then
					if KEY(0) ='0' then
						rollCounter1 <= 0;
						rollCounter2 <=0;
						roll_trigger1 <= '1';
						roll_trigger2 <= '1';
					elsif rollCounter1 < 20 then
						rollCounter1 <= rollCounter1 + 1;
						roll_trigger1<= '1';
						roll_trigger2<= '1';
						Final_dice1 <= iFinal_dice1;
						Final_dice2 <= iFinal_dice2;
					else
						roll_trigger1 <='0';
						--roll_trigger2 <='0';
					end if;
					if rollCounter2 < 30 then 
                    rollCounter2 <= rollCounter2 + 1;
                    roll_trigger2 <= '1';
                    Final_dice2 <= iFinal_dice2;
                else
                    roll_trigger2 <= '0';
                end if;
					 
				elsif present_state = rolling1 then
					if KEY(0) ='0' then
						rollCounter1 <= 0;
						roll_trigger1 <= '1';
						roll_trigger2 <= '0';
					elsif rollCounter1 < 20 then
						rollCounter1 <= rollCounter1 + 1;
						roll_trigger1<= '1';
						roll_trigger2 <= '0'; --may not need
						Final_dice1 <= iFinal_dice1;
					--	Final_dice2 <= "000";
					else
						roll_trigger1 <='0';
					end if;
				elsif present_state <= resetting then 
					roll_trigger1 <= '0';
					roll_trigger2 <= '0';
					Final_dice1 <= "000";
					Final_dice2 <= "000";
				end if;
        end if;
		 end if;
    end process;
end behaviour;
