`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/29 20:24:18
// Design Name: 
// Module Name: ic_ram
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module ic_ram(
    clk,
    rst_n,
    wea,
    addra,//write port
    dina,

    addrb,
    doutb
    );


parameter ram_dw = 128;
parameter ram_aw = 9;

localparam dp = 1 << ram_aw;

input   clk;
input   rst_n;
input   wea;
input   [ram_aw - 1 : 0]    addra;
input   [ram_dw - 1 : 0]    dina;

input   [ram_aw - 1 : 0]	addrb;
output  [ram_dw - 1 : 0]	doutb;

(* ram_style="distributed" *)	
reg		[ram_dw - 1 : 0]	ram [dp - 1 : 0];

//ram init, the code below can not be implement in vivado,
//but it can be translated in synopsys.
// integer i;
// initial begin
// 	for (i = 0; i< dp; i++)begin
// 		ram[i] = 128'd0;
// 	end
// end

always @(posedge clk)begin
	if(wea) begin
		ram[addra] <=	dina;
	end
end
   
assign doutb =  ram[addrb];

endmodule

   