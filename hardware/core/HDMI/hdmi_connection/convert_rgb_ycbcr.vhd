----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/01/2021 10:22:55 AM
-- Design Name: 
-- Module Name: convert_rgb_ycbcr - Behavioral
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


entity convert_rgb_ycbcr is
    port (
        i_clk   : in STD_LOGIC;
        i_r     : in STD_LOGIC_VECTOR(7 downto 0);
        i_g     : in STD_LOGIC_VECTOR(7 downto 0);
        i_b     : in STD_LOGIC_VECTOR(7 downto 0);
        i_de    : in STD_LOGIC;
        i_hsync : in STD_LOGIC;
        i_vsync : in STD_LOGIC;
        
        o_y     : out STD_LOGIC_VECTOR(7 downto 0);
        o_cb    : out STD_LOGIC_VECTOR(7 downto 0);
        o_cr    : out STD_LOGIC_VECTOR(7 downto 0);
        o_de    : out STD_LOGIC;
        o_hsync : out STD_LOGIC;
        o_vsync : out STD_LOGIC
    );
end convert_rgb_ycbcr;


architecture Behavioral of convert_rgb_ycbcr is
    
    signal latch_de    : STD_LOGIC;
    signal latch_hsync : STD_LOGIC;
    signal latch_vsync : STD_LOGIC;
    
    signal intermed_y_sum_r  : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_y_sum_g  : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_y_sum_b  : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_cb_sum_r : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_cb_sum_g : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_cb_sum_b : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_cr_sum_r : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_cr_sum_g : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_cr_sum_b : STD_LOGIC_VECTOR(15 downto 0);
    
    signal intermed_y  : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_cb : STD_LOGIC_VECTOR(15 downto 0);
    signal intermed_cr : STD_LOGIC_VECTOR(15 downto 0);
    
begin
    
    o_y  <= x"10" + intermed_y(15 downto 8);   -- y  =  16 + (intermed_y>>8)
    o_cb <= x"80" + intermed_cb(15 downto 8);  -- cb = 128 + (intermed_cb>>8)
    o_cr <= x"80" + intermed_cr(15 downto 8);  -- cr = 128 + (intermed_cr>>8)
    
    -----------------------------------------------------------------------------------
    
    latch_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            latch_de    <= i_de;
            latch_hsync <= i_hsync;
            latch_vsync <= i_vsync;
            
            o_de    <= latch_de;
            o_hsync <= latch_hsync;
            o_vsync <= latch_vsync;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    convert_to_ycbcr_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            -- Y --
            intermed_y_sum_r <= x"0000" + (i_r&"000000")  + (i_r&"0");          -- + (r<<6) + (r<<1)
            intermed_y_sum_g <= x"0000" + (i_g&"0000000") + i_g;                -- + (g<<7) + g
            intermed_y_sum_b <= x"0000" + (i_b&"0000")    + (i_b&"000") + i_b;  -- + (b<<4) + (b<<3) + b
            
            intermed_y <= intermed_y_sum_r + intermed_y_sum_g + intermed_y_sum_b;
            
            -- Cb --
            intermed_cb_sum_r <= x"0000" - (i_r&"00000")   - (i_r&"00")  - (i_r&"0");  -- - (r<<5) - (r<<2) - (r<<1)
            intermed_cb_sum_g <= x"0000" - (i_g&"000000")  - (i_g&"000") - (i_g&"0");  -- - (g<<6) - (g<<3) - (g<<1)
            intermed_cb_sum_b <= x"0000" + (i_b&"0000000") - (i_b&"0000");             -- + (b<<7) - (b<<4)
            
            intermed_cb <= intermed_cb_sum_r + intermed_cb_sum_g + intermed_cb_sum_b;
            
            -- Cr --
            intermed_cr_sum_r <= x"0000" + (i_r&"0000000") - (i_r&"0000");               -- + (r<<7) - (r<<4)
            intermed_cr_sum_g <= x"0000" - (i_g&"000000")  - (i_g&"00000") + (i_g&"0");  -- - (g<<6) - (g<<5) + (g<<1)
            intermed_cr_sum_b <= x"0000" - (i_b&"0000")    - (i_b&"0");                  -- - (b<<4) - (b<<1)
            
            intermed_cr <= intermed_cr_sum_r + intermed_cr_sum_g + intermed_cr_sum_b;
            
        end if;
    end process;
    
end Behavioral;
