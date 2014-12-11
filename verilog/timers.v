`timescale 1ns / 1ps

module timers(
	input clk,
	input rst,
	input[7:0] data,
	input set_delay,
	input set_sound,
	output reg[7:0] delay_timer,
	output reg[7:0] sound_timer
);
	//Counter used to generate timing:
	//Counting from 0 to 1666666 will give us a period of 1/60.
	//Chip-8 counters decrement at 60Hz.
	reg[20:0] counter;
	parameter[20:0] COUNTER_MAX = 1666666;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			counter <= 21'd0;
		end
		else begin
			if(counter < COUNTER_MAX) begin
				counter <= counter + 21'd1;
			end
			else begin
				counter <= 21'd0;
			end
		end
	end
	
	//Process to decrement the counters:
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			delay_timer <= 8'd0;
			sound_timer <= 8'd0;
		end
		else begin
			//If the counter reaches the maximum value, decrement the counters as necessary:
			if(counter == COUNTER_MAX) begin
				if(delay_timer > 0) begin
					delay_timer <= delay_timer - 8'd1;
				end
				if(sound_timer > 0) begin
					sound_timer <= sound_timer - 8'd1;
				end
			end
			
			//If the set signals are HIGH, load the data into counters:
			if(set_delay) begin
				delay_timer <= data;
			end
			
			if(set_sound) begin
				sound_timer <= data;
			end
		end
	end
endmodule
