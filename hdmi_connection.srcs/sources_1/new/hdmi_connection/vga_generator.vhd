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
    use work.events_list.ALL;


entity vga_generator is
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
end vga_generator;


architecture Behavioral of vga_generator is
    
    signal hcounter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal vcounter : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    
begin
    clk_process: process(i_clk)
    begin
        if rising_edge(i_clk) then 
        
            if hcounter < C_H_VISIBLE and vcounter < C_V_VISIBLE then 
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
                
            -- Generate the sync Pulses
            if    hcounter = C_H_START_SYNC then 
                o_hsync <= C_H_SYNC_ACTIVE;
            elsif hcounter = C_H_END_SYNC then
                o_hsync <= not(C_H_SYNC_ACTIVE);
            end if;
            
            if    vcounter = C_V_START_SYNC then 
                o_vsync <= C_V_SYNC_ACTIVE;
            elsif vcounter = C_V_END_SYNC then
                o_vsync <= not(C_V_SYNC_ACTIVE);
            end if;
            
            -- Advance the position counters
            if hcounter < C_H_MAX then
                hcounter <= hcounter + 1;
            else
                -- starting a new line
                hcounter <= (others => '0');
                if vcounter < C_V_MAX then
                    vcounter <= vcounter + 1;
                else
                    -- starting a new screen
                    vcounter <= (others => '0');
                end if;
            end if;
        
        end if;
    end process;
                
    o_hcounter <= hcounter;
    o_vcounter <= vcounter;

end Behavioral;
