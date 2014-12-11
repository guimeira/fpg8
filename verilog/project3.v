`timescale 1ns / 1ps

module project3(
	input clk_board,
	input rst,
	//VGA signals:
	output hsync,
	output vsync,
	output[2:0] red,
	output[2:0] green,
	output[1:0] blue,
	//Memory signals:
	output[25:0] addr,
	output mem_oe,
	output mem_we,
	output mem_clk,
	output mem_adv,
	output mem_mt_ce,
	output mem_mt_ub,
	output mem_mt_lb,
	output mem_mt_cre,
	output flash_ce,
	inout[15:0] mem_data,
	//DAC signals:
	output dac_clk,
	output dac_sync,
	output dac_data,
	//UART signals:
	input rx,
	output tx
);

//DCM instantiation:
wire clk_100mhz;
wire clk_25mhz;
dcm_25 instance_name(
	.CLK_IN1(clk_board),
	.CLK_OUT1(clk_100mhz),
	.CLK_OUT2(clk_25mhz),
	.RESET(rst)
);

//Video controller instantiation:
wire extended_video_mode;
wire[15:0] sprite;
wire[5:0] draw_row;
wire[6:0] draw_col;
wire draw_sprite;
wire clear_screen;
wire scroll_left;
wire scroll_right;
wire scroll_down;
wire[3:0] scroll_down_amount;
wire colision;
wire video_busy;
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
	.hs(hsync),
	.vs(vsync),
	.red(red),
	.green(green),
	.blue(blue)
);

//Memory controller instantiation:
wire mem_read;
wire mem_write;
assign mem_write = !idle ? chip8_mem_write : microblaze_mem_write;
wire[25:0] mem_address;
assign mem_address = !idle ? chip8_mem_address : {14'd0,gpo1[19:8]};
wire[15:0] mem_write_data;
assign mem_write_data = !idle ? chip8_mem_write_data : {8'd0,gpo1[7:0]};
wire[15:0] mem_read_data;
wire mem_busy;
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
	.mem_clk(mem_clk),
	.mem_adv(mem_adv),
	.mem_mt_ce(mem_mt_ce),
	.mem_mt_ub(mem_mt_ub),
	.mem_mt_lb(mem_mt_lb),
	.mem_mt_cre(mem_mt_cre),
	.flash_ce(flash_ce),
	.data(mem_data)
);

//Input controller instantiation:
wire[15:0] key_state;
wire[3:0] key_decoder;
input_controller keyboard(
	.keyboard(gpo2[15:0]),
	.key_state(key_state),
	.output_decoder(key_decoder)
);

//Microblaze instantiation:
wire[31:0] gpo1;
wire[31:0] gpo2;
wire[31:0] gpi1;
assign gpi1[0] = mem_busy;
wire[31:0] gpi2;
microblaze_mcs mcs_0 (
	.Clk(clk_100mhz),
	.Reset(rst),
	.UART_Rx(rx),
	.UART_Tx(tx),
	.GPO1(gpo1),
	.GPO2(gpo2),
	.GPI1(gpi1),
	.GPI1_Interrupt(),
	.GPI2(gpi2),
	.GPI2_Interrupt()
);

//Make a one-cycle pulse out of Microblaze's mem_write,
//to make sure it won't write to the memory more than once:
wire microblaze_mem_write;
assign microblaze_mem_write = shift_reg == 2'b10;
reg[1:0] shift_reg;
always @(posedge clk_100mhz, posedge rst) begin
	if(rst) begin
		shift_reg <= 2'd0;
	end
	else begin
		shift_reg <= {gpo1[20],shift_reg[1]};
	end
end

//Sound controller instantiation:
wire sound;
wire dac_clk;
wire dac_sync;
wire dac_data;
sound_controller sound_control(
	.clk(clk_100mhz),
	.rst(rst),
	.sound(sound),
	.dac_clk(dac_clk),
	.dac_sync(dac_sync),
	.dac_data(dac_data)
);

//Chip-8 core instantiation:
wire start;
assign start = gpo1[21];
wire chip8_mem_write;
wire[25:0] chip8_mem_address;
wire[15:0] chip8_mem_write_data;
wire debug_mode;
assign debug_mode = gpo1[27];
wire debug_step;
assign debug_step = gpo1[22];
wire[15:0] current_ir;
assign gpi2[15:0] = current_ir;
assign gpi2[31:16] = current_pc;
wire[15:0] current_pc;
wire debug_stopped;
wire idle;
assign gpi1[1] = debug_stopped;
wire[3:0] debug_read_reg;
assign debug_read_reg = gpo1[26:23];
wire [7:0] debug_reg_val;
assign gpi1[9:2] = debug_reg_val;
wire[15:0] debug_current_i;
assign gpi1[26:10] = debug_current_i;
chip8_core core(
	.clk_100mhz(clk_100mhz),
	.rst(rst),
	.start(start),
	.debug_mode(debug_mode),
	.step(debug_step),
	.current_ir(current_ir),
	.current_pc(current_pc),
	.current_i(debug_current_i),
	.read_reg(debug_read_reg),
	.reg_val(debug_reg_val),
	.stopped(debug_stopped),
	.idle(idle),
	.mem_read(mem_read),
	.mem_write(chip8_mem_write),
	.mem_address(chip8_mem_address),
	.mem_write_data(chip8_mem_write_data),
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
	.slow_down(gpo2[31:16])
);
endmodule
