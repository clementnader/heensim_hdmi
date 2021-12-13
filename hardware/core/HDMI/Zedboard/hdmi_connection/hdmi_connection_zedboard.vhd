----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/11/2021 12:13:10 PM
-- Design Name: 
-- Module Name: hdmi_connection - Behavioral
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


entity hdmi_connection is
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
end hdmi_connection;


architecture Behavioral of hdmi_connection is
    
    component position_counters
        port (
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            
            o_hcounter : out STD_LOGIC_VECTOR(11 downto 0);
            o_vcounter : out STD_LOGIC_VECTOR(11 downto 0)
        );
    end component;
    
    component rgb_generator is
        port (
            i_clk      : in STD_LOGIC;
            i_color    : in STD_LOGIC_VECTOR(23 downto 0);
            i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_r     : out STD_LOGIC_VECTOR(7 downto 0);
            o_g     : out STD_LOGIC_VECTOR(7 downto 0);
            o_b     : out STD_LOGIC_VECTOR(7 downto 0);
            o_de    : out STD_LOGIC;
            o_hsync : out STD_LOGIC;
            o_vsync : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component convert_rgb_ycbcr
        port (
            i_clk   : in STD_LOGIC;
            i_r     : in STD_LOGIC_VECTOR(7 downto 0);
            i_g     : in STD_LOGIC_VECTOR(7 downto 0);
            i_b     : in STD_LOGIC_VECTOR(7 downto 0);
            i_de    : in STD_LOGIC;
            i_hsync : in STD_LOGIC;
            i_vsync : in STD_LOGIC;
            
            o_y     : out STD_LOGIC_VECTOR(7 downto 0);
            o_cb    : out STD_LOGIC_VECTOR(7 downto 0);
            o_cr    : out STD_LOGIC_VECTOR(7 downto 0);
            o_de    : out STD_LOGIC;
            o_hsync : out STD_LOGIC;
            o_vsync : out STD_LOGIC
        );
    end component;
    
    component hdmi_output_zedboard
        port (
            i_clk   : in STD_LOGIC;
            i_y     : in STD_LOGIC_VECTOR(7 downto 0);
            i_cb    : in STD_LOGIC_VECTOR(7 downto 0);
            i_cr    : in STD_LOGIC_VECTOR(7 downto 0);
            i_de    : in STD_LOGIC;
            i_hsync : in STD_LOGIC;
            i_vsync : in STD_LOGIC;
            
            o_hdmi_clk   : out STD_LOGIC;
            o_hdmi_d     : out STD_LOGIC_VECTOR(35 downto 0);
            o_hdmi_de    : out STD_LOGIC;
            o_hdmi_hsync : out STD_LOGIC;
            o_hdmi_vsync : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    component config_hdmi_chip_i2c_zedboard
        port (
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            
            o_scl : out STD_LOGIC;
            o_sda : out STD_LOGIC
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    -- Signals from the VGA generator
    signal pattern_r     : STD_LOGIC_VECTOR(7 downto 0);
    signal pattern_g     : STD_LOGIC_VECTOR(7 downto 0);
    signal pattern_b     : STD_LOGIC_VECTOR(7 downto 0);
    signal pattern_de    : STD_LOGIC;
    signal pattern_hsync : STD_LOGIC;
    signal pattern_vsync : STD_LOGIC;
    
    -- Signals from the converter RGB => YCbCr
    signal conv_y     : STD_LOGIC_VECTOR(7 downto 0);
    signal conv_cb    : STD_LOGIC_VECTOR(7 downto 0);
    signal conv_cr    : STD_LOGIC_VECTOR(7 downto 0);
    signal conv_de    : STD_LOGIC;
    signal conv_hsync : STD_LOGIC;
    signal conv_vsync : STD_LOGIC;
    
begin
    
    position_counters_inst : position_counters
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            o_hcounter => o_hcounter,
            o_vcounter => o_vcounter
        );
    
    rgb_generator_inst : rgb_generator
        port map (
            i_clk      => i_clk,
            i_color    => i_color,
            i_hcounter => i_hcounter,
            i_vcounter => i_vcounter,
            
            o_r     => pattern_r,
            o_g     => pattern_g,
            o_b     => pattern_b,
            o_de    => pattern_de,
            o_hsync => pattern_hsync,
            o_vsync => pattern_vsync
        );
    
    -----------------------------------------------------------------------------------
    
    convert_rgb_ycbcr_inst : convert_rgb_ycbcr
        port map (
            i_clk   => i_clk,
            i_r     => pattern_r,
            i_g     => pattern_g,
            i_b     => pattern_b,
            i_de    => pattern_de,
            i_hsync => pattern_hsync,
            i_vsync => pattern_vsync,
            
            o_y     => conv_y,
            o_cb    => conv_cb,
            o_cr    => conv_cr,
            o_de    => conv_de,
            o_hsync => conv_hsync,
            o_vsync => conv_vsync
        );
    
    hdmi_output_zedboard_inst : hdmi_output_zedboard
        port map (
            i_clk   => i_clk,
            i_y     => conv_y,
            i_cb    => conv_cb,
            i_cr    => conv_cr,
            i_de    => conv_de,
            i_hsync => conv_hsync,
            i_vsync => conv_vsync,
            
            o_hdmi_clk   => o_hdmi_clk,
            o_hdmi_d     => o_hdmi_d,
            o_hdmi_de    => o_hdmi_de,
            o_hdmi_hsync => o_hdmi_hsync,
            o_hdmi_vsync => o_hdmi_vsync
        );
    
    -----------------------------------------------------------------------------------
    
    config_hdmi_chip_i2c_zedboard_inst : config_hdmi_chip_i2c_zedboard
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            o_scl => o_hdmi_scl,
            o_sda => o_hdmi_sda
        );
    
end Behavioral;
