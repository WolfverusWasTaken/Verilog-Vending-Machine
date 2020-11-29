`timescale 1 ns / 1 ps

module quad_seven_seg (
    input wire clk,
    input wire [3:0] val3,
    input wire [3:0] val2,
    input wire [3:0] val1,
    input wire [3:0] val0,
    output wire an3,
    output wire an2,
    output wire an1,
    output wire an0,
    output wire dp,
    output reg ca,
    output reg cb,
    output reg cc,
    output reg cd,
    output reg ce,
    output reg cf,
    output reg cg
    );

    //Register Declarations
    parameter max_count20 = 400_000; //400_000, Simulation = 4
    reg [19:0] cntr20 = 0;	       // 20-bit counter to divide the 100MHz on board clock
    reg [1:0] step = 2'b00 ;      // step will determine the mux output
    reg en = 1'b0;                // en=1 will increment the step by 1
    reg [3:0] mux_out = 4'd0;     // mux_out will be any of the four val depending on step
    
  
    //20-bit counter with frequency of 100MHz divide by 400000 = 250 Hz, i.e. period is 4 ms
    //So that the human eye is able to view the seven segment correctly
    always@(posedge clk)
    begin
        if (cntr20 >= max_count20)
            cntr20 <= 20'd0;
        else
            cntr20 <= cntr20 + 1;
    end

    //Enable Signal Logic for 2 bit counter
    always @ (posedge clk) begin
         if (cntr20 == max_count20 - 1)
           en <= 1'b1;
         else
           en <= 1'b0;
     end
   

    //2 bit couter with enable
    always@(posedge clk)
        if(en) begin 
          step <= step + 1;
        end else begin
          step <= step;
    end  
   
    // 2 to 4 Encoder
    assign an0 = !(step == 2'b00);  //an0 is logic 0 when step is 00
    assign an1 = !(step == 2'b01);
    assign an2 = !(step == 2'b10);
    assign an3 = !(step == 2'b11);

    assign dp = !(step == 2'b10);   //Default position. Might need to be changed according to specific system!!
    
    // 4 to 1 Multiplexer
    always@(*)
     if (step == 2'b00) begin
       mux_out = val0;
     end else if (step == 2'b01) begin
       mux_out = val1;
     end else if (step == 2'b10) begin
      mux_out = val2;
     end else if (step == 2'b11) begin
      mux_out = val3;
     end else begin
      mux_out = 4'bzzzz;
     end
   
    // 4 to 7 Decoder
    // the seven segments are activel low
    always@(*)
      case(mux_out)                          //abcdefg
        4'd0 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b0000001}; // display 0
        4'd1 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b1001111}; 
        4'd2 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b0010010}; 
        4'd3 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b0000110}; 
        4'd4 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b1001100}; 
        4'd5 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b0100100}; 
        4'd6 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b0100000}; 
        4'd7 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b0001111}; 
        4'd8 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b0000000}; 
        4'd9 :    {ca,cb,cc,cd,ce,cf,cg} = {7'b0000100};
        4'd10:    {ca,cb,cc,cd,ce,cf,cg} = {7'b1111110}; //display '-', used in refund state
        default : {ca,cb,cc,cd,ce,cf,cg} = {7'b1111111}; //default: no display
      endcase
    
endmodule
