----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 05:53:15 PM
-- Package Name: plot_pkg
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
    use work.neurons_pkg.ALL;


package plot_pkg is
    
    -- Definition of the colors
    constant C_BLACK   : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    constant C_GREY    : STD_LOGIC_VECTOR(23 downto 0) := x"222222";
    constant C_RED     : STD_LOGIC_VECTOR(23 downto 0) := x"FF0000";
    constant C_ORANGE  : STD_LOGIC_VECTOR(23 downto 0) := x"CC8800";
    constant C_YELLOW  : STD_LOGIC_VECTOR(23 downto 0) := x"FFFF00";
    constant C_GREEN   : STD_LOGIC_VECTOR(23 downto 0) := x"00FF00";
    constant C_CYAN    : STD_LOGIC_VECTOR(23 downto 0) := x"00FFFF";
    constant C_BLUE    : STD_LOGIC_VECTOR(23 downto 0) := x"0000FF";
    constant C_MAGENTA : STD_LOGIC_VECTOR(23 downto 0) := x"FF00FF";
    constant C_WHITE   : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
    
    -----------------------------------------------------------------------------------
    
    constant C_NB_H_POINTS : INTEGER := 1024;
    
    constant C_NB_V_POINTS : INTEGER := C_RANGE_ID_SMALL_PLOT;
    
    ------------------------------------------
    
    -- Definition of the horizontal limits of the plot
    constant C_H_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := ('0'&C_H_VISIBLE(11 downto 1)) - C_NB_H_POINTS/2; -- (C_H_VISIBLE-C_NB_H_POINTS)/2
    constant C_H_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT + C_NB_H_POINTS;
    -- the vertical axis is reversed with the zero being at the top
    constant C_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := x"028";
    constant C_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_V_UP_LIMIT + C_NB_V_POINTS;
    
    ------------------------------------------
    
    -- Draw ticks on the horizontal axis
    constant C_RANGE_HCNT1 : INTEGER := 25;  -- horizontal tick every 25 timestamps
    constant C_RANGE_HCNT2 : INTEGER := 4;   -- horizontal tick every 100 timestamps
    constant C_RANGE_HCNT3 : INTEGER := 5;   -- horizontal tick every 500 timestamps
    
    -- Draw ticks on the vertical axis
    constant C_RANGE_VCNT1 : INTEGER := 10;  -- vertical tick every 10 neurons
    constant C_RANGE_VCNT2 : INTEGER := 5;   -- vertical tick every 50 neurons
    constant C_RANGE_VCNT3 : INTEGER := 2;   -- vertical tick every 100 neurons
    
    constant C_VCNT1_UP_LIMIT : INTEGER := C_NB_V_POINTS mod C_RANGE_VCNT1;
    constant C_VCNT_Q1        : INTEGER := (C_NB_V_POINTS-C_VCNT1_UP_LIMIT) / C_RANGE_VCNT1;
    constant C_VCNT2_UP_LIMIT : INTEGER := C_VCNT_Q1 mod C_RANGE_VCNT2;
    constant C_VCNT_Q2        : INTEGER := (C_VCNT_Q1-C_VCNT2_UP_LIMIT) / C_RANGE_VCNT2;
    constant C_VCNT3_UP_LIMIT : INTEGER := C_VCNT_Q2 mod C_RANGE_VCNT3;
    
    ------------------------------------------
    
    constant C_TICK_LABEL_MOD : INTEGER := (C_NB_V_POINTS-1) mod 50;
    constant C_NB_TICK_LABEL  : INTEGER := (C_NB_V_POINTS-1-C_TICK_LABEL_MOD) / 50 + 1;
    
end package;


package body plot_pkg is
    
end package body;
