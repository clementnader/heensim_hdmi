----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2021 07:49:23 PM
-- Design Name: 
-- Module Name: hdmi_output_zc706 - Behavioral
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


entity hdmi_output_zc706 is
    port (
        i_clk   : in STD_LOGIC;
        i_r     : in STD_LOGIC_VECTOR(7 downto 0);
        i_g     : in STD_LOGIC_VECTOR(7 downto 0);
        i_b     : in STD_LOGIC_VECTOR(7 downto 0);
        i_de    : in STD_LOGIC;
        i_hsync : in STD_LOGIC;
        i_vsync : in STD_LOGIC;
        
        o_hdmi_clk   : out STD_LOGIC;
        o_hdmi_d     : out STD_LOGIC_VECTOR(35 downto 0);
        o_hdmi_de    : out STD_LOGIC;
        o_hdmi_hsync : out STD_LOGIC;
        o_hdmi_vsync : out STD_LOGIC
    );
end hdmi_output_zc706;


architecture Behavioral of hdmi_output_zc706 is
    
begin
    
    o_hdmi_clk <= i_clk;
    
    -----------------------------------------------------------------------------------
    
    latch_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_hdmi_vsync <= i_vsync;
            o_hdmi_hsync <= i_hsync;
            o_hdmi_de    <= i_de;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    hdmi_data_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_hdmi_d(35 downto 28) <= i_r;
            o_hdmi_d(23 downto 16) <= i_g;
            o_hdmi_d(11 downto  4) <= i_b;
            
        end if;
    end process;
    
end Behavioral;
