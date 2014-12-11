`timescale 1ns / 1ps

module seven_seg(
	//The 25MHz clock:
	input clk,
	//The reset signal:
	input rst,
	//This signal enables or disables the displays:
	input enable,
	//Four 4-bit numbers to display:
	input [15:0] numbers,
	//When HIGH, this signal makes a display blink:
	input [3:0] blink,
	//Outputs to the displays:
	output [3:0] anodes,
	output reg [6:0] catodes
);
	//Constants definition:
	parameter SHAPE0 = 7'b0000001;
	parameter SHAPE1 = 7'b1001111;
	parameter SHAPE2 = 7'b0010010;
	parameter SHAPE3 = 7'b0000110;
	parameter SHAPE4 = 7'b1001100;
	parameter SHAPE5 = 7'b0100100;
	parameter SHAPE6 = 7'b0100000;
	parameter SHAPE7 = 7'b0001111;
	parameter SHAPE8 = 7'b0000000;
	parameter SHAPE9 = 7'b0000100;
	parameter SHAPEA = 7'b0001000;
	parameter SHAPEB = 7'b1100000;
	parameter SHAPEC = 7'b0110001;
	parameter SHAPED = 7'b1000010;
	parameter SHAPEE = 7'b0110000;
	parameter SHAPEF = 7'b0111000;
	
	//Counter from 0 to 25000, which gives us approximately 1ms.
	//It will be used to change the active anode.
	reg[14:0] counter;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			counter <= 15'd0;
		end
		else begin
			if(counter == 15'd25000) begin
				//If the counter reaches the maximum value, go back to zero:
				counter <= 15'd0;
			end
			else begin
				//Otherwise, keep counting:
				counter <= counter + 15'd1;
			end
		end
	end
	
	reg[24:0] blink_counter;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			blink_counter <= 25'd0;
		end
		else begin
			if(blink_counter == 25'd25000000) begin
				//If the counter reaches the maximum value, go back to zero:
				blink_counter <= 25'd0;
			end
			else begin
				//Otherwise, keep counting:
				blink_counter <= blink_counter + 25'd1;
			end
		end
	end
	
	//Selects the active anode. This works like a shift register,
	//but the bit at the leftmost position reappears in the rightmost
	//position when shifted.
	reg[3:0] active_anode;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			//Asynchronous reset:
			active_anode <= 4'b1110;
		end
		else begin
			if(counter == 15'd25000) begin
				//We only change the active anode when the counter reaches 25000:
				active_anode <= {active_anode[2:0],active_anode[3]};
			end
		end
	end
	
	//Combinational logic that selects the four bits that represent
	//the number currently being displayed.
	reg[3:0] active_number;
	always @(active_anode,numbers) begin
		case(active_anode)
			4'b1110: active_number = numbers[3:0];
			4'b1101: active_number = numbers[7:4];
			4'b1011: active_number = numbers[11:8];
			default: active_number = numbers[15:12];
		endcase
	end
	
	//Combinational logic that generates the catode signals
	//based on the currently active number.
	always @(active_number) begin
		case(active_number)
			4'h0: catodes = SHAPE0;
			4'h1: catodes = SHAPE1;
			4'h2: catodes = SHAPE2;
			4'h3: catodes = SHAPE3;
			4'h4: catodes = SHAPE4;
			4'h5: catodes = SHAPE5;
			4'h6: catodes = SHAPE6;
			4'h7: catodes = SHAPE7;
			4'h8: catodes = SHAPE8;
			4'h9: catodes = SHAPE9;
			4'hA: catodes = SHAPEA;
			4'hB: catodes = SHAPEB;
			4'hC: catodes = SHAPEC;
			4'hD: catodes = SHAPED;
			4'hE: catodes = SHAPEE;
			default: catodes = SHAPEF;
		endcase
	end
	
	//Combinational logic to generate anodes.
	//There are two cases that we don't power an anode: when the display is not enabled
	//and when the current active anode is with blinking activated and it's in the part of the
	//blink that the display is turned off.
	assign anodes = (!enable) || (((~active_anode)&blink)&&(blink_counter < 25'd12500000)) ? 4'hF : active_anode;
endmodule
