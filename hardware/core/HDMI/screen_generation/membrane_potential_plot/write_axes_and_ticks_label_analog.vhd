----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/20/2021 05:07:01 PM
-- Design Name: 
-- Module Name: write_axes_and_ticks_label_analog - Behavioral
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
    use work.neurons_pkg.ALL;


entity write_axes_and_ticks_label_analog is
    generic (
        G_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0);
        G_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0)
    );
    port (
        i_clk      : in STD_LOGIC;
        i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
        
        o_axes_label_pixel    : out BOOLEAN;
        o_h_ticks_label_pixel : out BOOLEAN;
        o_v_ticks_label_pixel : out T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1)
    );
end write_axes_and_ticks_label_analog;


architecture Behavioral of write_axes_and_ticks_label_analog is
    
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
    
    -- Ticks label on horizontal axis
    constant C_H_TICK_VPOS : STD_LOGIC_VECTOR(11 downto 0) := G_V_UP_LIMIT - 12 - C_FONT_HEIGHT;
    
    signal h_ticks_pixel : T_BOOLEAN_ARRAY(0 to 10);
    
    -----------------------------------------------------------------------------------
    
    -- Ticks label on vertical axis
    constant C_V_LOW_TICK_VALUE : STRING := "-80";
    constant C_V_MID_TICK_VALUE : STRING := "-55";
    constant C_V_UP_TICK_VALUE  : STRING := "-30";
    constant C_V_LOW_TICK_LABEL : STRING := "depolarization";
    constant C_V_MID_TICK_LABEL : STRING := "threshold";
    
    constant C_V_LEFT_TICK_HPOS  : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT - 14 - 3*C_FONT_WIDTH;
    constant C_V_RIGHT_TICK_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_H_UP_LIMIT  + 14;
    
    constant C_V_LOW_TICK_VPOS : STD_LOGIC_VECTOR(11 downto 0) := G_V_LOW_LIMIT -   0 - C_FONT_HEIGHT/2 + 1;
    constant C_V_MID_TICK_VPOS : STD_LOGIC_VECTOR(11 downto 0) := G_V_LOW_LIMIT - 250 - C_FONT_HEIGHT/2 + 1;
    constant C_V_UP_TICK_VPOS  : STD_LOGIC_VECTOR(11 downto 0) := G_V_LOW_LIMIT - 500 - C_FONT_HEIGHT/2 + 1;
    
    signal v_low_left_ticks_pixel  : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    signal v_mid_left_ticks_pixel  : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    signal v_up_left_ticks_pixel   : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    signal v_low_right_ticks_pixel : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    signal v_mid_right_ticks_pixel : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    
    -----------------------------------------------------------------------------------
    
    -- Labels on vertical axis
    constant C_V_LABEL : STRING := "voltage (mV)";
    
    constant C_V_MIDDLE_PLOT : STD_LOGIC_VECTOR(11 downto 0)
        := G_V_UP_LIMIT + ('0'&(G_V_LOW_LIMIT(11 downto 1)-G_V_UP_LIMIT(11 downto 1)));
    
    signal C_V_LABEL_HPOS : STD_LOGIC_VECTOR(11 downto 0) := C_V_LEFT_TICK_HPOS - 10 - C_FONT_HEIGHT;
    signal C_V_LABEL_VPOS : STD_LOGIC_VECTOR(11 downto 0) := C_V_MIDDLE_PLOT - C_FONT_WIDTH/2*(C_V_LABEL'length);
    
begin
    
    o_h_ticks_label_pixel <= True when h_ticks_pixel /= (h_ticks_pixel'range => False) else False;
    
    o_v_ticks_label_pixel <= v_low_left_ticks_pixel or v_mid_left_ticks_pixel or v_up_left_ticks_pixel
        or v_low_right_ticks_pixel or v_mid_right_ticks_pixel;
    
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
    
    -----------------------------------------------------------------------------------
    
    write_text_gen_v_ticks :
    for i in 0 to C_NB_NEURONS_ANALOG-1 generate
        
        write_text_inst_v_low_left_ticks : write_text
            generic map (
               G_TEXT_LENGTH => C_V_LOW_TICK_VALUE'length
            )
            port map (
                i_clk          => i_clk,
                i_do_display   => True,
                i_display_text => C_V_LOW_TICK_VALUE,
                i_text_hpos    => C_V_LEFT_TICK_HPOS,
                i_text_vpos    => C_V_LOW_TICK_VPOS - 50*i,
                i_hcounter     => i_hcounter,
                i_vcounter     => i_vcounter,
                
                o_pixel => v_low_left_ticks_pixel(i)
            );
        
        write_text_inst_v_mid_left_ticks : write_text
            generic map (
               G_TEXT_LENGTH => C_V_MID_TICK_VALUE'length
            )
            port map (
                i_clk          => i_clk,
                i_do_display   => True,
                i_display_text => C_V_MID_TICK_VALUE,
                i_text_hpos    => C_V_LEFT_TICK_HPOS,
                i_text_vpos    => C_V_MID_TICK_VPOS - 50*i,
                i_hcounter     => i_hcounter,
                i_vcounter     => i_vcounter,
                
                o_pixel => v_mid_left_ticks_pixel(i)
            );
        
        write_text_inst_v_up_left_ticks : write_text
            generic map (
               G_TEXT_LENGTH => C_V_UP_TICK_VALUE'length
            )
            port map (
                i_clk          => i_clk,
                i_do_display   => True,
                i_display_text => C_V_UP_TICK_VALUE,
                i_text_hpos    => C_V_LEFT_TICK_HPOS,
                i_text_vpos    => C_V_UP_TICK_VPOS - 50*i,
                i_hcounter     => i_hcounter,
                i_vcounter     => i_vcounter,
                
                o_pixel => v_up_left_ticks_pixel(i)
            );
        
        write_text_inst_v_low_right_ticks : write_text
            generic map (
               G_TEXT_LENGTH => C_V_LOW_TICK_LABEL'length
            )
            port map (
                i_clk          => i_clk,
                i_do_display   => True,
                i_display_text => C_V_LOW_TICK_LABEL,
                i_text_hpos    => C_V_RIGHT_TICK_HPOS,
                i_text_vpos    => C_V_LOW_TICK_VPOS - 50*i,
                i_hcounter     => i_hcounter,
                i_vcounter     => i_vcounter,
                
                o_pixel => v_low_right_ticks_pixel(i)
            );
        
        write_text_inst_v_mid_right_ticks : write_text
            generic map (
               G_TEXT_LENGTH => C_V_MID_TICK_LABEL'length
            )
            port map (
                i_clk          => i_clk,
                i_do_display   => True,
                i_display_text => C_V_MID_TICK_LABEL,
                i_text_hpos    => C_V_RIGHT_TICK_HPOS,
                i_text_vpos    => C_V_MID_TICK_VPOS - 50*i,
                i_hcounter     => i_hcounter,
                i_vcounter     => i_vcounter,
                
                o_pixel => v_mid_right_ticks_pixel(i)
            );
        
    end generate;
    
    -----------------------------------------------------------------------------------
    
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
            
            o_pixel => o_axes_label_pixel
        );
    
end Behavioral;
