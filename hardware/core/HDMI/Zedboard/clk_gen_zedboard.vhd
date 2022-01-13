----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/09/2021 12:24:44 PM
-- Design Name: 
-- Module Name: clk_gen - Behavioral
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

library UNISIM;
    use UNISIM.VComponents.all;


entity clk_gen is
    port (
        i_gclk   : in STD_LOGIC;
        i_gclk_p : in STD_LOGIC;
        i_gclk_n : in STD_LOGIC;
        
        o_pixel_clk : out STD_LOGIC;
        o_heens_clk : out STD_LOGIC
    );
end clk_gen;


architecture Behavioral of clk_gen is
    
    signal clk_fb : STD_LOGIC;  -- feedback clock used by the PLL
    
begin
    
    -- Primitive: Base Phase-Locked Loop (PLL)
    -- PLLE2_BASE
    pll_hdmi_clk_gen_inst : PLLE2_BASE
        generic map (
            BANDWIDTH    => "OPTIMIZED",
            STARTUP_WAIT => "TRUE",
            
            CLKIN1_PERIOD => 10.0,  -- 10 ns -> 100 MHz
            REF_JITTER1   => 0.000,
            
            DIVCLK_DIVIDE  => 1,   -- /1  -> 100 MHz
            CLKFBOUT_MULT  => 15,  -- *15 -> 1500 MHz
            CLKFBOUT_PHASE => 0.0,
            
            CLKOUT0_DIVIDE     => 10,  -- /10 -> 150 MHz
            CLKOUT0_DUTY_CYCLE => 0.50,
            CLKOUT0_PHASE      => 0.0,
            
            CLKOUT1_DIVIDE     => 12,  -- /12 -> 125 MHz
            CLKOUT1_DUTY_CYCLE => 0.50,
            CLKOUT1_PHASE      => 0.0
        )
        port map (
            CLKIN1   => i_gclk,  -- 100 MHz
            RST      => '0',
            CLKFBIN  => clk_fb,
            CLKFBOUT => clk_fb,
            PWRDWN   => '0',
            
            CLKOUT0 => o_pixel_clk,  -- 150 MHz
            CLKOUT1 => o_heens_clk   -- 125 MHz
        );
    
end Behavioral;
