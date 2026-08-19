`timescale 1ns / 1ps

module UARTRx
#(
    parameter clk_frequency = 1000000,
    parameter baud_rate     = 9600
)
(
    input        clk,
    input        rst,
    input        rx,

    output       donerx,
    output [7:0] rx_data
);


/************************************************
 * Baud Clock Generator
 ************************************************/

localparam clkcounts = clk_frequency / baud_rate;

integer count = 0;

reg slow_clk;


/************************************************
 * FSM States
 ************************************************/

localparam [1:0]
    idle         = 2'b00,
    receive_data = 2'b01,
    done         = 2'b10;

reg [1:0] state_reg;
reg [1:0] state_next;


/************************************************
 * Registers
 ************************************************/

integer bitcount_reg;
integer bitcount_next;

reg        donerx_reg;
reg        donerx_next;

reg [7:0]  rx_data_reg;
reg [7:0]  rx_data_next;


/************************************************
 * Baud Clock Generator
 ************************************************/

always @(posedge clk or posedge rst)
begin

    if (rst)
    begin
        count    <= 0;
        slow_clk <= 1'b0;
    end

    else
    begin

        if (count < clkcounts/2)
        begin
            count <= count + 1;
        end

        else
        begin
            count    <= 0;
            slow_clk <= ~slow_clk;
        end

    end

end


/************************************************
 * Sequential Logic
 ************************************************/

always @(posedge slow_clk or posedge rst)
begin

    if (rst)
    begin
        state_reg    <= idle;
        bitcount_reg <= 0;

        donerx_reg   <= 1'b0;
        rx_data_reg  <= 8'b0;
    end

    else
    begin
        state_reg    <= state_next;
        bitcount_reg <= bitcount_next;

        donerx_reg   <= donerx_next;
        rx_data_reg  <= rx_data_next;
    end

end


/************************************************
 * Combinational Logic
 ************************************************/

always @(*)
begin

    /*
     * Default values
     */

    state_next    = state_reg;
    bitcount_next = bitcount_reg;

    donerx_next   = 1'b0;
    rx_data_next  = rx_data_reg;


    /*
     * FSM
     */

    case (state_reg)


        /****************************************
         * IDLE
         ****************************************/

        idle:
        begin

            if (rx == 1'b0)
            begin

                /*
                 * Start bit detected
                 */

                state_next    = receive_data;
                bitcount_next = 0;

            end

        end


        /****************************************
         * RECEIVE DATA
         ****************************************/

        receive_data:
        begin

            if (bitcount_reg < 8)
            begin

                /*
                 * UART receives LSB first
                 */

                rx_data_next[bitcount_reg] = rx;

                bitcount_next = bitcount_reg + 1;

            end

            else
            begin

                state_next = done;

            end

        end


        /****************************************
         * DONE
         ****************************************/

        done:
        begin

            donerx_next = 1'b1;

            state_next = idle;

            bitcount_next = 0;

        end


        /****************************************
         * DEFAULT
         ****************************************/

        default:
        begin

            state_next    = idle;
            bitcount_next = 0;

        end

    endcase

end


/************************************************
 * Outputs
 ************************************************/

assign donerx  = donerx_reg;
assign rx_data = rx_data_reg;


endmodule