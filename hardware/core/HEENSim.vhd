----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/06/2021 10:53:02 PM
-- Design Name: 
-- Module Name: HEENSim - Behavioral
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


entity HEENSim is
    generic (
        G_DATA_SIZE : INTEGER;
        G_PERIOD    : INTEGER
    );
    port (
        i_clk                 : in STD_LOGIC;
        i_rst                 : in STD_LOGIC;
        i_spikes_hdmi_rd_fifo : in STD_LOGIC;
        i_analog_hdmi_rd_fifo : in STD_LOGIC;
        
        o_spikes_fifo_dout  : out STD_LOGIC_VECTOR(31 downto 0);
        o_spikes_fifo_empty : out STD_LOGIC;
        o_spikes_fifo_valid : out STD_LOGIC;
        o_analog_fifo_dout  : out STD_LOGIC_VECTOR(15 downto 0);
        o_analog_fifo_empty : out STD_LOGIC;
        o_analog_fifo_valid : out STD_LOGIC;
        o_ph_init           : out STD_LOGIC;
        o_ph_conf           : out STD_LOGIC;
        o_ph_exec           : out STD_LOGIC;
        o_ph_dist           : out STD_LOGIC
    );
end HEENSim;

architecture Behavioral of HEENSim is

    component blk_mem_gen_4
        port (
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(10 downto 0);
            dina  : in STD_LOGIC_VECTOR(17 downto 0);
            
            douta : out STD_LOGIC_VECTOR(17 downto 0)
        );
    end component;
    
    component fifo_generator_0
        port (
            clk   : in STD_LOGIC;
            srst  : in STD_LOGIC;
            din   : in STD_LOGIC_VECTOR(17 downto 0);
            wr_en : in STD_LOGIC;
            rd_en : in STD_LOGIC;
            
            dout       : out STD_LOGIC_VECTOR(17 downto 0);
            full       : out STD_LOGIC;
            empty      : out STD_LOGIC;
            valid      : out STD_LOGIC;
            data_count : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    type T_PHASESTATE_FSM is (
        INIT_PHASE,
        CONF_PHASE,
        EXEC_PHASE,
        EXEC_WRITE,
        DIST_PHASE,
        DIST_READ
    );
    
    signal phase_state : T_PHASESTATE_FSM := INIT_PHASE;
    
    -- BRAM
    signal mem_en   : STD_LOGIC :=  '0';
    signal mem_addr : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal mem_dout : STD_LOGIC_VECTOR(17 downto 0);
    
    -- FIFO
    signal fifo_wr_en : STD_LOGIC :=  '0';
    signal fifo_din   : STD_LOGIC_VECTOR(17 downto 0);
    signal fifo_rd_en : STD_LOGIC :=  '0';
    signal fifo_empty : STD_LOGIC;
    signal fifo_valid : STD_LOGIC;
    signal fifo_dout  : STD_LOGIC_VECTOR(17 downto 0);
    
    -- OTHERS
    signal count        : STD_LOGIC_VECTOR(11 downto 0);
    signal period_count : STD_LOGIC_VECTOR(23 downto 0);

begin
    
    -- Phase States
    o_ph_init <= '1' when phase_state = INIT_PHASE else '0';
    o_ph_conf <= '1' when phase_state = CONF_PHASE else '0';
    o_ph_exec <= '1' when phase_state = EXEC_PHASE or phase_state = EXEC_WRITE else '0';
    o_ph_dist <= '1' when phase_state = DIST_PHASE or phase_state = DIST_READ  else '0';
    
    -- FIFO signals
    o_spikes_fifo_empty <= fifo_empty;
    o_spikes_fifo_valid <= fifo_valid;
    o_spikes_fifo_dout  <= (31 downto 18 => '1') & fifo_dout;
    
    -----------------------------------------------------------------------------------
    
    blk_mem_gen_4_inst : blk_mem_gen_4 
        port map (
            clka   => i_clk,
            ena    => mem_en,
            wea(0) => '0',
            addra  => mem_addr,
            dina   => (others => '0'),
            
            douta => mem_dout
        );
    
    fifo_generator_0_inst : fifo_generator_0
        port map (
            clk   => i_clk,
            srst  => i_rst,
            din   => fifo_din,
            wr_en => fifo_wr_en,
            rd_en => fifo_rd_en,
            
            dout       => fifo_dout,
            full       => open,
            empty      => fifo_empty,
            valid      => fifo_valid,
            data_count => open
        );
    
    -----------------------------------------------------------------------------------
    
    phase_state_fsm : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_rst = '1' then
                fifo_wr_en   <= '0';
                fifo_rd_en   <= '0';
                mem_en       <= '0';
                mem_addr     <= (others => '0');
                phase_state  <= INIT_PHASE;
            
            else
                case phase_state is
                    
                    when INIT_PHASE =>
                        fifo_wr_en   <= '0';
                        fifo_rd_en   <= '0';
                        mem_en       <= '0';
                        count        <= (others => '0');
                        period_count <= (others => '0');
                        phase_state  <= CONF_PHASE;
                    
                    when CONF_PHASE =>
                        count        <= (others => '0');
                        period_count <= (others => '0');
                        phase_state  <= EXEC_PHASE;
                    
                    when EXEC_PHASE =>
                        period_count <= period_count + 1;
                        if count < G_DATA_SIZE + 1 then
                            mem_en      <= '1';
                            fifo_wr_en  <= '0';
                            phase_state <= EXEC_WRITE;
                        else
                            fifo_wr_en  <= '0';
                            mem_en      <= '0';
                            phase_state <= DIST_PHASE;
                        end if;
                    
                    when EXEC_WRITE =>
                        period_count <= period_count + 1;
                        if count > 0 then
                            fifo_din   <= mem_dout;
                            fifo_wr_en <= '1';
                        end if;
                        if count < G_DATA_SIZE then
                            mem_addr <= mem_addr + 1;
                        end if;
                        count       <= count + 1;
                        phase_state <= EXEC_PHASE;
                    
                    when DIST_PHASE =>
                        period_count <= period_count + 1;
                        if fifo_empty = '0' and i_spikes_hdmi_rd_fifo = '1' then
                            fifo_rd_en  <= '1';
                            phase_state <= DIST_READ;
                        elsif fifo_empty = '1' and period_count = G_PERIOD then
                            count        <= (others => '0');
                            period_count <= (others => '0');
                            phase_state  <= EXEC_PHASE;
                        end if;
                    
                    when DIST_READ =>
                        period_count <= period_count + 1;
                        fifo_rd_en  <= '0';
                        phase_state <= DIST_PHASE;
                    
                    when others =>
                        phase_state <= INIT_PHASE;
                    
                end case;
            end if;
            
        end if;
    end process;
    
end Behavioral;
