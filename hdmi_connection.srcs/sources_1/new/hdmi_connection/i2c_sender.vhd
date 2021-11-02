----------------------------------------------------------------------------------
-- Engineer:    Mike Field <hamster@snap.net.nz>
-- 
-- Module Name: i2c_sender h- Behavioral 
--
-- Description: Send register writes over an I2C-like interface
--
-- Feel free to use this how you see fit, and fix any errors you find :-)
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;
    use IEEE.STD_LOGIC_UNSIGNED.ALL;
    use IEEE.NUMERIC_STD.ALL;


entity i2c_sender is
    port (
        i_clk : in STD_LOGIC;
        
        o_sioc : out STD_LOGIC;
        o_siod : out STD_LOGIC
    );
end i2c_sender;


architecture Behavioral of i2c_sender is
    
    signal divider           : STD_LOGIC_VECTOR(8 downto 0)  := (others => '0'); 
    -- this value gives nearly 200ms cycles before the first register is written
    signal initial_pause     : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    signal finished          : STD_LOGIC := '0';
    signal address           : STD_LOGIC_VECTOR( 7 downto 0) := (others => '0');
    signal clk_first_quarter : STD_LOGIC_VECTOR(28 downto 0) := (others => '1');
    signal clk_last_quarter  : STD_LOGIC_VECTOR(28 downto 0) := (others => '1');
    signal busy_sr           : STD_LOGIC_VECTOR(28 downto 0) := (others => '1');
    signal data_sr           : STD_LOGIC_VECTOR(28 downto 0) := (others => '1');
    signal tristate_sr       : STD_LOGIC_VECTOR(28 downto 0) := (others => '0');
    signal reg_value         : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
    constant C_I2C_WR_ADDR   : STD_LOGIC_VECTOR( 7 downto 0) := x"72";
    
    type T_REG_VALUE_PAIR is array(0 to 63) of STD_LOGIC_VECTOR(15 downto 0);    
    
    constant C_REG_VALUE_PAIRS : T_REG_VALUE_PAIR := (
        -------------------
        -- Powerup please!
        -------------------
        x"4110", 
        ---------------------------------------
        -- These valuse must be set as follows
        ---------------------------------------
        x"9803", x"9AE0", x"9C30", x"9D61", x"A2A4", x"A3A4", x"E0D0", x"5512", x"F900",
        
        ---------------
        -- Input mode
        ---------------
        x"1506", -- YCbCr 422, DDR, External sync
        x"4810", -- left justified data (D23 downto 8)
        -- according to documenation, style 2 should be x"1637" but it isn't. ARGH!
        x"1637", -- 444 output, 8 bit style 2, 1st half on rising edge - YCrCb clipping
        x"1700", -- output asp ect ratio 16:9, external DE 
        x"D03C", -- auto sync data - must be set for DDR modes. No DDR clock delay
        ---------------
        -- Output mode
        ---------------
        x"AF04", -- DVI mode
        x"4C04", -- Deep colour off (HDMI only?)     - not needed
        x"4000", -- Turn off additional data packets - not needed
        
        --------------------------------------------------------------
        -- Here is the YCrCb => RGB conversion, as per programming guide
        -- This is table 57 - HDTV YCbCr (16 to 255) to RGB (0 to 255)
        --------------------------------------------------------------
        -- (Cr * A1       +      Y * A2       +     Cb * A3)/4096 +     A4    =  Red
        x"18E7", x"1934",   x"1A04", x"1BAD",   x"1C00", x"1D00",   x"1E1C", x"1F1B",
        -- (Cr * B1       +      Y * B2       +     Cb * B3)/4096 +     B4    =  Green
        x"201D", x"21DC",   x"2204", x"23AD",   x"241F", x"2524",   x"2601", x"2735",
        -- (Cr * C1       +      Y * C2       +     Cb * C3)/4096 +     C4    =  Blue
        x"2800", x"2900",   x"2A04", x"2BAD",   x"2C08", x"2D7C",   x"2E1B", x"2F77",
        
        -- Extra space filled with FFFFs to signify end of data
        x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF",
        x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF",
        x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF", x"FFFF"
    );
    
begin
    
    registers: process(i_clk)
    begin
        if rising_edge(i_clk) then
            reg_value <= C_REG_VALUE_PAIRS(to_integer(unsigned(address)));
        end if;
    end process;
    
    i2c_tristate: process(data_sr, tristate_sr)
    begin
        if tristate_sr(tristate_sr'length-1) = '0' then
            o_siod <= data_sr(data_sr'length-1);
        else
            o_siod <= 'Z';
        end if;
    end process;
    
    with divider(divider'length-1 downto divider'length-2)
        select o_sioc <= clk_first_quarter(clk_first_quarter'length-1) when "00",
                         clk_last_quarter(clk_last_quarter'length-1)   when "11",
                         '1' when others;
    
    i2c_send: process(i_clk)
    begin
        if rising_edge(i_clk) then
            if busy_sr(busy_sr'length-1) = '0' then
                if initial_pause(initial_pause'length-1) = '0' then
                    initial_pause <= initial_pause + 1;
                elsif finished = '0' then
                    if divider = "111111111" then
                        divider <= (others =>'0');
                        if reg_value(15 downto 8) = x"FF" then
                            finished <= '1';
                        else
                            -- move the new data into the shift registers
                            clk_first_quarter <= (clk_first_quarter'length-1 => '1', others => '0');
                            clk_last_quarter  <= (0 => '1', others => '0');
                            --            Start     Address      Ack         Register           Ack           Value            Ack   Stop
                            tristate_sr <= "0" & "00000000"    & "1" & "00000000"             & "1" & "00000000"             & "1"  & "0";
                            data_sr     <= "0" & C_I2C_WR_ADDR & "1" & reg_value(15 downto 8) & "1" & reg_value( 7 downto 0) & "1"  & "0";
                            busy_sr     <= (others => '1');
                            address     <= address + 1;
                        end if;
                    else
                        divider <= divider+1; 
                    end if;
                end if;
            else
                if divider = "111111111" then   -- divide i_clk by 128 for I2C
                    tristate_sr       <= tristate_sr(tristate_sr'length-2 downto 0) & '0';
                    busy_sr           <= busy_sr(busy_sr'length-2 downto 0) & '0';
                    data_sr           <= data_sr(data_sr'length-2 downto 0) & '1';
                    clk_first_quarter <= clk_first_quarter(clk_first_quarter'length-2 downto 0) & '1';
                    clk_last_quarter  <= clk_last_quarter(clk_last_quarter'length-2   downto 0) & '1';
                    divider           <= (others => '0');
                else
                    divider <= divider + 1;
                end if;
            end if;
        end if;
    end process;
    
end Behavioral;
