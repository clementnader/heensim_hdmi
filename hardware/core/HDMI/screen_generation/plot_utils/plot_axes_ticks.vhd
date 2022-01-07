----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 06:18:50 PM
-- Design Name: 
-- Module Name: plot_axes_ticks - Behavioral
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


entity plot_axes_ticks is
    generic (
        G_NB_V_POINTS : INTEGER;
        G_V_UP_LIMIT  : STD_LOGIC_VECTOR(11 downto 0);
        G_V_LOW_LIMIT : STD_LOGIC_VECTOR(11 downto 0);
        
        G_RANGE_VCNT1 : INTEGER := 10;  -- vertical tick every 10
        G_RANGE_VCNT2 : INTEGER := 5;   -- vertical tick every 50
        G_RANGE_VCNT3 : INTEGER := 2    -- vertical tick every 100
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
end plot_axes_ticks;


architecture Behavioral of plot_axes_ticks is
    
    constant C_VCNT1_UP_LIMIT : INTEGER := G_NB_V_POINTS mod G_RANGE_VCNT1;
    constant C_VCNT_Q1        : INTEGER := (G_NB_V_POINTS-C_VCNT1_UP_LIMIT) / G_RANGE_VCNT1;
    constant C_VCNT2_UP_LIMIT : INTEGER := C_VCNT_Q1 mod G_RANGE_VCNT2;
    constant C_VCNT_Q2        : INTEGER := (C_VCNT_Q1-C_VCNT2_UP_LIMIT) / G_RANGE_VCNT2;
    constant C_VCNT3_UP_LIMIT : INTEGER := C_VCNT_Q2 mod G_RANGE_VCNT3;
    
    -----------------------------------------------------------------------------------
    
    -- Signals to draw ticks on the horizontal axis
    signal hcnt1 : INTEGER range 0 to C_RANGE_HCNT1-1;
    signal hcnt2 : INTEGER range 0 to C_RANGE_HCNT2-1;
    signal hcnt3 : INTEGER range 0 to C_RANGE_HCNT3-1;
    
    -- Signals to draw ticks on the vertical axis
    signal vcnt1 : INTEGER range 0 to G_RANGE_VCNT1-1;
    signal vcnt2 : INTEGER range 0 to G_RANGE_VCNT2-1;
    signal vcnt3 : INTEGER range 0 to G_RANGE_VCNT3-1;
    
    -- Signal to know when there is a change in the vcounter value,
    -- needed for the vertical counter because it does not change every clock period like the horizontal one
    signal last_vcounter : STD_LOGIC_VECTOR(11 downto 0);
    
begin
    
    o_hcnt1 <= hcnt1;
    o_hcnt2 <= hcnt2;
    o_hcnt3 <= hcnt3;
    
    o_vcnt1 <= vcnt1;
    o_vcnt2 <= vcnt2;
    o_vcnt3 <= vcnt3;
    
    -----------------------------------------------------------------------------------
    
    htick_counters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_hcounter = C_H_LOW_LIMIT-1 then
                hcnt1 <= 0;
                hcnt2 <= 0;
                hcnt3 <= 0;
            elsif i_hcounter >= C_H_LOW_LIMIT and i_hcounter < C_H_UP_LIMIT then
                if hcnt1 < C_RANGE_HCNT1-1 then
                    hcnt1 <= hcnt1 + 1;
                else
                    hcnt1 <= 0;
                    if hcnt2 < C_RANGE_HCNT2-1 then
                        hcnt2 <= hcnt2 + 1;
                    else
                        hcnt2 <= 0;
                        if hcnt3 < C_RANGE_HCNT3-1 then
                            hcnt3 <= hcnt3 + 1;
                        else
                            hcnt3 <= 0;
                        end if;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    vtick_counters_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            last_vcounter <= i_vcounter;
            
            if i_vcounter = G_V_UP_LIMIT then
                vcnt1 <= C_VCNT1_UP_LIMIT;
                vcnt2 <= C_VCNT2_UP_LIMIT;
                vcnt3 <= C_VCNT3_UP_LIMIT;
            elsif i_vcounter <= G_V_LOW_LIMIT and i_vcounter > G_V_UP_LIMIT
             and last_vcounter /= i_vcounter then
                if vcnt1 > 0 then
                    vcnt1 <= vcnt1 - 1;
                else
                    vcnt1 <= G_RANGE_VCNT1-1;
                    if vcnt2 > 0 then
                        vcnt2 <= vcnt2 - 1;
                    else
                        vcnt2 <= G_RANGE_VCNT2-1;
                        if vcnt3 > 0 then
                            vcnt3 <= vcnt3 - 1;
                        else
                            vcnt3 <= G_RANGE_VCNT3-1;
                        end if;
                    end if;
                end if;
            end if;
            
        end if;
    end process;
    
end Behavioral;
