----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2021 11:20:46 AM
-- Design Name: 
-- Module Name: hdmi_output_zedboard - Behavioral
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


entity hdmi_output_zedboard is
    port (
        i_clk   : in STD_LOGIC;
        i_y     : in STD_LOGIC_VECTOR(7 downto 0);
        i_cb    : in STD_LOGIC_VECTOR(7 downto 0);
        i_cr    : in STD_LOGIC_VECTOR(7 downto 0);
        i_de    : in STD_LOGIC;
        i_hsync : in STD_LOGIC;
        i_vsync : in STD_LOGIC;
        
        o_hdmi_clk   : out STD_LOGIC;
        o_hdmi_d     : out STD_LOGIC_VECTOR(35 downto 0);
        o_hdmi_de    : out STD_LOGIC;
        o_hdmi_hsync : out STD_LOGIC;
        o_hdmi_vsync : out STD_LOGIC
    );
end hdmi_output_zedboard;


architecture Behavioral of hdmi_output_zedboard is
    
    signal cb_or_cr : STD_LOGIC;
    
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
    
    cb_or_cr_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_de = '0' then
                cb_or_cr <= '0';
            else
                cb_or_cr <= not(cb_or_cr);
            end if;
            
        end if;
    end process;
    
    hdmi_data_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_hdmi_d(23 downto 16) <= i_y;
            
            if cb_or_cr = '0' then
                o_hdmi_d(15 downto 8) <= i_cb;
            else
                o_hdmi_d(15 downto 8) <= i_cr;
            end if;
            
        end if;
    end process;
    
end Behavioral;
