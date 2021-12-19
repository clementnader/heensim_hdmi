----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 05:47:45 PM
-- Design Name: 
-- Module Name: write_axes_and_ticks_label - Behavioral
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


entity write_axes_and_ticks_label is
    port (
        i_clk          : in STD_LOGIC;
        i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
        i_extend_vaxis : in STD_LOGIC;
        
        o_axes_label_pixel  : out BOOLEAN;
        o_ticks_label_pixel : out BOOLEAN
    );
end write_axes_and_ticks_label;


architecture Behavioral of write_axes_and_ticks_label is
    
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
    
    constant C_V_LOW_LIMIT_EXT : STD_LOGIC_VECTOR(11 downto 0)
                              := C_V_UP_LIMIT + (C_V_LOW_LIMIT(9 downto 0)&"00")-(C_V_UP_LIMIT(9 downto 0)&"00");
                              -- C_V_UP_LIMIT + (C_V_LOW_LIMIT-C_V_UP_LIMIT)*4
    
    -----------------------------------------------------------------------------------
    
    type T_LABEL_POS     is ARRAY(NATURAL range <>) of STD_LOGIC_VECTOR(11 downto 0);
    type T_STRING_ARRAY  is ARRAY(NATURAL range <>) of STRING;
    type T_INTEGER_ARRAY is ARRAY(NATURAL range <>) of INTEGER;
    type T_BOOLEAN_ARRAY is ARRAY(NATURAL range <>) of BOOLEAN;
    
    -----------------------------------------------------------------------------------
    
    -- Ticks label on horizontal axis
    constant C_H_TICK_NAME : T_STRING_ARRAY := ("   0", " 100", " 200", " 300", " 400",
        " 500", " 600", " 700", " 800", " 900", "1000");
    
    constant C_H_TICK_HPOS : T_LABEL_POS(0 to 10) := (
         0 => C_H_LOW_LIMIT +    0 - C_FONT_WIDTH*3 - C_FONT_WIDTH/2*1 - 1,  --    0
         1 => C_H_LOW_LIMIT +  100 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  100
         2 => C_H_LOW_LIMIT +  200 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  200
         3 => C_H_LOW_LIMIT +  300 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  300
         4 => C_H_LOW_LIMIT +  400 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  400
         5 => C_H_LOW_LIMIT +  500 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  500
         6 => C_H_LOW_LIMIT +  600 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  600
         7 => C_H_LOW_LIMIT +  700 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  700
         8 => C_H_LOW_LIMIT +  800 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  800
         9 => C_H_LOW_LIMIT +  900 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  900
        10 => C_H_LOW_LIMIT + 1000 - C_FONT_WIDTH*0 - C_FONT_WIDTH/2*4 - 1   -- 1000
    );
    
    constant C_H_TICK_VPOS     : STD_LOGIC_VECTOR(11 downto 0) := C_V_LOW_LIMIT     + 12;
    constant C_H_TICK_VPOS_EXT : STD_LOGIC_VECTOR(11 downto 0) := C_V_LOW_LIMIT_EXT + 14;
    
    signal h_tick_vpos : STD_LOGIC_VECTOR(11 downto 0);
    
    signal h_ticks_pixel : T_BOOLEAN_ARRAY(0 to 10);
    
    -----------------------------------------------------------------------------------
    
    -- Ticks label on vertical axis
    constant C_V_TICK_NAME : T_STRING_ARRAY := ("   0", "  50", " 100", " 150", " 200",
        " 250", " 300", " 350", " 400", " 450", " 500", " 550", " 600", " 650", " 700",
        " 750", " 800", " 850", " 900", " 950", "1000", "1050");
    
    constant C_V_TICK_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT - 15 - 4*C_FONT_WIDTH;
    
    constant C_V_TICK_VPOS : T_LABEL_POS := (
        0 => C_V_LOW_LIMIT -    0 - C_FONT_HEIGHT/2 + 1,  --    0
        1 => C_V_LOW_LIMIT -   50 - C_FONT_HEIGHT/2 + 1,  --   50
        2 => C_V_LOW_LIMIT -  100 - C_FONT_HEIGHT/2 + 1,  --  100
        3 => C_V_LOW_LIMIT -  150 - C_FONT_HEIGHT/2 + 1,  --  150
        4 => C_V_LOW_LIMIT -  200 - C_FONT_HEIGHT/2 + 1,  --  200
        5 => C_V_LOW_LIMIT -  250 - C_FONT_HEIGHT/2 + 1,  --  250
        6 => C_V_LOW_LIMIT -  300 - C_FONT_HEIGHT/2 + 1,  --  300
        7 => C_V_LOW_LIMIT -  350 - C_FONT_HEIGHT/2 + 1,  --  350
        8 => C_V_LOW_LIMIT -  400 - C_FONT_HEIGHT/2 + 1,  --  400
        9 => C_V_LOW_LIMIT -  450 - C_FONT_HEIGHT/2 + 1,  --  450
       10 => C_V_LOW_LIMIT -  500 - C_FONT_HEIGHT/2 + 1,  --  500
       11 => C_V_LOW_LIMIT -  550 - C_FONT_HEIGHT/2 + 1,  --  550
       12 => C_V_LOW_LIMIT -  600 - C_FONT_HEIGHT/2 + 1,  --  600
       13 => C_V_LOW_LIMIT -  650 - C_FONT_HEIGHT/2 + 1,  --  650
       14 => C_V_LOW_LIMIT -  700 - C_FONT_HEIGHT/2 + 1,  --  700
       15 => C_V_LOW_LIMIT -  750 - C_FONT_HEIGHT/2 + 1,  --  750
       16 => C_V_LOW_LIMIT -  800 - C_FONT_HEIGHT/2 + 1,  --  800
       17 => C_V_LOW_LIMIT -  850 - C_FONT_HEIGHT/2 + 1,  --  850
       18 => C_V_LOW_LIMIT -  900 - C_FONT_HEIGHT/2 + 1,  --  900
       19 => C_V_LOW_LIMIT -  950 - C_FONT_HEIGHT/2 + 1,  --  950
       20 => C_V_LOW_LIMIT - 1000 - C_FONT_HEIGHT/2 + 1,  -- 1000
       21 => C_V_LOW_LIMIT - 1050 - C_FONT_HEIGHT/2 + 1   -- 1050
    );
    constant C_V_TICK_VPOS_EXT : T_LABEL_POS := (
        0 => C_V_LOW_LIMIT_EXT -    0*4 - C_FONT_HEIGHT/2,  --    0
        1 => C_V_LOW_LIMIT_EXT -   50*4 - C_FONT_HEIGHT/2,  --   50
        2 => C_V_LOW_LIMIT_EXT -  100*4 - C_FONT_HEIGHT/2,  --  100
        3 => C_V_LOW_LIMIT_EXT -  150*4 - C_FONT_HEIGHT/2,  --  150
        4 => C_V_LOW_LIMIT_EXT -  200*4 - C_FONT_HEIGHT/2,  --  200
        5 => C_V_LOW_LIMIT_EXT -  250*4 - C_FONT_HEIGHT/2,  --  250
        6 => C_V_LOW_LIMIT_EXT -  300*4 - C_FONT_HEIGHT/2,  --  300
        7 => C_V_LOW_LIMIT_EXT -  350*4 - C_FONT_HEIGHT/2,  --  350
        8 => C_V_LOW_LIMIT_EXT -  400*4 - C_FONT_HEIGHT/2,  --  400
        9 => C_V_LOW_LIMIT_EXT -  450*4 - C_FONT_HEIGHT/2,  --  450
       10 => C_V_LOW_LIMIT_EXT -  500*4 - C_FONT_HEIGHT/2,  --  500
       11 => C_V_LOW_LIMIT_EXT -  550*4 - C_FONT_HEIGHT/2,  --  550
       12 => C_V_LOW_LIMIT_EXT -  600*4 - C_FONT_HEIGHT/2,  --  600
       13 => C_V_LOW_LIMIT_EXT -  650*4 - C_FONT_HEIGHT/2,  --  650
       14 => C_V_LOW_LIMIT_EXT -  700*4 - C_FONT_HEIGHT/2,  --  700
       15 => C_V_LOW_LIMIT_EXT -  750*4 - C_FONT_HEIGHT/2,  --  750
       16 => C_V_LOW_LIMIT_EXT -  800*4 - C_FONT_HEIGHT/2,  --  800
       17 => C_V_LOW_LIMIT_EXT -  850*4 - C_FONT_HEIGHT/2,  --  850
       18 => C_V_LOW_LIMIT_EXT -  900*4 - C_FONT_HEIGHT/2,  --  900
       19 => C_V_LOW_LIMIT_EXT -  950*4 - C_FONT_HEIGHT/2,  --  950
       20 => C_V_LOW_LIMIT_EXT - 1000*4 - C_FONT_HEIGHT/2,  -- 1000
       21 => C_V_LOW_LIMIT_EXT - 1050*4 - C_FONT_HEIGHT/2   -- 1050
    );
    
    signal v_tick_vpos : T_LABEL_POS(0 to C_NB_TICK_LABEL-1);
    
    signal v_ticks_pixel : T_BOOLEAN_ARRAY(0 to C_NB_TICK_LABEL-1);
    
    -----------------------------------------------------------------------------------
    
    -- Labels on horizontal axis
    constant C_H_LABEL : STRING := "time (ms)";
    
    constant C_H_MIDDLE_PLOT : STD_LOGIC_VECTOR(11 downto 0)
                            := C_H_LOW_LIMIT + ('0'&(C_H_UP_LIMIT(11 downto 1)-C_H_LOW_LIMIT(11 downto 1)));
    
    signal h_label_vpos : STD_LOGIC_VECTOR(11 downto 0);
    
    signal h_label_pixel : BOOLEAN;
    
    -- Labels on vertical axis
    constant C_V_LABEL : STRING := "neuron";
    
    constant C_V_MIDDLE_PLOT : STD_LOGIC_VECTOR(11 downto 0)
                            := C_V_UP_LIMIT + ('0'&(C_V_LOW_LIMIT(11 downto 1)-C_V_UP_LIMIT(11 downto 1)));
    constant C_V_MIDDLE_PLOT_EXT : STD_LOGIC_VECTOR(11 downto 0)
                                := C_V_UP_LIMIT + ('0'&(C_V_LOW_LIMIT_EXT(11 downto 1)-C_V_UP_LIMIT(11 downto 1)));
    
    signal v_label_vpos : STD_LOGIC_VECTOR(11 downto 0);
    
    signal v_label_pixel : BOOLEAN;
    
begin
    
    o_axes_label_pixel <= True when h_ticks_pixel /= (h_ticks_pixel'range => False)
                                 or v_ticks_pixel /= (v_ticks_pixel'range => False)
                     else False;
    
    o_ticks_label_pixel <= h_label_pixel or v_label_pixel;
    
    -----------------------------------------------------------------------------------
    
    h_tick_vpos <= C_H_TICK_VPOS_EXT when i_extend_vaxis = '1'
              else C_H_TICK_VPOS;
    write_text_gen_h_ticks :
        for i in 0 to 10 generate
            write_text_inst_h_tick : write_text
                generic map (
                   G_TEXT_LENGTH => 4
                )
                port map (
                    i_clk          => i_clk,
                    i_do_display   => True,
                    i_display_text => C_H_TICK_NAME(i),
                    i_text_hpos    => C_H_TICK_HPOS(i),
                    i_text_vpos    => h_tick_vpos,
                    i_hcounter     => i_hcounter,
                    i_vcounter     => i_vcounter,
                    
                    o_pixel => h_ticks_pixel(i)
                );
        end generate;
    
    v_tick_vpos <= C_V_TICK_VPOS_EXT(0 to C_NB_TICK_LABEL-1) when i_extend_vaxis = '1'
              else C_V_TICK_VPOS(0 to C_NB_TICK_LABEL-1);
    write_text_gen_v_ticks :
    for i in 0 to C_NB_TICK_LABEL-1 generate
        write_text_inst_v_tick : write_text
            generic map (
               G_TEXT_LENGTH => 4
            )
            port map (
                i_clk          => i_clk,
                i_do_display   => True,
                i_display_text => C_V_TICK_NAME(i),
                i_text_hpos    => C_V_TICK_HPOS,
                i_text_vpos    => v_tick_vpos(i),
                i_hcounter     => i_hcounter,
                i_vcounter     => i_vcounter,
                
                o_pixel => v_ticks_pixel(i)
            );
    end generate;
    
    -----------------------------------------------------------------------------------
    
    h_label_vpos <= h_tick_vpos + 8 + C_FONT_HEIGHT;
    write_text_inst_h_label : write_text
        generic map (
           G_TEXT_LENGTH => C_H_LABEL'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_H_LABEL,
            i_text_hpos    => C_H_MIDDLE_PLOT - C_FONT_WIDTH/2*9 - 3,
            i_text_vpos    => h_label_vpos,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => h_label_pixel
        );
    
    v_label_vpos <= C_V_MIDDLE_PLOT_EXT - C_FONT_WIDTH/2*6 - 4 when i_extend_vaxis = '1'
               else C_V_MIDDLE_PLOT     - C_FONT_WIDTH/2*6;
    write_text_rotated_inst_v_label : write_text_rotated
        generic map (
           G_TEXT_LENGTH => C_V_LABEL'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_V_LABEL,
            i_text_hpos    => C_H_LOW_LIMIT - 15 - 3*C_FONT_WIDTH - 10 - C_FONT_HEIGHT,
            i_text_vpos    => v_label_vpos,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => v_label_pixel
        );
    
end Behavioral;
