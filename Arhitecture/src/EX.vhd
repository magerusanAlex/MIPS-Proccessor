library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL; 

entity EX is
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
end EX;

architecture Behavioral of EX is

    signal ALUCtrl : STD_LOGIC_VECTOR(2 downto 0);
    signal A, B    : STD_LOGIC_VECTOR(31 downto 0);
    signal ALU_Out : STD_LOGIC_VECTOR(31 downto 0);

begin

    BranchAddress <= PC_plus_4 + (Ext_Imm(29 downto 0) & "00");

    -- MUX ALUSrc
    A <= RD1;
    B <= Ext_Imm when ALUSrc = '1' else RD2;

    -- ALU Control
    process(ALUOp, func)
    begin
        case ALUOp is
            when "00" => -- addi, lw, sw
                ALUCtrl <= "000"; -- add
            when "01" => -- beq, bne
                ALUCtrl <= "001"; -- sub
            when "10" => -- tip R
                case func is
                    when "100000" => ALUCtrl <= "000"; -- add
                    when "100100" => ALUCtrl <= "010"; -- and
                    when "101010" => ALUCtrl <= "011"; -- slt
                    when "000000" => ALUCtrl <= "100"; -- sll
                    when others   => ALUCtrl <= "000";
                end case;
            when others => ALUCtrl <= "000";
        end case;
    end process;

    -- Unitatea ALU
    process(A, B, ALUCtrl, sa)
    begin
        case ALUCtrl is
            when "000" => -- add
                ALU_Out <= A + B;
            when "001" => -- sub
                ALU_Out <= A - B;
            when "010" => -- and
                ALU_Out <= A and B;
            when "011" => -- slt
                if signed(A) < signed(B) then
                    ALU_Out <= x"00000001";
                else
                    ALU_Out <= x"00000000";
                end if;
            when "100" => -- sll
                ALU_Out <= to_stdlogicvector(to_bitvector(B) sll conv_integer(sa));
            when others => 
                ALU_Out <= (others => '0');
        end case;
    end process;

    ALURes <= ALU_Out;
    Zero <= '1' when ALU_Out = x"00000000" else '0';

end Behavioral;