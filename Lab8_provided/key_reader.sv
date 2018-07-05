module key_reader(
			input logic [31:0] keyc,
			output logic w_on, a_on, s_on, d_on,
			output logic lef_on, rig_on, up_on, dow_on,
			output logic pl_1shoot, pl_2shoot,
			output logic press1, press2,
			output logic enter
			);	
			
	assign press1 = (w_on || a_on || s_on || d_on);
	assign press2 = (lef_on || rig_on || up_on || dow_on);
		

	//Checking the WASD keys //for player one
	assign w_on = (keyc[31:24] == 8'h1A |
						keyc[23:16] == 8'h1A |
						keyc[15:8] == 8'h1A |
						keyc[7:0] == 8'h1A);
						
	assign a_on = (keyc[31:24] == 8'h04 |
						keyc[23:16] == 8'h04 |
						keyc[15:8] == 8'h04 |
						keyc[7:0] == 8'h04);
						
	assign s_on = (keyc[31:24] == 8'h16 |
						keyc[23:16] == 8'h16 |
						keyc[15:8] == 8'h16 |
						keyc[7:0] == 8'h16);
						
	assign d_on = (keyc[31:24] == 8'h07 |
						keyc[23:16] == 8'h07 |
						keyc[15:8] == 8'h07 |
						keyc[7:0] == 8'h07);
						
	//Checking the Arrow keys //for player two
	assign lef_on = (keyc[31:24] == 8'h50 |
						keyc[23:16] == 8'h50 |
						keyc[15:8] == 8'h50 |
						keyc[7:0] == 8'h50);
						
	assign rig_on = (keyc[31:24] == 8'h4F |
						keyc[23:16] == 8'h4F |
						keyc[15:8] == 8'h4F |
						keyc[7:0] == 8'h4F);
						
	assign up_on = (keyc[31:24] == 8'h52 |
						keyc[23:16] == 8'h52 |
						keyc[15:8] == 8'h52 |
						keyc[7:0] == 8'h52);
						
	assign dow_on = (keyc[31:24] == 8'h51 |
						keyc[23:16] == 8'h51 |
						keyc[15:8] == 8'h51 |
						keyc[7:0] == 8'h51);
						
	//Checking the shooting keys
	//for player two, shoot key is keypad enter
	assign pl_2shoot = (	keyc[31:24] == 8'h58 |
								keyc[23:16] == 8'h58 |
								keyc[15:8] == 8'h58 |
								keyc[7:0] == 8'h58); 
								
	//for player one, shoot key is spacebar
	assign pl_1shoot = (	keyc[31:24] == 8'h2C |
								keyc[23:16] == 8'h2C |
								keyc[15:8] == 8'h2C |
								keyc[7:0] == 8'h2C); 

	assign enter = (	keyc[31:24] == 8'h28 |
								keyc[23:16] == 8'h28 |
								keyc[15:8] == 8'h28 |
								keyc[7:0] == 8'h28); 
								
endmodule
