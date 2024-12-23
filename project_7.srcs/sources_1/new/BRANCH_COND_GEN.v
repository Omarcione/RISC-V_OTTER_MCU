`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: CPE 233
// Engineer: Advika Deodhar, Owen Marcione
// 
// Create Date: 02/24/2024 04:47:44 PM
// Design Name: 
// Module Name: BRANCH_COND_GEN
// Project Name: CPE 233 Lab 6
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module BRANCH_COND_GEN(
    input wire [31:0] rs1,
    input wire [31:0] rs2, 
    output reg br_eq, 
    output reg br_lt, 
    output reg br_ltu );
   
    always @(*) begin
    // equal
    br_eq = (rs1 == rs2);
    
    // less than signed
    br_lt = ($signed(rs1) < $signed(rs2)) ? 1'b1 : 1'b0;
    
    // less than unsigned
    br_ltu = (rs1 < rs2) ? 1'b1 : 1'b0;
end

endmodule