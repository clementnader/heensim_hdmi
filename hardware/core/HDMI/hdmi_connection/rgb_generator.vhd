----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/02/2021 12:23:44 PM
-- Design Name: 
-- Module Name: rgb_generator - Behavioral
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


entity rgb_generator is
    port (
        i_clk      : in STD_LOGIC;
        i_color    : in STD_LOGIC_VECTOR(23 downto 0);
        i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
        
        o_r     : out STD_LOGIC_VECTOR(7 downto 0);
        o_g     : out STD_LOGIC_VECTOR(7 downto 0);
        o_b     : out STD_LOGIC_VECTOR(7 downto 0);
        o_de    : out STD_LOGIC;
        o_hsync : out STD_LOGIC;
        o_vsync : out STD_LOGIC
    );
end rgb_generator;


architecture Behavioral of rgb_generator is
    
begin
    
    generate_rgb_de_syncs_signals_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then 
            
            -- Generate the rgb and de signals
            if i_hcounter < C_H_VISIBLE and i_vcounter < C_V_VISIBLE then 
                o_r  <= i_color(23 downto 16);
                o_g  <= i_color(15 downto  8);
                o_b  <= i_color( 7 downto  0);
                o_de <= '1';
            else
                o_r  <= (others => '0');
                o_g  <= (others => '0');
                o_b  <= (others => '0');
                o_de <= '0';
            end if;
            
            -- Generate the sync pulses
            if i_hcounter = C_H_START_SYNC then 
                o_hsync <= C_H_SYNC_ACTIVE;
            elsif i_hcounter = C_H_END_SYNC then
                o_hsync <= not(C_H_SYNC_ACTIVE);
            end if;
            
            if i_vcounter = C_V_START_SYNC then 
                o_vsync <= C_V_SYNC_ACTIVE;
            elsif i_vcounter = C_V_END_SYNC then
                o_vsync <= not(C_V_SYNC_ACTIVE);
            end if;
            
        end if;
    end process;
    
end Behavioral;
