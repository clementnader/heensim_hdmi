----------------------------------------------------------------------------------
-- Engineer:    Mike Field <hamster@snap.net.nz> 
-- Module Name: vga_hdmi - Behavioral 
-- 
-- Description: A test of the Zedboard's VGA & HDMI interface
--
-- Feel free to use this how you see fit, and fix any errors you find :-)
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library work;
    use work.hdmi_resolution.ALL;
    use work.events_list.ALL;


entity vga_hdmi is
    port (
        GCLK : in STD_LOGIC;
        SW   : in STD_LOGIC_VECTOR(2 downto 0);
        BTNC : in STD_LOGIC;
        
        HDMI_CLK   : out STD_LOGIC;
        HDMI_D     : out STD_LOGIC_VECTOR(15 downto 0);
        HDMI_DE    : out STD_LOGIC;
        HDMI_HSYNC : out STD_LOGIC;
        HDMI_VSYNC : out STD_LOGIC;
        HDMI_SCL   : out STD_LOGIC;
        HDMI_SDA   : out STD_LOGIC
    );
end vga_hdmi;


architecture Behavioral of vga_hdmi is
    
    component stabilize_inputs
        generic (
            G_NB_INPUTS : INTEGER
        );
        port (
            i_clk : in STD_LOGIC;
            i_in  : in STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
            
            o_out : out STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0)
        );
    end component;
    
    component HEENSim
        generic (
            G_DATA_SIZE : INTEGER;
            G_PERIOD    : INTEGER
        );
        port (
            i_clk           : in STD_LOGIC;
            i_rst           : in STD_LOGIC;
            i_freeze_screen : in STD_LOGIC;
            i_rd_en         : in STD_LOGIC;
            
            o_dout       : out STD_LOGIC_VECTOR(17 downto 0);
            o_empty      : out STD_LOGIC;
            o_valid      : out STD_LOGIC;
            o_data_count : out STD_LOGIC_VECTOR(9 downto 0);
            o_ph_exec    : out STD_LOGIC;
            o_ph_dist    : out STD_LOGIC
        );
    end component;
    
    component read_fifo_spikes
        port (
            i_clk           : in STD_LOGIC;
            i_rst           : in STD_LOGIC;
            i_freeze_screen : in STD_LOGIC;
            i_ph_dist       : in STD_LOGIC;
            i_empty         : in STD_LOGIC;
            i_valid         : in STD_LOGIC;
            i_fifo_dout     : in STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
            i_end_screen    : in STD_LOGIC;
            
            o_fifo_rd_en  : out STD_LOGIC;
            o_mem_wr_en   : out STD_LOGIC;
            o_mem_wr_we   : out STD_LOGIC;
            o_mem_wr_addr : out STD_LOGIC_VECTOR(9 downto 0);
            o_mem_wr_din  : out STD_LOGIC_VECTOR(C_MAX_ID downto 0)
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
    
    component get_current_timestamp
        port ( 
            i_clk           : in STD_LOGIC;
            i_rst           : in STD_LOGIC;
            i_freeze_screen : in STD_LOGIC;
            i_ph_dist       : in STD_LOGIC;
            
            o_current_ts : out STD_LOGIC_VECTOR (C_LENGTH_TIMESTAMP-1 downto 0)
        );
    end component;
    
    component raster_plot
        port (
            i_clk           : in STD_LOGIC;
            i_rst           : in STD_LOGIC;
            i_freeze_screen : in STD_LOGIC;
            i_hcounter      : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter      : in STD_LOGIC_VECTOR(11 downto 0);
            i_mem_rd_data   : in STD_LOGIC_VECTOR(C_MAX_ID downto 0);
            i_current_ts    : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            i_extend_vaxis  : in STD_LOGIC;
            i_bigger_dots   : in STD_LOGIC;
            
            o_mem_rd_en   : out STD_LOGIC;
            o_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
            o_color       : out STD_LOGIC_VECTOR(23 downto 0);
            o_end_screen  : out STD_LOGIC
        );
    end component;
    
    component hdmi_connection
        port (
            i_clk   : in STD_LOGIC;
            i_clk90 : in STD_LOGIC;
            i_color : in STD_LOGIC_VECTOR(23 downto 0);
            
            o_hcounter   : out STD_LOGIC_VECTOR(11 downto 0);
            o_vcounter   : out STD_LOGIC_VECTOR(11 downto 0);
            o_hdmi_clk   : out STD_LOGIC;
            o_hdmi_d     : out STD_LOGIC_VECTOR(15 downto 0);
            o_hdmi_de    : out STD_LOGIC;
            o_hdmi_hsync : out STD_LOGIC;
            o_hdmi_vsync : out STD_LOGIC;
            o_hdmi_scl   : out STD_LOGIC;
            o_hdmi_sda   : out STD_LOGIC
        );
    end component;
    
    component clk_wiz_0 
        port (
            clk_in1 : in STD_LOGIC;
            reset   : in STD_LOGIC;
            
            clk        : out STD_LOGIC;
            clk_150    : out STD_LOGIC;
            clk_150_90 : out STD_LOGIC
        );
    end component;
    
    -- Clocking
    signal clk        : STD_LOGIC;
    signal clk_150    : STD_LOGIC;
    signal clk_150_90 : STD_LOGIC;
    signal current_ts : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
    
    -- Stabilized inputs
    signal rst               : STD_LOGIC;
    signal freeze_screen     : STD_LOGIC;
    
    signal rst_150           : STD_LOGIC;
    signal freeze_screen_150 : STD_LOGIC;
    signal extend_vaxis_150  : STD_LOGIC;
    signal bigger_dots_150   : STD_LOGIC;
    
    -- State signals
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
    
    signal mem_rd_en   : STD_LOGIC;
    signal mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    signal mem_rd_data : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
    
    -- Signals from the plot generator
    signal plot_hcounter   : STD_LOGIC_VECTOR(11 downto 0);
    signal plot_vcounter   : STD_LOGIC_VECTOR(11 downto 0);
    signal plot_color      : STD_LOGIC_VECTOR(23 downto 0);
    signal plot_end_screen : STD_LOGIC;

begin
    
    i_stabilize_inputs : stabilize_inputs
    generic map (
        G_NB_INPUTS => 2
    )
    port map (
        i_clk   => clk,
        i_in(0) => BTNC,
        i_in(1) => SW(0),
        
        o_out(0) => rst,
        o_out(1) => freeze_screen
    );
    
    i_stabilize_inputs_150 : stabilize_inputs
    generic map (
        G_NB_INPUTS => 4
    )
    port map (
        i_clk   => clk_150,
        i_in(0) => BTNC,
        i_in(1) => SW(0),
        i_in(2) => SW(1),
        i_in(3) => SW(2),
        
        o_out(0) => rst_150,
        o_out(1) => freeze_screen_150,
        o_out(2) => extend_vaxis_150,
        o_out(3) => bigger_dots_150
    );
    
    i_HEENSim : HEENSim
    generic map (
        G_DATA_SIZE => 1,
        G_PERIOD    => 125_000  -- Tspike = 1 ms
    )
    port map (
        i_clk           => clk,
        i_rst           => rst,
        i_freeze_screen => freeze_screen,
        i_rd_en         => fifo_rd_en,
        
        o_dout       => fifo_dout,
        o_empty      => fifo_empty,
        o_valid      => fifo_valid,
        o_data_count => open,
        o_ph_exec    => open,
        o_ph_dist    => ph_dist
    );
    
    i_read_fifo_spikes : read_fifo_spikes
    port map (
        i_clk           => clk,
        i_rst           => rst,
        i_freeze_screen => freeze_screen,
        i_ph_dist       => ph_dist,
        i_empty         => fifo_empty,
        i_valid         => fifo_valid,
        i_fifo_dout     => fifo_dout,
        i_end_screen    => plot_end_screen,
        
        o_fifo_rd_en  => fifo_rd_en,
        o_mem_wr_en   => mem_wr_en,
        o_mem_wr_we   => mem_wr_we,
        o_mem_wr_addr => mem_wr_addr,
        o_mem_wr_din  => mem_wr_din
    );
    
    i_blk_mem_gen_1 : blk_mem_gen_1
    port map (
        clka   => clk,
        ena    => mem_wr_en,
        wea(0) => mem_wr_we,
        addra  => mem_wr_addr,
        dina   => mem_wr_din,
        douta  => open,
        
        clkb   => clk_150,
        enb    => mem_rd_en,
        web(0) => '0',
        addrb  => mem_rd_addr,
        dinb   => (C_MAX_ID downto 0 => '0'),
        doutb  => mem_rd_data
    );
    
    i_get_current_timestamp : get_current_timestamp
    port map ( 
        i_clk           => clk_150,
        i_rst           => rst_150,
        i_freeze_screen => freeze_screen_150,
        i_ph_dist       => ph_dist,
        
        o_current_ts => current_ts
    );
    
    i_raster_plot : raster_plot
    port map (
        i_clk           => clk_150,
        i_rst           => rst_150,
        i_freeze_screen => freeze_screen_150,
        i_hcounter      => plot_hcounter,
        i_vcounter      => plot_vcounter,
        i_mem_rd_data   => mem_rd_data,
        i_current_ts    => current_ts,
        i_extend_vaxis  => extend_vaxis_150,
        i_bigger_dots   => bigger_dots_150,
        
        o_mem_rd_en   => mem_rd_en,
        o_mem_rd_addr => mem_rd_addr,
        o_color       => plot_color,
        o_end_screen  => plot_end_screen
    );
    
    i_hdmi_connection : hdmi_connection
    port map (
        i_clk   => clk_150,
        i_clk90 => clk_150_90,
        i_color => plot_color,
        
        o_hcounter   => plot_hcounter,
        o_vcounter   => plot_vcounter,
        o_hdmi_clk   => HDMI_CLK,
        o_hdmi_d     => HDMI_D,
        o_hdmi_de    => HDMI_DE,
        o_hdmi_hsync => HDMI_HSYNC,
        o_hdmi_vsync => HDMI_VSYNC,
        o_hdmi_scl   => HDMI_SCL,
        o_hdmi_sda   => HDMI_SDA
    );
    
    i_clk_wiz : clk_wiz_0
    port map (
        clk_in1 => GCLK,  -- 100 MHz
        reset   => '0',
        
        clk        => clk,        -- 125 MHz
        clk_150    => clk_150,    -- 150 MHz
        clk_150_90 => clk_150_90  -- 150 MHz, phase shift 90°
    );
    
end Behavioral;
