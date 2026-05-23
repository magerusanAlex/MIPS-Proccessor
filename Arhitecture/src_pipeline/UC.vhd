library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity UC is
    Port ( Instr : in  STD_LOGIC_VECTOR (5 downto 0);
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
end UC;

architecture Behavioral of UC is
begin
    process(Instr)
    begin
        RegDst <= '0'; ExtOp <= '0'; ALUSrc <= '0';
        Branch <= '0'; BranchNotEq <= '0'; Jump <= '0';
        MemWrite <= '0'; MemtoReg <= '0'; RegWrite <= '0';
        ALUOp <= "00";

        case Instr is
            when "000000" => -- Tip R 
                RegDst <= '1';
                RegWrite <= '1';
                ALUOp <= "10";
                
            when "001000" => -- addi
                ExtOp <= '1';
                ALUSrc <= '1';
                RegWrite <= '1';
                ALUOp <= "00";
                
            when "100011" => -- lw
                ExtOp <= '1';
                ALUSrc <= '1';
                MemtoReg <= '1';
                RegWrite <= '1';
                ALUOp <= "00";
                
            when "101011" => -- sw
                ExtOp <= '1';
                ALUSrc <= '1';
                MemWrite <= '1';
                ALUOp <= "00";
                
            when "000100" => -- beq
                ExtOp <= '1';
                Branch <= '1';
                ALUOp <= "01";
                
            when "000101" => -- bne
                ExtOp <= '1';
                BranchNotEq <= '1';
                ALUOp <= "01";
                
            when "000010" => -- j
                Jump <= '1';
                
            when others => 
                -- Pentru instructiuni necunoscute, pastram valorile de mai sus (0)
        end case;
    end process;
end Behavioral;