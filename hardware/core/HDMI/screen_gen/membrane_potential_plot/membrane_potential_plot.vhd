----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/19/2021 03:46:52 PM
-- Design Name: 
-- Module Name: membrane_potential_plot - Behavioral
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
    use work.plot_pkg.ALL;
    use work.neurons_pkg.ALL;


entity membrane_potential_plot is
    port (
        i_clk               : in STD_LOGIC;
        i_hcounter          : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter          : in STD_LOGIC_VECTOR(11 downto 0);
        i_mem_rd_data       : in STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
        i_extend_vaxis      : in STD_LOGIC;
        i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        i_pointer0          : in STD_LOGIC_VECTOR(9 downto 0);
        
        o_mem_rd_en         : out STD_LOGIC;
        o_mem_rd_addr       : out STD_LOGIC_VECTOR(9 downto 0);
        o_dot_pixel         : out BOOLEAN;
        o_contours_pixel    : out BOOLEAN;
        o_axes_label_pixel  : out BOOLEAN;
        o_ticks_label_pixel : out BOOLEAN
    );
end membrane_potential_plot;


architecture Behavioral of membrane_potential_plot is

begin


end Behavioral;
