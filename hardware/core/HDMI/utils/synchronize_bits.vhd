----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/03/2021 12:54:47 PM
-- Design Name: 
-- Module Name: synchronize_bits - Behavioral
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

library XPM;
    use XPM.VComponents.ALL;


entity synchronize_bits is
    generic (
        G_NB_INPUTS : INTEGER
    );
    port (
        i_src_clk : in STD_LOGIC;
        i_src     : in STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
        
        i_dest_clk : in STD_LOGIC;
        o_dest     : out STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0)
    );
end synchronize_bits;


architecture Behavioral of synchronize_bits is
    
begin
    
    xpm_cdc_single_gen :
    for i in 0 to G_NB_INPUTS-1 generate
        -- xpm_cdc_single: Single-bit Synchronizer
        -- Xilinx Parameterized Macro, version 2018.2
        xpm_cdc_single_inst : xpm_cdc_single
            generic map (
                DEST_SYNC_FF   => 2, -- DECIMAL; range: 2-10
                INIT_SYNC_FF   => 0, -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
                SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
                SRC_INPUT_REG  => 1  -- DECIMAL; 0=do not register input, 1=register input
            )
            port map (
                dest_out => o_dest(i),  -- 1-bit output: src_in synchronized to the destination clock domain. This output is registered.
                dest_clk => i_dest_clk, -- 1-bit input: Clock signal for the destination clock domain.
                src_clk  => i_src_clk,  -- 1-bit input: optional; required when SRC_INPUT_REG = 1
                src_in   => i_src(i)    -- 1-bit input: Input signal to be synchronized to dest_clk domain.
            );
    end generate;
    
end Behavioral;
