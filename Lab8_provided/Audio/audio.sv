module audio(
	input logic Clk, Reset_h, Clk_27,

	output logic LEDG1,
	output logic AUD_MCLK,
	output logic AUD_BCLK,
	input  logic AUD_ADCDAT,
	output logic AUD_DACDAT,
	output logic AUD_DACLRCK,
	output logic AUD_XCK,

	output logic AUD_ADCLRCK,

	output logic [31:0] ADCDATA
	
	/*
	inout I2C_SDAT,
	output I2C_SCLK
	*/
	);
	

	assign LEDG1 = AUD_CTRL_CLK;
	logic [15:0] ldata, rdata, signal;
	logic [7:0] counter;
	logic AUD_CTRL_CLK;
	logic [15:0] audio_inL, audio_inR;
	logic [15:0] audio_outL, audio_outR;
	logic [7:0] index;
	logic DLY_RST;
	//mono sound
	assign ldata = ~signal + 1'b1;
	assign rdata = ~signal + 1'b1;

	Reset_Delay r0(	.iCLK(Clk),.oRESET(DLY_RST) );
	VGA_Audio_PLL p1 (.areset(Reset_h), .inclk0(Clk_27), .c0(), .c1(AUD_CTRL_CLK), .c2());

	/*
	I2C_AV_Config u3(.iCLK(Clk), .iRST_N(~DLY_RST), .I2C_SCLK, .I2C_SDAT);
	*/

	audio_clock u4(	.AUD_BCLK(AUD_BCLK), .AUD_DACLRCK, .AUD_CTRL_CLK, .reset(Reset_h));

	audio_converter u5( .AUD_BCLK(AUD_BCLK), .AUD_DACLRCK(AUD_DACLRCK), .AUD_ADCDAT(AUD_ADCDAT), .AUD_DACDAT(AUD_DACDAT), .reset(~Reset_h), .audio_outL(audio_outL), .audio_outR(audio_outR), .AUD_inL(audio_inL), .AUD_inR(audio_inR));

	parameter PERIOD = 48;
	
	always @(negedge AUD_DACLRCK) begin
		if (index<PERIOD-1) index <= index + 1'b1;
		else index <= 8'h00;
	end

	assign	AUD_ADCLRCK	=	AUD_DACLRCK;
	assign	AUD_XCK		=	AUD_CTRL_CLK;

	sine_table sin(.index(index), .signal(audio_outR));

	//1. In this module initialize the ram to hold the music files, or make your own music based on a couple predefined signals
	//2. initialize the state machine to interact with the audio interface
	//3. Connect this module with the top level of lab8, Test?
	//Notes: Use the data_over signal to increment your counter
 	
	// enum logic [3:0] {Begin, Init, Init_Done, Dat_Trans, Data_fin} State, Next_State;

	// always_ff @(posedge Clk) begin : ALYWAYS1
	// 	if(Reset_h) begin
	// 		State <= Begin;
	// 	end else begin
	// 		State <= Next_State;
	// 	end
	// end
	// always_comb begin : NEXT_STATE_LOGIC
	// 	unique case (State)
	// 		Begin: Next_State = Init;
	// 		Init: begin
	// 			if (init_finish)
	// 				Next_State = Init_Done;
	// 			else
	// 				Next_State = Init;
	// 		end
	// 		Init_Done: Next_State = Dat_Trans;
	// 		Dat_Trans: begin
	// 			if (data_over)
	// 				Next_State = Data_fin;
	// 			else
	// 				Next_State = Dat_Trans;
	// 		end
	// 		Data_fin: begin
	// 			if (~data_over)
	// 				Next_State = Dat_Trans;
	// 			else
	// 				Next_State = Data_fin;
	// 		end
	// 	endcase // Stateendcase
	// end
	// always_comb begin : CONTROL_LOGIC
	// 	case (State)
	// 		Begin: initialize = 1'b0;
	// 		Init: initialize = 1'b1;
	// 		Init_Done: initialize = 1'b0;
	// 		Dat_Trans: initialize = 1'b0;
	// 		Data_fin: initialize = 1'b0;
	// 	endcase // State
	// end

endmodule // audio


