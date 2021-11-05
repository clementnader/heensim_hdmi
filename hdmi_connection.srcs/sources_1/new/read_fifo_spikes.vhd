----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/08/2021 10:50:17 AM
-- Design Name: 
-- Module Name: read_fifo_spikes - Behavioral
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
    use work.events_list.ALL;


entity read_fifo_spikes is
    port (
        i_clk           : in STD_LOGIC;
        i_rst           : in STD_LOGIC;
        i_freeze_screen : in STD_LOGIC;
        i_ph_dist       : in STD_LOGIC;
        i_empty         : in STD_LOGIC;
        i_valid         : in STD_LOGIC;
        i_fifo_dout     : in STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
        i_end_screen    : in STD_LOGIC;
        
        o_fifo_rd_en  : out STD_LOGIC := '0';
        o_mem_wr_en   : out STD_LOGIC := '0';
        o_mem_wr_we   : out STD_LOGIC := '0';
        o_mem_wr_addr : out STD_LOGIC_VECTOR(9 downto 0);
        o_mem_wr_din  : out STD_LOGIC_VECTOR(C_MAX_ID downto 0)
    );
end read_fifo_spikes;


architecture Behavioral of read_fifo_spikes is
    
    component blk_mem_gen_2
        port (
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(4 downto 0);
            dina  : in STD_LOGIC_VECTOR(C_MAX_ID downto 0);
            
            douta : out STD_LOGIC_VECTOR(C_MAX_ID downto 0)
        );
    end component;
    
    constant C_BLANK_MEMORY : STD_LOGIC_VECTOR(C_MAX_ID downto 0) := (others => '0');
    
    function convert_neuron_id(
        id_value   : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
        old_memory : STD_LOGIC_VECTOR(C_MAX_ID downto 0)
    ) return STD_LOGIC_VECTOR is
            variable new_memory   : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
        begin
            new_memory := old_memory;
            new_memory(to_integer(unsigned(id_value))) := '1';
            return new_memory;
    end function;
    
    type T_STATE is (
        IDLE,
        EMPTY_MEM,
        FIFO_READ,
        WAIT_BEFORE_CHECK_VALID,
        CHECK_VALID,
        WAIT_BEFORE_MEM_READ,
        MEM_WRITE,
        FIFO_EMPTY,
        WAIT_BEFORE_TRANSFER_READ,
        TRANSFER_WRITE
    );
    
    signal state      : T_STATE := IDLE;
    signal current_ts : STD_LOGIC_VECTOR(C_LENGTH_TIMESTAMP-1 downto 0) := (others => '0');
    signal neuron_id  : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
    signal id_value   : STD_LOGIC_VECTOR(C_LENGTH_NEURON_ID-1 downto 0);
    
    signal buffer_en   : STD_LOGIC := '0';
    signal buffer_we   : STD_LOGIC := '0';
    signal buffer_addr : STD_LOGIC_VECTOR(4 downto 0);
    signal buffer_din  : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
    signal buffer_dout : STD_LOGIC_VECTOR(C_MAX_ID downto 0);
    
    signal buffer_cnt : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    
    signal transfer_from_buffer : STD_LOGIC := '0';
    signal transfer_addr        : STD_LOGIC_VECTOR(9 downto 0);
    signal transfer_rd_delay    : STD_LOGIC;
    
    signal last_end_screen : STD_LOGIC;
    
begin
    
    blk_mem_gen_2_inst : blk_mem_gen_2
    port map (
        clka   => i_clk,
        ena    => buffer_en,
        wea(0) => buffer_we,
        addra  => buffer_addr,
        dina   => buffer_din,
        
        douta => buffer_dout
    );
    
    reading_process : process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            last_end_screen <= i_end_screen;
            if last_end_screen = '0' and i_end_screen = '1' then  -- rising edge
                transfer_from_buffer <= '1';
            end if;
            
            if i_rst = '1' or i_freeze_screen = '1' then
                o_fifo_rd_en         <= '0';
                o_mem_wr_en          <= '0';
                o_mem_wr_we          <= '0';
                buffer_en            <= '0';
                buffer_we            <= '0';
                buffer_cnt           <= (others => '0');
                transfer_from_buffer <= '0';
                current_ts           <= (others => '0');
                state <= IDLE;
                
            else
                case state is
                    
                    when IDLE =>
                        if i_ph_dist = '1' then  -- a new distribution phase
                            state <= EMPTY_MEM;
                        end if;
                    
                    when EMPTY_MEM =>
                        buffer_en   <= '1';
                        buffer_we   <= '1';
                        buffer_addr <= buffer_cnt;
                        buffer_din  <= C_BLANK_MEMORY;
                        buffer_cnt  <= buffer_cnt + 1;
                        if i_empty = '0' then
                            state <= FIFO_READ;  -- try to read from the FIFO
                        else
                            state <= FIFO_EMPTY;
                        end if;
                    
                    when FIFO_READ =>
                        buffer_en <= '0';
                        buffer_we <= '0';
                        if i_empty = '0' then
                            o_fifo_rd_en <= '1';
                            state <= WAIT_BEFORE_CHECK_VALID;
                        else  -- the FIFO is empty
                            state <= FIFO_EMPTY;
                        end if;
                    
                    when WAIT_BEFORE_CHECK_VALID =>  -- delay of one period before checking the i_valid signal from the FIFO
                        o_fifo_rd_en <= '0';
                        state <= CHECK_VALID;
                    
                    when CHECK_VALID =>
                        if i_valid = '1' then  -- the read value is valid, it can be saved in the memory
                            neuron_id <= i_fifo_dout;
                            buffer_en <= '1';
                            state <= WAIT_BEFORE_MEM_READ;
                        else  -- we try to read again
                            state <= FIFO_READ;
                        end if;
                    
                    when WAIT_BEFORE_MEM_READ =>
                        id_value <= get_id_value(neuron_id);  -- compute the transform from the neuron_id on 18 bits to a number from 0 to C_MAX_ID(=199 for the ZedBoard)
                        state <= MEM_WRITE;
                    
                    when MEM_WRITE =>  -- write the new vertical array, and return to read the FIFO again
                        -- the new column has a '1' at the vertical position corresponding to the ID value
                        buffer_din <= convert_neuron_id(id_value, buffer_dout);
                        buffer_we  <= '1';
                        state <= FIFO_READ;
                    
                    when FIFO_EMPTY =>
                        buffer_en   <= '0';
                        buffer_we   <= '0';
                        o_mem_wr_en <= '0';
                        o_mem_wr_we <= '0';
                        if i_empty = '0' then
                            state <= FIFO_READ;
                        elsif transfer_from_buffer = '1' then
                            transfer_from_buffer <= '0';
                            transfer_addr        <= current_ts(transfer_addr'high downto 0) - (buffer_cnt-1);
                            buffer_en            <= '1';
                            buffer_addr          <= (others => '0');
                            transfer_rd_delay    <= '0';
                            state <= WAIT_BEFORE_TRANSFER_READ;
                        elsif i_ph_dist = '0' then  -- the end of the distribution phase
                            current_ts <= current_ts + 1;  -- increment the timestamp
                            state <= IDLE;
                        end if;
                    
                    when WAIT_BEFORE_TRANSFER_READ =>
                        buffer_addr <= buffer_addr + 1;
                        if transfer_rd_delay = '0' then
                            transfer_rd_delay <= '1';
                        else
                            state <= TRANSFER_WRITE;
                        end if;
                    
                    when TRANSFER_WRITE =>
                        o_mem_wr_en   <= '1';
                        o_mem_wr_we   <= '1';
                        o_mem_wr_addr <= transfer_addr;
                        o_mem_wr_din  <= buffer_dout;
                        if buffer_addr < buffer_cnt+1 then
                            buffer_addr   <= buffer_addr + 1;
                            transfer_addr <= transfer_addr + 1;
                        else
                            buffer_cnt <= (others => '0');
                            state <= FIFO_EMPTY;
                        end if;
                    
                    when others =>
                        o_fifo_rd_en <= '0';
                        buffer_en    <= '0';
                        buffer_we    <= '0';
                        o_mem_wr_en  <= '0';
                        o_mem_wr_we  <= '0';
                        state <= IDLE;
                    
                end case;
            end if;
        end if;
    end process;
    
end Behavioral;
