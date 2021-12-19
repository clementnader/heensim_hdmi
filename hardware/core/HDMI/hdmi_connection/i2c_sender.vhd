----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/26/2021 07:09:43 PM
-- Design Name: 
-- Module Name: i2c_sender - Behavioral
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


entity i2c_sender is
    generic (
        G_DATA_LENGTH : INTEGER
    );
    port (
        i_clk    : in STD_LOGIC;
        i_clk_x2 : in STD_LOGIC;
        i_rst    : in STD_LOGIC;
        i_addr   : in STD_LOGIC_VECTOR(6 downto 0);
        i_data   : in STD_LOGIC_VECTOR(8*G_DATA_LENGTH-1 downto 0);
        i_start  : in STD_LOGIC;
        
        o_scl   : out STD_LOGIC;
        o_sda   : out STD_LOGIC;
        o_ready : out STD_LOGIC
    );
end i2c_sender;


architecture Behavioral of i2c_sender is
    
    -- Shift registers
    constant C_SR_LENGTH : INTEGER := 2 + 9*(G_DATA_LENGTH+1);
    
    signal busy_sr              : STD_LOGIC_VECTOR(C_SR_LENGTH-1 downto 0) := (others => '0');
    signal clk_first_quarter_sr : STD_LOGIC_VECTOR(C_SR_LENGTH-1 downto 0) := (others => '1');
    signal clk_last_quarter_sr  : STD_LOGIC_VECTOR(C_SR_LENGTH-1 downto 0) := (others => '1');
    signal ack_sr          : STD_LOGIC_VECTOR(C_SR_LENGTH-1 downto 0) := (others => '0');
    signal data_sr              : STD_LOGIC_VECTOR(C_SR_LENGTH-1 downto 0) := (others => '1');
    
    -----------------------------------------------------------------------------------
    
    type T_I2C_STATE is (
        READY,
        SET_SHIFT_REG,
        SHIFT_REG
    );
    
    signal i2c_state : T_I2C_STATE := READY;
    
begin
    
    o_ready <= '1' when i2c_state = READY else '0';
    
    -----------------------------------------------------------------------------------
    
    o_sda <= data_sr(data_sr'high) when ack_sr(ack_sr'high) = '0'
        else 'Z';
    
    o_scl <= clk_first_quarter_sr(clk_first_quarter_sr'high) when i_clk = '1' and i_clk_x2 = '1'
        else clk_last_quarter_sr(clk_last_quarter_sr'high)   when i_clk = '0' and i_clk_x2 = '0'
        else '1';
    
    -----------------------------------------------------------------------------------
    
    state_machine_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_rst = '1' then
                i2c_state <= READY;
            else
                case i2c_state is
                    when READY =>
                        if i_start = '1' then
                            i2c_state <= SET_SHIFT_REG;
                        end if;
                    
                    when SET_SHIFT_REG =>
                        i2c_state <= SHIFT_REG;
                    
                    when SHIFT_REG =>
                        if busy_sr(busy_sr'high) = '0' then
                            i2c_state <= READY;
                        end if;
                    
                    when others =>
                        i2c_state <= READY;
                    
                end case;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    i2c_sending_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            case i2c_state is
                
                when READY =>
                    -- Default values
                    busy_sr              <= (others => '0');
                    clk_first_quarter_sr <= (others => '1');
                    clk_last_quarter_sr  <= (others => '1');
                    ack_sr          <= (others => '0');
                    data_sr              <= (others => '1');
                    
                when SET_SHIFT_REG =>
                    -- Put the new data into the shift registers
                    busy_sr              <= (others => '1');
                    clk_first_quarter_sr <= (clk_first_quarter_sr'high => '1', others => '0');
                    clk_last_quarter_sr  <= (0 => '1', others => '0');
                    
                    -- start bit
                    ack_sr(C_SR_LENGTH-1)  <= '0';
                    data_sr(C_SR_LENGTH-1) <= '0';
                    -- I2C address on 7 bits
                    ack_sr(C_SR_LENGTH-2 downto C_SR_LENGTH-8)  <= b"0000_000";
                    data_sr(C_SR_LENGTH-2 downto C_SR_LENGTH-8) <= i_addr;
                    -- R/W bit
                    ack_sr(C_SR_LENGTH-9)  <= '0';
                    data_sr(C_SR_LENGTH-9) <= '0';  -- write
                    -- ack bit
                    ack_sr(C_SR_LENGTH-10)  <= '1';
                    data_sr(C_SR_LENGTH-10) <= '1';
                    for i in 0 to G_DATA_LENGTH-1 loop
                        -- data on 8 bits
                        ack_sr(C_SR_LENGTH-11-9*i downto C_SR_LENGTH-18-9*i)  <= b"0000_0000";
                        data_sr(C_SR_LENGTH-11-9*i downto C_SR_LENGTH-18-9*i) <= i_data(8*(G_DATA_LENGTH-i)-1 downto 8*(G_DATA_LENGTH-i)-8);
                        -- ack bit
                        ack_sr(C_SR_LENGTH-19-9*i)  <= '1';
                        data_sr(C_SR_LENGTH-19-9*i) <= '1';
                    end loop;
                    -- stop bit
                    ack_sr(0)  <= '0';
                    data_sr(0) <= '0';
                    
                when SHIFT_REG =>
                    -- Shift registers
                    busy_sr              <= busy_sr(busy_sr'high-1 downto 0) & '0';
                    clk_first_quarter_sr <= clk_first_quarter_sr(clk_first_quarter_sr'high-1 downto 0) & '1';
                    clk_last_quarter_sr  <= clk_last_quarter_sr(clk_last_quarter_sr'high-1 downto 0) & '1';
                    ack_sr               <= ack_sr(ack_sr'high-1 downto 0) & '0';
                    data_sr              <= data_sr(data_sr'high-1 downto 0) & '1';
                    
                when others =>
                    
            end case;
            
        end if;
    end process;
    
end Behavioral;
