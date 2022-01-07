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
        i_btn                 : in STD_LOGIC;
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
    
    component stabilize_inputs
        generic (
            G_NB_INPUTS : INTEGER
        );
        port (
            i_clk : in STD_LOGIC;
            i_in  : in STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
            
            o_out : out STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0)
        );
    end component;
    
    component flip_flop_inputs
        generic (
            G_NB_INPUTS : INTEGER
        );
        port (
            i_clk : in STD_LOGIC;
            i_rst : in STD_LOGIC;
            i_in  : in STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0);
            
            o_out : out STD_LOGIC_VECTOR(G_NB_INPUTS-1 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
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
    
    component blk_mem_gen_5
        port (
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(11 downto 0);
            dina  : in STD_LOGIC_VECTOR(15 downto 0);
            
            douta : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;
    
    component fifo_generator_1
        port (
            clk   : in STD_LOGIC;
            srst  : in STD_LOGIC;
            din   : in STD_LOGIC_VECTOR(15 downto 0);
            wr_en : in STD_LOGIC;
            rd_en : in STD_LOGIC;
            
            dout       : out STD_LOGIC_VECTOR(15 downto 0);
            full       : out STD_LOGIC;
            empty      : out STD_LOGIC;
            valid      : out STD_LOGIC;
            data_count : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    -- Stabilized inputs
    signal buff_btn : STD_LOGIC;
    
    -- Pause system
    signal pause : STD_LOGIC;
    
    -----------------------------------------------------------------------------------
    
    type T_PHASESTATE_FSM is (
        INIT_PHASE,
        CONF_PHASE,
        EXEC_PHASE,
        EXEC_WRITE,
        DIST_PHASE,
        DIST_READ,
        DIST_PAUSE
    );
    
    signal phase_state : T_PHASESTATE_FSM := INIT_PHASE;
    
    -----------------------------------------------------------------------------------
    
    -- BRAM
    signal spikes_mem_en   : STD_LOGIC :=  '0';
    signal spikes_mem_addr : STD_LOGIC_VECTOR(10 downto 0) := (others => '0');
    signal spikes_mem_dout : STD_LOGIC_VECTOR(17 downto 0);
    
    -- FIFO
    signal spikes_fifo_wr_en : STD_LOGIC :=  '0';
    signal spikes_fifo_din   : STD_LOGIC_VECTOR(17 downto 0);
    signal spikes_fifo_rd_en : STD_LOGIC :=  '0';
    signal spikes_fifo_empty : STD_LOGIC;
    signal spikes_fifo_valid : STD_LOGIC;
    signal spikes_fifo_dout  : STD_LOGIC_VECTOR(17 downto 0);
    
    -----------------------------------------------------------------------------------
    
    -- BRAM
    signal analog_mem_en   : STD_LOGIC :=  '0';
    signal analog_mem_addr : STD_LOGIC_VECTOR(11 downto 0) := (others => '0');
    signal analog_mem_dout : STD_LOGIC_VECTOR(15 downto 0);
    
    -- FIFO
    signal analog_fifo_wr_en : STD_LOGIC :=  '0';
    signal analog_fifo_din   : STD_LOGIC_VECTOR(15 downto 0);
    signal analog_fifo_rd_en : STD_LOGIC :=  '0';
    signal analog_fifo_empty : STD_LOGIC;
    signal analog_fifo_valid : STD_LOGIC;
    signal analog_fifo_dout  : STD_LOGIC_VECTOR(15 downto 0);
    
    -----------------------------------------------------------------------------------
    
    -- OTHERS
    signal count        : STD_LOGIC_VECTOR(11 downto 0);
    signal period_count : STD_LOGIC_VECTOR(23 downto 0);
    
    function maximum(
        val1 : INTEGER;
        val2 : INTEGER
    ) return INTEGER is
        
        begin
            if val1 > val2 then
                return val1;
            else
                return val2;
            end if;
            
    end function;
    
begin
    
    -- Phase States
    o_ph_init <= '1' when phase_state = INIT_PHASE else '0';
    o_ph_conf <= '1' when phase_state = CONF_PHASE else '0';
    o_ph_exec <= '1' when phase_state = EXEC_PHASE or phase_state = EXEC_WRITE else '0';
    o_ph_dist <= '1' when phase_state = DIST_PHASE or phase_state = DIST_READ or phase_state = DIST_PAUSE else '0';
    
    -- FIFO signals
    o_spikes_fifo_empty <= spikes_fifo_empty;
    o_spikes_fifo_valid <= spikes_fifo_valid;
    o_spikes_fifo_dout  <= (31 downto 18 => '1') & spikes_fifo_dout;
    
    o_analog_fifo_empty <= analog_fifo_empty;
    o_analog_fifo_valid <= analog_fifo_valid;
    o_analog_fifo_dout  <= analog_fifo_dout;
    
--  ===================================================================================
--  ----------------------------------- Button Input ----------------------------------
--  ===================================================================================
    
    stabilize_inputs_inst : stabilize_inputs
        generic map (
            G_NB_INPUTS => 1
        )
        port map (
            i_clk   => i_clk,
            i_in(0) => i_btn,
            
            o_out(0) => buff_btn
        );
    
    flip_flop_inputs_inst : flip_flop_inputs
        generic map (
            G_NB_INPUTS => 1
        )
        port map (
            i_clk   => i_clk,
            i_rst   => i_rst,
            i_in(0) => buff_btn,
            
            o_out(0) => pause
        );
    
    -----------------------------------------------------------------------------------
    
    example_spikes : blk_mem_gen_4 
        port map (
            clka   => i_clk,
            ena    => spikes_mem_en,
            wea(0) => '0',
            addra  => spikes_mem_addr,
            dina   => (others => '0'),
            
            douta => spikes_mem_dout
        );
    
    spikes_fifo : fifo_generator_0
        port map (
            clk   => i_clk,
            srst  => i_rst,
            din   => spikes_fifo_din,
            wr_en => spikes_fifo_wr_en,
            rd_en => spikes_fifo_rd_en,
            
            dout       => spikes_fifo_dout,
            full       => open,
            empty      => spikes_fifo_empty,
            valid      => spikes_fifo_valid,
            data_count => open
        );
    
    -----------------------------------------------------------------------------------
    
    example_analog_values : blk_mem_gen_5 
        port map (
            clka   => i_clk,
            ena    => analog_mem_en,
            wea(0) => '0',
            addra  => analog_mem_addr,
            dina   => (others => '0'),
            
            douta => analog_mem_dout
        );
    
    analog_fifo : fifo_generator_1
        port map (
            clk   => i_clk,
            srst  => i_rst,
            din   => analog_fifo_din,
            wr_en => analog_fifo_wr_en,
            rd_en => analog_fifo_rd_en,
            
            dout       => analog_fifo_dout,
            full       => open,
            empty      => analog_fifo_empty,
            valid      => analog_fifo_valid,
            data_count => open
        );
    
    -----------------------------------------------------------------------------------
    
    phase_state_fsm : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_rst = '1' then
                spikes_fifo_wr_en <= '0';
                spikes_fifo_rd_en <= '0';
                spikes_mem_en     <= '0';
                spikes_mem_addr   <= (others => '0');
                analog_fifo_wr_en <= '0';
                analog_fifo_rd_en <= '0';
                analog_mem_en     <= '0';
                analog_mem_addr   <= (others => '0');
                phase_state       <= INIT_PHASE;
            
            else
                case phase_state is
                    
                    when INIT_PHASE =>
                        spikes_fifo_wr_en <= '0';
                        spikes_fifo_rd_en <= '0';
                        spikes_mem_en     <= '0';
                        analog_fifo_wr_en <= '0';
                        analog_fifo_rd_en <= '0';
                        analog_mem_en     <= '0';
                        count             <= (others => '0');
                        period_count      <= (others => '0');
                        phase_state       <= CONF_PHASE;
                    
                    when CONF_PHASE =>
                        count        <= (others => '0');
                        period_count <= (others => '0');
                        phase_state  <= EXEC_PHASE;
                    
                    when EXEC_PHASE =>
                        period_count <= period_count + 1;
                        if count < maximum(G_DATA_SIZE, 4) + 1 then 
                            if count < G_DATA_SIZE + 1 then
                                spikes_mem_en     <= '1';
                                spikes_fifo_wr_en <= '0';
                            else
                                spikes_mem_en     <= '0';
                                spikes_fifo_wr_en <= '0';
                            end if;
                            if count < 4 + 1 then
                                analog_mem_en     <= '1';
                                analog_fifo_wr_en <= '0';
                            else
                                analog_mem_en     <= '0';
                                analog_fifo_wr_en <= '0';
                            end if;
                            phase_state <= EXEC_WRITE;
                        else
                            spikes_mem_en     <= '0';
                            spikes_fifo_wr_en <= '0';
                            analog_mem_en     <= '0';
                            analog_fifo_wr_en <= '0';
                            phase_state       <= DIST_PHASE;
                        end if;
                    
                    when EXEC_WRITE =>
                        period_count <= period_count + 1;
                        if count > 0 and count < G_DATA_SIZE + 1 then
                            spikes_fifo_din   <= spikes_mem_dout;
                            spikes_fifo_wr_en <= '1';
                        end if;
                        if count > 0 and count < 4 + 1 then
                            analog_fifo_din   <= analog_mem_dout;
                            analog_fifo_wr_en <= '1';
                        end if;
                        if count < G_DATA_SIZE then
                            spikes_mem_addr <= spikes_mem_addr + 1;
                        end if;
                        if count < 4 then
                            analog_mem_addr <= analog_mem_addr + 1;
                        end if;
                        count       <= count + 1;
                        phase_state <= EXEC_PHASE;
                    
                    when DIST_PHASE =>
                        period_count <= period_count + 1;
                        if spikes_fifo_empty = '0' and i_spikes_hdmi_rd_fifo = '1' then
                            spikes_fifo_rd_en <= '1';
                            phase_state       <= DIST_READ;
                        end if;
                        if analog_fifo_empty = '0' and i_analog_hdmi_rd_fifo = '1' then
                            analog_fifo_rd_en <= '1';
                            phase_state       <= DIST_READ;
                        end if;
                        if period_count = G_PERIOD then
                            count        <= (others => '0');
                            period_count <= (others => '0');
                            if pause = '0' then
                                phase_state <= EXEC_PHASE;
                            else
                                phase_state <= DIST_PAUSE;
                            end if;
                        end if;
                    
                    when DIST_READ =>
                        period_count      <= period_count + 1;
                        spikes_fifo_rd_en <= '0';
                        analog_fifo_rd_en <= '0';
                        phase_state       <= DIST_PHASE;
                    
                    when DIST_PAUSE =>
                        if pause = '0' then
                            phase_state <= EXEC_PHASE;
                        end if;
                    
                    when others =>
                        phase_state <= INIT_PHASE;
                    
                end case;
            end if;
            
        end if;
    end process;
    
end Behavioral;
