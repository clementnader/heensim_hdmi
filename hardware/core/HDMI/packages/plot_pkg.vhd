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
    use work.character_definition_pkg.ALL;


package plot_pkg is
    
    -- Definition of the colors
    constant C_BLACK   : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    constant C_GREY    : STD_LOGIC_VECTOR(23 downto 0) := x"222222";
    constant C_RED     : STD_LOGIC_VECTOR(23 downto 0) := x"CC0000";
    constant C_ORANGE  : STD_LOGIC_VECTOR(23 downto 0) := x"CC8800";
    constant C_YELLOW  : STD_LOGIC_VECTOR(23 downto 0) := x"CCCC00";
    constant C_GREEN   : STD_LOGIC_VECTOR(23 downto 0) := x"00AA00";
    constant C_CYAN    : STD_LOGIC_VECTOR(23 downto 0) := x"00FFFF";
    constant C_BLUE    : STD_LOGIC_VECTOR(23 downto 0) := x"0000FF";
    constant C_MAGENTA : STD_LOGIC_VECTOR(23 downto 0) := x"FF00FF";
    constant C_WHITE   : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
    
    -----------------------------------------------------------------------------------
    
    constant C_NB_H_POINTS : INTEGER := 1024;  -- 1024 timestamps
    
    -----------------------------------------------------------------------------------
    
    -- Definition of the horizontal limits of the plot
    constant C_H_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := ('0'&C_H_VISIBLE(11 downto 1)) - C_NB_H_POINTS/2; -- (C_H_VISIBLE-C_NB_H_POINTS)/2
    constant C_H_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT + C_NB_H_POINTS;
    
    constant C_OFFSET : STD_LOGIC_VECTOR(11 downto 0) := x"025";
    
    -----------------------------------------------------------------------------------
    
    -- Draw ticks on the horizontal axis
    constant C_RANGE_HCNT1 : INTEGER := 25;  -- horizontal tick every 25 timestamps
    constant C_RANGE_HCNT2 : INTEGER := 4;   -- horizontal tick every 100 timestamps
    constant C_RANGE_HCNT3 : INTEGER := 5;   -- horizontal tick every 500 timestamps
    
    -----------------------------------------------------------------------------------
    
    type T_BOOLEAN_ARRAY is ARRAY(NATURAL range <>) of BOOLEAN;
    
    type T_LABEL_POS     is ARRAY(NATURAL range <>) of STD_LOGIC_VECTOR(11 downto 0);
    type T_STRING_ARRAY  is ARRAY(NATURAL range <>) of STRING;
    type T_INTEGER_ARRAY is ARRAY(NATURAL range <>) of INTEGER;
    
    -----------------------------------------------------------------------------------
    
    -- Ticks label on horizontal axis
    constant C_H_TICK_NAME : T_STRING_ARRAY := ("   0", " 100", " 200",
        " 300", " 400", " 500", " 600", " 700", " 800", " 900", "1000");
    
    constant C_H_TICK_HPOS : T_LABEL_POS(0 to 10) := (
         0 => C_H_LOW_LIMIT +    0 - C_FONT_WIDTH*3 - C_FONT_WIDTH/2*1,  --    0
         1 => C_H_LOW_LIMIT +  100 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  100
         2 => C_H_LOW_LIMIT +  200 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  200
         3 => C_H_LOW_LIMIT +  300 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  300
         4 => C_H_LOW_LIMIT +  400 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  400
         5 => C_H_LOW_LIMIT +  500 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  500
         6 => C_H_LOW_LIMIT +  600 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  600
         7 => C_H_LOW_LIMIT +  700 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  700
         8 => C_H_LOW_LIMIT +  800 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  800
         9 => C_H_LOW_LIMIT +  900 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3,  --  900
        10 => C_H_LOW_LIMIT + 1000 - C_FONT_WIDTH*0 - C_FONT_WIDTH/2*4   -- 1000
    );
    
    -- Horizontal axis label
    constant C_H_LABEL : STRING := "time (ms)";
    
    constant C_H_MIDDLE_PLOT : STD_LOGIC_VECTOR(11 downto 0)
        := C_H_LOW_LIMIT + ('0'&(C_H_UP_LIMIT(11 downto 1)-C_H_LOW_LIMIT(11 downto 1)));
    
    -----------------------------------------------------------------------------------
    
    -- Analog Plot
    type T_COLORS_ARRAY is ARRAY(0 to C_NB_NEURONS_ANALOG-1) of STD_LOGIC_VECTOR(23 downto 0);
    
    constant C_ANALOG_PLOT_COLORS : T_COLORS_ARRAY := (
        0 => C_BLUE,
        1 => C_RED,
        2 => C_GREEN,
        3 => C_ORANGE
    );
    
end package;


package body plot_pkg is
    
end package body;
