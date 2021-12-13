----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/08/2021 04:43:39 PM
-- Design Name: 
-- Module Name: color_gen - Behavioral
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


entity color_gen is
    port (
        i_clk      : in STD_LOGIC;
        i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
        
        o_hcounter : out STD_LOGIC_VECTOR(11 downto 0);
        o_vcounter : out STD_LOGIC_VECTOR(11 downto 0);
        o_color    : out STD_LOGIC_VECTOR(23 downto 0)
    );
end color_gen;

architecture Behavioral of color_gen is
    
    -- Definition of the colors
    constant C_BLACK   : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    constant C_RED     : STD_LOGIC_VECTOR(23 downto 0) := x"FF0000";
    constant C_YELLOW  : STD_LOGIC_VECTOR(23 downto 0) := x"FFFF00";
    constant C_GREEN   : STD_LOGIC_VECTOR(23 downto 0) := x"00FF00";
    constant C_CYAN    : STD_LOGIC_VECTOR(23 downto 0) := x"00FFFF";
    constant C_BLUE    : STD_LOGIC_VECTOR(23 downto 0) := x"0000FF";
    constant C_MAGENTA : STD_LOGIC_VECTOR(23 downto 0) := x"FF00FF";
    constant C_WHITE   : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
    
begin
    
    color_proc: process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_hcounter <= i_hcounter;
            o_vcounter <= i_vcounter;
            o_color <= C_BLACK;
            
            if i_hcounter < 256 then
                o_color <= C_RED;
            elsif i_hcounter < 512 then
                o_color <= C_YELLOW;
            elsif i_hcounter < 768 then
                o_color <= C_GREEN;
            elsif i_hcounter < 1024 then
                o_color <= C_CYAN;
            elsif i_hcounter < 1280 then
                o_color <= C_BLUE;
            elsif i_hcounter < 1536 then
                o_color <= C_MAGENTA;
            else
                o_color <= C_WHITE;
            end if;
            
--            o_color(23 downto 16) <= i_hcounter(7 downto 0);
--            o_color(15 downto  8) <= i_vcounter(7 downto 0);
--            o_color( 7 downto  0) <= i_hcounter(7 downto 0) + i_vcounter(7 downto 0);
            
        end if;
    end process;

end Behavioral;
