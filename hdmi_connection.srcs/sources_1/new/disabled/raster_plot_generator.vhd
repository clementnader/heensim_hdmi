----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/05/2021 11:48:16 AM
-- Design Name: 
-- Module Name: raster_plot_generator - Behavioral
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
    use work.hdmi_resolution.ALL;
    use work.events_list.ALL;


entity raster_plot_generator is
    port (
        i_clk         : in STD_LOGIC;
        i_hcounter    : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter    : in STD_LOGIC_VECTOR(11 downto 0);
        i_current_ts  : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        i_events_list : in T_EVENTS_LIST;
        i_list_count  : in INTEGER range 0 to C_MAX_LIST-1;
        
        o_color : out STD_LOGIC_VECTOR(23 downto 0)
    );
end raster_plot_generator;


architecture Behavioral of raster_plot_generator is
    
    constant C_BLACK   : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    constant C_GREY    : STD_LOGIC_VECTOR(23 downto 0) := x"606060";
    constant C_RED     : STD_LOGIC_VECTOR(23 downto 0) := x"FF0000";
    constant C_YELLOW  : STD_LOGIC_VECTOR(23 downto 0) := x"FFFF00";
    constant C_GREEN   : STD_LOGIC_VECTOR(23 downto 0) := x"00FF00";
    constant C_CYAN    : STD_LOGIC_VECTOR(23 downto 0) := x"00FFFF";
    constant C_BLUE    : STD_LOGIC_VECTOR(23 downto 0) := x"0000FF";
    constant C_MAGENTA : STD_LOGIC_VECTOR(23 downto 0) := x"FF00FF";
    constant C_WHITE   : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
    
    function get_h_value(
        event_ts   : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        current_ts : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0)
    ) return STD_LOGIC_VECTOR is
            variable delta_t     : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            variable pre_product : STD_LOGIC_VECTOR(12+C_LENGTH_TIMESTAMP+C_T_DIV_ACCURACY downto 0);
            variable h_value     : STD_LOGIC_VECTOR(11 downto 0);
        begin
            if current_ts < C_TIMEOUT then
                delta_t := C_TIMEOUT  - event_ts;
            else
                delta_t := current_ts - event_ts;
            end if;
            pre_product := C_H_PLOT*delta_t * C_T_MULT;
            h_value := C_H_VISIBLE - C_H_OFFSET
                     - pre_product(11+C_T_DIV_ACCURACY downto C_T_DIV_ACCURACY);
                       -- shifted by C_T_DIV_ACCURACY to the right
            return h_value;
    end function;
    
    function get_v_value(
        neuron_id : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0)
    ) return STD_LOGIC_VECTOR is
            variable id_value    : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
            variable pre_product : STD_LOGIC_VECTOR(12+C_LENGTH_NEURON_ID+C_ID_DIV_ACCURACY downto 0);
            variable v_value     : STD_LOGIC_VECTOR(11 downto 0);
        begin
            id_value    := get_id_value(neuron_id);
            pre_product := C_V_PLOT*id_value * C_ID_MULT;
            v_value     := C_V_VISIBLE - C_V_OFFSET
                         - pre_product(11+C_ID_DIV_ACCURACY downto C_ID_DIV_ACCURACY);
                           -- shifted by C_ID_DIV_ACCURACY to the right
            return v_value;
    end function;
    
    function approx(
        coord     : STD_LOGIC_VECTOR(11 downto 0);
        ref_coord : STD_LOGIC_VECTOR(11 downto 0);
        size      : STD_LOGIC_VECTOR(11 downto 0) := C_SIZE
    ) return BOOLEAN is
            variable test : BOOLEAN;
        begin
            test := (coord > ref_coord - size) and (coord < ref_coord + size);
            return test;
    end function;
    
begin
    
    color_proc: process(i_clk)
        variable current_event : T_EVENT;
        variable h_value : STD_LOGIC_VECTOR(11 downto 0);
        variable v_value : STD_LOGIC_VECTOR(11 downto 0);
        
    begin
        if rising_edge(i_clk) then
            
            o_color <= C_BLACK;
            
            if (approx(i_hcounter, C_H_OFFSET)               and i_vcounter > C_V_OFFSET and i_vcounter < C_V_VISIBLE - C_V_OFFSET) or
               (approx(i_vcounter, C_V_VISIBLE - C_V_OFFSET) and i_hcounter > C_H_OFFSET and i_hcounter < C_H_VISIBLE - C_H_OFFSET) then
                -- White plot limits
                o_color <= C_WHITE;
                
            elsif i_hcounter > C_H_OFFSET and i_hcounter < C_H_VISIBLE - C_H_OFFSET and
                  i_vcounter > C_V_OFFSET and i_vcounter < C_V_VISIBLE - C_V_OFFSET then
                -- Grey background
                o_color <= C_GREY;
                
                -- Plot yellow dots when a switch is raised
                if i_list_count > 0 then  -- something is in the LIST
                    for count in C_MAX_LIST-1 downto 0 loop
                        if count < i_list_count then
                            
                            current_event := i_events_list(count);
                            h_value := get_h_value(current_event.TimeStamp, i_current_ts);
                            v_value := get_v_value(current_event.NeuronID);
                            if approx(i_vcounter, v_value, x"005") and approx(i_hcounter, h_value, x"005") then
                                o_color <= C_YELLOW;
                            end if;
                            
                        end if;
                    end loop;
                end if;
                
            end if;
            
        end if;
    end process;
    
end Behavioral;
