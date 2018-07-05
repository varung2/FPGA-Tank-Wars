/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  ROM2( 
		input [15:0] ADDR,
		input Clk,

		output logic [4:0] out
);

// mem has width of 5 bits and a total of 256x256 addresses (picture size)
// address needs to be 16 bits, 2^16 = 65,536 locations 
logic [4:0] mem [0:65535];

initial
begin
	 $readmemh("Tanksprites.txt", mem);
end


always_ff @ (negedge Clk) begin
	out <= mem[ADDR];
end

endmodule
