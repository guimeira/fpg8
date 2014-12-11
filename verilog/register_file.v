`timescale 1ns / 1ps

module register_file(
	input clk,
	input rst,
	input[3:0] address,
	input write,
	input[7:0] write_data,
	output[7:0] reg_data
);
	reg[15:0][7:0] registers;
	
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			//For initialization purposes, the for loop is synthesizable
			//http://stackoverflow.com/questions/20356857/how-to-set-all-the-bits-to-be-0-in-a-two-dimensional-array-in-verilog
			for(integer i = 0; i < 16; i = i+1) registers[i] <= 8'd0;
		end
		else begin
			if(write) begin
				registers[address] <= write_data;
			end
		end
	end
	
	assign reg_data = registers[address];
endmodule
