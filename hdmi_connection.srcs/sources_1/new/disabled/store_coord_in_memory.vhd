----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2021 19:15:29 PM
-- Design Name: 
-- Module Name: store_coord_in_memory - Behavioral
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
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.hdmi_resolution.ALL;
    use work.events_list.ALL;


entity store_coord_in_memory is
    port (
        i_clk        : in STD_LOGIC;
        i_rst        : in STD_LOGIC;
        i_valid      : in STD_LOGIC;
        i_coord      : in T_COORD;
        i_current_ts : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        
        o_coord_list : out T_COORD_LIST
    );
end store_coord_in_memory;


architecture Behavioral of store_coord_in_memory is
    signal coord_list : T_COORD_LIST;
    
    constant C_DELTA_TS : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0)
                      := std_logic_vector(to_unsigned(C_TIMEOUT, C_LENGTH_TIMESTAMP)/unsigned(C_H_PLOT));
    
    signal ts_update_time : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0) := C_TIMEOUT + C_DELTA_TS;
    
begin
    store_in_the_list : process(i_clk)
    begin
        if rising_edge(i_clk) then
            if i_rst = '1' then
                coord_list     <= (others => (others => x"000"));
                ts_update_time <= C_TIMEOUT + C_DELTA_TS;
            else
                if i_valid = '1' then  -- there is an event to store
                    -- Add the new event at the first position
                    coord_list <= i_coord & coord_list(0 to C_MAX_LIST-2);
                    
                elsif i_current_ts > ts_update_time then
                    ts_update_time <= ts_update_time + C_DELTA_TS;
                    for count in C_MAX_LIST-1 downto 0 loop
                        if coord_list(count).h_value > C_H_OFFSET then
                            -- shift the point to the left
                            coord_list(count).h_value <= coord_list(count).h_value - 1;
                        else
                            -- delete this coordinate
                            coord_list(count) <= (others => x"000");
                        end if;
                    end loop;
                end if;
            end if;
        end if;
    end process;
    
    o_coord_list <= coord_list;
    
end Behavioral;
