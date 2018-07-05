module Skynet(			input logic Clk,
						input logic [9:0] Tank1X, Tank1Y,
						input logic [9:0] Tank2X, Tank2Y,
						output logic ai_w, ai_a, ai_s, ai_d, //0 = U, 1 = R, 2 = D, 3 = L
						output logic ai_shoot
					  );

	parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd429;     // Bottommost point on the Y axis
	




    //TANK1 IS THE AI
	logic [1:0] dir_in;
	int distance;

	//TANK1 IS THE AI
	always_comb begin
		ai_w = 0;
		ai_a = 0;
		ai_s = 0;
		ai_d = 0;

		ai_shoot = 1'b1;
		distance = (Tank1Y - Tank2Y)*(Tank1Y - Tank2Y) + (Tank1X - Tank2X)*(Tank1X - Tank2X);


		if (distance > 361) begin
			//Wall avoidance mechanism
			if (Tank1Y + 10 > Ball_Y_Max) //if it hits the bottom boundary, move right
				ai_w = 1'b1;
			else if (/*cur_motion == 2'd1 && */Tank1X + 10 > Ball_X_Max) //right boundary, move down
				ai_a = 1'b1;
			else if (/*cur_motion == 2'd0 && */Tank1Y < Ball_Y_Min + 10) //top boundary, move left
				ai_s = 1'b1;
			else if (/*cur_motion == 2'd3 && */Tank1X < Ball_X_Min + 10) //left boundary, move up
				ai_d = 1'b1;
			else begin 
				//Follow the player
				if (Tank1X >= Tank2X + 8)
					ai_a = 1'b1; //move left
				else if (Tank1X + 8 < Tank2X)
					ai_d = 1'd1; //move right
				else if (Tank1Y >= Tank2Y + 8)
					ai_w = 1'd1; //move up
				else if (Tank1Y + 8 < Tank2Y)
					ai_s = 1'd1; //move down
			end // else
		end
	end // always_comb
	
endmodule // Skynet