----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/15/2021 07:59:23 PM
-- Design Name: 
-- Package Name: neurons_pkg
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
    use IEEE.MATH_REAL.ALL;

library work;
    use work.SNN_pkg.ALL;


package neurons_pkg is
    
    constant C_RANGE_ID            : INTEGER := 968;
    constant C_RANGE_ID_SMALL_PLOT : INTEGER := 200;
    
    -----------------------------------------------------------------------------------
    
    constant C_MAX_CHIP_ID : INTEGER := 1;
    constant C_MAX_VIRT    : INTEGER := max_neuron_v;
    constant C_MAX_ROW     : INTEGER := size_x_1;
    constant C_MAX_COLUMN  : INTEGER := size_y_1;
    
    constant C_MAX_ID : INTEGER := C_MAX_COLUMN
        + (C_MAX_COLUMN+1) * (C_MAX_ROW
        + (C_MAX_ROW+1)    * (C_MAX_VIRT
        + (C_MAX_VIRT+1)   * (C_MAX_CHIP_ID-1)));
    
    -----------------------------------------------------------------------------------
    
    function minimum (
        val1 : INTEGER;
        val2 : INTEGER
    ) return INTEGER;
    
    constant C_SMALL_RANGE_ID : INTEGER := minimum(C_MAX_ID+1, C_RANGE_ID_SMALL_PLOT);
    constant C_EXT_RANGE_ID   : INTEGER := minimum(C_MAX_ID+1, C_RANGE_ID);
    
    -----------------------------------------------------------------------------------
    
    constant C_LENGTH_CHIP_ID : INTEGER := 7;
    constant C_LENGTH_VIRT    : INTEGER := 3;
    constant C_LENGTH_ROW     : INTEGER := 4;
    constant C_LENGTH_COLUMN  : INTEGER := 4;
    
    constant C_LENGTH_NEURON_ID : INTEGER := C_LENGTH_CHIP_ID + C_LENGTH_VIRT + C_LENGTH_ROW + C_LENGTH_COLUMN;  -- 18
    
    constant C_LENGTH_TIMESTAMP : INTEGER := 32;
    
    -----------------------------------------------------------------------------------
    
    function get_id_value (
        neuron_id : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0)
    ) return INTEGER;
    
    -----------------------------------------------------------------------------------
    
    constant C_ANALOG_VALUE_SIZE : INTEGER := 16;
    
    constant C_ANALOG_MIN_VALUE : INTEGER := -8000;
    constant C_ANALOG_MAX_VALUE : INTEGER := -3000;
    
    constant C_TARGET_MIN : INTEGER := 0;
    constant C_TARGET_MAX : INTEGER := 180;
    
    constant C_ANALOG_PLOT_VALUE_SIZE : INTEGER := integer(ceil(log2(real(C_TARGET_MAX))));  -- 8
    
    constant C_NB_NEURONS_ANALOG : INTEGER := 4;
    
    constant C_ANALOG_MEM_SIZE : INTEGER := C_ANALOG_PLOT_VALUE_SIZE*C_NB_NEURONS_ANALOG;  -- 32
    
    -----------------------------------------------------------------------------------
    
    constant C_ANALOG_TRANSFORM_DIVIDER : REAL    := real(C_ANALOG_MAX_VALUE-C_ANALOG_MIN_VALUE) / real(C_TARGET_MAX-C_TARGET_MIN);
    constant C_ANALOG_TRANSFORM_ADDER   : INTEGER := C_TARGET_MIN - C_ANALOG_MIN_VALUE;
    
    constant C_ANALOG_DIV_PRECISION_BITS : INTEGER := 16;
    constant C_ANALOG_DIV_MULTIPLIER     : INTEGER := integer(ceil(real(2**C_ANALOG_DIV_PRECISION_BITS)/C_ANALOG_TRANSFORM_DIVIDER));
    
end package;


package body neurons_pkg is
    
    function minimum (
        val1 : INTEGER;
        val2 : INTEGER
    ) return INTEGER is
        
        begin
            if val1 < val2 then
                return val1;
            else
                return val2;
            end if;
        
    end function;
    
    -----------------------------------------------------------------------------------
    
    function get_id_value (
        neuron_id : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0)
    ) return INTEGER is
            variable chip_id : STD_LOGIC_VECTOR(C_LENGTH_CHIP_ID-1 downto 0);
            variable virt    : STD_LOGIC_VECTOR(C_LENGTH_VIRT-1    downto 0);
            variable row     : STD_LOGIC_VECTOR(C_LENGTH_ROW-1     downto 0);
            variable column  : STD_LOGIC_VECTOR(C_LENGTH_COLUMN-1  downto 0);
            
            variable nb_chip_id : INTEGER range 0 to C_MAX_CHIP_ID-1;
            variable nb_virt    : INTEGER range 0 to C_MAX_VIRT;
            variable nb_row     : INTEGER range 0 to C_MAX_ROW;
            variable nb_column  : INTEGER range 0 to C_MAX_COLUMN;
            
            variable id_value : INTEGER range 0 to C_MAX_ID;
            
            constant C_LOW_CHIP_ID : INTEGER := C_LENGTH_NEURON_ID-C_LENGTH_CHIP_ID;
            constant C_LOW_VIRT    : INTEGER := C_LOW_CHIP_ID-C_LENGTH_VIRT;
            constant C_LOW_ROW     : INTEGER := C_LOW_VIRT-C_LENGTH_ROW;
            
        begin
            chip_id := neuron_id(C_LENGTH_NEURON_ID-1 downto C_LOW_CHIP_ID);
            virt    := neuron_id(C_LOW_CHIP_ID-1      downto C_LOW_VIRT);
            row     := neuron_id(C_LOW_VIRT-1         downto C_LOW_ROW);
            column  := neuron_id(C_LOW_ROW-1          downto 0);
            
            nb_chip_id := to_integer(unsigned(chip_id-1));
            nb_virt    := to_integer(unsigned(virt));
            nb_row     := to_integer(unsigned(row));
            nb_column  := to_integer(unsigned(column));
            
            id_value := nb_column
                + (C_MAX_COLUMN+1) * (nb_row
                + (C_MAX_ROW+1)    * (nb_virt
                + (C_MAX_VIRT+1)   * (nb_chip_id)));
            
            return id_value;
        
    end function;
    
end package body;
