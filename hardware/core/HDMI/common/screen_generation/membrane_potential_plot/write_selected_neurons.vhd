----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2022 02:36:42 PM
-- Design Name: 
-- Module Name: write_selected_neurons - Behavioral
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
    use work.plot_pkg.ALL;
    use work.neurons_pkg.ALL;
    use work.character_definition_pkg.ALL;


entity write_selected_neurons is
    generic (
        G_V_UP_LIMIT_ALL : STD_LOGIC_VECTOR(11 downto 0)
    );
    port (
        i_clk           : in STD_LOGIC;
        i_hcounter      : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter      : in STD_LOGIC_VECTOR(11 downto 0);
        i_npos_hdmi_mon : in STD_LOGIC_VECTOR(C_LENGTH_SELECTED_NEURONS_INFO-1 downto 0);
        
        o_text_pixel  : out BOOLEAN;
        o_value_pixel : out T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1)
    );
end write_selected_neurons;


architecture Behavioral of write_selected_neurons is
    
    component write_neuron_info is
        generic (
            G_TOP_V_POS  : STD_LOGIC_VECTOR(11 downto 0);
            G_COLOR_NAME : STRING(C_ANALOG_PLOT_COLORS_NAME(1)'range)
        );
        port (
            i_clk       : in STD_LOGIC;
            i_hcounter  : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter  : in STD_LOGIC_VECTOR(11 downto 0);
            i_neuron_id : in STD_LOGIC_VECTOR(C_LENGTH_NEURON_INFO-1 downto 0);
            
            o_text_pixel  : out BOOLEAN;
            o_value_pixel : out BOOLEAN
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    signal text_pixel  : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    signal value_pixel : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    
begin
    
    o_text_pixel  <= True when text_pixel /= (text_pixel'range => False) else False;
    o_value_pixel <= value_pixel;
    
    -----------------------------------------------------------------------------------
    
    write_neurons_info :
    for i in 0 to C_NB_NEURONS_ANALOG-1 generate
        
        write_neuron_info_inst : write_neuron_info
            generic map (
                G_TOP_V_POS  => G_V_UP_LIMIT_ALL + C_FONT_HEIGHT + (C_ANALOG_PLOT_RANGE + 2)*i,
                G_COLOR_NAME => C_ANALOG_PLOT_COLORS_NAME(i)
            )
            port map (
                i_clk       => i_clk,
                i_hcounter  => i_hcounter,
                i_vcounter  => i_vcounter,
                i_neuron_id => i_npos_hdmi_mon(C_LENGTH_NEURON_INFO*(i+1)-1 downto C_LENGTH_NEURON_INFO*i),
                
                o_text_pixel  => text_pixel(i),
                o_value_pixel => value_pixel(i)
            );
        
    end generate;
    
end Behavioral;
