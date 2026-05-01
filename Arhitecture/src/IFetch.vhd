library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port ( clk           : in  STD_LOGIC;
           rst           : in  STD_LOGIC;
           en            : in  STD_LOGIC;
           BranchAddress : in  STD_LOGIC_VECTOR (31 downto 0);
           JumpAddress   : in  STD_LOGIC_VECTOR (31 downto 0);
           Jump          : in  STD_LOGIC;
           PCSrc         : in  STD_LOGIC;
           Instruction   : out STD_LOGIC_VECTOR (31 downto 0);
           PC_plus_4     : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is
    signal PC      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Next_PC : STD_LOGIC_VECTOR(31 downto 0);
    signal PC4     : STD_LOGIC_VECTOR(31 downto 0);

    type rom_type is array (0 to 31) of std_logic_vector(31 downto 0);
signal ROM : rom_type := (
        0  => B"000000_00000_00000_00100_00000_100000", -- [00002020] add  $4, $0, $0   (Adresa de baza RAM = 0)
        1  => B"001000_00000_01010_0000000000010000", -- [200A0010] addi $10, $0, 16  (Adresa de baza array x = 16)
        2  => B"100011_00100_00001_0000000000000000", -- [8C810000] lw   $1, 0($4)    (Citire a)
        3  => B"100011_00100_00010_0000000000000100", -- [8C820004] lw   $2, 4($4)    (Citire b)
        4  => B"100011_00100_00011_0000000000001000", -- [8C830008] lw   $3, 8($4)    (Citire n)
        5  => B"000000_00000_00000_00101_00000_100000", -- [00002820] add  $5, $0, $0   (sum = 0)
        6  => B"000000_00000_00000_00110_00000_100000", -- [00003020] add  $6, $0, $0   (i = 0)
        7  => B"000000_00110_00011_00111_00000_101010", -- [00C3382A] slt  $7, $6, $3   (loop_start)
        8  => B"000100_00111_00000_0000000000001111", -- [10E0000F] beq  $7, $0, 15   (sare la sw)
        9  => B"000000_00000_00110_01001_00010_000000", -- [00064880] sll  $9, $6, 2
        10 => B"000000_01010_01001_01001_00000_100000", -- [01494820] add  $9, $10, $9
        11 => B"100011_01001_01000_0000000000000000", -- [8D280000] lw   $8, 0($9)
        12 => B"001000_00110_00110_0000000000000001", -- [20C60001] addi $6, $6, 1
        13 => B"000000_01000_00001_00111_00000_101010", -- [0101382A] slt  $7, $8, $1
        14 => B"000101_00111_00000_1111111111111000", -- [14E0FFF8] bne  $7, $0, -8   (sare la loop_start)
        15 => B"000000_00010_01000_00111_00000_101010", -- [0048382A] slt  $7, $2, $8
        16 => B"000101_00111_00000_1111111111110110", -- [14E0FFF6] bne  $7, $0, -10  (sare la loop_start)
        17 => B"000000_00000_01000_00111_00000_101010", -- [0008382A] slt  $7, $0, $8
        18 => B"000100_00111_00000_1111111111110100", -- [10E0FFF4] beq  $7, $0, -12  (sare la loop_start)
        19 => B"001000_01000_01001_1111111111111111", -- [2109FFFF] addi $9, $8, -1
        20 => B"000000_01000_01001_01001_00000_100100", -- [01094824] and  $9, $8, $9
        21 => B"000101_01001_00000_1111111111110001", -- [1520FFF1] bne  $9, $0, -15  (sare la loop_start)
        22 => B"000000_00101_01000_00101_00000_100000", -- [00A82820] add  $5, $5, $8
        23 => B"000010_00000000000000000000000111", -- [08000007] j    7            (sare la loop_start)
        24 => B"101011_00100_00101_0000000000001100", -- [AC85000C] sw   $5, 12($4)   (Salveaza suma)
        25 => B"000010_00000000000000000000011001", -- [08000019] j    25           (Loop infinit)
        others => B"000000_00000_00000_00000_00000_000000" -- [00000000] (NoOp)
    );
begin

    process(clk, rst)
    begin
        if rst = '1' then
            PC <= (others => '0');
        elsif rising_edge(clk) then
            if en = '1' then
                PC <= Next_PC;
            end if;
        end if;
    end process;

    PC4 <= PC + 4;
    PC_plus_4 <= PC4;

    Next_PC <= JumpAddress when Jump = '1' else
               BranchAddress when PCSrc = '1' else
               PC4;

    Instruction <= ROM(conv_integer(PC(6 downto 2)));

end Behavioral;