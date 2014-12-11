`timescale 1ns / 1ps

module lfsr(
	input clk,
	input rst,
	output[7:0] random_byte
);

//Current state of the LFSR:
reg[7:0] register;

always @(posedge clk, posedge rst) begin
	if(rst) begin
		//We can't have a initial value of zero:
		register <= 8'b10101101;
	end
	else begin
		//LFSR input:
		register <= {register[0] ^ register[2] ^ register[3] ^ register[5], register[7:1]};
	end
end

assign random_byte = register;

endmodule
