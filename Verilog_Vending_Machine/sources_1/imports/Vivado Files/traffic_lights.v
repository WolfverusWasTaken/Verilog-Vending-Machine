`timescale 1ns / 1ps

module traffic_lights(
    input clk,
    input [15:0] sw,
    input btnC,
    output reg [15:0] led	//Output as Register, as it will be assigned in Sequential Logic
    );
    parameter max_count = 500_000_000;	//5 seconds count limit 500_000_000
    parameter state_1 = 0, state_2 = 1, state_3 = 2, state_4 = 3;	//State machine definition
    reg [31:0] count = 0;	//Count variable
    reg trig = 1'b0;		//1-clock pulse trigger
    reg [1:0] current_state = 2'b00;
    reg [1:0] next_state = 2'b00;
    reg btnC_reg1, btnC_reg2, btnC_pulse;
	/********************************
	*** 5 Second Counting Logic
	********************************/
    always @(posedge clk) begin
        if (count == max_count)
            count <= 32'd0;
        else
            count <= count + 1;
    end
    
    always @(posedge clk) begin
        btnC_reg1 <= btnC;
        btnC_reg2 <= btnC_reg1;
        btnC_pulse <= btnC_reg1 && ~btnC_reg2;
    end
	/********************************
	*** 1-clock pulse trigger Logic
	********************************/
    always @(posedge clk) begin
        if (count == max_count - 1)  //(btnC_pulse == 1)
            trig <= 1'b1;
        else
            trig <= 1'b0;
    end
	/********************************
	*** Next State Combinational Logic
	********************************/
    always @(current_state, trig)
    begin
        case (current_state)
            2'b00 : begin
                if (trig == 1'b1)
                    next_state = 2'b01;
                else
                    next_state = 2'b00;
            end
            2'b01 : begin
                if (trig == 1'b1)
                    next_state = 2'b10;
                else
                    next_state = 2'b01;
            end
            2'b10 : begin
                if (trig == 1'b1)
                    next_state = 2'b11;
                else
                    next_state = 2'b10;
            end
            2'b11 : begin
                if (trig == 1'b1)
                    next_state = 2'b00;
                else
                    next_state = 2'b11;
            end
        endcase
    end
	/********************************
	*** State storage Logic
	********************************/
    always @(posedge clk) begin
        current_state <= next_state;
    end
	/********************************
	*** Outputs Logic
	********************************/
    always @(posedge clk) begin
        case (current_state)
            2'b00 : begin	//North and South : Left + Straight
                led[15:12] <= 4'b1100;
                led[11:8] <= 4'b0000;
                led[7:4] <= 4'b1100;
                led[3:0] <= 4'b0000;
                //led <= 16'b1100000011000000;
              end
            2'b01 : begin	//North and South : Right
                led[15:12] <= 4'b0010;
                led[11:8] <= 4'b0000;
                led[7:4] <= 4'b0010;
                led[3:0] <= 4'b0000;
                //led <= 16'b0010000000100000;
              end
            2'b10 : begin	//West : Left + Straight + Right
                led[15:12] <= 4'b0000;
                led[11:8] <= 4'b1110;
                led[7:4] <= 4'b0000;
                led[3:0] <= 4'b0000;
                //led <= 16'b0000111000000000;
              end
            2'b11 : begin	//East : Left + Straight + Right
                led[15:12] <= 4'b0000;
                led[11:8] <= 4'b0000;
                led[7:4] <= 4'b0000;
                led[3:0] <= 4'b1110;
                //led <= 16'b0000000000001110;
              end
            default :
                led <= 16'd0;
        endcase
    end

endmodule
