----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/24/2021 07:53:02 PM
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
    
    component hdmi_output_zc706
        port (
            i_clk   : in STD_LOGIC;
            i_r     : in STD_LOGIC_VECTOR(7 downto 0);
            i_g     : in STD_LOGIC_VECTOR(7 downto 0);
            i_b     : in STD_LOGIC_VECTOR(7 downto 0);
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
    
    component config_hdmi_chip_i2c_zc706
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
    
    hdmi_output_zc706_inst : hdmi_output_zc706
        port map (
            i_clk   => i_clk,
            i_r     => pattern_r,
            i_g     => pattern_g,
            i_b     => pattern_b,
            i_de    => pattern_de,
            i_hsync => pattern_hsync,
            i_vsync => pattern_vsync,
            
            o_hdmi_clk   => o_hdmi_clk,
            o_hdmi_d     => o_hdmi_d,
            o_hdmi_de    => o_hdmi_de,
            o_hdmi_hsync => o_hdmi_hsync,
            o_hdmi_vsync => o_hdmi_vsync
        );
   
    -----------------------------------------------------------------------------------
    
    config_hdmi_chip_i2c_zc706_inst : config_hdmi_chip_i2c_zc706
        port map (
            i_clk => i_clk,
            i_rst => i_rst,
            
            o_scl => o_hdmi_scl,
            o_sda => o_hdmi_sda
        );
    
end Behavioral;
