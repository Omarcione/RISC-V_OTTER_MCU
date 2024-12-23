`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Advika and Owen
// 
// Create Date: 01/29/2024 11:31:36 AM
// Design Name: ALU
// Module Name: ALUmod
// Project Name: Experiment 3
// Target Devices: 
// Tool Versions: 
// Description: Making an ALU that does all of the bit-crunching required by the instruction set
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ALUmod(
    input wire [31:0] srcA,
    input wire [31:0] srcB, 
    input wire [3:0] alu_fun,
    output reg [31:0] result );
    
    parameter [3:0] 
    ADD = 4'b0000, 
    SUB = 4'b1000, 
    OR = 4'b0110,
    AND = 4'b0111, 
    XOR = 4'b0100, 
    SRL = 4'b0101,
    SLL = 4'b0001,
    SRA = 4'b1101, 
    SLT = 4'b0010,
    SLTU = 4'b0011,
    LUI = 4'b1001;  
    
    always @(*) 
    begin
        case (alu_fun) 
            ADD: 
                result = srcA + srcB; //add the two operands together 
               
            SUB: 
                result = srcA - srcB; //subtracts the two operands
                
            OR: 
                result = srcB | srcA; //ORs the two operands
                
            AND: 
                result = srcB & srcA; //ANSa the two operands
                
            XOR: 
                result = srcB ^ srcA; //XORs the two operands
                
            SRL: 
                result = srcA >> srcB [4:0]; //Shifts data to the right in OP_1 by the amount specified in OP_2 but only considers the 5 LSB
                
            SLL: 
                result = srcA << srcB [4:0]; //Shifts data to the left in OP_1 by the amount specified in OP_2 but only considers the 5 LSB
                
            SRA: 
                result = $signed(srcA) >>> srcB [4:0]; //Shifts data to the right in OP_1 by the amount specified in OP_2 but only considers the 5 LSB
                
            SLT: //set if less than (signed)
              begin 
                if ($signed(srcA) < $signed(srcB)) 
                    result = 1;
                else 
                    result = 0;
              end
            SLTU: //set if less than (unsigned)
              begin 
                if (srcA < srcB) 
                    result = 1;
                else 
                    result = 0;
              end 
            LUI: //return the same value (copy)
                result = srcA;  
            default: //default case is to set all the values in the destination register to 0.
                result = 32'hDEADBEEF;
        endcase  
    end
endmodule


