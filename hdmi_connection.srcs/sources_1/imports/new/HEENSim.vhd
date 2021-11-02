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
        G_DATA_SIZE : INTEGER := 1;
        G_PERIOD    : INTEGER := 125_000  -- 1 ms
    );
    port (
        i_clk           : in STD_LOGIC;
        i_rst           : in STD_LOGIC;
        i_freeze_screen : in STD_LOGIC;
        i_rd_en         : in STD_LOGIC;
        
        o_dout       : out STD_LOGIC_VECTOR(17 downto 0);
        o_empty      : out STD_LOGIC;
        o_valid      : out STD_LOGIC;
        o_data_count : out STD_LOGIC_VECTOR(9 downto 0);
        o_ph_exec    : out STD_LOGIC;
        o_ph_dist    : out STD_LOGIC
        
        
--        o_mem_en     : out STD_LOGIC;
--        o_mem_addr   : out STD_LOGIC_VECTOR(10 downto 0);
--        o_mem_dout   : out STD_LOGIC_VECTOR(17 downto 0);
--        o_fifo_wr_en : out STD_LOGIC;
--        o_fifo_din   : out STD_LOGIC_VECTOR(17 downto 0)
    );
end HEENSim;

architecture Behavioral of HEENSim is
    
    component blk_mem_gen_0
        port (
            clka  : in STD_LOGIC;
            ena   : in STD_LOGIC;
            wea   : in STD_LOGIC_VECTOR(0 downto 0);
            addra : in STD_LOGIC_VECTOR(10 downto 0);
            dina  : in STD_LOGIC_VECTOR(17 downto 0);
            
            douta : out STD_LOGIC_VECTOR(17 downto 0)
        );
    end component blk_mem_gen_0;
    
    component fifo_generator_0
        port (
            clk    : in STD_LOGIC;
            srst   : in STD_LOGIC;
            din    : in STD_LOGIC_VECTOR(17 downto 0);
            wr_en  : in STD_LOGIC;
            rd_en  : in STD_LOGIC;
            
            dout       : out STD_LOGIC_VECTOR(17 downto 0);
            full       : out STD_LOGIC;
            empty      : out STD_LOGIC;
            valid      : out STD_LOGIC;
            data_count : out STD_LOGIC_VECTOR(9 downto 0)
        );
    end component;
    
    type phasestate_fsm is (
        IDLE_PHASE,
        EXEC_PHASE,
        EXEC_WRITE,
        DIST_PHASE
    );
    signal phase_state : phasestate_fsm;
    -- BRAM
    signal mem_en   : STD_LOGIC;
    signal mem_addr : STD_LOGIC_VECTOR(10 downto 0);
    signal mem_dout : STD_LOGIC_VECTOR(17 downto 0);
    -- FIFO
    signal fifo_rst   : STD_LOGIC;
    signal fifo_wr_en : STD_LOGIC;
    signal fifo_din   : STD_LOGIC_VECTOR(17 downto 0);
    -- OTHERS
    signal count : STD_LOGIC_VECTOR(23 downto 0) := (others => '0');
    
begin
    
--    o_mem_en     <= mem_en    ;
--    o_mem_addr   <= mem_addr  ;
--    o_mem_dout   <= mem_dout  ;
--    o_fifo_wr_en <= fifo_wr_en;
--    o_fifo_din   <= fifo_din  ;
    
    fifo_rst <= i_rst or i_freeze_screen;
    
    blk_mem_gen : blk_mem_gen_0 
    port map (
        clka   => i_clk,
        ena    => mem_en,
        wea(0) => '0',
        addra  => mem_addr,
        dina   => (others => '0'),
        
        douta => mem_dout
    );
    
    fifo_generator : fifo_generator_0  
    port map (
        clk    => i_clk,
        srst   => fifo_rst,
        din    => fifo_din,
        wr_en  => fifo_wr_en,
        rd_en  => i_rd_en,
        
        dout       => o_dout,
        full       => open,
        empty      => o_empty,
        valid      => o_valid,
        data_count => o_data_count
    );
    
    o_ph_dist  <= '1' when phase_state = DIST_PHASE else '0';
    o_ph_exec  <= '1' when phase_state = EXEC_PHASE or phase_state = EXEC_WRITE else '0';
    
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_rst = '1' then
                phase_state <= IDLE_PHASE;
                mem_addr    <= (others => '0');
                count       <= (others => '0');
                fifo_wr_en  <= '0';
                mem_en      <= '0';
            
            else
                case phase_state is
                    
                    when IDLE_PHASE =>
                        if count < 9 then
                            count <= count + 1;
                        else
                            count       <= (others => '0');
                            phase_state <= EXEC_PHASE;
                        end if;
                    
                    when EXEC_PHASE =>
                        if count < G_DATA_SIZE + 1 then
                            mem_en      <= '1';
                            fifo_wr_en  <= '0';
                            if count > 0 then
                                fifo_din <= mem_dout;
                            end if;
                            phase_state <= EXEC_WRITE;
                        else
                            fifo_wr_en  <= '0';
                            mem_en      <= '0';
                            phase_state <= DIST_PHASE;
                        end if;
                    
                    when EXEC_WRITE =>
                        if count > 0 then
                            fifo_wr_en <= '1';
                        end if;
                        if count < G_DATA_SIZE then
                            mem_addr <= mem_addr + 1;
                        end if;
                        count       <= count + 1;
                        phase_state <= EXEC_PHASE;
                    
                    when DIST_PHASE =>
                        if count < G_PERIOD then
                            count <= count + 1;
                        else
                            count       <= (others => '0');
                            phase_state <= EXEC_PHASE;
                        end if;
                    
                    when others =>
                        phase_state <= IDLE_PHASE;
                    
                end case;
            end if;
            
        end if;
    end process;
    
end Behavioral;
