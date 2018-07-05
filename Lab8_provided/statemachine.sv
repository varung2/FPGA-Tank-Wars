module statemachine (
	input Clk,    // Clock
	input Reset_h, // Reset
	input [9:0] DrawX, DrawY,

	input Enter_key, //Enter Key for the beginning of the game
	input Win,		 //If a player is dead

	//control signals for game, start for the begining of the game. Gen for 
	output logic Start_sig, 	//for start screen
	output logic Done_sig, 		//for game over screen
	output logic [2:0] tilenum,
	output logic Gen,
	input logic Gen_Done2
);
	
	//Instantiating the background module
	logic Gen_Done, All_Gen_Done;
	// assign Gen_Done = 1'b1;
	assign All_Gen_Done = ((Gen_Done && Gen_Done2));
	//UNCOMMENT THIS FOR FINAL PRESENTATION
	background back(.*, .tilenumber(tilenum)); //outputs the tile number for the sprite;
	// assign tilenum = 3'd0;


	enum logic [4:0] {Start, Generate, Game, Done} State, Next_State;
	

	//State machine
	always_ff @(posedge Clk) begin : proc_
		if(Reset_h) begin
			State <= Start;
		end else begin
			State <= Next_State;
		end
	end

	//Next State logic
	always_comb begin : NEXT_STATE_LOGIC
		unique case(State)
			Start: begin
				if (Enter_key)
					Next_State = Generate;
				else
					Next_State = Start;
			end

			Generate: begin
				if (All_Gen_Done)
					Next_State = Game;
				else 
					Next_State = Generate;
			end

			Game: begin
				if (Win)
					Next_State = Done;
				else 
					Next_State = Game;
			end

			Done:
				Next_State = Done;
		endcase // State
	end

	//Control Signal Logic
	always_comb begin : CONTROL
		//Default Signals
		Start_sig = 1'b0;
		Gen = 1'b0;
		Done_sig = 1'b0;

		case(State)
			Start: Start_sig = 1'b1; //Signal to Draw the Start Screen (Press Enter to Start...)
			Generate: Gen = 1'b1; //Signal to Generate the Background map
			Game: ; //No control signal for game
			Done: Done_sig = 1'b1; //Signal to show Game Over Screen
		endcase // State
	end

endmodule