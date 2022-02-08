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
    
    type T_QUOTIENT_SR is ARRAY(NATURAL range <>) of INTEGER range 0 to 10**G_NB_DIGITS-1;
    
    signal remain   : T_DIGITS_ARRAY(G_NB_DIGITS-1 downto 0) := (others => 0);
    signal quotient : T_QUOTIENT_SR(G_NB_DIGITS-1 downto 0) := (others => 0);
    
begin
    
    o_digits <= remain;
    
    div_by_ten_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            quotient(0) <= i_integer;
            
            for i in 0 to G_NB_DIGITS-1 loop
                
                if i > 0 and quotient(i) = 0 then
                    remain(i) <= -1;
                else
                    remain(i) <= quotient(i) mod 10;
                    if i < G_NB_DIGITS-1 then
                        quotient(i+1) <= (quotient(i)-remain(i)) / 10;
                    end if;
                end if;
                
            end loop;
            
        end if;
    end process;
    
end Behavioral;
