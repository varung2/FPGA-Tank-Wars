/* 
 * This 10-bit psuedo-random generator is to be used to randomize 
 * the size and position of any obstacle, during the map generation 
 * state of the game FSM. This module also randomizes the placement 
 * of pickup items, during the actual game.	
 */

module random2 ( 
				 input logic Clk,
				 input logic Reset_h,
				 output logic [9:0] out
			    );
	
	logic LF;
	
	assign LF = (out[3] ^ out[6]); //linear feedback function
	
	always_ff @(posedge Clk) begin
		if (~Reset_h) begin
			out <= {out[2], out[5], out[3], out[1], out[6], out[7], out[0], out[8], out[9], LF}; //scramble the numbers
		end
		
		else begin
			out <= 9'b0000101111; //the initial seed of the function
		end
		
	end
	
endmodule
