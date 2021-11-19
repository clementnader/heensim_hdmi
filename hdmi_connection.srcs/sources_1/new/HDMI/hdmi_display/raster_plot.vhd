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
    use work.hdmi_resolution.ALL;
    use work.events_list.ALL;
    use work.character_definition.ALL;


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
    
    component write_text
        generic (
           G_TEXT_LENGTH : INTEGER
        );
        port (
            i_clk          : in STD_LOGIC;
            i_display_text : in STRING(0 to G_TEXT_LENGTH-1);
            i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_pixel : out STD_LOGIC
        );
    end component;
    
    component write_text_rotated
        generic (
           G_TEXT_LENGTH : INTEGER
        );
        port (
            i_clk          : in STD_LOGIC;
            i_display_text : in STRING(0 to G_TEXT_LENGTH-1);
            i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_pixel : out STD_LOGIC
        );
    end component;
    ------------------------------------------
    
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
    
    -- Definition of the limits of the plot
    constant C_H_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_H_OFFSET;
    constant C_H_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT + C_NB_H_POINTS;
    -- the vertical axis is reversed with the zero being at the top
    constant C_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_V_OFFSET;
    constant C_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_V_UP_LIMIT + (C_MAX_ID + 1);
    
    ------------------------------------------
    
    -- Time-related signals, they update only once per display
    signal pointer0   : STD_LOGIC_VECTOR(9 downto 0);   -- pointer in the memory to the oldest timestamp
    signal current_ts : STD_LOGIC_VECTOR(31 downto 0);  -- current timestamp that updates only once per display
    
    -- Signal that converts the vertical position to the correspondant neuron ID
    signal shifted_vcounter : INTEGER range 0 to C_MAX_ID+1;
    
    -- Signals to extend vertical axis by a factor of 4
    signal extend_vaxis  : STD_LOGIC;
    signal intermed_vcnt : STD_LOGIC_VECTOR(1 downto 0);
    signal vcounter_ext  : STD_LOGIC_VECTOR(11 downto 0);
    
    constant C_V_LOW_LIMIT_EXT : STD_LOGIC_VECTOR(11 downto 0) := C_V_UP_LIMIT + (C_V_LOW_LIMIT(9 downto 0)&"00")-(C_V_UP_LIMIT(9 downto 0)&"00") - 2;
    
    -- Signal of the current memory address to read
    signal mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Signals to increase dots size from one pixel to a cross of 3-pixel diameter
    signal mem_column_before  : STD_LOGIC_VECTOR(C_MAX_ID downto 0);  -- the column of C_MAX_ID+1 range corresponding to the previous timestamp
    signal mem_column_current : STD_LOGIC_VECTOR(C_MAX_ID downto 0);  -- the column of C_MAX_ID+1 range corresponding to the current timestamp
    -- the column that corresponds to the next timestamp is the input i_mem_rd_data
    
    signal last_transfer_done : STD_LOGIC;
    
    ------------------------------------------
    
    -- Signals to draw ticks on the vertical axis
    constant RANGE_VCNT1 : INTEGER := 10;  -- vertical tick every 10 neurons
    constant RANGE_VCNT2 : INTEGER := 5;   -- vertical tick every 50 neurons
    constant RANGE_VCNT3 : INTEGER := 2;   -- vertical tick every 100 neurons
    
    signal vcnt1 : INTEGER range 0 to RANGE_VCNT1-1;
    signal vcnt2 : INTEGER range 0 to RANGE_VCNT2-1;
    signal vcnt3 : INTEGER range 0 to RANGE_VCNT3-1;
    
    signal last_shifted_vcounter : INTEGER range 0 to C_MAX_ID+1;  -- signal to know when there is a change in the shifted_vcounter value
    
    -- Signals to draw ticks on the horizontal axis
    constant RANGE_HCNT1 : INTEGER := 25;  -- horizontal tick every 25 timestamps
    constant RANGE_HCNT2 : INTEGER := 4;   -- horizontal tick every 100 timestamps
    constant RANGE_HCNT3 : INTEGER := 5;   -- horizontal tick every 500 timestamps
    
    signal hcnt1 : INTEGER range 0 to RANGE_HCNT1-1;
    signal hcnt2 : INTEGER range 0 to RANGE_HCNT2-1;
    signal hcnt3 : INTEGER range 0 to RANGE_HCNT3-1;
    
    ------------------------------------------
    
    -- Draw text
    constant C_BOARD_NAME   : STRING := "ZedBoard";
    signal board_name_pixel : STD_LOGIC;
    
    type T_LABEL_POS     is ARRAY(NATURAL range <>) of STD_LOGIC_VECTOR(11 downto 0);
    type T_STRING_ARRAY  is ARRAY(NATURAL range <>) of STRING;
    type T_INTEGER_ARRAY is ARRAY(NATURAL range <>) of INTEGER;
    
    ------------------------------------------
    
    -- Ticks label on vertical axis
    constant C_V_TICK_NAME : T_STRING_ARRAY := ("  0", " 50", "100", "150");
    
    constant C_V_TICK_VPOS     : T_LABEL_POS := (
        0 => C_V_LOW_LIMIT             - C_FONT_HEIGHT/2 + 1,  --   0
        1 => C_V_LOW_LIMIT     -  50   - C_FONT_HEIGHT/2 + 1,  --  50
        2 => C_V_LOW_LIMIT     - 100   - C_FONT_HEIGHT/2 + 1,  -- 100
        3 => C_V_LOW_LIMIT     - 150   - C_FONT_HEIGHT/2 + 1   -- 150
    );
    constant C_V_TICK_VPOS_EXT : T_LABEL_POS := (
        0 => C_V_LOW_LIMIT_EXT         - C_FONT_HEIGHT/2 - 2,  --   0
        1 => C_V_LOW_LIMIT_EXT -  50*4 - C_FONT_HEIGHT/2 - 2,  --  50
        2 => C_V_LOW_LIMIT_EXT - 100*4 - C_FONT_HEIGHT/2 - 2,  -- 100
        3 => C_V_LOW_LIMIT_EXT - 150*4 - C_FONT_HEIGHT/2 - 2   -- 150
    );
    signal v_tick_vpos : T_LABEL_POS(0 to 3);
    
    signal v_ticks_pixel : STD_LOGIC_VECTOR(0 to 3);
    
    -- Ticks label on horizontal axis
    constant C_H_TICK_NAME : T_STRING_ARRAY := ("   0", " 100", " 200", " 300", " 400",
        " 500", " 600", " 700", " 800", " 900", "1000");
    
    constant C_H_TICK_HPOS : T_LABEL_POS := (
         0 => C_H_LOW_LIMIT        - C_FONT_WIDTH*3 - C_FONT_WIDTH/2*1 - 1,  --    0
         1 => C_H_LOW_LIMIT +  100 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  100
         2 => C_H_LOW_LIMIT +  200 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  200
         3 => C_H_LOW_LIMIT +  300 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  300
         4 => C_H_LOW_LIMIT +  400 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  400
         5 => C_H_LOW_LIMIT +  500 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  500
         6 => C_H_LOW_LIMIT +  600 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  600
         7 => C_H_LOW_LIMIT +  700 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  700
         8 => C_H_LOW_LIMIT +  800 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  800
         9 => C_H_LOW_LIMIT +  900 - C_FONT_WIDTH*1 - C_FONT_WIDTH/2*3 - 1,  --  900
        10 => C_H_LOW_LIMIT + 1000                  - C_FONT_WIDTH/2*4 - 1   -- 1000
    );
    
    signal h_tick_vpos : STD_LOGIC_VECTOR(11 downto 0);
    
    signal h_ticks_pixel : STD_LOGIC_VECTOR(0 to 10);
    
    ------------------------------------------
    
    -- Labels on vertical axis
    signal v_label_pixel : STD_LOGIC;
    
    constant C_V_MIDDLE_PLOT     : STD_LOGIC_VECTOR(11 downto 0)
                                := C_V_UP_LIMIT + ('0'&(C_V_LOW_LIMIT(11 downto 1)    -C_V_UP_LIMIT(11 downto 1)));
    constant C_V_MIDDLE_PLOT_EXT : STD_LOGIC_VECTOR(11 downto 0)
                                := C_V_UP_LIMIT + ('0'&(C_V_LOW_LIMIT_EXT(11 downto 1)-C_V_UP_LIMIT(11 downto 1)));
    
    signal v_label_vpos : STD_LOGIC_VECTOR(11 downto 0);
    
    -- Labels on horizontal axis
    signal h_label_pixel : STD_LOGIC;
    
    constant C_H_MIDDLE_PLOT : STD_LOGIC_VECTOR(11 downto 0)
                            := C_H_LOW_LIMIT + ('0'&(C_H_UP_LIMIT(11 downto 1)-C_H_LOW_LIMIT(11 downto 1)));
    
    signal h_label_vpos : STD_LOGIC_VECTOR(11 downto 0);
    
begin
    
    write_text_inst_board_name : write_text
        generic map (
           G_TEXT_LENGTH => C_BOARD_NAME'length
        )
        port map (
            i_clk          => i_clk,
            i_display_text => C_BOARD_NAME,
            i_text_hpos    => x"007",
            i_text_vpos    => x"007",
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => board_name_pixel
        );
    
    ------------------------------------------
    
    v_tick_vpos <= C_V_TICK_VPOS_EXT when extend_vaxis = '1'
               else C_V_TICK_VPOS;
    write_text_gen_v_ticks :
    for i in 0 to 3 generate
        write_text_inst_v_tick : write_text
            generic map (
               G_TEXT_LENGTH => 3
            )
            port map (
                i_clk          => i_clk,
                i_display_text => C_V_TICK_NAME(i),
                i_text_hpos    => C_H_LOW_LIMIT - 15 - 3*C_FONT_WIDTH,
                i_text_vpos    => v_tick_vpos(i),
                i_hcounter     => i_hcounter,
                i_vcounter     => i_vcounter,
                
                o_pixel => v_ticks_pixel(i)
            );
    end generate;
    
    h_tick_vpos <= C_V_LOW_LIMIT_EXT + 12 when extend_vaxis = '1'
              else C_V_LOW_LIMIT     + 12;
    write_text_gen_h_ticks :
        for i in 0 to 10 generate
            write_text_inst_h_tick : write_text
                generic map (
                   G_TEXT_LENGTH => 4
                )
                port map (
                    i_clk          => i_clk,
                    i_display_text => C_H_TICK_NAME(i),
                    i_text_hpos    => C_H_TICK_HPOS(i),
                    i_text_vpos    => h_tick_vpos,
                    i_hcounter     => i_hcounter,
                    i_vcounter     => i_vcounter,
                    
                    o_pixel => h_ticks_pixel(i)
                );
        end generate;
    
    ------------------------------------------
    
    v_label_vpos <= C_V_MIDDLE_PLOT_EXT - C_FONT_WIDTH/2*6 - 4 when extend_vaxis = '1'
               else C_V_MIDDLE_PLOT     - C_FONT_WIDTH/2*6;
    write_text_rotated_inst_v_label : write_text_rotated
        generic map (
           G_TEXT_LENGTH => 6
        )
        port map (
            i_clk          => i_clk,
            i_display_text => "neuron",
            i_text_hpos    => C_H_LOW_LIMIT - 15 - 3*C_FONT_WIDTH - 10 - C_FONT_HEIGHT,
            i_text_vpos    => v_label_vpos,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => v_label_pixel
        );
    
    h_label_vpos <= h_tick_vpos + 8 + C_FONT_HEIGHT;
    write_text_inst_h_label : write_text
        generic map (
           G_TEXT_LENGTH => 9
        )
        port map (
            i_clk          => i_clk,
            i_display_text => "time (ms)",
            i_text_hpos    => C_H_MIDDLE_PLOT - C_FONT_WIDTH/2*9 - 3,
            i_text_vpos    => h_label_vpos,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => h_label_pixel
        );
    
    ------------------------------------------
    
    counter_latch_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_hcounter <= i_hcounter;
            o_vcounter <= i_vcounter;
            
        end if;
    end process;
    
    ------------------------------------------
    
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
    
    ------------------------------------------
    
    shifted_vcounters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_hcounter = 0 then
                if i_vcounter = 0 then
                    -- Initialization
                    extend_vaxis <= not(i_extend_vaxis);
                    
                    vcounter_ext     <= (others => '0');
                    shifted_vcounter <= C_MAX_ID + 1;
                    intermed_vcnt    <= (others => '0');
                    
                elsif vcounter_ext > C_V_LOW_LIMIT or vcounter_ext <= C_V_UP_LIMIT then
                    vcounter_ext <= vcounter_ext + 1;
                    
                elsif vcounter_ext <= C_V_LOW_LIMIT and vcounter_ext > C_V_UP_LIMIT then
                    if extend_vaxis = '1' then
                        intermed_vcnt <= intermed_vcnt + 1;  -- counter from 0 to 3
                        if intermed_vcnt = "00" then
                            vcounter_ext     <= vcounter_ext + 1;
                            shifted_vcounter <= shifted_vcounter - 1;  -- from C_MAX_ID=199 downto 0
                        end if;
                    else
                        vcounter_ext     <= vcounter_ext + 1;
                        shifted_vcounter <= shifted_vcounter - 1;  -- from C_MAX_ID=199 downto 0
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
    ------------------------------------------
    
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
    
    ------------------------------------------
    
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
    
    htick_counters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_hcounter = C_H_LOW_LIMIT - 1 then
                hcnt1 <= 0;
                hcnt2 <= 0;
                hcnt3 <= 0;
            elsif i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                if hcnt1 < RANGE_HCNT1-1 then
                    hcnt1 <= hcnt1 + 1;
                else
                    hcnt1 <= 0;
                    if hcnt2 < RANGE_HCNT2-1 then
                        hcnt2 <= hcnt2 + 1;
                    else
                        hcnt2 <= 0;
                        if hcnt3 < RANGE_HCNT3-1 then
                            hcnt3 <= hcnt3 + 1;
                        else
                            hcnt3 <= 0;
                        end if;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
    ------------------------------------------
    
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
            
            -- Ticks on vaxis
            if vcounter_ext <= C_V_LOW_LIMIT and vcounter_ext > C_V_UP_LIMIT then
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
            
            -- Ticks on haxis
            if i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                if (vcounter_ext <= C_V_LOW_LIMIT+11 and vcounter_ext > C_V_LOW_LIMIT+8)
                 or (vcounter_ext > C_V_UP_LIMIT-11 and vcounter_ext <= C_V_UP_LIMIT-8) then
                    if hcnt1 = 0 and hcnt2 = 0 and hcnt3 = 0 then
                        o_color <= C_BLACK;
                    end if;
                elsif (vcounter_ext <= C_V_LOW_LIMIT+8 and vcounter_ext > C_V_LOW_LIMIT+5)
                 or (vcounter_ext > C_V_UP_LIMIT-8 and vcounter_ext <= C_V_UP_LIMIT-5) then
                    if hcnt1 = 0 and hcnt2 = 0 then
                        o_color <= C_BLACK;
                    end if;
                elsif (vcounter_ext <= C_V_LOW_LIMIT+5 and vcounter_ext > C_V_LOW_LIMIT+2)
                 or (vcounter_ext > C_V_UP_LIMIT-5 and vcounter_ext <= C_V_UP_LIMIT-2) then
                    if hcnt1 = 0 then
                        o_color <= C_BLACK;
                    end if;
                end if;
            end if;
            
            -- Inside the plot
            if vcounter_ext <= C_V_LOW_LIMIT and vcounter_ext > C_V_UP_LIMIT
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
            
            -- Board name
            if board_name_pixel = '1' then
                o_color <= C_BLUE;
            end if;
            -- Vertical axis ticks label
            if v_ticks_pixel /= 0 then
                o_color <= C_BLACK;
            end if;
            -- Horizontal axis ticks label
            if h_ticks_pixel /= 0 then
                o_color <= C_BLACK;
            end if;
            -- Vertical axis label
            if v_label_pixel = '1' then
                o_color <= C_BLACK;
            end if;
            -- Horizontal axis label
            if h_label_pixel = '1' then
                o_color <= C_BLACK;
            end if;
            
        end if;
    end process;
    
end Behavioral;
