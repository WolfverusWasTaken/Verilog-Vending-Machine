`timescale 1ns / 1ps

module PB_Pulse_Generator(
    input clk,
    input PB,
    output pulse
    );
    
    reg PB_reg1, PB_reg2;
    
    always @(posedge clk) begin
        PB_reg1 <= PB;
        PB_reg2 <= PB_reg1;
        
    end
    
    assign pulse = PB_reg1 && ~PB_reg2;
endmodule
