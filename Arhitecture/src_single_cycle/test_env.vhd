library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env is
    Port ( clk : in  STD_LOGIC;
           btn : in  STD_LOGIC_VECTOR (4 downto 0);
           sw  : in  STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an  : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

    component IFetch is
        Port ( clk           : in  STD_LOGIC;
               rst           : in  STD_LOGIC;
               en            : in  STD_LOGIC;
               BranchAddress : in  STD_LOGIC_VECTOR (31 downto 0);
               JumpAddress   : in  STD_LOGIC_VECTOR (31 downto 0);
               Jump          : in  STD_LOGIC;
               PCSrc         : in  STD_LOGIC;
               Instruction   : out STD_LOGIC_VECTOR (31 downto 0);
               PC_plus_4     : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component UC is
        Port ( Instr_opcode : in  STD_LOGIC_VECTOR (5 downto 0);
               RegDst       : out STD_LOGIC;
               ExtOp        : out STD_LOGIC;
               ALUSrc       : out STD_LOGIC;
               Branch       : out STD_LOGIC;
               BranchNotEq  : out STD_LOGIC;
               Jump         : out STD_LOGIC;
               ALUOp        : out STD_LOGIC_VECTOR (1 downto 0);
               MemWrite     : out STD_LOGIC;
               MemtoReg     : out STD_LOGIC;
               RegWrite     : out STD_LOGIC);
    end component;

    component IDecode is
        Port ( clk          : in  STD_LOGIC;
               en           : in  STD_LOGIC;
               Instr        : in  STD_LOGIC_VECTOR (25 downto 0);
               WD           : in  STD_LOGIC_VECTOR (31 downto 0);
               RegWrite     : in  STD_LOGIC;
               RegDst       : in  STD_LOGIC;
               ExtOp        : in  STD_LOGIC;
               RD1          : out STD_LOGIC_VECTOR (31 downto 0);
               RD2          : out STD_LOGIC_VECTOR (31 downto 0);
               Ext_Imm      : out STD_LOGIC_VECTOR (31 downto 0);
               func         : out STD_LOGIC_VECTOR (5 downto 0);
               sa           : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    component EX is
        Port ( PC_plus_4     : in  STD_LOGIC_VECTOR (31 downto 0);
               RD1           : in  STD_LOGIC_VECTOR (31 downto 0);
               RD2           : in  STD_LOGIC_VECTOR (31 downto 0);
               Ext_Imm       : in  STD_LOGIC_VECTOR (31 downto 0);
               ALUSrc        : in  STD_LOGIC;
               ALUOp         : in  STD_LOGIC_VECTOR (1 downto 0);
               func          : in  STD_LOGIC_VECTOR (5 downto 0);
               sa            : in  STD_LOGIC_VECTOR (4 downto 0);
               BranchAddress : out STD_LOGIC_VECTOR (31 downto 0);
               ALURes        : out STD_LOGIC_VECTOR (31 downto 0);
               Zero          : out STD_LOGIC);
    end component;

    component MEM is
        Port ( clk        : in  STD_LOGIC;
               en         : in  STD_LOGIC;
               MemWrite   : in  STD_LOGIC;
               ALUResin   : in  STD_LOGIC_VECTOR (31 downto 0);
               RD2        : in  STD_LOGIC_VECTOR (31 downto 0);
               MemData    : out STD_LOGIC_VECTOR (31 downto 0);
               ALUResout  : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component MPG is
        Port ( enable : out STD_LOGIC;
               btn : in STD_LOGIC;
               clk : in STD_LOGIC);
    end component;

    component SSD is
        Port ( clk : in STD_LOGIC;
               digits : in STD_LOGIC_VECTOR(31 downto 0);
               an : out STD_LOGIC_VECTOR(7 downto 0);
               cat : out STD_LOGIC_VECTOR(6 downto 0));
    end component;

    signal en : STD_LOGIC;
    signal rst : STD_LOGIC;

    signal Instruction : STD_LOGIC_VECTOR(31 downto 0);
    signal PC_plus_4   : STD_LOGIC_VECTOR(31 downto 0);
    
    signal RegDst, ExtOp, ALUSrc, Branch, BranchNotEq, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
    signal ALUOp : STD_LOGIC_VECTOR(1 downto 0);
    
    signal RD1, RD2, Ext_Imm : STD_LOGIC_VECTOR(31 downto 0);
    signal func : STD_LOGIC_VECTOR(5 downto 0);
    signal sa   : STD_LOGIC_VECTOR(4 downto 0);
    
    signal BranchAddress, ALURes : STD_LOGIC_VECTOR(31 downto 0);
    signal Zero : STD_LOGIC;
    
    signal MemData, ALUResout : STD_LOGIC_VECTOR(31 downto 0);
    
    signal WD : STD_LOGIC_VECTOR(31 downto 0);

    signal PCSrc : STD_LOGIC;
    signal JumpAddress : STD_LOGIC_VECTOR(31 downto 0);

    signal digits_out : STD_LOGIC_VECTOR(31 downto 0);

begin

    empege: MPG port map (enable => en, btn => btn(0), clk => clk);
    rst <= btn(1);

    display: SSD port map (clk => clk, digits => digits_out, an => an, cat => cat);

    inst_IFetch: IFetch port map (
        clk => clk, rst => rst, en => en,
        BranchAddress => BranchAddress,
        JumpAddress => JumpAddress,
        Jump => Jump,
        PCSrc => PCSrc,
        Instruction => Instruction,
        PC_plus_4 => PC_plus_4
    );

    inst_UC: UC port map (
        Instr_opcode => Instruction(31 downto 26),
        RegDst => RegDst, ExtOp => ExtOp, ALUSrc => ALUSrc,
        Branch => Branch, BranchNotEq => BranchNotEq, Jump => Jump,
        ALUOp => ALUOp,
        MemWrite => MemWrite, MemtoReg => MemtoReg, RegWrite => RegWrite
    );

    inst_IDecode: IDecode port map (
        clk => clk, en => en,
        Instr => Instruction(25 downto 0),
        WD => WD,
        RegWrite => RegWrite, RegDst => RegDst, ExtOp => ExtOp,
        RD1 => RD1, RD2 => RD2, Ext_Imm => Ext_Imm,
        func => func, sa => sa
    );

    inst_EX: EX port map (
        PC_plus_4 => PC_plus_4,
        RD1 => RD1, RD2 => RD2, Ext_Imm => Ext_Imm,
        ALUSrc => ALUSrc, ALUOp => ALUOp, func => func, sa => sa,
        BranchAddress => BranchAddress,
        ALURes => ALURes, Zero => Zero
    );

    inst_MEM: MEM port map (
        clk => clk, en => en,
        MemWrite => MemWrite,
        ALUResin => ALURes, RD2 => RD2,
        MemData => MemData, ALUResout => ALUResout
    );

    WD <= MemData when MemtoReg = '1' else ALUResout;

    PCSrc <= (Branch and Zero) or (BranchNotEq and not Zero);
    
    JumpAddress <= PC_plus_4(31 downto 28) & Instruction(25 downto 0) & "00";
    
    led(0) <= RegDst;
    led(1) <= ExtOp;
    led(2) <= ALUSrc;
    led(3) <= Branch;
    led(4) <= BranchNotEq;
    led(5) <= Jump;
    led(6) <= MemWrite;
    led(7) <= MemtoReg;
    led(8) <= RegWrite;
    led(10 downto 9) <= ALUOp;
    led(15 downto 11) <= (others => '0'); -- Restul ledurilor oprite

    process(sw(7 downto 5), Instruction, PC_plus_4, RD1, RD2, Ext_Imm, ALURes, MemData, WD)
    begin
        case sw(7 downto 5) is
            when "000" => digits_out <= Instruction;
            when "001" => digits_out <= PC_plus_4;
            when "010" => digits_out <= RD1;
            when "011" => digits_out <= RD2;
            when "100" => digits_out <= Ext_Imm;
            when "101" => digits_out <= ALURes;
            when "110" => digits_out <= MemData;
            when "111" => digits_out <= WD;
            when others => digits_out <= (others => '0');
        end case;
    end process;

end Behavioral;