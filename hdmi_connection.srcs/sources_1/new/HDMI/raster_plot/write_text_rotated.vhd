----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/19/2021 02:47:15 PM
-- Design Name: 
-- Module Name: write_text_rotated - Behavioral
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
    use IEEE.NUMERIC_STD.ALL;

library work;
    use work.character_definition_pkg.ALL;


entity write_text_rotated is
    generic (
       G_TEXT_LENGTH : INTEGER
    );
    port (
        i_clk          : in STD_LOGIC;
        i_display_text : in STRING(1 to G_TEXT_LENGTH);
        i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);  -- horizontal position of the top left corner of the text
        i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);  -- vertical position of the top left corner of the text
        i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);  -- current pixel horizontal position
        i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);  -- current pixel vertical position
        
        o_pixel : out STD_LOGIC
    );
end write_text_rotated;

architecture Behavioral of write_text_rotated is
    
    signal shifted_hpos : STD_LOGIC_VECTOR(11 downto 0);
    signal shifted_vpos : STD_LOGIC_VECTOR(11 downto 0);
    
    signal char_pos_in_text : STD_LOGIC_VECTOR(11 downto C_FONT_WIDTH_POW);   -- the position of a character in the given text
    signal col_pos_in_char  : STD_LOGIC_VECTOR(C_FONT_WIDTH_POW-1 downto 0);  -- the column position in a character
    signal char_code        : STD_LOGIC_VECTOR(6 downto 0);                   -- character ASCII code
    
    signal row_addr_in_table : STD_LOGIC_VECTOR(10 downto 0);
    signal current_char_row  : STD_LOGIC_VECTOR(C_FONT_WIDTH-1 downto 0);  -- a row of bits in a character, we check if our current (h, v) is 1 in char row
    
begin
    
    shifted_hpos <= i_hcounter - i_text_hpos;
    shifted_vpos <= i_vcounter - i_text_vpos;
    
    char_pos_in_text <= shifted_vpos(11 downto C_FONT_WIDTH_POW);
    col_pos_in_char  <= shifted_vpos(C_FONT_WIDTH_POW-1 downto 0);
    
    char_code <= std_logic_vector(to_unsigned(
        character'pos(  -- gives the ASCII code of a character
            i_display_text(G_TEXT_LENGTH - to_integer(unsigned(char_pos_in_text)))
        ), 7));
    
--    char_code <= std_logic_vector(to_unsigned(
--        character'pos(  -- gives the ASCII code of a character
--            i_display_text(G_TEXT_LENGTH - to_integer(unsigned(char_pos_in_text)))
--        ), 7)) when G_TEXT_LENGTH - to_integer(unsigned(char_pos_in_text)) >= 1
--                and G_TEXT_LENGTH - to_integer(unsigned(char_pos_in_text)) <= G_TEXT_LENGTH
--        else (others => 'Z');
    
    row_addr_in_table <= char_code & shifted_hpos(3 downto 0);
    
    read_char_row_from_table_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            current_char_row <= C_CHARACTERS_TABLE(to_integer(unsigned(row_addr_in_table)));
            
        end if;
    end process;
    
    check_if_the_current_pixel_has_to_be_on_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_pixel <= '0';
            
            if (i_hcounter >= i_text_hpos and i_hcounter < i_text_hpos + C_FONT_HEIGHT)
             and (i_vcounter >= i_text_vpos and i_vcounter < i_text_vpos + (C_FONT_WIDTH * G_TEXT_LENGTH)) then
                
--                if to_integer(unsigned(col_pos_in_char)) >= 0
--                 and to_integer(unsigned(col_pos_in_char)) <= C_FONT_WIDTH-1 then
                if current_char_row(to_integer(unsigned(col_pos_in_char))) = '1' then
                    o_pixel <= '1';
                end if;
--                end if;
                
            end if;
            
        end if;
    end process;
    
end Behavioral;
