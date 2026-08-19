library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_RX_TB is
end UART_RX_TB;

architecture sim of UART_RX_TB is

    signal clk        : std_logic := '0';
    signal Rx         : std_logic := '1';
    signal data_out   : std_logic_vector(7 downto 0);
    signal data_ready : std_logic;

    constant CLK_PERIOD : time := 10 ns;       -- 100 MHz
    constant BIT_PERIOD : time := 104160 ns;   -- 1 / 9600

begin

    -- Device Under Test
    DUT: entity work.UART_Rx
        port map (
            clk        => clk,
            Rx         => Rx,
            data_out   => data_out,
            data_ready => data_ready
        );

    -- Clock generator (concurrent, NOT inside a process)
    clk <= not clk after CLK_PERIOD / 2;

    -- Stimulus
    process
    begin
        -- Idle
        wait for 20 * CLK_PERIOD;

        ----------------------------------------------------------
        -- Send one byte: 0x55 = 0101_0101 (LSB first)
        ----------------------------------------------------------
        
        -- Start bit
        Rx <= '0';
        wait for BIT_PERIOD;

        -- Data bits (LSB first)
        Rx <= '1';  wait for BIT_PERIOD;  -- bit 0
        Rx <= '0';  wait for BIT_PERIOD;  -- bit 1
        Rx <= '1';  wait for BIT_PERIOD;  -- bit 2
        Rx <= '0';  wait for BIT_PERIOD;  -- bit 3
        Rx <= '1';  wait for BIT_PERIOD;  -- bit 4
        Rx <= '0';  wait for BIT_PERIOD;  -- bit 5
        Rx <= '1';  wait for BIT_PERIOD;  -- bit 6
        Rx <= '0';  wait for BIT_PERIOD;  -- bit 7

        -- Stop bit
        Rx <= '1';
        wait for BIT_PERIOD;

        ----------------------------------------------------------
        -- Wait for DUT to flag data_ready and check result
        ----------------------------------------------------------
        wait until rising_edge(clk) and data_ready = '1';
        
        assert data_out = x"55"
            report "ERROR: Expected 0x55, got " & 
                   integer'image(to_integer(unsigned(data_out)))
            severity error;

        report "Test passed: 0x55 received correctly";

        -- Idle forever
        wait;
    end process;

end sim;