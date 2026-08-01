library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Rx is
    Port (
        clk        : in  STD_LOGIC;
        Rx         : in  STD_LOGIC;
        data_out   : out STD_LOGIC_VECTOR(7 downto 0);
        data_ready : out STD_LOGIC
    );
end UART_Rx;

architecture Behavioral of UART_Rx is

    ------------------------------------------------------------------
    -- UART Configuration
    ------------------------------------------------------------------
    constant CLK_FREQ : integer := 100000000;
    constant BAUD     : integer := 9600;
    constant BAUD_DIV : integer := CLK_FREQ / BAUD;

    type state_type is (IDLE, START_BIT, DATA_BITS, STOP_BIT);
    signal state : state_type := IDLE;

    signal baud_counter : integer range 0 to BAUD_DIV := 0;
    signal bit_counter  : integer range 0 to 7 := 0;
    signal rx_buffer    : std_logic_vector(7 downto 0) := (others => '0');

begin

    process(clk)
    begin
        if rising_edge(clk) then

            -- Default
            data_ready <= '0';

            case state is

            ------------------------------------------------------------------
            -- Wait for Start Bit
            ------------------------------------------------------------------
            when IDLE =>

                baud_counter <= 0;

                if Rx = '0' then
                    state <= START_BIT;
                end if;

            ------------------------------------------------------------------
            -- Wait Half Bit
            ------------------------------------------------------------------
            when START_BIT =>

                if baud_counter = BAUD_DIV/2 then

                    baud_counter <= 0;

                    if Rx = '0' then
                        bit_counter <= 0;
                        state <= DATA_BITS;
                    else
                        state <= IDLE;
                    end if;

                else
                    baud_counter <= baud_counter + 1;
                end if;

            ------------------------------------------------------------------
            -- Receive Data
            ------------------------------------------------------------------
            when DATA_BITS =>

                if baud_counter = BAUD_DIV-1 then

                    baud_counter <= 0;

                    rx_buffer(bit_counter) <= Rx;

                    if bit_counter = 7 then
                        state <= STOP_BIT;
                    else
                        bit_counter <= bit_counter + 1;
                    end if;

                else
                    baud_counter <= baud_counter + 1;
                end if;

            ------------------------------------------------------------------
            -- Stop Bit
            ------------------------------------------------------------------
            when STOP_BIT =>

                if baud_counter = BAUD_DIV-1 then

                    baud_counter <= 0;

                    if Rx = '1' then
                        data_out <= rx_buffer;
                        data_ready <= '1';
                    end if;

                    state <= IDLE;

                else
                    baud_counter <= baud_counter + 1;
                end if;

            end case;

        end if;
    end process;

end Behavioral;