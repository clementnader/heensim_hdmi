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
    
    component stabilize_input
        port (
            i_clk : in STD_LOGIC;
            i_in  : in STD_LOGIC;
            
            o_out : out STD_LOGIC
        );
    end component;
    
begin
    
    stabilize_input_gen :
    for i in 0 to G_NB_INPUTS-1 generate
        stabilize_input_inst : stabilize_input
        port map (
            i_clk => i_clk,
            i_in  => i_in(i),
            
            o_out => o_out(i)
        );
    end generate;
    
end Behavioral;
