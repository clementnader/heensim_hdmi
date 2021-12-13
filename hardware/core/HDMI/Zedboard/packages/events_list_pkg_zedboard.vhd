----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/05/2021 12:07:46 PM
-- Package Name: events_list_pkg
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


package events_list_pkg is
    
    -- ZedBoard
    constant C_PLATFORM_NAME : STRING := "ZedBoard";
    
    constant C_MAX_CHIP_ID : INTEGER := 1;
    constant C_MAX_VIRT    : INTEGER := 7;
    constant C_MAX_ROW     : INTEGER := 4;
    constant C_MAX_COLUMN  : INTEGER := 4;
    
    constant C_RANGE_ID : INTEGER := 200;
    
    ------------------------------------------
    
    constant C_LENGTH_CHIP_ID : INTEGER := 7;
    constant C_LENGTH_VIRT    : INTEGER := 3;
    constant C_LENGTH_ROW     : INTEGER := 4;
    constant C_LENGTH_COLUMN  : INTEGER := 4;
    
    constant C_LENGTH_NEURON_ID : INTEGER := C_LENGTH_CHIP_ID + C_LENGTH_VIRT + C_LENGTH_ROW + C_LENGTH_COLUMN;  -- 18
    
    constant C_LENGTH_TIMESTAMP : INTEGER := 32;
    
    ------------------------------------------
    
    function get_id_value (
        neuron_id : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0)
    ) return STD_LOGIC_VECTOR;
    
end package;


package body events_list_pkg is
    
    function get_id_value (
        neuron_id : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0)
    ) return STD_LOGIC_VECTOR is
            variable chip_id  : STD_LOGIC_VECTOR(C_LENGTH_CHIP_ID-1   downto 0);
            variable virt     : STD_LOGIC_VECTOR(C_LENGTH_VIRT-1      downto 0);
            variable row      : STD_LOGIC_VECTOR(C_LENGTH_ROW-1       downto 0);
            variable column   : STD_LOGIC_VECTOR(C_LENGTH_COLUMN-1    downto 0);
            variable id_value : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID+2 downto 0);
            
            constant C_LOW_CHIP_ID : INTEGER := C_LENGTH_NEURON_ID-C_LENGTH_CHIP_ID;
            constant C_LOW_VIRT    : INTEGER := C_LOW_CHIP_ID-C_LENGTH_VIRT;
            constant C_LOW_ROW     : INTEGER := C_LOW_VIRT-C_LENGTH_ROW;
            
        begin
            chip_id := neuron_id(C_LENGTH_NEURON_ID-1 downto C_LOW_CHIP_ID);
            virt    := neuron_id(C_LOW_CHIP_ID-1      downto C_LOW_VIRT);
            row     := neuron_id(C_LOW_VIRT-1         downto C_LOW_ROW);
            column  := neuron_id(C_LOW_ROW-1          downto 0);
            
            id_value := column
                + std_logic_vector(to_unsigned(C_MAX_COLUMN+1, C_LENGTH_COLUMN+1)) * (row
                + std_logic_vector(to_unsigned(C_MAX_ROW+1,    C_LENGTH_ROW+1))    * (virt
                + std_logic_vector(to_unsigned(C_MAX_VIRT+1,   C_LENGTH_VIRT+1))   * (chip_id-1)));
            
            return id_value(C_LENGTH_NEURON_ID-1 downto 0);
        
    end function;
    
end package body;
