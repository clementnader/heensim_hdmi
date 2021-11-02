----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/26/2021 10:17:10 AM
-- Design Name: 
-- Module Name: stabilize_input - Behavioral
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


entity stabilize_input is
    port (
        i_clk : in STD_LOGIC;
        i_in  : in STD_LOGIC;
        
        o_out : out STD_LOGIC
    );
end stabilize_input;


architecture Behavioral of stabilize_input is
    
    signal shft_reg : STD_LOGIC_VECTOR(7 downto 0);
    
begin
    
    shift_register : process(i_clk)
    begin
        if rising_edge(i_clk) then
            shft_reg <= shft_reg(shft_reg'high-1 downto 0) & i_in;
            if shft_reg = (shft_reg'high downto 0 => '1') then
                o_out <= '1';
            elsif shft_reg = (shft_reg'high downto 0 => '0') then
                o_out <= '0';
            end if;
        end if;
    end process;
    
end Behavioral;
