//-------------------------------------------------------------------------
//      lab8.sv                                                          --
//      Christine Chen                                                   --
//      Fall 2014                                                        --
//                                                                       --
//      Modified by Po-Han Huang                                         --
//      10/06/2017                                                       --
//                                                                       --
//      Fall 2017 Distribution                                           --
//                                                                       --
//      For use with ECE 385 Lab 8                                       --
//      UIUC ECE Department                                              --
//-------------------------------------------------------------------------
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!

module lab8(input               CLOCK_50,
            input        [3:0]  KEY,          //bit 0 is set up as Reset
            input  logic [7:0]	SW,
            output logic [7:0] LEDG,

            output logic [6:0]  HEX0, HEX1, HEX2, HEX3, HEX4, HEX5, HEX6, HEX7,
            // VGA Interface 
            output logic [7:0]  VGA_R,        //VGA Red
                                 VGA_G,        //VGA Green
                                 VGA_B,        //VGA Blue
            output logic        VGA_CLK,      //VGA Clock
                                 VGA_SYNC_N,   //VGA Sync signal
                                 VGA_BLANK_N,  //VGA Blank signal
                                 VGA_VS,       //VGA virtical sync signal
                                 VGA_HS,       //VGA horizontal sync signal
											
            // CY7C67200 Interface
            inout  wire  [15:0] OTG_DATA,     //CY7C67200 Data bus 16 Bits
            output logic [1:0]  OTG_ADDR,     //CY7C67200 Address 2 Bits
            output logic        OTG_CS_N,     //CY7C67200 Chip Select
                                 OTG_RD_N,     //CY7C67200 Write
                                 OTG_WR_N,     //CY7C67200 Read
                                 OTG_RST_N,    //CY7C67200 Reset
            input               OTG_INT,      //CY7C67200 Interrupt
				 
             // SDRAM Interface for Nios II Software
            output logic [12:0] DRAM_ADDR,    //SDRAM Address 13 Bits
            inout  wire  [31:0] DRAM_DQ,      //SDRAM Data 32 Bits
            output logic [1:0]  DRAM_BA,      //SDRAM Bank Address 2 Bits
            output logic [3:0]  DRAM_DQM,     //SDRAM Data Mast 4 Bits
            output logic        DRAM_RAS_N,   //SDRAM Row Address Strobe
                                 DRAM_CAS_N,   //SDRAM Column Address Strobe
                                 DRAM_CKE,     //SDRAM Clock Enable
                                 DRAM_WE_N,    //SDRAM Write Enable
                                 DRAM_CS_N,    //SDRAM Chip Select
                                 DRAM_CLK,      //SDRAM Clock

            // I2C Interface for Audio
            /*
            inout  I2C_SDAT, // I2C Data
            output I2C_SCLK, // I2C Clock
            */
            
            output logic AUD_XCK,
            output logic AUD_MCLK,
                         AUD_DACDAT,

            inout 		AUD_BCLK,
            input       AUD_ADCDAT,
            output      AUD_DACLRCK,
                        AUD_ADCLRCK
                    );
//-------------------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------------------
//-----------AUDIO MODULE INSTANTIATED HERE-------------------------------------------------------------------------------------- 
    logic data_over, adc_full;
    audio aud_inst(.*);
    logic restart;
    logic [31:0] ADCDATA;
    logic LEDG1;

    assign LEDG[4] = LEDG1;

    assign LEDG[0] = AUD_DACLRCK;
    assign LEDG[1] = AUD_ADCLRCK;
    assign LEDG[2] = AUD_BCLK;

    assign LEDG[3] = Clk_27;


    assign restart = (Done_sig && (~KEY[3] || enter));
    logic Reset_h, Clk, Clk_27;
    logic [31:0] keycode;
	logic vgaclk;

    assign Clk = CLOCK_50;
    assign Reset_h = ~KEY[0] || restart;
    
    logic [1:0] hpi_addr;
    logic [15:0] hpi_data_in, hpi_data_out;
    logic hpi_r, hpi_w, hpi_cs, hpi_reset;
    
    // Interface between NIOS II and EZ-OTG chip
    hpi_io_intf hpi_io_inst(
                            .Clk(CLOCK_50),
                            .Reset(Reset_h),
                            // signals connected to NIOS II
                            .from_sw_address(hpi_addr),
                            .from_sw_data_in(hpi_data_in),
                            .from_sw_data_out(hpi_data_out),
                            .from_sw_r(hpi_r),
                            .from_sw_w(hpi_w),
                            .from_sw_cs(hpi_cs),
                            .from_sw_reset(hpi_reset),
                            // signals connected to EZ-OTG chip
                            .OTG_DATA(OTG_DATA),    
                            .OTG_ADDR(OTG_ADDR),    
                            .OTG_RD_N(OTG_RD_N),    
                            .OTG_WR_N(OTG_WR_N),    
                            .OTG_CS_N(OTG_CS_N),
                            .OTG_RST_N(OTG_RST_N)
    );
     
    // You need to make sure that the port names here match the ports in Qsys-generated codes.
    nios_system nios_system(
                             .clk_clk(CLOCK_50),
							 .clk_27_clk(Clk_27), 
                             .reset_reset_n(1'b1),    // Never reset NIOS
                             .sdram_wire_addr(DRAM_ADDR), 
                             .sdram_wire_ba(DRAM_BA),   
                             .sdram_wire_cas_n(DRAM_CAS_N),
                             .sdram_wire_cke(DRAM_CKE),  
                             .sdram_wire_cs_n(DRAM_CS_N), 
                             .sdram_wire_dq(DRAM_DQ),   
                             .sdram_wire_dqm(DRAM_DQM),  
                             .sdram_wire_ras_n(DRAM_RAS_N),
                             .sdram_wire_we_n(DRAM_WE_N), 
                             .sdram_clk_clk(DRAM_CLK),
                             .keycode_export(keycode),  
                             .otg_hpi_address_export(hpi_addr),
                             .otg_hpi_data_in_port(hpi_data_in),
                             .otg_hpi_data_out_port(hpi_data_out),
                             .otg_hpi_cs_export(hpi_cs),
                             .otg_hpi_r_export(hpi_r),
                             .otg_hpi_w_export(hpi_w),
                             .otg_hpi_reset_export(hpi_reset),
							 .vga_clk_clk(vgaclk)
    );

//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!

    //ANIMATION COUNTER
	    logic [5:0] counter;
	    logic anim_1; logic enter;
		//using VGA_HS to make the counter
	    //counter for animation
		always_ff @ (posedge VGA_VS)
		begin
				if (counter == 6'd60)
					counter <= 6'd0;
				else
					counter <= counter + 1;
		end

	    //for animation
	    always_comb begin
	        if (counter <= 6'd15)
	            anim_1 = 0;
	        else if (counter > 6'd15 && counter < 6'd30)
	            anim_1 = 1;
	        else if (counter >= 6'd30 && counter < 6'd45)
	            anim_1 = 0;
	        else
	            anim_1 = 1;
	    end
    

	logic ai_w, ai_a, ai_s, ai_d, ai_shoot;
    Skynet arnavs_stupidly_good_ai(.*);

    // Use PLL to generate the 25MHZ VGA_CLK. DONE in PLL
    vga_clk vga_clk_instance(.inclk0(Clk), .c0(VGA_CLK));


	logic [9:0] DY, DX;
	logic player1, player2;
    logic w, a, s, d, up, down, right, left, space, numenter;
	logic [1:0] fdir, sdir;
	logic [9:0] fX, fY, sX, sY;
    logic [9:0] Tank1X, Tank1Y, Tank2X, Tank2Y;
    VGA_controller vga_controller_instance(.*, .Reset(Reset_h), .VGA_CLK(VGA_CLK), .DrawX(DX), .DrawY(DY));

    //REMEMBER TO CHANGE THE INPUT FOR WIN ONCE YOU INPUT COLLISIONS FOR THE BULLET
    logic [2:0] tilenum;		//Done sig is to display the gameover screen
    logic Start_sig, Done_sig;	//Start sig is to display the beginning screen
    logic Enter_key, Win;
    assign Enter_key = (enter || ~KEY[3]);
    statemachine stae(.*, .DrawX(DX), .DrawY(DY));

    logic key_up, key_down, key_left, key_right, key_shoot;
    logic ai_enable;
    always_comb begin : AIENABLE
        if (ai_enable) begin
            key_up = ai_w;
            key_down = ai_s;
            key_left = ai_a;
            key_right = ai_d;
            key_shoot = ai_shoot;
        end
        else begin
            key_up = w || SW[0];
            key_down = s || SW[1];
            key_left = a || SW[2];
            key_right = d || SW[3];
            key_shoot = shoot1;
        end
    end



    logic stop;
    assign stop = ~Win && ~Start_sig;
    ball #(.Ball_X_Center(10'd213)) ball_first(.*, .pick(tank1pick), .is_obst(is_obst), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DX), .DrawY(DY), .is_ball(player1), .w_on(key_up && stop), .a_on(key_left && stop), .s_on(key_down && stop), .d_on(key_right && stop), .dir(fdir), .spriteX(fX), .spriteY(fY), .BallX(Tank1X), .BallY(Tank1Y));
    ball #(.Ball_X_Center(10'd426)) ball_second(.*, .pick(tank2pick), .is_obst(is_obst_2), .Reset(Reset_h), .frame_clk(VGA_VS), .DrawX(DX), .DrawY(DY), .is_ball(player2), .w_on((up || SW[4]) && stop), .a_on((left || SW[5]) && stop), .s_on((down || SW[6]) && stop), .d_on((right || SW[7]) && stop), .dir(sdir), .spriteX(sX), .spriteY(sY), .BallX(Tank2X), .BallY(Tank2Y));
	
	//player's bullet positions and sprite positions
	logic [9:0] p1_BullX, p1_BullY, p1_bullspx, p1_bullspy;
	logic [9:0] p2_BullX, p2_BullY, p2_bullspx, p2_bullspy;
	logic p1_bullet, p2_bullet;
	logic [1:0] p1_bulldir, p2_bulldir;
	logic hittank1, hittank2;

	logic shoot1, shoot2;
	assign shoot1 = (space || ~KEY[1]);
	assign shoot2 = (numenter || ~KEY[2]);

	logic is_shot1, is_shot2;
    bullet bullet_player1(.*, .hitobj(hitobj1), .shot(is_shot1), .hittank(hittank2), .bulldir(p1_bulldir), .TankX(Tank1X), .TankY(Tank1Y), .frame_clk(VGA_VS), .dir(fdir), .shoot(key_shoot && stop), .is_bullet(p1_bullet), .BulletX(p1_BullX), .BulletY(p1_BullY), .BullSpriteX(p1_bullspx), .BullSpriteY(p1_bullspy));
    bullet bullet_player2(.*, .hitobj(hitobj2), .shot(is_shot2), .hittank(hittank1), .bulldir(p2_bulldir), .TankX(Tank2X), .TankY(Tank2Y), .frame_clk(VGA_VS), .dir(sdir), .shoot(shoot2 && stop), .is_bullet(p2_bullet), .BulletX(p2_BullX), .BulletY(p2_BullY), .BullSpriteX(p2_bullspx), .BullSpriteY(p2_bullspy));

    logic [3:0] hitcount;
	logic is_obst, is_obst_2;
    logic hitobj1, hitobj2; //for the bullets
	logic [20:0] obst;
    logic [9:0] obj_cnt;
	//obstacle #(.tl_corner_x(10'd313), .tl_corner_y(10'd233)) oh(.*, .Tank1_X(Tank1X), .Tank1_Y(Tank1Y), .TankSize(10'd8), .Tank2_X(Tank2X), .Tank2_Y(Tank2Y), .DrawX(DX), .DrawY(DY));
    logic Gen_Done2, Gen;
    obstacle_gen rand_obst(.*, .DrawX(DX), .DrawY(DY)); //random obstacle generator

    //Pickup Generation
    logic tank1pick, tank2pick;
    logic [20:0] pickup;
    pickup_gen items_inst(.*, .DrawX(DX), .DrawY(DY));



    color_mapper color_instance( .*, .first_X(fX), .first_Y(fY), .second_X(sX), .second_Y(sY), .first_dir(fdir), .second_dir(sdir), .is_ball_1(player1), .is_ball_2(player2), .DrawX(DX), .DrawY(DY));
    
	//Checks if the tanks collide
    logic collide; //auto assign
    tankcollision collisionchk(.*);
    //Bullet Collision
    bullet_collision col_inst(.*, .hittank1(hittank1), .hittank2(hittank2));

    //health system
    logic [9:0] hp1_drawx, hp1_drawy, hp2_drawx, hp2_drawy;
    logic [2:0] is_hp1, is_hp2;
    health health_inst(.*);

    logic press1, press2;
	key_reader keyread(.*, .keyc(keycode), .w_on(w), .a_on(a), .s_on(s), .d_on(d),
													 .lef_on(left), .rig_on(right), .up_on(up), .dow_on(down),
													 .pl_1shoot(space), .pl_2shoot(numenter));
	logic [3:0] hp1, hp2;
    // Display keycode on hex display
    HexDriver hex_inst_0 ({3'b0,data_over}, HEX0);
    HexDriver hex_inst_1 ({3'b0,adc_full}, HEX1);
	 
	HexDriver hex_inst_2 ({3'b0, Win}, HEX2);
	HexDriver hex_inst_3 ({3'b0, Done_sig}, HEX3);
	HexDriver hex_inst_4 (keycode[19:16], HEX4);
	HexDriver hex_inst_5 (obj_cnt[3:0], HEX5); 
	HexDriver hex_inst_6 (hp2, HEX6); 
    HexDriver hex_inst_7 (hp1, HEX7); 
	
    /**************************************************************************************
        ATTENTION! Please answer the following quesiton in your lab report! Points will be allocated for the answers!
        Hidden Question #1/2:
        What are the advantages and/or disadvantages of using a USB interface over PS/2 interface to
             connect to the keyboard? List any two.  Give an answer in your Post-Lab.
    **************************************************************************************/
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!
//REMEMBER TO UNCOMMENT ROM INITIALIZATION (COLORMAPPER) AND BACKGROUND INITIALIZATION (STATEMACHINE)!!!!!!!!!!!!

endmodule
