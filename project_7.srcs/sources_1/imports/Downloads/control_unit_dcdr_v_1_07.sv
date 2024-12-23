`timescale 1ns / 1ps
///////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer: Advika and Owen
// 
// Create Date: 01/07/2020 09:12:54 PM
// Design Name: CPE 233 Lab 6 - CU_DCDR
// Module Name: top_level
// Project Name: CPE 233 Lab 6
// Target Devices: Basys 3
// Tool Versions: 
// Description: Control Unit Template/Starter File for RISC-V OTTER
// 
// Instantiation Template:
//
// CU_DCDR my_cu_dcdr(
//   .br_eq     (xxxx), 
//   .br_lt     (xxxx), 
//   .br_ltu    (xxxx),
//   .opcode    (xxxx),    
//   .func7     (xxxx),    
//   .func3     (xxxx),    
//   .ALU_FUN   (xxxx),
//   .PC_SEL    (xxxx),
//   .srcA_SEL  (xxxx),
//   .srcB_SEL  (xxxx), 
//   .RF_SEL    (xxxx)   );
//
// 
// Revision:
// Revision 1.00 - Created (02-01-2020) - from Paul, Joseph, & Celina
//          1.01 - (02-08-2020) - removed  else's; fixed assignments
//          1.02 - (02-25-2020) - made all assignments blocking
//          1.03 - (05-12-2020) - reduced func7 to one bit
//          1.04 - (05-31-2020) - removed misleading code
//          1.05 - (12-10-2020) - added comments
//          1.06 - (02-11-2021) - fixed formatting issues
//          1.07 - (12-26-2023) - changed signal names
//
// Additional Comments:
// 
///////////////////////////////////////////////////////////////////////////

module CU_DCDR(
   input br_eq, 
   input br_lt, 
   input br_ltu,
   input int_taken, //added for interrupts
   input [6:0] opcode,   //-  ir[6:0]
   input func7,          //-  ir[30]
   input [2:0] func3,    //-  ir[14:12] 
   output logic [3:0] ALU_FUN,
   output logic [2:0] PC_SEL, //increases to 3 bits
   output logic [1:0] srcA_SEL, //increases to 2 bits
   output logic [2:0] srcB_SEL, //increases to 3 bits
    output logic [1:0] RF_SEL   );
    
   //- datatypes for RISC-V opcode types
   typedef enum logic [6:0] {
        LUI    = 7'b0110111,
        AUIPC  = 7'b0010111,
        JAL    = 7'b1101111,
        JALR   = 7'b1100111,
        BRANCH = 7'b1100011,
        LOAD   = 7'b0000011,
        STORE  = 7'b0100011,
        OP_IMM = 7'b0010011,
        OP_RG3 = 7'b0110011, 
        OP_SYS = 7'b1110011  //the opcode for all sys type instructions is the same
   } opcode_t;
   opcode_t OPCODE; //- define variable of new opcode type
    
   assign OPCODE = opcode_t'(opcode); //- Cast input enum 

   //- datatype for func3Symbols tied to values
   typedef enum logic [2:0] {
        //BRANCH labels
        BEQ = 3'b000,
        BNE = 3'b001,
        BLT = 3'b100,
        BGE = 3'b101,
        BLTU = 3'b110,
        BGEU = 3'b111
   } func3_t;    
   func3_t FUNC3; //- define variable of new opcode type
   
    assign FUNC3 = func3_t'(func3); //- Cast input enum 
      
   always_comb
   begin 
   
   
   
      //- schedule all values to avoid latch
      PC_SEL = 3'b000;  srcB_SEL = 3'b000;     RF_SEL = 2'b00; 
      srcA_SEL = 2'b00;   ALU_FUN  = 4'b0000;
		
		
    if (int_taken == 1'b1)
        PC_SEL = 3'b100;
    else
    
    
      case(OPCODE)
        LUI:
         begin
            ALU_FUN = 4'b1001; //LUI in ALU
            srcA_SEL = 2'b01;    //from IMMMED_GEN
            RF_SEL = 2'b11;     //from ALU
         end
         
        AUIPC:
         begin
            PC_SEL = 3'b000;
            srcB_SEL = 3'b011;
            RF_SEL = 2'b11;
            srcA_SEL = 2'b01; //NOT SURE ABOUT THIS
            ALU_FUN  = 4'b0000; //add instruction 
         end
			
        JAL:
         begin
			RF_SEL = 2'b00; //rd <- PC+4
			PC_SEL = 3'b011; //from jal
	     end
			
		JALR:
         begin
            srcB_SEL = 3'b001;
			srcA_SEL = 2'b00; //NOT SURE ABOUT THIS
            PC_SEL = 3'b001;
            RF_SEL = 2'b00;
         end
			
         LOAD: 
         begin
            ALU_FUN = 4'b0000;
            srcA_SEL = 2'b00;  
            srcB_SEL = 3'b001; //I-type 
            RF_SEL = 2'b10; //from mem
         end
			
         STORE:
         begin
            ALU_FUN = 4'b0000; //add
            srcA_SEL = 2'b00; //rs1
            srcB_SEL = 3'b010; //imm
         end
				
		 BRANCH:
		  begin
		  case(FUNC3)
		      BEQ: 
		      begin 
		          if (br_eq == 1'b1)
		          PC_SEL = 3'b010;
		      end
		      BNE: 
		      begin 
		          if (br_eq == 1'b0)
		          PC_SEL = 3'b010;
		      end
		      BLT: 
		      begin 
		          if (br_lt == 1'b1)
		          PC_SEL = 3'b010;
		      end
		      BGE: 
		      begin 
		          if (br_lt == 1'b0)
		          PC_SEL = 3'b010;
		      end
		      BLTU: 
		      begin 
		          if (br_ltu == 1'b1)
		          PC_SEL = 3'b010;
		      end
		      BGEU: 
		      begin 
		          if (br_ltu == 1'b0)
		          PC_SEL = 3'b010;
		      end
		    endcase
          end 
		
         OP_IMM:
         begin
         RF_SEL = 2'b11;
         PC_SEL = 3'b000;
         srcB_SEL = 3'b001;
         srcA_SEL = 2'b00;
            case(FUNC3)
               3'b000: //ADDI
               begin
                  ALU_FUN = 4'b0000; 
               end
               
               3'b010: //SLTI
               begin
                  ALU_FUN = 4'b0010; 
               end
               
               3'b011: //SLTIU
               begin
                  ALU_FUN = 4'b0011; 
               end
               
               3'b110: //ORI
               begin
                  ALU_FUN = 4'b0110; 
               end
               
               3'b100: //XORI
               begin
                  ALU_FUN = 4'b0100; 
               end
               
               3'b111: //ANDI
               begin
                  ALU_FUN = 4'b0111; 
               end
               
               3'b001: //SLLI
               begin
                  ALU_FUN = 4'b0001; 
               end
               
               3'b101: //SRLI and SRAI
               begin
                if(func7 == 1'b0) //SRLI
                  ALU_FUN = 4'b0101; 
                else if(func7 == 1'b1) //SRAI
                    ALU_FUN = 4'b1101;
               end
               
					
               default: //default everything off
               begin
                  PC_SEL = 3'b000; 
                  ALU_FUN = 4'b0000;
                  srcA_SEL = 2'b00; 
                  srcB_SEL = 3'b000; 
                  RF_SEL = 2'b00; 
               end
            endcase
         end
         
          OP_SYS:
         begin
         RF_SEL = 2'b00;
         PC_SEL = 3'b000;
         srcB_SEL = 3'b000;
         srcA_SEL = 2'b00;
            case(FUNC3)
               3'b001: //CSRRW - can read and write to csr reg at the same time
               begin
                  PC_SEL = 3'b000; //make a 4, takes in the mtvec
                  ALU_FUN = 4'b1001; //LUI
                  srcA_SEL = 2'b00; //takes in rs1
                  srcB_SEL = 3'b100; //takes in csr_RD which is the CSR output
                  RF_SEL = 2'b01; //takes in the csr_RD
               end
               
               3'b011: //CSRRC
               begin
                  ALU_FUN = 4'b0111; //AND
                  srcA_SEL = 2'b10; // set to 2 - take in the notRS1
                  srcB_SEL = 3'b100; // set to 4? still the CSR_RD
                  RF_SEL = 2'b01; //takes in the csr_RD
               end
               
               3'b010: //CSRRS
               begin
                  ALU_FUN = 4'b0110; //OR
                  srcA_SEL = 2'b00; // keep it zero for rs1
                  srcB_SEL = 3'b100; // 4 for csr_RD
                  RF_SEL = 2'b01; //takes in the csr_RD
               end
               
               3'b000: //MRET
               begin
                  PC_SEL = 3'b101; //set to 5 - need mepc
               end
              
               default: //default everything off
               begin
                  PC_SEL = 3'b000; 
                  ALU_FUN = 4'b0000;
                  srcA_SEL = 2'b00; 
                  srcB_SEL = 3'b000; 
                  RF_SEL = 2'b00; 
               end
            endcase
         end
         
         
         OP_RG3:
          begin
          RF_SEL = 2'b11;
          PC_SEL = 3'b000;
          srcA_SEL = 2'b00; 
          srcB_SEL = 3'b000; 
        
            case(FUNC3)
            
               3'b000: //ADD OR SUB
               begin
                if(func7 == 1'b0) //ADD
                  ALU_FUN = 4'b0000; 
                else if(func7 == 1'b1) //SUB
                  ALU_FUN = 4'b1000; 
               end
               
               3'b001: //SLL
               begin
                  ALU_FUN = 4'b0001; 
               end
               
               3'b010: //SLT
               begin
                  ALU_FUN = 4'b0010; 
               end
               
               3'b011: //SLTU
               begin
                  ALU_FUN = 4'b0011; 
               end
               
               3'b100: //XOR
               begin
                  ALU_FUN = 4'b0100; 
               end
               
               3'b101: //SRA OR SRL
               begin
                if(func7 == 1'b0) //SRL
                  ALU_FUN = 4'b0101; 
                else if(func7 == 1'b1) //SRA
                  ALU_FUN = 4'b1101;
               end
              
               3'b110: //OR
               begin
                  ALU_FUN = 4'b0110; 
               end
               
                3'b111: //AND
               begin
                  ALU_FUN = 4'b0111; 
               end

         default:
         begin
             PC_SEL = 3'b000; 
             srcB_SEL = 3'b000; 
             RF_SEL = 2'b00; 
             srcA_SEL = 2'b00; 
             ALU_FUN = 4'b0000;
         end
      endcase 
     end
    endcase
   end

endmodule