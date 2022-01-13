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
    
--     signal unbuff_clk : STD_LOGIC;  -- result clock from the differential clocks - @200 MHz
    signal buff_clk : STD_LOGIC;  -- result clock from the differential clocks - @200 MHz
    signal clk_fb   : STD_LOGIC;  -- feedback clock used by the PLL
    
begin
    
    -- IBUFDS: Differential Input Buffer
    -- Xilinx HDL Libraries Guide, version 2012.2
    differential_input_buffer_inst : IBUFDS
        generic map (
            DIFF_TERM    => FALSE,  -- Differential Termination
            IBUF_LOW_PWR => TRUE,   -- Low power (TRUE) vs. performance (FALSE) setting for referenced I/O standards
            IOSTANDARD   => "DEFAULT"
        )
        port map (
            O  => buff_clk,  -- Buffer output
            I  => i_gclk_p,  -- Diff_p buffer input (connect directly to top-level port)
            IB => i_gclk_n   -- Diff_n buffer input (connect directly to top-level port)
        );
    
--            -- BUFG: Global Clock Simple Buffer
--            -- Xilinx HDL Libraries Guide, version 2012.2
--            clock_buffer_inst : BUFG
--                port map (
--                    O => buff_clk,   -- 1-bit output: Clock output
--                    I => unbuff_clk  -- 1-bit input: Clock input
--                );
    
    -- Primitive: Base Phase-Locked Loop (PLL)
    -- PLLE2_BASE
    pll_hdmi_clk_gen_inst : PLLE2_BASE
        generic map (
            BANDWIDTH    => "OPTIMIZED",
            STARTUP_WAIT => "TRUE",
            
            CLKIN1_PERIOD => 5.0,  -- 5 ns -> 200 MHz
            REF_JITTER1   => 0.000,
            
            DIVCLK_DIVIDE  => 2,   -- /2  -> 100 MHz
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
            clkin1   => buff_clk,  -- 200 MHz
            rst      => '0',
            clkfbin  => clk_fb,
            clkfbout => clk_fb,
            pwrdwn   => '0',
            
            clkout0 => o_pixel_clk,  -- 150 MHz
            clkout1 => o_heens_clk   -- 125 MHz
        );
        
end Behavioral;
