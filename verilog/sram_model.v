`timescale 1ns / 1ps

module sram_model(
	input [9:0] addr,
	inout [7:0] data,
	input oe_n,
	input we_n
);

reg[7:0] sram[0:1023];

always @(posedge we_n)
	sram[addr] = data;

assign data = (oe_n == 0) ? sram[addr] : 8'bz;

endmodule
