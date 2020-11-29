`timescale 1ns / 1ps

module vm(
    //output
    output reg [8:6] led = 3'b000, //all led off by default
    output wire [3:0] an,
    output wire dp,
    output reg [6:0] seg,
    
    //input
    input btnR,btnD,btnL,btnC, //buttons
    input clk,                 //clock
    input [8:6] sw             //switch
    );
    
    
PB_Pulse_Generator R_Gen(
    .clk(clk),
    .PB(btnR),
    .pulse(pulse_R)

);

PB_Pulse_Generator L_Gen(
    .clk(clk),
    .PB(btnL),
    .pulse(pulse_L)

);

PB_Pulse_Generator D_Gen(
    .clk(clk),
    .PB(btnD),
    .pulse(pulse_D)

);

PB_Pulse_Generator C_Gen(
    .clk(clk),
    .PB(btnC),
    .pulse(pulse_C)

);


/********************************
*** Signals Declaration
********************************/
    //Constants
    reg[3:0] a = 4'd0,b = 4'd0,c = 4'd0, minus = 4'b0; //$minusa.bc
    //All Max Counters //tbc
    parameter max_count = 100_000_00;	//0.5 seconds count limit 50_000_000; Simulation value can be 5
    parameter max_count3s = 300_000_000;	//3 seconds count limit 300_000_000; Simulation value can be 3
    parameter max_count20 = 400_000; //400_000 EN's counter
    parameter max_blink5 = 500_000_000;	//0.5 seconds count limit 50_000_000; Simulation value can be 5
                                        //remember to change modulus at vend state

    //All Current Counters
    reg [31:0] count = 0;	//Count variable 32 bits
    reg [31:0] count3s = 0;	//Count variable 32 bits
    reg [19:0] cntr20 = 0;	// 20-bit counter to divide the 100MHz on board clock
    reg [31:0] blink5 = 0;	//Count variable 32 bits
    
    //All counters trigger
    reg trig = 1'b0;		//1-clock pulse trigger
    reg delay3s = 1'b0;		//1-clock pulse trigger
    reg en = 1'b0;          // en=1 will increment the step by 1
    reg blinktrig = 1'b0;   //1-clock pulse trigger
    
    reg activate_delay3s = 1'b0; // this will activate the 3s delay when transitioning from state 4 to 1
    reg activate_blink5 = 1'b0; // this will activate the led to blink 5 times when in state 3
    

    
    //States
    reg [1:0] current_state = 0;
    reg [1:0] next_state = 0;
    
    
    //SSD Initialize
    reg [1:0] step = 2'b00 ;      // step will determine the mux output
    reg [3:0] mux_out = 4'd0;     // mux_out will be any of the four val depending on step
    
	
/********************************
*** Sequential Logic
********************************/
    always@(posedge clk)begin
        if (cntr20 >= max_count20) //en counter
            cntr20 <= 20'd0;
        else
            cntr20 <= cntr20 + 1;
        
        if (count >= max_count) //trig counter
            count <= 32'd0;
        else
            count <= count + 1;
        
        
    end

    //Enable Signal Logic for 2 bit counter
    always @ (posedge clk) begin
         if (cntr20 == max_count20 - 1)begin //en toggler - en is for changing step
           en <= 1'b1;
         end else
           en <= 1'b0;
         
         if (count == max_count - 1)begin //trig toggler - trig is for changing/affecting led
           trig <= 1'b1;
         end else
           trig <= 1'b0;
         
         if (count3s == max_count3s - 1)begin //3s wait toggle - waits for 3s before going to state 1
           delay3s <= 1'b1;
         end else
           delay3s <= 1'b0;
     end
   

    //2 bit couter with enable
    always@(posedge clk)begin
        if(en) begin 
          step <= step + 1;
        end else begin
          step <= step;
        end
    end  
   
   
    // 2 to 4 Encoder
    assign an[0] = !(step == 2'b00);  //an0 is logic 0 when step is 00
    assign an[1] = !(step == 2'b01);
    assign an[2]= !(step == 2'b10);
    assign an[3] = !(step == 2'b11);
    assign dp = !(step == 2'b10);   //Default position. Might need to be changed according to specific system
    
    // 4 to 1 Multiplexer
    always@(*) begin //$-a.bc
        if (step == 2'b00) begin
            mux_out = c;
        end else if (step == 2'b01) begin
            mux_out = b;
        end else if (step == 2'b10) begin
            mux_out = a;
        end else if (step == 2'b11) begin
            mux_out = minus;
        end else begin
            mux_out = 4'bzzzz;
        end
    end
    
    always @(posedge clk) //state identification //tbc
    begin
        case (current_state)
            2'b00 :
            begin //State is IDLE   
                
                count3s <= 32'd0;
                
                minus <= 1'b0;
                if(trig == 1'b1)begin //trig ON
                    led[8] <= ~led[8]; //toggle LED 8
                    led[7] <= ~led[7]; //toggle LED 7
                    led[6] <= ~led[6]; //toggle LED 6
                end
               
               
                if(pulse_R == 1'b1 || pulse_D == 1'b1 || pulse_L == 1'b1)begin
                    
                    if(pulse_R == 1'b1)begin //add 50c
                        
                        a <= a;
                        b <= b + 5;
                        current_state <= 2'b01;
                        led <= 3'b000;
                    end
                    
                    if(pulse_L == 1'b1)begin //add $1
                        a <= a + 2;
                        b <= b;
                        current_state <= 2'b01;
                    end
                    
                    if(pulse_D == 1'b1)begin //add $2
                        a <= a + 1;
                        b <= b;
                        current_state <= 2'b01;
                        led <= 3'b000;
                    end
                 
                end
                
            end //end of current_state 00
            
            2'b01 :
            begin //State is COIN
                if(pulse_R == 1'b1)begin //add 50c
                    a <= a;
                    b <= b + 4'd5;
                end
               if(pulse_D == 1'b1)begin //add $1
                    a <= a + 4'd1;
                    b <= b;
                end
                
                if(pulse_L == 1'b1)begin //add $2
                    a <= a + 4'd2;
                    b <= b;
                end
                
                if(pulse_C == 1'b1) begin
                    current_state <= 2'b11;
                end
                  
                if(b > 4'd9)begin //makes sure if b = 10(basically 100c), a+1 and b=0
                  a <= a + 1;
                  b <= b - 10;
                end
                
                led <= 3'b000;
                if((a >= 4'd2 && b >= 4'd5 && c >= 4'd0) || (a > 4'd2) )begin //if can buy small coco
                  led <= 3'b100;
                end
                
                if((a >= 4'd3 && b >= 4'd5 && c >= 4'd0) || (a > 4'd3) )begin //if can buy medium coco
                  led <= 3'b110;
                end
                
                if((a >= 4'd4 && b >= 4'd5 && c >= 4'd0) || (a > 4'd4) )begin //if can buy large coco
                  led <= 3'b111;
                end
                
                if(sw[8] == 1'b1 && led[8] == 1'b1)begin
                    if(b == 4'd0)begin
                        b <= 5;
                        a <= a - 3;
                    end
                    
                    else if(b == 4'd5)begin
                        b <= 0;
                        a <= a - 2;
                    end
                    
                    activate_blink5 <= 1'b1;
                    current_state <= 2'b10;
                end
                  
                if(sw[7] == 1'b1 && led[7] == 1'b1)begin
                    if(b == 4'd0)begin
                        b <= 5;
                        a <= a - 4;
                    end
                    
                    else if(b == 4'd5)begin
                        b <= 0;
                        a <= a - 3;
                    end
                    
                    activate_blink5 <= 1'b1;
                    current_state <= 2'b10;
                end
                
                if(sw[6] == 1'b1 && led[6] == 1'b1)begin
                    if(b == 4'd0)begin
                        b <= 5;
                        a <= a - 5;
                    end
                    
                    else if(b == 4'd5)begin
                        b <= 0;
                        a <= a - 4;
                    end
                    
                    activate_blink5 <= 1'b1;
                    current_state <= 2'b10;
                end
                  
            end //end of current_state 01
            
            2'b10 :
            begin //State is VEND
                  if(sw[8] == 1'b1 && activate_blink5 == 1'b1)begin //if any one of them is activated then
                    
                    if(activate_blink5 == 1'b1)begin //if state 3 and blink 5 times is activated
                        if (blink5 == max_blink5 - 1) begin
                            blink5 <= 32'd0;
                            activate_blink5 = 1'b0; //when switch is off, this will deactivate counter
                            led <= 3'b000;
                            current_state <= 2'b11;
                        end else
                            blink5 <= blink5 + 1;
                    end
                    
                    if((blink5%050_000_000 == 0) && (activate_blink5 == 1'b1))begin //when counter is offed then blink will stop
                        led[8] <= ~led[8];
                    end
                    
                  end
                  
                  if(sw[7] == 1'b1 && activate_blink5 == 1'b1) begin
                        if(activate_blink5 == 1'b1)begin //if state 3 and blink 5 times is activated
                            if (blink5 == max_blink5 - 1) begin
                                blink5 <= 32'd0;
                                activate_blink5 = 1'b0; //when switch is off, this will deactivate counter
                                led <= 3'b000;
                                current_state <= 2'b11;
                            end else
                                blink5 <= blink5 + 1;
                    end
                    
                    if((blink5%050_000_000 == 0) && (activate_blink5 == 1'b1))begin //when counter is offed then blink will stop
                        led[7] <= ~led[7];
                    end
                  end
                  
                  if(sw[6] == 1'b1 && activate_blink5 == 1'b1) begin
                        if(activate_blink5 == 1'b1)begin //if state 3 and blink 5 times is activated
                            if (blink5 == max_blink5 - 1) begin
                                blink5 <= 32'd0;
                                activate_blink5 = 1'b0; //when switch is off, this will deactivate counter
                                led <= 3'b000;
                                current_state <= 2'b11;
                            end else
                                blink5 <= blink5 + 1;
                            end
                    
                        if((blink5%050_000_000 == 0) && (activate_blink5 == 1'b1))begin //when counter is offed then blink will stop
                            led[6] <= ~led[6];
                        end
                  end

            end //end of current_state 10
            
            2'b11 :
            begin //State is REFUND
                  
                  minus <= 4'd10;
                  a <= a;
                  b <= b;
                  c <= c;
                  
                  delay3s = 1'b1;
                  if(delay3s == 1'b1)begin //if delay is activated
                        if (count3s == max_count3s)begin //3s delay counter
                            count3s <= 32'd0;
                        end else
                            count3s <= count3s + 1;
                  end
                  
                  if (count3s == max_count3s)begin //3s wait toggle - waits for 3s before going to state 1
                        delay3s <= 1'b1;
                        current_state <= 2'b00;
                        
                        a <= 0;
                        b <= 0;
                        c <= 0;
                        
                  end else
                        delay3s <= 1'b0;
                        
                  
            end //end of current_state 11
            
        endcase
    end
    
    

    
    

    always @(posedge clk) begin //resposible for constantly converting a,b,c,minus value to SSD
        case (mux_out) //may have to change accordingly
            
            4'd0: seg[6:0] = 7'b1000000; //gfedcba
            4'd1: seg[6:0] = 7'b1111001;
            4'd2: seg[6:0] = 7'b0100100;
            4'd3: seg[6:0] = 7'b0110000;
            4'd4: seg[6:0] = 7'b0011001;
            4'd5: seg[6:0] = 7'b0010010; 
            4'd6: seg[6:0] = 7'b0000010;
            4'd7: seg[6:0] = 7'b1111000;
            4'd8: seg[6:0] = 7'b0000000;
            4'd9: seg[6:0] = 7'b0010000;
            4'd10: seg[6:0] = 7'b0111111; //display 0 also(may change again)
            
        endcase
   
    end
    
endmodule


