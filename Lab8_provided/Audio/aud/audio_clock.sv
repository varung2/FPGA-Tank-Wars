module audio_clock (
//	Audio Side
   output logic AUD_BCLK,
   output AUD_DACLRCK,
//	Control Signals
   input AUD_CTRL_CLK,
   input reset
);
/*
*  Note: Reference clock seems to be 18 Mhz
*  Work it backward: 18 MHz /( 48 kHz *16 * 2 ) = 11.7185
*  The closest integer is 12, so actual sample rate is 46.875 kHz.
*/
parameter	REF_CLK		=	18432000;	// 18.432 MHz
parameter	SAMPLE_RATE	=	48000;		// 48 KHz
parameter	DATA_WIDTH	=	16;		// 16 Bits
parameter	CHANNEL_NUM	=	2;		// Dual Channel

//	Internal Registers and Wires
logic [3:0] BCK_DIV;
logic [8:0] LRCK_1X_DIV;
logic [7:0] LRCK_2X_DIV;
logic [6:0] LRCK_4X_DIV;
logic LRCK_1X;
logic LRCK_2X;
logic LRCK_4X;

//  AUD_BCK Generator
always_ff @(posedge AUD_CTRL_CLK or posedge reset)
begin
	if(reset)
	begin
	  BCK_DIV <= 4'h0;
	  AUD_BCLK <= 1'b0;
	end
	else
	begin
	  // REF_CLK/SAMPLE_RATE = 384, 384/(DATA_WIDTH*CHANNEL_NUM) = 12
	  //  12/2 - 1 = 5
	  if (BCK_DIV >= REF_CLK/(SAMPLE_RATE*DATA_WIDTH*CHANNEL_NUM*2)-1 )
	  begin
		BCK_DIV	 <= 4'h0;
		AUD_BCLK <= ~AUD_BCLK;
	  end
	  else BCK_DIV <= BCK_DIV+1'b1;
	end
end
//
//  AUD_LRCK Generator
//    AUD_DACLRCK is high for left and low for right channel
//
always_ff @(posedge AUD_CTRL_CLK or posedge reset)
begin
	if(reset)
	begin
		LRCK_1X_DIV	<=	0;
		LRCK_2X_DIV	<=	0;
		LRCK_4X_DIV	<=	0;
		LRCK_1X		<=	0;
		LRCK_2X		<=	0;
		LRCK_4X		<=	0;
	end
	else
	begin
		//LRCK 1X
		if(LRCK_1X_DIV >= REF_CLK/(SAMPLE_RATE*2)-1 )
		begin
			LRCK_1X_DIV <=	0;
			LRCK_1X	<= ~LRCK_1X;
		end
		else LRCK_1X_DIV <= LRCK_1X_DIV+1'b1;
		// LRCK 2X
		if(LRCK_2X_DIV >= REF_CLK/(SAMPLE_RATE*4)-1 )
		begin
			LRCK_2X_DIV <= 0;
			LRCK_2X	<= ~LRCK_2X;
		end
		else LRCK_2X_DIV <= LRCK_2X_DIV+1'b1;
		// LRCK 4X
		if(LRCK_4X_DIV >= REF_CLK/(SAMPLE_RATE*8)-1 )
		begin
			LRCK_4X_DIV <= 0;
			LRCK_4X	<= ~LRCK_4X;
		end
		else LRCK_4X_DIV <= LRCK_4X_DIV+1'b1;
	end
end
assign	AUD_DACLRCK = LRCK_1X;

endmodule
