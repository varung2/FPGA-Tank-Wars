module bullet_collision (
	input logic [9:0] p1_BullX, p1_BullY, p2_BullX, p2_BullY,
	input logic [9:0] Tank1X, Tank1Y, Tank2X, Tank2Y,


	output logic hittank1, hittank2
	);

	parameter [9:0] TankSize = 10'd8; //radius for Tank and radius for bullet 
	parameter [9:0] BullSize = 10'd3;


	int distX, distY, r;
	assign r = TankSize + BullSize;
	assign distX = Tank1X - p2_BullX;
	assign distY = Tank1Y - p2_BullY;
	int distX2, distY2;
	assign distX2 = Tank2X - p1_BullX;
	assign distY2 = Tank2Y - p1_BullY;

	
	always_comb begin : BulletCollisions_PL1
		//collisions for tank1
		if (distX*distX + distY*distY <= r*r)
			hittank1 = 1'b1;
		else 
			hittank1 = 1'b0;
	end

	always_comb begin : BulletCollisions_PL2
		//collisions for tank2
		if (distX2*distX2 + distY2*distY2 <= r*r)
			hittank2 = 1'b1;
		else
			hittank2 = 1'b0;
	end


endmodule // bullet_collision