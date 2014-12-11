`timescale 1ns / 1ps

module test_processor;

	// Inputs
	reg clk_100mhz;
	reg clk_25mhz;
	reg rst;
	reg start;
	reg debug_mode;
	reg step;
	reg [3:0] read_reg;
	wire [15:0] mem_read_data;
	wire mem_busy;
	wire colision;
	wire video_busy;
	reg [15:0] key_state;
	reg [3:0] key_decoder;
	reg [15:0] slow_down;

	// Outputs
	wire [15:0] current_ir;
	wire [15:0] current_pc;
	wire [15:0] current_i;
	wire [7:0] reg_val;
	wire stopped;
	wire idle;
	wire mem_read;
	wire mem_write;
	wire [25:0] mem_address;
	wire [15:0] mem_write_data;
	wire extended_video_mode;
	wire [15:0] sprite;
	wire [5:0] draw_row;
	wire [6:0] draw_col;
	wire draw_sprite;
	wire clear_screen;
	wire scroll_left;
	wire scroll_right;
	wire scroll_down;
	wire [3:0] scroll_down_amount;
	wire sound;
	wire [25:0] addr;
	wire mem_oe;
	wire mem_we;
	wire [15:0] mem_data;
	assign mem_data[15:8] = 0;
	
	sram_model simple_ram(
		.addr(addr[9:0]),
		.data(mem_data[7:0]),
		.oe_n(mem_oe),
		.we_n(mem_we)
	);
	
	//Instantiate the memory controller and connect it
	//to the very simple SRAM model:
	memory_controller memory(
		.clk(clk_100mhz),
		.rst(rst),
		.read(mem_read),
		.write(mem_write),
		.address(mem_address),
		.write_data(mem_write_data),
		.read_data(mem_read_data),
		.busy(mem_busy),
		.mem_address(addr),
		.mem_oe(mem_oe),
		.mem_we(mem_we),
		.mem_clk(),
		.mem_adv(),
		.mem_mt_ce(),
		.mem_mt_ub(),
		.mem_mt_lb(),
		.mem_mt_cre(),
		.flash_ce(),
		.data(mem_data)
	);
	
	//Instantiate the video controller:
	video_controller video(
		.clk_100mhz(clk_100mhz),
		.clk_25mhz(clk_25mhz),
		.rst(rst),
		.extended_video_mode(extended_video_mode),
		.sprite(sprite),
		.draw_row(draw_row),
		.draw_col(draw_col),
		.draw_sprite(draw_sprite),
		.clear_screen(clear_screen),
		.scroll_left(scroll_left),
		.scroll_right(scroll_right),
		.scroll_down(scroll_down),
		.scroll_down_amount(scroll_down_amount),
		.colision(colision),
		.busy(video_busy),
		.hs(),
		.vs(),
		.red(),
		.green(),
		.blue()
	);

	// Instantiate the Unit Under Test (UUT)
	chip8_core uut (
		.clk_100mhz(clk_100mhz), 
		.rst(rst), 
		.start(start), 
		.debug_mode(debug_mode), 
		.step(step), 
		.current_ir(current_ir), 
		.current_pc(current_pc), 
		.current_i(current_i), 
		.read_reg(read_reg), 
		.reg_val(reg_val), 
		.stopped(stopped), 
		.idle(idle), 
		.mem_read(mem_read), 
		.mem_write(mem_write), 
		.mem_address(mem_address), 
		.mem_write_data(mem_write_data), 
		.mem_read_data(mem_read_data), 
		.mem_busy(mem_busy), 
		.extended_video_mode(extended_video_mode), 
		.sprite(sprite), 
		.draw_row(draw_row), 
		.draw_col(draw_col), 
		.draw_sprite(draw_sprite), 
		.clear_screen(clear_screen), 
		.scroll_left(scroll_left), 
		.scroll_right(scroll_right), 
		.scroll_down(scroll_down), 
		.scroll_down_amount(scroll_down_amount), 
		.colision(colision), 
		.video_busy(video_busy), 
		.sound(sound), 
		.key_state(key_state), 
		.key_decoder(key_decoder), 
		.slow_down(slow_down)
	);
	
	parameter NUM_DUMPS = 86;
	reg[159:0] dump [0:NUM_DUMPS-1];
	reg[159:0] current_values;
	
	//Generate clocks:
	always begin
		clk_100mhz = 0;
		#5;
		clk_100mhz = 1;
		#5;
	end
	
	always begin
		clk_25mhz = 0;
		#20;
		clk_25mhz = 1;
		#20;
	end

	integer current_inst;
	
	initial begin
		//Read dump file:
		$readmemh("dump.txt", dump);
		
		//Load program to simple RAM model:
		$readmemh("program.txt", simple_ram.sram, 'h200);
		current_inst = 0;
		
		// Initialize Inputs
		rst = 1;

		// Wait 100 ns for global reset to finish
		#100;
      
		//Start the processor:
		rst = 0;
		start = 1;
		
		//Wait until we execute the first instruction and go back
		//to the FETCH state:
		wait(uut.current_state == uut.FETCH_INSTRUCTION);
		wait(uut.current_state != uut.FETCH_INSTRUCTION);
		
		//For each instruction we want to check:
		while(current_inst < NUM_DUMPS) begin
			//Wait until we reach the FETCH state:
			wait(uut.current_state == uut.FETCH_INSTRUCTION);
			
			//Collect the current processor state:
			current_values = {uut.i_reg,
			 uut.registers[0],
			 uut.registers[1],
			 uut.registers[2],
			 uut.registers[3],
			 uut.registers[4],
			 uut.registers[5],
			 uut.registers[6],
			 uut.registers[7],
			 uut.registers[8],
			 uut.registers[9],
			 uut.registers[10],
			 uut.registers[11],
			 uut.registers[12],
			 uut.registers[13],
			 uut.registers[14],
			 uut.registers[15],
			 uut.program_counter};
			 
			//Compare with the expected output:
			if(dump[current_inst] == current_values) begin
				//Everything is fine:
				$display("%t: Instruction %d executed correctly",$time,current_inst);
			end
			else begin
				//Outputs don't match, display some useful information:
				$display("%t: Error on instruction %d",$time,current_inst);
				$display("Expected:");
				$display("%h",dump[current_inst]);
				$display("Found:");
				$display("%h",current_values);
				$display("Instruction: %h",uut.instruction_register);
			end
			
			//Increment our counter:
			current_inst = current_inst + 1;
			
			//Give the processor some time to start
			//executing the next instruction:
			wait(uut.current_state != uut.FETCH_INSTRUCTION);
		end
		$finish;
	end
      
endmodule
