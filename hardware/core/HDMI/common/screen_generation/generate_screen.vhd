----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/15/2021 07:35:40 PM
-- Design Name: 
-- Module Name: generate_screen - Behavioral
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
    use work.plot_pkg.ALL;
    use work.neurons_pkg.ALL;
    use work.character_definition_pkg.ALL;


entity generate_screen is
    port (
        i_clk                : in STD_LOGIC;
        i_rst                : in STD_LOGIC;
        i_current_timestamp  : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        i_hcounter           : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter           : in STD_LOGIC_VECTOR(11 downto 0);
        i_spikes_mem_rd_data : in STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
        i_analog_mem_rd_data : in STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
        i_extend_vaxis       : in STD_LOGIC;
        i_transfer_done      : in STD_LOGIC;
        i_npos_hdmi_mon      : in STD_LOGIC_VECTOR(C_LENGTH_SELECTED_NEURONS_INFO-1 downto 0);
        
        o_hcounter           : out STD_LOGIC_VECTOR(11 downto 0);
        o_vcounter           : out STD_LOGIC_VECTOR(11 downto 0);
        o_spikes_mem_rd_en   : out STD_LOGIC;
        o_spikes_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
        o_analog_mem_rd_en   : out STD_LOGIC;
        o_analog_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
        o_color              : out STD_LOGIC_VECTOR(23 downto 0);
        o_end_screen         : out STD_LOGIC
    );
end generate_screen;


architecture Behavioral of generate_screen is
    
    component write_info
        port (
            i_clk      : in STD_LOGIC;
            i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_board_pixel : out BOOLEAN;
            o_text_pixel  : out BOOLEAN;
            o_val_pixel   : out BOOLEAN
        );
    end component;
    
    component write_time
        port (
            i_clk               : in STD_LOGIC;
            i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            
            o_time_label_pixel : out BOOLEAN;
            o_time_pixel       : out BOOLEAN;
            o_time_val_pixel   : out BOOLEAN
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component raster_plot
        generic (
            G_NB_NEURONS : INTEGER
        );
        port (
            i_clk               : in STD_LOGIC;
            i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_mem_rd_data       : in STD_LOGIC_VECTOR(G_NB_NEURONS-1 downto 0);
            i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            i_pointer0          : in STD_LOGIC_VECTOR(9 downto 0);
            
            o_mem_rd_en         : out STD_LOGIC;
            o_mem_rd_addr       : out STD_LOGIC_VECTOR(9 downto 0);
            o_dot_pixel         : out BOOLEAN;
            o_contours_pixel    : out BOOLEAN;
            o_axes_label_pixel  : out BOOLEAN;
            o_ticks_label_pixel : out BOOLEAN
        );
    end component;
    
    component raster_plot_ext
        generic (
            G_NB_NEURONS : INTEGER
        );
        port (
            i_clk               : in STD_LOGIC;
            i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_mem_rd_data       : in STD_LOGIC_VECTOR(G_NB_NEURONS-1 downto 0);
            i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            i_pointer0          : in STD_LOGIC_VECTOR(9 downto 0);
            
            o_mem_rd_en         : out STD_LOGIC;
            o_mem_rd_addr       : out STD_LOGIC_VECTOR(9 downto 0);
            o_dot_pixel         : out BOOLEAN;
            o_contours_pixel    : out BOOLEAN;
            o_axes_label_pixel  : out BOOLEAN;
            o_ticks_label_pixel : out BOOLEAN
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component membrane_potential_plot
        port (
            i_clk               : in STD_LOGIC;
            i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
            i_mem_rd_data       : in STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
            i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            i_pointer0          : in STD_LOGIC_VECTOR(9 downto 0);
            i_npos_hdmi_mon     : in STD_LOGIC_VECTOR(C_LENGTH_SELECTED_NEURONS_INFO-1 downto 0);
            
            o_mem_rd_en               : out STD_LOGIC;
            o_mem_rd_addr             : out STD_LOGIC_VECTOR(9 downto 0);
            o_dot_pixel               : out T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
            o_contours_pixel          : out BOOLEAN;
            o_axes_label_pixel        : out BOOLEAN;
            o_h_ticks_label_pixel     : out BOOLEAN;
            o_v_ticks_label_pixel     : out T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
            o_sel_neurons_text_pixel  : out BOOLEAN;
            o_sel_neurons_value_pixel : out T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    -- Time-related signals, they update only once per display
    signal pointer0               : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');  -- pointer in the memory to the oldest timestamp
    signal plot_current_timestamp : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0) := (others => '0');  -- current timestamp that updates only once per display
    
    signal last_transfer_done : STD_LOGIC;
    
    -- Signals to extend vertical axis by a factor of 4
    signal plot_extend_vaxis : STD_LOGIC;
    
    -- Write information
    signal board_name_pixel : BOOLEAN;
    signal info_pixel       : BOOLEAN;
    signal info_val_pixel   : BOOLEAN;
    
    -- Write current time
    signal time_label_pixel : BOOLEAN;
    signal time_pixel       : BOOLEAN;
    signal time_val_pixel   : BOOLEAN;
    
    -- Raster plot
    signal raster_mem_rd_en         : STD_LOGIC;
    signal raster_mem_rd_addr       : STD_LOGIC_VECTOR(9 downto 0);
    signal raster_dot_pixel         : BOOLEAN;
    signal raster_contours_pixel    : BOOLEAN;
    signal raster_axes_label_pixel  : BOOLEAN;
    signal raster_ticks_label_pixel : BOOLEAN;
    
    signal raster_ext_mem_rd_en         : STD_LOGIC;
    signal raster_ext_mem_rd_addr       : STD_LOGIC_VECTOR(9 downto 0);
    signal raster_ext_dot_pixel         : BOOLEAN;
    signal raster_ext_contours_pixel    : BOOLEAN;
    signal raster_ext_axes_label_pixel  : BOOLEAN;
    signal raster_ext_ticks_label_pixel : BOOLEAN;
    
    -- Analog values plot: membrane potential
    signal analog_dot_pixel           : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    signal analog_contours_pixel      : BOOLEAN;
    signal analog_axes_label_pixel    : BOOLEAN;
    signal analog_h_ticks_label_pixel : BOOLEAN;
    signal analog_v_ticks_label_pixel : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    signal sel_neurons_text_pixel     : BOOLEAN;
    signal sel_neurons_value_pixel    : T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1);
    
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
    
    o_spikes_mem_rd_en <= raster_mem_rd_en when plot_extend_vaxis = '0'
                     else raster_ext_mem_rd_en;
    
    o_spikes_mem_rd_addr <= raster_mem_rd_addr when plot_extend_vaxis = '0'
                       else raster_ext_mem_rd_addr;
    
    raster_plot_inst_small_plot : raster_plot
        generic map (
            G_NB_NEURONS => C_SMALL_RANGE_ID
        )
        port map (
            i_clk               => i_clk,
            i_hcounter          => i_hcounter,
            i_vcounter          => i_vcounter,
            i_mem_rd_data       => i_spikes_mem_rd_data(C_SMALL_RANGE_ID-1 downto 0),
            i_current_timestamp => plot_current_timestamp,
            i_pointer0          => pointer0,
            
            o_mem_rd_en         => raster_mem_rd_en,
            o_mem_rd_addr       => raster_mem_rd_addr,
            o_dot_pixel         => raster_dot_pixel,
            o_contours_pixel    => raster_contours_pixel,
            o_axes_label_pixel  => raster_axes_label_pixel,
            o_ticks_label_pixel => raster_ticks_label_pixel
        );
    
    small_range_ext : if C_EXT_RANGE_ID <= C_RANGE_ID_SMALL_PLOT generate
        
        raster_plot_ext_inst : raster_plot_ext
            generic map (
                G_NB_NEURONS => C_EXT_RANGE_ID
            )
            port map (
                i_clk               => i_clk,
                i_hcounter          => i_hcounter,
                i_vcounter          => i_vcounter,
                i_mem_rd_data       => i_spikes_mem_rd_data(C_EXT_RANGE_ID-1 downto 0),
                i_current_timestamp => plot_current_timestamp,
                i_pointer0          => pointer0,
                
                o_mem_rd_en         => raster_ext_mem_rd_en,
                o_mem_rd_addr       => raster_ext_mem_rd_addr,
                o_dot_pixel         => raster_ext_dot_pixel,
                o_contours_pixel    => raster_ext_contours_pixel,
                o_axes_label_pixel  => raster_ext_axes_label_pixel,
                o_ticks_label_pixel => raster_ext_ticks_label_pixel
            );
        
    end generate;
    
    extended_range : if C_EXT_RANGE_ID > C_RANGE_ID_SMALL_PLOT generate
        
        raster_plot_inst_ext : raster_plot
            generic map (
                G_NB_NEURONS => C_EXT_RANGE_ID
            )
            port map (
                i_clk               => i_clk,
                i_hcounter          => i_hcounter,
                i_vcounter          => i_vcounter,
                i_mem_rd_data       => i_spikes_mem_rd_data(C_EXT_RANGE_ID-1 downto 0),
                i_current_timestamp => plot_current_timestamp,
                i_pointer0          => pointer0,
                
                o_mem_rd_en         => raster_ext_mem_rd_en,
                o_mem_rd_addr       => raster_ext_mem_rd_addr,
                o_dot_pixel         => raster_ext_dot_pixel,
                o_contours_pixel    => raster_ext_contours_pixel,
                o_axes_label_pixel  => raster_ext_axes_label_pixel,
                o_ticks_label_pixel => raster_ext_ticks_label_pixel
            );
        
    end generate;
    
    -----------------------------------------------------------------------------------
    
    membrane_potential_plot_inst : membrane_potential_plot
        port map (
            i_clk               => i_clk,
            i_hcounter          => i_hcounter,
            i_vcounter          => i_vcounter,
            i_mem_rd_data       => i_analog_mem_rd_data,
            i_current_timestamp => plot_current_timestamp,
            i_pointer0          => pointer0,
            i_npos_hdmi_mon     => i_npos_hdmi_mon,
            
            o_mem_rd_en               => o_analog_mem_rd_en,
            o_mem_rd_addr             => o_analog_mem_rd_addr,
            o_dot_pixel               => analog_dot_pixel,
            o_contours_pixel          => analog_contours_pixel,
            o_axes_label_pixel        => analog_axes_label_pixel,
            o_h_ticks_label_pixel     => analog_h_ticks_label_pixel,
            o_v_ticks_label_pixel     => analog_v_ticks_label_pixel,
            o_sel_neurons_text_pixel  => sel_neurons_text_pixel,
            o_sel_neurons_value_pixel => sel_neurons_value_pixel
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
            
            if i_rst = '1' then
                plot_current_timestamp <= (others => '0');
                pointer0               <= (others => '0');
                o_end_screen           <= '0';
            else
                if last_transfer_done = '0' and i_transfer_done = '1' then  -- rising edge
                    plot_current_timestamp <= i_current_timestamp;
                    if i_current_timestamp(i_current_timestamp'high downto pointer0'high+1) = 0 then  -- the memory has not been written fully
                        pointer0 <= (others => '0');
                    else
                        pointer0 <= i_current_timestamp(pointer0'high downto 0) + 1;
                    end if;
                end if;
                
                if i_hcounter = 0 and i_vcounter = 0 then
                    -- Initialization
                    plot_extend_vaxis <= i_extend_vaxis;
                    o_end_screen      <= '0';
                end if;
                
                if i_hcounter = C_H_VISIBLE and i_vcounter = C_V_VISIBLE then
                    -- End of visible screen
                    o_end_screen <= '1';
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
            
            -- Write board name
            if board_name_pixel then
                o_color <= C_BLUE;
            end if;
            -- Write information
            if info_pixel then
                o_color <= C_BLACK;
            end if;
            -- Write information values
            if info_val_pixel then
                o_color <= C_RED;
            end if;
            
            -- Write current time
            if time_label_pixel then
                o_color <= C_BLACK;
            end if;
            if time_pixel then
                o_color <= C_BLACK;
            end if;
            if time_val_pixel then
                o_color <= C_BLUE;
            end if;
            
            if plot_extend_vaxis = '0' then
                
                -- Raster plot
                if raster_dot_pixel then
                    o_color <= C_BLUE;
                end if;
                if raster_contours_pixel then
                    o_color <= C_BLACK;
                end if;
                if raster_axes_label_pixel then
                    o_color <= C_BLACK;
                end if;
                if raster_ticks_label_pixel then
                    o_color <= C_BLACK;
                end if;
                
                -- Analog values plot
                for i in 0 to C_NB_NEURONS_ANALOG-1 loop
                    if analog_dot_pixel(i) or sel_neurons_value_pixel(i) then
                        o_color <= C_ANALOG_PLOT_COLORS(i);
                    end if;
                end loop;
                if analog_contours_pixel or sel_neurons_text_pixel then
                    o_color <= C_BLACK;
                end if;
                if analog_axes_label_pixel then
                    o_color <= C_BLACK;
                end if;
                if analog_h_ticks_label_pixel then
                    o_color <= C_BLACK;
                end if;
                for i in 0 to C_NB_NEURONS_ANALOG-1 loop
                    if analog_v_ticks_label_pixel(i) then
                        o_color <= C_ANALOG_PLOT_COLORS(i);
                    end if;
                end loop;
                
            else
                
                -- Raster plot
                if raster_ext_dot_pixel then
                    o_color <= C_BLUE;
                end if;
                if raster_ext_contours_pixel then
                    o_color <= C_BLACK;
                end if;
                if raster_ext_axes_label_pixel then
                    o_color <= C_BLACK;
                end if;
                if raster_ext_ticks_label_pixel then
                    o_color <= C_BLACK;
                end if;
                
            end if;
            
        end if;
    end process;
    
end Behavioral;
