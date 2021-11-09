----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/05/2021 04:47:02 PM
-- Design Name: 
-- Module Name: HEENS_top - Behavioral
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


entity HEENS_top is
    port (
        GCLK             : in STD_LOGIC;
        BTNC, BTNL, BTNR : in STD_LOGIC;
        
        LD         : out STD_LOGIC_VECTOR(3 downto 0);
        HDMI_CLK   : out STD_LOGIC;
        HDMI_D     : out STD_LOGIC_VECTOR(15 downto 0);
        HDMI_DE    : out STD_LOGIC;
        HDMI_HSYNC : out STD_LOGIC;
        HDMI_VSYNC : out STD_LOGIC;
        HDMI_SCL   : out STD_LOGIC;
        HDMI_SDA   : out STD_LOGIC
    );
end HEENS_top;


architecture Behavioral of HEENS_top is
    
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
            i_clk                : in STD_LOGIC;
            i_rst                : in STD_LOGIC;
            i_hdmi_ready_rd_fifo : in STD_LOGIC;
            
            o_fifo_dout  : out STD_LOGIC_VECTOR(17 downto 0);
            o_fifo_empty : out STD_LOGIC;
            o_fifo_valid : out STD_LOGIC;
            o_ph_init    : out STD_LOGIC;
            o_ph_conf    : out STD_LOGIC;
            o_ph_exec    : out STD_LOGIC;
            o_ph_dist    : out STD_LOGIC
        );
    end component;
    
    component hdmi_display
        port (
            i_clk           : in STD_LOGIC;
            i_clk_150       : in STD_LOGIC;
            i_clk_150_90    : in STD_LOGIC;
            i_rst           : in STD_LOGIC;
            i_freeze_screen : in STD_LOGIC;
            i_extend_vaxis  : in STD_LOGIC;
            i_ph_dist       : in STD_LOGIC;
            i_fifo_empty    : in STD_LOGIC;
            i_fifo_valid    : in STD_LOGIC;
            i_fifo_dout     : in STD_LOGIC_VECTOR(17 downto 0);
            
            o_hdmi_ready_rd_fifo : out STD_LOGIC;
            o_hdmi_clk           : out STD_LOGIC;
            o_hdmi_d             : out STD_LOGIC_VECTOR(15 downto 0);
            o_hdmi_de            : out STD_LOGIC;
            o_hdmi_hsync         : out STD_LOGIC;
            o_hdmi_vsync         : out STD_LOGIC;
            o_hdmi_scl           : out STD_LOGIC;
            o_hdmi_sda           : out STD_LOGIC
        );
    end component;
    
    component clk_wiz_1 
        port (
            clk_in1 : in STD_LOGIC;
            reset   : in STD_LOGIC;
            
            clk        : out STD_LOGIC;
            clk_150    : out STD_LOGIC;
            clk_150_90 : out STD_LOGIC
        );
    end component;
    
    -- Clocking
    signal clk        : STD_LOGIC;  -- 125 MHz
    signal clk_150    : STD_LOGIC;  -- 150 MHz
    signal clk_150_90 : STD_LOGIC;  -- 150 MHz, 90° phase shift
    
    -- Stabilized inputs
    signal rst           : STD_LOGIC;
    signal freeze_screen : STD_LOGIC;
    signal extend_vaxis  : STD_LOGIC;
    
    -- State signals
    signal ph_init : STD_LOGIC;
    signal ph_conf : STD_LOGIC;
    signal ph_exec : STD_LOGIC;
    signal ph_dist : STD_LOGIC;
    
    -- Signals from the FIFO
    signal fifo_dout  : STD_LOGIC_VECTOR(17 downto 0);
    signal fifo_rd_en : STD_LOGIC;
    signal fifo_empty : STD_LOGIC;
    signal fifo_valid : STD_LOGIC;
    
    -- Signals from the HDMI display
    signal hdmi_ready_rd_fifo : STD_LOGIC;
    
begin
    
    LD(0) <= ph_init;
    LD(1) <= ph_conf;
    LD(2) <= ph_exec;
    LD(3) <= ph_dist;
    
    stabilize_inputs_inst : stabilize_inputs
    generic map (
        G_NB_INPUTS => 3
    )
    port map (
        i_clk   => clk,
        i_in(0) => BTNL,
        i_in(1) => BTNC,
        i_in(2) => BTNR,
        
        o_out(0) => rst,
        o_out(1) => freeze_screen,
        o_out(2) => extend_vaxis
    );
    
    HEENSim_inst : HEENSim
    generic map (
        G_DATA_SIZE => 1,
        G_PERIOD    => 125_000  -- Tspike = 1 ms
    )
    port map (
        i_clk                => clk,
        i_rst                => rst,
        i_hdmi_ready_rd_fifo => hdmi_ready_rd_fifo,
        
        o_fifo_dout  => fifo_dout,
        o_fifo_empty => fifo_empty,
        o_fifo_valid => fifo_valid,
        o_ph_init    => ph_init,
        o_ph_conf    => ph_conf,
        o_ph_exec    => ph_exec,
        o_ph_dist    => ph_dist
    );
    
    hdmi_display_inst : hdmi_display
    port map (
        i_clk           => clk,
        i_clk_150       => clk_150,
        i_clk_150_90    => clk_150_90,
        i_rst           => rst,
        i_freeze_screen => freeze_screen,
        i_extend_vaxis  => extend_vaxis,
        i_ph_dist       => ph_dist,
        i_fifo_empty    => fifo_empty,
        i_fifo_valid    => fifo_valid,
        i_fifo_dout     => fifo_dout,
        
        o_hdmi_ready_rd_fifo => hdmi_ready_rd_fifo,
        o_hdmi_clk           => HDMI_CLK,
        o_hdmi_d             => HDMI_D,
        o_hdmi_de            => HDMI_DE,
        o_hdmi_hsync         => HDMI_HSYNC,
        o_hdmi_vsync         => HDMI_VSYNC,
        o_hdmi_scl           => HDMI_SCL,
        o_hdmi_sda           => HDMI_SDA
    );
    
    clk_wiz_1_inst : clk_wiz_1
    port map (
        clk_in1 => GCLK,  -- 100 MHz
        reset   => '0',
        
        clk        => clk,        -- 125 MHz
        clk_150    => clk_150,    -- 150 MHz
        clk_150_90 => clk_150_90  -- 150 MHz, phase shift 90°
    );
    
end Behavioral;
