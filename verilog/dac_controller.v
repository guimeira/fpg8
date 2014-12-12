`timescale 1ns / 1ps

module dac_controller(
	//The 100MHz clock:
	input clk,
	//The reset signal:
	input rst,
	//Data to write to the DAC:
	input[7:0] data,
	//Signal to trigger the write:
	input write,
	//High when the controller is transmitting:
	output busy,
	
	output dac_clk,
	output dac_sync,
	output dac_data
);
	
	//States for the main state machine:
	parameter[1:0] STATE_IDLE = 2'd0,
						STATE_PREPARING_TRANSMISSION = 2'd1,
						STATE_TRANSMITTING = 2'd2;
						
	reg[1:0] current_state, next_state;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			current_state = STATE_IDLE;
		end
		else begin
			current_state = next_state;
		end
	end
	
	//Next state logic for the main state machine:
	always @(current_state,write,counter) begin
		case(current_state)
			STATE_IDLE: begin
				//If we are idle and someone wants to start a transmission:
				if(write) begin
					next_state = STATE_PREPARING_TRANSMISSION;
				end
				else begin
					next_state = STATE_IDLE;
				end
			end
			STATE_PREPARING_TRANSMISSION: begin
				next_state = STATE_TRANSMITTING;
			end
			STATE_TRANSMITTING: begin
				if(counter == 4'd15) begin
					next_state = STATE_IDLE;
				end
				else begin
					next_state = STATE_TRANSMITTING;
				end
			end
			default: next_state = current_state; //avoid latches
		endcase
	end
	
	//Counter used during transmission:
	reg[3:0] counter;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			counter <= 4'd0;
		end
		else begin
			if(current_state == STATE_TRANSMITTING) begin
				counter <= counter + 4'd1;
			end
			else begin
				counter <= 4'd0;
			end
		end
	end
	
	//Shift register to hold the data:
	reg [15:0] shift_reg;
	always @(posedge clk, posedge rst) begin
		if(rst) begin
			shift_reg <= 16'd0;
		end
		else begin
			if(current_state == STATE_PREPARING_TRANSMISSION) begin
				shift_reg <= data;
			end
			else if(current_state == STATE_TRANSMITTING) begin
				shift_reg <= {shift_reg[14:0],1'd0};
			end
		end
	end
	
	wire clk_inv;
	assign clk_inv = !clk;
	ODDR2 oddr(
		.Q(dac_clk),
		.C0(clk),
		.C1(clk_inv),
		.CE(1'd1),
		.D0(1'd0),
		.D1(1'd1),
		.R(1'd0),
		.S(1'd0)
	);
	
	//The busy signal is high whenever we are not idle:
	assign busy = current_state != STATE_IDLE;
	
	//The data sent to the DAC is the most significant bit in our shift register:
	assign dac_data = shift_reg[15];
	
	//The sync signal is low during a transmission:
	assign dac_sync = current_state == STATE_IDLE;
endmodule
