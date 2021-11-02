----------------------------------------------------------------------------------
-- Engineer:    Mike Field <hamster@snap.net.nz> 
-- Module Name: convert_444_422 - Behavioral 
-- 
-- Description: Convert the input pixels into two RGB values - that for the Y calc
--              and that for the CbCr calculation
--
-- Feel free to use this how you see fit, and fix any errors you find :-)
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity convert_444_422 is
    port (
        i_clk   : in STD_LOGIC;
        -- pixels and control signals in
        i_r     : in STD_LOGIC_VECTOR(7 downto 0);
        i_g     : in STD_LOGIC_VECTOR(7 downto 0);
        i_b     : in STD_LOGIC_VECTOR(7 downto 0);
        i_de    : in STD_LOGIC;
        i_hsync : in STD_LOGIC;
        i_vsync : in STD_LOGIC;
        
        -- two channels of output RGB + control signals
        o_r1         : out STD_LOGIC_VECTOR(8 downto 0);
        o_g1         : out STD_LOGIC_VECTOR(8 downto 0);
        o_b1         : out STD_LOGIC_VECTOR(8 downto 0);
        o_r2         : out STD_LOGIC_VECTOR(8 downto 0);
        o_g2         : out STD_LOGIC_VECTOR(8 downto 0);
        o_b2         : out STD_LOGIC_VECTOR(8 downto 0);
        o_pair_start : out STD_LOGIC;
        o_de         : out STD_LOGIC;
        o_hsync      : out STD_LOGIC;
        o_vsync      : out STD_LOGIC
    );
end convert_444_422;


architecture Behavioral of convert_444_422 is
    
    signal r_a      : STD_LOGIC_VECTOR(7 downto 0);
    signal g_a      : STD_LOGIC_VECTOR(7 downto 0);
    signal b_a      : STD_LOGIC_VECTOR(7 downto 0);
    signal h_a      : STD_LOGIC;
    signal v_a      : STD_LOGIC;
    signal d_a      : STD_LOGIC;
    signal d_a_last : STD_LOGIC;
    
    -- flag is used to work out which pairs of pixels to sum.
    signal flag : STD_LOGIC;

begin
    clk_proc: process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            -- sync pairs to the i_de going high (if a scan line has odd pixel count)
            if (d_a = '1' and d_a_last = '0') or flag = '1' then
                o_r2 <= ('0' & r_a) + ('0' & i_r);
                o_g2 <= ('0' & g_a) + ('0' & i_g);
                o_b2 <= ('0' & b_a) + ('0' & i_b);
                flag <= '0';
                o_pair_start <= '1';
            else
                flag <= '1';
                o_pair_start <= '0';
            end if;
            
            r_a      <= i_r;
            g_a      <= i_g;
            b_a      <= i_b;
            h_a      <= i_hsync;
            v_a      <= i_vsync;
            d_a      <= i_de;
            d_a_last <= d_a;
            
            o_r1    <= r_a & "0";
            o_g1    <= g_a & "0";
            o_b1    <= b_a & "0";
            o_hsync <= h_a;
            o_vsync <= v_a;
            o_de    <= d_a;
            
        end if;
    end process;

end Behavioral;