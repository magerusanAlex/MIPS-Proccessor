library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MEM is
    Port ( clk        : in  STD_LOGIC;
           en         : in  STD_LOGIC;
           MemWrite   : in  STD_LOGIC;
           ALUResin   : in  STD_LOGIC_VECTOR (31 downto 0);
           RD2        : in  STD_LOGIC_VECTOR (31 downto 0);
           MemData    : out STD_LOGIC_VECTOR (31 downto 0);
           ALUResout  : out STD_LOGIC_VECTOR (31 downto 0));
end MEM;

architecture Behavioral of MEM is

    type ram_type is array (0 to 63) of STD_LOGIC_VECTOR(31 downto 0);
    
    signal RAM : ram_type := (
        0 => x"00000002", -- RAM[0]: a = 2
        1 => x"0000005A", -- RAM[4]: b = 90
        2 => x"00000004", -- RAM[8]: n = 4
        3 => x"00000000", -- RAM[12]: sum = 0 (aici se va salva rezultatul)
        4 => x"00000002", -- RAM[16]: x[0] = 2
        5 => x"00000001", -- RAM[20]: x[1] = 1
        6 => x"00000000", -- RAM[24]: x[2] = 0
        7 => x"00000020", -- RAM[28]: x[3] = 32
        others => x"00000000"
    );

begin

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                if MemWrite = '1' then
                    RAM(conv_integer(ALUResin(7 downto 2))) <= RD2;
                end if;
            end if;
        end if;
    end process;

    -- Citire asincrona (in afara procesului)
    MemData <= RAM(conv_integer(ALUResin(7 downto 2)));
    ALUResout <= ALUResin;

end Behavioral;