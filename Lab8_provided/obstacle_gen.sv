module obstacle_gen(
		input Clk, Reset_h,
		input logic Gen,
		output logic Gen_Done2,

		input [9:0] Tank1X, Tank1Y, Tank2X, Tank2Y,
		input [9:0] p1_BullX, p1_BullY, p2_BullX, p2_BullY,

		output logic is_obst,
		output logic is_obst_2,

		output [9:0] obj_cnt,

		output logic hitobj1, hitobj2,

		input [9:0] DrawX, DrawY,
		output [20:0] obst
		);
	
	parameter [9:0] number_obstacles = 16;
	parameter [20:0] defaultsig = 21'd0;

	assign obj_cnt = objcounter;

	logic [9:0] objcounter, obj_in;
	logic [9:0] randx, randy;
	logic [9:0] tl_obj_x[number_obstacles];
	logic [9:0] tl_obj_y[number_obstacles];


	random #(.seed(10'd103)) genx(.*, .out(randx));
	random #(.seed(10'd453)) geny(.*, .out(randy));

	logic finish, finish_in;
	always_ff @(posedge Clk) begin : Counter
		if (Reset_h) begin
			objcounter <= 0;
			finish <= 0;
		end
		else begin
			objcounter <= obj_in;
			finish <= finish_in;
		end
	end
	always_comb begin : POSITION
		//default signals
		obj_in = objcounter;
		tl_obj_x[objcounter] = 7'd0;
		tl_obj_y[objcounter] = 7'd0;
		finish_in = 0;

		if (Gen) begin
			if ((randx[8:0] > 0) && (randy[8:0] > 0) && (randx[8:0] < 640) && (randy[8:0] < 480) && (~finish)) begin
				tl_obj_x[objcounter] = randx[8:0];
				tl_obj_y[objcounter] = randy[8:0];
				obj_in = objcounter + 1;
			end
			else begin
				obj_in = objcounter;
				tl_obj_x[objcounter] = 7'd0;
				tl_obj_y[objcounter] = 7'd0;
			end
			
			//logic for finish
			if (objcounter >= number_obstacles)
				finish_in = 1;
			else
				finish_in = 0;
		end
	end





	//all the output logic in arrays
	logic donecount[number_obstacles];
	logic [20:0] obst_out[number_obstacles];
	logic hitobj1_out[number_obstacles];
	logic hitobj2_out[number_obstacles];
	logic is_obst_out[number_obstacles];
	logic is_obst_2_out[number_obstacles];

	//All of these signals work
	assign hitobj1 = (hitobj1_out[0] || hitobj1_out[1] || hitobj1_out[2] || hitobj1_out[3] || hitobj1_out[4] || hitobj1_out[5] || hitobj1_out[6] || hitobj1_out[7] || hitobj1_out[8] || hitobj1_out[9] || hitobj1_out[10] || hitobj1_out[11] || hitobj1_out[12] || hitobj1_out[13] || hitobj1_out[14] || hitobj1_out[15]);  //||
	assign hitobj2 = (hitobj2_out[0] || hitobj2_out[1] || hitobj2_out[2] || hitobj2_out[3] || hitobj2_out[4] || hitobj2_out[5] || hitobj2_out[6] || hitobj2_out[7] || hitobj2_out[8] || hitobj2_out[9] || hitobj2_out[10] || hitobj2_out[11] || hitobj2_out[12] || hitobj2_out[13] || hitobj2_out[14] || hitobj2_out[15]);
	assign is_obst = (is_obst_out[0] || is_obst_out[1] || is_obst_out[2] || is_obst_out[3] || is_obst_out[4] || is_obst_out[5] || is_obst_out[6] || is_obst_out[7] || is_obst_out[8] || is_obst_out[9] || is_obst_out[10] || is_obst_out[11] || is_obst_out[12] || is_obst_out[13] || is_obst_out[14] || is_obst_out[15]);
	assign is_obst_2 = (is_obst_2_out[0] || is_obst_2_out[1] || is_obst_2_out[2] || is_obst_2_out[3] || is_obst_2_out[4] || is_obst_2_out[5] || is_obst_2_out[6] || is_obst_2_out[7] || is_obst_2_out[8] || is_obst_2_out[9] || is_obst_2_out[10] || is_obst_2_out[11] || is_obst_2_out[12] || is_obst_2_out[13] || is_obst_2_out[14] || is_obst_2_out[15]);
	assign Gen_Done2 = (donecount[3] && donecount[2] && donecount[1] && donecount[4] && donecount[5] && donecount[6] && donecount[7] && donecount[8] && donecount[9] && donecount[10] && donecount[11] && donecount[12] && donecount[13] && donecount[14] && donecount[15]);

	//MUX for obstacle signal and position -- Works
	always_comb begin : proc_
		if (obst_out[0][20] == 1'b1)
			obst = obst_out[0];
		else if (obst_out[1][20] == 1'b1)
			obst = obst_out[1];
		else if (obst_out[2][20] == 1'b1)
			obst = obst_out[2];
		else if (obst_out[3][20] == 1'b1)
			obst = obst_out[3];
		else if (obst_out[4][20] == 1'b1)
			obst = obst_out[4];
		else if (obst_out[5][20] == 1'b1)
			obst = obst_out[5];
		else if (obst_out[6][20] == 1'b1)
			obst = obst_out[6];
		else if (obst_out[7][20] == 1'b1)
			obst = obst_out[7];
		else if (obst_out[8][20] == 1'b1)
			obst = obst_out[8];
		else if (obst_out[9][20] == 1'b1)
			obst = obst_out[9];
		else if (obst_out[10][20] == 1'b1)
			obst = obst_out[10];
		else if (obst_out[11][20] == 1'b1)
			obst = obst_out[11];
		else if (obst_out[12][20] == 1'b1)
			obst = obst_out[12];
		else if (obst_out[13][20] == 1'b1)
			obst = obst_out[13];
		else if (obst_out[14][20] == 1'b1)
			obst = obst_out[14];
		else if (obst_out[15][20] == 1'b1)
			obst = obst_out[15];
		else
			obst = defaultsig;
	end

	obstacle obst1(.*, .x_init(tl_obj_x[0]), .y_init(tl_obj_y[0]), .is_obst(is_obst_out[0]), .is_obst_2(is_obst_2_out[0]), .hitobj1(hitobj1_out[0]), .hitobj2(hitobj2_out[0]), .obst(obst_out[0]), .done_out(donecount[0]));
	obstacle obst2(.*, .x_init(tl_obj_x[1]), .y_init(tl_obj_y[1]), .is_obst(is_obst_out[1]), .is_obst_2(is_obst_2_out[1]), .hitobj1(hitobj1_out[1]), .hitobj2(hitobj2_out[1]), .obst(obst_out[1]), .done_out(donecount[1]));
	obstacle obst3(.*, .x_init(tl_obj_x[2]), .y_init(tl_obj_y[2]), .is_obst(is_obst_out[2]), .is_obst_2(is_obst_2_out[2]), .hitobj1(hitobj1_out[2]), .hitobj2(hitobj2_out[2]), .obst(obst_out[2]), .done_out(donecount[2]));
	obstacle obst4(.*, .x_init(tl_obj_x[3]), .y_init(tl_obj_y[3]), .is_obst(is_obst_out[3]), .is_obst_2(is_obst_2_out[3]), .hitobj1(hitobj1_out[3]), .hitobj2(hitobj2_out[3]), .obst(obst_out[3]), .done_out(donecount[3]));
	obstacle obst5(.*, .x_init(tl_obj_x[4]), .y_init(tl_obj_y[4]), .is_obst(is_obst_out[4]), .is_obst_2(is_obst_2_out[4]), .hitobj1(hitobj1_out[4]), .hitobj2(hitobj2_out[4]), .obst(obst_out[4]), .done_out(donecount[4]));
	obstacle obst6(.*, .x_init(tl_obj_x[5]), .y_init(tl_obj_y[5]), .is_obst(is_obst_out[5]), .is_obst_2(is_obst_2_out[5]), .hitobj1(hitobj1_out[5]), .hitobj2(hitobj2_out[5]), .obst(obst_out[5]), .done_out(donecount[5]));
	obstacle obst7(.*, .x_init(tl_obj_x[6]), .y_init(tl_obj_y[6]), .is_obst(is_obst_out[6]), .is_obst_2(is_obst_2_out[6]), .hitobj1(hitobj1_out[6]), .hitobj2(hitobj2_out[6]), .obst(obst_out[6]), .done_out(donecount[6]));
	obstacle obst8(.*, .x_init(tl_obj_x[7]), .y_init(tl_obj_y[7]), .is_obst(is_obst_out[7]), .is_obst_2(is_obst_2_out[7]), .hitobj1(hitobj1_out[7]), .hitobj2(hitobj2_out[7]), .obst(obst_out[7]), .done_out(donecount[7]));
	obstacle obst9(.*,  .x_init(tl_obj_x[8]), .y_init(tl_obj_y[8]), .is_obst(is_obst_out[8]), .is_obst_2(is_obst_2_out[8]), .hitobj1(hitobj1_out[8]), .hitobj2(hitobj2_out[8]), .obst(obst_out[8]), .done_out(donecount[8]));
	obstacle obst10(.*, .x_init(tl_obj_x[9]), .y_init(tl_obj_y[9]),  .is_obst(is_obst_out[9]), .is_obst_2(is_obst_2_out[9]), .hitobj1(hitobj1_out[9]), .hitobj2(hitobj2_out[9]), .obst(obst_out[9]), .done_out(donecount[9]));
	obstacle obst11(.*, .x_init(tl_obj_x[10]), .y_init(tl_obj_y[10]),  .is_obst(is_obst_out[10]), .is_obst_2(is_obst_2_out[10]), .hitobj1(hitobj1_out[10]), .hitobj2(hitobj2_out[10]), .obst(obst_out[10]), .done_out(donecount[10]));
	obstacle obst12(.*, .x_init(tl_obj_x[11]), .y_init(tl_obj_y[11]),  .is_obst(is_obst_out[11]), .is_obst_2(is_obst_2_out[11]), .hitobj1(hitobj1_out[11]), .hitobj2(hitobj2_out[11]), .obst(obst_out[11]), .done_out(donecount[11]));
	obstacle obst13(.*, .x_init(tl_obj_x[12]), .y_init(tl_obj_y[12]),  .is_obst(is_obst_out[12]), .is_obst_2(is_obst_2_out[12]), .hitobj1(hitobj1_out[12]), .hitobj2(hitobj2_out[12]), .obst(obst_out[12]), .done_out(donecount[12]));
	obstacle obst14(.*, .x_init(tl_obj_x[13]), .y_init(tl_obj_y[13]),  .is_obst(is_obst_out[13]), .is_obst_2(is_obst_2_out[13]), .hitobj1(hitobj1_out[13]), .hitobj2(hitobj2_out[13]), .obst(obst_out[13]), .done_out(donecount[13]));
	obstacle obst15(.*, .x_init(tl_obj_x[14]), .y_init(tl_obj_y[14]),  .is_obst(is_obst_out[14]), .is_obst_2(is_obst_2_out[14]), .hitobj1(hitobj1_out[14]), .hitobj2(hitobj2_out[14]), .obst(obst_out[14]), .done_out(donecount[14]));
	obstacle obst16(.*, .x_init(tl_obj_x[15]), .y_init(tl_obj_y[15]),  .is_obst(is_obst_out[15]), .is_obst_2(is_obst_2_out[15]), .hitobj1(hitobj1_out[15]), .hitobj2(hitobj2_out[15]), .obst(obst_out[15]), .done_out(donecount[15]));
	// obstacle #(.seedx(10'd), .seedy(10'd)) obst17(.*, .is_obst(is_obst_out[16]), .is_obst_2(is_obst_2_out[16]), .hitobj1(hitobj1_out[16]), .hitobj2(hitobj2_out[16]), .obst(obst_out[16]), .done_out(donecount[16]));
	// obstacle #(.seedx(10'd), .seedy(10'd)) obst18(.*, .is_obst(is_obst_out[17]), .is_obst_2(is_obst_2_out[17]), .hitobj1(hitobj1_out[17]), .hitobj2(hitobj2_out[17]), .obst(obst_out[17]), .done_out(donecount[17]));
	// obstacle #(.seedx(10'd), .seedy(10'd)) obst19(.*, .is_obst(is_obst_out[18]), .is_obst_2(is_obst_2_out[18]), .hitobj1(hitobj1_out[18]), .hitobj2(hitobj2_out[18]), .obst(obst_out[18]), .done_out(donecount[18]));
	// obstacle #(.seedx(10'd), .seedy(10'd)) obst20(.*, .is_obst(is_obst_out[19]), .is_obst_2(is_obst_2_out[19]), .hitobj1(hitobj1_out[19]), .hitobj2(hitobj2_out[19]), .obst(obst_out[19]), .done_out(donecount[19]));

endmodule // obstacle_gen