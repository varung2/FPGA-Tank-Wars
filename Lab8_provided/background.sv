module background ( input logic Clk,
					input logic Reset_h,

					//for state machine
					input logic Gen, //State Machine Signal to start generating background
					output logic Gen_Done, //State Machine Signal to signal generation done.

					input logic [9:0] DrawX, DrawY, //to grab value for drawing.
					output logic [2:0] tilenumber
					
);

	//background array
	logic [2:0] backarr [60][80]; //unpacked array of 60 rows by 80 columns (made it two bits incase for 4 possible tiles))
	

	//Random number generator
	logic [9:0] number, rand_in;
	random random(.*, .out(rand_in));

	assign Gen_Done = Done;

	logic Done, Done_in;
	logic [6:0]	column, column_in;	//80 max
	logic [5:0] row, row_in;	//60 max
	//Making a counter to loop between rows and columns;

	always_ff @(posedge Clk) begin : proc_
		if (Reset_h) begin
			Done <= 0;
			column <= 0;
			row <= 0;
			number <= 0;
		end
		else begin
			Done <= Done_in;
			column <= column_in;
			row <= row_in;
			number <= rand_in;
		end
	end

	always_comb begin: Counter
		//Default values, done is 0 and column and row stay the same i.e. don't count
		Done_in = 0;
		column_in = column;
		row_in = row;
		if (Gen && ~Done) begin
			//if reached the end of the row
			if (column >= 7'd79 && row < 6'd59) begin
				row_in = row + 1;
				column_in = 0;
			end

			//reached the last tile
			else if (column >= 7'd79 && row >= 6'd59)
				Done_in = 1;
			else
				column_in = column + 1;
		end
	end

	always_comb begin: RAND_GEN
		if (Gen) begin
			if (number[8:0] <= 9'd20) begin : GENERATE_FEATURES //if less than 32 generate some features
				if (number[6:0] >= 9'd16) //Generate Tree
					backarr[row][column] = 3'd1;
				else if (number[6:0] < 9'd16 && number[6:0] >= 9'd12) //grassy patch 1
					backarr[row][column] = 3'd2;
				else if (number[6:0] < 9'd12 && number[6:0] >= 9'd8) //grassy patch 2
					backarr[row][column] = 3'd3;
				else if (number[6:0] < 9'd8 && number[6:0] >= 9'd6) //grassy patch 3
					backarr[row][column] = 3'd4;
				else //stone tile
					backarr[row][column] = 3'd5;
			end
			else
				backarr[row][column] = 3'd0; //background green color
		end
		else 
			backarr[row][column] = 3'd0; //background color, i.e. no tile
	end 

	//assigning the tile number based on the value in the backarr 
	assign tilenumber = backarr[DrawY/8][DrawX/8];

endmodule