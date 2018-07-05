//-------------------------------------------------------------------------
//    Ball.sv                                                            --
//    Viral Mehta                                                        --
//    Spring 2005                                                        --
//                                                                       --
//    Modified by Stephen Kempf 03-01-2006                               --
//                              03-12-2007                               --
//    Translated by Joe Meng    07-07-2013                               --
//    Modified by Po-Han Huang  12-08-2017                               --
//    Spring 2018 Distribution                                           --
//                                                                       --
//    For use with ECE 385 Lab 8                                         --
//    UIUC ECE Department                                                --
//-------------------------------------------------------------------------

//SIZE OF TANK IS 16x16 PIXELS

module  ball ( input         Clk,                // 50 MHz clock
                             Reset,              // Active-high reset signal
                             frame_clk,          // The clock indicating a new frame (~60Hz)
               input [9:0]   DrawX, DrawY,		 // Current pixel coordinates
					input w_on, a_on, s_on, d_on,
			   input logic is_obst,
			   input logic collide,

			   input logic pick, //for pickups
			   input logic VGA_VS,

               output logic  is_ball,             // Whether current pixel belongs to sprite or background
					output logic [1:0] dir,
					output logic [9:0] spriteX, //xposition of sprite
					output logic [9:0] spriteY, //yposition of sprite
					output logic [9:0] BallX,
					output logic [9:0] BallY
              );
    
	 //parameter [1:0] Default_Dir = 2'd0; //sets the default direction: 0 = up, 1 = right, 2 = down, 3 = left.
    parameter [9:0] Ball_X_Center = 10'd320;  // Center position on the X axis
    parameter [9:0] Ball_Y_Center = 10'd240;  // Center position on the Y axis
    parameter [9:0] Ball_X_Min = 10'd0;       // Leftmost point on the X axis
    parameter [9:0] Ball_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Ball_Y_Min = 10'd0;       // Topmost point on the Y axis
    parameter [9:0] Ball_Y_Max = 10'd429;     // Bottommost point on the Y axis
    parameter [9:0] BallXStep = 10'd1;      // Step size on the X axis
    parameter [9:0] BallYStep = 10'd1;      // Step size on the Y axis
    parameter [9:0] Ball_Size = 10'd8;        // Ball size !!!!! Was previously 10'd4
    parameter [9:0] PowerStep = 10'd3;


    logic [9:0] Ball_X_Pos, Ball_X_Motion, Ball_Y_Pos, Ball_Y_Motion;
    logic [9:0] Ball_X_Pos_in, Ball_X_Motion_in, Ball_Y_Pos_in, Ball_Y_Motion_in;
	logic [1:0] Direction_in, Direction;
    
	logic [9:0] Ball_X_Step, Ball_Y_Step;


	assign spriteX = DrawX-Ball_X_Pos+8;
	assign spriteY = DrawY-Ball_Y_Pos+8;
	assign dir = Direction;

	assign BallX = Ball_X_Pos;
	assign BallY = Ball_Y_Pos;

	logic start;
	logic [9:0] counter;
	always_ff @ (posedge VGA_VS)
	begin
		if (start) begin
			if (counter == 10'd300 || pick)
				counter <= 6'd0;
			else
				counter <= counter + 1;
		end 
		else 
			counter <= 0;
	end

	enum logic {Powerup, Not_Power} State, Next_State;
	always_ff @(posedge Clk) begin
		if (Reset) State <= Not_Power;
		else State <= Next_State;
	end
	always_comb begin : NEXTSTATELOGIC
		unique case (State) 
			Not_Power: begin 
				if (pick)
					Next_State = Powerup;
				else
					Next_State = Not_Power;
			end
			Powerup: begin
				if (counter == 10'd300)
					Next_State = Not_Power;
				else
					Next_State = Powerup;
			end
		endcase
	end
	always_comb begin : CONTROL
		case (State)
			Not_Power: begin
				start = 0;
			end
			Powerup: begin
				start = 1;
			end
		endcase
		//control the step signals with a mux
		if (start) begin
			Ball_X_Step = PowerStep;
			Ball_Y_Step = PowerStep;
		end
		else begin
			Ball_X_Step = BallXStep;
			Ball_Y_Step = BallYStep;
		end
	end


    //////// Do not modify the always_ff blocks. ////////
    // Detect rising edge of frame_clk
    logic frame_clk_delayed, frame_clk_rising_edge;
    always_ff @ (posedge Clk) begin
        frame_clk_delayed <= frame_clk;
        frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end
    // Update registers
    always_ff @ (posedge Clk)
    begin
        if (Reset)
        begin
            Ball_X_Pos <= Ball_X_Center;
            Ball_Y_Pos <= Ball_Y_Center;
            Ball_X_Motion <= 10'd0;
            Ball_Y_Motion <= Ball_Y_Step;
				Direction <= 2'd0;
        end
        else
        begin
            Ball_X_Pos <= Ball_X_Pos_in;
            Ball_Y_Pos <= Ball_Y_Pos_in;
            Ball_X_Motion <= Ball_X_Motion_in;
            Ball_Y_Motion <= Ball_Y_Motion_in;
				Direction <= Direction_in;
        end
    end
    //////// Do not modify the always_ff blocks. ////////
    
	 
	 //DONE, DESCRIPTION:
	 //	Checks if it has a keypress first, then checks if it is at the edge of the screen
	 //		If it is at the edge, then bounce, otherwise, apply the respective motion to the ball
	 //	If no key is pressed, then default to check the boundary conditions
	 //      If it is not at the edge, do nothing.
	 //CHANGE THIS-------------------------------------------------------------------------------------------------
    // You need to modify always_comb block.
    always_comb
    begin
        // By default, keep motion and position unchanged
        Ball_X_Pos_in = Ball_X_Pos;
        Ball_Y_Pos_in = Ball_Y_Pos;
        Ball_X_Motion_in = Ball_X_Motion;
        Ball_Y_Motion_in = Ball_Y_Motion;
        Direction_in = Direction;
        // Update position and motion only at rising edge of frame clock
        if (frame_clk_rising_edge)
        begin	
			//Keypress 'W', UP
			if(w_on && ~a_on && ~s_on && ~d_on)
				begin
					Direction_in = 2'd0;
					Ball_X_Motion_in = 10'd0;
					// Be careful when using comparators with "logic" datatype because compiler treats 
					//   both sides of the operator as UNSIGNED numbers.
					// e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
					// If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
					if (is_obst || collide)
						Ball_Y_Motion_in = 10'd1;
					else 
					if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.  
					else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
						Ball_Y_Motion_in = Ball_Y_Step;
					// TODO: Add other boundary detections and handle keypress here.
				
					//left and right boundary positions
					else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max) //Ball is at left edge
						begin
						Ball_Y_Motion_in = 10'd0;	//clearing y motion for xbounce
						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
						end
					else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size) //Ball is at right edge 
						begin
						Ball_Y_Motion_in = 10'd0;	//clearing y motion for xbounce
						Ball_X_Motion_in = Ball_X_Step;
						end 

					else Ball_Y_Motion_in = (~Ball_X_Step)+1;
				end
				
			//Keypress 'S', DOWN
			else if (~w_on && ~a_on && s_on && ~d_on)
				begin
					Direction_in = 2'd2;
					Ball_X_Motion_in = 10'd0;
					// Be careful when using comparators with "logic" datatype because compiler treats 
					//   both sides of the operator as UNSIGNED numbers.
					// e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
					// If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
					if (is_obst || collide)
						Ball_Y_Motion_in = (~10'd1) + 1;
					else if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.  
					else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
						Ball_Y_Motion_in = Ball_Y_Step;
				
					//left and right boundary positions
					else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max) //Ball is at left edge
						begin
						Ball_Y_Motion_in = 10'd0;	//clearing y motion for xbounce 
						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
						end
					else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size) //Ball is at right edge 
						begin
						Ball_Y_Motion_in = 10'd0;	//clearing y motion for xbounce
						Ball_X_Motion_in = Ball_X_Step;
						end
					
					else Ball_Y_Motion_in = (Ball_X_Step);
				end
				
			//Keypress 'A', LEFT
			else if (~w_on && a_on && ~s_on && ~d_on)
				begin
					Direction_in = 2'd3;
					Ball_Y_Motion_in = 10'd0;
					// Be careful when using comparators with "logic" datatype because compiler treats 
					//   both sides of the operator as UNSIGNED numbers.
					// e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
					// If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
					if (is_obst || collide)
						Ball_X_Motion_in = Ball_X_Step;
					else if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
						begin	
						Ball_X_Motion_in = 10'b0; //clearing x motion in ybounce;
						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.  
						end
					else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
						begin
						Ball_X_Motion_in = 10'b0; //clearing x motion in ybounce;
						Ball_Y_Motion_in = Ball_Y_Step;
						end
						
					//left and right boundary positions
					else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max) //Ball is at left edge
						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
					else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size) //Ball is at right edge 
						Ball_X_Motion_in = Ball_X_Step;
					
					//actual movement if not bouncing
					else Ball_X_Motion_in = ~(Ball_X_Step) + 1; //2's complement, move left
				end
				
			//Keypress 'D', RIGHT
			else if (~w_on && ~a_on && ~s_on && d_on)
				begin
					Direction_in = 2'd1;
					Ball_Y_Motion_in = 10'd0;
					// Be careful when using comparators with "logic" datatype because compiler treats 
					//   both sides of the operator as UNSIGNED numbers.
					// e.g. Ball_Y_Pos - Ball_Size <= Ball_Y_Min 
					// If Ball_Y_Pos is 0, then Ball_Y_Pos - Ball_Size will not be -4, but rather a large positive number.
					if (is_obst || collide)
						Ball_X_Motion_in = (~Ball_X_Step) + 1;
					else if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
						begin
						Ball_X_Motion_in = 10'b0; //clearing x motion in ybounce;
						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.  
						end
					else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
						begin
						Ball_X_Motion_in = 10'b0; //clearing x motion in ybounce;
						Ball_Y_Motion_in = Ball_Y_Step;
						end
				
					//left and right boundary positions
					else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max) //Ball is at left edge
						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
					else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size) //Ball is at right edge 
						Ball_X_Motion_in = Ball_X_Step;
					
					//actual movement if not bouncing
					else Ball_X_Motion_in = (Ball_X_Step); //increase
				end
				
			//also in case multiple keys are pressed 
			//default case, just check if it is going to bounce, do not add any motion
			else 
				begin 
					Direction_in = Direction; //Keep the direction the same
					
					if (is_obst) begin
						case (Direction)
							2'd0: Ball_Y_Motion_in = Ball_Y_Step;
							2'd1: Ball_X_Motion_in = ~Ball_X_Step + 1;
							2'd2: Ball_Y_Motion_in = ~Ball_Y_Step + 1;
							2'd3: Ball_X_Motion_in = Ball_X_Step;
						endcase // Direction
						end
					else if( Ball_Y_Pos + Ball_Size >= Ball_Y_Max )  // Ball is at the bottom edge, BOUNCE!
						Ball_Y_Motion_in = (~(Ball_Y_Step) + 1'b1);  // 2's complement.  
					else if ( Ball_Y_Pos <= Ball_Y_Min + Ball_Size )  // Ball is at the top edge, BOUNCE!
						Ball_Y_Motion_in = Ball_Y_Step;
					// TODO: Add other boundary detections and handle keypress here.
				
					//left and right boundary positions
					else if ( Ball_X_Pos + Ball_Size >= Ball_X_Max) //Ball is at right edge
						begin
						//Ball_Y_Motion_in = 10'd0;	//clearing y motion for xbounce 
						Ball_X_Motion_in = (~(Ball_X_Step) + 1'b1);
						end
					else if ( Ball_X_Pos <= Ball_X_Min + Ball_Size) //Ball is at left edge 
						begin
						//Ball_Y_Motion_in = 10'd0;	//clearing y motion for xbounce
						Ball_X_Motion_in = Ball_X_Step;
						end 
						                                                                    
					else 
						begin
							Ball_X_Motion_in = 10'd0;
							Ball_Y_Motion_in = 10'd0;
						end
				end 
				
            // Update the ball's position with its motion
            Ball_X_Pos_in = Ball_X_Pos + Ball_X_Motion;
            Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;
        end
        
        /**************************************************************************************
            ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
            Hidden Question #2/2:
               Notice that Ball_Y_Pos is updated using Ball_Y_Motion. 
              Will the new value of Ball_Y_Motion be used when Ball_Y_Pos is updated, or the old? 
              What is the difference between writing
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion;" and 
                "Ball_Y_Pos_in = Ball_Y_Pos + Ball_Y_Motion_in;"?
              How will this impact behavior of the ball during a bounce, and how might that interact with a response to a keypress?
              Give an answer in your Post-Lab.
        **************************************************************************************/
    end
    
    // Compute whether the pixel corresponds to ball or background
    /* Since the multiplicants are required to be signed, we have to first cast them
       from logic to int (signed by default) before they are multiplied. */
    int DistX, DistY, size, size2;
    assign DistX = DrawX - Ball_X_Pos;
    assign DistY = DrawY - Ball_Y_Pos;
    assign size = 8; //size of a tank is 16 pixels width and height
	assign size2 = -8;
    always_comb begin
       	// if ((DistX <= Size) &&& (DistY <= Size) && ()) 
      	//      is_ball = 1'b1;
		if (DrawX <= Ball_X_Pos + size && DrawX + size >= Ball_X_Pos && DrawY <= Ball_Y_Pos + size && DrawY + size >= Ball_Y_Pos)
			is_ball = 1'b1;
        else
        	is_ball = 1'b0;
        /* The ball's (pixelated) circle is generated using the standard circle formula.  Note that while 
           the single line is quite powerful descriptively, it causes the synthesis tool to use up three
           of the 12 available multipliers on the chip! */
    end
    
endmodule
