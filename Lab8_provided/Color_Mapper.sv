	//-------------------------------------------------------------------------
	//    Color_Mapper.sv                                                    --
	//    Stephen Kempf                                                      --
	//    3-1-06                                                             --
	//                                                                       --
	//    Modified by David Kesler  07-16-2008                               --
	//    Translated by Joe Meng    07-07-2013                               --
	//    Modified by Po-Han Huang  10-06-2017                               --
	//                                                                       --
	//    Fall 2017 Distribution                                             --
	//                                                                       --
	//    For use with ECE 385 Lab 8                                         --
	//    University of Illinois ECE Department                              --
	//-------------------------------------------------------------------------

	//SIZE OF TANK IS 16x16 PIXELS
		
	// color_mapper: Decide which color to be output to VGA for each pixel.
	module  color_mapper ( 		input Clk, Reset_h,
								input [9:0] first_X, first_Y, //center position on the first sprite
								input [9:0] second_X, second_Y, //center position on the second sprite
								input [1:0] first_dir, second_dir, //directions of each sprite
								input       is_ball_1, is_ball_2,
								input [20:0] obst,        // Whether current pixel belongs to ball             	 
								input press1, press2, anim_1,

								input [7:0] SW, //for animation from the input switches
								input [3:0] KEY,

								//Bullet signals
								input [9:0] p1_bullspx, p1_bullspy, p2_bullspx, p2_bullspy,
								input logic p1_bullet, p2_bullet,
								input [1:0] p1_bulldir, p2_bulldir,

								//healthbar signals
								input [9:0] hp1_drawx, hp1_drawy, hp2_drawx, hp2_drawy,
								input [2:0] is_hp1, is_hp2,

								//pickup signal
								input logic [20:0] pickup,

								input [9:0] DrawX, DrawY,       // Current pixel coordinates

								input [2:0] tilenum,
								input logic Start_sig, Done_sig,

								output logic [7:0] VGA_R, VGA_G, VGA_B, // VGA RGB output
								
								output logic ai_enable,
								input a, d
								);
		
		//ministatemachine for selecting ai
		enum logic {Single, Multipl} Status, NextStat;
		always_ff @(posedge Clk) begin
			if (Reset_h) Status <= Multipl;
			else Status <= NextStat;
		end
		always_comb begin : NEXT_STATE_LOGIC
			unique case (Status)
				Single: begin
					if ((d || ~KEY[1]) && Start_sig) NextStat = Multipl;
					else NextStat = Single;
				end
				Multipl: begin
					if ((a || ~KEY[2]) && Start_sig) NextStat = Single;
					else NextStat = Multipl;
				end
			endcase // Status
		end
		always_comb begin : CONTROL
			case (Status)
				Single: ai_enable = 1;
				Multipl: ai_enable = 0;
			endcase // Status
		end // CONTROL
		//Title dimensions
		parameter [9:0] Title_TL_X = 320 - 94;
		parameter [9:0] Title_TL_Y = 84;
		parameter [9:0] Title_BR_X = 320 + 94;
		parameter [9:0] Title_BR_Y = 84 + 60;
		logic DrawTitle;
		assign DrawTitle = (Start_sig && (DrawX >= Title_TL_X && DrawX < Title_BR_X && DrawY >= Title_TL_Y && DrawY < Title_BR_Y));

		//Player dimensions (43x9) //Number dimensions (8x9)
		parameter [9:0] Number1_TL_X = 320 - 65;
		parameter [9:0] Number1_TL_Y = 240 + 21;
		parameter [9:0] Number1_BR_X = 320 - 65 + 8;
		parameter [9:0] Number1_BR_Y = 240 + 21 + 9;

		parameter [9:0] Number2_TL_X = 320 + 10;
		parameter [9:0] Number2_TL_Y = 240 + 20;
		parameter [9:0] Number2_BR_X = 320 + 10 + 8;
		parameter [9:0] Number2_BR_Y = 240 + 20 + 9;

		parameter [9:0] SinglePlayer_TL_X = 320 - 53;
		parameter [9:0] SinglePlayer_TL_Y = 240 + 21;
		parameter [9:0] SinglePlayer_BR_X = 320 - 10;
		parameter [9:0] SinglePlayer_BR_Y = 240 + 21 + 9;

		parameter [9:0] MultiPlayer_TL_X = 320 + 22;
		parameter [9:0] MultiPlayer_TL_Y = 240 + 21;
		parameter [9:0] MultiPlayer_BR_X = 320 + 65;
		parameter [9:0] MultiPlayer_BR_Y = 240 + 21 + 9;

		logic DrawNum1, DrawNum2, DrawSingle, DrawMulti, DrawSelection;
		assign DrawSelection = (DrawNum1 || DrawNum2 || DrawSingle || DrawMulti || 0);
		assign DrawNum1		= (Start_sig && (DrawX >= Number1_TL_X && DrawX < Number1_BR_X && DrawY > Number1_TL_Y && DrawY < Number1_BR_Y));
		assign DrawNum2 	= (Start_sig && (DrawX >= Number2_TL_X && DrawX < Number2_BR_X && DrawY > Number2_TL_Y && DrawY < Number2_BR_Y));
		assign DrawSingle 	= (Start_sig && (DrawX >= SinglePlayer_TL_X && DrawX < SinglePlayer_BR_X && DrawY > SinglePlayer_TL_Y && DrawY < SinglePlayer_BR_Y));
		assign DrawMulti 	= (Start_sig && (DrawX >= MultiPlayer_TL_X && DrawX < MultiPlayer_BR_X && DrawY > MultiPlayer_TL_Y && DrawY < MultiPlayer_BR_Y));

		//"PRESS START" dimensions: (56x20)
		parameter [9:0] Start_TL_X = 320 - 29; //Top left X
		parameter [9:0] Start_TL_Y = 240 - 11;
		parameter [9:0] Start_BR_Y = 240 + 11; //Bottom Right Y
		parameter [9:0] Start_BR_X = 320 + 29;

		//"GAME OVER" dimensions: (124x60)
		parameter [9:0] Done_TL_X = 320 - 62;
		parameter [9:0] Done_TL_Y = 240 - 30;
		parameter [9:0] Done_BR_Y = 240 + 30;
		parameter [9:0] Done_BR_X = 320 + 62;

		logic [7:0] Red, Green, Blue;
		logic DrawStart, DrawFinish; //Draws the "Press Start" and "Game Over" sprites
		// Output colors to VGA
		assign VGA_R = Red;
		assign VGA_G = Green;
		assign VGA_B = Blue;
		
		assign DrawStart = (Start_sig && (DrawX >= Start_TL_X && DrawX < Start_BR_X && DrawY >= Start_TL_Y && DrawY < Start_BR_Y));
		assign DrawFinish = (Done_sig && (DrawX >= Done_TL_X && DrawX < Done_BR_X && DrawY >= Done_TL_Y && DrawY < Done_BR_Y));
		
		assign DrawCut = (DrawStart || DrawFinish || DrawTitle);
		//for final project
		logic [15:0] ocm, addr;
		logic [4:0] color, back, vgaout;
		logic obstacle;
		assign obstacle = obst[20];
		
		logic drawbullet;
		assign drawbullet = (p1_bullet || p2_bullet);

		logic [1:0] hp1type, hp2type;
		logic hp1, hp2;
		assign hp1 = is_hp1[2];
		assign hp2 = is_hp2[2];
		assign hp1type = is_hp1[1:0];
		assign hp2type = is_hp2[1:0];

		//This chooses the background color from the second sprite sheet
		//	-> incase the first color is 0 or the background.
		always_comb begin : BACKGROUND_ADDR
			case (tilenum)
				3'd1: addr = (DrawX%8) + 40 + (((DrawY%8) + 96) << 8); 
				3'd2: addr = (DrawX%8) + 40 + (((DrawY%8) + 104) << 8);
				3'd3: addr = (DrawX%8) + 24 + (((DrawY%8) + 96) << 8);
				3'd4: addr = (DrawX%8) + 32 + (((DrawY%8) + 104) << 8);
				3'd5: addr = (DrawX%8) + 32 + (((DrawY%8) + 96) << 8); //stone tile
				default : addr = 24 + ((96) << 8); //default green background color
			endcase		
		end

		logic drawsp;
		always_comb
		begin
			//default ocm signal
			ocm = 0;

			if (is_ball_1 && ~is_ball_2  && ~obstacle && ~DrawCut && ~DrawSelection) begin
				drawsp = 1;
					if (press1  || SW[0] || SW[1] || SW[2] || SW[3]) begin : PLAYER_1_KEYPRESS
						if (anim_1) begin : ANIMATION
							case(first_dir) //chooses the direction
								2'd0: ocm = first_X + 16 + ((first_Y+112) << 8); //facing up
								2'd1: ocm = first_X + 32 + 16 + ((first_Y+112) << 8); //right
								2'd2: ocm = first_X + 64 + 16 + ((first_Y+112) << 8); //down
								2'd3: ocm = first_X + 96 + 16 + ((first_Y+112) << 8); //left
							endcase
						end
						else begin
							case(first_dir) //chooses the direction
								2'd0: ocm = first_X + ((first_Y+112) << 8);
								2'd1: ocm = first_X + 32 + ((first_Y+112) << 8);
								2'd2: ocm = first_X + 64 + ((first_Y+112) << 8);
								2'd3: ocm = first_X + 96 + ((first_Y+112) << 8);
							endcase
						end
					end

					else begin
						case(first_dir) //chooses the direction
							2'd0: ocm = first_X + ((first_Y+112) << 8);
							2'd1: ocm = first_X + 32 + ((first_Y+112) << 8);
							2'd2: ocm = first_X + 64 + ((first_Y+112) << 8);
							2'd3: ocm = first_X + 96 + ((first_Y+112) << 8);
						endcase
					end
			end
			else if (is_ball_2 && ~obstacle && ~DrawCut && ~DrawSelection) begin //Draw the second tank over the first tank
				drawsp = 1;
				if (press2 || SW[4] || SW[5] || SW[6] || SW[7]) begin : PLAYER_2_KEYPRESS
						if (anim_1) begin : ANIMATION
							case(second_dir) //chooses the direction
								2'd0: ocm = second_X + 16 + ((second_Y+160) << 8);
								2'd1: ocm = second_X + 31 + 16 + ((second_Y+161) << 8);
								2'd2: ocm = second_X + 64 + 16 + ((second_Y+160) << 8);
								2'd3: ocm = second_X + 96 + 16 + ((second_Y+161) << 8);
							endcase
						end
						else begin
							case(second_dir) //chooses the direction
								2'd0: ocm = second_X + ((second_Y+160) << 8);
								2'd1: ocm = second_X + 31 +((second_Y+161) << 8);
								2'd2: ocm = second_X + 64 + ((second_Y+160) << 8);
								2'd3: ocm = second_X + 96 + ((second_Y+161) << 8);
							endcase
						end
					end
				else begin
					case(second_dir) //chooses the direction
						2'd0: ocm = second_X + ((second_Y+160) << 8);
						2'd1: ocm = second_X + 31 +((second_Y+161) << 8);
						2'd2: ocm = second_X + 64 + ((second_Y+160) << 8);
						2'd3: ocm = second_X + 96 + ((second_Y+161) << 8);
					endcase
					end
			end
			else if (drawbullet && ~obstacle && ~DrawCut && ~DrawSelection)
				begin
					drawsp = 1;
					if (p1_bullet && ~p2_bullet /* && ~is_ball_1*/) begin
						case(p1_bulldir) //bullet direction
							2'd0: ocm = p1_bullspx + 53 +((p1_bullspy + 99) << 8);
							2'd1: ocm = p1_bullspx + 61 +((p1_bullspy + 107) << 8);
							2'd2: ocm = p1_bullspx + 53 +((p1_bullspy + 107) << 8);
							2'd3: ocm = p1_bullspx + 61 +((p1_bullspy + 99) << 8);
						endcase
					end
					else begin //draw bullet 2 over bullet 1;
						case(p2_bulldir /* && ~is_ball_2*/) //hide the bullet behind the tank
							2'd0: ocm = p2_bullspx + 53+((p2_bullspy + 99) << 8);
							2'd1: ocm = p2_bullspx + 61+((p2_bullspy + 107) << 8);
							2'd2: ocm = p2_bullspx + 53+((p2_bullspy + 107) << 8);
							2'd3: ocm = p2_bullspx + 61+((p2_bullspy + 99) << 8);
						endcase
					end
				end
			else if (obstacle && ~DrawCut && ~DrawSelection)
				begin
					drawsp = 1;
					ocm = obst[19:10] + 16 + ((obst[9:0] + 96) << 8);
				end
			else if (pickup[20] && ~DrawCut && ~DrawSelection)
				begin
					ocm = pickup[19:10] + 176 + ((pickup[9:0] + 209) << 8);
				end
			else if (DrawStart) 
				begin
					drawsp = 1;
					if (anim_1 == 1)
						ocm = (DrawX - Start_TL_X) + 197 + (((DrawY - Start_TL_Y) + 1) << 8); //calculate ocm addrs for "Press Space to Start..." Sprite
					else
						ocm = (DrawX - Start_TL_X) + 197 + (((DrawY - Start_TL_Y) + 23) << 8);
				end
			else if (DrawTitle)
				ocm = (DrawX - Title_TL_X) + 0 + (((DrawY - Title_TL_Y) + 0) << 8);
			else if (DrawSelection) begin
				if (DrawNum1) ocm = (DrawX - Number1_TL_X) + 189 + (((DrawY - Number1_TL_Y) + 47) << 8);
				else if (DrawNum2) ocm = (DrawX - Number2_TL_X) + 189 + (((DrawY - Number2_TL_Y) + 57) << 8);
				else if (DrawSingle) begin
					if (ai_enable)
						ocm = (DrawX - SinglePlayer_TL_X) + 201 + (((DrawY - SinglePlayer_TL_Y) + 47) << 8);
					else
						ocm = (DrawX - SinglePlayer_TL_X) + 201 + (((DrawY - SinglePlayer_TL_Y) + 57) << 8);
				end
				else if (DrawMulti) begin 
					if (ai_enable)
						ocm = (DrawX - MultiPlayer_TL_X) + 201 + (((DrawY - MultiPlayer_TL_Y) + 57) << 8);
					else
						ocm = (DrawX - MultiPlayer_TL_X) + 201 + (((DrawY - MultiPlayer_TL_Y) + 47) << 8);
				end
			end
			else if (DrawFinish) 
				begin
					drawsp = 1;
					//calculate ocm addrs for "Game Over Screen"
					ocm = (DrawX - Done_TL_X) + 130 + (((DrawY - Done_TL_Y) + 130) << 8);
				end
			else if (hp1 || hp2) begin
				if (hp1) begin
					case(hp1type)
						2'd0: ocm = hp1_drawx + 222 + ((hp1_drawy + 240) << 8);
						2'd1: ocm = hp1_drawx + 208 + ((hp1_drawy + 240) << 8);
						2'd2: ocm = hp1_drawx + 194 + ((hp1_drawy + 240) << 8);
						default: ;
					endcase
				end
				else if (hp2) begin
					case(hp2type)
						2'd0: ocm = hp2_drawx + 222 + ((hp2_drawy + 240) << 8);
						2'd1: ocm = hp2_drawx + 208 + ((hp2_drawy + 240) << 8);
						2'd2: ocm = hp2_drawx + 194 + ((hp2_drawy + 240) << 8);
						default: ;
					endcase
				end
			end
			else begin
				drawsp = 0;
				case (tilenum)
					3'd1: ocm = (DrawX%8) + 40 + (((DrawY%8) + 96) << 8); 
					3'd2: ocm = (DrawX%8) + 40 + (((DrawY%8) + 104) << 8);
					3'd3: ocm = (DrawX%8) + 24 + (((DrawY%8) + 96) << 8);
					3'd4: ocm = (DrawX%8) + 32 + (((DrawY%8) + 104) << 8);
					3'd5: ocm = (DrawX%8) + 32 + (((DrawY%8) + 96) << 8); //stone tile
					default : ocm = 24 + ((96) << 8); //default green background color
				endcase
			end
		end
		

		//UNCOMMENT THIS FOR FINAL PRESENTATION!!!!!!!!!!!!!!!!!!!!!!!!!1
		ROM2 background(.ADDR(addr), .Clk(Clk), .out(back));
		
		ROM sprite_sheet(.ADDR(ocm), .Clk(Clk), .out(color)); //On chip memory rom of the sprite sheet
		 //value of magenta = rgb(255, 0, 255), check so as to do back ground color or something
		 //set this value based on the location calculated for the sram
		

		//assign background color if pink, else draw sprite color
		assign vgaout = (color != 5'd0) ? color : back; //remove this line for transparency
		//assign vgaout = color;
		//Doing the color palette, from piskelapp
		always_comb begin : COLOR_DATA
				unique case(vgaout)
					
					5'd0: begin //background color, dark green
						Red = 8'h00;
						Green = 8'd65;
						Blue = 8'd0;
					end
					
					5'd1:begin //black
						Red = 8'h00;
						Green = 8'd0;
						Blue = 8'd0;
					end
					
					5'd2: begin //white
						Red = 8'hff;
						Green = 8'hff;
						Blue = 8'hff;
					end 
					
					5'd3: begin //grey
						Red = 8'd102;
						Green = 8'd102;
						Blue = 8'd102;
					end
					
					5'd4: begin
						Red = 8'd127;
						Green = 8'd127;
						Blue = 8'd127;
					end
					
					5'd5: begin
						Red = 8'd128;
						Green = 8'd128;
						Blue = 8'd128;
					end
					
					5'd6: begin
						Red = 8'd188;
						Green = 8'd188;
						Blue = 8'd188;
					end
					
					5'd7: begin
						Red = 8'd204;
						Green = 8'd204;
						Blue = 8'd204;
					end
					
					5'd8: begin
						Red = 8'd188;
						Green = 8'd187;
						Blue = 8'd188;
					end
					
					5'd9: begin
						Red = 8'd255;
						Green = 8'd0;
						Blue = 8'd0;
					end
					
					5'd10: begin
						Red = 8'd160;
						Green = 8'd48;
						Blue = 8'd0;
					end
					
					5'd11: begin
						Red = 8'd244;
						Green = 8'd80;
						Blue = 8'd0;
					end
					
					5'd12: begin
						Red = 8'd192;
						Green = 8'd112;
						Blue = 8'd0;
					end
					
					5'd13: begin
						Red = 8'd255;
						Green = 8'd160;
						Blue = 8'd0;
					end
					
					5'd14: begin
						Red = 8'd136;
						Green = 8'd136;
						Blue = 8'd0;
					end
					
					5'd15: begin
						Red = 8'd255;
						Green = 8'd240;
						Blue = 8'd144;
					end
					
					5'd16: begin
						Red = 8'd56;
						Green = 8'd104;
						Blue = 8'd0;
					end
					
					5'd17: begin
						Red = 8'd152;
						Green = 8'd232;
						Blue = 8'd0;
					end
					
					5'd18: begin
						Red = 8'd48;
						Green = 8'd96;
						Blue = 8'd64;
					end
					
					5'd19: begin
						Red = 8'd160;
						Green = 8'd255;
						Blue = 8'd240;
					end
					
					5'd20: begin
						Red = 8'd48;
						Green = 8'd80;
						Blue = 8'd128;
					end
					
					5'd21: begin
						Red = 8'd64;
						Green = 8'd64;
						Blue = 8'd255;
					end
					
					5'd22: begin
						Red = 8'd152;
						Green = 8'd32;
						Blue = 8'd120;
					end
				
				endcase
		end
	endmodule
