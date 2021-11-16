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
        i_freeze_screen : in STD_LOGIC;
        i_hcounter      : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter      : in STD_LOGIC_VECTOR(11 downto 0);
        i_mem_rd_data   : in STD_LOGIC_VECTOR(C_MAX_ID downto 0);
        i_current_ts    : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        i_extend_vaxis  : in STD_LOGIC;
        i_transfer_done : in STD_LOGIC;
        
        o_hcounter    : out STD_LOGIC_VECTOR(11 downto 0);
        o_vcounter    : out STD_LOGIC_VECTOR(11 downto 0);
        o_mem_rd_en   : out STD_LOGIC;
        o_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
        o_color       : out STD_LOGIC_VECTOR(23 downto 0);
        o_end_screen  : out STD_LOGIC
    );
end raster_plot;


architecture Behavioral of raster_plot is
    
    -- Definition of the colors
    constant C_BLACK   : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    constant C_GREY    : STD_LOGIC_VECTOR(23 downto 0) := x"222222";
    constant C_RED     : STD_LOGIC_VECTOR(23 downto 0) := x"FF0000";
    constant C_YELLOW  : STD_LOGIC_VECTOR(23 downto 0) := x"FFFF00";
    constant C_GREEN   : STD_LOGIC_VECTOR(23 downto 0) := x"00FF00";
    constant C_CYAN    : STD_LOGIC_VECTOR(23 downto 0) := x"00FFFF";
    constant C_BLUE    : STD_LOGIC_VECTOR(23 downto 0) := x"0000FF";
    constant C_MAGENTA : STD_LOGIC_VECTOR(23 downto 0) := x"FF00FF";
    constant C_WHITE   : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
    
    -- Definition of the limits of the plot
    constant C_H_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_H_OFFSET;
    constant C_H_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT + C_NB_H_POINTS;
    -- the vertical axis is reversed with the zero being at the top
    constant C_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_V_OFFSET;
    constant C_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_V_UP_LIMIT + (C_MAX_ID + 1);
    
    -- Time-related signals, they update only once per display
    signal pointer0   : STD_LOGIC_VECTOR(9 downto 0);  -- pointer in the memory to the oldest timestamp
    signal current_ts : STD_LOGIC_VECTOR(31 downto 0);  -- current timestamp that updates only once per display
    
    -- Signal that converts the vertical position to the correspondant neuron ID
    signal shifted_vcounter : INTEGER range 0 to C_MAX_ID+1;
    
    -- Signals to extend vertical axis by a factor of 4
    signal extend_vaxis   : STD_LOGIC;
    signal intermed_vcnt  : STD_LOGIC_VECTOR(1 downto 0);
    signal neuron_id_vcnt : STD_LOGIC_VECTOR(11 downto 0);
    
    -- Signal of the current memory address to read
    signal mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Signals to increase dots size from one pixel to a cross of 3-pixel diameter
    signal mem_column_before  : STD_LOGIC_VECTOR(C_MAX_ID downto 0);  -- the column of C_MAX_ID+1 range corresponding to the previous timestamp
    signal mem_column_current : STD_LOGIC_VECTOR(C_MAX_ID downto 0);  -- the column of C_MAX_ID+1 range corresponding to the current timestamp
    -- the column that corresponds to the next timestamp is the input i_mem_rd_data
    
    signal last_transfer_done : STD_LOGIC;
    
    -- Vertical counters to draw ticks
    constant RANGE_VCNT1 : INTEGER := 10;  -- vertical tick every 10 neurons
    constant RANGE_VCNT2 : INTEGER := 5;   -- vertical tick every 50 neurons
    constant RANGE_VCNT3 : INTEGER := 2;   -- vertical tick every 100 neurons
    signal vcnt1 : INTEGER range 0 to RANGE_VCNT1-1;
    signal vcnt2 : INTEGER range 0 to RANGE_VCNT2-1;
    signal vcnt3 : INTEGER range 0 to RANGE_VCNT3-1;
    
    signal last_shifted_vcounter : INTEGER range 0 to C_MAX_ID+1;
    
begin
    
    counter_latch_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_hcounter <= i_hcounter;
            o_vcounter <= i_vcounter;
            
        end if;
    end process;
    
    update_ts_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            last_transfer_done <= i_transfer_done;
            if last_transfer_done = '0' and i_transfer_done = '1' then  -- rising edge
                current_ts <= i_current_ts;
                if i_current_ts(31 downto 10) = 0 then  -- the memory has not been written fully
                    pointer0 <= (others => '0');
                else
                    pointer0 <= i_current_ts(pointer0'high downto 0) + 1;
                end if;
            end if;
            
            if i_vcounter = 0 and i_hcounter = 0 then
                -- Initialization
                o_end_screen <= '0';
                if i_current_ts = 0 then
                    current_ts <= (others => '0');
                    pointer0   <= (others => '0');
                end if;
                
            elsif i_hcounter = C_H_VISIBLE and i_vcounter = C_V_VISIBLE then -- end of visible screen
                if i_freeze_screen = '0' then
                    o_end_screen <= '1';
                end if;
            end if;
            
        end if;
    end process;
    
    shifted_vcounters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_hcounter = 0 then
                if i_vcounter = 0 then
                    -- Initialization
                    extend_vaxis <= not(i_extend_vaxis);
                    
                    neuron_id_vcnt   <= (others => '0');
                    shifted_vcounter <= C_MAX_ID + 1;
                    intermed_vcnt    <= (others => '0');
                    
                elsif neuron_id_vcnt > C_V_LOW_LIMIT or neuron_id_vcnt <= C_V_UP_LIMIT then
                    neuron_id_vcnt <= neuron_id_vcnt + 1;
                    
                elsif neuron_id_vcnt <= C_V_LOW_LIMIT and neuron_id_vcnt > C_V_UP_LIMIT then
                    if extend_vaxis = '1' then
                        intermed_vcnt <= intermed_vcnt + 1;  -- counter from 0 to 3
                        if intermed_vcnt = "00" then
                            neuron_id_vcnt   <= neuron_id_vcnt + 1;
                            shifted_vcounter <= shifted_vcounter - 1;  -- from C_MAX_ID=199 downto 0
                        end if;
                    else
                        neuron_id_vcnt   <= neuron_id_vcnt + 1;
                        shifted_vcounter <= shifted_vcounter - 1;  -- from C_MAX_ID=199 downto 0
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
    o_mem_rd_addr <= mem_rd_addr;
    memory_en_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if neuron_id_vcnt <= C_V_LOW_LIMIT and neuron_id_vcnt > C_V_UP_LIMIT then
                -- we need three time periods before reading from the memory
                if i_hcounter = C_H_LOW_LIMIT - 4 then
                    o_mem_rd_en <= '1';
                    mem_rd_addr <= pointer0;
                elsif i_hcounter > C_H_LOW_LIMIT - 4 and i_hcounter < C_H_UP_LIMIT then
                    if mem_rd_addr + 1 /= pointer0 then
                        mem_rd_addr <= mem_rd_addr + 1;
                    end if;
                else
                    o_mem_rd_en <= '0';
                end if;
            end if;
            
        end if;
    end process;
    
    memory_read_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if neuron_id_vcnt <= C_V_LOW_LIMIT and neuron_id_vcnt > C_V_UP_LIMIT then
                if i_hcounter >= C_H_LOW_LIMIT - 4 and i_hcounter < C_H_UP_LIMIT then
                    if i_hcounter = C_H_LOW_LIMIT - 1 then
                        mem_column_before  <= (others => '0');
                        mem_column_current <= i_mem_rd_data;
                    elsif i_hcounter >= C_H_LOW_LIMIT then
                        mem_column_before  <= mem_column_current;
                        mem_column_current <= i_mem_rd_data;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
    vtick_counters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            last_shifted_vcounter <= shifted_vcounter;
            
            if shifted_vcounter = C_MAX_ID + 1 then
                vcnt1 <= 1;
                vcnt2 <= 0;
                vcnt3 <= 0;
            elsif last_shifted_vcounter /= shifted_vcounter then
                if vcnt1 < RANGE_VCNT1-1 then
                    vcnt1 <= vcnt1 + 1;
                else
                    vcnt1 <= 0;
                    if vcnt2 < RANGE_VCNT2-1 then
                        vcnt2 <= vcnt2 + 1;
                    else
                        vcnt2 <= 0;
                        if vcnt3 < RANGE_VCNT3-1 then
                            vcnt3 <= vcnt3 + 1;
                        else
                            vcnt3 <= 0;
                        end if;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
    color_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            -- Black background
            o_color <= C_BLACK;
            
            -- Plot contours
            if neuron_id_vcnt <= C_V_LOW_LIMIT+18 and neuron_id_vcnt > C_V_UP_LIMIT-18 then
                if (i_hcounter < C_H_LOW_LIMIT-2 and i_hcounter >= C_H_LOW_LIMIT-18)
                 or (i_hcounter >= C_H_UP_LIMIT+2 and i_hcounter < C_H_UP_LIMIT+18) then
                    o_color <= C_WHITE;
                end if;
            end if;
            if i_hcounter >= C_H_LOW_LIMIT-18 and i_hcounter < C_H_UP_LIMIT+18 then
                if (neuron_id_vcnt > C_V_LOW_LIMIT+2 and neuron_id_vcnt <= C_V_LOW_LIMIT+18)
                 or (neuron_id_vcnt <= C_V_UP_LIMIT-2 and neuron_id_vcnt > C_V_UP_LIMIT-18) then
                    o_color <= C_WHITE;
                end if;
            end if;
            
            -- Ticks on vaxis
            if neuron_id_vcnt <= C_V_LOW_LIMIT and neuron_id_vcnt > C_V_UP_LIMIT then
                if extend_vaxis = '0' or intermed_vcnt = "10" then
                    if (i_hcounter >= C_H_LOW_LIMIT-11 and i_hcounter < C_H_LOW_LIMIT-8)
                     or (i_hcounter < C_H_UP_LIMIT+11 and i_hcounter >= C_H_UP_LIMIT+8) then
                        if vcnt1 = 0 and vcnt2 = 0 and vcnt3 = 0 then
                            o_color <= C_BLACK;
                        end if;
                    elsif (i_hcounter >= C_H_LOW_LIMIT-8 and i_hcounter < C_H_LOW_LIMIT-5)
                     or (i_hcounter < C_H_UP_LIMIT+8 and i_hcounter >= C_H_UP_LIMIT+5) then
                        if vcnt1 = 0 and vcnt2 = 0 then
                            o_color <= C_BLACK;
                        end if;
                    elsif (i_hcounter >= C_H_LOW_LIMIT-5 and i_hcounter < C_H_LOW_LIMIT-2)
                     or (i_hcounter < C_H_UP_LIMIT+5 and i_hcounter >= C_H_UP_LIMIT+2) then
                        if vcnt1 = 0 then
                            o_color <= C_BLACK;
                        end if;
                    end if;
                end if;
            end if;
            
            -- Inside the plot
            if neuron_id_vcnt <= C_V_LOW_LIMIT and neuron_id_vcnt > C_V_UP_LIMIT
             and i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                -- White background inside the plot
                o_color <= C_WHITE;
                
                if current_ts(31 downto 10) > 0 or current_ts >= mem_rd_addr then
                    if extend_vaxis = '1' then
                        if (intermed_vcnt /= "00"  -- middle, up or down points
                          and mem_column_current(shifted_vcounter) = '1')
                         or (intermed_vcnt = "10"  -- middle point
                          and (mem_column_before(shifted_vcounter) = '1'
                           or i_mem_rd_data(shifted_vcounter) = '1')) then
                            -- Plot dots for the corresponding spike
                            o_color <= C_BLUE;
                        end if;
                    else
                        if mem_column_current(shifted_vcounter) = '1'
                         or (mem_column_before(shifted_vcounter) = '1'
                         or i_mem_rd_data(shifted_vcounter) = '1'
                         or (shifted_vcounter > 0        and mem_column_current(shifted_vcounter-1) = '1')
                         or (shifted_vcounter < C_MAX_ID and mem_column_current(shifted_vcounter+1) = '1')) then
                            -- Plot dots for the corresponding spike
                            o_color <= C_BLUE;
                        end if;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
end Behavioral;
