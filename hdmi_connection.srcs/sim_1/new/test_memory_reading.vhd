----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/21/2021 04:13:48 PM
-- Design Name: 
-- Module Name: test_memory_reading - Behavioral
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


entity test_memory_reading is
end test_memory_reading;


architecture Behavioral of test_memory_reading is

    component blk_mem_gen_1
        port (
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(9 downto 0);
            dina  : in STD_LOGIC_VECTOR(C_MAX_ID downto 0);
            douta : out STD_LOGIC_VECTOR(C_MAX_ID downto 0);
            
            clkb  : in STD_LOGIC;
            enb   : in STD_LOGIC;
            web   : in STD_LOGIC_VECTOR(0 downto 0);
            addrb : in STD_LOGIC_VECTOR(9 downto 0);
            dinb  : in STD_LOGIC_VECTOR(C_MAX_ID downto 0);
            doutb : out STD_LOGIC_VECTOR(C_MAX_ID downto 0)
        );
    end component;
    
    -- Clocking
    signal clk_150    : STD_LOGIC := '1';
    signal current_ts : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0) := std_logic_vector(to_unsigned(200, C_LENGTH_TIMESTAMP));
    
    -- Inputs
    signal extend_vaxis_150 : STD_LOGIC := '0';
    signal bigger_dots_150  : STD_LOGIC := '0';
    
    -- Signals from the memory block
    signal mem_rd_en   : STD_LOGIC;
    signal mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    signal mem_rd_data : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
    
    -- Signals from the plot generator
    signal plot_hcounter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal plot_vcounter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal plot_color    : STD_LOGIC_VECTOR(23 downto 0);
    
begin
    
    blk_mem_gen_1_inst : blk_mem_gen_1
    port map (
        clka   => clk_150,
        ena    => '0',
        wea(0) => '0',
        addra  => (9 downto 0 => '0'),
        dina   => (C_MAX_ID downto 0 => '0'),
        douta  => open,
        
        clkb   => clk_150,
        enb    => mem_rd_en,
        web(0) => '0',
        addrb  => mem_rd_addr,
        dinb   => (C_MAX_ID downto 0 => '0'),
        doutb  => mem_rd_data
    );
    
    -- Generate the clock
    clk_150 <= not clk_150 after 3.33 ns;  -- 150 MHz
--    current_ts <= current_ts + 1 after 1 ms;
    
    test_read_fifo_spikes : entity work.raster_plot
    port map (
        i_clk           => clk_150,
        i_rst           => '0',
        i_freeze_screen => '0',
        i_hcounter      => plot_hcounter,
        i_vcounter      => plot_vcounter,
        i_mem_rd_data   => mem_rd_data,
        i_current_ts    => current_ts,
        i_extend_vaxis  => extend_vaxis_150,
--        i_bigger_dots   => bigger_dots_150,
        
        o_mem_rd_en   => mem_rd_en,
        o_mem_rd_addr => mem_rd_addr,
        o_color       => plot_color,
        o_end_screen  => open
    );
    
    -- Advance the position counters
    counters_process : process(clk_150)
    begin
        if rising_edge(clk_150) then
            -- Advance the position counters
            if plot_hcounter < C_H_MAX then
                plot_hcounter <= plot_hcounter + 1;
            else
                -- starting a new line
                plot_hcounter <= (others => '0');
                if plot_vcounter < C_V_MAX then
                    plot_vcounter <= plot_vcounter + 1;
                else
                    -- starting a new screen
                    plot_vcounter <= (others => '0');
                end if;
            end if;
        end if;
    end process;
    
    -- Testbench sequence
    process is
    begin
        wait for 1_000 ms;
        extend_vaxis_150 <= '1';
        
        wait for 2_000 ms;
        extend_vaxis_150 <= '0';
        
        wait for 2_000 ms;
        
    end process;
    
    
end Behavioral;
