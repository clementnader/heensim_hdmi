----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2021 07:44:26 PM
-- Design Name: 
-- Module Name: raster_plot - Behavioral
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


entity raster_plot is
    port (
        i_clk           : in STD_LOGIC;
        i_rst           : in STD_LOGIC;
        i_freeze_screen : in STD_LOGIC;
        i_hcounter      : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter      : in STD_LOGIC_VECTOR(11 downto 0);
        i_mem_rd_data   : in STD_LOGIC_VECTOR(C_MAX_ID downto 0);
        i_current_ts    : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        i_extend_vaxis  : in STD_LOGIC;
        i_bigger_dots   : in STD_LOGIC;
        
        o_mem_rd_en   : out STD_LOGIC;
        o_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
        o_color       : out STD_LOGIC_VECTOR(23 downto 0);
        o_end_screen  : out STD_LOGIC
    );
end raster_plot;


architecture Behavioral of raster_plot is
    
    constant C_BLACK   : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    constant C_GREY    : STD_LOGIC_VECTOR(23 downto 0) := x"444444";
    constant C_RED     : STD_LOGIC_VECTOR(23 downto 0) := x"FF0000";
    constant C_YELLOW  : STD_LOGIC_VECTOR(23 downto 0) := x"FFFF00";
    constant C_GREEN   : STD_LOGIC_VECTOR(23 downto 0) := x"00FF00";
    constant C_CYAN    : STD_LOGIC_VECTOR(23 downto 0) := x"00FFFF";
    constant C_BLUE    : STD_LOGIC_VECTOR(23 downto 0) := x"0000FF";
    constant C_MAGENTA : STD_LOGIC_VECTOR(23 downto 0) := x"FF00FF";
    constant C_WHITE   : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
    
    constant C_H_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_H_OFFSET;
    constant C_H_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT + C_NB_H_POINTS;
    
    constant C_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_V_OFFSET;
    constant C_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_V_UP_LIMIT + (C_MAX_ID + 1);
    
    signal pointer0   : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal current_ts : STD_LOGIC_VECTOR(31 downto 0);
    
    signal extend_vaxis   : STD_LOGIC;
    signal intermed_vcnt  : STD_LOGIC_VECTOR(1 downto 0);
    signal neuron_id_vcnt : STD_LOGIC_VECTOR(11 downto 0);
    
    signal mem_column_before  : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
    signal mem_column_current : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
    
begin
    
    color_proc: process(i_clk)
        variable shifted_hcounter : STD_LOGIC_VECTOR(11 downto 0);
        variable shifted_vcounter : INTEGER range 0 to C_MAX_ID;
        
    begin
        if rising_edge(i_clk) then
            -- Black background
            o_color <= C_BLACK;
            o_end_screen <= '0';
            if i_current_ts = 0 then
                pointer0   <= (others => '0');
                current_ts <= (others => '0');
            end if;
            
            if i_rst = '0' then
                
                if (i_hcounter <= C_H_LOW_LIMIT - 1 and i_hcounter >= C_H_LOW_LIMIT - 2
                  and neuron_id_vcnt <= C_V_LOW_LIMIT + 2 and neuron_id_vcnt > C_V_UP_LIMIT)
                 or (neuron_id_vcnt >= C_V_LOW_LIMIT + 1 and neuron_id_vcnt <= C_V_LOW_LIMIT + 2
                  and i_hcounter >= C_H_LOW_LIMIT - 2 and i_hcounter < C_H_UP_LIMIT) then
                    -- White plot limits
                    o_color <= C_WHITE;
                    if neuron_id_vcnt >= C_V_LOW_LIMIT + 1 and neuron_id_vcnt <= C_V_LOW_LIMIT + 2
                     and i_hcounter = C_H_UP_LIMIT - 1 then
                        neuron_id_vcnt <= neuron_id_vcnt + 1;
                    end if;
                end if;
                
                if i_hcounter = C_H_VISIBLE and i_vcounter = C_V_VISIBLE then  -- end of screen
                    if i_freeze_screen = '0' then
                        o_end_screen <= '1';
                        current_ts   <= i_current_ts;
                        if i_current_ts(31 downto 10) = 0 then  -- the memory has not been written fully
                            pointer0 <= (others => '0');
                        else
                            pointer0 <= i_current_ts(pointer0'high downto 0) + 1;
                        end if;
                    end if;
                end if;
                
                if i_vcounter = 0 and i_hcounter = 0 then
                    -- Initialization
                    mem_column_before  <= (others => '0');
                    mem_column_current <= (others => '0');
                    extend_vaxis       <= i_extend_vaxis;
                    neuron_id_vcnt     <= (others => '0');
                    intermed_vcnt      <= "00";
                elsif i_vcounter = C_V_UP_LIMIT and i_hcounter = 0 then
                    neuron_id_vcnt <= C_V_UP_LIMIT;
                elsif i_vcounter > C_V_UP_LIMIT and neuron_id_vcnt <= C_V_LOW_LIMIT then
                    if i_hcounter = 0 then
                        if extend_vaxis = '1' then
                            intermed_vcnt <= intermed_vcnt + 1;  -- counter from 0 to 3
                            if intermed_vcnt = "00" then
                                neuron_id_vcnt <= neuron_id_vcnt + 1;
                            end if;
                        else
                            neuron_id_vcnt <= neuron_id_vcnt + 1;
                        end if;
                    elsif i_hcounter >= C_H_LOW_LIMIT - 4 and i_hcounter < C_H_UP_LIMIT then
                        -- we need three time periods before reading from the memory
                        o_mem_rd_en <= '1';
                        shifted_hcounter := i_hcounter - (C_H_LOW_LIMIT - 4);  -- from 0 to C_NB_H_POINTS-1=1023
                        o_mem_rd_addr <= pointer0 + shifted_hcounter(pointer0'high downto 0);
                        
                        if i_hcounter = C_H_LOW_LIMIT - 1 then
                            mem_column_current <= i_mem_rd_data;
                        
                        elsif i_hcounter >= C_H_LOW_LIMIT then
                            -- Grey background inside the plot
                            o_color <= C_GREY;
                            mem_column_before  <= mem_column_current;
                            mem_column_current <= i_mem_rd_data;
                            
                            if shifted_hcounter <= current_ts then
                                shifted_vcounter := to_integer(unsigned(C_V_LOW_LIMIT - neuron_id_vcnt));  -- from 0 to C_MAX_ID=199
                                if extend_vaxis = '1' then
                                    if (intermed_vcnt = "10"  -- middle point
                                      and mem_column_current(shifted_vcounter) = '1')
                                     or (i_bigger_dots = '1'
                                      and ((intermed_vcnt = "10"  -- middle point
                                        and (mem_column_before(shifted_vcounter) = '1'
                                         or i_mem_rd_data(shifted_vcounter) = '1'))
                                       or ((intermed_vcnt = "01" or intermed_vcnt = "11")  -- up and down points
                                        and mem_column_current(shifted_vcounter) = '1'))) then
                                        -- Plot dots for the corresponding spike
                                        o_color <= C_YELLOW;
                                    end if;
                                else
                                    if mem_column_current(shifted_vcounter) = '1'
                                     or (i_bigger_dots = '1'
                                      and (mem_column_before(shifted_vcounter) = '1'
                                       or i_mem_rd_data(shifted_vcounter) = '1'
                                       or (shifted_vcounter > 0        and mem_column_current(shifted_vcounter-1) = '1')
                                       or (shifted_vcounter < C_MAX_ID and mem_column_current(shifted_vcounter+1) = '1'))) then
                                        -- Plot dots for the corresponding spike
                                        o_color <= C_YELLOW;
                                    end if;
                                end if;
                            end if;
                        end if;
                    else
                        o_mem_rd_en <= '0';
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
