`timescale 1ns / 1ps

module video_controller(
	//Clock 100MHz from the DCM:
	input clk_100mhz,
	//Clock 25MHz from the DCM:
	input clk_25mhz,
	//Reset signal:
	input rst,
	//HIGH when using extended video mode:
	input extended_video_mode,
	//Sprite data to draw:
	input[15:0] sprite,
	//Row to draw:
	input[5:0] draw_row,
	//Column to draw:
	input[6:0] draw_col,
	//HIGH triggers a drawing:
	input draw_sprite,
	//HIGH triggers a clear:
	input clear_screen,
	//HIGH triggers scrolls:
	input scroll_left,
	input scroll_right,
	input scroll_down,
	//Number of lines to scroll down:
	input[3:0] scroll_down_amount,
	//HIGH if the last draw generated a colision:
	output reg colision,
	//HIGH when the module is working:
	output busy,
	//VGA signals:
	output hs,
	output vs,
	output[2:0] red,
	output[2:0] green,
	output[1:0] blue
);

	//VGA Controller instantiation:
	wire[10:0] hcount;
	wire[10:0] vcount;
	wire blank;
	vga_controller_640_60 vga(
		.rst(rst),
		.pixel_clk(clk_25mhz),
		.hs(hs),
		.vs(vs),
		.hcount(hcount),
		.vcount(vcount),
		.blank(blank)
	);
   
	//Video memory instantiation:
	reg write_enable_a;
	reg[5:0] address_a;
	wire[5:0] address_b;
	reg[127:0] data_input_a;
	wire[127:0] data_output_a;
	wire[127:0] data_output_b;
	video_memory mem (
		.clka(clk_100mhz),
		.wea(write_enable_a),
		.addra(address_a),
		.dina(data_input_a),
		.douta(data_output_a),
		.clkb(clk_25mhz),
		.web(1'b0),
		.addrb(address_b),
		.dinb(128'd0),
		.doutb(data_output_b)
	);
	
	//State machine that performs the sprite drawing:
	parameter[3:0] STATE_IDLE = 4'd0,
						STATE_DRAW_READING = 4'd1,
						STATE_DRAW_PREPARING_WRITE = 4'd2,
						STATE_DRAW_WRITING = 4'd3,
						STATE_CLEARING = 4'd4,
						STATE_SCROLLING_LEFT_READING = 4'd5,
						STATE_SCROLLING_LEFT_PREPARING_WRITE = 4'd6,
						STATE_SCROLLING_LEFT_WRITING = 4'd7,
						STATE_SCROLLING_RIGHT_READING = 4'd8,
						STATE_SCROLLING_RIGHT_PREPARING_WRITE = 4'd9,
						STATE_SCROLLING_RIGHT_WRITING = 4'd10,
						STATE_SCROLLING_DOWN_READING = 4'd11,
						STATE_SCROLLING_DOWN_PREPARING_WRITE = 4'd12,
						STATE_SCROLLING_DOWN_WRITING = 4'd13,
						STATE_SCROLLING_DOWN_CLEARING = 4'd14;
	reg[3:0] current_state, next_state;
	always @(posedge clk_100mhz, posedge rst) begin
		if(rst) begin
			current_state <= STATE_IDLE;
		end
		else begin
			current_state <= next_state;
		end
	end
	
	always @(current_state,draw_sprite,clear_screen,scroll_left,scroll_right,scroll_down,scroll_amount,address_a,draw_counter) begin
		case(current_state)
			STATE_IDLE: begin
				//While idle, check if the user requested some operation:
				if(draw_sprite) begin
					next_state = STATE_DRAW_READING;
				end
				else if(clear_screen) begin
					next_state = STATE_CLEARING;
				end
				else if(scroll_left) begin
					next_state = STATE_SCROLLING_LEFT_READING;
				end
				else if(scroll_right) begin
					next_state = STATE_SCROLLING_RIGHT_READING;
				end
				else if(scroll_down) begin
					next_state = STATE_SCROLLING_DOWN_READING;
				end
				else begin
					next_state = STATE_IDLE;
				end
			end
			
			STATE_DRAW_READING: begin
				//Wait for data from the memory:
				next_state = STATE_DRAW_PREPARING_WRITE;
			end
			
			STATE_DRAW_PREPARING_WRITE: begin
				//Preparing sprite to be written:
				if(draw_counter == 7'd0) begin
					next_state = STATE_DRAW_WRITING;
				end
				else begin
					next_state = STATE_DRAW_PREPARING_WRITE;
				end
			end
			
			STATE_DRAW_WRITING: begin
				//Wait one cycle for the memory to write:
				next_state = STATE_IDLE;
			end
			
			STATE_CLEARING: begin
				//While we don't reach the last line, wait in this state:
				if(address_a == 6'd63) begin
					next_state = STATE_IDLE;
				end
				else begin
					next_state = STATE_CLEARING;
				end
			end
			
			STATE_SCROLLING_LEFT_READING: begin
				//Waiting for data from the memory:
				next_state = STATE_SCROLLING_LEFT_PREPARING_WRITE;
			end
			
			STATE_SCROLLING_LEFT_PREPARING_WRITE: begin
				//Scrolling data to write:
				next_state = STATE_SCROLLING_LEFT_WRITING;
			end
			
			STATE_SCROLLING_LEFT_WRITING: begin
				//If we updated the last line, we are done, otherwise,
				//start the scroll for the next line:
				if(address_a == 6'd63) begin
					next_state = STATE_IDLE;
				end
				else begin
					next_state = STATE_SCROLLING_LEFT_READING;
				end
			end
			
			STATE_SCROLLING_RIGHT_READING: begin
				//Waiting for data from the memory:
				next_state = STATE_SCROLLING_RIGHT_PREPARING_WRITE;
			end
			
			STATE_SCROLLING_RIGHT_PREPARING_WRITE: begin
				//Scrolling data to write:
				next_state = STATE_SCROLLING_RIGHT_WRITING;
			end
			
			STATE_SCROLLING_RIGHT_WRITING: begin
				//If we updated the last line, we are done, otherwise,
				//start the scroll for the next line:
				if(address_a == 6'd63) begin
					next_state = STATE_IDLE;
				end
				else begin
					next_state = STATE_SCROLLING_RIGHT_READING;
				end
			end
			
			STATE_SCROLLING_DOWN_READING: begin
				//Waiting for data from the memory:
				next_state = STATE_SCROLLING_DOWN_PREPARING_WRITE;
			end
			
			STATE_SCROLLING_DOWN_PREPARING_WRITE: begin
				//Preparing data to be written:
				next_state = STATE_SCROLLING_DOWN_WRITING;
			end
			
			STATE_SCROLLING_DOWN_WRITING: begin
				//If we updated the last line, we can clear the topmost lines, otherwise,
				//start the scroll for the next line:
				if(address_a == scroll_amount) begin
					next_state = STATE_SCROLLING_DOWN_CLEARING;
				end
				else begin
					next_state = STATE_SCROLLING_DOWN_READING;
				end
			end
			
			STATE_SCROLLING_DOWN_CLEARING: begin
				//Here we clean the topmost lines:
				if(address_a == 6'd0) begin
					next_state = STATE_IDLE;
				end
				else begin
					next_state = STATE_SCROLLING_DOWN_CLEARING;
				end
			end
			
			//Avoid latches:
			default: next_state = current_state;
		endcase
	end
	
	//This signal indicates when we are performing some operation:
	assign busy = current_state != STATE_IDLE;
	
	reg[127:0] new_row;
	reg[6:0] draw_counter;
	reg[3:0] scroll_amount;
	always @(posedge clk_100mhz, posedge rst) begin
		if(rst) begin
			colision <= 1'd0;
			address_a <= 6'd0;
			new_row <= 127'd0;
			draw_counter <= 7'd0;
			write_enable_a <= 1'd0;
			data_input_a <= 128'd0;
			scroll_amount <= 4'd0;
		end
		else begin
			if(current_state == STATE_IDLE && draw_sprite) begin
				//When we are about to begin a reading:
				address_a <= draw_row;
				new_row <= extended_video_mode ? {sprite,112'd0} : {64'd0,sprite,48'd0};
				draw_counter <= draw_col;
			end
			else if(current_state == STATE_DRAW_PREPARING_WRITE) begin
				//We will stay in this state until the sprite is shifted
				//to its correct position.
				if(draw_counter > 7'd0) begin
					if(extended_video_mode) begin
						new_row <= {new_row[0],new_row[127:1]};
					end
					else begin
						//For Chip-8 video mode, we only rotate half of the vector:
						new_row <= {new_row[127:64],new_row[0],new_row[63:1]};
					end
					draw_counter <= draw_counter - 7'd1;
				end
				else begin
					//The sprite is in the correct position, we are
					//ready to write:
					data_input_a <= data_output_a ^ new_row;
					write_enable_a <= 1'b1;
					colision <= |(data_output_a & new_row);
				end
			end
			else if(current_state == STATE_DRAW_WRITING) begin
				//When this cycle finishes, writing is done:
				write_enable_a <= 1'b0;
			end
			else if(current_state == STATE_IDLE && clear_screen) begin
				address_a <= 6'd0;
				write_enable_a <= 1'b1;
				data_input_a <= 128'd0;
			end
			else if(current_state == STATE_CLEARING) begin
				if(address_a == 6'd63) begin
					//We are done with the writing:
					write_enable_a <= 1'b0;
				end
				else begin
					address_a <= address_a + 6'd1;
				end
			end
			else if(current_state == STATE_IDLE && scroll_left) begin
				address_a <= 7'd0;
				write_enable_a <= 1'b0;
			end
			else if(current_state == STATE_SCROLLING_LEFT_PREPARING_WRITE) begin
				data_input_a <= data_output_a << (extended_video_mode ? 4 : 2);
				write_enable_a <= 1'b1;
			end
			else if(current_state == STATE_SCROLLING_LEFT_WRITING) begin
				write_enable_a <= 1'b0;
				address_a <= address_a + 6'd1;
			end
			else if(current_state == STATE_IDLE && scroll_right) begin
				address_a <= 7'd0;
				write_enable_a <= 1'b0;
			end
			else if(current_state == STATE_SCROLLING_RIGHT_PREPARING_WRITE) begin
				data_input_a <= data_output_a >> (extended_video_mode ? 4 : 2);
				write_enable_a <= 1'b1;
			end
			else if(current_state == STATE_SCROLLING_RIGHT_WRITING) begin
				write_enable_a <= 1'b0;
				address_a <= address_a + 6'd1;
			end
			else if(current_state == STATE_IDLE && scroll_down) begin
				address_a <= 6'd63 - scroll_down_amount;
				write_enable_a <= 1'b0;
				scroll_amount <= scroll_down_amount;
			end
			else if(current_state == STATE_SCROLLING_DOWN_PREPARING_WRITE) begin
				data_input_a <= data_output_a;
				address_a <= address_a + scroll_amount;
				write_enable_a <= 1'b1;
			end
			else if(current_state == STATE_SCROLLING_DOWN_WRITING) begin
				if(address_a == scroll_amount) begin
					data_input_a <= 128'd0;
					address_a <= address_a - 6'd1;
				end
				else begin
					address_a <= address_a - scroll_amount - 6'd1;
					write_enable_a <= 1'b0;
				end
			end
			else if(current_state == STATE_SCROLLING_DOWN_CLEARING) begin
				if(address_a == 6'd0) begin
					//We are done with the writing:
					write_enable_a <= 1'b0;
				end
				else begin
					address_a <= address_a - 6'd1;
				end
			end
		end
	end
	
	//This ALWAYS block generates the video output, it's clocked at 25MHz and
	//uses the memory port B.
	
	//Used to count the number of screen pixels used for each game pixel in the horizontal axis:
	reg[3:0] pixel_counter_vertical;
	
	//The same as above for the vertical axis:
	reg[3:0] pixel_counter_horizontal;
	
	//Current game pixel we are drawing (row and col):
	reg[5:0] current_row;
	reg[6:0] current_col;
	
	//How many screen pixels we will use for each game pixel:
	wire[3:0] count_to;
	assign count_to = extended_video_mode ? 4'd4 : 4'd9;
	
	//The number of cols:
	wire[6:0] num_cols;
	assign num_cols = extended_video_mode ? 7'd127 : 7'd63;
	
	//The data used to address the memory is the current row:
	assign address_b = current_row;
	
	always @(posedge clk_25mhz, posedge rst) begin
		if(rst) begin
			pixel_counter_vertical <= 4'd0;
			pixel_counter_horizontal <= 4'd0;
			current_row <= 6'd0;
			current_col <= 7'd0;
		end
		else begin
			if(hcount == 10'd640 && vcount == 79) begin
				//If we are about to start our first row, setup our counters:
				pixel_counter_vertical <= 4'd0;
				pixel_counter_horizontal <= 4'd0;
				current_row <= 6'd0;
				current_col <= num_cols;
			end
			else if(hcount == 10'd640 && vcount >= 80 && vcount < 400) begin
				//If we finished drawing a row:
				if(pixel_counter_vertical < count_to) begin
					//If the next VGA row is the next game row:
					pixel_counter_vertical <= pixel_counter_vertical + 4'd1;
				end
				else begin
					//If the next VGA row is the same game row:
					pixel_counter_vertical <= 4'd0;
					current_row <= current_row + 6'd1;
				end
				
				pixel_counter_horizontal <= 4'd0;
				current_col <= num_cols;
			end
			else if(!blank && vcount >= 80 && vcount < 400) begin
				if(pixel_counter_horizontal < count_to) begin
					pixel_counter_horizontal <= pixel_counter_horizontal + 4'd1;
				end
				else begin
					pixel_counter_horizontal <= 4'd0;
					current_col <= current_col - 7'd1;
				end
			end
		end
	end
	
	//Indicates when we are drawing the game screen and not the black screen:
	wire drawing_screen;
	assign drawing_screen = vcount >= 80 && vcount < 400;
	
	//Determines if the current pixel is on or off:
	wire active_pixel;
	assign active_pixel = data_output_b[current_col];
	
	//Generate color signals:
	assign red = !blank && drawing_screen && active_pixel ? 3'b100 :
					 !blank && drawing_screen && !active_pixel ? 3'b001 :
					 3'b000;
	
	assign green = !blank && drawing_screen && active_pixel ? 3'b110 :
					 !blank && drawing_screen && !active_pixel ? 3'b001 :
					 3'b000;
	
	assign blue = !blank && drawing_screen && active_pixel ? 2'b10 :
					 2'b00;
endmodule
