----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/25/2021 11:11:18 AM
-- Design Name: 
-- Module Name: write_text_integer - Behavioral
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


entity write_text_integer is
    generic (
       G_TEXT_LENGTH : INTEGER
    );
    port (
        i_clk         : in STD_LOGIC;
        i_do_display  : in BOOLEAN;
        i_display_int : in INTEGER range 0 to 10**G_TEXT_LENGTH-1;
        i_text_hpos   : in STD_LOGIC_VECTOR(11 downto 0);  -- horizontal position of the top left corner of the text
        i_text_vpos   : in STD_LOGIC_VECTOR(11 downto 0);  -- vertical position of the top left corner of the text
        i_hcounter    : in STD_LOGIC_VECTOR(11 downto 0);  -- current pixel horizontal position
        i_vcounter    : in STD_LOGIC_VECTOR(11 downto 0);  -- current pixel vertical position
        
        o_pixel : out BOOLEAN
    );
end write_text_integer;


architecture Behavioral of write_text_integer is
    
    component split_integer_to_digits
        generic (
           G_NB_DIGITS : INTEGER
        );
        port (
            i_clk     : in STD_LOGIC;
            i_integer : in INTEGER range 0 to 10**G_NB_DIGITS-1;
            
            o_digits : out T_DIGITS_ARRAY(0 to G_NB_DIGITS-1)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    signal digits : T_DIGITS_ARRAY(0 to G_TEXT_LENGTH-1);
    
    signal within_range : BOOLEAN;
    
    signal shifted_hpos : STD_LOGIC_VECTOR(11 downto 0);
    signal shifted_vpos : STD_LOGIC_VECTOR(11 downto 0);
    
    signal char_pos_in_text : INTEGER range 0 to G_TEXT_LENGTH-1;  -- the position of the current character in the given text
    signal col_pos_in_char  : INTEGER range 0 to C_FONT_WIDTH-1;   -- the current column position in the character
    signal char_code        : STD_LOGIC_VECTOR(6 downto 0);        -- character ASCII code of the current character
    
    signal row_addr_in_table : STD_LOGIC_VECTOR(10 downto 0);          -- the current row position in the characters table
    signal current_char_row  : STD_LOGIC_VECTOR(0 to C_FONT_WIDTH-1);  -- the current row of bits in the character
    
begin
    
    split_integer_to_digits_inst : split_integer_to_digits
        generic map (
           G_NB_DIGITS => G_TEXT_LENGTH
        )
        port map (
            i_clk     => i_clk,
            i_integer => i_display_int,
            
            o_digits => digits
        );
    
    -----------------------------------------------------------------------------------
    
    within_range <= (i_hcounter >= i_text_hpos) and (i_hcounter < i_text_hpos + (C_FONT_WIDTH * G_TEXT_LENGTH))
                and (i_vcounter >= i_text_vpos) and (i_vcounter < i_text_vpos + C_FONT_HEIGHT);
    
    shifted_hpos <= i_hcounter - i_text_hpos;
    shifted_vpos <= i_vcounter - i_text_vpos;
    
    char_pos_in_text <= to_integer(unsigned(shifted_hpos(shifted_hpos'high downto C_FONT_WIDTH_POW)));
    col_pos_in_char  <= to_integer(unsigned(shifted_hpos(C_FONT_WIDTH_POW-1 downto 0)-1));  -- the minus one is because we need one clock period to process the data but hcounter increments continuously
    
    char_code <= C_ZERO_CHAR + digits(char_pos_in_text) when i_do_display and digits(char_pos_in_text) /= -1
            else C_SPACE_CHAR;
    
    row_addr_in_table <= char_code & shifted_vpos(3 downto 0);
    
    -----------------------------------------------------------------------------------
    
    read_char_row_from_table_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            current_char_row <= C_CHARACTERS_TABLE(to_integer(unsigned(row_addr_in_table)));
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    check_if_the_current_pixel_has_to_be_on_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_pixel <= (current_char_row(col_pos_in_char) = '1') and within_range;
            
        end if;
    end process;
    
end Behavioral;
