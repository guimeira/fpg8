`timescale 1ns / 1ps

module bcd_encoder(
	input[7:0] binary,
	output[1:0] hundreds,
	output[3:0] tens,
	output[3:0] ones
);

//Generate the hundreds value:
wire[7:0] hundreds_value;
assign hundreds_value = binary >= 8'd200 ? 8'd200 :
								binary >= 8'd100 ? 8'd100 : 8'd0;

assign hundreds = binary >= 8'd200 ? 2'd2 :
						binary >= 8'd100 ? 2'd1 : 2'd0;

//Generate the tens value:
wire[6:0] tens_value;
assign tens_value = binary-hundreds_value >= 7'd90 ? 7'd90 :
						  binary-hundreds_value >= 7'd80 ? 7'd80 :
						  binary-hundreds_value >= 7'd70 ? 7'd70 :
						  binary-hundreds_value >= 7'd60 ? 7'd60 :
						  binary-hundreds_value >= 7'd50 ? 7'd50 :
						  binary-hundreds_value >= 7'd40 ? 7'd40 :
						  binary-hundreds_value >= 7'd30 ? 7'd30 :
						  binary-hundreds_value >= 7'd20 ? 7'd20 :
						  binary-hundreds_value >= 7'd10 ? 7'd10 : 7'd0;

assign tens = binary-hundreds_value >= 7'd90 ? 4'd9 :
				  binary-hundreds_value >= 7'd80 ? 4'd8 :
				  binary-hundreds_value >= 7'd70 ? 4'd7 :
				  binary-hundreds_value >= 7'd60 ? 4'd6 :
				  binary-hundreds_value >= 7'd50 ? 4'd5 :
				  binary-hundreds_value >= 7'd40 ? 4'd4 :
				  binary-hundreds_value >= 7'd30 ? 4'd3 :
				  binary-hundreds_value >= 7'd20 ? 4'd2 :
				  binary-hundreds_value >= 7'd10 ? 4'd1 : 4'd0;

//Generate the ones value:
wire[7:0] ones_value = binary-hundreds_value-tens_value;
assign ones = ones_value[3:0];
endmodule
