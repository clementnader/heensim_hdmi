----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/19/2022 02:36:21 PM
-- Design Name: 
-- Module Name: write_neuron_info - Behavioral
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
    use work.plot_pkg.ALL;
    use work.neurons_pkg.ALL;
    use work.character_definition_pkg.ALL;


entity write_neuron_info is
    generic (
        G_TOP_V_POS  : STD_LOGIC_VECTOR(11 downto 0);
        G_COLOR_NAME : STRING
    );
    port (
        i_clk       : in STD_LOGIC;
        i_hcounter  : in STD_LOGIC_VECTOR(11 downto 0);
        i_vcounter  : in STD_LOGIC_VECTOR(11 downto 0);
        i_neuron_id : in STD_LOGIC_VECTOR(C_LENGTH_NEURON_INFO-1 downto 0);
        
        o_text_pixel  : out BOOLEAN;
        o_value_pixel : out BOOLEAN
    );
end write_neuron_info;


architecture Behavioral of write_neuron_info is
    
    component write_text
        generic (
           G_TEXT_LENGTH : INTEGER
        );
        port (
            i_clk          : in STD_LOGIC;
            i_do_display   : in BOOLEAN;
            i_display_text : in STRING(1 to G_TEXT_LENGTH);
            i_text_hpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_text_vpos    : in STD_LOGIC_VECTOR(11 downto 0);
            i_hcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter     : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_pixel : out BOOLEAN
        );
    end component;
    
    component split_integer_to_digits is
        generic (
            G_NB_DIGITS : INTEGER
        );
        port (
            i_clk     : in STD_LOGIC;
            i_integer : in INTEGER range 0 to 10**G_NB_DIGITS-1;
            
            o_digits : out T_DIGITS_ARRAY(G_NB_DIGITS-1 downto 0)
        );
    end component;
    
    component write_text_integer
        generic (
           G_NB_DIGITS : INTEGER
        );
        port (
            i_clk         : in STD_LOGIC;
            i_do_display  : in BOOLEAN;
            i_display_int : in T_DIGITS_ARRAY(G_NB_DIGITS-1 downto 0);
            i_text_hpos   : in STD_LOGIC_VECTOR(11 downto 0);
            i_text_vpos   : in STD_LOGIC_VECTOR(11 downto 0);
            i_hcounter    : in STD_LOGIC_VECTOR(11 downto 0);
            i_vcounter    : in STD_LOGIC_VECTOR(11 downto 0);
            
            o_pixel : out BOOLEAN
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    constant C_NEURON_STR : STRING := "Neuron in";
    
    constant C_VIRT_STR   : STRING := "Virtualization level:";
    constant C_ROW_STR    : STRING := "Row:";
    constant C_COLUMN_STR : STRING := "Column:";
    
    constant C_NUMERO_STR : STRING := "Identifier value:";
    
    constant C_BASE_H_POS      : STD_LOGIC_VECTOR(11 downto 0) := x"008";
    constant C_BASE_H_POS_INFO : STD_LOGIC_VECTOR(11 downto 0) := C_BASE_H_POS + x"008";
    
    -----------------------------------------------------------------------------------
    
    signal neuron_pixel : BOOLEAN;
    signal color_pixel  : BOOLEAN;
    
    -----------------------------------------------------------------------------------
    
    signal virt_value   : STD_LOGIC_VECTOR(C_LENGTH_VIRT-1 downto 0);
    signal row_value    : STD_LOGIC_VECTOR(C_LENGTH_ROW-1 downto 0);
    signal column_value : STD_LOGIC_VECTOR(C_LENGTH_COLUMN-1 downto 0);
    
    signal virt_int   : INTEGER range 0 to C_MAX_VIRT;
    signal row_int    : INTEGER range 0 to C_MAX_ROW;
    signal column_int : INTEGER range 0 to C_MAX_COLUMN;
    
    signal virt_digits_array   : T_DIGITS_ARRAY(C_VIRT_NB_DIGITS-1 downto 0);
    signal row_digits_array    : T_DIGITS_ARRAY(C_ROW_NB_DIGITS-1 downto 0);
    signal column_digits_array : T_DIGITS_ARRAY(C_COLUMN_NB_DIGITS-1 downto 0);
    
    signal virt_pixel   : BOOLEAN;
    signal row_pixel    : BOOLEAN;
    signal column_pixel : BOOLEAN;
    
    signal virt_val_pixel   : BOOLEAN;
    signal row_val_pixel    : BOOLEAN;
    signal column_val_pixel : BOOLEAN;
    
    -----------------------------------------------------------------------------------
    
    signal numero_int : INTEGER range 0 to C_MAX_ID;
    
    signal numero_digits_array : T_DIGITS_ARRAY(C_NUMERO_NB_DIGITS-1 downto 0);
    
    signal numero_pixel     : BOOLEAN;
    signal numero_val_pixel : BOOLEAN;
    
begin
    
    o_text_pixel  <= neuron_pixel or virt_pixel     or row_pixel     or column_pixel     or numero_pixel;
    o_value_pixel <= color_pixel  or virt_val_pixel or row_val_pixel or column_val_pixel or numero_val_pixel;
    
    -----------------------------------------------------------------------------------
    
    column_value <= i_neuron_id(C_LENGTH_COLUMN-1 downto 0);
    row_value    <= i_neuron_id(C_LENGTH_ROW+C_LENGTH_COLUMN-1 downto C_LENGTH_COLUMN);
    virt_value   <= i_neuron_id(i_neuron_id'high downto C_LENGTH_ROW+C_LENGTH_COLUMN);
    
    column_int <= to_integer(unsigned(column_value));
    row_int    <= to_integer(unsigned(row_value));
    virt_int   <= to_integer(unsigned(virt_value));
    
    -----------------------------------------------------------------------------------
    
    get_id_value_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            numero_int <= get_id_value("0000000" & i_neuron_id);
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    -- Neuron
    write_text_inst_neuron : write_text
        generic map (
            G_TEXT_LENGTH => C_NEURON_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_NEURON_STR,
            i_text_hpos    => C_BASE_H_POS,
            i_text_vpos    => G_TOP_V_POS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => neuron_pixel
        );
    
    write_text_inst_color : write_text
        generic map (
            G_TEXT_LENGTH => G_COLOR_NAME'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => G_COLOR_NAME,
            i_text_hpos    => C_BASE_H_POS + (C_NEURON_STR'length+1)*C_FONT_WIDTH,
            i_text_vpos    => G_TOP_V_POS,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => color_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    -- Virtualization level
    write_text_inst_virt : write_text
        generic map (
            G_TEXT_LENGTH => C_VIRT_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_VIRT_STR,
            i_text_hpos    => C_BASE_H_POS_INFO,
            i_text_vpos    => G_TOP_V_POS + C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => virt_pixel
        );
    
    split_integer_to_digits_inst_virt : split_integer_to_digits
        generic map (
            G_NB_DIGITS => C_VIRT_NB_DIGITS
        )
        port map (
            i_clk     => i_clk,
            i_integer => virt_int,
            
            o_digits => virt_digits_array
        );
    
    write_text_integer_inst_virt : write_text_integer
        generic map (
            G_NB_DIGITS => C_VIRT_NB_DIGITS
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_int  => virt_digits_array,
            i_text_hpos    => C_BASE_H_POS_INFO + (C_VIRT_STR'length+1)*C_FONT_WIDTH,
            i_text_vpos    => G_TOP_V_POS + C_FONT_HEIGHT,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => virt_val_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    -- Row
    write_text_inst_row : write_text
        generic map (
            G_TEXT_LENGTH => C_ROW_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_ROW_STR,
            i_text_hpos    => C_BASE_H_POS_INFO,
            i_text_vpos    => G_TOP_V_POS + C_FONT_HEIGHT*2,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => row_pixel
        );
    
    split_integer_to_digits_inst_row : split_integer_to_digits
        generic map (
            G_NB_DIGITS => C_ROW_NB_DIGITS
        )
        port map (
            i_clk     => i_clk,
            i_integer => row_int,
            
            o_digits => row_digits_array
        );
    
    write_text_integer_inst_row : write_text_integer
        generic map (
            G_NB_DIGITS => C_ROW_NB_DIGITS
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_int  => row_digits_array,
            i_text_hpos    => C_BASE_H_POS_INFO + (C_ROW_STR'length+1)*C_FONT_WIDTH,
            i_text_vpos    => G_TOP_V_POS + C_FONT_HEIGHT*2,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => row_val_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    -- Column
    write_text_inst_column : write_text
        generic map (
            G_TEXT_LENGTH => C_COLUMN_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_COLUMN_STR,
            i_text_hpos    => C_BASE_H_POS_INFO,
            i_text_vpos    => G_TOP_V_POS + C_FONT_HEIGHT*3,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => column_pixel
        );
    
    split_integer_to_digits_inst_column : split_integer_to_digits
        generic map (
            G_NB_DIGITS => C_COLUMN_NB_DIGITS
        )
        port map (
            i_clk     => i_clk,
            i_integer => column_int,
            
            o_digits => column_digits_array
        );
    
    write_text_integer_inst_column : write_text_integer
        generic map (
            G_NB_DIGITS => C_COLUMN_NB_DIGITS
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_int  => column_digits_array,
            i_text_hpos    => C_BASE_H_POS_INFO + (C_COLUMN_STR'length+1)*C_FONT_WIDTH,
            i_text_vpos    => G_TOP_V_POS + C_FONT_HEIGHT*3,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => column_val_pixel
        );
    
    -----------------------------------------------------------------------------------
    
    -- Neuron numero
    write_text_inst_numero : write_text
        generic map (
            G_TEXT_LENGTH => C_NUMERO_STR'length
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_text => C_NUMERO_STR,
            i_text_hpos    => C_BASE_H_POS_INFO,
            i_text_vpos    => G_TOP_V_POS + C_FONT_HEIGHT*5,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => numero_pixel
        );
    
    split_integer_to_digits_inst_numero : split_integer_to_digits
        generic map (
            G_NB_DIGITS => C_NUMERO_NB_DIGITS
        )
        port map (
            i_clk     => i_clk,
            i_integer => numero_int,
            
            o_digits => numero_digits_array
        );
    
    write_text_integer_inst_numero : write_text_integer
        generic map (
            G_NB_DIGITS => C_NUMERO_NB_DIGITS
        )
        port map (
            i_clk          => i_clk,
            i_do_display   => True,
            i_display_int  => numero_digits_array,
            i_text_hpos    => C_BASE_H_POS_INFO + (C_NUMERO_STR'length+1)*C_FONT_WIDTH,
            i_text_vpos    => G_TOP_V_POS + C_FONT_HEIGHT*5,
            i_hcounter     => i_hcounter,
            i_vcounter     => i_vcounter,
            
            o_pixel => numero_val_pixel
        );
    
end Behavioral;
