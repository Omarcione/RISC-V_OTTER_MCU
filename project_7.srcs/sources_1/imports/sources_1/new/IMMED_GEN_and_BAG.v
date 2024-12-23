
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Cal Poly 
// Engineer: Advika Deodhar and Owen Marcione 
// 
// Create Date: 01/24/2024 04:24:59 PM
// Design Name: 
// Module Name: Immediate Address Generator and Branch Address Generator 
// Project Name: Experiment 4
// Target Devices: 
// Tool Versions: 
// Description: Memory Module and PC connected to the IMMED_GEN and BAG.
//              Creates immed values and provides addresses for PC to jump/branch
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//////////////////////////////////////////////////////////////////////////////////


module IMMED_GEN_and_BAG(
    input reset,
    input PC_WE,
    input wire [2:0] PC_SEL,
    input CLK,
    input memWE2,
    input MEM_RDEN1,
    input MEM_RDEN2,
    input [31:0] IOBUS_IN,
    input [31:0] MEM_ADDR2,
    input [31:0] MEM_DIN2,
    input [31:0] rs1,
    output IOBUS_WR,
    output [31:0] PC,
    output [31:0] U_type,
    output [31:0] S_type,
    output [31:0] I_type,
    output [31:0] MEM_DOUT2,
    output [31:0] ir
    );
 
//    wire [31:0] J_type; //into BAG
//    wire [31:0] B_type; //into BAG
//    wire [31:0] jalr; //input 1 into MUX
//    wire [31:0] CSR_MTVEC; //input 4 into MUX
//    wire [31:0] CSR_MEPC; //input 5 into MUX
//    wire [31:0] branch; //input 2 into MUX
//    wire [31:0] jal; //input 3 into MUX 
//    wire [31:0] data; //the data output from the MUX
    
//  mux_4t1_nb  #(.n(32)) my_4t1_mux  (
//       .SEL   (PC_SEL), 
//       .D0    (PC + 4), //each time the address will increment by 4
//       .D1    (jalr),  //set MUX inputs to jalr, branch, and jal
//       .D2    (branch), 
//       .D3    (jal),
//       .D_OUT (data) );  //MUX output


//new pc mux with interrupts
//     mux_8t1_nb  #(.n(32)) my_8t1_mux  (
//       .SEL   (PC_SEL), 
//       .D0    (PC + 4), 
//       .D1    (jalr), 
//       .D2    (branch), 
//       .D3    (jal),
//       .D4    (CSR_MTVEC),
//       .D5    (CSR_MEPC),
//       .D6    (0),
//       .D7    (0),
//       .D_OUT (data) );  

//  reg_nb_sclr #(.n(32)) MY_PC ( //program counter instantiation
//        .data_in  (data), 
//        .ld       (PC_WE), 
//        .clk      (CLK), 
//        .clr      (reset), 
//        .data_out (PC)
// );  
          
// Memory OTTER_MEMORY ( //memory instantiation
//        .MEM_CLK    (CLK), 
//        .MEM_RDEN1  (MEM_RDEN1),  
//        .MEM_RDEN2  (MEM_RDEN2),  
//        .MEM_WE2    (memWE2), 
//        .MEM_ADDR1  (PC[15:2]), 
//        .MEM_ADDR2  (MEM_ADDR2), 
//        .MEM_DIN2   (MEM_DIN2),   
//        .MEM_SIZE   (ir[13:12]), 
//        .MEM_SIGN   (ir[14]), 
//        .IO_IN      (IOBUS_IN), 
//        .IO_WR      (IOBUS_WR), 
//        .MEM_DOUT1  (ir), 
//        .MEM_DOUT2  (MEM_DOUT2)  );
        
        
//  //IMMED_GEN
//  assign I_type[31:11] = {21{ir[31]}}, //I-type instruction
//         I_type[10:5] = ir[30:25],
//         I_type[4:0] = ir[24:20];
  
//  assign S_type[31:11] = {21{ir[31]}}, //S-type
//         S_type[10:5] = ir[30:25],
//         S_type[4:0] = ir[11:7];
  
//  assign B_type[31:12] = {20{ir[31]}},  //B-type
//         B_type[11] = ir[7],
//         B_type[10:5] = ir[30:25],
//         B_type[4:1] = ir[11:8],
//         B_type[0] = 0;  
         
//  assign U_type[31:12] = ir[31:12],    //U-type
//         U_type[11:0] = 0;
  
//  assign J_type[31:20] = {12{ir[31]}}, //J type
//         J_type[19:12] = ir[19:12],
//         J_type[11] = ir[20],
//         J_type[10:1] = ir[30:21],
//         J_type[0] = 0;  
         
////BAG
//    assign jal = ((PC) + J_type),
//           branch = ((PC) + B_type),
//           jalr = (rs1 + I_type); //rs = 12 for this experiment
            
endmodule
