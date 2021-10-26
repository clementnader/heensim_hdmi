----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2021 07:01:02 PM
-- Design Name: 
-- Module Name: convert_event_to_coord - Behavioral
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

entity convert_event_to_coord is
    port (
        i_valid      : in STD_LOGIC;
        i_event      : in T_EVENT;
        i_current_ts : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        
        o_coord : out T_COORD
    );
end convert_event_to_coord;


architecture Behavioral of convert_event_to_coord is
    
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
            h_value     := C_H_VISIBLE - C_H_OFFSET
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
    
begin
    current_time_process : process(i_valid, i_event, i_current_ts)
        variable h_value : STD_LOGIC_VECTOR(11 downto 0);
        variable v_value : STD_LOGIC_VECTOR(11 downto 0);
        
    begin
        if i_valid = '1' then  -- there is an event to store
            h_value := get_h_value(i_event.TimeStamp, i_current_ts);
            v_value := get_v_value(i_event.NeuronID);
            o_coord <= (h_value, v_value);
        end if;
    end process;

end Behavioral;
