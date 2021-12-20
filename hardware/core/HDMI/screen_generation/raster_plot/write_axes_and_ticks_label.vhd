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
    
    constant C_TICK_LABEL_MOD : INTEGER := (G_NB_V_POINTS-1) mod 50;
    constant C_NB_TICK_LABEL  : INTEGER := (G_NB_V_POINTS-1-C_TICK_LABEL_MOD) / 50 + 1;
    
    -----------------------------------------------------------------------------------
    
    -- Ticks label on horizontal axis
    constant C_H_TICK_VPOS : STD_LOGIC_VECTOR(11 downto 0) := G_V_LOW_LIMIT + 13;
    
    signal h_ticks_pixel : T_BOOLEAN_ARRAY(0 to 10);
    
    -----------------------------------------------------------------------------------
    
    -- Ticks label on vertical axis
    constant C_V_TICK_NAME : T_STRING_ARRAY := ("  0", " 50", "100", "150", "200", "250", "300",
        "350", "400", "450", "500", "550", "600", "650", "700", "750", "800", "850", "900", "950");
    
    constant C_V_TICK_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT - 14 - 3*C_FONT_WIDTH;
    constant C_V_TICK_VPOS : T_LABEL_POS := (
        0 => G_V_LOW_LIMIT -   0 - C_FONT_HEIGHT/2 + 1,  --   0
        1 => G_V_LOW_LIMIT -  50 - C_FONT_HEIGHT/2 + 1,  --  50
        2 => G_V_LOW_LIMIT - 100 - C_FONT_HEIGHT/2 + 1,  -- 100
        3 => G_V_LOW_LIMIT - 150 - C_FONT_HEIGHT/2 + 1,  -- 150
        4 => G_V_LOW_LIMIT - 200 - C_FONT_HEIGHT/2 + 1,  -- 200
        5 => G_V_LOW_LIMIT - 250 - C_FONT_HEIGHT/2 + 1,  -- 250
        6 => G_V_LOW_LIMIT - 300 - C_FONT_HEIGHT/2 + 1,  -- 300
        7 => G_V_LOW_LIMIT - 350 - C_FONT_HEIGHT/2 + 1,  -- 350
        8 => G_V_LOW_LIMIT - 400 - C_FONT_HEIGHT/2 + 1,  -- 400
        9 => G_V_LOW_LIMIT - 450 - C_FONT_HEIGHT/2 + 1,  -- 450
       10 => G_V_LOW_LIMIT - 500 - C_FONT_HEIGHT/2 + 1,  -- 500
       11 => G_V_LOW_LIMIT - 550 - C_FONT_HEIGHT/2 + 1,  -- 550
       12 => G_V_LOW_LIMIT - 600 - C_FONT_HEIGHT/2 + 1,  -- 600
       13 => G_V_LOW_LIMIT - 650 - C_FONT_HEIGHT/2 + 1,  -- 650
       14 => G_V_LOW_LIMIT - 700 - C_FONT_HEIGHT/2 + 1,  -- 700
       15 => G_V_LOW_LIMIT - 750 - C_FONT_HEIGHT/2 + 1,  -- 750
       16 => G_V_LOW_LIMIT - 800 - C_FONT_HEIGHT/2 + 1,  -- 800
       17 => G_V_LOW_LIMIT - 850 - C_FONT_HEIGHT/2 + 1,  -- 850
       18 => G_V_LOW_LIMIT - 900 - C_FONT_HEIGHT/2 + 1,  -- 900
       19 => G_V_LOW_LIMIT - 950 - C_FONT_HEIGHT/2 + 1   -- 950
    );
    
    signal v_ticks_pixel : T_BOOLEAN_ARRAY(0 to C_NB_TICK_LABEL-1);
    
    -----------------------------------------------------------------------------------
    
    -- Labels on horizontal axis
    constant C_H_LABEL_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_H_MIDDLE_PLOT - C_FONT_WIDTH/2*(C_H_LABEL'length) - 6;
    constant C_H_LABEL_VPOS : STD_LOGIC_VECTOR(11 downto 0) := C_H_TICK_VPOS + C_FONT_HEIGHT + 8;
    
    signal h_label_pixel : BOOLEAN;
    
    -- Labels on vertical axis
    constant C_V_LABEL : STRING := "neuron";
    
    constant C_V_MIDDLE_PLOT : STD_LOGIC_VECTOR(11 downto 0)
        := G_V_UP_LIMIT + ('0'&(G_V_LOW_LIMIT(11 downto 1)-G_V_UP_LIMIT(11 downto 1)));
    
    signal C_V_LABEL_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_V_TICK_HPOS - 10 - C_FONT_HEIGHT;
    signal C_V_LABEL_VPOS : STD_LOGIC_VECTOR(11 downto 0) := C_V_MIDDLE_PLOT - C_FONT_WIDTH/2*(C_V_LABEL'length);
    
    signal v_label_pixel : BOOLEAN;
    
begin
    
    o_axes_label_pixel <= h_label_pixel or v_label_pixel;
    
    o_ticks_label_pixel <= True when h_ticks_pixel /= (h_ticks_pixel'range => False)
                                  or v_ticks_pixel /= (v_ticks_pixel'range => False)
                      else False;
    
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
