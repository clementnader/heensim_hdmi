----------------------------------------------------------------------------------
-- Engineer:    Mike Field <hamster@snap.net.nz>
-- 
-- Module Name:    hdmi_ddr_output - Behavioral 
--
-- Description: DDR inferface to the ADV7511 HDMI transmitter
--
-- Feel free to use this how you see fit, and fix any errors you find :-)
----------------------------------------------------------------------------------

library IEEE;
    use IEEE.STD_LOGIC_1164.ALL;

library UNISIM;
    use UNISIM.VComponents.ALL;


entity hdmi_ddr_output is
    port (
        i_clk   : in STD_LOGIC;
        i_clk90 : in STD_LOGIC;
        i_rst   : in STD_LOGIC;
        i_y     : in STD_LOGIC_VECTOR(7 downto 0);
        i_c     : in STD_LOGIC_VECTOR(7 downto 0);
        i_de    : in STD_LOGIC;
        i_hsync : in STD_LOGIC;
        i_vsync : in STD_LOGIC;
        
        o_hdmi_clk   : out STD_LOGIC;
        o_hdmi_d     : out STD_LOGIC_VECTOR(15 downto 0);
        o_hdmi_de    : out STD_LOGIC;
        o_hdmi_hsync : out STD_LOGIC;
        o_hdmi_vsync : out STD_LOGIC;
        o_hdmi_scl   : out STD_LOGIC;
        o_hdmi_sda   : out STD_LOGIC
    );
end hdmi_ddr_output;


architecture Behavioral of hdmi_ddr_output is
    
    component i2c_sender
        port (
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            
            o_sioc : out STD_LOGIC;
            o_siod : out STD_LOGIC
        );
    end component;
    
begin
    
    clk_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            o_hdmi_vsync <= i_vsync;
            o_hdmi_hsync <= i_hsync;
            
        end if;
    end process;
    
    ODDR_inst_hdmi_clk : ODDR
    generic map (
        DDR_CLK_EDGE => "SAME_EDGE",
        INIT         => '0',
        SRTYPE       => "SYNC"
    )
    port map (
        C  => i_clk90,
        Q  => o_hdmi_clk,
        D1 => '1',
        D2 => '0',
        CE => '1',
        R  => '0',
        S  => '0'
    );
    
    ODDR_inst_hdmi_de : ODDR
    generic map (
        DDR_CLK_EDGE => "SAME_EDGE",
        INIT         => '0',
        SRTYPE       => "SYNC"
    ) 
    port map (
        C  => i_clk,
        Q  => o_hdmi_de,
        D1 => i_de,
        D2 => i_de,
        CE => '1',
        R  => '0',
        S  => '0'
    );
    
    ODDR_gen_hdmi_d : for i in 0 to 7 generate
    begin
        ODDR_inst_hdmi_d : ODDR
        generic map (
            DDR_CLK_EDGE => "SAME_EDGE",
            INIT         => '0',
            SRTYPE       => "SYNC"
        )
        port map (
            C  => i_clk,
            Q  => o_hdmi_d(8+i),
            D1 => i_y(i),
            D2 => i_c(i),
            CE => '1',
            R  => '0',
            S  => '0'
        );
    end generate;
    
    o_hdmi_d(7 downto 0) <= "00000000";
    
    -----------------------------------------------------------------------   
    -- This sends the configuration register values to the HDMI transmitter
    -----------------------------------------------------------------------   
    i2c_sender_inst : i2c_sender
    port map (
        i_clk => i_clk,
        i_rst => i_rst,
        
        o_sioc => o_hdmi_scl,
        o_siod => o_hdmi_sda
    );
    
end Behavioral;
