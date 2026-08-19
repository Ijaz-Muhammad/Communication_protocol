`timescale 1ns / 1ps

module UARTRx_tb;

reg        clk;
reg        rst;
reg        rx;

wire       donerx;
wire [7:0] rx_data;


/************************************************
 * DUT
 ************************************************/

UARTRx
#(
    .clk_frequency(1000000),
    .baud_rate(9600)
)
uut
(
    .clk(clk),
    .rst(rst),
    .rx(rx),

    .donerx(donerx),
    .rx_data(rx_data)
);


/************************************************
 * Clock Generation
 *
 * 1 MHz clock
 * Period = 1 us
 ************************************************/

always #500 clk = ~clk;


/************************************************
 * UART Bit Timing
 *
 * 9600 baud
 * Tbit = 104.17 us
 ************************************************/

localparam BIT_PERIOD = 104170;


/************************************************
 * UART Transmit Task
 ************************************************/

task uart_send_byte;

    input [7:0] data;

    integer i;

    begin

        /*
         * Start bit
         */

        rx = 1'b0;
        #(BIT_PERIOD);


        /*
         * Data bits
         * LSB first
         */

        for (i = 0; i < 8; i = i + 1)
        begin

            rx = data[i];

            #(BIT_PERIOD);

        end


        /*
         * Stop bit
         */

        rx = 1'b1;
        #(BIT_PERIOD);

    end

endtask


/************************************************
 * Test
 ************************************************/

initial
begin

    /*
     * Initial values
     */

    clk = 1'b0;
    rst = 1'b1;
    rx  = 1'b1;


    /*
     * Reset
     */

    #2000;

    rst = 1'b0;


    /*
     * Wait before transmission
     */

    #5000;


    /********************************************
     * Test 1
     *
     * Send 8'h55
     *
     * Binary:
     *
     * 01010101
     *
     * UART sends LSB first:
     *
     * 1 0 1 0 1 0 1 0
     ********************************************/

    uart_send_byte(8'h55);


    /*
     * Wait for receiver
     */

    #200000;
    

    $finish;

end


/************************************************
 * Monitor
 ************************************************/

always @(posedge donerx)
begin

    $display(
        "Time = %0t ns : RX DATA = %02h",
        $time,
        rx_data
    );

end

endmodule