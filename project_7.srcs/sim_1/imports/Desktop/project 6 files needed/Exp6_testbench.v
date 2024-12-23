`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Ratner Surf Designs
// Engineer:  James Ratner
// 
// Create Date: 01/07/2020 12:59:51 PM
// Design Name: 
// Module Name: Ex6_6_testbench
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Testbench file for Exp 6
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module otter_tb(); 

   reg [15:0] switches; 
   reg [4:0] buttons;
   reg clk; 
   wire [15:0] leds; 
   wire [7:0] segs; 
   wire [3:0] an; 


OTTER_Wrapper #(.SIM_MODE(1)) my_wrapper(
   .clk    (clk),
   .buttons  (buttons),
   .switches  (switches),
   .leds  (leds),
   .segs  (segs),
   .an  (an)  );

   
  //- Generate periodic clock signal    
   initial    
      begin       
         clk = 0;   //- init signal        
         forever  #10 clk = ~clk;    
      end                        
         
   initial        
   begin           
      buttons = 5'b00000;   //start with all buttons not pressed 
      switches = 16'h0000;
      #20
      
      //Press button 3 and turn on reset
      buttons = 5'b01000;   //press the reset button
      #40 //make reset last for a while
      
      buttons = 5'b00000; //release reset button
      #4000 //wait for the MCU to finish initializing
      
      //generating a interrupt pulse 
      buttons = 5'b10000; //interrupt button pressed 
      #60 //keep that short 
      
      buttons = 5'b00000; //release the interrupt button 
      
      #80 //wait a little 
      $finish;
    end
endmodule
