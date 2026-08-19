`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////

module uarttx_tb(    );
reg clk, rst;
reg newd;
reg [7:0] tx_data;
wire donetx;
wire  tx;
UARTTx uut (
.clk(clk),
.rst(rst),
.newd(newd),
.tx_data(tx_data),
.donetx(donetx),
.tx(tx)
);

always #5 clk = ~clk;

initial
begin
    clk =0;
    rst =1;
    newd=0;
    tx_data =0;
    #100;
    rst=0;
    tx_data=8'b01010011;
    #100;
    newd=1;
    
    #2000;
    newd=0;
    #100000;
    newd=1;
    #2000;
    newd=0;
    #100000;
   
end

endmodule
