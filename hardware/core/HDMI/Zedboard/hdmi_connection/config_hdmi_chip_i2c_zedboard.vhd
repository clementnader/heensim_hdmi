----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/26/2021 11:15:30 PM
-- Design Name: 
-- Module Name: config_hdmi_chip_i2c_zedboard - Behavioral
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


entity config_hdmi_chip_i2c_zedboard is
    port (
        i_clk : in STD_LOGIC;
        i_rst : in STD_LOGIC;
        
        o_scl : out STD_LOGIC;
        o_sda : out STD_LOGIC
    );
end config_hdmi_chip_i2c_zedboard;


architecture Behavioral of config_hdmi_chip_i2c_zedboard is
    
    constant C_HDMI_I2C_ADDR : STD_LOGIC_VECTOR(6 downto 0) := b"0111_001";
    
    -----------------------------------------------------------------------------------
    
    type T_CONFIG_REG_VALUE_PAIR is ARRAY(NATURAL range <>) of STD_LOGIC_VECTOR(15 downto 0);
    
    constant C_CONFIG_REG_VALUE_PAIRS : T_CONFIG_REG_VALUE_PAIR := (
        ----------------------------------------------------------
        -- ADV7511 Configuration (from ADV7511_Programming_Guide)
        ----------------------------------------------------------
        
        -----------------------------------------------
        -- Fixed Registers That Must Be Set (Table 14)
        -----------------------------------------------
        x"9803", x"9AE0", x"9C30", x"9D61", x"A2A4", x"A3A4", x"E0D0",
        x"F900", -- Fixed I2C Address, this should be set to a non-conflicting I2C address (set to 0x00)
        
        -----------------
        -- Main Power Up
        -----------------
        x"4110",
        
        ---------------------------------------
        -- Input mode (Input ID: 1 - Table 18)
        ---------------------------------------
        x"1501", -- Input ID: 1 -> 16, 20, 24 bit YCbCr 4:2:2 (separate syncs)
        x"163C", -- Output Format: 4:4:4, Color Depth for Input Video Data: 8 bit, Input Style: 3
        x"1700", -- VSync and HSync polarities pass through, 4:2:2 to 4:4:4 Up Conversion Method: zero order interpolation
        x"4808", -- Normal Video Input Bus Order, Video Input Justification: right justified
--        x"D03C", -- No sync pulse
        
        ---------------
        -- Output mode
        ---------------
        x"AF04", -- DVI mode
        
        -------------------------------------------------------------
        -- Conversion from Input to Output
        -- Table 40 - HDTV YCbCr (Limited Range) to RGB (Full Range)
        -------------------------------------------------------------
        --     A1                  A2                  A3                  A4
        x"18E7", x"1934",   x"1A04", x"1BAD",   x"1C00", x"1D00",   x"1E1C", x"1F1B",
        --     B1                  B2                  B3                  B4
        x"201D", x"21DC",   x"2204", x"23AD",   x"241F", x"2524",   x"2601", x"2735",
        --     C1                  C2                  C3                  C4
        x"2800", x"2900",   x"2A04", x"2BAD",   x"2C08", x"2D7C",   x"2E1B", x"2F77"
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
    
    -----------------------------------------------------------------------------------
    
    type T_CONFIG_HDMI_STATE is (
        INIT,
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
    
    state_machine_proc : process(div_clk)
    begin
        if rising_edge(div_clk) then
            
            if i_rst = '1' then
                config_hdmi_state <= INIT;
            else
                case config_hdmi_state is
                    
                    -- INIT --
                    when INIT =>
                        if i2c_ready = '1' then
                            config_hdmi_state <= HDMI_CONFIG_STARTING;
                        end if;
                    
                    -- HDMI CONFIGURATION --
                    when HDMI_CONFIG_STARTING =>
                        config_hdmi_state <= HDMI_CONFIG_WAIT;
                    
                    when HDMI_CONFIG_WAIT =>
                        if i2c_ready = '0' then
                            config_hdmi_state <= HDMI_CONFIGURATION;
                        end if;
                    
                    when HDMI_CONFIGURATION =>
                        if i2c_ready = '1' then
                            if config_address = C_CONFIG_REG_VALUE_PAIRS'high then
                                config_hdmi_state <= FINISHED;
                            else
                                config_hdmi_state <= HDMI_CONFIG_STARTING;
                            end if;
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
    
    i2c_addr  <= C_HDMI_I2C_ADDR when config_hdmi_state = HDMI_CONFIG_WAIT or config_hdmi_state = HDMI_CONFIGURATION
            else (others => '0');
    
    i2c_data  <= config_reg_value when config_hdmi_state = HDMI_CONFIG_WAIT or config_hdmi_state = HDMI_CONFIGURATION
            else (others => '0');
    
    i2c_start <= '1' when config_hdmi_state = HDMI_CONFIG_STARTING
            else '0';
    
    -----------------------------------------------------------------------------------
    
    increment_config_address_proc : process(div_clk)
    begin
        if rising_edge(div_clk) then
            
            if i_rst = '1' then
                config_address <= 0;
            else
                if config_hdmi_state = HDMI_CONFIGURATION and i2c_ready = '1' and config_address < C_CONFIG_REG_VALUE_PAIRS'high then
                    config_address <= config_address + 1;
                end if;
            end if;
            
        end if;
    end process;
    
end Behavioral;
