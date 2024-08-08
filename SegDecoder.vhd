LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY SegDecoder IS
    PORT (
        D : IN STD_LOGIC_VECTOR(2 DOWNTO 0);
        Y : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
    );
END SegDecoder;

ARCHITECTURE LogicFunction OF SegDecoder IS
BEGIN
    WITH D SELECT
        Y <= "1000000" WHEN "000",
             "1111001" WHEN "001",
             "0100100" WHEN "010",
             "0110000" WHEN "011",
             "0011001" WHEN "100",
             "0010010" WHEN "101",
             "0000010" WHEN "110",
             "1111000" WHEN "111";
END LogicFunction;
