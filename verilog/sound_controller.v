`timescale 1ns / 1ps

module sound_controller(
	//The 100MHz clock:
	input clk,
	//The reset signal:
	input rst,
	//Indicates whether the sound should be produced:
	input sound,
	//The DAC clock:
	output dac_clk,
	//The DAC sync signal:
	output dac_sync,
	//The DAC data signal:
	output dac_data
);

	//DAC controller instantiation:
	wire[7:0] data;
	wire write;
	wire busy;
	dac_controller dac(
		.clk(clk),
		.rst(rst),
		.data(data),
		.busy(busy),
		.write(write),
		.dac_clk(dac_clk),
		.dac_sync(dac_sync),
		.dac_data(dac_data)
	);
	
	//Our wave has 100 samples and the frequency is 440Hz, so the time between
	//samples in clock cycles is is 1/(440*100) * 100MHz = 2272
	reg[11:0] counter;
	parameter[11:0] FREQUENCY_COUNTER = 2272;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			counter <= 12'd0;
		end
		else begin
			if(counter < FREQUENCY_COUNTER) begin
				counter <= counter + 12'd1;
			end
			else begin
				counter <= 12'd0;
			end
		end
	end
	
	//Counter to select a sample to be sent to the DAC:
	reg[6:0] current_value;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			current_value <= 7'd0;
		end
		else begin
			if(counter == FREQUENCY_COUNTER) begin
				if(current_value == 7'd99) begin
					current_value <= 4'd0;
				end
				else begin
					current_value <= current_value + 7'd1;
				end
			end
		end
	end
	
	//When we want sound we write a sample, otherwise, just write zero:
	assign data = sound ? sine_table[current_value] : 8'd0;
	
	//We trigger a write on the DAC when our counter restarts the counting:
	assign write = counter == 0;
	
	//Samples for the sine wave:
	parameter[7:0] sine_table[99:0] = {8'h80,8'h88,8'h8f,8'h97,8'h9f,8'ha7,8'hae,8'hb6,8'hbd,8'hc4,8'hca,8'hd1,8'hd7,8'hdc,8'he2,8'he7,8'heb,8'hef,8'hf3,8'hf6,8'hf9,8'hfb,8'hfd,8'hfe,8'hff,8'hff,8'hff,8'hfe,8'hfd,8'hfb,8'hf9,8'hf6,8'hf3,8'hef,8'heb,8'he7,8'he2,8'hdc,8'hd7,8'hd1,8'hca,8'hc4,8'hbd,8'hb6,8'hae,8'ha7,8'h9f,8'h97,8'h8f,8'h88,8'h80,8'h77,8'h70,8'h68,8'h60,8'h58,8'h51,8'h49,8'h42,8'h3b,8'h35,8'h2e,8'h28,8'h23,8'h1d,8'h18,8'h14,8'h10,8'hc,8'h9,8'h6,8'h4,8'h2,8'h1,8'h0,8'h0,8'h0,8'h1,8'h2,8'h4,8'h6,8'h9,8'hc,8'h10,8'h14,8'h18,8'h1d,8'h23,8'h28,8'h2e,8'h35,8'h3b,8'h42,8'h49,8'h51,8'h58,8'h60,8'h68,8'h70,8'h77};
endmodule
