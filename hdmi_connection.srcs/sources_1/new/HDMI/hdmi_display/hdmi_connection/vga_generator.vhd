----------------------------------------------------------------------------------
-- Engineer:  Mike Field <hamster@snap.net.nz> 
-- Module:    vga_generator.vhd
-- 
-- Description: A test pattern generator for the Zedboard's VGA & HDMI interface
--
-- Feel free to use this how you see fit, and fix any errors you find :-)
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;

library work;
    use work.hdmi_resolution.ALL;


entity vga_generator is
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
end vga_generator;


architecture Behavioral of vga_generator is
begin
    
    clk_process: process(i_clk)
    begin
        if rising_edge(i_clk) then 
            
            if i_hcounter < C_H_VISIBLE and i_vcounter < C_V_VISIBLE then 
                o_r  <= i_color(23 downto 16);
                o_g  <= i_color(15 downto  8);
                o_b  <= i_color( 7 downto  0);
                o_de <= '1';
            else
                o_r  <= (others => '0');
                o_g  <= (others => '0');
                o_b  <= (others => '0');
                o_de <= '0';
            end if;
            
            -- Generate the sync pulses
            if i_hcounter = C_H_START_SYNC then 
                o_hsync <= C_H_SYNC_ACTIVE;
            elsif i_hcounter = C_H_END_SYNC then
                o_hsync <= not(C_H_SYNC_ACTIVE);
            end if;
            
            if i_vcounter = C_V_START_SYNC then 
                o_vsync <= C_V_SYNC_ACTIVE;
            elsif i_vcounter = C_V_END_SYNC then
                o_vsync <= not(C_V_SYNC_ACTIVE);
            end if;
            
        end if;
    end process;
    
end Behavioral;
