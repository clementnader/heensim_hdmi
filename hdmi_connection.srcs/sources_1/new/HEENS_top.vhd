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
    
    -- Reset signal
    signal reset : STD_LOGIC;
    
    -- State signals
    signal ph_init : STD_LOGIC;
    signal ph_conf : STD_LOGIC;
    signal ph_exec : STD_LOGIC;
    signal ph_dist : STD_LOGIC;
    
    -- Signals from the FIFO
    signal empty_input_fifo : STD_LOGIC;
    signal valid_input_fifo : STD_LOGIC;
    signal dout_input_fifo  : STD_LOGIC_VECTOR(31 downto 0);
    
    -- Signals from the HDMI display
    signal hdmi_rd_fifo : STD_LOGIC;

begin
    
    LD(0) <= ph_init;
    LD(1) <= ph_conf;
    LD(2) <= ph_exec;
    LD(3) <= ph_dist;
    
    reset <= BTNC;
    
--  ===================================================================================
--  --------------------------------------- Z_INTERFACE -------------------------------
--  ===================================================================================
    
    ZAER_INTERFACE_i : entity work.HEENSim
    generic map (
        G_DATA_SIZE => 1,
        G_PERIOD    => 125_000  -- Tspike = 1 ms
    )
    port map (
        i_clk                => clk,
        i_rst                => reset,
        i_hdmi_ready_rd_fifo => hdmi_rd_fifo,
        
        o_fifo_dout  => dout_input_fifo,
        o_fifo_empty => empty_input_fifo,
        o_fifo_valid => valid_input_fifo,
        o_ph_init    => ph_init,
        o_ph_conf    => ph_conf,
        o_ph_exec    => ph_exec,
        o_ph_dist    => ph_dist
    );
    
    
--  ===================================================================================
--  --------------------------------------- HDMI --------------------------------------
--  ===================================================================================
    
    HDMI_DISPLAY_INST : entity work.hdmi_display
        port map (
            i_clk        => clk,
            i_clk_150    => clk_150,
            i_clk_150_90 => clk_150_90,
            i_rst        => reset,
            i_btnl       => BTNL,
            i_btnr       => BTNR,
            i_ph_dist    => ph_dist,
            i_fifo_empty => empty_input_fifo,
            i_fifo_valid => valid_input_fifo,
            i_fifo_dout  => dout_input_fifo(17 downto 0),
            
            o_hdmi_ready_rd_fifo => hdmi_rd_fifo,
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
