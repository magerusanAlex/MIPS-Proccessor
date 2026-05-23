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
           PCplus4     : out STD_LOGIC_VECTOR (31 downto 0));
end IFetch;

architecture Behavioral of IFetch is
    signal PC      : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal Next_PC : STD_LOGIC_VECTOR(31 downto 0);
    signal PC4     : STD_LOGIC_VECTOR(31 downto 0);

    type rom_type is array (0 to 63) of std_logic_vector(31 downto 0);
signal ROM : rom_type := (
    -- =====================================
    -- INITIALIZARI
    -- =====================================
    x"20010002", -- 00: addi $1, $0, 2   (a = 2)
    x"2002005A", -- 01: addi $2, $0, 90  (b = 90)
    x"20030007", -- 02: addi $3, $0, 7   (n = 7)
    x"20040000", -- 03: addi $4, $0, 0   (base_addr = 0)
    x"00002820", -- 04: add  $5, $0, $0  (sum = 0)
    x"00003020", -- 05: add  $6, $0, $0  (i = 0)
    x"00000000", -- 06: NoOp (RAW pentru $6)
    x"00000000", -- 07: NoOp (RAW pentru $6)

    -- =====================================
    -- LOOP_START (Index 08)
    -- =====================================
    x"00C3382A", -- 08: slt  $7, $6, $3  (i < n)
    x"00000000", -- 09: NoOp (RAW pt $7)
    x"00000000", -- 10: NoOp (RAW pt $7)
    x"10E0002E", -- 11: beq  $7, $0, end (Sare la index 58. Offset: 58 - 11 - 1 = 46 = 0x2E)
    x"00000000", -- 12: NoOp (Branch Delay)
    x"00000000", -- 13: NoOp (Branch Delay)
    x"00000000", -- 14: NoOp (Branch Delay)

    -- Calcul adresa RAM
    x"00064880", -- 15: sll  $9, $6, 2   (i * 4)
    x"00000000", -- 16: NoOp (RAW pt $9)
    x"00000000", -- 17: NoOp (RAW pt $9)
    x"00894820", -- 18: add  $9, $4, $9  (base + offset)
    x"00000000", -- 19: NoOp (RAW pt $9)
    x"00000000", -- 20: NoOp (RAW pt $9)
    x"8D280000", -- 21: lw   $8, 0($9)   (citim RAM[adresa])
    x"20C60001", -- 22: addi $6, $6, 1   (i = i + 1)
    x"00000000", -- 23: NoOp (Load-Use RAW pt $8)

    -- Filtru 1: val < a
    x"0101382A", -- 24: slt  $7, $8, $1  (val < a)
    x"00000000", -- 25: NoOp (RAW pt $7)
    x"00000000", -- 26: NoOp (RAW pt $7)
    x"14E0FFEC", -- 27: bne  $7, $0, loop_start (Sare la index 08. Offset: 08 - 27 - 1 = -20 = 0xFFEC)
    x"00000000", -- 28: NoOp (Branch Delay)
    x"00000000", -- 29: NoOp (Branch Delay)
    x"00000000", -- 30: NoOp (Branch Delay)

    -- Filtru 2: b < val
    x"0048382A", -- 31: slt  $7, $2, $8  (b < val)
    x"00000000", -- 32: NoOp (RAW pt $7)
    x"00000000", -- 33: NoOp (RAW pt $7)
    x"14E0FFE5", -- 34: bne  $7, $0, loop_start (Sare la index 08. Offset: 08 - 34 - 1 = -27 = 0xFFE5)
    x"00000000", -- 35: NoOp (Branch Delay)
    x"00000000", -- 36: NoOp (Branch Delay)
    x"00000000", -- 37: NoOp (Branch Delay)

    -- Filtru 3: 0 < val
    x"0008382A", -- 38: slt  $7, $0, $8  (0 < val)
    x"00000000", -- 39: NoOp (RAW pt $7)
    x"00000000", -- 40: NoOp (RAW pt $7)
    x"10E0FFDE", -- 41: beq  $7, $0, loop_start (Sare la index 08. Offset: 08 - 41 - 1 = -34 = 0xFFDE)
    x"00000000", -- 42: NoOp (Branch Delay)
    x"00000000", -- 43: NoOp (Branch Delay)
    x"00000000", -- 44: NoOp (Branch Delay)

    -- Filtru 4: Verificare putere a lui 2 (val & (val - 1) == 0)
    x"2109FFFF", -- 45: addi $9, $8, -1  (val - 1)
    x"00000000", -- 46: NoOp (RAW pt $9)
    x"00000000", -- 47: NoOp (RAW pt $9)
    x"01094824", -- 48: and  $9, $8, $9  (val & (val - 1))
    x"00000000", -- 49: NoOp (RAW pt $9)
    x"00000000", -- 50: NoOp (RAW pt $9)
    x"1520FFD4", -- 51: bne  $9, $0, loop_start (Sare la index 08. Offset: 08 - 51 - 1 = -44 = 0xFFD4)
    x"00000000", -- 52: NoOp (Branch Delay)
    x"00000000", -- 53: NoOp (Branch Delay)
    x"00000000", -- 54: NoOp (Branch Delay)

    -- Adaugare in suma
    x"00A82820", -- 55: add  $5, $5, $8  (sum = sum + val)
    x"08000008", -- 56: j    loop_start  (Target absolut = 0x08)
    x"00000000", -- 57: NoOp (Jump Delay)

    -- =====================================
    -- END (Index 58)
    -- =====================================
    x"0800003A", -- 58: j    end         (Target absolut = 58 = 0x3A)
    x"00000000", -- 59: NoOp (Jump Delay)
    
    others => x"00000000"
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
    PCplus4 <= PC4;

    Next_PC <= JumpAddress when Jump = '1' else
               BranchAddress when PCSrc = '1' else
               PC4;

    Instruction <= ROM(conv_integer(PC(7 downto 2)));

end Behavioral;