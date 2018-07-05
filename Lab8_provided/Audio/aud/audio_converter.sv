module audio_converter (
	// Audio side
	input AUD_BCLK,    // Audio bit clock
	input AUD_DACLRCK,   // left-right clock
	input AUD_ADCDAT,
	output AUD_DACDAT,
	// Controller side
	input reset,  // reset
	input [15:0] audio_outL,
	input [15:0] audio_outR,
	output logic[15:0] AUD_inL,
	output logic[15:0] AUD_inR
);


//	16 Bits - MSB First
// Clocks in the ADC input
// and sets up the output bit selector

logic [3:0] SEL_Cont;
always_ff @(negedge AUD_BCLK or posedge reset)
begin
	if(reset) SEL_Cont <= 4'h0;
	else
	begin
	   SEL_Cont <= SEL_Cont+1'b1; //4 bit counter, so it wraps at 16
	   if (AUD_DACLRCK) AUD_inL[~(SEL_Cont)] <= AUD_ADCDAT;
	   else AUD_inR[~(SEL_Cont)] <= AUD_ADCDAT;
	end
end

// output the DAC bit-stream
assign AUD_DACDAT = (AUD_DACLRCK)? audio_outL[~SEL_Cont]: audio_outR[~SEL_Cont] ;

endmodule
