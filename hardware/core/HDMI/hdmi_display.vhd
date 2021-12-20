----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/15/2021 07:44:26 PM
-- Design Name: 
-- Module Name: hdmi_display - Behavioral 
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

library work;
    use work.neurons_pkg.ALL;


entity hdmi_display is
    port (
        i_heens_clk         : in STD_LOGIC;
        i_pixel_clk         : in STD_LOGIC;
        i_rst               : in STD_LOGIC;
        i_btn               : in STD_LOGIC;
        i_ph_dist           : in STD_LOGIC;
        i_spikes_fifo_empty : in STD_LOGIC;
        i_spikes_fifo_valid : in STD_LOGIC;
        i_spikes_fifo_dout  : in STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
        i_analog_fifo_empty : in STD_LOGIC;
        i_analog_fifo_valid : in STD_LOGIC;
        i_analog_fifo_dout  : in STD_LOGIC_VECTOR(C_ANALOG_VALUE_SIZE-1 downto 0);
        
        o_spikes_hdmi_rd_fifo : out STD_LOGIC;
        o_analog_hdmi_rd_fifo : out STD_LOGIC;
        o_hdmi_clk            : out STD_LOGIC;
        o_hdmi_d              : out STD_LOGIC_VECTOR(35 downto 0);
        o_hdmi_de             : out STD_LOGIC;
        o_hdmi_hsync          : out STD_LOGIC;
        o_hdmi_vsync          : out STD_LOGIC;
        o_hdmi_scl            : out STD_LOGIC;
        o_hdmi_sda            : out STD_LOGIC
    );
end hdmi_display;


architecture Behavioral of hdmi_display is
    
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
    
    component flip_flop_inputs
        generic (
            G_NB_INPUTS : INTEGER
        );
        port (
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            i_in  : in STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
            
            o_out : out STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component synchronize_bits
        generic (
            G_NB_INPUTS : INTEGER
        );
        port (
            i_src_clk : in STD_LOGIC;
            i_src     : in STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
            
            i_dest_clk : in STD_LOGIC;
            o_dest     : out STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component get_current_timestamp
        port ( 
            i_clk     : in STD_LOGIC;
            i_rst     : in STD_LOGIC;
            i_ph_dist : in STD_LOGIC;
            
            o_current_timestamp : out STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component read_fifo_spikes
        port (
            i_clk               : in STD_LOGIC;
            i_rst               : in STD_LOGIC;
            i_ph_dist           : in STD_LOGIC;
            i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            i_fifo_empty        : in STD_LOGIC;
            i_fifo_valid        : in STD_LOGIC;
            i_fifo_dout         : in STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
            i_end_screen        : in STD_LOGIC;
            
            o_hdmi_rd_fifo  : out STD_LOGIC;
            o_mem_wr_en     : out STD_LOGIC;
            o_mem_wr_we     : out STD_LOGIC;
            o_mem_wr_addr   : out STD_LOGIC_VECTOR(9 downto 0);
            o_mem_wr_din    : out STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
            o_transfer_done : out STD_LOGIC
        );
    end component;
    
    component blk_mem_gen_0
        port (
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(9 downto 0);
            dina  : in STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
            douta : out STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
            
            clkb  : in STD_LOGIC;
            enb   : in STD_LOGIC;
            web   : in STD_LOGIC_VECTOR(0 downto 0);
            addrb : in STD_LOGIC_VECTOR(9 downto 0);
            dinb  : in STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
            doutb : out STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component read_fifo_analog
        port (
            i_clk               : in STD_LOGIC;
            i_rst               : in STD_LOGIC;
            i_ph_dist           : in STD_LOGIC;
            i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            i_fifo_empty        : in STD_LOGIC;
            i_fifo_valid        : in STD_LOGIC;
            i_fifo_dout         : in STD_LOGIC_VECTOR(C_ANALOG_VALUE_SIZE-1 downto 0);
            i_end_screen        : in STD_LOGIC;
            
            o_hdmi_rd_fifo  : out STD_LOGIC;
            o_mem_wr_en     : out STD_LOGIC;
            o_mem_wr_we     : out STD_LOGIC;
            o_mem_wr_addr   : out STD_LOGIC_VECTOR(9 downto 0);
            o_mem_wr_din    : out STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
            o_transfer_done : out STD_LOGIC                                  
        );
    end component;
    
    component blk_mem_gen_2
        port (
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(9 downto 0);
            dina  : in STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
            douta : out STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
            
            clkb  : in STD_LOGIC;
            enb   : in STD_LOGIC;
            web   : in STD_LOGIC_VECTOR(0 downto 0);
            addrb : in STD_LOGIC_VECTOR(9 downto 0);
            dinb  : in STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
            doutb : out STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component generate_screen
        port (
            i_clk                : in STD_LOGIC;
            i_rst                : in STD_LOGIC;
            i_current_timestamp  : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
            i_hcounter           : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter           : in STD_LOGIC_VECTOR(11 downto 0);
            i_spikes_mem_rd_data : in STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
            i_analog_mem_rd_data : in STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
            i_extend_vaxis       : in STD_LOGIC;
            i_transfer_done      : in STD_LOGIC;
            
            o_hcounter           : out STD_LOGIC_VECTOR(11 downto 0);
            o_vcounter           : out STD_LOGIC_VECTOR(11 downto 0);
            o_spikes_mem_rd_en   : out STD_LOGIC;
            o_spikes_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
            o_analog_mem_rd_en   : out STD_LOGIC;
            o_analog_mem_rd_addr : out STD_LOGIC_VECTOR(9 downto 0);
            o_color              : out STD_LOGIC_VECTOR(23 downto 0);
            o_end_screen         : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component hdmi_connection
        port (
            i_clk      : in STD_LOGIC;
            i_rst      : in STD_LOGIC;
            i_color    : in STD_LOGIC_VECTOR(23 downto 0);
            i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_hcounter   : out STD_LOGIC_VECTOR(11 downto 0);
            o_vcounter   : out STD_LOGIC_VECTOR(11 downto 0);
            o_hdmi_clk   : out STD_LOGIC;
            o_hdmi_d     : out STD_LOGIC_VECTOR(35 downto 0);
            o_hdmi_de    : out STD_LOGIC;
            o_hdmi_hsync : out STD_LOGIC;
            o_hdmi_vsync : out STD_LOGIC;
            o_hdmi_scl   : out STD_LOGIC;
            o_hdmi_sda   : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    -- Reset signal
    signal pixel_clk_rst : STD_LOGIC;
    
    -- Stabilized inputs
    signal buff_btn : STD_LOGIC;
    
    -- Extend vertical axis input signal
    signal extend_vaxis : STD_LOGIC;
    
    -- State signals
    signal pixel_clk_ph_dist : STD_LOGIC;
    
    -- Timestamps signals
    signal heens_clk_current_timestamp : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
    signal pixel_clk_current_timestamp : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
    
    -- Signals from the spikes memory block
    signal spikes_mem_wr_en   : STD_LOGIC;
    signal spikes_mem_wr_we   : STD_LOGIC;
    signal spikes_mem_wr_addr : STD_LOGIC_VECTOR(9 downto 0);
    signal spikes_mem_wr_din  : STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
    
    signal spikes_mem_rd_en   : STD_LOGIC;
    signal spikes_mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    signal spikes_mem_rd_data : STD_LOGIC_VECTOR(C_RANGE_ID-1 downto 0);
    
    -- Signals from the analog memory block
    signal analog_mem_wr_en   : STD_LOGIC;
    signal analog_mem_wr_we   : STD_LOGIC;
    signal analog_mem_wr_addr : STD_LOGIC_VECTOR(9 downto 0);
    signal analog_mem_wr_din  : STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
    
    signal analog_mem_rd_en   : STD_LOGIC;
    signal analog_mem_rd_addr : STD_LOGIC_VECTOR(9 downto 0);
    signal analog_mem_rd_data : STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
    
    -- Signals from the plot generator
    signal color_hcounter : STD_LOGIC_VECTOR(11 downto 0);  -- horizontal counter generated by hdmi_display
    signal color_vcounter : STD_LOGIC_VECTOR(11 downto 0);  -- vertical counter generated by hdmi_display
    signal plot_hcounter  : STD_LOGIC_VECTOR(11 downto 0);  -- horizontal counter delayed used by hdmi_display
    signal plot_vcounter  : STD_LOGIC_VECTOR(11 downto 0);  -- vertical counter delayed used by hdmi_display
    signal plot_color     : STD_LOGIC_VECTOR(23 downto 0);  -- colors RGB (color depth 8 bits) used by hdmi_display
    
    -- Flags to tell the end of the visible screen has been reached, the memory can be updated
    signal heens_clk_plot_end_screen : STD_LOGIC;
    signal pixel_clk_plot_end_screen : STD_LOGIC;
    
    -- Flags to tell the memory has be updated, the new time can get set
    signal heens_clk_sp_fsm_transfer_done : STD_LOGIC;
    signal pixel_clk_sp_fsm_transfer_done : STD_LOGIC;
    
begin
    
--  ===================================================================================
--  ----------------------------------- Button Input ----------------------------------
--  ===================================================================================
    
    stabilize_inputs_inst : stabilize_inputs
        generic map (
            G_NB_INPUTS => 1
        )
        port map (
            i_clk   => i_pixel_clk,
            i_in(0) => i_btn,
            
            o_out(0) => buff_btn
        );
    
    flip_flop_inputs_inst : flip_flop_inputs
        generic map (
            G_NB_INPUTS => 1
        )
        port map (
            i_clk   => i_pixel_clk,
            i_rst   => '0',
            i_in(0) => buff_btn,
            
            o_out(0) => extend_vaxis
        );
    
--  ===================================================================================
--  ------------------- Synchronize signals between the two clocks --------------------
--  ===================================================================================
    
    synchronize_bits_inst_heens_clk : synchronize_bits
        generic map (
             G_NB_INPUTS => 1
         )
         port map (
            i_src_clk => i_pixel_clk,
            i_src(0)  => pixel_clk_plot_end_screen,
            
            i_dest_clk => i_heens_clk,
            o_dest(0)  => heens_clk_plot_end_screen
        );
    
    synchronize_bits_inst_pixel_clk : synchronize_bits
        generic map (
            G_NB_INPUTS => 3
        )
        port map (
            i_src_clk => i_heens_clk,
            i_src(0)  => i_rst,
            i_src(1)  => i_ph_dist,
            i_src(2)  => heens_clk_sp_fsm_transfer_done,
            
            i_dest_clk => i_pixel_clk,
            o_dest(0)  => pixel_clk_rst,
            o_dest(1)  => pixel_clk_ph_dist,
            o_dest(2)  => pixel_clk_sp_fsm_transfer_done
        );
    
    -----------------------------------------------------------------------------------
    
    get_current_timestamp_inst_heens_clk : get_current_timestamp
        port map ( 
            i_clk     => i_heens_clk,
            i_rst     => i_rst,
            i_ph_dist => i_ph_dist,
            
            o_current_timestamp => heens_clk_current_timestamp
        );
    
    get_current_timestamp_inst_pixel_clk : get_current_timestamp
        port map ( 
            i_clk     => i_pixel_clk,
            i_rst     => pixel_clk_rst,
            i_ph_dist => pixel_clk_ph_dist,
            
            o_current_timestamp => pixel_clk_current_timestamp
        );
    
--  ===================================================================================
--  ------------------ Read the spikes FIFO and store it in memory --------------------
--  ===================================================================================
    
    read_fifo_spikes_inst : read_fifo_spikes
        port map (
            i_clk               => i_heens_clk,
            i_rst               => i_rst,
            i_ph_dist           => i_ph_dist,
            i_current_timestamp => heens_clk_current_timestamp,
            i_fifo_empty        => i_spikes_fifo_empty,
            i_fifo_valid        => i_spikes_fifo_valid,
            i_fifo_dout         => i_spikes_fifo_dout,
            i_end_screen        => heens_clk_plot_end_screen,
            
            o_hdmi_rd_fifo  => o_spikes_hdmi_rd_fifo,
            o_mem_wr_en     => spikes_mem_wr_en,
            o_mem_wr_we     => spikes_mem_wr_we,
            o_mem_wr_addr   => spikes_mem_wr_addr,
            o_mem_wr_din    => spikes_mem_wr_din,
            o_transfer_done => heens_clk_sp_fsm_transfer_done
        );
    
    spikes_memory_inst : blk_mem_gen_0
        port map (
            clka   => i_heens_clk,
            ena    => spikes_mem_wr_en,
            wea(0) => spikes_mem_wr_we,
            addra  => spikes_mem_wr_addr,
            dina   => spikes_mem_wr_din,
            douta  => open,
            
            clkb   => i_pixel_clk,
            enb    => spikes_mem_rd_en,
            web(0) => '0',
            addrb  => spikes_mem_rd_addr,
            dinb   => (others => '0'),
            doutb  => spikes_mem_rd_data
        );
    
--  ===================================================================================
--  ------------------ Read the analog FIFO and store it in memory --------------------
--  ===================================================================================
    
--    read_fifo_analog_inst : read_fifo_analog
--        port map (
--            i_clk               => i_heens_clk,
--            i_rst               => i_rst,
--            i_ph_dist           => i_ph_dist,
--            i_current_timestamp => heens_clk_current_timestamp,
--            i_fifo_empty        => i_analog_fifo_empty,
--            i_fifo_valid        => i_analog_fifo_valid,
--            i_fifo_dout         => i_analog_fifo_dout,
--            i_end_screen        => heens_clk_plot_end_screen,
            
--            o_hdmi_rd_fifo  => o_analog_hdmi_rd_fifo,
--            o_mem_wr_en     => analog_mem_wr_en,
--            o_mem_wr_we     => analog_mem_wr_we,
--            o_mem_wr_addr   => analog_mem_wr_addr,
--            o_mem_wr_din    => analog_mem_wr_din
--        );
    
--    analog_memory_inst : blk_mem_gen_2
--        port map (
--            clka   => i_heens_clk,
--            ena    => analog_mem_wr_en,
--            wea(0) => analog_mem_wr_we,
--            addra  => analog_mem_wr_addr,
--            dina   => analog_mem_wr_din,
--            douta  => open,
            
--            clkb   => i_pixel_clk,
--            enb    => analog_mem_rd_en,
--            web(0) => '0',
--            addrb  => analog_mem_rd_addr,
--            dinb   => (others => '0'),
--            doutb  => analog_mem_rd_data
--        );
    
--  ===================================================================================
--  ------------------- Read the memory and create the Raster plot --------------------
--  ===================================================================================
    
    generate_screen_inst : generate_screen
        port map (
            i_clk                => i_pixel_clk,
            i_rst                => pixel_clk_rst,
            i_current_timestamp  => pixel_clk_current_timestamp,
            i_hcounter           => color_hcounter,
            i_vcounter           => color_vcounter,
            i_spikes_mem_rd_data => spikes_mem_rd_data,
            i_analog_mem_rd_data => analog_mem_rd_data,
            i_extend_vaxis       => extend_vaxis,
            i_transfer_done      => pixel_clk_sp_fsm_transfer_done,
            
            o_hcounter           => plot_hcounter,
            o_vcounter           => plot_vcounter,
            o_spikes_mem_rd_en   => spikes_mem_rd_en,
            o_spikes_mem_rd_addr => spikes_mem_rd_addr,
            o_analog_mem_rd_en   => analog_mem_rd_en,
            o_analog_mem_rd_addr => analog_mem_rd_addr,
            o_color              => plot_color,
            o_end_screen         => pixel_clk_plot_end_screen
        );
    
--  ===================================================================================
--  --------------------------------- Connection to HDMI ------------------------------
--  ===================================================================================
    
    hdmi_connection_inst : hdmi_connection
        port map (
            i_clk      => i_pixel_clk,
            i_rst      => pixel_clk_rst,
            i_color    => plot_color,
            i_hcounter => plot_hcounter,
            i_vcounter => plot_vcounter,
            
            o_hcounter   => color_hcounter,
            o_vcounter   => color_vcounter,
            o_hdmi_clk   => o_hdmi_clk,
            o_hdmi_d     => o_hdmi_d,
            o_hdmi_de    => o_hdmi_de,
            o_hdmi_hsync => o_hdmi_hsync,
            o_hdmi_vsync => o_hdmi_vsync,
            o_hdmi_scl   => o_hdmi_scl,
            o_hdmi_sda   => o_hdmi_sda
        );
    
end Behavioral;
