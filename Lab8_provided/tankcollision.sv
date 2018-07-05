module tankcollision(
		input logic [9:0] Tank1X, Tank1Y, Tank2X, Tank2Y,
		output logic collide);

	parameter [9:0] Half = 10'd9;
	parameter [9:0] Width = 10'd16;
	always_comb begin : TANK_COLLISIONS

		// //Using a box to check collisions
		// if ((Tank1X + Width >= Tank2X) && 
		// 	(((Tank2Y + Width >= Tank1Y) && (Tank2Y <= Tank1Y)) || 
		// 	 ((Tank2Y >= Tank1Y) && (Tank2Y <= Tank1Y + Width))))
		// 	colide = 1'b1;
		// else
		// if ((Tank1Y + Width >= Tank2Y) &&
		// 	(((Tank2X + Half >= Tank1X - Half) && (Tank2X + Half <= Tank1X + Half)) || 
		// 	 ((Tank2X - Half >= Tank1X - Half) && (Tank2X - Half <= Tank1X + Half))))
		// 	colide = 1'b1;
		// else
		// if ((Tank2Y + Width >= Tank1Y) &&
		// 	(((Tank1X + Half >= Tank2X - Half) && (Tank1X + Half <= Tank2X + Half)) ||
		// 	 ((Tank1X - Half >= Tank1X - Half) && (Tank1X - Half <= Tank2X + Half))))
		// 	colide = 1'b1;
		// else
		// if ((Tank2X + Width >= Tank1X) &&
		// 	(((Tank1Y + Half >= Tank2Y - Half) && (Tank1Y + Half <= Tank2Y + Half)) ||
		// 	 ((Tank1Y - Half >= Tank2Y - Half) && (Tank1Y - Half <= Tank2Y + Half))))
		// 	colide = 1'b1;
		// else
		// 	colide = 1'b0;


		int distX, distY, r;

		distX = Tank1X - Tank2X;
		distY = Tank1Y - Tank2Y;
		r = Width;

		if (distX*distX + distY*distY <= r*r)
			collide = 1'b1;
		else
			collide = 1'b0;

	end



endmodule // tankcollision
