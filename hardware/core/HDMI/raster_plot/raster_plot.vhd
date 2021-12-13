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

library work;
    use work.hdmi_resolution_pkg.ALL;
    use work.raster_plot_pkg.ALL;
    use work.events_list_pkg.ALL;


entity raster_plot is
    port (
        i_clk               : in STD_LOGIC;
        i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
        i_mem_rd_data       : in STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
        i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        i_extend_vaxis      : in STD_LOGIC;
        i_transfer_done     : in STD_LOGIC;
        
        o_hcounter    : out STD_LOGIC_VECTOR(11 downto 0);
        o_vcounter    : out STD_LOGIC_VECTOR(11 downto 0);
        o_mem_rd_en   : out STD_LOGIC;
        o_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
        o_color       : out STD_LOGIC_VECTOR(23 downto 0);
        o_end_screen  : out STD_LOGIC
    );
end raster_plot;


architecture Behavioral of raster_plot is
    
    component write_info
        port (
            i_clk      : in STD_LOGIC;
            i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_board_pixel : out STD_LOGIC;
            o_text_pixel  : out STD_LOGIC;
            o_val_pixel   : out STD_LOGIC
        );
    end component;
    
    component write_axes
        port (
            i_clk          : in STD_LOGIC;
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_extend_vaxis : in STD_LOGIC;
            
            o_h_tick_pixel  : out STD_LOGIC;
            o_v_tick_pixel  : out STD_LOGIC;
            o_h_label_pixel : out STD_LOGIC;
            o_v_label_pixel : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component plot_axes_ticks
        port (
            i_clk          : in STD_LOGIC;
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter_ext : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_hcnt1 : out INTEGER range 0 to C_RANGE_HCNT1-1;
            o_hcnt2 : out INTEGER range 0 to C_RANGE_HCNT2-1;
            o_hcnt3 : out INTEGER range 0 to C_RANGE_HCNT3-1;
            o_vcnt1 : out INTEGER range 0 to C_RANGE_VCNT1-1;
            o_vcnt2 : out INTEGER range 0 to C_RANGE_VCNT2-1;
            o_vcnt3 : out INTEGER range 0 to C_RANGE_VCNT3-1
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component write_time
        port (
            i_clk               : in STD_LOGIC;
            i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            
            o_time_label_pixel : out STD_LOGIC;
            o_time_pixel       : out STD_LOGIC;
            o_time_val_pixel   : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    -- Definition of the colors
    constant C_BLACK   : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    constant C_GREY    : STD_LOGIC_VECTOR(23 downto 0) := x"222222";
    constant C_RED     : STD_LOGIC_VECTOR(23 downto 0) := x"FF0000";
    constant C_ORANGE  : STD_LOGIC_VECTOR(23 downto 0) := x"CC8800";
    constant C_YELLOW  : STD_LOGIC_VECTOR(23 downto 0) := x"FFFF00";
    constant C_GREEN   : STD_LOGIC_VECTOR(23 downto 0) := x"00FF00";
    constant C_CYAN    : STD_LOGIC_VECTOR(23 downto 0) := x"00FFFF";
    constant C_BLUE    : STD_LOGIC_VECTOR(23 downto 0) := x"0000FF";
    constant C_MAGENTA : STD_LOGIC_VECTOR(23 downto 0) := x"FF00FF";
    constant C_WHITE   : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
    
    -----------------------------------------------------------------------------------
    
    -- Time-related signals, they update only once per display
    signal pointer0          : STD_LOGIC_VECTOR(9 downto 0);   -- pointer in the memory to the oldest timestamp
    signal current_timestamp : STD_LOGIC_VECTOR(31 downto 0);  -- current timestamp that updates only once per display
    
    -- Signal that converts the vertical position to the correspondant neuron ID
    signal shifted_vcounter : INTEGER range 0 to C_RANGE_ID-1;
    
    -- Signals to extend vertical axis by a factor of 4
    signal extend_vaxis  : STD_LOGIC;
    signal intermed_vcnt : STD_LOGIC_VECTOR(1 downto 0);
    signal vcounter_ext  : STD_LOGIC_VECTOR(11 downto 0);
    
    -- Signal of the current memory address to read
    signal mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Signals to increase dots size from one pixel to a cross of 3-pixel diameter
    signal mem_column_before  : STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);  -- the column of C_RANGE_ID range corresponding to the previous timestamp
    signal mem_column_current : STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);  -- the column of C_RANGE_ID range corresponding to the current timestamp
    -- the column that corresponds to the next timestamp is the input i_mem_rd_data
    
    signal last_transfer_done : STD_LOGIC;
    
    -----------------------------------------------------------------------------------
    
    -- Signals to draw ticks on the horizontal axis
    signal hcnt1 : INTEGER range 0 to C_RANGE_HCNT1-1;
    signal hcnt2 : INTEGER range 0 to C_RANGE_HCNT2-1;
    signal hcnt3 : INTEGER range 0 to C_RANGE_HCNT3-1;
    -- Signals to draw ticks on the vertical axis
    signal vcnt1 : INTEGER range 0 to C_RANGE_VCNT1-1;
    signal vcnt2 : INTEGER range 0 to C_RANGE_VCNT2-1;
    signal vcnt3 : INTEGER range 0 to C_RANGE_VCNT3-1;
    
    -----------------------------------------------------------------------------------
    
    -- Write information
    signal board_name_pixel : STD_LOGIC;
    signal info_pixel       : STD_LOGIC;
    signal info_val_pixel   : STD_LOGIC;
    
    -- Write ticks labels and axes labels
    signal h_tick_pixel  : STD_LOGIC;
    signal v_tick_pixel  : STD_LOGIC;
    signal h_label_pixel : STD_LOGIC;
    signal v_label_pixel : STD_LOGIC;
    
    -- Write current time
    signal time_label_pixel : STD_LOGIC;
    signal time_pixel       : STD_LOGIC;
    signal time_val_pixel   : STD_LOGIC;
    
begin
    
    write_info_inst : write_info
        port map (
            i_clk      => i_clk,
            i_hcounter => i_hcounter,
            i_vcounter => i_vcounter,
            
            o_board_pixel => board_name_pixel,
            o_text_pixel  => info_pixel,
            o_val_pixel   => info_val_pixel
        );
    
    write_axes_inst : write_axes
        port map (
            i_clk          => i_clk,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            i_extend_vaxis => extend_vaxis,
            
            o_h_tick_pixel  => h_tick_pixel,
            o_v_tick_pixel  => v_tick_pixel,
            o_h_label_pixel => h_label_pixel,
            o_v_label_pixel => v_label_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    plot_axes_ticks_inst : plot_axes_ticks
        port map (
            i_clk          => i_clk,
            i_hcounter     => i_hcounter,
            i_vcounter_ext => vcounter_ext,
            
            o_hcnt1 => hcnt1,
            o_hcnt2 => hcnt2,
            o_hcnt3 => hcnt3,
            o_vcnt1 => vcnt1,
            o_vcnt2 => vcnt2,
            o_vcnt3 => vcnt3
        );
    
    write_time_inst : write_time
        port map (
            i_clk               => i_clk,
            i_hcounter          => i_hcounter,
            i_vcounter          => i_vcounter,
            i_current_timestamp => i_current_timestamp,
            
            o_time_label_pixel => time_label_pixel,
            o_time_pixel       => time_pixel,
            o_time_val_pixel   => time_val_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    counter_latch_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_hcounter <= i_hcounter;
            o_vcounter <= i_vcounter;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    update_timestamp_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            last_transfer_done <= i_transfer_done;
            if last_transfer_done = '0' and i_transfer_done = '1' then  -- rising edge
                current_timestamp <= i_current_timestamp;
                if i_current_timestamp(31 downto 10) = 0 then  -- the memory has not been written fully
                    pointer0 <= (others => '0');
                else
                    pointer0 <= i_current_timestamp(pointer0'high downto 0) + 1;
                end if;
            end if;
            
            if i_hcounter = 0 and i_vcounter = 0 then
                -- Initialization
                o_end_screen <= '0';
                if i_current_timestamp = 0 then
                    current_timestamp <= (others => '0');
                    pointer0   <= (others => '0');
                end if;
            elsif i_hcounter = C_H_VISIBLE and i_vcounter = C_V_VISIBLE then
                -- End of visible screen
                o_end_screen <= '1';
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    shifted_vcounters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_hcounter = 0 then
                if i_vcounter = 0 then
                    -- Initialization
                    extend_vaxis     <= i_extend_vaxis;
                    vcounter_ext     <= (others => '0');
                    shifted_vcounter <= C_NB_V_POINTS-1;
                    intermed_vcnt    <= (others => '0');
                elsif vcounter_ext > C_V_LOW_LIMIT or vcounter_ext <= C_V_UP_LIMIT then
                    vcounter_ext <= vcounter_ext + 1;
                else
                    if extend_vaxis = '1' then
                        intermed_vcnt <= intermed_vcnt + 1;  -- counter of 4
                        if intermed_vcnt = "11" then
                            vcounter_ext     <= vcounter_ext + 1;
                            shifted_vcounter <= shifted_vcounter - 1;
                        end if;
                    else
                        vcounter_ext     <= vcounter_ext + 1;
                        shifted_vcounter <= shifted_vcounter - 1;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    o_mem_rd_addr <= mem_rd_addr;
    memory_en_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if vcounter_ext <= C_V_LOW_LIMIT and vcounter_ext > C_V_UP_LIMIT then
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
            
            if vcounter_ext <= C_V_LOW_LIMIT and vcounter_ext > C_V_UP_LIMIT then
                if i_hcounter = C_H_LOW_LIMIT - 1 then
                    mem_column_before  <= (others => '0');
                    mem_column_current <= i_mem_rd_data;
                end if;
                if i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                    mem_column_before  <= mem_column_current;
                    mem_column_current <= i_mem_rd_data;
                end if;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    color_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            -- White background
            o_color <= C_WHITE;
            
            -- Plot contours
            if vcounter_ext <= C_V_LOW_LIMIT+2 and vcounter_ext > C_V_UP_LIMIT-2 then
                if (i_hcounter < C_H_LOW_LIMIT and i_hcounter >= C_H_LOW_LIMIT-2)
                 or (i_hcounter >= C_H_UP_LIMIT and i_hcounter < C_H_UP_LIMIT+2) then
                    o_color <= C_BLACK;
                end if;
            end if;
            if i_hcounter >= C_H_LOW_LIMIT-2 and i_hcounter < C_H_UP_LIMIT+2 then
                if (vcounter_ext > C_V_LOW_LIMIT and vcounter_ext <= C_V_LOW_LIMIT+2)
                 or (vcounter_ext <= C_V_UP_LIMIT and vcounter_ext > C_V_UP_LIMIT-2) then
                    o_color <= C_BLACK;
                end if;
            end if;
            
            -- Ticks on haxis
            if i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                if (vcounter_ext <= C_V_LOW_LIMIT+11 and vcounter_ext > C_V_LOW_LIMIT+8)
                 or (vcounter_ext > C_V_UP_LIMIT-11 and vcounter_ext <= C_V_UP_LIMIT-8) then
                    if hcnt1 = 0 and hcnt2 = 0 and hcnt3 = 0 then
                        o_color <= C_BLACK;
                    end if;
                end if;
                if (vcounter_ext <= C_V_LOW_LIMIT+8 and vcounter_ext > C_V_LOW_LIMIT+5)
                 or (vcounter_ext > C_V_UP_LIMIT-8 and vcounter_ext <= C_V_UP_LIMIT-5) then
                    if hcnt1 = 0 and hcnt2 = 0 then
                        o_color <= C_BLACK;
                    end if;
                end if;
                if (vcounter_ext <= C_V_LOW_LIMIT+5 and vcounter_ext > C_V_LOW_LIMIT+2)
                 or (vcounter_ext > C_V_UP_LIMIT-5 and vcounter_ext <= C_V_UP_LIMIT-2) then
                    if hcnt1 = 0 then
                        o_color <= C_BLACK;
                    end if;
                end if;
            end if;
            -- Ticks on vaxis
            if vcounter_ext <= C_V_LOW_LIMIT and vcounter_ext > C_V_UP_LIMIT then
                if extend_vaxis = '0' or intermed_vcnt = "10" then
                    if (i_hcounter >= C_H_LOW_LIMIT-11 and i_hcounter < C_H_LOW_LIMIT-8)
                     or (i_hcounter < C_H_UP_LIMIT+11 and i_hcounter >= C_H_UP_LIMIT+8) then
                        if vcnt1 = 0 and vcnt2 = 0 and vcnt3 = 0 then
                            o_color <= C_BLACK;
                        end if;
                    end if;
                    if (i_hcounter >= C_H_LOW_LIMIT-8 and i_hcounter < C_H_LOW_LIMIT-5)
                     or (i_hcounter < C_H_UP_LIMIT+8 and i_hcounter >= C_H_UP_LIMIT+5) then
                        if vcnt1 = 0 and vcnt2 = 0 then
                            o_color <= C_BLACK;
                        end if;
                    end if;
                    if (i_hcounter >= C_H_LOW_LIMIT-5 and i_hcounter < C_H_LOW_LIMIT-2)
                     or (i_hcounter < C_H_UP_LIMIT+5 and i_hcounter >= C_H_UP_LIMIT+2) then
                        if vcnt1 = 0 then
                            o_color <= C_BLACK;
                        end if;
                    end if;
                end if;
            end if;
            
            -- Inside the plot
            if vcounter_ext <= C_V_LOW_LIMIT and vcounter_ext > C_V_UP_LIMIT
             and i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                -- White background inside the plot
                o_color <= C_WHITE;
                
                -- Plot dots for the corresponding spike (+ shape)
                --     Middle, up and down points
                if current_timestamp(31 downto 10) /= 0 or current_timestamp >= i_hcounter-C_H_LOW_LIMIT then
                    if extend_vaxis = '1' then
                        if intermed_vcnt /= "00" and mem_column_current(shifted_vcounter) = '1' then
                            o_color <= C_BLUE;
                        end if;
                    else
                        if mem_column_current(shifted_vcounter) = '1'
                         or (shifted_vcounter > 0               and mem_column_current(shifted_vcounter-1) = '1')
                         or (shifted_vcounter < C_NB_V_POINTS-1 and mem_column_current(shifted_vcounter+1) = '1') then
                            o_color <= C_BLUE;
                        end if;
                    end if;
                end if;
                --     Left points
                if current_timestamp(31 downto 10) /= 0 or current_timestamp >= i_hcounter-C_H_LOW_LIMIT+1 then
                    if extend_vaxis = '1' then
                        if intermed_vcnt = "10" and i_mem_rd_data(shifted_vcounter) = '1' then
                            o_color <= C_BLUE;
                        end if;
                    else
                        if i_mem_rd_data(shifted_vcounter) = '1' then
                            o_color <= C_BLUE;
                        end if;
                    end if;
                end if;
                --     Right points
                if current_timestamp(31 downto 10) /= 0 or current_timestamp >= i_hcounter-C_H_LOW_LIMIT-1 then
                    if extend_vaxis = '1' then
                        if intermed_vcnt = "10" and mem_column_before(shifted_vcounter) = '1' then
                            o_color <= C_BLUE;
                        end if;
                    else
                        if mem_column_before(shifted_vcounter) = '1' then
                            o_color <= C_BLUE;
                        end if;
                    end if;
                end if;
            end if;
            
            -- Write board name
            if board_name_pixel = '1' then
                o_color <= C_BLUE;
            end if;
            -- Write information
            if info_pixel = '1' then
                o_color <= C_BLACK;
            end if;
            -- Write information values
            if info_val_pixel = '1' then
                o_color <= C_RED;
            end if;
            
            -- Write axes ticks label
            if h_tick_pixel = '1' or v_tick_pixel = '1' then
                o_color <= C_BLACK;
            end if;
            -- Write axes label
            if h_label_pixel = '1' or v_label_pixel = '1' then
                o_color <= C_BLACK;
            end if;
            
            -- Write current time
            if time_label_pixel = '1' then
                o_color <= C_BLACK;
            end if;
            if time_pixel = '1' then
                o_color <= C_BLACK;
            end if;
            if time_val_pixel = '1' then
                o_color <= C_BLUE;
            end if;
            
        end if;
    end process;
    
end Behavioral;
