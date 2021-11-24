----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/03/2021 04:48:01 PM
-- Design Name: 
-- Module Name: position_counters - Behavioral
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
    use work.hdmi_resolution_pkg.ALL;


entity position_counters is
    port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        
        o_hcounter : out STD_LOGIC_VECTOR(11 downto 0);
        o_vcounter : out STD_LOGIC_VECTOR(11 downto 0)
    );
end position_counters;


architecture Behavioral of position_counters is
    
    signal hcounter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal vcounter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    
begin
    
    o_hcounter <= hcounter;
    o_vcounter <= vcounter;
    
    clk_process: process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_rst = '1' then
                hcounter <= (others => '0');
                vcounter <= (others => '0');
            else
                -- Advance the position counters
                if hcounter < C_H_MAX then
                    hcounter <= hcounter + 1;
                else
                    -- starting a new line
                    hcounter <= (others => '0');
                    if vcounter < C_V_MAX then
                        vcounter <= vcounter + 1;
                    else
                        -- starting a new screen
                        vcounter <= (others => '0');
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
end Behavioral;
