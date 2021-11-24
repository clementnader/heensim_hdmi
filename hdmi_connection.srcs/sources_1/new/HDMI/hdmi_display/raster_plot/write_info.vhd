----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/22/2021 05:14:24 PM
-- Design Name: 
-- Module Name: write_info - Behavioral
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
    use work.events_list_pkg.ALL;
    use work.character_definition_pkg.ALL;


entity write_info is
    port (
        i_clk      : in STD_LOGIC;
        i_hcounter : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter : in STD_LOGIC_VECTOR(11 downto 0);
        
        o_board_pixel : out STD_LOGIC;
        o_text_pixel  : out STD_LOGIC;
        o_val_pixel   : out STD_LOGIC
    );
end write_info;


architecture Behavioral of write_info is

    component write_text
        generic (
           G_TEXT_LENGTH : INTEGER
        );
        port (
            i_clk          : in STD_LOGIC;
            i_display_text : in STRING(1 to G_TEXT_LENGTH);
            i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_pixel : out STD_LOGIC
        );
    end component;
    
    ------------------------------------------
    
    constant C_NB_CHIP_STR : STRING := integer'image(C_MAX_CHIP_ID);
    constant C_NB_VIRT_STR : STRING := integer'image(C_MAX_VIRT+1);
    constant C_NB_ROW_STR  : STRING := integer'image(C_MAX_ROW+1);
    constant C_NB_COL_STR  : STRING := integer'image(C_MAX_COLUMN+1);
    
    signal nb_chip_pixel : STD_LOGIC;
    signal nb_virt_pixel : STD_LOGIC;
    signal nb_row_pixel  : STD_LOGIC;
    signal nb_col_pixel  : STD_LOGIC;
    
    signal nb_chip_val_pixel : STD_LOGIC;
    signal nb_virt_val_pixel : STD_LOGIC;
    signal nb_row_val_pixel  : STD_LOGIC;
    signal nb_col_val_pixel  : STD_LOGIC;
    
    ------------------------------------------
    
begin
    
    o_text_pixel <= nb_chip_pixel or nb_virt_pixel or nb_row_pixel or nb_col_pixel;
    o_val_pixel  <= nb_chip_val_pixel or nb_virt_val_pixel or nb_row_val_pixel or nb_col_val_pixel;
    
    ------------------------------------------
    
    write_text_inst_board_name : write_text
        generic map (
           G_TEXT_LENGTH => C_BOARD_NAME'length
        )
        port map (
            i_clk          => i_clk,
            i_display_text => C_BOARD_NAME,
            i_text_hpos    => x"008",
            i_text_vpos    => x"008",
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => o_board_pixel
        );
    
    ------------------------------------------
    
    write_text_inst_nb_chip : write_text
        generic map (
           G_TEXT_LENGTH => 16
        )
        port map (
            i_clk          => i_clk,
            i_display_text => "Number of chips:",
            i_text_hpos    => x"008",
            i_text_vpos    => x"008" + 2*C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => nb_chip_pixel
        );
    
    write_text_inst_nb_chip_val : write_text
        generic map (
           G_TEXT_LENGTH => C_NB_CHIP_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_display_text => C_NB_CHIP_STR,
            i_text_hpos    => x"008" + (16+1)*C_FONT_WIDTH,
            i_text_vpos    => x"008" + 2*C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => nb_chip_val_pixel
        );
    
    ------------------------------------------
    
    write_text_inst_nb_virt : write_text
        generic map (
           G_TEXT_LENGTH => 25
        )
        port map (
            i_clk          => i_clk,
            i_display_text => "Number of virtualization:",
            i_text_hpos    => x"008",
            i_text_vpos    => x"008" + 3*C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => nb_virt_pixel
        );
    
    write_text_inst_nb_virt_val : write_text
        generic map (
           G_TEXT_LENGTH => C_NB_VIRT_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_display_text => C_NB_VIRT_STR,
            i_text_hpos    => x"008" + (25+1)*C_FONT_WIDTH,
            i_text_vpos    => x"008" + 3*C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => nb_virt_val_pixel
        );
    
    ------------------------------------------
    
    write_text_inst_nb_row : write_text
        generic map (
           G_TEXT_LENGTH => 15
        )
        port map (
            i_clk          => i_clk,
            i_display_text => "Number of rows:",
            i_text_hpos    => x"008",
            i_text_vpos    => x"008" + 4*C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => nb_row_pixel
        );
    
    write_text_inst_nb_row_val : write_text
        generic map (
           G_TEXT_LENGTH => C_NB_ROW_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_display_text => C_NB_ROW_STR,
            i_text_hpos    => x"008" + (15+1)*C_FONT_WIDTH,
            i_text_vpos    => x"008" + 4*C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => nb_row_val_pixel
        );
    
    ------------------------------------------
    
    write_text_inst_nb_col : write_text
        generic map (
           G_TEXT_LENGTH => 18
        )
        port map (
            i_clk          => i_clk,
            i_display_text => "Number of columns:",
            i_text_hpos    => x"008",
            i_text_vpos    => x"008" + 5*C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => nb_col_pixel
        );
    
    write_text_inst_nb_col_val : write_text
        generic map (
           G_TEXT_LENGTH => C_NB_COL_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_display_text => C_NB_COL_STR,
            i_text_hpos    => x"008" + (18+1)*C_FONT_WIDTH,
            i_text_vpos    => x"008" + 5*C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => nb_col_val_pixel
        );
    
end Behavioral;
