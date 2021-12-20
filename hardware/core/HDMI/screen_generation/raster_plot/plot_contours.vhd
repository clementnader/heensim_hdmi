----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/16/2021 01:20:04 PM
-- Design Name: 
-- Module Name: plot_contours - Behavioral
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


entity plot_contours is
    generic (
        G_NB_V_POINTS : INTEGER;
        G_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0);
        G_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0);
        
        G_RANGE_VCNT1 : INTEGER;
        G_RANGE_VCNT2 : INTEGER;
        G_RANGE_VCNT3 : INTEGER
    );
    port (
        i_clk      : in STD_LOGIC;
        i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
        
        o_contours_pixel : out BOOLEAN
    );
end plot_contours;


architecture Behavioral of plot_contours is
    
    component plot_axes_ticks
        generic (
            G_NB_V_POINTS : INTEGER;
            G_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0);
            G_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0);
            
            G_RANGE_VCNT1 : INTEGER;
            G_RANGE_VCNT2 : INTEGER;
            G_RANGE_VCNT3 : INTEGER
        );
        port (
            i_clk      : in STD_LOGIC;
            i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_hcnt1 : out INTEGER range 0 to C_RANGE_HCNT1-1;
            o_hcnt2 : out INTEGER range 0 to C_RANGE_HCNT2-1;
            o_hcnt3 : out INTEGER range 0 to C_RANGE_HCNT3-1;
            o_vcnt1 : out INTEGER range 0 to G_RANGE_VCNT1-1;
            o_vcnt2 : out INTEGER range 0 to G_RANGE_VCNT2-1;
            o_vcnt3 : out INTEGER range 0 to G_RANGE_VCNT3-1
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    -- Signals to draw ticks on the horizontal axis
    signal hcnt1 : INTEGER range 0 to C_RANGE_HCNT1-1;
    signal hcnt2 : INTEGER range 0 to C_RANGE_HCNT2-1;
    signal hcnt3 : INTEGER range 0 to C_RANGE_HCNT3-1;
    
    -- Signals to draw ticks on the vertical axis
    signal vcnt1 : INTEGER range 0 to G_RANGE_VCNT1-1;
    signal vcnt2 : INTEGER range 0 to G_RANGE_VCNT2-1;
    signal vcnt3 : INTEGER range 0 to G_RANGE_VCNT3-1;
    
begin
    
    plot_axes_ticks_inst : plot_axes_ticks
        generic map (
            G_NB_V_POINTS => G_NB_V_POINTS,
            G_V_UP_LIMIT  => G_V_UP_LIMIT,
            G_V_LOW_LIMIT => G_V_LOW_LIMIT,
            
            G_RANGE_VCNT1 => G_RANGE_VCNT1,
            G_RANGE_VCNT2 => G_RANGE_VCNT2,
            G_RANGE_VCNT3 => G_RANGE_VCNT3
        )
        port map (
            i_clk      => i_clk,
            i_hcounter => i_hcounter,
            i_vcounter => i_vcounter,
            
            o_hcnt1 => hcnt1,
            o_hcnt2 => hcnt2,
            o_hcnt3 => hcnt3,
            o_vcnt1 => vcnt1,
            o_vcnt2 => vcnt2,
            o_vcnt3 => vcnt3
        );
    
    -----------------------------------------------------------------------------------
    
    color_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_contours_pixel <= False;
            
            -- Plot contours
            if i_vcounter <= G_V_LOW_LIMIT+2 and i_vcounter > G_V_UP_LIMIT-2 then
                if (i_hcounter < C_H_LOW_LIMIT and i_hcounter >= C_H_LOW_LIMIT-2)
                 or (i_hcounter >= C_H_UP_LIMIT and i_hcounter < C_H_UP_LIMIT+2) then
                    o_contours_pixel <= True;
                end if;
            end if;
            if i_hcounter >= C_H_LOW_LIMIT-2 and i_hcounter < C_H_UP_LIMIT+2 then
                if (i_vcounter > G_V_LOW_LIMIT and i_vcounter <= G_V_LOW_LIMIT+2)
                 or (i_vcounter <= G_V_UP_LIMIT and i_vcounter > G_V_UP_LIMIT-2) then
                    o_contours_pixel <= True;
                end if;
            end if;
            
            -- Ticks on haxis
            if i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                if (i_vcounter <= G_V_LOW_LIMIT+11 and i_vcounter > G_V_LOW_LIMIT+8)
                 or (i_vcounter > G_V_UP_LIMIT-11 and i_vcounter <= G_V_UP_LIMIT-8) then
                    if hcnt1 = 0 and hcnt2 = 0 and hcnt3 = 0 then
                        o_contours_pixel <= True;
                    end if;
                end if;
                if (i_vcounter <= G_V_LOW_LIMIT+8 and i_vcounter > G_V_LOW_LIMIT+5)
                 or (i_vcounter > G_V_UP_LIMIT-8 and i_vcounter <= G_V_UP_LIMIT-5) then
                    if hcnt1 = 0 and hcnt2 = 0 then
                        o_contours_pixel <= True;
                    end if;
                end if;
                if (i_vcounter <= G_V_LOW_LIMIT+5 and i_vcounter > G_V_LOW_LIMIT+2)
                 or (i_vcounter > G_V_UP_LIMIT-5 and i_vcounter <= G_V_UP_LIMIT-2) then
                    if hcnt1 = 0 then
                        o_contours_pixel <= True;
                    end if;
                end if;
            end if;
            -- Ticks on vaxis
            if i_vcounter <= G_V_LOW_LIMIT and i_vcounter > G_V_UP_LIMIT then
                if (i_hcounter >= C_H_LOW_LIMIT-11 and i_hcounter < C_H_LOW_LIMIT-8)
                 or (i_hcounter < C_H_UP_LIMIT+11 and i_hcounter >= C_H_UP_LIMIT+8) then
                    if vcnt1 = 0 and vcnt2 = 0 and vcnt3 = 0 then
                        o_contours_pixel <= True;
                    end if;
                end if;
                if (i_hcounter >= C_H_LOW_LIMIT-8 and i_hcounter < C_H_LOW_LIMIT-5)
                 or (i_hcounter < C_H_UP_LIMIT+8 and i_hcounter >= C_H_UP_LIMIT+5) then
                    if vcnt1 = 0 and vcnt2 = 0 then
                        o_contours_pixel <= True;
                    end if;
                end if;
                if (i_hcounter >= C_H_LOW_LIMIT-5 and i_hcounter < C_H_LOW_LIMIT-2)
                 or (i_hcounter < C_H_UP_LIMIT+5 and i_hcounter >= C_H_UP_LIMIT+2) then
                    if vcnt1 = 0 then
                        o_contours_pixel <= True;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
end Behavioral;
