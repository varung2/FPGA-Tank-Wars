module pickup(
		input Clk, Reset_h,
		input [9:0] Tank1X, Tank1Y, //Tank size is the half-width of the sprite
		input [9:0] Tank2X, Tank2Y, 

		output tank1pick, tank2pick, //which tank picks it up first

		input regen,
		input [9:0] x_init, y_init,

		input [9:0] DrawX, DrawY,
		output [20:0] pickup
	);


	logic [9:0] tl_corner_x, tl_corner_y;

	logic [9:0] offset;
	random #(.seed(10'd777)) gen(.*, .out(offset));

	parameter [9:0] dim = 10'd16; //dimensions of the sprite
	parameter [9:0] maxhits = 10'd1;
	parameter [9:0] TankSize = 10'd8;
	//Sprite starts at 176, 209

	always_comb begin
		if (x_init < 12 && y_init < 12) begin
			tl_corner_x = (x_init + 20 + (offset%40)); //multiply by 8 to get a valid coordinate
			tl_corner_y = (y_init + 20 + (offset%90));
		end
		else begin
			tl_corner_x = x_init;
			tl_corner_y = y_init;
		end
	end

	assign done_out = ((x_init == 0) && (y_init == 0)) ? 0 : 1;


	always_comb begin : TANK_COLLISION
		tank1pick = 1'b0;
		tank2pick = 1'b0;
		if (en) begin
			//if Tank1 hits obst, tank1pick is 1
			if ((Tank1X <= tl_corner_x + dim + TankSize) && (Tank1X + TankSize >= tl_corner_x) && 
				(Tank1Y <= tl_corner_y + dim + TankSize) && (Tank1Y + TankSize >= tl_corner_y))
				tank1pick = 1'b1;
			else 
				tank1pick = 1'b0;

			//same thing for Tank2
			if ((Tank2X <= tl_corner_x + dim + TankSize) && (Tank2X + TankSize >= tl_corner_x) && 
				(Tank2Y <= tl_corner_y + dim + TankSize) && (Tank2Y + TankSize >= tl_corner_y))
				tank2pick = 1'b1;
			else 
				tank2pick = 1'b0;
		end
	end


	logic en;
	assign en = (hitcounter >= maxhits) ? 1'b0 : 1'b1;

	assign hitcount = hitcounter;
	logic [3:0] hitcounter, hitcounter_in;
	enum logic [1:0] {Hit, Hit_1, Not_Hit} State, Next_State;
	always_ff @(posedge Clk) begin
		if (Reset_h || regen) begin
			State <= Not_Hit;
			hitcounter <= 0;
		end
		else begin
			State <= Next_State;
			hitcounter <= hitcounter_in;
		end
	end
	always_comb begin : NEXT_STATE_LOGIC
		unique case(State)
			Hit: Next_State = Hit_1;
			Hit_1: begin
				if ((~tank1pick) && (~tank2pick))
					Next_State = Not_Hit;
				else
					Next_State = Hit_1;
			end
			Not_Hit: begin
				if (tank1pick || tank2pick)
					Next_State = Hit;
				else
					Next_State = Not_Hit;
			end
		endcase // State
	end
	always_comb begin : RECORD_HIT
		hitcounter_in = hitcounter;
		case(State)
			Hit: hitcounter_in = hitcounter + 1;
			default: ; //do nothing for the others
		endcase
	end

	always_comb begin : DRAWING	
		pickup[20] = 1'b0;
		if (en) begin
			if (DrawX < tl_corner_x + dim && DrawX >= tl_corner_x && DrawY < tl_corner_y + dim && DrawY >= tl_corner_y)	 
				pickup[20] = 1'b1;
			else 
				pickup[20] = 1'b0;
		end
	end

	assign pickup[19:10] = DrawX - tl_corner_x;
	assign pickup[9:0] = DrawY - tl_corner_y;

endmodule // pickup
