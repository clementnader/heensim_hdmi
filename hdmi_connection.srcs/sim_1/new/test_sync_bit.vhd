----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2021 09:59:33 AM
-- Design Name: 
-- Module Name: test_sync_bit - Behavioral
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

library work;
    use work.events_list.ALL;


entity test_sync_bit is
end test_sync_bit;


architecture Behavioral of test_sync_bit is
    
    signal src_clk  : STD_LOGIC := '1';
    signal dest_clk : STD_LOGIC := '1';
    
    signal src      : STD_LOGIC := '0';
    signal dest     : STD_LOGIC;
    
    signal current_ts : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
    
    constant C_SRC_PERIOD  : TIME := 3.33 ns;
    constant C_DEST_PERIOD : TIME := 4 ns;
    
begin
    
    -- Generate the clock
    src_clk  <= not src_clk  after C_SRC_PERIOD;   -- 150 MHz
    dest_clk <= not dest_clk after C_DEST_PERIOD;  -- 125 MHz
    
--    xpm_cdc_single_inst : xpm_cdc_single
--    generic map (
--        DEST_SYNC_FF   => 2, -- DECIMAL; range: 2-10
--        INIT_SYNC_FF   => 0, -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
--        SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
--        SRC_INPUT_REG  => 0  -- DECIMAL; 0=do not register input, 1=register input
--    )
--    port map (
--        dest_out => dest,  -- 1-bit output: src_in synchronized to the destination clock domain. This output is registered.
--        dest_clk => dest_clk, -- 1-bit input: Clock signal for the destination clock domain.
--        src_clk  => src_clk,  -- 1-bit input: optional; required when SRC_INPUT_REG = 1
--        src_in   => src    -- 1-bit input: Input signal to be synchronized to dest_clk domain.
--    );
    
    xpm_cdc_single_inst : xpm_cdc_single
    generic map (
        DEST_SYNC_FF   => 2, -- DECIMAL; range: 2-10
        INIT_SYNC_FF   => 0, -- DECIMAL; 0=disable simulation init values, 1=enable simulation init values
        SIM_ASSERT_CHK => 0, -- DECIMAL; 0=disable simulation messages, 1=enable simulation messages
        SRC_INPUT_REG  => 0  -- DECIMAL; 0=do not register input, 1=register input
    )
    port map (
        dest_out => dest,  -- 1-bit output: src_in synchronized to the destination clock domain. This output is registered.
        dest_clk => dest_clk, -- 1-bit input: Clock signal for the destination clock domain.
        src_clk  => src_clk,  -- 1-bit input: optional; required when SRC_INPUT_REG = 1
        src_in   => src    -- 1-bit input: Input signal to be synchronized to dest_clk domain.
    );
    
    get_current_timestamp_test : entity work.get_current_timestamp
    port map (
        i_clk           => dest_clk,
        i_rst           => '0',
        i_freeze_screen => '0',
        i_ph_dist       => dest,
        
        o_current_ts => current_ts
    );
    
    -- Testbench sequence
    process is
    begin
        wait for 4*C_SRC_PERIOD;
        src <= '1';
        wait for 2*C_SRC_PERIOD;
        src <= '0';
        wait for 8*C_SRC_PERIOD;
        src <= '1';
        wait for 2*C_SRC_PERIOD;
        src <= '0';
        wait for 4*C_SRC_PERIOD;
        
    end process;
    
end Behavioral;
