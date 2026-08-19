library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity UART_Tx is
Port (
    clk      : in STD_LOGIC;
    start    : in STD_LOGIC;
    data_in  : in STD_LOGIC_VECTOR(7 downto 0);
    Tx       : out STD_LOGIC
);
end UART_Tx;

architecture Behavioral of UART_Tx is

    ------------------------------------------------------------------
    -- Constants
    ------------------------------------------------------------------
    constant CLK_FREQ : integer := 100000000;
    constant BAUD     : integer := 9600;
    constant BAUD_DIV : integer := CLK_FREQ / BAUD;   -- 10416

    ------------------------------------------------------------------
    -- Signals
    ------------------------------------------------------------------
    signal baud_counter : integer range 0 to BAUD_DIV-1 := 0;
    signal baud_tick    : std_logic := '0';

    type state_type is (IDLE, SEND);
    signal state : state_type := IDLE;

    signal txData      : std_logic_vector(9 downto 0);
    signal bit_counter : integer range 0 to 9 := 0;

    signal tx_reg : std_logic := '1';

begin

    ------------------------------------------------------------------
    -- Baud Tick Generator
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then

            baud_tick <= '0';

            if state = SEND then

                if baud_counter = BAUD_DIV-1 then
                    baud_counter <= 0;
                    baud_tick <= '1';
                else
                    baud_counter <= baud_counter + 1;
                end if;

            else
                baud_counter <= 0;
            end if;

        end if;
    end process;

    ------------------------------------------------------------------
    -- UART Transmitter FSM
    ------------------------------------------------------------------
    process(clk)
    begin
        if rising_edge(clk) then
            case state is
                ------------------------------------------------------
                when IDLE =>
                    tx_reg <= '1';
                    if start = '1' then
                        -- Stop + Data + Start
                        txData <= '1' & data_in & '0';
                        bit_counter <= 0;
                        tx_reg <= '0';      -- Start bit immediately
                        state <= SEND;
                    end if;
                ------------------------------------------------------
                when SEND =>
                    if baud_tick = '1' then
                        bit_counter <= bit_counter + 1;
                        if bit_counter < 9 then
                            tx_reg <= txData(bit_counter + 1);
                        else
                            tx_reg <= '1';
                            state <= IDLE;
                            bit_counter <= 0;
                        end if;
                    end if;
            end case;
        end if;
    end process;
    ------------------------------------------------------------------
    -- Output
    ------------------------------------------------------------------
    Tx <= tx_reg;
end Behavioral;