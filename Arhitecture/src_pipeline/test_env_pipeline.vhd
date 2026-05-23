library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity test_env_pipeline is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw  : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an  : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env_pipeline;

architecture Behavioral of test_env_pipeline is
    -- component declarations
    component MPG is
        Port ( en : out STD_LOGIC; btn : in STD_LOGIC; clk : in STD_LOGIC);
    end component;

    component SSD is
        Port ( digits : in STD_LOGIC_VECTOR (31 downto 0);   -- note: 'digits'
               clk : in STD_LOGIC;
               cat : out STD_LOGIC_VECTOR (6 downto 0);
               an : out STD_LOGIC_VECTOR (7 downto 0));
    end component;

    component IFetch is
        Port ( clk, rst, en : in STD_LOGIC;
               BranchAddress, JumpAddress : in STD_LOGIC_VECTOR (31 downto 0);
               Jump, PCSrc : in STD_LOGIC;
               Instruction, PCplus4 : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    component IDecode is
        Port ( clk, en : in STD_LOGIC;
               Instr : in STD_LOGIC_VECTOR (25 downto 0);
               WD : in STD_LOGIC_VECTOR (31 downto 0);
               RegWrite : in STD_LOGIC;
               WA : in STD_LOGIC_VECTOR (4 downto 0);      -- corrected name
               ExtOp : in STD_LOGIC;
               RD1, RD2, Ext_Imm : out STD_LOGIC_VECTOR (31 downto 0);
               func : out STD_LOGIC_VECTOR (5 downto 0);
               sa, rt, rd : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    component UC is
        Port ( Instr : in STD_LOGIC_VECTOR (5 downto 0);
               RegDst, ExtOp, ALUSrc, Branch, BranchNotEq, Jump,
               MemWrite, MemtoReg, RegWrite : out STD_LOGIC;
               ALUOp : out STD_LOGIC_VECTOR (1 downto 0));   -- 2 bits
    end component;

    component EX is
        Port ( PCplus4 : in STD_LOGIC_VECTOR (31 downto 0);
               RD1, RD2, Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
               func : in STD_LOGIC_VECTOR (5 downto 0);
               sa : in STD_LOGIC_VECTOR (4 downto 0);
               ALUSrc : in STD_LOGIC;
               ALUOp : in STD_LOGIC_VECTOR (1 downto 0);     -- 2 bits
               rt, rd : in STD_LOGIC_VECTOR (4 downto 0);
               RegDst : in STD_LOGIC;
               BranchAddress, ALURes : out STD_LOGIC_VECTOR (31 downto 0);
               Zero : out STD_LOGIC;
               WriteAddress : out STD_LOGIC_VECTOR (4 downto 0));
    end component;

    component MEM is
        Port ( clk, en : in STD_LOGIC;
               ALUResIn, RD2 : in STD_LOGIC_VECTOR (31 downto 0);
               MemWrite : in STD_LOGIC;
               MemData, ALUResOut : out STD_LOGIC_VECTOR (31 downto 0));
    end component;

    -- global signals
    signal en, rst : std_logic;
    signal digits : std_logic_vector(31 downto 0);
    signal WriteBackData : std_logic_vector(31 downto 0);
    signal PCSrc_Signal : std_logic;
    signal JumpAddress_Signal : std_logic_vector(31 downto 0);

    -- IF stage
    signal IF_Instr, IF_PCplus4 : std_logic_vector(31 downto 0);
    -- ID stage
    signal ID_RD1, ID_RD2, ID_ExtImm : std_logic_vector(31 downto 0);
    signal ID_func : std_logic_vector(5 downto 0);
    signal ID_sa, ID_rt, ID_rd : std_logic_vector(4 downto 0);
    -- UC outputs
    signal UC_RegDst, UC_ExtOp, UC_ALUSrc, UC_Branch, UC_BranchNotEq,
           UC_Jump, UC_MemWrite, UC_MemtoReg, UC_RegWrite : std_logic;
    signal UC_ALUOp : std_logic_vector(1 downto 0);
    -- EX outputs
    signal EX_BranchAddr, EX_ALURes : std_logic_vector(31 downto 0);
    signal EX_Zero : std_logic;
    signal EX_WriteAddr : std_logic_vector(4 downto 0);
    -- MEM outputs
    signal MEM_Data, MEM_ALUResOut : std_logic_vector(31 downto 0);

    -- pipeline registers
    signal IF_ID_PCplus4, IF_ID_Instr : std_logic_vector(31 downto 0);
    signal ID_EX_PCplus4, ID_EX_RD1, ID_EX_RD2, ID_EX_ExtImm : std_logic_vector(31 downto 0);
    signal ID_EX_func : std_logic_vector(5 downto 0);
    signal ID_EX_sa, ID_EX_rt, ID_EX_rd : std_logic_vector(4 downto 0);
    signal ID_EX_RegDst, ID_EX_ALUSrc, ID_EX_Branch, ID_EX_BranchNotEq,
           ID_EX_MemWrite, ID_EX_MemtoReg, ID_EX_RegWrite : std_logic;
    signal ID_EX_ALUOp : std_logic_vector(1 downto 0);   -- 2 bits

    signal EX_MEM_BranchAddr, EX_MEM_ALURes, EX_MEM_RD2 : std_logic_vector(31 downto 0);
    signal EX_MEM_WriteAddr : std_logic_vector(4 downto 0);
    signal EX_MEM_Zero, EX_MEM_Branch, EX_MEM_BranchNotEq,
           EX_MEM_MemWrite, EX_MEM_MemtoReg, EX_MEM_RegWrite : std_logic;

    signal MEM_WB_MemData, MEM_WB_ALURes : std_logic_vector(31 downto 0);
    signal MEM_WB_WriteAddr : std_logic_vector(4 downto 0);
    signal MEM_WB_MemtoReg, MEM_WB_RegWrite : std_logic;

begin
    -- MPG and reset
    monopulse_inst: MPG port map(en, btn(0), clk);
    rst <= btn(1);

    -- IFetch
    inst_IFetch: IFetch port map(
        clk => clk, rst => rst, en => en,
        BranchAddress => EX_MEM_BranchAddr,
        JumpAddress => JumpAddress_Signal,
        Jump => UC_Jump,
        PCSrc => PCSrc_Signal,
        Instruction => IF_Instr,
        PCplus4 => IF_PCplus4
    );

    -- Control unit
    inst_UC: UC port map(
        Instr => IF_ID_Instr(31 downto 26),
        RegDst => UC_RegDst, ExtOp => UC_ExtOp, ALUSrc => UC_ALUSrc,
        Branch => UC_Branch, BranchNotEq => UC_BranchNotEq, Jump => UC_Jump,
        ALUOp => UC_ALUOp, MemWrite => UC_MemWrite,
        MemtoReg => UC_MemtoReg, RegWrite => UC_RegWrite
    );

    -- Decode
    inst_IDecode: IDecode port map(
        clk => clk, en => en,
        Instr => IF_ID_Instr(25 downto 0),
        WD => WriteBackData,
        RegWrite => MEM_WB_RegWrite,
        WA => MEM_WB_WriteAddr,
        ExtOp => UC_ExtOp,
        RD1 => ID_RD1, RD2 => ID_RD2, Ext_Imm => ID_ExtImm,
        func => ID_func, sa => ID_sa, rt => ID_rt, rd => ID_rd
    );

    -- Execute
    inst_EX: EX port map(
        PCplus4 => ID_EX_PCplus4,
        RD1 => ID_EX_RD1, RD2 => ID_EX_RD2, Ext_Imm => ID_EX_ExtImm,
        func => ID_EX_func, sa => ID_EX_sa,
        ALUSrc => ID_EX_ALUSrc, ALUOp => ID_EX_ALUOp,
        rt => ID_EX_rt, rd => ID_EX_rd, RegDst => ID_EX_RegDst,
        BranchAddress => EX_BranchAddr, ALURes => EX_ALURes,
        Zero => EX_Zero, WriteAddress => EX_WriteAddr
    );

    -- Memory
    inst_MEM: MEM port map(
        clk => clk, en => en,
        ALUResIn => EX_MEM_ALURes, RD2 => EX_MEM_RD2,
        MemWrite => EX_MEM_MemWrite,
        MemData => MEM_Data, ALUResOut => MEM_ALUResOut
    );

    -- jump address
    JumpAddress_Signal <= IF_ID_PCplus4(31 downto 28) & IF_ID_Instr(25 downto 0) & "00";
    -- branch decision (BEQ and BNE)
    PCSrc_Signal <= (EX_MEM_Branch and EX_MEM_Zero) or (EX_MEM_BranchNotEq and not EX_MEM_Zero);
    -- write-back mux
    WriteBackData <= MEM_WB_MemData when MEM_WB_MemtoReg = '1' else MEM_WB_ALURes;

    -- pipeline registers update
    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                -- IF/ID
                IF_ID_PCplus4 <= IF_PCplus4;
                IF_ID_Instr   <= IF_Instr;

                -- ID/EX
                ID_EX_PCplus4 <= IF_ID_PCplus4;
                ID_EX_RD1 <= ID_RD1;
                ID_EX_RD2 <= ID_RD2;
                ID_EX_ExtImm <= ID_ExtImm;
                ID_EX_func <= ID_func;
                ID_EX_sa <= ID_sa;
                ID_EX_rt <= ID_rt;
                ID_EX_rd <= ID_rd;
                ID_EX_RegDst <= UC_RegDst;
                ID_EX_ALUSrc <= UC_ALUSrc;
                ID_EX_ALUOp  <= UC_ALUOp;      -- 2 bits
                ID_EX_Branch <= UC_Branch;
                ID_EX_BranchNotEq <= UC_BranchNotEq;
                ID_EX_MemWrite <= UC_MemWrite;
                ID_EX_MemtoReg <= UC_MemtoReg;
                ID_EX_RegWrite <= UC_RegWrite;

                -- EX/MEM
                EX_MEM_BranchAddr <= EX_BranchAddr;
                EX_MEM_ALURes <= EX_ALURes;
                EX_MEM_RD2 <= ID_EX_RD2;
                EX_MEM_WriteAddr <= EX_WriteAddr;
                EX_MEM_Zero <= EX_Zero;
                EX_MEM_Branch <= ID_EX_Branch;
                EX_MEM_BranchNotEq <= ID_EX_BranchNotEq;
                EX_MEM_MemWrite <= ID_EX_MemWrite;
                EX_MEM_MemtoReg <= ID_EX_MemtoReg;
                EX_MEM_RegWrite <= ID_EX_RegWrite;

                -- MEM/WB
                MEM_WB_MemData <= MEM_Data;
                MEM_WB_ALURes <= MEM_ALUResOut;
                MEM_WB_WriteAddr <= EX_MEM_WriteAddr;
                MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
                MEM_WB_RegWrite <= EX_MEM_RegWrite;
            end if;
        end if;
    end process;

    -- display multiplexer
    process(sw(7 downto 5), IF_Instr, IF_PCplus4, ID_RD1, ID_RD2, ID_ExtImm, EX_ALURes, MEM_Data, WriteBackData)
    begin
        case sw(7 downto 5) is
            when "000" => digits <= IF_Instr;
            when "001" => digits <= IF_PCplus4;
            when "010" => digits <= ID_RD1;
            when "011" => digits <= ID_RD2;
            when "100" => digits <= ID_ExtImm;
            when "101" => digits <= EX_ALURes;
            when "110" => digits <= MEM_Data;
            when "111" => digits <= WriteBackData;
            when others => digits <= (others => '0');
        end case;
    end process;

    -- SSD instance - note port name 'digits'
    inst_SSD: SSD port map(digits => digits, clk => clk, cat => cat, an => an);

    -- debug LEDs
    led(0) <= UC_RegDst;
    led(1) <= UC_ExtOp;
    led(2) <= UC_ALUSrc;
    led(3) <= UC_Branch;
    led(4) <= UC_Jump;
    led(5) <= UC_MemWrite;
    led(6) <= UC_MemtoReg;
    led(7) <= UC_RegWrite;
    led(9 downto 8) <= UC_ALUOp;
    led(10) <= PCSrc_Signal;
    led(15 downto 11) <= (others => '0');
end Behavioral;