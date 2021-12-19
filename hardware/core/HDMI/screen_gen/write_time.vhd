----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2021 11:47:49 PM
-- Design Name: 
-- Module Name: write_time - Behavioral
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
    use work.neurons_pkg.ALL;
    use work.character_definition_pkg.ALL;


entity write_time is
    port (
        i_clk               : in STD_LOGIC;
        i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
        i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        
        o_time_label_pixel : out BOOLEAN;
        o_time_pixel       : out BOOLEAN;
        o_time_val_pixel   : out BOOLEAN
    );
end write_time;


architecture Behavioral of write_time is
    
    component write_text
        generic (
           G_TEXT_LENGTH : INTEGER
        );
        port (
            i_clk          : in STD_LOGIC;
            i_do_display   : in BOOLEAN;
            i_display_text : in STRING(1 to G_TEXT_LENGTH);
            i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_pixel : out BOOLEAN
        );
    end component;
    
    component write_text_integer
        generic (
           G_TEXT_LENGTH : INTEGER
        );
        port (
            i_clk         : in STD_LOGIC;
            i_do_display  : in BOOLEAN;
            i_display_int : in INTEGER range 0 to 10**G_TEXT_LENGTH-1;
            i_text_hpos   : in STD_LOGIC_VECTOR(11 downto 0);  -- horizontal position of the top left corner of the text
            i_text_vpos   : in STD_LOGIC_VECTOR(11 downto 0);  -- vertical position of the top left corner of the text
            i_hcounter    : in STD_LOGIC_VECTOR(11 downto 0);  -- current pixel horizontal position
            i_vcounter    : in STD_LOGIC_VECTOR(11 downto 0);  -- current pixel vertical position
            
            o_pixel : out BOOLEAN
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    signal cnt_ms  : INTEGER range 0 to 999;
    signal cnt_s   : INTEGER range 0 to 59;
    signal cnt_mn  : INTEGER range 0 to 59;
    signal cnt_hr  : INTEGER range 0 to 23;
    signal cnt_day : INTEGER range 0 to 63;
    
    signal last_timestamp : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);  -- signal to know when there is a change in the timestamp value
    
    -----------------------------------------------------------------------------------
    
    constant C_H_LABEL_POS : STD_LOGIC_VECTOR(11 downto 0) := x"008";
    constant C_V_LABEL_POS : STD_LOGIC_VECTOR(11 downto 0) := x"008" + 9*C_FONT_HEIGHT;
    constant C_TIME_LABEL  : STRING := "Execution Time:";
    
    constant C_H_TIME_BASE_POS : STD_LOGIC_VECTOR(11 downto 0) := C_H_LABEL_POS + (C_TIME_LABEL'length+1)*C_FONT_WIDTH;
    constant C_V_TIME_POS      : STD_LOGIC_VECTOR(11 downto 0) := C_V_LABEL_POS;
    
    type T_POS_ARRAY is ARRAY(NATURAL range <>) of STD_LOGIC_VECTOR(11 downto 0);
    
    -----------------------------------------------------------------------------------
    
    constant C_H_TIME_DAY_VAL_POS : T_POS_ARRAY := (
        0 => C_H_TIME_BASE_POS
    );
    constant C_H_TIME_DAY_POS     : T_POS_ARRAY := (
        0 => C_H_TIME_BASE_POS + 2*C_FONT_WIDTH
    );
    
    signal time_day_bool      : BOOLEAN;
    signal time_day_pixel     : BOOLEAN;
    signal time_day_val_pixel : BOOLEAN;
    
    -----------------------------------------------------------------------------------
    
    constant C_H_TIME_HR_VAL_POS : T_POS_ARRAY := (
        0 => C_H_TIME_BASE_POS,
        1 => C_H_TIME_BASE_POS +  4*C_FONT_WIDTH
    );
    constant C_H_TIME_HR_POS : T_POS_ARRAY := (
        0 => C_H_TIME_BASE_POS +  2*C_FONT_WIDTH,
        1 => C_H_TIME_BASE_POS +  6*C_FONT_WIDTH
    );
    signal h_time_hr_val_pos : STD_LOGIC_VECTOR(11 downto 0);
    signal h_time_hr_pos     : STD_LOGIC_VECTOR(11 downto 0);
    signal h_time_hr_i       : INTEGER range 0 to 1;
    
    signal time_hr_bool      : BOOLEAN;
    signal time_hr_pixel     : BOOLEAN;
    signal time_hr_val_pixel : BOOLEAN;
    
    -----------------------------------------------------------------------------------
    
    constant C_H_TIME_MN_VAL_POS : T_POS_ARRAY := (
        0 => C_H_TIME_BASE_POS,
        1 => C_H_TIME_BASE_POS +  4*C_FONT_WIDTH,
        2 => C_H_TIME_BASE_POS +  8*C_FONT_WIDTH
    );
    constant C_H_TIME_MN_POS : T_POS_ARRAY := (
        0 => C_H_TIME_BASE_POS +  2*C_FONT_WIDTH,
        1 => C_H_TIME_BASE_POS +  6*C_FONT_WIDTH,
        2 => C_H_TIME_BASE_POS + 10*C_FONT_WIDTH
    );
    signal h_time_mn_val_pos : STD_LOGIC_VECTOR(11 downto 0);
    signal h_time_mn_pos     : STD_LOGIC_VECTOR(11 downto 0);
    signal h_time_mn_i       : INTEGER range 0 to 2;
    
    signal time_mn_bool      : BOOLEAN;
    signal time_mn_pixel     : BOOLEAN;
    signal time_mn_val_pixel : BOOLEAN;
    
    -----------------------------------------------------------------------------------
    
    constant C_H_TIME_S_VAL_POS : T_POS_ARRAY := (
        0 => C_H_TIME_BASE_POS,
        1 => C_H_TIME_BASE_POS +  5*C_FONT_WIDTH,
        2 => C_H_TIME_BASE_POS +  9*C_FONT_WIDTH,
        3 => C_H_TIME_BASE_POS + 13*C_FONT_WIDTH
    );
    constant C_H_TIME_S_POS : T_POS_ARRAY := (
        0 => C_H_TIME_BASE_POS +  2*C_FONT_WIDTH,
        1 => C_H_TIME_BASE_POS +  7*C_FONT_WIDTH,
        2 => C_H_TIME_BASE_POS + 11*C_FONT_WIDTH,
        3 => C_H_TIME_BASE_POS + 15*C_FONT_WIDTH
    );
    signal h_time_s_val_pos : STD_LOGIC_VECTOR(11 downto 0);
    signal h_time_s_pos     : STD_LOGIC_VECTOR(11 downto 0);
    signal h_time_s_i       : INTEGER range 0 to 3;
    
    signal time_s_pixel     : BOOLEAN;
    signal time_s_val_pixel : BOOLEAN;
    
begin
    
    o_time_pixel     <= time_s_pixel     or time_mn_pixel     or time_hr_pixel     or time_day_pixel    ;
    o_time_val_pixel <= time_s_val_pixel or time_mn_val_pixel or time_hr_val_pixel or time_day_val_pixel;
    
    -----------------------------------------------------------------------------------
    
    time_counters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            last_timestamp <= i_current_timestamp;
            
            if i_current_timestamp = 0 then
                cnt_ms  <= 0;
                cnt_s   <= 0;
                cnt_mn  <= 0;
                cnt_hr  <= 0;
                cnt_day <= 0;
            elsif last_timestamp /= i_current_timestamp then
                if cnt_ms < 999 then
                    cnt_ms <= cnt_ms + 1;
                else
                    cnt_ms <= 0;
                    if cnt_s < 59 then
                        cnt_s <= cnt_s + 1;
                    else
                        cnt_s <= 0;
                        if cnt_mn < 59 then
                            cnt_mn <= cnt_mn + 1;
                        else
                            cnt_mn <= 0;
                            if cnt_hr < 23 then
                                cnt_hr <= cnt_hr + 1;
                            else
                                cnt_hr <= 0;
                                if cnt_day < 63 then
                                    cnt_day <= cnt_day + 1;
                                else
                                    cnt_day <= 0;
                                end if;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    h_time_hr_i <= 0 when cnt_day = 0
              else 1;
    
    h_time_mn_i <= 0 when cnt_day = 0 and cnt_hr = 0
              else 1 when cnt_day = 0 and cnt_hr /= 0
              else 2;
    
    h_time_s_i <= 0 when cnt_day = 0 and cnt_hr = 0 and cnt_mn = 0
             else 1 when cnt_day = 0 and cnt_hr = 0 and cnt_mn /= 0
             else 2 when cnt_day = 0 and cnt_hr /= 0
             else 3;
    
    -----------------------------------------------------------------------------------
    
    h_time_hr_val_pos <= C_H_TIME_HR_VAL_POS(h_time_hr_i);
    h_time_hr_pos     <= C_H_TIME_HR_POS(h_time_hr_i);
    
    h_time_mn_val_pos <= C_H_TIME_MN_VAL_POS(h_time_mn_i);
    h_time_mn_pos     <= C_H_TIME_MN_POS(h_time_mn_i);
    
    h_time_s_val_pos  <= C_H_TIME_S_VAL_POS(h_time_s_i);
    h_time_s_pos      <= C_H_TIME_S_POS(h_time_s_i);
    
    ------------------------------------------
    
    time_mn_bool  <= not (cnt_mn = 0 and h_time_mn_i = 0);
    time_hr_bool  <= not (cnt_hr = 0 and h_time_hr_i = 0);
    time_day_bool <= not (cnt_day = 0);
    
    -----------------------------------------------------------------------------------
    
    write_text_inst_label : write_text
        generic map (
           G_TEXT_LENGTH => C_TIME_LABEL'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_TIME_LABEL,
            i_text_hpos    => C_H_LABEL_POS,
            i_text_vpos    => C_V_LABEL_POS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => o_time_label_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    write_text_integer_inst_s : write_text_integer
        generic map (
           G_TEXT_LENGTH => 2
        )
        port map (
            i_clk         => i_clk,
            i_do_display  => True,
            i_display_int => cnt_s,
            i_text_hpos   => h_time_s_val_pos,
            i_text_vpos   => C_V_TIME_POS,
            i_hcounter    => i_hcounter,
            i_vcounter    => i_vcounter,
            
            o_pixel => time_s_val_pixel
        );
    
    write_text_inst_s : write_text
        generic map (
           G_TEXT_LENGTH => 1
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => "s",
            i_text_hpos    => h_time_s_pos,
            i_text_vpos    => C_V_TIME_POS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => time_s_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    write_text_integer_inst_mn : write_text_integer
        generic map (
           G_TEXT_LENGTH => 2
        )
        port map (
            i_clk         => i_clk,
            i_do_display  => time_mn_bool,
            i_display_int => cnt_mn,
            i_text_hpos   => h_time_mn_val_pos,
            i_text_vpos   => C_V_TIME_POS,
            i_hcounter    => i_hcounter,
            i_vcounter    => i_vcounter,
            
            o_pixel => time_mn_val_pixel
        );
    
    write_text_inst_mn : write_text
        generic map (
           G_TEXT_LENGTH => 2
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => time_mn_bool,
            i_display_text => "mn",
            i_text_hpos    => h_time_mn_pos,
            i_text_vpos    => C_V_TIME_POS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => time_mn_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    write_text_integer_inst_hr : write_text_integer
        generic map (
           G_TEXT_LENGTH => 2
        )
        port map (
            i_clk         => i_clk,
            i_do_display  => time_hr_bool,
            i_display_int => cnt_hr,
            i_text_hpos   => h_time_hr_val_pos,
            i_text_vpos   => C_V_TIME_POS,
            i_hcounter    => i_hcounter,
            i_vcounter    => i_vcounter,
            
            o_pixel => time_hr_val_pixel
        );
    
    write_text_inst_hr : write_text
        generic map (
           G_TEXT_LENGTH => 1
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => time_hr_bool,
            i_display_text => "h",
            i_text_hpos    => h_time_hr_pos,
            i_text_vpos    => C_V_TIME_POS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => time_hr_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    write_text_integer_inst_day : write_text_integer
        generic map (
           G_TEXT_LENGTH => 2
        )
        port map (
            i_clk         => i_clk,
            i_do_display  => time_day_bool,
            i_display_int => cnt_day,
            i_text_hpos   => C_H_TIME_DAY_VAL_POS(0),
            i_text_vpos   => C_V_TIME_POS,
            i_hcounter    => i_hcounter,
            i_vcounter    => i_vcounter,
            
            o_pixel => time_day_val_pixel
        );
    
    write_text_inst_day : write_text
        generic map (
           G_TEXT_LENGTH => 1
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => time_day_bool,
            i_display_text => "d",
            i_text_hpos    => C_H_TIME_DAY_POS(0),
            i_text_vpos    => C_V_TIME_POS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => time_day_pixel
        );
    
end Behavioral;
