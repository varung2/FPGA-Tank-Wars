module pickup_gen (
		input Clk, Reset_h,
		input [9:0] Tank1X, Tank1Y, //Tank size is the half-width of the sprite
		input [9:0] Tank2X, Tank2Y, 
		input Gen,

		output tank1pick, tank2pick, //which tank picks it up first

		input [9:0] DrawX, DrawY,
		output [20:0] pickup
	);
	
	parameter [9:0] number_obstacles = 1;

	logic [9:0] randx, randy;
	random #(.seed(10'd594)) genx(.*, .out(randx));
	random #(.seed(10'd99)) geny(.*, .out(randy));
	
	logic regen;
	pickup(.*, .x_init(tl_obj_x[0]), .y_init(tl_obj_y[0]));


	logic finish, finish_in;
	logic [9:0] objcounter, obj_in;
	logic [9:0] tl_obj_x[number_obstacles];
	logic [9:0] tl_obj_y[number_obstacles];
	always_ff @(posedge Clk) begin : Counter
		if (Reset_h || tank1pick || tank2pick) begin
			objcounter <= 0;
			finish <= 0;
		end
		else begin
			objcounter <= obj_in;
			finish <= finish_in;
		end
	end
	always_comb begin : POSITION
		//default signals
		obj_in = objcounter;
		tl_obj_x[objcounter] = 7'd0;
		tl_obj_y[objcounter] = 7'd0;
		finish_in = finish;
		regen = 0;
		if (~finish || Gen) begin
			regen = 1;
			if ((randx[8:0] > 0) && (randy[8:0] > 0) && (randx[8:0] < 640) && (randy[8:0] < 480) && (~finish)) begin
				tl_obj_x[objcounter] = randx[8:0];
				tl_obj_y[objcounter] = randy[8:0];
				obj_in = objcounter + 1;
			end
			else begin
				obj_in = objcounter;
				tl_obj_x[objcounter] = 7'd0;
				tl_obj_y[objcounter] = 7'd0;
			end
			
			//logic for finish
			if (objcounter >= number_obstacles)
				finish_in = 1;
			else
				finish_in = 0;
		end
	end




endmodule // pickup_gen
