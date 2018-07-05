module obstacle( 	
					input Clk, Reset_h,
					//TankX and TankY are the center coordiantes of the tank
					input [9:0] Tank1X, Tank1Y, //Tank size is the half-width of the sprite
					input [9:0] Tank2X, Tank2Y, 
					output logic is_obst,
					output logic is_obst_2,
					output logic hitobj1, hitobj2,

					input [9:0] p1_BullX, p1_BullY, p2_BullX, p2_BullY,

					//x and y positions
					input [9:0] x_init, y_init,


					// input is valid,
					output done_out,

					input [9:0] DrawX, DrawY,
					output [20:0] obst
					);
	
	parameter [9:0] seedx = 10'b0000101111; //change these when you instantiate it
	parameter [9:0] seedy = 10'b1010111111;

	logic [9:0] offset;
 	random #(.seed(seedy)) gen(.*, .out(offset));

	parameter [5:0] height = 5'd8;
	parameter [5:0] width = 5'd8;
	parameter [9:0] tl_init_x = 10'd0; 
	parameter [9:0] tl_init_y = 10'd0;
	parameter [9:0] bullhalfsize = 10'd1;
	parameter [9:0] bullwidth = 10'd3;
	parameter [3:0] maxhits = 10;
	parameter [9:0] TankSize = 10'd8;

	logic [9:0] tl_corner_y, tl_corner_x;
	logic [9:0] tl_corner_y_in, tl_corner_x_in;


	logic en;
	assign en = (hitcounter >= maxhits) ? 1'b0 : 1'b1;

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

	assign hitcount = hitcounter;
	logic [3:0] hitcounter, hitcounter_in;
	enum logic [1:0] {Hit, Hit_1, Not_Hit} State, Next_State;
	always_ff @(posedge Clk) begin
		if (Reset_h) begin
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
				if ((~hitobj1) && (~hitobj2))
					Next_State = Not_Hit;
				else
					Next_State = Hit_1;
			end
			Not_Hit: begin
				if (hitobj1 || hitobj2)
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

	always_comb begin : BULLET_COLLISION
		hitobj1 = 1'b0;
		hitobj2 = 1'b0;
		if (en) begin
			if ((p1_BullX < tl_corner_x + width + bullhalfsize) && (p1_BullX + bullhalfsize >= tl_corner_x) &&
				(p1_BullY < tl_corner_y + height + bullhalfsize) && (p1_BullY + bullhalfsize >= tl_corner_y))
				hitobj1 = 1'b1;
			else
				hitobj1 = 1'b0;

			if ((p2_BullX < tl_corner_x + width + bullhalfsize) && (p2_BullX + bullhalfsize >= tl_corner_x) && 
				(p2_BullY < tl_corner_y + height + bullhalfsize) && (p2_BullY + bullhalfsize >= tl_corner_y))
				hitobj2 = 1'b1;
			else 
				hitobj2 = 1'b0;
		end
	end

	always_comb begin : TANK_COLLISION
		is_obst = 1'b0;
		is_obst_2 = 1'b0;
		if (en) begin
			//if Tank1 hits obst, is_obst is 1
			if ((Tank1X <= tl_corner_x + width + TankSize) && (Tank1X + TankSize >= tl_corner_x) && 
				(Tank1Y <= tl_corner_y + height + TankSize) && (Tank1Y + TankSize >= tl_corner_y))
				is_obst = 1'b1;
			else 
				is_obst = 1'b0;

			//same thing for Tank2
			if ((Tank2X <= tl_corner_x + width + TankSize) && (Tank2X + TankSize >= tl_corner_x) && 
				(Tank2Y <= tl_corner_y + height + TankSize) && (Tank2Y + TankSize >= tl_corner_y))
				is_obst_2 = 1'b1;
			else 
				is_obst_2 = 1'b0;
		end
	end

	always_comb begin : DRAWING	
		obst[20] = 1'b0;
		if (en) begin
			if (DrawX < tl_corner_x + width && DrawX >= tl_corner_x && DrawY < tl_corner_y + height && DrawY >= tl_corner_y)	 
				obst[20] = 1'b1;
			else 
				obst[20] = 1'b0;
		end
	end

	assign obst[19:10] = DrawX - tl_corner_x;
	assign obst[9:0] = DrawY - tl_corner_y;

endmodule 
