----------------------------------------------------------------------------------
-- Project Name:  HEENS
-- Design Name:   SNN_pkg.vhd
-- Module Name:   SNN_pkg (package)
--
-- Creator: Jordi Madrenas
-- E-mail: jordi.madrenas@upc.edu 
-- Modified: Mireya Zapata
-- Modified: Jordi Madrenas
-- Company: Universitat Politecnica de Catalunya (UPC)
--          
-- Date:    May 2016
--
-- Description: This package defines the constants, types, and 
--              components of the SNN multiprocessor array
--
--
--
-- Revision: 0.31 September 30, 2016. Debugged. Added type opcode_symb and constant opcode_vect
-- Revision: 0.32 October 10, 2016. Added virtual constants
-- Revision: 0.33 October 24, 2016. Added new instructions MOVS, SPMOV, INCV, READMPV
-- Revision: 0.35 November 2, 2016. General debug.
-- Revision: 0.36 December 12, 2019. LOCAL_SYN definition is modified.
--
--
-- Additional Comments: 
-- 
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;


package SNN_pkg is
    
    -----------------------------------------------------------------------------------------------------
    --------------------------------------- GLOBAL PARAMETERS -------------------------------------------
    -----------------------------------------------------------------------------------------------------
    constant size_x        : integer := 11;         -- 4 columns -- 4 bits: 1 <= size_x <= 16
    constant size_y        : integer := 11;         -- 4 rows    -- 4 bits: 1 <= size_y <= 16
    constant size_x_1      : integer := size_x - 1; -- Number of Processing Element columns;
    constant size_y_1      : integer := size_y - 1; -- Number of Processing Element rows;
    constant max_neuron_v  : integer := 7;          -- Maximum number of virtual layers
    
end SNN_pkg;


package body SNN_pkg is
    
end;
