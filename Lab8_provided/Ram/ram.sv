/*
 * ECE385-HelperTools/PNG-To-Txt
 * Author: Rishi Thakkar
 *
 */

module  ram( 
		input [4:0] data_In,
		input [15:0] write_address, read_address,
		input we, Clk,

		output logic [4:0] data_Out
);

// mem has width of 5 bits and a total of 256x256 addresses (picture size)
// address needs to be 2^16
logic [4:0] mem [0:65535];

initial
begin
	 $readmemh("Tanksprites.txt", mem);
end


always_ff @ (posedge Clk) begin
	if (we)
		mem[write_address] <= data_In;
	data_Out<= mem[read_address];
end

endmodule
