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
        GCLK           : in STD_LOGIC;  -- 100 MHz
        GCLK_P, GCLK_N : in STD_LOGIC;  -- 200 MHz
        BTNC, BTNR     : in STD_LOGIC;
        
        LD         : out STD_LOGIC_VECTOR(3 downto 0);
        HDMI_CLK   : out STD_LOGIC;
        HDMI_D     : out STD_LOGIC_VECTOR(35 downto 0);
        HDMI_DE    : out STD_LOGIC;
        HDMI_HSYNC : out STD_LOGIC;
        HDMI_VSYNC : out STD_LOGIC;
        HDMI_SCL   : out STD_LOGIC;
        HDMI_SDA   : out STD_LOGIC
    );
end HEENS_top;


architecture Behavioral of HEENS_top is
    
    component HEENSim
        generic (
            G_DATA_SIZE : INTEGER;
            G_PERIOD    : INTEGER
        );
        port (
            i_clk          : in STD_LOGIC;
            i_rst          : in STD_LOGIC;
            i_hdmi_rd_fifo : in STD_LOGIC;
            
            o_fifo_dout  : out STD_LOGIC_VECTOR(31 downto 0);
            o_fifo_empty : out STD_LOGIC;
            o_fifo_valid : out STD_LOGIC;
            o_ph_init    : out STD_LOGIC;
            o_ph_conf    : out STD_LOGIC;
            o_ph_exec    : out STD_LOGIC;
            o_ph_dist    : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component hdmi_display
        port (
            i_heens_clk  : in STD_LOGIC;
            i_pixel_clk  : in STD_LOGIC;
            i_rst        : in STD_LOGIC;
            i_btnr       : in STD_LOGIC;
            i_ph_dist    : in STD_LOGIC;
            i_fifo_empty : in STD_LOGIC;
            i_fifo_valid : in STD_LOGIC;
            i_fifo_dout  : in STD_LOGIC_VECTOR(17 downto 0);
            
            o_hdmi_rd_fifo : out STD_LOGIC;
            o_hdmi_clk     : out STD_LOGIC;
            o_hdmi_d       : out STD_LOGIC_VECTOR(35 downto 0);
            o_hdmi_de      : out STD_LOGIC;
            o_hdmi_hsync   : out STD_LOGIC;
            o_hdmi_vsync   : out STD_LOGIC;
            o_hdmi_scl     : out STD_LOGIC;
            o_hdmi_sda     : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component clk_gen
        port (
            i_gclk   : in STD_LOGIC;
            i_gclk_p : in STD_LOGIC;
            i_gclk_n : in STD_LOGIC;
            
            o_pixel_clk : out STD_LOGIC;
            o_heens_clk : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    -- Clocking
    signal heens_clk : STD_LOGIC;  -- HEENS clock - @125 MHz
    signal pixel_clk : STD_LOGIC;  -- pixel clock used for HDMI - @150 MHz
    
    -- Reset signal
    signal reset : STD_LOGIC;  -- reset signal, it corresponds to BTNC
    
    -- State signals
    signal ph_init : STD_LOGIC;  -- initial phase
    signal ph_conf : STD_LOGIC;  -- configuration phase
    signal ph_exec : STD_LOGIC;  -- execution phase
    signal ph_dist : STD_LOGIC;  -- distribution phase
    
    -- Signals from the spikes FIFO
    signal empty_input_fifo : STD_LOGIC;  -- empty signal from the spikes FIFO
    signal valid_input_fifo : STD_LOGIC;  -- valid signal from the spikes FIFO
    signal dout_input_fifo  : STD_LOGIC_VECTOR(31 downto 0);  -- output data from the spikes FIFO
    signal hdmi_rd_fifo     : STD_LOGIC;  -- flag to tell HEENS we are ready to read from the spikes FIFO

begin
    
--  ===================================================================================
--  ---------------------------------------- I/O --------------------------------------
--  ===================================================================================
    
    LD(0) <= ph_init;
    LD(1) <= ph_conf;
    LD(2) <= ph_exec;
    LD(3) <= ph_dist;
    
    reset <= BTNC;
    
--  ===================================================================================
--  ------------------------------------ Z_INTERFACE ----------------------------------
--  ===================================================================================
    
    ZAER_INTERFACE_i : HEENSim
        generic map (
            G_DATA_SIZE => 1,
            G_PERIOD    => 125_000  -- Tspike = 1 ms
        )
        port map (
            i_clk          => heens_clk,
            i_rst          => reset,
            i_hdmi_rd_fifo => hdmi_rd_fifo,
            
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
    
    HDMI_DISPLAY_INST : hdmi_display
        port map (
            i_heens_clk  => heens_clk,
            i_pixel_clk  => pixel_clk,
            i_rst        => reset,
            i_btnr       => BTNR,
            i_ph_dist    => ph_dist,
            i_fifo_empty => empty_input_fifo,
            i_fifo_valid => valid_input_fifo,
            i_fifo_dout  => dout_input_fifo(17 downto 0),
            
            o_hdmi_rd_fifo => hdmi_rd_fifo,
            o_hdmi_clk     => HDMI_CLK,
            o_hdmi_d       => HDMI_D,
            o_hdmi_de      => HDMI_DE,
            o_hdmi_hsync   => HDMI_HSYNC,
            o_hdmi_vsync   => HDMI_VSYNC,
            o_hdmi_scl     => HDMI_SCL,
            o_hdmi_sda     => HDMI_SDA
        );
    
--  ===================================================================================
--  --------------------------------- CLOCK GENERATION --------------------------------
--  ===================================================================================
    
    CLOCK_GENERATION_INST : clk_gen
        port map (
            i_gclk   => GCLK,
            i_gclk_p => GCLK_P,
            i_gclk_n => GCLK_N,
            
            o_pixel_clk => pixel_clk,
            o_heens_clk => heens_clk
        );
    
end Behavioral;
