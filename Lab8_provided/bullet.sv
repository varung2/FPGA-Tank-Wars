module bullet (
	input logic Clk, Reset_h, frame_clk,
	input logic [9:0] DX, DY,
	input logic [9:0] TankX, TankY, //To keep the bullet at the center of the tank
	input shoot, //input from the keyboard
    input logic hittank, //if it hit the oposite tank
    input logic hitobj,
	//for the direction of the bullet
	input [1:0] dir,

    output logic shot,

	output is_bullet,
    output logic [9:0] BulletX, BulletY,
    output logic [9:0] BullSpriteX, BullSpriteY,
    output logic [1:0] bulldir
	);

	parameter [9:0] Bullet_Center_X = 10'd213;
	parameter [9:0] Bullet_Center_Y = 10'd240;
	parameter [9:0] Bull_X_Min = 10'd2;       // Leftmost point on the X axis
    parameter [9:0] Bull_X_Max = 10'd639;     // Rightmost point on the X axis
    parameter [9:0] Bull_Y_Min = 10'd2;       // Topmost point on the Y axis
    parameter [9:0] Bull_Y_Max = 10'd479;     // Bottommost point on the Y axis
	parameter [9:0] Bullet_Step = 10'd5;
    parameter [9:0] Bull_Size = 10'd3; //Sprite is 5x5, changed to 6x6

    assign shot = is_shot;

	logic [9:0] Bull_X_Pos, Bull_X_Motion, Bull_Y_Pos, Bull_Y_Motion;
	logic [9:0] Bull_X_Pos_in, Bull_X_Motion_in, Bull_Y_Pos_in, Bull_Y_Motion_in;
	logic frame_clk_delayed, frame_clk_rising_edge;
	logic is_shot, is_shot_in;

	logic [1:0] Direc, Direc_in;

    logic singlekey;
    enum logic [1:0] {Pressed, Pressed_1, Not_Pressed} State, Next_State;
    //So you can't hold the shoot key
    always_comb begin : Next_StateLOGIC
        unique case(State)
            Pressed: Next_State = Pressed_1;
            Pressed_1: begin
                if (~shoot)
                    Next_State = Not_Pressed;
                else
                    Next_State = Pressed_1;
            end
            Not_Pressed: begin
                if (shoot)
                    Next_State = Pressed;
                else
                    Next_State = Not_Pressed;
            end
        endcase // Stateendcase
    end
    always_comb begin : CONTROL
        case(State)
            Pressed: singlekey = 1'b1;
            Pressed_1: singlekey = 1'b1;
            Not_Pressed: singlekey = 1'b0;
        endcase
    end


	//Tank positions
    logic [9:0] Tank_X_Pos, Tank_Y_Pos;
    assign Tank_X_Pos = TankX;
    assign Tank_Y_Pos = TankY;

    //assigning output signals
    assign BulletX = Bull_X_Pos;
    assign BulletY = Bull_Y_Pos;
    assign BullSpriteX = DX - Bull_X_Pos + 1;
    assign BullSpriteY = DY - Bull_Y_Pos + 1;
    assign bulldir = Direc;

	always_ff @ (posedge Clk) begin
    	frame_clk_delayed <= frame_clk;
    	frame_clk_rising_edge <= (frame_clk == 1'b1) && (frame_clk_delayed == 1'b0);
    end

    always_ff @ (posedge Clk)
    begin
        if (Reset_h)
        begin
            State <= Not_Pressed;
            Bull_X_Pos <= Tank_X_Pos;
            Bull_Y_Pos <= Tank_Y_Pos;
            Bull_X_Motion <= 10'd0;
            Bull_Y_Motion <= 10'd0;
            is_shot <= 0;
            Direc <= 0;
        end
        else
        begin
            State <= Next_State;
            Bull_X_Pos <= Bull_X_Pos_in;
            Bull_Y_Pos <= Bull_Y_Pos_in;
            Bull_X_Motion <= Bull_X_Motion_in;
            Bull_Y_Motion <= Bull_Y_Motion_in;
            is_shot <= is_shot_in;
            Direc <= Direc_in;
        end
    end

    always_comb begin : BULLET_MOTION
    	//By default, keep motion unchanged
        Bull_X_Motion_in = Bull_X_Motion;
        Bull_Y_Motion_in = Bull_Y_Motion;
        Direc_in = Direc;
        is_shot_in = is_shot;
        Bull_X_Pos_in = Bull_X_Pos;
        Bull_Y_Pos_in = Bull_Y_Pos;
        
    	if (frame_clk_rising_edge) begin
            //Default Signals
    		//check if the shoot key is pressed
    		if (shoot && ~is_shot && ~hittank && ~hitobj) begin
                //Default Signals
    			Direc_in = dir;
    			//Checking Collisions, if there is a collision, then set the shot status to 0, and position to the tank
                //collisions for the boundary of the screen
    			if (Bull_Y_Pos + Bull_Size >= Bull_Y_Max) begin
    				is_shot_in = 0;
    				Bull_X_Pos_in = Tank_X_Pos;
    				Bull_Y_Pos_in = Tank_Y_Pos;
    				Bull_Y_Motion_in = 0;
    				Bull_X_Motion_in = 0;
    				end
    			else if (Bull_Y_Pos <= Bull_Y_Min + Bull_Size) begin
    				is_shot_in = 0;
    				Bull_X_Pos_in = Tank_X_Pos;
    				Bull_Y_Pos_in = Tank_Y_Pos;
    				Bull_Y_Motion_in = 0;
    				Bull_X_Motion_in = 0;
    				end 
    			else if ( Bull_X_Pos + Bull_Size >= Bull_X_Max)	begin
					is_shot_in = 0;
    				Bull_X_Pos_in = Tank_X_Pos;
    				Bull_Y_Pos_in = Tank_Y_Pos;
    				Bull_Y_Motion_in = 0;
    				Bull_X_Motion_in = 0;
					end
				else if ( Bull_X_Pos <= Bull_X_Min + Bull_Size) begin
					is_shot_in = 0;
    				Bull_X_Pos_in = Tank_X_Pos;
    				Bull_Y_Pos_in = Tank_Y_Pos;
    				Bull_Y_Motion_in = 0;
    				Bull_X_Motion_in = 0;
					end
				else begin //if there is no collision
					is_shot_in = 1;
					//check the direction of the tank and assign motion
					case (dir)
						2'd0: Bull_Y_Motion_in = ~Bullet_Step + 1;
						2'd1: Bull_X_Motion_in = Bullet_Step; 
						2'd2: Bull_Y_Motion_in = Bullet_Step;
						2'd3: Bull_X_Motion_in = ~Bullet_Step + 1;
					endcase // dir
				end
    		end 

    		else if (is_shot && ~hittank && ~hitobj) begin
    			is_shot_in = 1;
    			Direc_in = Direc;
    			//Checking collisions
    			if (Bull_Y_Pos + Bull_Size >= Bull_Y_Max) begin
    				is_shot_in = 0;
    				Bull_X_Pos_in = Tank_X_Pos;
    				Bull_Y_Pos_in = Tank_Y_Pos;
    				Bull_Y_Motion_in = 0;
    				Bull_X_Motion_in = 0;
    				end
    			else if (Bull_Y_Pos <= Bull_Y_Min + Bull_Size) begin
    				is_shot_in = 0;
    				Bull_X_Pos_in = Tank_X_Pos;
    				Bull_Y_Pos_in = Tank_Y_Pos;
    				Bull_Y_Motion_in = 0;
    				Bull_X_Motion_in = 0;
    				end 
    			else if ( Bull_X_Pos + Bull_Size >= Bull_X_Max)	begin
					is_shot_in = 0;
    				Bull_X_Pos_in = Tank_X_Pos;
    				Bull_Y_Pos_in = Tank_Y_Pos;
    				Bull_Y_Motion_in = 0;
    				Bull_X_Motion_in = 0;
					end
				else if ( Bull_X_Pos <= Bull_X_Min + Bull_Size) begin
					is_shot_in = 0;
    				Bull_X_Pos_in = Tank_X_Pos;
    				Bull_Y_Pos_in = Tank_Y_Pos;
    				Bull_Y_Motion_in = 0;
    				Bull_X_Motion_in = 0;
					end
				else begin // if there are no collisions
					//keep motion constant and update position
                    is_shot_in = is_shot;
					Bull_X_Motion_in = Bull_X_Motion;
					Bull_Y_Motion_in = Bull_Y_Motion;
					Bull_X_Pos_in = Bull_X_Pos + Bull_X_Motion;
                    Bull_Y_Pos_in = Bull_Y_Pos + Bull_Y_Motion;
				end
    		end 
            else if ((hittank || hitobj) && is_shot) begin
                is_shot_in = 0;
                Bull_X_Pos_in = Tank_X_Pos;
                Bull_Y_Pos_in = Tank_Y_Pos;
                Bull_Y_Motion_in = 0;
                Bull_X_Motion_in = 0;
            end
            else if (~shoot && ~is_shot && ~hittank && ~hitobj) begin
                Bull_X_Pos_in = Tank_X_Pos;
                Bull_Y_Pos_in = Tank_Y_Pos;
            end
    	end
    end // BULLET_MOTION

    //Drawing the Bullet
    int size;
    assign size = 2; //sprite size if 4 x 4
    always_comb begin : proc_
        if (DX <= Bull_X_Pos + size && DX + size >= Bull_X_Pos && DY <= Bull_Y_Pos + size && DY + size >= Bull_Y_Pos)
            is_bullet = 1'b1;
        else
            is_bullet = 1'b0;
    end

endmodule // bullet