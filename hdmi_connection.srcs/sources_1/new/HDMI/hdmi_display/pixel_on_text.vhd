----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/18/2021 03:37:31 PM
-- Design Name: 
-- Module Name: pixel_on_text - Behavioral
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
    use work.character_definition.ALL;


entity pixel_on_text is
    generic (
       G_TEXT_LENGTH : INTEGER
    );
    port (
        i_clk          : in STD_LOGIC;
        i_display_text : in STRING(0 to G_TEXT_LENGTH-1);
        i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);  -- horizontal position of the top left corner of the text
        i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);  -- vertical position of the top left corner of the text
        i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);  -- current pixel horizontal position
        i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);  -- current pixel vertical position
        
        o_pixel : out STD_LOGIC
    );
end pixel_on_text;

architecture Behavioral of pixel_on_text is
    
    signal fontAddress : INTEGER range 0 to C_ARRAY_SIZE-1;
    
    -- A row of bits in a character, we check if our current (x,y) is 1 in char row
    signal charBitInRow : STD_LOGIC_VECTOR(C_FONT_WIDTH-1 downto 0);
    
    signal charCode     : INTEGER range 0 to C_ASCII_CODE_RANGE-1;  -- character ASCII code
    
    signal shifted_hpos : STD_LOGIC_VECTOR(11 downto 0);
    signal charPosition : STD_LOGIC_VECTOR(11 downto C_FONT_WIDTH_POW);   -- the position(column) of a character in the given text
    signal bitPosition  : STD_LOGIC_VECTOR(C_FONT_WIDTH_POW-1 downto 0);  -- the bit position(column) in a character
    
begin
    shifted_hpos <= i_hcounter - i_text_hpos;
    charPosition <= shifted_hpos(11 downto C_FONT_WIDTH_POW);
    bitPosition  <= shifted_hpos(C_FONT_WIDTH_POW-1 downto 0);
    
    charCode <= character'pos(i_display_text(to_integer(unsigned(charPosition))));
    
    fontAddress <= charCode*16 + to_integer(unsigned(i_vcounter - i_text_vpos));
    
    fontRom : process(i_clk)
    begin
        if rising_edge(i_clk) then
            charBitInRow <= C_CHARACTERS_TABLE(fontAddress);
        end if;
    end process;
    
    pixelOn: process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_pixel <= '0';
            
            if (i_hcounter >= i_text_hpos and i_hcounter < i_text_hpos + (C_FONT_WIDTH * G_TEXT_LENGTH)) 
             and (i_vcounter >= i_text_vpos and i_vcounter < i_text_vpos + C_FONT_HEIGHT) then
                -- C_FONT_WIDTH-bitPosition: we are reverting the character
                if charBitInRow(C_FONT_WIDTH-to_integer(unsigned(bitPosition))) = '1' then
                    o_pixel <= '1';
                end if;
                
            end if;
            
        end if;
    end process;
    
    
    
end Behavioral;
