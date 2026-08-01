----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01.08.2026 15:37:49
-- Design Name: 
-- Module Name: UART_TX_TB - Behavioral
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
entity UART_TX_TB is
end UART_TX_TB;

architecture Behavioral of UART_TX_TB is
 signal  clk      : STD_LOGIC :='0';
 signal  start    : STD_LOGIC :='0';
 signal  data_in  : STD_LOGIC_VECTOR(7 downto 0):=x"00";
 signal  Tx       :  STD_LOGIC;
begin
D1: entity work.UART_Tx
    port map(
            clk     => clk     ,
            start   => start   ,
            data_in => data_in ,
            Tx      => Tx                  
        );
Clk_process:process(clk)
begin
    clk <= not clk after 5ns;
end process;
Stim:process
begin
    wait for 100ns;
    start <='1';
    data_in <=x"03";
    wait; 
end process;
end Behavioral;
