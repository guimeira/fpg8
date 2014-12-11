`timescale 1ns / 1ps

module chip8_core(
	//The clock:
	input clk_100mhz,
	//The reset signal:
	input rst,
	//The signal that starts program execution:
	input start,
	//Debug mode:
	input debug_mode,
	input step,
	output[15:0] current_ir,
	output[15:0] current_pc,
	output[15:0] current_i,
	input[3:0] read_reg,
	output[7:0] reg_val,
	output stopped,
	output idle,
	//Signals to drive the memory controller:
	output reg mem_read,
	output reg mem_write,
	output reg[25:0] mem_address,
	output reg[15:0] mem_write_data,
	input[15:0] mem_read_data,
	input mem_busy,
	//Signals to drive the video controller:
	output reg extended_video_mode,
	output reg[15:0] sprite,
	output reg[5:0] draw_row,
	output reg[6:0] draw_col,
	output reg draw_sprite,
	output reg clear_screen,
	output reg scroll_left,
	output reg scroll_right,
	output reg scroll_down,
	output reg[3:0] scroll_down_amount,
	input colision,
	input video_busy,
	//Signal to drive the audio controller:
	output sound,
	//Signals from the input controller:
	input[15:0] key_state,
	input[3:0] key_decoder,
	//Slowdown value:
	input[15:0] slow_down
);
assign current_i = i_reg;
assign reg_val = registers[read_reg];

wire[7:0] random_byte;
lfsr random_gen(
	.clk(clk_100mhz),
	.rst(rst),
	.random_byte(random_byte)
);

//General purpose registers:
reg[7:0] registers[15:0];
//The special register I:
reg[15:0] i_reg;
always @(posedge clk_100mhz, posedge rst) begin : registers_manager
	//Variable to perform adition:
	reg[8:0] tmp_operation;
	integer i;
	
	if(rst) begin
		//For initialization purposes, the for loop is synthesizable
		//http://stackoverflow.com/questions/20356857/how-to-set-all-the-bits-to-be-0-in-a-two-dimensional-array-in-verilog\
		for(i = 0; i < 16; i = i+1) registers[i] <= 8'd0;
		i_reg <= 16'd0;
	end
	else begin
		//If we go to the idle state, put the processor in its initial state:
		if(current_state == RESET) begin
			for(i = 0; i < 16; i = i+1) registers[i] <= 8'd0;
			i_reg <= 16'd0;
		end
		else if(current_state == EXECUTE) begin
			casez(instruction_register)
				16'h6???: begin
					//This type of LD puts an immediate value in a register:
					registers[operand1] <= instruction_register[7:0];
				end
				16'h7???: begin
					//If executing an ADD, compute the adition:
					registers[operand1] <= registers[operand1] + byte_immediate;
				end
				16'h8??0: begin
					//This type of LD copies a register in another:
					registers[operand1] <= registers[operand2];
				end
				16'h8??1: begin
					//Performs a bitwise OR between registers:
					registers[operand1] <= registers[operand1] | registers[operand2];
				end
				16'h8??2: begin
					//Performs a bitwise AND between registers:
					registers[operand1] <= registers[operand1] & registers[operand2];
				end
				16'h8??3: begin
					//Performs a bitwise XOR between registers:
					registers[operand1] <= registers[operand1] ^ registers[operand2];
				end
				16'h8??4: begin
					//Performs an adition. Sets VF to 1 if carry or 0 otherwise:
					tmp_operation = {1'd0,registers[operand1]} + {1'd0,registers[operand2]};
					registers[operand1] <= tmp_operation[7:0];
					registers[15] <= {7'd0,tmp_operation[8]};
				end
				16'h8??5: begin
					//Performs a subtraction. Sets VF to 1 if Vx > Vy:
					registers[15] <= {7'd0,registers[operand2] <= registers[operand1]};
					registers[operand1] <= registers[operand1] - registers[operand2];
				end
				16'h8??6: begin
					//Performs a shift right. Sets VF to the discarded value:
					registers[15] <= {7'd0,registers[operand1][0]};
					registers[operand1] <= registers[operand1] >> 1;
				end
				16'h8??7: begin
					//Performs a subtraction. Sets VF to 1 if Vy > Vx:
					registers[15] <= {7'd0,registers[operand1] <= registers[operand2]};
					registers[operand1] <= registers[operand2] - registers[operand1];
				end
				16'h8??E: begin
					//Performs a shift left. Sets VF to the discarded value:
					registers[15] <= {7'd0,registers[operand1][7]};
					registers[operand1] <= registers[operand1] << 1;
				end
				16'hA???: begin
					//Sets the value of I:
					i_reg <= {4'h0,big_immediate};
				end
				16'hC???: begin
					registers[operand1] <= random_byte & byte_immediate;
				end
				16'hF?07: begin
					//Sets Vx to the current value of the delay timer:
					registers[operand1] <= delay_timer;
				end
				16'hF?1E: begin
					//Adds I and Vx:
					i_reg <= i_reg + registers[operand1];
				end
				16'hF?29: begin
					//Sets I to the location of sprite representing hex value in Vx:
					i_reg <= registers[operand1][3:0] == 4'h0 ? 16'd0 :
								registers[operand1][3:0] == 4'h1 ? 16'd5 :
								registers[operand1][3:0] == 4'h2 ? 16'd10 :
								registers[operand1][3:0] == 4'h3 ? 16'd15 :
								registers[operand1][3:0] == 4'h4 ? 16'd20 :
								registers[operand1][3:0] == 4'h5 ? 16'd25 :
								registers[operand1][3:0] == 4'h6 ? 16'd30 :
								registers[operand1][3:0] == 4'h7 ? 16'd35 :
								registers[operand1][3:0] == 4'h8 ? 16'd40 :
								registers[operand1][3:0] == 4'h9 ? 16'd45 :
								registers[operand1][3:0] == 4'hA ? 16'd50 :
								registers[operand1][3:0] == 4'hB ? 16'd55 :
								registers[operand1][3:0] == 4'hC ? 16'd60 :
								registers[operand1][3:0] == 4'hD ? 16'd65 :
								registers[operand1][3:0] == 4'hE ? 16'd70 : 16'd75;
				end
				16'hF?30: begin
					//Sets I to the location of hi-res sprite representing hex value in Vx:
					i_reg <= registers[operand1][3:0] == 4'h0 ? 16'd80 :
								registers[operand1][3:0] == 4'h1 ? 16'd90 :
								registers[operand1][3:0] == 4'h2 ? 16'd100 :
								registers[operand1][3:0] == 4'h3 ? 16'd110 :
								registers[operand1][3:0] == 4'h4 ? 16'd120 :
								registers[operand1][3:0] == 4'h5 ? 16'd130 :
								registers[operand1][3:0] == 4'h6 ? 16'd140 :
								registers[operand1][3:0] == 4'h7 ? 16'd150 :
								registers[operand1][3:0] == 4'h8 ? 16'd160 :
								registers[operand1][3:0] == 4'h9 ? 16'd170 :
								registers[operand1][3:0] == 4'hA ? 16'd180 :
								registers[operand1][3:0] == 4'hB ? 16'd190 :
								registers[operand1][3:0] == 4'hC ? 16'd200 :
								registers[operand1][3:0] == 4'hD ? 16'd210 :
								registers[operand1][3:0] == 4'hE ? 16'd220 : 16'd230;
				end
			endcase
		end
		else if(current_state == WAIT_FOR_INPUT) begin
			if(key_state != 16'd0) begin
				registers[operand1] <= {4'd0,key_decoder};
			end
		end
		else if(comm_current_state == STATE_LOAD_REGS_WAIT && !mem_busy) begin
			registers[current_reg] <= mem_read_data[7:0];
		end
		else if(comm_current_state == STATE_DRAW_SPRITE_WAIT_WRITE && !video_busy) begin
			registers[15] <= {7'd0,colision_detected | colision};
		end
	end
end : registers_manager

//The program counter register:
reg[15:0] program_counter;
always @(posedge clk_100mhz, posedge rst) begin
	if(rst) begin
		program_counter <= 16'h200;
	end
	else begin
		if(current_state == RESET) begin
			program_counter <= 16'h200;
		end
		else if(current_state == INCREMENT_PC) begin
			casez(instruction_register)
				16'h00EE: begin
					//If executing a RET, restore the program counter from stack and increment:
					program_counter <= stack[stack_pointer-4'd1] + 16'd2;
				end
				16'h1???: begin
					//If executing a JMP, set program counter from the instruction:
					program_counter <= {4'h0,big_immediate};
				end
				16'h2???: begin
					//If executing CALL, the current PC will be stored on stack and here we set it
					//to the new value:
					program_counter <= {4'h0,big_immediate};
				end
				16'h3???: begin
					//If executing SE (register and byte), set PC based on comparison:
					program_counter <= registers[operand1] == byte_immediate ?
											program_counter + 16'd4 : program_counter + 16'd2;
				end
				16'h4???: begin
					//If executing SNE (register and byte), set PC based on comparison:
					program_counter <= registers[operand1] != byte_immediate ?
											program_counter + 16'd4 : program_counter + 16'd2;
				end
				16'h5??0: begin
					//If executing SE (register and register), set PC based on comparison:
					program_counter <= registers[operand1] == registers[operand2] ?
											program_counter + 16'd4 : program_counter + 16'd2;
				end
				16'h9??0: begin
					//If executing SNE (register and register), set PC based on comparison:
				program_counter <= registers[operand1] != registers[operand2] ?
											program_counter + 16'd4 : program_counter + 16'd2;
				end
				16'hB???: begin
					//If executing JP with V0 and immediate, set PC based on the values:
					program_counter <= registers[0] + big_immediate;
				end
				16'hE?9E: begin
					//If executing SKP, check key and increment PC accordingly:
					program_counter <= key_state[registers[operand1][3:0]] ? program_counter + 16'd4 : program_counter + 16'd2;
				end
				16'hE?A1: begin
					//If executing SKNP, check key and increment PC accordingly:
					program_counter <= !key_state[registers[operand1][3:0]] ? program_counter + 16'd4 : program_counter + 16'd2;
				end
				default: begin
					//If executing any other instruction, simply increments PC by 2:
					program_counter <= program_counter + 16'd2;
				end
			endcase
		end
	end
end

//Stack and stack pointer:
reg[3:0] stack_pointer;
reg[15:0] stack[15:0];
always @(posedge clk_100mhz, posedge rst) begin : stack_manager
	integer i;
	if(rst) begin
		stack_pointer <= 4'd0;
		//For initialization purposes, the for loop is synthesizable
		//http://stackoverflow.com/questions/20356857/how-to-set-all-the-bits-to-be-0-in-a-two-dimensional-array-in-verilog\
		for(i = 0; i < 16; i = i+1) stack[i] <= 16'd0;
	end
	else begin
		if(current_state == RESET) begin
			stack_pointer <= 4'd0;
			for(i = 0; i < 16; i = i+1) stack[i] <= 16'd0;
		end
		else if(current_state == INCREMENT_PC) begin
			casez(instruction_register)
				16'h00EE: begin
					//If we are executing a RET, decrement the stack pointer:
					stack_pointer <= stack_pointer - 4'd1;
				end
				16'h2???: begin
					//If we are executing a CALL, store the current PC and increment stack pointer:
					stack_pointer <= stack_pointer + 4'd1;
					stack[stack_pointer] <= program_counter; //the stack_pointer here is still the non-incremented
				end
			endcase
		end
	end
end : stack_manager

//Timers instantiation:
wire[7:0] delay_timer;
wire[7:0] sound_timer;
reg set_delay_timer;
reg set_sound_timer;
reg[7:0] timer_data;
timers timers(
	.clk(clk_100mhz),
	.rst(rst),
	.set_delay(set_delay_timer),
	.set_sound(set_sound_timer),
	.data(timer_data),
	.delay_timer(delay_timer),
	.sound_timer(sound_timer)
);
assign sound = sound_timer != 8'd0;

always @(posedge clk_100mhz, posedge rst) begin
	if(rst) begin
		set_delay_timer <= 1'd0;
		set_sound_timer <= 1'd0;
		timer_data <= 8'd0;
	end
	else begin
		if(current_state == RESET) begin
			set_delay_timer <= 1'd0;
			set_sound_timer <= 1'd0;
			timer_data <= 8'd0;
		end
		else if(current_state == EXECUTE) begin
			casez(instruction_register)
				16'hF?15: begin
					set_delay_timer <= 1'd1;
					timer_data <= registers[operand1];
				end
				16'hF?18: begin
					set_sound_timer <= 1'd1;
					timer_data <= registers[operand1];
				end
			endcase
		end
		else begin
			set_delay_timer <= 1'd0;
			set_sound_timer <= 1'd0;
		end
	end
end

//This register stores a instruction read from memory:
reg[15:0] instruction_register;
//Give names to parts of instruction:
wire[3:0] operand1;
assign operand1 = instruction_register[11:8];
wire[3:0] operand2;
assign operand2 = instruction_register[7:4];
wire[7:0] byte_immediate;
assign byte_immediate = instruction_register[7:0];
wire[11:0] big_immediate;
assign big_immediate = instruction_register[11:0];
wire[3:0] nibble_immediate;
assign nibble_immediate = instruction_register[3:0];

//BCD Converter instantiation:
wire[7:0] bcd_in;
assign bcd_in = registers[operand1];
wire[1:0] bcd_hundreds;
wire[3:0] bcd_tens;
wire[3:0] bcd_ones;
bcd_encoder bcd(
	.binary(bcd_in),
	.hundreds(bcd_hundreds),
	.tens(bcd_tens),
	.ones(bcd_ones)
);

//This state machine controls the communication with the memory controller
//and the video controller:
parameter[4:0] STATE_COMM_IDLE = 5'd0,
					STATE_FETCH_PREPARE_1 = 5'd1,
					STATE_FETCH_WAIT_1 = 5'd2,
					STATE_FETCH_PREPARE_2 = 5'd3,
					STATE_FETCH_WAIT_2 = 5'd4,
					STATE_CLEAR_DISPLAY_PREPARE = 5'd5,
					STATE_CLEAR_DISPLAY_WAIT = 5'd6,
					STATE_DRAW_SPRITE_PREPARE_1 = 5'd7,
					STATE_DRAW_SPRITE_WAIT_1 = 5'd8,
					STATE_DRAW_SPRITE_PREPARE_2 = 5'd9,
					STATE_DRAW_SPRITE_WAIT_2 = 5'd10,
					STATE_DRAW_SPRITE_PREPARE_WRITE = 5'd11,
					STATE_DRAW_SPRITE_WAIT_WRITE = 5'd12,
					STATE_STORE_BCD_PREPARE_1 = 5'd13,
					STATE_STORE_BCD_WAIT_1 = 5'd14,
					STATE_STORE_BCD_PREPARE_2 = 5'd15,
					STATE_STORE_BCD_WAIT_2 = 5'd16,
					STATE_STORE_BCD_PREPARE_3 = 5'd17,
					STATE_STORE_BCD_WAIT_3 = 5'd18,
					STATE_STORE_REGS_PREPARE = 5'd19,
					STATE_STORE_REGS_WAIT = 5'd20,
					STATE_LOAD_REGS_PREPARE = 5'd21,
					STATE_LOAD_REGS_WAIT = 5'd22,
					STATE_SCROLL_DOWN_PREPARE = 5'd23,
					STATE_SCROLL_DOWN_WAIT = 5'd24,
					STATE_SCROLL_LEFT_PREPARE = 5'd25,
					STATE_SCROLL_LEFT_WAIT = 5'd26,
					STATE_SCROLL_RIGHT_PREPARE = 5'd27,
					STATE_SCROLL_RIGHT_WAIT = 5'd28;
reg[4:0] comm_current_state, comm_next_state;

always @(posedge clk_100mhz, posedge rst) begin
	if(rst) begin
		comm_current_state <= STATE_COMM_IDLE;
	end
	else begin
		comm_current_state <= comm_next_state;
	end
end

always @(comm_current_state,current_state,mem_busy,video_busy,extended_video_mode,sprite_height,current_reg,nibble_immediate,operand1) begin
	case(comm_current_state)
		STATE_COMM_IDLE: begin
			if(current_state == FETCH_INSTRUCTION) begin
				comm_next_state = STATE_FETCH_PREPARE_1;
			end
			else if(current_state == CLEAR_DISPLAY) begin
				comm_next_state = STATE_CLEAR_DISPLAY_PREPARE;
			end
			else if(current_state == DRAW_SPRITE) begin
				comm_next_state = STATE_DRAW_SPRITE_PREPARE_1;
			end
			else if(current_state == STORE_BCD) begin
				comm_next_state = STATE_STORE_BCD_PREPARE_1;
			end
			else if(current_state == STORE_REGISTERS) begin
				comm_next_state = STATE_STORE_REGS_PREPARE;
			end
			else if(current_state == LOAD_REGISTERS) begin
				comm_next_state = STATE_LOAD_REGS_PREPARE;
			end
			else if(current_state == SCROLL_DOWN) begin
				comm_next_state = STATE_SCROLL_DOWN_PREPARE;
			end
			else if(current_state == SCROLL_LEFT) begin
				comm_next_state = STATE_SCROLL_LEFT_PREPARE;
			end
			else if(current_state == SCROLL_RIGHT) begin
				comm_next_state = STATE_SCROLL_RIGHT_PREPARE;
			end
			else if(current_state == RESET) begin
				comm_next_state = STATE_CLEAR_DISPLAY_PREPARE;
			end
			else begin
				comm_next_state = STATE_COMM_IDLE;
			end
		end
		STATE_FETCH_PREPARE_1: begin
			comm_next_state = STATE_FETCH_WAIT_1;
		end
		STATE_FETCH_WAIT_1: begin
			if(!mem_busy) begin
				comm_next_state = STATE_FETCH_PREPARE_2;
			end
			else begin
				comm_next_state = STATE_FETCH_WAIT_1;
			end
		end
		STATE_FETCH_PREPARE_2: begin
			comm_next_state = STATE_FETCH_WAIT_2;
		end
		STATE_FETCH_WAIT_2: begin
			if(!mem_busy) begin
				comm_next_state = STATE_COMM_IDLE;
			end
			else begin
				comm_next_state = STATE_FETCH_WAIT_2;
			end
		end
		STATE_CLEAR_DISPLAY_PREPARE: begin
			comm_next_state = STATE_CLEAR_DISPLAY_WAIT;
		end
		STATE_CLEAR_DISPLAY_WAIT: begin
			if(!video_busy) begin
				comm_next_state = STATE_COMM_IDLE;
			end
			else begin
				comm_next_state = STATE_CLEAR_DISPLAY_WAIT;
			end
		end
		STATE_DRAW_SPRITE_PREPARE_1: begin
			comm_next_state = STATE_DRAW_SPRITE_WAIT_1;
		end
		STATE_DRAW_SPRITE_WAIT_1: begin
			if(!mem_busy) begin
				if(extended_video_mode && nibble_immediate == 4'd0) begin
					comm_next_state = STATE_DRAW_SPRITE_PREPARE_2;
				end
				else begin
					comm_next_state = STATE_DRAW_SPRITE_PREPARE_WRITE;
				end
			end
			else begin
				comm_next_state = STATE_DRAW_SPRITE_WAIT_1;;
			end
		end
		STATE_DRAW_SPRITE_PREPARE_2: begin
			comm_next_state = STATE_DRAW_SPRITE_WAIT_2;
		end
		STATE_DRAW_SPRITE_WAIT_2: begin
			if(!mem_busy) begin
				comm_next_state = STATE_DRAW_SPRITE_PREPARE_WRITE;
			end
			else begin
				comm_next_state = STATE_DRAW_SPRITE_WAIT_2;
			end
		end
		STATE_DRAW_SPRITE_PREPARE_WRITE: begin
			comm_next_state = STATE_DRAW_SPRITE_WAIT_WRITE;
		end
		STATE_DRAW_SPRITE_WAIT_WRITE: begin
			if(!video_busy) begin
				if(sprite_height == 5'd0) begin
					comm_next_state = STATE_COMM_IDLE;
				end
				else begin
					comm_next_state = STATE_DRAW_SPRITE_PREPARE_1;
				end
			end
			else begin
				comm_next_state = STATE_DRAW_SPRITE_WAIT_WRITE;
			end
		end
		STATE_STORE_BCD_PREPARE_1: begin
			comm_next_state = STATE_STORE_BCD_WAIT_1;
		end
		STATE_STORE_BCD_WAIT_1: begin
			if(!mem_busy) begin
				comm_next_state = STATE_STORE_BCD_PREPARE_2;
			end
			else begin
				comm_next_state = STATE_STORE_BCD_WAIT_1;
			end
		end
		STATE_STORE_BCD_PREPARE_2: begin
			comm_next_state = STATE_STORE_BCD_WAIT_2;
		end
		STATE_STORE_BCD_WAIT_2: begin
			if(!mem_busy) begin
				comm_next_state = STATE_STORE_BCD_PREPARE_3;
			end
			else begin
				comm_next_state = STATE_STORE_BCD_WAIT_2;
			end
		end
		STATE_STORE_BCD_PREPARE_3: begin
			comm_next_state = STATE_STORE_BCD_WAIT_3;
		end
		STATE_STORE_BCD_WAIT_3: begin
			if(!mem_busy) begin
				comm_next_state = STATE_COMM_IDLE;
			end
			else begin
				comm_next_state = STATE_STORE_BCD_WAIT_3;
			end
		end
		STATE_STORE_REGS_PREPARE: begin
			comm_next_state = STATE_STORE_REGS_WAIT;
		end
		STATE_STORE_REGS_WAIT: begin
			if(!mem_busy) begin
				if(current_reg == operand1) begin
					comm_next_state = STATE_COMM_IDLE;
				end
				else begin
					comm_next_state = STATE_STORE_REGS_PREPARE;
				end
			end
			else begin
				comm_next_state = STATE_STORE_REGS_WAIT;
			end
		end
		STATE_LOAD_REGS_PREPARE: begin
			comm_next_state = STATE_LOAD_REGS_WAIT;
		end
		STATE_LOAD_REGS_WAIT: begin
			if(!mem_busy) begin
				if(current_reg == operand1) begin
					comm_next_state = STATE_COMM_IDLE;
				end
				else begin
					comm_next_state = STATE_LOAD_REGS_PREPARE;
				end
			end
			else begin
				comm_next_state = STATE_LOAD_REGS_WAIT;
			end
		end
		STATE_SCROLL_DOWN_PREPARE: begin
			comm_next_state = STATE_SCROLL_DOWN_WAIT;
		end
		STATE_SCROLL_DOWN_WAIT: begin
			if(!video_busy) begin
				comm_next_state = STATE_COMM_IDLE;
			end
			else begin
				comm_next_state = STATE_SCROLL_DOWN_WAIT;
			end
		end
		STATE_SCROLL_LEFT_PREPARE: begin
			comm_next_state = STATE_SCROLL_LEFT_WAIT;
		end
		STATE_SCROLL_LEFT_WAIT: begin
			if(!video_busy) begin
				comm_next_state = STATE_COMM_IDLE;
			end
			else begin
				comm_next_state = STATE_SCROLL_LEFT_WAIT;
			end
		end
		STATE_SCROLL_RIGHT_PREPARE: begin
			comm_next_state = STATE_SCROLL_RIGHT_WAIT;
		end
		STATE_SCROLL_RIGHT_WAIT: begin
			if(!video_busy) begin
				comm_next_state = STATE_COMM_IDLE;
			end
			else begin
				comm_next_state = STATE_SCROLL_RIGHT_WAIT;
			end
		end
		
		//Avoid latches:
		default: comm_next_state = comm_current_state;
	endcase
end

//This register will store the remaining rows to be loaded
//from memory:
reg[3:0] sprite_height;
reg[3:0] current_reg;
reg colision_detected;
always @(posedge clk_100mhz, posedge rst) begin
	if(rst) begin
		mem_read <= 1'd0;
		mem_write <= 1'd0;
		mem_address <= 26'd0;
		mem_write_data <= 16'd0;
		instruction_register <= 16'd0;
		sprite <= 16'd0;
		draw_row <= 6'd0;
		draw_col <= 7'd0;
		draw_sprite <= 1'd0;
		clear_screen <= 1'd0;
		scroll_left <= 1'd0;
		scroll_right <= 1'd0;
		scroll_down <= 1'd0;
		scroll_down_amount <= 4'd0;
		sprite_height <= 4'd0;
		current_reg <= 4'd0;
		colision_detected <= 1'd0;
	end
	else begin
		case(comm_current_state)
			STATE_COMM_IDLE: begin
				if(current_state == FETCH_INSTRUCTION) begin
					mem_address <= {10'd0,program_counter};
					mem_read <= 1'd1;
				end
				else if(current_state == CLEAR_DISPLAY) begin
					clear_screen <= 1'd1;
				end
				else if(current_state == DRAW_SPRITE) begin
					mem_address <= {10'd0,i_reg};
					mem_read <= 1'd1;
					draw_row <= extended_video_mode ? registers[operand2][5:0] : {1'd0,registers[operand2][4:0]};
					draw_col <= extended_video_mode ? registers[operand1][6:0] : {1'd0,registers[operand1][5:0]};
					sprite_height <= extended_video_mode && nibble_immediate == 4'd0 ? 4'd15 : nibble_immediate-4'd1;
					colision_detected <= 1'd0;
				end
				else if(current_state == STORE_BCD) begin
					mem_address <= {10'd0,i_reg};
					mem_write <= 1'd1;
					mem_write_data <= {14'd0,bcd_hundreds};
				end
				else if(current_state == STORE_REGISTERS) begin
					mem_address <= {10'd0,i_reg};
					mem_write <= 1'd1;
					mem_write_data <= {8'd0,registers[0]};
					current_reg <= 4'd0;
				end
				else if(current_state == LOAD_REGISTERS) begin
					mem_address <= {10'd0,i_reg};
					mem_read <= 1'd1;
					current_reg <= 4'd0;
				end
				else if(current_state == SCROLL_DOWN) begin
					scroll_down <= 1'd1;
					scroll_down_amount <= nibble_immediate;
				end
				else if(current_state == SCROLL_LEFT) begin
					scroll_left <= 1'd1;
				end
				else if(current_state == SCROLL_RIGHT) begin
					scroll_right <= 1'd1;
				end
				else if(current_state == RESET) begin
					clear_screen <= 1'd1;
				end
			end
			STATE_FETCH_WAIT_1: begin
				if(mem_busy) begin
					//The memory controller already started reading,
					//so we can set this signal to low here:
					mem_read <= 1'd0;
				end
				else begin
					//The memory finished reading, let's store the data
					//and trigger new read:
					instruction_register[15:8] <= mem_read_data[7:0];
					mem_read <= 1'd1;
					mem_address <= {10'd0,program_counter+1};
				end
			end
			STATE_FETCH_WAIT_2: begin
				if(mem_busy) begin
					//Already reading, disable the read signal:
					mem_read <= 1'd0;
				end
				else begin
					//Read finished, store the data:
					instruction_register[7:0] <= mem_read_data[7:0];
				end
			end
			STATE_CLEAR_DISPLAY_WAIT: begin
				if(video_busy) begin
					//Clear operation already started, we can set
					//this signal to low:
					clear_screen <= 1'd0;
				end
			end
			STATE_DRAW_SPRITE_WAIT_1: begin
				if(mem_busy) begin
					//Read started:
					mem_read <= 1'd0;
				end
				else begin
					//Read finished:
					//We will set the least significant bits to zero
					//If we are in Chip-8 video mode, we are done with
					//loading, otherwise, those bits will be overriden
					//by the next load:
					sprite <= {mem_read_data[7:0],8'd0};
					
					//If the sprite is 8-bit long, we are done reading:
					if(!extended_video_mode || nibble_immediate != 4'd0) begin
						draw_sprite <= 1'd1;
					end
					else begin
						mem_address <= mem_address + 26'd1;
						mem_read <= 1'd1;
					end
				end
			end
			STATE_DRAW_SPRITE_WAIT_2: begin
				if(mem_busy) begin
					//Read started:
					mem_read <= 1'd0;
				end
				else begin
					//Read finished:
					sprite[7:0] <= mem_read_data[7:0];
					draw_sprite <= 1'd1;
				end
			end
			STATE_DRAW_SPRITE_WAIT_WRITE: begin
				if(video_busy) begin
					draw_sprite <= 1'd0;
				end
				else begin
					if(sprite_height > 4'd0) begin
						sprite_height <= sprite_height - 4'd1;
						if((extended_video_mode && draw_row == 6'd63) || (!extended_video_mode && draw_row == 6'd31)) begin
							draw_row <= 6'd0;
						end
						else begin
							draw_row <= draw_row + 6'd1;
						end
						mem_address <= mem_address + 26'd1;
						mem_read <= 1'd1;
						colision_detected <= colision_detected | colision;
					end
				end
			end
			STATE_STORE_BCD_WAIT_1: begin
				if(mem_busy) begin
					mem_write <= 1'd0;
				end
				else begin
					mem_write <= 1'd1;
					mem_address <= mem_address+26'd1;
					mem_write_data <= {12'd0,bcd_tens};
				end
			end
			STATE_STORE_BCD_WAIT_2: begin
				if(mem_busy) begin
					mem_write <= 1'd0;
				end
				else begin
					mem_write <= 1'd1;
					mem_address <= mem_address+26'd1;
					mem_write_data <= {12'd0,bcd_ones};
				end
			end
			STATE_STORE_BCD_WAIT_3: begin
				if(mem_busy) begin
					mem_write <= 1'd0;
				end
			end
			STATE_STORE_REGS_WAIT: begin
				if(mem_busy) begin
					mem_write <= 1'd0;
				end
				else begin
					if(current_reg < operand1) begin
						mem_address <= mem_address + 26'd1;
						mem_write <= 1'd1;
						mem_write_data <= {8'd0,registers[current_reg+4'd1]};
						current_reg <= current_reg + 4'd1;
					end
				end
			end
			STATE_LOAD_REGS_WAIT: begin
				if(mem_busy) begin
					mem_read <= 1'd0;
				end
				else begin
					if(current_reg < operand1) begin
						mem_address <= mem_address + 26'd1;
						mem_read <= 1'd1;
						current_reg <= current_reg + 4'd1;
					end
				end
			end
			STATE_SCROLL_DOWN_WAIT: begin
				if(video_busy) begin
					scroll_down <= 1'd0;
				end
			end
			STATE_SCROLL_LEFT_WAIT: begin
				if(video_busy) begin
					scroll_left <= 1'd0;
				end
			end
			STATE_SCROLL_RIGHT_WAIT: begin
				if(video_busy) begin
					scroll_right <= 1'd0;
				end
			end
		endcase
	end
end

//This ALWAYS statement controls the video mode:
always @(posedge clk_100mhz, posedge rst) begin
	if(rst) begin
		extended_video_mode <= 1'd0;
	end
	else begin
		if(current_state == RESET) begin
			extended_video_mode <= 1'd0;
		end
		else if(current_state == EXECUTE) begin
			casez(instruction_register)
				16'h00FE: begin
					extended_video_mode <= 1'd0;
				end
				16'h00FF: begin
					extended_video_mode <= 1'd1;
				end
			endcase
		end
	end
end

//Edge detector for the step signal:
reg[1:0] shift_reg;
wire step_edge;
assign step_edge = shift_reg == 2'b10;
always @(posedge clk_100mhz,posedge rst) begin
	if(rst) begin
		shift_reg <= 2'd0;
	end
	else begin
		shift_reg <= {step,shift_reg[1]};
	end
end

//Slow down counter:
reg[15:0] slow_down_counter;
always @(posedge clk_100mhz, posedge rst) begin
	if(rst) begin
		slow_down_counter <= 16'd0;
	end
	else begin
		//We restart the counter when we begin to fetch a instruction and count
		//until we reach the desired value:
		if(current_state != FETCH_INSTRUCTION) begin
			if(slow_down_counter < slow_down) begin
				slow_down_counter <= slow_down_counter + 16'd1;
			end
			else begin
				slow_down_counter <= slow_down_counter;
			end
		end
		else begin
			slow_down_counter <= 16'd0;
		end
	end
end

//Possible states for the main state machine:
parameter[4:0] FETCH_INSTRUCTION = 5'd0,
					EXECUTE = 5'd1,
					WAIT_FOR_COMM = 5'd2,
					CLEAR_DISPLAY = 5'd3,
					DRAW_SPRITE = 5'd4,
					WAIT_FOR_INPUT = 5'd5,
					STORE_BCD = 5'd6,
					STORE_REGISTERS = 5'd7,
					LOAD_REGISTERS = 5'd8,
					SCROLL_DOWN = 5'd9,
					SCROLL_LEFT = 5'd10,
					SCROLL_RIGHT = 5'd11,
					INCREMENT_PC = 5'd12,
					IDLE = 5'd13,
					BREAKPOINT = 5'd14,
					WAIT_FOR_FETCH = 5'd15,
					SLOW_DOWN = 5'd16,
					RESET = 5'd17;

assign current_ir = instruction_register;
assign current_pc = program_counter;
assign stopped = current_state == BREAKPOINT;
assign idle = current_state == IDLE;

reg[4:0] current_state, next_state;
//Change state machine state:
always @(posedge clk_100mhz, posedge rst) begin
	if(rst) begin
		current_state <= IDLE;
	end
	else begin
		current_state <= next_state;
	end
end

always @(current_state,comm_current_state,start,instruction_register,key_state,debug_mode,step_edge,slow_down,slow_down_counter) begin
	case(current_state)
		IDLE: begin
			if(start) begin
				next_state = FETCH_INSTRUCTION;
			end
			else begin
				next_state = IDLE;
			end
		end
		FETCH_INSTRUCTION: begin
			//In this state we just ask the memory controller to start the read.
			//Then we go to the next state to wait for the read to finish.
			next_state = WAIT_FOR_FETCH;
		end
		
		WAIT_FOR_FETCH: begin
			//Here we wait until the memory controller finishes the reading.
			//When the reading is finished, we start execution.
			if(comm_current_state == STATE_COMM_IDLE) begin
				next_state = EXECUTE;
			end
			else begin
				next_state = WAIT_FOR_FETCH;
			end
		end
		
		EXECUTE: begin
			//Special case construction that supports dont-cares.
			//Greatly simplifies the instruction parsing.
			//http://pages.cs.wisc.edu/~david/courses/cs552/S12/handouts/verilog2.pdf
			casez(instruction_register)
				//CLS: Clears the display
				16'h00E0: begin
					next_state = CLEAR_DISPLAY;
				end
				//RET: return from subroutine
				16'h00EE: begin
					next_state = INCREMENT_PC;
				end
				//JMP: jump to location
				16'h1???: begin
					next_state = INCREMENT_PC;
				end
				//CALL: invoke subroutine
				16'h2???: begin
					next_state = INCREMENT_PC;
				end
				//SE: skip next instruction if register is equals a value
				16'h3???: begin
					next_state = INCREMENT_PC;
				end
				//SNE: skip next instruction if register is not equals a value
				16'h4???: begin
					next_state = INCREMENT_PC;
				end
				//SE: skip next instruction if two registers are equals
				16'h5??0: begin
					next_state = INCREMENT_PC;
				end
				//LD: put a value in a register
				16'h6???: begin
					next_state = INCREMENT_PC;
				end
				//ADD: adds a value to a register
				16'h7???: begin
					next_state = INCREMENT_PC;
				end
				//LD: copies a value of a register
				16'h8??0: begin
					next_state = INCREMENT_PC;
				end
				//OR: performs a bitwise OR:
				16'h8??1: begin
					next_state = INCREMENT_PC;
				end
				//AND: performs a bitwise AND:
				16'h8??2: begin
					next_state = INCREMENT_PC;
				end
				//XOR: performs a bitwise XOR:
				16'h8??3: begin
					next_state = INCREMENT_PC;
				end
				//ADD: performs an addition:
				16'h8??4: begin
					next_state = INCREMENT_PC;
				end
				//SUB: performs a subtraction:
				16'h8??5: begin
					next_state = INCREMENT_PC;
				end
				//SHR: performs a shift right:
				16'h8??6: begin
					next_state = INCREMENT_PC;
				end
				//SUB: performs a subtraction:
				16'h8??7: begin
					next_state = INCREMENT_PC;
				end
				//SHL: performs a shift left:
				16'h8??E: begin
					next_state = INCREMENT_PC;
				end
				//SNE: skip next instruction if two registers are different:
				16'h9??0: begin
					next_state = INCREMENT_PC;
				end
				//LD: loads the I register:
				16'hA???: begin
					next_state = INCREMENT_PC;
				end
				//JP: jump to location:
				16'hB???: begin
					next_state = INCREMENT_PC;
				end
				//RND: assigns a random value to a register:
				16'hC???: begin
					next_state = INCREMENT_PC;
				end
				//DRW: draws a sprite on screen:
				16'hD???: begin
					next_state = DRAW_SPRITE;
				end
				//SKP: skip next instruction if key is pressed:
				16'hE?9E: begin
					next_state = INCREMENT_PC;
				end
				//SKNP: skip next instruction if key is not pressed:
				16'hE?A1: begin
					next_state = INCREMENT_PC;
				end
				//LD: load delay timer value:
				16'hF?07: begin
					next_state = INCREMENT_PC;
				end
				//LD: wait for key press and put value in Vx:
				16'hF?0A: begin
					next_state = WAIT_FOR_INPUT;
				end
				//LD: set value of delay timer:
				16'hF?15: begin
					next_state = INCREMENT_PC;
				end
				//LD: set value of sound timer:
				16'hF?18: begin
					next_state = INCREMENT_PC;
				end
				//ADD: add I and Vx:
				16'hF?1E: begin
					next_state = INCREMENT_PC;
				end
				//LD: set I to the location of sprite for digit in Vx:
				16'hF?29: begin
					next_state = INCREMENT_PC;
				end
				//LD: put on memory the BCD representation of Vx:
				16'hF?33: begin
					next_state = STORE_BCD;
				end
				//LD: store registers V0 through Vx starting at location I:
				16'hF?55: begin
					next_state = STORE_REGISTERS;
				end
				//LD: read registers V) through Vx from memory starting at location I:
				16'hF?65: begin
					next_state = LOAD_REGISTERS;
				end
				//SCD: scroll the screen down:
				16'h00C?: begin
					next_state = SCROLL_DOWN;
				end
				//SCR: scroll the screen to the right:
				16'h00FB: begin
					next_state = SCROLL_RIGHT;
				end
				//SCL: scroll the screen to the left:
				16'h00FC: begin
					next_state = SCROLL_LEFT;
				end
				//EXIT: stops execution:
				16'h00FD: begin
					next_state = RESET;
				end
				//LOW: switches to Chip-8 video mode:
				16'h00FE: begin
					next_state = INCREMENT_PC;
				end
				//HIGH: switches to S-Chip (extended) video mode:
				16'h00FF: begin
					next_state = INCREMENT_PC;
				end
				//Point I to the address of a hi-res font sprite:
				16'hF?30: begin
					next_state = INCREMENT_PC;
				end
				//The folliwing two instructions interface with the HP calculator for which
				//the original S-Chip emulator was built. Here we simply do nothing, but they
				//are here to ensure compatibility with games that use them:
				16'hF?75: begin
					next_state = INCREMENT_PC;
				end
				16'hF?85: begin
					next_state = INCREMENT_PC;
				end
				//Unknown instruction, reset the processor:
				default: next_state = RESET;
			endcase
		end
		WAIT_FOR_COMM: begin
			//Here we wait until the memory controller finishes the reading.
			//When the reading is finished, we start execution.
			if(comm_current_state == STATE_COMM_IDLE) begin
				if(start) begin
					next_state = INCREMENT_PC;
				end
				else begin
					//If we are resetting the processor, go to idle state:
					next_state = IDLE;
				end
			end
			else begin
				next_state = WAIT_FOR_COMM;
			end
		end
		CLEAR_DISPLAY: begin
			next_state = WAIT_FOR_COMM;
		end
		DRAW_SPRITE: begin
			next_state = WAIT_FOR_COMM;
		end
		STORE_BCD: begin
			next_state = WAIT_FOR_COMM;
		end
		STORE_REGISTERS: begin
			next_state = WAIT_FOR_COMM;
		end
		LOAD_REGISTERS: begin
			next_state = WAIT_FOR_COMM;
		end
		SCROLL_DOWN: begin
			next_state = WAIT_FOR_COMM;
		end
		SCROLL_LEFT: begin
			next_state = WAIT_FOR_COMM;
		end
		SCROLL_RIGHT: begin
			next_state = WAIT_FOR_COMM;
		end
		WAIT_FOR_INPUT: begin
			if(key_state != 16'd0) begin
				next_state = INCREMENT_PC;
			end
			else begin
				next_state = WAIT_FOR_INPUT;
			end
		end
		INCREMENT_PC: begin
			//We wait one cycle for the increment logic and we are done:
			if(!start) begin
				//If the processor was stopped, go to reset state:
				next_state = RESET;
			end
			else if(debug_mode) begin
				//If we are in debug mode, wait for the step signal:
				next_state = BREAKPOINT;
			end
			else if(slow_down > 16'd0) begin
				next_state = SLOW_DOWN;
			end
			else begin
				//If not in debug mode, fetch next instruction:
				next_state = FETCH_INSTRUCTION;
			end
		end
		
		SLOW_DOWN: begin
			if(slow_down_counter == slow_down) begin
				next_state = FETCH_INSTRUCTION;
			end
			else begin
				next_state = SLOW_DOWN;
			end
		end
		
		BREAKPOINT: begin
			if(step_edge) begin
				next_state = FETCH_INSTRUCTION;
			end
			else begin
				next_state = BREAKPOINT;
			end
		end
		
		RESET: begin
			next_state = WAIT_FOR_COMM;
		end
		
		//Avoid latches:
		default: next_state = current_state;
	endcase
end

endmodule
