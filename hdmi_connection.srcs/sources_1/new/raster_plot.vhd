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
        i_clk         : in STD_LOGIC;
        i_rst         : in STD_LOGIC;
        i_hcounter    : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter    : in STD_LOGIC_VECTOR(11 downto 0);
        i_mem_rd_data : in STD_LOGIC_VECTOR(C_MAX_ID downto 0);
        i_current_ts  : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
--        i_sw          : in STD_LOGIC;
        
        o_mem_rd_en   : out STD_LOGIC;
        o_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
        o_color       : out STD_LOGIC_VECTOR(23 downto 0);
        o_end_screen  : out STD_LOGIC
    );
end raster_plot;

architecture Behavioral of raster_plot is
    
    constant C_BLACK   : STD_LOGIC_VECTOR(23 downto 0) := x"000000";
    constant C_GREY    : STD_LOGIC_VECTOR(23 downto 0) := x"606060";
    constant C_RED     : STD_LOGIC_VECTOR(23 downto 0) := x"FF0000";
    constant C_YELLOW  : STD_LOGIC_VECTOR(23 downto 0) := x"FFFF00";
    constant C_GREEN   : STD_LOGIC_VECTOR(23 downto 0) := x"00FF00";
    constant C_CYAN    : STD_LOGIC_VECTOR(23 downto 0) := x"00FFFF";
    constant C_BLUE    : STD_LOGIC_VECTOR(23 downto 0) := x"0000FF";
    constant C_MAGENTA : STD_LOGIC_VECTOR(23 downto 0) := x"FF00FF";
    constant C_WHITE   : STD_LOGIC_VECTOR(23 downto 0) := x"FFFFFF";
    
    constant C_AXIS_SIZE : STD_LOGIC_VECTOR(11 downto 0) := x"002";
    
    constant C_H_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_H_OFFSET;
    constant C_H_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_H_LOW_LIMIT + C_NB_H_POINTS;
    
    constant C_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0) := C_V_OFFSET;
    constant C_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0) := C_V_UP_LIMIT + (C_MAX_ID + 1);
    
    signal pointer0   : STD_LOGIC_VECTOR(9 downto 0) := (others => '0');
    signal current_ts : STD_LOGIC_VECTOR(31 downto 0);
    
--    signal div_vcounter    : STD_LOGIC_VECTOR(11 downto 0);
--    signal vcounter_mod    : STD_LOGIC_VECTOR(1 downto 0);
--    signal mult_v_low_limit : STD_LOGIC_VECTOR(11 downto 0);
    
begin
--    div_vcounter <= C_V_UP_LIMIT + i_vcounter(11 downto 2) - C_V_UP_LIMIT(11 downto 2) when i_sw = '1'
--               else i_vcounter;
--    vcounter_mod <= (i_vcounter(1 downto 0) - C_V_UP_LIMIT(1 downto 0)) when i_sw = '1'
--               else "00";
--    mult_v_low_limit <= C_V_UP_LIMIT + ((C_V_LOW_LIMIT(9 downto 0) - C_V_UP_LIMIT(9 downto 0)) & "00") when i_sw = '1'
--                   else C_V_LOW_LIMIT;
    
    color_proc: process(i_clk)
        variable h_value : STD_LOGIC_VECTOR(11 downto 0);
        variable v_value : STD_LOGIC_VECTOR(11 downto 0);
        variable shifted_hcounter : STD_LOGIC_VECTOR(11 downto 0);
        variable shifted_vcounter : STD_LOGIC_VECTOR(11 downto 0);
        
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
                if (i_hcounter >= C_H_LOW_LIMIT - 3 and i_hcounter < C_H_LOW_LIMIT) and
                   (i_vcounter <= C_V_LOW_LIMIT and i_vcounter > C_V_UP_LIMIT) then
                    -- we need three time periods before reading from the memory
                    shifted_hcounter := i_hcounter - (C_H_LOW_LIMIT - 3);  -- from 0 to C_NB_H_POINTS-1=1023
                    o_mem_rd_en   <= '1';
                    o_mem_rd_addr <= pointer0 + shifted_hcounter(9 downto 0);
                end if;
                
                if (i_hcounter >= C_H_LOW_LIMIT - C_AXIS_SIZE and i_hcounter < C_H_LOW_LIMIT 
                    and i_vcounter <= C_V_LOW_LIMIT + C_AXIS_SIZE and i_vcounter > C_V_UP_LIMIT) or
                   (i_vcounter <= C_V_LOW_LIMIT + C_AXIS_SIZE and i_vcounter > C_V_LOW_LIMIT
                    and i_hcounter >= C_H_LOW_LIMIT - C_AXIS_SIZE and i_hcounter < C_H_UP_LIMIT) then
                    -- White plot limits
                    o_color <= C_WHITE;
                    
                elsif (i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT) and
                      (i_vcounter <= C_V_LOW_LIMIT and i_vcounter > C_V_UP_LIMIT) then
                    
                    shifted_hcounter := i_hcounter - (C_H_LOW_LIMIT - 3);
                    o_mem_rd_addr <= pointer0 + shifted_hcounter(9 downto 0);
                    shifted_vcounter := C_V_LOW_LIMIT - i_vcounter;  -- from 0 to C_MAX_ID=200
                    
                    if shifted_hcounter(9 downto 0) <= current_ts and 
                       i_mem_rd_data(to_integer(unsigned(shifted_vcounter))) = '1' then
                        -- Plot yellow dots for the corresponding spike
                        o_color <= C_YELLOW;
                    else
                        -- Grey background inside the plot
                        o_color <= C_GREY;
                    end if;
                
                elsif (i_hcounter = C_H_UP_LIMIT) and
                      (i_vcounter = C_V_LOW_LIMIT) then
                    o_mem_rd_en <= '0';
                
                elsif (i_hcounter = C_H_VISIBLE) and
                      (i_vcounter = C_V_VISIBLE) then
                    o_end_screen <= '1';
                    
                    current_ts <= i_current_ts;
                    if i_current_ts(31 downto 10) = 0 then  -- the memory has not been written fully
                        pointer0 <= (others => '0');
                    else
                        pointer0 <= i_current_ts(9 downto 0) + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
