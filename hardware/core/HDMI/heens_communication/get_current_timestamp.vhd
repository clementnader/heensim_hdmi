----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/27/2021 06:48:05 PM
-- Design Name: 
-- Module Name: get_current_timestamp - Behavioral
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

library work;
    use work.neurons_pkg.ALL;


entity get_current_timestamp is
    port ( 
        i_clk     : in STD_LOGIC;
        i_rst     : in STD_LOGIC;
        i_ph_dist : in STD_LOGIC;
        
        o_current_timestamp : out STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0)
    );
end get_current_timestamp;


architecture Behavioral of get_current_timestamp is
    
    signal current_timestamp : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0) := (others => '0');
    
    signal last_ph_dist : STD_LOGIC;
    
begin
    
    o_current_timestamp <= current_timestamp;
    
    increment_timestamp_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            last_ph_dist <= i_ph_dist;
            
            if i_rst = '1' then
                current_timestamp <= (others => '0');
            else
                if last_ph_dist = '1' and i_ph_dist = '0' then  -- falling edge
                    current_timestamp <= current_timestamp + 1;
                end if;
            end if;
            
        end if;
    end process;
    
end Behavioral;
