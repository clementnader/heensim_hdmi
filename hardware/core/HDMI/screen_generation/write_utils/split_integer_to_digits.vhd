----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/25/2021 11:23:24 AM
-- Design Name: 
-- Module Name: split_integer_to_digits - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library work;
    use work.character_definition_pkg.ALL;


entity split_integer_to_digits is
    generic (
       G_NB_DIGITS : INTEGER
    );
    port (
        i_clk     : in STD_LOGIC;
        i_integer : in INTEGER range 0 to 10**G_NB_DIGITS-1;
        
        o_digits : out T_DIGITS_ARRAY(G_NB_DIGITS-1 downto 0)
    );
end split_integer_to_digits;


architecture Behavioral of split_integer_to_digits is
    
begin
    
    div_by_ten_proc : process(i_clk)
        
        variable remain   : INTEGER range 0 to 9;
        variable quotient : INTEGER range 0 to 10**G_NB_DIGITS-1;
        
    begin
        if rising_edge(i_clk) then
            
            quotient := i_integer;
            
            for i in 0 to G_NB_DIGITS-1 loop
                
                if i > 0 and quotient = 0 then
                    o_digits(i) <= -1;
                else
                    remain   := quotient mod 10;
                    quotient := (quotient-remain) / 10;
                    o_digits(i) <= remain;
                end if;
                
            end loop;
            
        end if;
    end process;
    
end Behavioral;
