----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2021 02:23:03 PM
-- Design Name: 
-- Module Name: flip_flop_inputs - Behavioral
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


entity flip_flop_inputs is
    generic (
        G_NB_INPUTS : INTEGER
    );
    port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        i_in  : in STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
        
        o_out : out STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0)
    );
end flip_flop_inputs;


architecture Behavioral of flip_flop_inputs is
    
    signal last_in : STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
    signal sig_out : STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0) := (others => '0');
    
begin
    
    o_out <= sig_out;
    
    flip_flop_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            last_in <= i_in;
            
            if i_rst = '1' then
                
                sig_out <= (others => '0');
                
            else
                
                for i in 0 to G_NB_INPUTS-1 loop
                    
                    if last_in(i) = '0' and i_in(i) = '1' then -- rising edge
                        sig_out(i) <= not(sig_out(i));
                    end if;
                    
                end loop;
                
            end if;
            
        end if;
    end process;
    
end Behavioral;
