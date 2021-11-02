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

library work;
    use work.hdmi_resolution.ALL;


entity hdmi_connection is
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
end hdmi_connection;


architecture Behavioral of hdmi_connection is
    
    component vga_generator is
        port (
            i_clk   : in STD_LOGIC;
            i_color : in STD_LOGIC_VECTOR(23 downto 0);
            
            o_hcounter : out STD_LOGIC_VECTOR(11 downto 0);
            o_vcounter : out STD_LOGIC_VECTOR(11 downto 0);
            o_r        : out STD_LOGIC_VECTOR(7 downto 0);
            o_g        : out STD_LOGIC_VECTOR(7 downto 0);
            o_b        : out STD_LOGIC_VECTOR(7 downto 0);
            o_de       : out STD_LOGIC;
            o_hsync    : out STD_LOGIC := '0';
            o_vsync    : out STD_LOGIC := '0'
        );
    end component;
    
    component convert_444_422
        port (
            i_clk   : in STD_LOGIC;
            i_r     : in STD_LOGIC_VECTOR(7 downto 0);
            i_g     : in STD_LOGIC_VECTOR(7 downto 0);
            i_b     : in STD_LOGIC_VECTOR(7 downto 0);
            i_de    : in STD_LOGIC;
            i_hsync : in STD_LOGIC;
            i_vsync : in STD_LOGIC;
            
            o_r1         : out STD_LOGIC_VECTOR(8 downto 0);
            o_g1         : out STD_LOGIC_VECTOR(8 downto 0);
            o_b1         : out STD_LOGIC_VECTOR(8 downto 0);
            o_r2         : out STD_LOGIC_VECTOR(8 downto 0);
            o_g2         : out STD_LOGIC_VECTOR(8 downto 0);
            o_b2         : out STD_LOGIC_VECTOR(8 downto 0);
            o_pair_start : out STD_LOGIC;
            o_de         : out STD_LOGIC;
            o_hsync      : out STD_LOGIC;
            o_vsync      : out STD_LOGIC
        );
    end component;
    
    component colour_space_conversion
        port (
            i_clk        : in STD_LOGIC;
            i_r1         : in STD_LOGIC_VECTOR(8 downto 0);
            i_g1         : in STD_LOGIC_VECTOR(8 downto 0);
            i_b1         : in STD_LOGIC_VECTOR(8 downto 0);
            i_r2         : in STD_LOGIC_VECTOR(8 downto 0);
            i_g2         : in STD_LOGIC_VECTOR(8 downto 0);
            i_b2         : in STD_LOGIC_VECTOR(8 downto 0);
            i_pair_start : in STD_LOGIC;
            i_de         : in STD_LOGIC;
            i_hsync      : in STD_LOGIC;
            i_vsync      : in STD_LOGIC;
            
            o_y     : out STD_LOGIC_VECTOR(7 downto 0);
            o_c     : out STD_LOGIC_VECTOR(7 downto 0);
            o_de    : out STD_LOGIC;
            o_hsync : out STD_LOGIC;
            o_vsync : out STD_LOGIC
        );
    end component;
    
    component hdmi_ddr_output
        port (
            i_clk   : in STD_LOGIC;
            i_clk90 : in STD_LOGIC;
            i_y     : in STD_LOGIC_VECTOR(7 downto 0);
            i_c     : in STD_LOGIC_VECTOR(7 downto 0);
            i_de    : in STD_LOGIC;
            i_hsync : in STD_LOGIC;
            i_vsync : in STD_LOGIC;
            
            o_hdmi_clk   : out STD_LOGIC;
            o_hdmi_d     : out STD_LOGIC_VECTOR(15 downto 0);
            o_hdmi_de    : out STD_LOGIC;
            o_hdmi_hsync : out STD_LOGIC;
            o_hdmi_vsync : out STD_LOGIC;
            o_hdmi_scl   : out STD_LOGIC;
            o_hdmi_sda   : out STD_LOGIC
        );
    end component;
    
    -- Signals from the VGA generator
    signal pattern_r     : STD_LOGIC_VECTOR(7 downto 0);
    signal pattern_g     : STD_LOGIC_VECTOR(7 downto 0);
    signal pattern_b     : STD_LOGIC_VECTOR(7 downto 0);
    signal pattern_de    : STD_LOGIC;
    signal pattern_hsync : STD_LOGIC;
    signal pattern_vsync : STD_LOGIC;
    
    -- Signals from the pixel pair convertor
    signal c422_r1         : STD_LOGIC_VECTOR(8 downto 0);
    signal c422_g1         : STD_LOGIC_VECTOR(8 downto 0);
    signal c422_b1         : STD_LOGIC_VECTOR(8 downto 0);
    signal c422_r2         : STD_LOGIC_VECTOR(8 downto 0);
    signal c422_g2         : STD_LOGIC_VECTOR(8 downto 0);
    signal c422_b2         : STD_LOGIC_VECTOR(8 downto 0);
    signal c422_pair_start : STD_LOGIC;
    signal c422_de         : STD_LOGIC;
    signal c422_hsync      : STD_LOGIC;
    signal c422_vsync      : STD_LOGIC;
    
    -- Signals from the colour space convertor
    signal csc_y     : STD_LOGIC_VECTOR(7 downto 0);
    signal csc_c     : STD_LOGIC_VECTOR(7 downto 0);
    signal csc_de    : STD_LOGIC;
    signal csc_hsync : STD_LOGIC;
    signal csc_vsync : STD_LOGIC;
    
begin
    
    i_vga_generator: vga_generator
    port map (
        i_clk   => i_clk,
        i_color => i_color,
        
        o_hcounter => o_hcounter,
        o_vcounter => o_vcounter,
        o_r        => pattern_r,
        o_g        => pattern_g,
        o_b        => pattern_b,
        o_de       => pattern_de,
        o_hsync    => pattern_hsync,
        o_vsync    => pattern_vsync
    );
    
    i_convert_444_422: convert_444_422
    port map (
        i_clk   => i_clk,
        i_r     => pattern_r,
        i_g     => pattern_g,
        i_b     => pattern_b,
        i_de    => pattern_de,
        i_hsync => pattern_hsync,
        i_vsync => pattern_vsync,
        
        o_r1         => c422_r1,
        o_g1         => c422_g1,
        o_b1         => c422_b1,
        o_r2         => c422_r2,
        o_g2         => c422_g2,
        o_b2         => c422_b2,
        o_pair_start => c422_pair_start,
        o_de         => c422_de,
        o_hsync      => c422_hsync,
        o_vsync      => c422_vsync
    );
    
    i_csc: colour_space_conversion
    port map (
        i_clk        => i_clk,
        i_r1         => c422_r1,
        i_g1         => c422_g1,
        i_b1         => c422_b1,
        i_r2         => c422_r2,
        i_g2         => c422_g2,
        i_b2         => c422_b2,
        i_pair_start => c422_pair_start,
        i_de         => c422_de,
        i_hsync      => c422_hsync,
        i_vsync      => c422_vsync,
        
        o_y     => csc_y,
        o_c     => csc_c,
        o_de    => csc_de,
        o_hsync => csc_hsync,
        o_vsync => csc_vsync
    );
    
    i_hdmi_ddr_output: hdmi_ddr_output
    port map (
        i_clk   => i_clk,
        i_clk90 => i_clk90,
        i_y     => csc_y,
        i_c     => csc_c,
        i_de    => csc_de,
        i_hsync => csc_hsync,
        i_vsync => csc_vsync,
        
        o_hdmi_clk   => o_hdmi_clk,
        o_hdmi_d     => o_hdmi_d,
        o_hdmi_de    => o_hdmi_de,
        o_hdmi_hsync => o_hdmi_hsync,
        o_hdmi_vsync => o_hdmi_vsync,
        o_hdmi_scl   => o_hdmi_scl,
        o_hdmi_sda   => o_hdmi_sda
    );
    
end Behavioral;
