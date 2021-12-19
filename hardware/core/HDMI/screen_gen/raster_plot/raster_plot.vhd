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
    use work.plot_pkg.ALL;
    use work.neurons_pkg.ALL;


entity raster_plot is
    port (
        i_clk               : in STD_LOGIC;
        i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
        i_mem_rd_data       : in STD_LOGIC_VECTOR(C_RANGE_ID_SMALL_PLOT-1 downto 0);
        i_extend_vaxis      : in STD_LOGIC;
        i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        i_pointer0          : in STD_LOGIC_VECTOR(9 downto 0);
        
        o_mem_rd_en         : out STD_LOGIC;
        o_mem_rd_addr       : out STD_LOGIC_VECTOR(9 downto 0);
        o_dot_pixel         : out BOOLEAN;
        o_contours_pixel    : out BOOLEAN;
        o_axes_label_pixel  : out BOOLEAN;
        o_ticks_label_pixel : out BOOLEAN
    );
end raster_plot;


architecture Behavioral of raster_plot is
    
    component plot_contours
        port (
            i_clk           : in STD_LOGIC;
            i_hcounter      : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter_ext  : in STD_LOGIC_VECTOR(11 downto 0);
            i_extend_vaxis  : in STD_LOGIC;
            i_intermed_vcnt : in STD_LOGIC_VECTOR(1 downto 0);
            
            o_contours_pixel : out BOOLEAN
        );
    end component;
    
    component write_axes_and_ticks_label
        port (
            i_clk          : in STD_LOGIC;
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_extend_vaxis : in STD_LOGIC;
            
            o_axes_label_pixel  : out BOOLEAN;
            o_ticks_label_pixel : out BOOLEAN
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    -- Signal that converts the vertical position to the correspondant neuron ID
    signal shifted_vcounter : INTEGER range 0 to C_RANGE_ID_SMALL_PLOT-1;
    
    -- Signals to extend vertical axis by a factor of 4
    signal intermed_vcnt : STD_LOGIC_VECTOR(1 downto 0);
    signal vcounter_ext  : STD_LOGIC_VECTOR(11 downto 0);
    
    -- Signal of the current memory address to read
    signal mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Signals to increase dots size from one pixel to a cross of 3-pixel diameter
    signal mem_column_before  : STD_LOGIC_VECTOR(C_RANGE_ID_SMALL_PLOT-1 downto 0);  -- the column of neurons IDs corresponding to the previous timestamp
    signal mem_column_current : STD_LOGIC_VECTOR(C_RANGE_ID_SMALL_PLOT-1 downto 0);  -- the column of neurons IDs corresponding to the current timestamp
    -- the column that corresponds to the next timestamp is the input i_mem_rd_data
    
begin
    
    plot_contours_inst : plot_contours
        port map (
            i_clk           => i_clk,
            i_hcounter      => i_hcounter,
            i_vcounter_ext  => vcounter_ext,
            i_extend_vaxis  => i_extend_vaxis,
            i_intermed_vcnt => intermed_vcnt,
            
            o_contours_pixel => o_contours_pixel
        );
    
    write_axes_and_ticks_label_inst : write_axes_and_ticks_label
        port map (
            i_clk          => i_clk,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            i_extend_vaxis => i_extend_vaxis,
            
            o_axes_label_pixel  => o_axes_label_pixel,
            o_ticks_label_pixel => o_ticks_label_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    shifted_vcounters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_hcounter = 0 then
                if i_vcounter = 0 then
                    -- Initialization
                    vcounter_ext     <= (others => '0');
                    shifted_vcounter <= C_NB_V_POINTS-1;
                    intermed_vcnt    <= (others => '0');
                elsif vcounter_ext > C_V_LOW_LIMIT or vcounter_ext <= C_V_UP_LIMIT then
                    vcounter_ext <= vcounter_ext + 1;
                else
                    if i_extend_vaxis = '1' then
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
            
            o_dot_pixel <= False;
            
            -- Inside the plot
            if vcounter_ext <= C_V_LOW_LIMIT and vcounter_ext > C_V_UP_LIMIT
             and i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                
                -- Plot dots for the corresponding spike (+ shape)
                --     Middle, up and down points
                if i_current_timestamp(31 downto 10) /= 0 or i_current_timestamp >= i_hcounter-C_H_LOW_LIMIT then
                    if i_extend_vaxis = '1' then
                        if intermed_vcnt /= "00" and mem_column_current(shifted_vcounter) = '1' then
                            o_dot_pixel <= True;
                        end if;
                    else
                        if mem_column_current(shifted_vcounter) = '1'
                         or (shifted_vcounter > 0               and mem_column_current(shifted_vcounter-1) = '1')
                         or (shifted_vcounter < C_NB_V_POINTS-1 and mem_column_current(shifted_vcounter+1) = '1') then
                            o_dot_pixel <= True;
                        end if;
                    end if;
                end if;
                --     Left points
                if i_current_timestamp(31 downto 10) /= 0 or i_current_timestamp >= i_hcounter-C_H_LOW_LIMIT+1 then
                    if i_extend_vaxis = '1' then
                        if intermed_vcnt = "10" and i_mem_rd_data(shifted_vcounter) = '1' then
                            o_dot_pixel <= True;
                        end if;
                    else
                        if i_mem_rd_data(shifted_vcounter) = '1' then
                            o_dot_pixel <= True;
                        end if;
                    end if;
                end if;
                --     Right points
                if i_current_timestamp(31 downto 10) /= 0 or i_current_timestamp >= i_hcounter-C_H_LOW_LIMIT-1 then
                    if i_extend_vaxis = '1' then
                        if intermed_vcnt = "10" and mem_column_before(shifted_vcounter) = '1' then
                            o_dot_pixel <= True;
                        end if;
                    else
                        if mem_column_before(shifted_vcounter) = '1' then
                            o_dot_pixel <= True;
                        end if;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
end Behavioral;
