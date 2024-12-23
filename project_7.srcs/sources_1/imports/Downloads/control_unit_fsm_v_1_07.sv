`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:  Ratner Surf Designs
// Engineer: Advika and Owen
// 
// Create Date: 01/07/2020 09:12:54 PM
// Design Name: CPE 233 Lab 6 - CU_FSM
// Module Name: top_level
// Project Name: CPE 233 Lab 6
// Target Devices: Basys 3
// Tool Versions: 
// Description: Control Unit Template/Starter File for RISC-V OTTER
//
//     //- instantiation template 
//     CU_FSM my_fsm(
//        .intr     (xxxx),
//        .clk      (xxxx),
//        .RST      (xxxx),
//        .opcode   (xxxx),   // ir[6:0]
//        .PC_WE    (xxxx),
//        .RF_WE    (xxxx),
//        .memWE2   (xxxx),
//        .memRDEN1 (xxxx),
//        .memRDEN2 (xxxx),
//        .reset    (xxxx)   );
//   
// Dependencies: 
// 
// Revision:
// Revision 1.00 - File Created - 02-01-2020 (from other people's files)
//          1.01 - (02-08-2020) switched states to enum type
//          1.02 - (02-25-2020) made PS assignment blocking
//                              made rst output asynchronous
//          1.03 - (04-24-2020) added "init" state to FSM
//                              changed rst to reset
//          1.04 - (04-29-2020) removed typos to allow synthesis
//          1.05 - (10-14-2020) fixed instantiation comment (thanks AF)
//          1.06 - (12-10-2020) cleared most outputs, added commentes
//          1.07 - (12-27-2023) changed signal names 
// 
//////////////////////////////////////////////////////////////////////////////////

module CU_FSM(
    input intr, //the interupt signal not used yet
    input clk,
    input RST, //reset signal to initialize fsm
    input [6:0] opcode,     // ir[6:0]
     input [2:0] func3,    //-  ir[14:12] 
    output logic PC_WE, //writes to PC
    output logic RF_WE, //writes to register file
    output logic memWE2, // memory write enable 2
    output logic memRDEN1, //memory read enable 1
    output logic memRDEN2, //memory read enable 2
    output logic reset,
    
    output logic csr_WE, // enables writing to the CSR[mstatus[MIE]]
    output logic int_taken, // 1 bit signal stating that MCU entered interrupt cycle
    output logic mret_exec // tells that FSM is executing a mret instruction
  );
    
    typedef  enum logic [2:0] {
       st_INIT, //initial state
	   st_FET, //fetch state
       st_EX, //execute state
       st_WB, //writeback state
       st_INTR //interrupt state
    }  state_type; 
    state_type  NS,PS; 
      
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
      
	opcode_t OPCODE;    //- symbolic names for instruction opcodes
     
	assign OPCODE = opcode_t'(opcode); //- Cast input as enum 
	 

	//- state registers (PS)
	always @ (posedge clk)
	begin
        if (RST == 1)
            PS <= st_INIT;
        else
            PS <= NS;
    end    

    always_comb
    begin              
        //- schedule all outputs to avoid latch
        PC_WE = 1'b0;    RF_WE = 1'b0;    reset = 1'b0;  
		memWE2 = 1'b0;   memRDEN1 = 1'b0;    memRDEN2 = 1'b0;
		csr_WE = 1'b0;      int_taken = 1'b0;    mret_exec = 1'b0;
		
                   
        case (PS)

            st_INIT: //waiting state  
            begin
                reset = 1'b1;     //have to reset to initialize 
                PC_WE = 0;        //everything else is off since its waiting 
                RF_WE = 0;
                memWE2 = 0;
                memRDEN1 = 0;
                memRDEN2= 0;
                        
                NS = st_FET; 
            end

            st_FET: //waiting state  
            begin
                memRDEN1 = 1'b1;  //fetches next instruction from memory
                PC_WE = 0;        //everything else is off
                RF_WE = 0;
                memWE2 = 0;
                memRDEN2= 0;                 
                reset = 0;
                
                NS = st_EX; 
            end
              
            st_EX: //decode + execute
            begin
                PC_WE = 1'b1;   //write enable is on to execute instruction
                int_taken = 1'b0;
                case (OPCODE)
                    OP_SYS: 
                    begin
					      case(func3)
                            3'b001: //CSRRW - can read and write to csr reg at the same time
                            begin
                            csr_WE = 1'b1;  //have to write to the csr for these instructions 
                             if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
					       end
               
                            3'b011: //CSRRC
                            begin
                            csr_WE = 1'b1;  //have to write to the csr for these instructions 
                            if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
					       end
                           
               
                            3'b010: //CSRRS
                            begin
                            csr_WE = 1'b1;  //have to write to the csr for these instructions 
                            if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
                            end
               
                            3'b000: //MRET
                            begin
                            csr_WE = 1'b1;
                            mret_exec = 1'b0; //not on here will turn on within the specific instruction? not sure about this one
                            if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
                            end
                        endcase //endcase for the func3
                        end //for the SYS opcode 
                        
				    AUIPC: 
				    begin  
				          RF_WE = 1'b1;	      //stores in a register
                          PC_WE = 1'b1;
                          memWE2 = 1'b0;
                          memRDEN1 = 1'b0;
                          memRDEN2 = 1'b0;
                          reset = 1'b0;          
					      if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
				    end
				
				    LOAD: //reads from memory
                       begin
                          RF_WE = 1'b0;     
                          PC_WE = 1'b0;     
                          memWE2 = 1'b0;
                          memRDEN1 = 1'b0;
                          memRDEN2 = 1'b1;  //gets output from addr 2
                          reset = 1'b0;
                          NS = st_WB;
                       end
                    
					STORE:     //writes to memory
                       begin
                          RF_WE = 1'b0;
                          PC_WE = 1'b1;     //on so you can go to next instruction
                          memWE2 = 1'b1;    //need to be able to write to memory to store
                          memRDEN1 = 1'b0;  //not reading anything from memory
                          memRDEN2 = 1'b0; 
                          reset = 1'b0;
                           if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
                       end
                    
					BRANCH: 
                       begin
                       PC_WE = 1'b1;
                       RF_WE = 1'b0;
                       memRDEN1 = 1'b0;  //not reading anything from memory
                       memRDEN2 = 1'b0;
                       if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
                       end
					
					LUI: 
					   begin
                          RF_WE = 1'b1;     //loads into register
                          PC_WE = 1'b1;
                          memWE2 = 1'b0;
                          memRDEN1 = 1'b0;
                          memRDEN2 = 1'b0;
                          reset = 1'b0;
                          if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;		     
					   end
					  
					OP_IMM:  // addi 
					   begin 
					      RF_WE = 1'b1;	      //stores in a register
                          PC_WE = 1'b1;
                          memWE2 = 1'b0;
                          memRDEN1 = 1'b0;
                          memRDEN2 = 1'b0;
                          reset = 1'b0;          
					      if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
					   end
					
	                JAL: 
					   begin
					      RF_WE = 1'b1;    //writes to register 
				          PC_WE = 1'b1;     //adds value to PC
                          memWE2 = 1'b0;
                          memRDEN1 = 1'b0;
                          memRDEN2 = 1'b0;
                          reset = 1'b0;
					       if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
					   end
					   
					JALR: 
					   begin
					      RF_WE = 1'b1;    //writes to register 
				          PC_WE = 1'b1;     //adds value to PC
                          memWE2 = 1'b0;
                          memRDEN1 = 1'b0;
                          memRDEN2 = 1'b0;
                          reset = 1'b0;
					      if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
					   end
					   
					 OP_RG3:
					   begin
                          RF_WE = 1'b1; 
                          PC_WE = 1'b1; 
                          memWE2 = 1'b0;
                          memRDEN1 = 1'b0;
                          memRDEN2 = 1'b0;
                          reset = 1'b0;
                          if(intr == 1'b1)
					        begin
					          NS = st_INTR;
					        end
					      else
                              NS = st_FET;
					   end
					   
					   
//					  OP_SYS: //handles all of the interrupt instructions
//					   begin
//                          RF_WE = 1'b0; //off only uses the CSR?
//                          PC_WE = 1'b1; //has to write next new address to PC
//                          memWE2 = 1'b0;
//                          memRDEN1 = 1'b0; //nothing to do with memory
//                          memRDEN2 = 1'b0;
//                          reset = 1'b0; 
//                          //new instructions
//                          csr_WE = 1'b1;  //have to write to the csr for these instructions    
//                          int_taken = 1'b1;  //on because currently within the interrupt?   
//                          mret_exec = 1'b0; //not on here will turn on within the specific instruction? not sure about this one
                          
//                          if(intr == 1'b1)
//					        begin
//					          NS = st_INTR;
//					        end
//					      else
//                              NS = st_FET;
//					   end	
   
                    default:  
					   begin 
					      NS = st_FET;
					   end
                endcase
            end

 
               
            st_WB:
            begin
               RF_WE = 1'b1; 
               PC_WE = 1'b1; //was off for load, but on here so that it can go to next instruction
               memWE2 = 1'b0;
               memRDEN1 = 1'b0;
               memRDEN2 = 1'b0;
               reset = 1'b0;
  
               
               if (intr == 1'b1)
                  begin
                    NS = st_INTR;
                  end
               else
                    NS = st_FET;
            end
 
            default: NS = st_FET;
           
           st_INTR:
           begin
               RF_WE = 1'b0; //the values are stored in the CSR not here
               PC_WE = 1'b1; //yes stays on to write the new address to the pC
               memWE2 = 1'b0; 
               memRDEN1 = 1'b0;
               memRDEN2 = 1'b0;
               reset = 1'b0;
               //new signals
               csr_WE = 0;   //off here because will get turned on in the intstructions
               int_taken = 1'b1; //on to indicate that currently in a interrupt cycle
               mret_exec = 1'b0; //wil/ be turned on in the individual instructions not here
               
               NS = st_FET;
           end
           
        endcase //- case statement for FSM states
    end
           
endmodule
