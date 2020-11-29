`timescale 1ns / 1ps

module test_vm4();
    //Signal Declarations - Feel free to modify the signal names as you wish.
    wire [8:6] led;
    wire [6:0] seg;
    wire [3:0] an;
    wire dp;
    reg clk;
    reg [8:6] sw;
    reg btnR;
    reg btnD;
    reg btnL;
    reg btnC;
    
    //DUT instantiation - Modify this code block according to your design
    vm vm_template(
        .seg(seg),
        .led(led),
        .an(an),
        .dp(dp),
        .clk(clk),
        .sw(sw),
        .btnR(btnR),
        .btnD(btnD),
        .btnL(btnL),
        .btnC(btnC)
    );
    
    //Clock Creation: 100 MHz
    initial clk = 0;
    always #5 clk = ~clk;
    
    //Test Pattern Creation - You may modify this code and add more test cases.
    initial
    begin
        sw = 3'b000; btnR = 0; btnD = 0; btnL = 0; btnC = 0; //Initial input values
        #400 btnD = 1; //Insert $1; Total = $1.00
        #40 btnD = 0;
        #125 btnD = 1; //Insert $1; Total = $1.00
        #10 btnD = 0;
        #120 btnR = 1;
        #40 btnR = 0;
        #100 btnR = 1; //Insert $1; Total = $1.00
        #10 btnR = 0;
        
    end
    
endmodule
