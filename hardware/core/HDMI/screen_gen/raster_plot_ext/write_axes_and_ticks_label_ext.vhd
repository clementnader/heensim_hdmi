----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/19/2021 03:52:23 PM
-- Design Name: 
-- Module Name: write_axes_and_ticks_label_ext - Behavioral
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
    use work.character_definition_pkg.ALL;
    use work.plot_pkg.ALL;


entity write_axes_and_ticks_label_ext is
    generic (
        G_NB_V_POINTS : INTEGER;
        G_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0);
        G_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0)
    );
    port (
        i_clk      : in STD_LOGIC;
        i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
        
        o_axes_label_pixel  : out BOOLEAN;
        o_ticks_label_pixel : out BOOLEAN
    );
end write_axes_and_ticks_label_ext;


architecture Behavioral of write_axes_and_ticks_label_ext is
    
    component write_text
        generic (
           G_TEXT_LENGTH : INTEGER
        );
        port (
            i_clk          : in STD_LOGIC;
            i_do_display   : in BOOLEAN;
            i_display_text : in STRING(1 to G_TEXT_LENGTH);
            i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_pixel : out BOOLEAN
        );
    end component;
    
    component write_text_rotated
        generic (
           G_TEXT_LENGTH : INTEGER
        );
        port (
            i_clk          : in STD_LOGIC;
            i_do_display   : in BOOLEAN;
            i_display_text : in STRING(1 to G_TEXT_LENGTH);
            i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_pixel : out BOOLEAN
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    type T_LABEL_POS     is ARRAY(NATURAL range <>) of STD_LOGIC_VECTOR(11 downto 0);
    type T_STRING_ARRAY  is ARRAY(NATURAL range <>) of STRING;
    type T_INTEGER_ARRAY is ARRAY(NATURAL range <>) of INTEGER;
    type T_BOOLEAN_ARRAY is ARRAY(NATURAL range <>) of BOOLEAN;
    
    -----------------------------------------------------------------------------------
    
    constant C_TICK_LABEL_MOD : INTEGER := (G_NB_V_POINTS-1) mod 50;
    constant C_NB_TICK_LABEL  : INTEGER := (G_NB_V_POINTS-1-C_TICK_LABEL_MOD) / 50 + 1;
    
    -----------------------------------------------------------------------------------
    
    constant C_V_LOW_LIMIT_EXT : STD_LOGIC_VECTOR(11 downto 0) := G_V_UP_LIMIT + 4*G_NB_V_POINTS;
    
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
    constant C_H_TICK_VPOS : STD_LOGIC_VECTOR(11 downto 0) := C_V_LOW_LIMIT_EXT + 13;
    
    signal h_ticks_pixel : T_BOOLEAN_ARRAY(0 to 10);
    
    -----------------------------------------------------------------------------------
    
    -- Ticks label on vertical axis
    constant C_V_TICK_NAME : T_STRING_ARRAY := ("  0", " 50", "100", "150");
    
    constant C_V_TICK_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT - 14 - 3*C_FONT_WIDTH;
    constant C_V_TICK_VPOS : T_LABEL_POS := (
        0 => C_V_LOW_LIMIT_EXT -   0*4 - C_FONT_HEIGHT/2,  --   0
        1 => C_V_LOW_LIMIT_EXT -  50*4 - C_FONT_HEIGHT/2,  --  50
        2 => C_V_LOW_LIMIT_EXT - 100*4 - C_FONT_HEIGHT/2,  -- 100
        3 => C_V_LOW_LIMIT_EXT - 150*4 - C_FONT_HEIGHT/2   -- 150
    );
    
    signal v_ticks_pixel : T_BOOLEAN_ARRAY(0 to C_NB_TICK_LABEL-1);
    
    -----------------------------------------------------------------------------------
    
    -- Labels on horizontal axis
    constant C_H_LABEL : STRING := "time (ms)";
    
    constant C_H_MIDDLE_PLOT : STD_LOGIC_VECTOR(11 downto 0)
        := C_H_LOW_LIMIT + ('0'&(C_H_UP_LIMIT(11 downto 1)-C_H_LOW_LIMIT(11 downto 1)));
    
    constant C_H_LABEL_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_H_MIDDLE_PLOT - C_FONT_WIDTH/2*(C_H_LABEL'length) - 6;
    constant C_H_LABEL_VPOS : STD_LOGIC_VECTOR(11 downto 0) := C_H_TICK_VPOS + C_FONT_HEIGHT + 8;
    
    signal h_label_pixel : BOOLEAN;
    
    -- Labels on vertical axis
    constant C_V_LABEL : STRING := "neuron";
    
    constant C_V_MIDDLE_PLOT : STD_LOGIC_VECTOR(11 downto 0)
        := G_V_UP_LIMIT + ('0'&(C_V_LOW_LIMIT_EXT(11 downto 1)-G_V_UP_LIMIT(11 downto 1)));
    
    signal C_V_LABEL_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_V_TICK_HPOS - 10 - C_FONT_HEIGHT;
    signal C_V_LABEL_VPOS : STD_LOGIC_VECTOR(11 downto 0) := C_V_MIDDLE_PLOT - C_FONT_WIDTH/2*(C_V_LABEL'length);
    
    signal v_label_pixel : BOOLEAN;
    
begin
    
    o_axes_label_pixel <= True when h_ticks_pixel /= (h_ticks_pixel'range => False)
                                 or v_ticks_pixel /= (v_ticks_pixel'range => False)
                     else False;
    
    o_ticks_label_pixel <= h_label_pixel or v_label_pixel;
    
    -----------------------------------------------------------------------------------
    
    write_text_gen_h_ticks :
        for i in 0 to 10 generate
            write_text_inst_h_tick : write_text
                generic map (
                   G_TEXT_LENGTH => C_H_TICK_NAME(0)'length
                )
                port map (
                    i_clk          => i_clk,
                    i_do_display   => True,
                    i_display_text => C_H_TICK_NAME(i),
                    i_text_hpos    => C_H_TICK_HPOS(i),
                    i_text_vpos    => C_H_TICK_VPOS,
                    i_hcounter     => i_hcounter,
                    i_vcounter     => i_vcounter,
                    
                    o_pixel => h_ticks_pixel(i)
                );
        end generate;
    
    write_text_gen_v_ticks :
    for i in 0 to C_NB_TICK_LABEL-1 generate
        write_text_inst_v_tick : write_text
            generic map (
               G_TEXT_LENGTH => C_V_TICK_NAME(0)'length
            )
            port map (
                i_clk          => i_clk,
                i_do_display   => True,
                i_display_text => C_V_TICK_NAME(i),
                i_text_hpos    => C_V_TICK_HPOS,
                i_text_vpos    => C_V_TICK_VPOS(i),
                i_hcounter     => i_hcounter,
                i_vcounter     => i_vcounter,
                
                o_pixel => v_ticks_pixel(i)
            );
    end generate;
    
    -----------------------------------------------------------------------------------
    
    write_text_inst_h_label : write_text
        generic map (
           G_TEXT_LENGTH => C_H_LABEL'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_H_LABEL,
            i_text_hpos    => C_H_LABEL_HPOS,
            i_text_vpos    => C_H_LABEL_VPOS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => h_label_pixel
        );
    
    write_text_rotated_inst_v_label : write_text_rotated
        generic map (
           G_TEXT_LENGTH => C_V_LABEL'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_V_LABEL,
            i_text_hpos    => C_V_LABEL_HPOS,
            i_text_vpos    => C_V_LABEL_VPOS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => v_label_pixel
        );
    
end Behavioral;
