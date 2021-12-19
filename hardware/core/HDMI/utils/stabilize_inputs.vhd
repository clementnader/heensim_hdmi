----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2021 05:09:05 PM
-- Design Name: 
-- Module Name: stabilize_inputs - Behavioral
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


entity stabilize_inputs is
    generic (
        G_NB_INPUTS : INTEGER := 1
    );
    port (
        i_clk : in STD_LOGIC;
        i_in  : in STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
        
        o_out : out STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0)
    );
end stabilize_inputs;


architecture Behavioral of stabilize_inputs is
    
    component clock_divider
        generic (
            G_NB_BITS_CLK_DIV : INTEGER
        );
        port (
            i_clk : in STD_LOGIC;
            
            o_div_clk : out STD_LOGIC
        );
    end component;
    
    signal div_clk : STD_LOGIC;
    
begin
    
    clock_divider_inst : clock_divider
        generic map (
            G_NB_BITS_CLK_DIV => 21
        )
        port map (
            i_clk => i_clk,
            
            o_div_clk => div_clk
        );
    
    stabilize_inputs : process(div_clk)
    begin
        if rising_edge(div_clk) then
            
            o_out <= i_in;
            
        end if;
    end process;
    
end Behavioral;
