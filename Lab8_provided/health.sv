//This module draws the hearts and calcualtes the remaining health based 
//	on how many hits each tank has taken
module health(
	input logic Clk, Reset_h, 
	input logic hittank1, hittank2,

	input logic is_shot1, is_shot2,

	input logic [9:0] DX, DY,
	output logic [9:0] hp1_drawx, hp1_drawy, hp2_drawx, hp2_drawy, //draw sprite locations 
	output logic [2:0] is_hp1, is_hp2, //drawing signals
	//KEY:	0 = empty heart
	//		1 = half heart
	//		2 = full heart
	//		MSB = Draw Sprite Signal

	output logic Win,
	output logic [3:0] hp1, hp2
	);
	
	parameter [3:0] health_init = 4'd10; //inital health
	parameter [9:0] hp1_tl_x = 10'd10;
	parameter [9:0] hp1_tl_y = 10'd455;
	parameter [9:0] hp2_tl_x = 10'd562; //640 - 10 - 68
	parameter [9:0] hp2_tl_y = 10'd455;
	parameter [9:0] hpwidth = 10'd70;
	parameter [9:0] hpheight = 10'd10;
	//length is 68 pixels, 12*5 + 4*2pixel gap 
	//height is 10 pixels


	logic [3:0] hp_p1; //health for player 1 //records how many hits
	logic [3:0] hp_p2; //health for player 2
	logic done, done_in;
	logic [3:0] hp_p1_in, hp_p2_in;

	assign Win = done;
	assign hp1 = hp_p1;
	assign hp2 = hp_p2;

	//--------------------------------------------------------------------------------------------
	//health state machine------------------------------------------------------------------------
	//State1 and Next_State1 is for player 1
	//State2 etc is for player 2
	//Two state machines for both players so that the hits can register properly
	enum logic {No_Hit, Hit} State1, State2, Next_State1, Next_State2;
	always_ff @(posedge Clk) begin : HIT_STATE_MACHINE
		if(Reset_h) begin
			State1 <= No_Hit;
			State2 <= No_Hit;
		end
		else begin
			State1 <= Next_State1;
			State2 <= Next_State2;
		end
	end

	always_comb begin : nextstatelogic
		unique case(State1)
			No_Hit: begin
				if (hittank1)
					Next_State1 = Hit;
				else
					Next_State1 = No_Hit;
			end
			Hit: begin
				if (~hittank1)
					Next_State1 = No_Hit;
				else
					Next_State1 = Hit;
			end
		endcase

		unique case(State2)
			No_Hit: begin
				if (hittank2)
					Next_State2 = Hit;
				else 
					Next_State2 = No_Hit;
			end
			Hit: begin
				if (~hittank2)
					Next_State2 = No_Hit;
				else
					Next_State2 = Hit;
			end
		endcase
	end
	//--------------------------------------------------------------------------------------------
	//--------------------------------------------------------------------------------------------

	always_ff @(posedge Clk) begin 
		if(Reset_h) begin
			hp_p2 <= health_init;
			hp_p1 <= health_init;
			done <= 1'b0;
		end 
		else begin
			hp_p1 <= hp_p1_in;
			hp_p2 <= hp_p2_in;
			done <= done_in;
		end
	end

	always_comb begin : CALUCULATE_HIT
		//default, keep everything same
		done_in = done;
		hp_p2_in = hp_p2;
		hp_p1_in = hp_p1;
		if ((hp_p1 == 4'd0) || (hp_p2 == 4'd0))
			done_in = 1'b1;
		
		case(State1)
			No_Hit: begin //if you hit tank1 (and tank2 shot the bullet)
				if (hp_p1 == 4'd0)
					done_in = 1'b1;
				else if (hittank1 && is_shot2) begin
					if (hp_p1 == 4'd0) //if hp is one or less, game over
						done_in = 1'b1;
					else 
						hp_p1_in = hp_p1 - 4'd1;
				end
			end
			Hit: ; //Do nothing
		endcase // State1

		case(State2)
			No_Hit: begin
				if (hp_p1 == 4'd0)
					done_in = 1'b1;
				else if (hittank2 && is_shot1) begin
					if (hp_p2 == 4'd0) //same as above
						done_in = 1'b1;
					else 
						hp_p2_in = hp_p2 - 4'd1;
				end
			end
			Hit: ; //Do nothing
		endcase


		//if you hit tank1 (and tank2 shot the bullet)
		// if (hittank1 && ~hittank2 && is_shot2) begin
		// 	if (hp_p1 == 4'd0) //if hp is one or less, game over
		// 		done_in = 1'b1;
		// 	else 
		// 		hp_p1_in = hp_p1 - 4'd1;
		// end

		//if you hit tank2 (and if tank1 shot the bullet)
		// if (hittank2 && ~hittank1 && is_shot1) begin
		// 	if (hp_p2 == 4'd0) //same as above
		// 		done_in = 1'b1;
		// 	else 
		// 		hp_p2_in = hp_p2 - 4'd1;
		// end

		//if you hit both tanks at the same time -- VERY UNLIKELY NOT IMPLEMENTED
		// else if (hittank1 && hittank2 && is_shot2 && is_shot1) begin
		// 	if ((hp_p2 == 4'd0) || (hp_p1 == 4'd0))
		// 		done_in = 1'b1;
		// 	else begin
		// 		hp_p2_in = hp_p2 - 4'd1;
		// 		hp_p1_in = hp_p1 - 4'd1;
		// 	end
		// end
		//if you don't hit anything, revert to default signals above
	end // CALCULATE_HIT


	//positions relative to top left corners
	int DrawX1, DrawY1, DrawX2, DrawY2;
	assign DrawX1 = DX - hp1_tl_x; 
	assign DrawY1 = DY - hp1_tl_y;
	assign DrawX2 = DX - hp2_tl_x;
	assign DrawY2 = DY - hp2_tl_y;

	assign hp1_drawx = DrawX1%14;
	assign hp2_drawx = DrawX2%14;
	assign hp1_drawy = DrawY1;
	assign hp2_drawy = DrawY2;

	logic in_heart_1, in_heart_2;
	assign in_heart_1 = ((DX >= hp1_tl_x) && (DX <= hp1_tl_x + hpwidth) && (DY >= hp1_tl_y) && (DY <= hp1_tl_y + hpheight)) ? 1'b1 : 1'b0;
	assign in_heart_2 = ((DX >= hp2_tl_x) && (DX <= hp2_tl_x + hpwidth) && (DY >= hp2_tl_y) && (DY <= hp2_tl_y + hpheight)) ? 1'b1 : 1'b0;
	always_comb begin : DRAWING 
		//default signal
		is_hp1 = 3'd0;
		is_hp2 = 3'd0;

		if (in_heart_1) begin
			is_hp1[2] = 1'b1; //player 1 sprite signal
			case (hp_p1)
				4'd0:
					is_hp1[1:0] = 2'd0;
				4'd1: begin
					if (DrawX1 >= 0 && DrawX1 < 14)
						is_hp1[1:0] = 2'd1;
					else
						is_hp1[1:0] = 2'd0;
				end
				4'd2: begin
					if (DrawX1 >= 14)
						is_hp1[1:0] = 2'd0;
					else
						is_hp1[1:0] = 2'd2;
				end

				4'd3: begin
					if (DrawX1 >= 14 && DrawX1 < 28)
						is_hp1[1:0] = 2'd1;
					else if (DrawX1 >= 28)
						is_hp1[1:0] = 2'd0;
					else
						is_hp1[1:0] = 2'd2;
				end
				4'd4: begin
					if (DrawX1 >= 28)
						is_hp1[1:0] = 2'd0;
					else
						is_hp1[1:0] = 2'd2;
				end
				4'd5: begin
					if (DrawX1 >= 28 && DrawX1 < 42)
						is_hp1[1:0] = 2'd1;
					else if (DrawX1 >= 42)
						is_hp1[1:0] = 2'd0;
					else 
						is_hp1[1:0] = 2'd2;
				end
				4'd6: begin
					if (DrawX1 >= 42)
						is_hp1[1:0] = 2'd0;
					else 
						is_hp1[1:0] = 2'd2;
				end
				4'd7: begin 
					if (DrawX1 >= 42 && DrawX1 < 56)
						is_hp1[1:0] = 2'd1;
					else if (DrawX1 >= 56)
						is_hp1[1:0] = 2'd0;
					else
						is_hp1[1:0] = 2'd2;
				end
				4'd8: begin //last heart is fully gone
					if (DrawX1 >= 56)
						is_hp1[1:0] = 2'd0;
					else
						is_hp1[1:0] = 2'd2; 
				end
				4'd9: begin //last heart is half
					if (DrawX1 >= 56)
						is_hp1[1:0] = 2'd1;
					else
						is_hp1[1:0] = 2'd2;
				end
				4'd10: is_hp1[1:0] = 2'd2; //all hearts are full
			endcase
		end
		else if (in_heart_2) begin
			is_hp2[2] = 1'b1;
			case (hp_p2)
				4'd0:
					is_hp2[1:0] = 2'd0;
				4'd1: begin
					if (DrawX2 >= 0 && DrawX2 < 14)
						is_hp2[1:0] = 2'd1;
					else
						is_hp2[1:0] = 2'd0;
				end
				4'd2: begin
					if (DrawX2 >= 14)
						is_hp2[1:0] = 2'd0;
					else
						is_hp2[1:0] = 2'd2;
				end

				4'd3: begin
					if (DrawX2 >= 14 && DrawX2 < 28)
						is_hp2[1:0] = 2'd1;
					else if (DrawX2 >= 28)
						is_hp2[1:0] = 2'd0;
					else
						is_hp2[1:0] = 2'd2;
				end
				4'd4: begin
					if (DrawX2 >= 28)
						is_hp2[1:0] = 2'd0;
					else
						is_hp2[1:0] = 2'd2;
				end
				4'd5: begin
					if (DrawX2 >= 28 && DrawX2 < 42)
						is_hp2[1:0] = 2'd1;
					else if (DrawX2 >= 42)
						is_hp2[1:0] = 2'd0;
					else 
						is_hp2[1:0] = 2'd2;
				end
				4'd6: begin
					if (DrawX2 >= 42)
						is_hp2[1:0] = 2'd0;
					else 
						is_hp2[1:0] = 2'd2;
				end
				4'd7: begin 
					if (DrawX2 >= 42 && DrawX2 < 56)
						is_hp2[1:0] = 2'd1;
					else if (DrawX2 >= 56)
						is_hp2[1:0] = 2'd0;
					else
						is_hp2[1:0] = 2'd2;
				end
				4'd8: begin //last heart is fully gone
					if (DrawX2 >= 56)
						is_hp2[1:0] = 2'd0;
					else
						is_hp2[1:0] = 2'd2; 
				end
				4'd9: begin //last heart is half
					if (DrawX2 >= 56)
						is_hp2[1:0] = 2'd1;
					else
						is_hp2[1:0] = 2'd2;
				end
				4'd10: is_hp2[1:0] = 2'd2; //all hearts are full
			endcase
		end
	end


endmodule // health