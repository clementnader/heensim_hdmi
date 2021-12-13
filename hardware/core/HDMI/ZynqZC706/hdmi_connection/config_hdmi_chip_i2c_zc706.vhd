----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/27/2021 12:24:48 AM
-- Design Name: 
-- Module Name: config_hdmi_chip_i2c_zc706 - Behavioral
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


entity config_hdmi_chip_i2c_zc706 is
    port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        
        o_scl : out STD_LOGIC;
        o_sda : out STD_LOGIC
    );
end config_hdmi_chip_i2c_zc706;


architecture Behavioral of config_hdmi_chip_i2c_zc706 is
    
    constant C_MUX_I2C_ADDR  : STD_LOGIC_VECTOR(6 downto 0) := b"1110_100";
    constant C_MUX_SELECTION : STD_LOGIC_VECTOR(7 downto 0) := b"0000_0010";  -- to enable ADV7511 as slave
    
    constant C_HDMI_I2C_ADDR : STD_LOGIC_VECTOR(6 downto 0) := b"0111_001";
    
    -----------------------------------------------------------------------------------
    
    type T_CONFIG_REG_VALUE_PAIR is ARRAY(NATURAL range <>) of STD_LOGIC_VECTOR(15 downto 0);
    
    constant C_CONFIG_REG_VALUE_PAIRS : T_CONFIG_REG_VALUE_PAIR := (
        ----------------------------------------------------------
        -- ADV7511 Configuration (from ADV7511_Programming_Guide)
        ----------------------------------------------------------
    
        -------------------
        -- Power-up the Tx
        -------------------
        x"4110",
        -----------------------------------------------
        -- Fixed Registers That Must Be Set (Table 14)
        -----------------------------------------------
        x"9803", x"9AE0", x"9C30", x"9D61", x"A2A4", x"A3A4", x"E0D0",
        x"F900", -- Fixed I2C Address, this should be set to a non-conflicting I2C address (set to 0x00)
    
        ---------------------------------------
        -- Input mode (Input ID: 0 - Table 16)
        ---------------------------------------
        x"1500", -- 24 bit RGB 4:4:4 or YCbCr 4:4:4 (separate syncs)
        x"1630", -- Output Format: 4:4:4, Color Depth for Input Video Data: 8 bit, Input Style: 0, Output Color Space: RGB
        x"1700", -- VSync and HSync polarities pass through, zero order interpolation, DE Generator Disabled
        x"4800", -- Normal Video Input Bus Order, Video Input Justification: 0
        x"D03C", -- No sync pulse
        ---------------
        -- Output mode
        ---------------
        x"AF04", -- DVI mode
    
        -----------------------------------------------
        -- Conversion from Input to Output
        -- Table 55 - Identity Matrix (Input = Output)
        -----------------------------------------------
        --     A1                  A2                  A3                  A4
        x"18A8", x"1900",   x"1A00", x"1B00",   x"1C00", x"1D00",   x"1E00", x"1F00",
        --     B1                  B2                  B3                  B4
        x"2000", x"2100",   x"2208", x"2300",   x"2400", x"2500",   x"2600", x"2700",
        --     C1                  C2                  C3                  C4
        x"2800", x"2900",   x"2A00", x"2B00",   x"2C08", x"2D00",   x"2E00", x"2F00",
        
        ------------------------
        -- End of configuration
        ------------------------
        x"FFFF"
    );
    
    -----------------------------------------------------------------------------------
    
    component clock_divider
        generic (
            G_NB_BITS_CLK_DIV : INTEGER
        );
        port (
            i_clk : in STD_LOGIC;
            
            o_div_clk : out STD_LOGIC
        );
    end component;
    
    component i2c_sender
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
    end component;
    
    -----------------------------------------------------------------------------------
    
    signal div_clk    : STD_LOGIC := '1';
    signal div_clk_x2 : STD_LOGIC;
    
    -----------------------------------------------------------------------------------
    
    signal i2c_addr  : STD_LOGIC_VECTOR(6 downto 0);
    signal i2c_data  : STD_LOGIC_VECTOR(15 downto 0);
    signal i2c_start : STD_LOGIC;
    signal i2c_ready : STD_LOGIC;
    
    -----------------------------------------------------------------------------------
    
    signal config_address   : INTEGER range 0 to C_CONFIG_REG_VALUE_PAIRS'high := 0;
    signal config_reg_value : STD_LOGIC_VECTOR(15 downto 0);
    signal config_finished  : STD_LOGIC;
    
    -----------------------------------------------------------------------------------
    
    type T_CONFIG_HDMI_STATE is (
        INIT,
        MUX_CONFIG_WAIT_READY,
        MUX_CONFIG_STARTING,
        MUX_CONFIG_WAIT,
        MUX_CONFIGURATION,
        HDMI_CONFIG_WAIT_READY,
        HDMI_CONFIG_STARTING,
        HDMI_CONFIG_WAIT,
        HDMI_CONFIGURATION,
        FINISHED
    );
    
    signal config_hdmi_state : T_CONFIG_HDMI_STATE := INIT;
    
begin
    
    clock_divider_inst : clock_divider
        generic map (
            G_NB_BITS_CLK_DIV => 8
        )
        port map (
            i_clk => i_clk,
            
            o_div_clk => div_clk_x2
        );
    
    div_clk_proc : process(div_clk_x2)
    begin
        if rising_edge(div_clk_x2) then
            
            div_clk <= not(div_clk);
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    i2c_sender_inst : i2c_sender
        generic map (
            G_DATA_LENGTH => 2
        )
        port map (
            i_clk    => div_clk,
            i_clk_x2 => div_clk_x2,
            i_rst    => i_rst,
            i_addr   => i2c_addr,
            i_data   => i2c_data,
            i_start  => i2c_start,
            
            o_scl   => o_scl,
            o_sda   => o_sda,
            o_ready => i2c_ready
        );
    
    -----------------------------------------------------------------------------------
    
    config_finished <= '1' when config_reg_value = x"FFFF" else '0';
    
    -----------------------------------------------------------------------------------
    
    state_machine_proc : process(div_clk)
    begin
        if rising_edge(div_clk) then
            
            if i_rst = '1' then
                config_hdmi_state <= INIT;
            else
                case config_hdmi_state is
                    
                    -- INIT --
                    when INIT =>
                        config_hdmi_state <= MUX_CONFIG_WAIT_READY;
                    
                    -- MUX CONFIGURATION --
                    when MUX_CONFIG_WAIT_READY =>
                        if i2c_ready = '1' then
                            config_hdmi_state <= MUX_CONFIG_STARTING;
                        end if;
                    
                    when MUX_CONFIG_STARTING =>
                        config_hdmi_state <= MUX_CONFIG_WAIT;
                    
                    when MUX_CONFIG_WAIT =>
                        if i2c_ready = '0' then
                            config_hdmi_state <= MUX_CONFIGURATION;
                        end if;
                    
                    when MUX_CONFIGURATION =>
                        if i2c_ready = '1' then
                            config_hdmi_state <= HDMI_CONFIG_WAIT_READY;
                        end if;
                    
                    -- HDMI CONFIGURATION --
                    when HDMI_CONFIG_WAIT_READY =>
                        if i2c_ready = '1' then
                            config_hdmi_state <= HDMI_CONFIG_STARTING;
                        end if;
                    
                    when HDMI_CONFIG_STARTING =>
                        config_hdmi_state <= HDMI_CONFIGURATION;
                    
                    when HDMI_CONFIG_WAIT =>
                        if i2c_ready = '0' then
                            config_hdmi_state <= HDMI_CONFIGURATION;
                        end if;
                        
                    when HDMI_CONFIGURATION =>
                        if config_finished = '1' then
                            config_hdmi_state <= FINISHED;
                        elsif i2c_ready = '1' then
                            config_hdmi_state <= HDMI_CONFIG_STARTING;
                        end if;
                    
                    -- FINISHED --
                    when FINISHED =>
                        
                    
                    when others =>
                        config_hdmi_state <= INIT;
                    
                end case;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    registers_proc : process(div_clk)
    begin
        if rising_edge(div_clk) then
            
            config_reg_value <= C_CONFIG_REG_VALUE_PAIRS(config_address);
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    i2c_addr  <= C_MUX_I2C_ADDR  when config_hdmi_state = MUX_CONFIG_STARTING
            else C_HDMI_I2C_ADDR when config_hdmi_state = HDMI_CONFIG_STARTING;
    
    i2c_data  <= C_MUX_SELECTION&C_MUX_SELECTION when config_hdmi_state = MUX_CONFIG_STARTING
            else config_reg_value                when config_hdmi_state = HDMI_CONFIG_STARTING;
    
    i2c_start <= '1' when config_hdmi_state = MUX_CONFIG_STARTING
            else '1' when config_hdmi_state = HDMI_CONFIG_STARTING
            else '0';
    
    -----------------------------------------------------------------------------------
    
    increment_config_address_proc : process(div_clk)
    begin
        if rising_edge(div_clk) then
            
            if i_rst = '1' then
                config_address <= 0;
            else
                if config_hdmi_state = HDMI_CONFIG_STARTING then
                    config_address <= config_address + 1;
                end if;
            end if;
            
        end if;
    end process;
    
end Behavioral;
