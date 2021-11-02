----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/19/2021 03:06:18 PM
-- Design Name: 
-- Module Name: test_fifo_reading - Behavioral
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


entity test_fifo_reading is
end test_fifo_reading;


architecture Behavioral of test_fifo_reading is

    component HEENSim
        generic (
            G_DATA_SIZE : INTEGER;
            G_PERIOD    : INTEGER
        );
        port (
            i_wr_clk        : in STD_LOGIC;
            i_rd_clk        : in STD_LOGIC;
            i_rst           : in STD_LOGIC;
            i_freeze_screen : in STD_LOGIC;
            i_rd_en         : in STD_LOGIC;
            
            o_dout    : out STD_LOGIC_VECTOR(17 downto 0);
            o_empty   : out STD_LOGIC;
            o_valid   : out STD_LOGIC;
            o_ph_exec : out STD_LOGIC;
            o_ph_dist : out STD_LOGIC
            
            
--            o_mem_en     : out STD_LOGIC;
--            o_mem_addr   : out STD_LOGIC_VECTOR(10 downto 0);
--            o_mem_dout   : out STD_LOGIC_VECTOR(17 downto 0);
--            o_fifo_wr_en : out STD_LOGIC;
--            o_fifo_din   : out STD_LOGIC_VECTOR(17 downto 0)
        );
    end component;
    
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
    signal clk        : STD_LOGIC := '1';
    signal clk_150    : STD_LOGIC := '1';
    signal current_ts : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
    
    -- Reset signal
    signal rst : STD_LOGIC := '1';
    
    -- State variables
    signal ph_exec : STD_LOGIC;
    signal ph_dist : STD_LOGIC;
    
    -- Signals from the FIFO
    signal fifo_dout  : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
    signal fifo_rd_en : STD_LOGIC;
    signal fifo_empty : STD_LOGIC;
    signal fifo_valid : STD_LOGIC;
    
    -- Signals from the memory block
    signal mem_wr_en   : STD_LOGIC;
    signal mem_wr_we   : STD_LOGIC;
    signal mem_wr_addr : STD_LOGIC_VECTOR(9 downto 0);
    signal mem_wr_din  : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
    
    signal end_screen          : STD_LOGIC := '0';
    signal end_screen_clk      : STD_LOGIC := '1';
    signal end_screen_prev_clk : STD_LOGIC := '1';
    
    
    -- BRAM
    signal mem_en   : STD_LOGIC;
    signal mem_addr : STD_LOGIC_VECTOR(10 downto 0);
    signal mem_dout : STD_LOGIC_VECTOR(17 downto 0);
    -- FIFO
    signal fifo_wr_en : STD_LOGIC;
    signal fifo_din   : STD_LOGIC_VECTOR(17 downto 0);
    
    
--    signal state        : T_STATE := IDLE;
--    signal neuron_id    : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
--    signal id_value     : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
    
--    signal buffer_en   : STD_LOGIC;
--    signal buffer_we   : STD_LOGIC;
--    signal buffer_addr : STD_LOGIC_VECTOR(4 downto 0);
--    signal buffer_din  : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
--    signal buffer_dout : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
    
--    signal buffer_cnt      : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    
--    signal transfer_from_buffer : STD_LOGIC;
--    signal transfer_addr        : STD_LOGIC_VECTOR(9 downto 0);
    
begin
    
--    i_HEENSim : HEENSim
--    generic map (
--        G_DATA_SIZE => 5,
--        G_PERIOD    => 125_000  -- Tspike = 1 ms
--    )
--    port map (
--        i_wr_clk        => clk,
--        i_rd_clk        => clk_150,
--        i_rst           => rst,
--        i_freeze_screen => '0',
--        i_rd_en         => fifo_rd_en,
        
--        o_dout       => fifo_dout,
--        o_empty      => fifo_empty,
--        o_valid      => fifo_valid,
--        o_ph_exec    => ph_exec,
--        o_ph_dist    => ph_dist
        
----        o_mem_en     => mem_en,
----        o_mem_addr   => mem_addr,
----        o_mem_dout   => mem_dout,
----        o_fifo_wr_en => fifo_wr_en,
----        o_fifo_din   => fifo_din
--    );
    
--    i_blk_mem_gen_1 : blk_mem_gen_1
--    port map (
--        clka   => clk_150,
--        ena    => mem_wr_en,
--        wea(0) => mem_wr_we,
--        addra  => mem_wr_addr,
--        dina   => mem_wr_din,
--        douta  => open,
        
--        clkb   => clk_150,
--        enb    => '0',
--        web(0) => '0',
--        addrb  => (9 downto 0 => '0'),
--        dinb   => (C_MAX_ID downto 0 => '0'),
--        doutb  => open
--    );
    
--    -- Generate the clock
--    clk            <= not clk     after 4 ns;     -- 125 MHz
--    clk_150        <= not clk_150 after 3.33 ns;  -- 150 MHz
    
--    end_screen_clk <= not end_screen_clk after 8 ms;
    
--    process(clk_150)
--    begin
--        if rising_edge(clk_150) then
--            if end_screen_prev_clk = '0' and end_screen_clk = '1' then
--                end_screen_prev_clk <= end_screen_clk;
--                end_screen <= '1';
--            else
--                end_screen_prev_clk <= end_screen_clk;
--                end_screen <= '0';
--            end if;
--        end if;
--    end process;
    
--    test_read_fifo_spikes : entity work.read_fifo_spikes
--    port map (
--        i_clk           => clk_150,
--        i_rst           => rst,
--        i_freeze_screen => '0',
--        i_ph_dist       => ph_dist,
--        i_empty         => fifo_empty,
--        i_valid         => fifo_valid,
--        i_fifo_dout     => fifo_dout,
--        i_end_screen    => end_screen,
        
--        o_fifo_rd_en  => fifo_rd_en,
--        o_mem_wr_en   => mem_wr_en,
--        o_mem_wr_we   => mem_wr_we,
--        o_mem_wr_addr => mem_wr_addr,
--        o_mem_wr_din  => mem_wr_din,
--        o_current_ts  => current_ts
        
        
----        o_state                => state               ,
----        o_neuron_id            => neuron_id           ,
----        o_id_value             => id_value            ,
----        o_buffer_en            => buffer_en           ,
----        o_buffer_we            => buffer_we           ,
----        o_buffer_addr          => buffer_addr         ,
----        o_buffer_din           => buffer_din          ,
----        o_buffer_dout          => buffer_dout         ,
----        o_buffer_cnt           => buffer_cnt          ,
----        o_transfer_from_buffer => transfer_from_buffer,
----        o_transfer_addr        => transfer_addr       
--    );
    
--    -- Testbench sequence
--    process is
--    begin
--        wait for 0.1 us;
--        rst <= '0';
--        wait for 16 ms;
        
--    end process;
    
end Behavioral;
