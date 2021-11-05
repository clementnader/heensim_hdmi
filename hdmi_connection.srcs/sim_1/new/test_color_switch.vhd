----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/05/2021 04:20:28 PM
-- Design Name: 
-- Module Name: test_color_switch - Behavioral
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
    use work.hdmi_resolution.ALL;
    use work.events_list.ALL;


entity test_color_switch is
end test_color_switch;


architecture Behavioral of test_color_switch is
    
--    component HEENSim
--        generic(
--            data_size   : INTEGER := 10;
--            exec_period : INTEGER := 125_000
--        );
--        port (
--            wr_clk : in STD_LOGIC;
--            rd_clk : in STD_LOGIC;
--            rst    : in STD_LOGIC;
--            rd_en  : in STD_LOGIC;
            
--            dout    : out STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
--            empty   : out STD_LOGIC;
--            valid   : out STD_LOGIC;
--            ph_exec : out STD_LOGIC;
--            ph_dist : out STD_LOGIC
--         );
--    end component;
    
--    component get_current_time
--        port (
--            i_clk     : in STD_LOGIC;
--            i_rst     : in STD_LOGIC;
--            i_ph_dist : in STD_LOGIC;
            
--            o_current_ts : out STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0)
--        );
--    end component;
    
    -- Clocking
    signal clk        : STD_LOGIC := '1';
    signal clk_150    : STD_LOGIC := '1';
    signal current_ts : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0) := (others => '0');
    
    -- Reset signal
    signal rst : STD_LOGIC := '1';
    
    -- State variables
    signal ph_exec : STD_LOGIC := '0';
    signal ph_dist : STD_LOGIC := '0';
    
    -- Signals from the FIFO
    signal fifo_dout  : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
    signal fifo_rd_en : STD_LOGIC;
    signal fifo_empty : STD_LOGIC;
    signal fifo_valid : STD_LOGIC;
    
    -- Signals from the plot generator
    signal hcounter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal vcounter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal color    : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');

begin
--    HEENSim_inst : HEENSim
--    generic map (
--        data_size   => 10,
--        exec_period => 1000
--    )
--    port map (
--        wr_clk => clk,
--        rd_clk => clk_150,
--        rst    => rst,
--        rd_en  => fifo_rd_en,
        
--        dout    => fifo_dout,
--        empty   => fifo_empty,
--        valid   => fifo_valid,
--        ph_exec => ph_exec,
--        ph_dist => ph_dist
--    );
    
--    -- The device under test (create_plot)
--    test_create_plot : entity work.create_plot
--    port map (
--        i_clk        => clk,
--        i_rst        => rst,
--        i_ph_dist    => ph_dist,
--        i_empty      => fifo_empty,
--        i_valid      => fifo_valid,
--        i_dout_fifo  => fifo_dout,
--        i_current_ts => current_ts,
--        i_hcounter   => hcounter,
--        i_vcounter   => vcounter,
        
--        o_rd_en => fifo_rd_en,
--        o_color => color
--    );
    
--    -- Generate the clock
--    clk     <= not clk     after 4 ns;     -- 125 MHz
--    clk_150 <= not clk_150 after 3.33 ns;  -- 150 MHz
    
--    -- Advance the position counters
--    counters_process : process(clk_150)
--    begin
--        if rising_edge(clk_150) then
--            -- Advance the position counters
--            if hcounter < C_H_MAX then
--                hcounter <= hcounter + 1;
--            else
--                -- starting a new line
--                hcounter <= (others => '0');
--                if vcounter < C_V_MAX then
--                    vcounter <= vcounter + 1;
--                else
--                    -- starting a new screen
--                    vcounter <= (others => '0');
--                end if;
--            end if;
--        end if;
--    end process;
    
--    -- Testbench sequence
--    process is
--    begin
--        wait for 0.1 ms;
--        rst <= '0';
--        wait for 0.2 ms;
        
--        wait for 0.3 ms;
        
--        wait for 0.4 ms;
        
--        wait for 0.4 ms;
        
--        wait for 0.1 ms;
        
--        wait for 0.2 ms;
        
--        wait for 1 ms;
        
--    end process;

end Behavioral;
