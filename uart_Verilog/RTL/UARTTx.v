`timescale 1ns / 1ps

module UARTTx
#(
    parameter clk_frequency = 1000000,
    parameter baud_rate     = 9600
)
(
    input        clk,
    input        rst,
    input        newd,
    input  [7:0] tx_data,
    output       donetx,
    output       tx
);

integer count = 0;
integer bitcounts_next, bitcounts_reg;

reg slow_clk;

reg donetx_reg, donetx_next;
reg tx_reg, tx_next;

reg [7:0] tx_data_reg;

localparam clkcount = clk_frequency / baud_rate;

localparam [1:0]
    idle     = 2'b00,
    transfer = 2'b01,
    done     = 2'b10;

reg [1:0] state_reg, state_next;


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

        if (count < clkcount/2)
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
        state_reg     <= idle;
        tx_reg        <= 1'b1;
        donetx_reg    <= 1'b0;
        bitcounts_reg <= 0;
        tx_data_reg   <= 8'b0;
    end

    else
    begin
        state_reg     <= state_next;
        tx_reg        <= tx_next;
        donetx_reg    <= donetx_next;
        bitcounts_reg <= bitcounts_next;

        if ((state_reg == idle) && newd)
        begin
            tx_data_reg <= tx_data;
        end
    end

end


/************************************************
 * Combinational Logic
 ************************************************/

always @(*)
begin

    state_next     = state_reg;
    tx_next        = tx_reg;
    donetx_next    = 1'b0;
    bitcounts_next = bitcounts_reg;

    case(state_reg)

        idle:
        begin

            tx_next = 1'b1;

            if(newd)
            begin
                state_next = transfer;

                /*
                 * Start bit
                 */
                tx_next = 1'b0;

                bitcounts_next = 0;
            end

        end


        transfer:
        begin

            if(bitcounts_reg <= 7)
            begin
                tx_next = tx_data_reg[bitcounts_reg];

                bitcounts_next = bitcounts_reg + 1;
            end

            else
            begin
                /*
                 * Stop bit
                 */
                tx_next = 1'b1;

                state_next = done;

                bitcounts_next = 0;
            end

        end


        done:
        begin

            tx_next     = 1'b1;

            donetx_next = 1'b1;

            state_next  = idle;

        end


        default:
        begin

            state_next     = idle;
            tx_next        = 1'b1;
            donetx_next    = 1'b0;
            bitcounts_next = 0;

        end

    endcase

end


assign tx     = tx_reg;
assign donetx = donetx_reg;

endmodule