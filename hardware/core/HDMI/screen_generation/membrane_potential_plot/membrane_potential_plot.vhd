----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/19/2021 03:46:52 PM
-- Design Name: 
-- Module Name: membrane_potential_plot - Behavioral
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
    use work.hdmi_resolution_pkg.ALL;
    use work.neurons_pkg.ALL;


entity membrane_potential_plot is
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
end membrane_potential_plot;


architecture Behavioral of membrane_potential_plot is
    
    component write_selected_neurons
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
    end component;
    
    component plot_contours
        generic (
            G_NB_V_POINTS : INTEGER;
            G_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0);
            G_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0);
            
            G_RANGE_VCNT1 : INTEGER;
            G_RANGE_VCNT2 : INTEGER;
            G_RANGE_VCNT3 : INTEGER
        );
        port (
            i_clk        : in STD_LOGIC;
            i_hcounter   : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter   : in STD_LOGIC_VECTOR(11 downto 0);
            i_plot_ext   : in BOOLEAN;
            i_in_between : in BOOLEAN;
            
            o_contours_pixel : out BOOLEAN
        );
    end component;
            
    component write_axes_and_ticks_label_analog
        generic (
            G_V_UP_LIMIT_ALL  : STD_LOGIC_VECTOR(11 downto 0);
            G_V_LOW_LIMIT_ALL : STD_LOGIC_VECTOR(11 downto 0);
            G_V_LOW_LIMIT_1   : STD_LOGIC_VECTOR(11 downto 0)
        );
        port (
            i_clk      : in STD_LOGIC;
            i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_axes_label_pixel    : out BOOLEAN;
            o_h_ticks_label_pixel : out BOOLEAN;
            o_v_ticks_label_pixel : out T_BOOLEAN_ARRAY(0 to C_NB_NEURONS_ANALOG-1)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    constant C_V_NB_POINTS : INTEGER := C_ANALOG_PLOT_RANGE * C_NB_NEURONS_ANALOG + 2 * (C_NB_NEURONS_ANALOG-1);  -- 720 + 6 = 726
    
    constant C_V_LOW_LIMIT_ALL : STD_LOGIC_VECTOR(11 downto 0) := C_V_VISIBLE - C_OFFSET;
    constant C_V_UP_LIMIT_ALL  : STD_LOGIC_VECTOR(11 downto 0) := C_V_LOW_LIMIT_ALL - C_V_NB_POINTS;
    constant C_V_LOW_LIMIT_1   : STD_LOGIC_VECTOR(11 downto 0) := C_V_UP_LIMIT_ALL + C_ANALOG_PLOT_RANGE;
    
    -----------------------------------------------------------------------------------
    
    constant C_RANGE_VCNT1 : INTEGER := C_ANALOG_PLOT_RANGE/10;  -- vertical tick every  5 mV
    constant C_RANGE_VCNT2 : INTEGER := 5;                       -- vertical tick every 25 mV
    constant C_RANGE_VCNT3 : INTEGER := 1;                       -- vertical tick every 25 mV
    
    -----------------------------------------------------------------------------------
    
    -- Signal that converts the vertical position to the correspondant analog plot value
    signal plot_cnt         : INTEGER range 0 to C_NB_NEURONS_ANALOG-1;
    signal shifted_vcounter : INTEGER range 0 to C_ANALOG_PLOT_RANGE-1;
    signal space_between    : INTEGER range 0 to 2;
    signal in_vplot         : BOOLEAN;
    signal in_between       : BOOLEAN;
    
    -- Signal of the current memory address to read
    signal mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Signals to have dots as a '+' of 3-pixel diameter
    signal mem_column_before  : STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);  -- the column of analog values corresponding to the previous timestamp
    signal mem_column_current : STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);  -- the column of analog values corresponding to the current timestamp
    -- the column that corresponds to the next timestamp is the input i_mem_rd_data
    
begin
    
    write_selected_neurons_inst : write_selected_neurons
        generic map (
            G_V_UP_LIMIT_ALL => C_V_UP_LIMIT_ALL
        )
        port map (
            i_clk           => i_clk,
            i_hcounter      => i_hcounter,
            i_vcounter      => i_vcounter,
            i_npos_hdmi_mon => i_npos_hdmi_mon,
            
            o_text_pixel  => o_sel_neurons_text_pixel,
            o_value_pixel => o_sel_neurons_value_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    in_between <= (space_between > 0)
            and (i_vcounter <= C_V_LOW_LIMIT_ALL and i_vcounter > C_V_UP_LIMIT_ALL);
    
    plot_contours_inst : plot_contours
        generic map (
            G_NB_V_POINTS => C_ANALOG_PLOT_RANGE,
            G_V_UP_LIMIT  => C_V_UP_LIMIT_ALL,
            G_V_LOW_LIMIT => C_V_LOW_LIMIT_ALL,
            
            G_RANGE_VCNT1 => C_RANGE_VCNT1,
            G_RANGE_VCNT2 => C_RANGE_VCNT2,
            G_RANGE_VCNT3 => C_RANGE_VCNT3
        )
        port map (
            i_clk        => i_clk,
            i_hcounter   => i_hcounter,
            i_vcounter   => i_vcounter,
            i_plot_ext   => True,
            i_in_between => in_between,
            
            o_contours_pixel => o_contours_pixel
        );
    
    write_axes_and_ticks_label_analog_inst : write_axes_and_ticks_label_analog
        generic map (
            G_V_UP_LIMIT_ALL  => C_V_UP_LIMIT_ALL,
            G_V_LOW_LIMIT_ALL => C_V_LOW_LIMIT_ALL,
            G_V_LOW_LIMIT_1   => C_V_LOW_LIMIT_1
        )
        port map (
            i_clk      => i_clk,
            i_hcounter => i_hcounter,
            i_vcounter => i_vcounter,
            
            o_axes_label_pixel    => o_axes_label_pixel,
            o_h_ticks_label_pixel => o_h_ticks_label_pixel,
            o_v_ticks_label_pixel => o_v_ticks_label_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    in_vplot <= (space_between = 0)
            and (i_vcounter <= C_V_LOW_LIMIT_ALL and i_vcounter > C_V_UP_LIMIT_ALL);
    
    shifted_vcounters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_hcounter = 0 then
                
                if i_vcounter = C_V_UP_LIMIT_ALL+1 then
                    
                    plot_cnt         <= 0;
                    shifted_vcounter <= C_ANALOG_PLOT_RANGE-1;
                    space_between    <= 0;
                    
                elsif i_vcounter <= C_V_LOW_LIMIT_ALL and i_vcounter > C_V_UP_LIMIT_ALL+1 then
                    
                    if shifted_vcounter = 0 then
                        shifted_vcounter <= C_ANALOG_PLOT_RANGE-1;
                        space_between    <= 2;
                        plot_cnt         <= plot_cnt + 1;
                    elsif space_between > 0 then
                        space_between <= space_between-1;
                    else
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
            
            if in_vplot then
                -- we need three time periods before reading from the memory
                if i_hcounter = C_H_LOW_LIMIT - 4 then
                    o_mem_rd_en <= '1';
                    mem_rd_addr <= i_pointer0;
                elsif i_hcounter > C_H_LOW_LIMIT - 4 and i_hcounter < C_H_UP_LIMIT then
                    if mem_rd_addr + 1 /= i_pointer0 then
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
            
            if in_vplot then
                if i_hcounter = C_H_LOW_LIMIT - 1 then
                    mem_column_before  <= i_mem_rd_data;
                    mem_column_current <= i_mem_rd_data;
                elsif i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                    mem_column_before  <= mem_column_current;
                    mem_column_current <= i_mem_rd_data;
                end if;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    color_proc : process(i_clk)
        
        variable analog_value_before  : STD_LOGIC_VECTOR(C_ANALOG_PLOT_VALUE_SIZE-1 downto 0);
        variable analog_value_current : STD_LOGIC_VECTOR(C_ANALOG_PLOT_VALUE_SIZE-1 downto 0);
        
    begin
        if rising_edge(i_clk) then
            
            -- Inside the plot
            o_dot_pixel <= (others => False);
            
            if in_vplot and i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                
                -- Plot the analog value
                if i_current_timestamp(31 downto 10) /= 0 or i_current_timestamp >= i_hcounter-C_H_LOW_LIMIT then
                    
                    analog_value_before  := mem_column_before(C_ANALOG_PLOT_VALUE_SIZE*(plot_cnt+1)-1 downto C_ANALOG_PLOT_VALUE_SIZE*plot_cnt);
                    analog_value_current := mem_column_current(C_ANALOG_PLOT_VALUE_SIZE*(plot_cnt+1)-1 downto C_ANALOG_PLOT_VALUE_SIZE*plot_cnt);
                    
                    if analog_value_current < analog_value_before then
                        if analog_value_current <= shifted_vcounter
                         and analog_value_before >= shifted_vcounter then
                            o_dot_pixel(plot_cnt) <= True;
                        end if;
                    else
                        if analog_value_current >= shifted_vcounter
                         and analog_value_before <= shifted_vcounter then
                            o_dot_pixel(plot_cnt) <= True;
                        end if;
                    end if;
                    
                end if;
                
            end if;
            
        end if;
    end process;
    
end Behavioral;
