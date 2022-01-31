----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2021 03:05:22 PM
-- Design Name: 
-- Module Name: clock_divider - Behavioral
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
    use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity clock_divider is
    generic (
        G_NB_BITS_CLK_DIV : INTEGER
    );
    port (
        i_clk : in STD_LOGIC;
        
        o_div_clk : out STD_LOGIC
    );
end clock_divider;


architecture Behavioral of clock_divider is
    
    signal div_cnt : STD_LOGIC_VECTOR(G_NB_BITS_CLK_DIV-1 downto 0) := (others => '0');
    
begin
    
    div_clk_process : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            div_cnt <= div_cnt + 1;
            
            if div_cnt = '1' & (div_cnt'high-1 downto 0 => '0') then
                o_div_clk <= '0';
            elsif div_cnt = (div_cnt'range => '0') then
                o_div_clk <= '1';
            end if;
            
        end if;
    end process;
    
end Behavioral;
