----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/19/2021 05:59:20 PM
-- Design Name: 
-- Module Name: read_fifo_analog - Behavioral
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

library work;
    use work.neurons_pkg.ALL;


entity read_fifo_analog is
    port (
        i_clk               : in STD_LOGIC;
        i_rst               : in STD_LOGIC;
        i_ph_dist           : in STD_LOGIC;
        i_current_timestamp : in STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0);
        i_fifo_empty        : in STD_LOGIC;
        i_fifo_valid        : in STD_LOGIC;
        i_fifo_dout         : in STD_LOGIC_VECTOR(C_ANALOG_VALUE_SIZE-1 downto 0);
        i_end_screen        : in STD_LOGIC;
        
        o_hdmi_rd_fifo  : out STD_LOGIC;
        o_mem_wr_en     : out STD_LOGIC;
        o_mem_wr_we     : out STD_LOGIC;
        o_mem_wr_addr   : out STD_LOGIC_VECTOR(9 downto 0);
        o_mem_wr_din    : out STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
        o_transfer_done : out STD_LOGIC                                  
    );
end read_fifo_analog;

architecture Behavioral of read_fifo_analog is
    
    component blk_mem_gen_3
        port (
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(4 downto 0);
            dina  : in STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
            
            douta : out STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0)
        );
    end component;
    
    -----------------------------------------------------------------------------------
    
    type T_FIFO_RD_STATE is (
        IDLE,
        FIFO_READ,
        ANALOG_VALUE_CALC,
        MEM_WRITE,
        FIFO_EMPTY,
        WAIT_BEFORE_TRANSFER,
        TRANSFER_WRITE
    );
    
    signal fifo_rd_state : T_FIFO_RD_STATE := IDLE;
    
    -----------------------------------------------------------------------------------
    
    signal analog_value         : SIGNED(C_ANALOG_VALUE_SIZE-1 downto 0);
    signal potential_plot_value : STD_LOGIC_VECTOR(C_POTENTIAL_PLOT_VALUE_SIZE-1 downto 0);
    
    signal neuron_cnt : STD_LOGIC_VECTOR(C_CNT_NEURONS_SIZE-1 downto 0);
    
    signal buffer_en   : STD_LOGIC;
    signal buffer_we   : STD_LOGIC;
    signal buffer_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal buffer_din  : STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
    signal buffer_dout : STD_LOGIC_VECTOR(C_ANALOG_MEM_SIZE-1 downto 0);
    
    -----------------------------------------------------------------------------------
    
    -- Counter to know how many values are in the buffer and then need to be transfer to the memory
    signal buffer_cnt : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    
    -- Signal to find rising edge of the end_screen signal
    signal last_end_screen : STD_LOGIC;
    
    -- Flag to tell we have to transfer from the buffer to the memory
    signal transfer_from_buffer : STD_LOGIC;
    
    -- Address in the memory to be written
    signal transfer_addr : STD_LOGIC_VECTOR(9 downto 0);
    
    -- Signal to delay the read of the buffer
    signal transfer_rd_delay : STD_LOGIC;
    
begin
    
    analog_buffer_inst : blk_mem_gen_3
        port map (
            clka   => i_clk,
            ena    => buffer_en,
            wea(0) => buffer_we,
            addra  => buffer_addr,
            dina   => buffer_din,
            
            douta => buffer_dout
        );
    
    -----------------------------------------------------------------------------------
    
    fifo_reading_fsm_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_rst = '1' then
                fifo_rd_state <= IDLE;
            else
                case fifo_rd_state is
                    
                    -- Idle
                    when IDLE =>
                        if i_ph_dist = '1' then
                            if i_fifo_empty = '0' then
                                fifo_rd_state <= FIFO_READ;
                            else
                                fifo_rd_state <= FIFO_EMPTY;
                            end if;
                        end if;
                    
                    -- Distribution phase: read the FIFO and store the spikes in the buffer
                    when FIFO_READ =>
                        if i_fifo_valid = '1' then
                            fifo_rd_state <= ANALOG_VALUE_CALC;
                        end if;
                    
                    when ANALOG_VALUE_CALC =>
                        fifo_rd_state <= MEM_WRITE;
                    
                    when MEM_WRITE =>
                        if i_fifo_empty = '0' then
                            fifo_rd_state <= FIFO_READ;
                        else
                            fifo_rd_state <= FIFO_EMPTY;
                        end if;
                    
                    when FIFO_EMPTY =>
                        if i_fifo_empty = '0' then
                            fifo_rd_state <= FIFO_READ;
                        elsif transfer_from_buffer = '1' then
                            fifo_rd_state <= WAIT_BEFORE_TRANSFER;
                        elsif i_ph_dist = '0' then
                            fifo_rd_state <= IDLE;
                        end if;
                    
                    -- Transfer buffer into the memory
                    when WAIT_BEFORE_TRANSFER =>
                        if transfer_rd_delay = '1' then
                            fifo_rd_state <= TRANSFER_WRITE;
                        end if;
                    
                    when TRANSFER_WRITE =>
                        if buffer_addr = buffer_cnt + 1 then
                            fifo_rd_state <= FIFO_EMPTY;
                        end if;
                    
                    when others =>
                        fifo_rd_state <= IDLE;
                    
                end case;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    o_hdmi_rd_fifo <= '1' when fifo_rd_state = FIFO_READ and i_fifo_valid = '0'
                 else '0';
    
    -----------------------------------------------------------------------------------
    
    transfer_flag_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
        
            last_end_screen <= i_end_screen;
            
            if i_rst = '1' then
                transfer_from_buffer <= '0';
            else
                if fifo_rd_state = WAIT_BEFORE_TRANSFER then
                    transfer_from_buffer <= '0';
                end if;
                if last_end_screen = '0' and i_end_screen = '1' then  -- rising edge
                    transfer_from_buffer <= '1';
                end if;
            end if;
        
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    compute_id_value_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if (fifo_rd_state = FIFO_READ and i_fifo_valid = '1') then
                analog_value <= signed(i_fifo_dout);
            end if;
            if fifo_rd_state = ANALOG_VALUE_CALC then
                potential_plot_value <= transform_analog_value(analog_value);
            end if;
            
        end if;
    end process;
    
    count_neuron_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if (fifo_rd_state = IDLE and i_ph_dist = '1') then
                neuron_cnt <= (others => '0');
            end if;
            if fifo_rd_state = MEM_WRITE then
                neuron_cnt <= neuron_cnt + 1;
            end if;
            
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    -- Write and read signals for the buffer
    buffer_en <= '1' when (fifo_rd_state = FIFO_READ and i_fifo_valid = '1')
                       or fifo_rd_state = ANALOG_VALUE_CALC
                       or fifo_rd_state = MEM_WRITE
                       
                       or fifo_rd_state = WAIT_BEFORE_TRANSFER
                       or fifo_rd_state = TRANSFER_WRITE
            else '0';
    
    buffer_we <= '1' when fifo_rd_state = MEM_WRITE
            else '0';
    
    buffer_din  <= neuron_cnt & potential_plot_value when fifo_rd_state = MEM_WRITE
              else (others => '0');
    
    -- Write signals for the memory (when we transfer the buffer into it)
    o_mem_wr_en   <= '1'           when fifo_rd_state = TRANSFER_WRITE else '0';
    o_mem_wr_we   <= '1'           when fifo_rd_state = TRANSFER_WRITE else '0';
    o_mem_wr_addr <= transfer_addr when fifo_rd_state = TRANSFER_WRITE else (others => '0');
    o_mem_wr_din  <= buffer_dout   when fifo_rd_state = TRANSFER_WRITE else (others => '0');
    
    -----------------------------------------------------------------------------------
    
    memory_addresses_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
        
            case fifo_rd_state is
                
                when IDLE =>
                    if i_ph_dist = '1' then
                        buffer_addr <= buffer_cnt;
                        buffer_cnt  <= buffer_cnt + 1;
                    end if;
                
                when FIFO_EMPTY =>
                    if transfer_from_buffer = '1' then
                        buffer_addr   <= (others => '0');
                        transfer_addr <= i_current_timestamp(transfer_addr'high downto 0) - (buffer_cnt-1);
                    end if;
                
                when WAIT_BEFORE_TRANSFER =>
                    buffer_addr <= buffer_addr + 1;
                
                when TRANSFER_WRITE =>
                    buffer_addr   <= buffer_addr + 1;
                    transfer_addr <= transfer_addr + 1;
                    
                    if buffer_addr = buffer_cnt + 1 then
                        buffer_cnt <= (others => '0');
                    end if;
                
                when others =>
                
            end case;
        
        end if;
    end process;
    
    -----------------------------------------------------------------------------------
    
    wait_before_transfer_proc : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if fifo_rd_state = FIFO_EMPTY then
                transfer_rd_delay <= '0';
            end if;
            if fifo_rd_state = WAIT_BEFORE_TRANSFER then
                transfer_rd_delay <= not(transfer_rd_delay);
            end if;
            
        end if;
    end process;
    
end Behavioral;
