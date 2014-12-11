`timescale 1ns / 1ps

module input_controller(
	input [15:0] keyboard,
	output[15:0] key_state,
	output[3:0] output_decoder
);

//This data is generated in the correct format by the Microblaze, so we just use it:
assign key_state = keyboard;

//Generate the lowest value of a pressed key:
assign output_decoder = key_state[0] ? 4'h0 :
								key_state[1] ? 4'h1 :
								key_state[2] ? 4'h2 :
								key_state[3] ? 4'h3 :
								key_state[4] ? 4'h4 :
								key_state[5] ? 4'h5 :
								key_state[6] ? 4'h6 :
								key_state[7] ? 4'h7 :
								key_state[8] ? 4'h8 :
								key_state[9] ? 4'h9 :
								key_state[10] ? 4'hA :
								key_state[11] ? 4'hB :
								key_state[12] ? 4'hC :
								key_state[13] ? 4'hD :
								key_state[14] ? 4'hE :
								key_state[15] ? 4'hF : 4'h0;

endmodule
