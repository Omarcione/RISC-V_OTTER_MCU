`timescale 1ns / 1ps
/////////////////////////////////////////////////////////////////////////////////////
module OTTER_MCU (
    input clk,
    input intr,
    input RST,
    input [31:0] iobus_in,
    output logic [31:0] iobus_out,
    output logic [31:0] iobus_addr,
    output logic iobus_wr 
    );
    
    wire [31:0] ir;
    wire [31:0] PC;
    
    
    //FSM outs
    wire reset;
    wire PC_WE;
    wire RF_WE;
    wire memWE2;
    wire MEM_RDEN1;
    wire mret_exec;
    wire MEM_RDEN2;
    
    //CSR REG OUTS
    wire [31:0] CSR_MEPC;
    wire [31:0] CSR_MTVEC;
    wire [31:0] csr_RD;
    wire CSR_MSTATUS_MIE;
    wire csr_WE;
    
    //REG_FILE
    wire [31:0] w_data;
    wire [31:0] rs1;
    wire [31:0] rs2;
    
    //ALU IO
    wire [31:0] srcA;
    wire [31:0] srcB;
    wire [31:0] ALU_result;

    //DCDR out
    wire [3:0] ALU_FUN;
    wire [1:0] srcA_SEL;
    wire [2:0] srcB_SEL;
    wire [1:0] RF_SEL;
    
    //IMMED_GEN & BAG outs
    wire [31:0] U_type;
    wire [31:0] I_type;
    wire [31:0] S_type; 
    wire [2:0] PC_SEL;
    wire [31:0] MEM_DOUT2;
    
    
    //more for immed gen
    wire [31:0] J_type; //into BAG
    wire [31:0] B_type; //into BAG
    wire [31:0] jalr; //input 1 into MUX
//    wire [31:0] CSR_MTVEC; //input 4 into MUX
//    wire [31:0] CSR_MEPC; //input 5 into MUX
    wire [31:0] branch; //input 2 into MUX
    wire [31:0] jal; //input 3 into MUX 
    wire [31:0] data; //the data output from the MUX
     
    //BCG
    wire br_eq;
    wire br_lt;
    wire br_ltu;
    
    
    CU_FSM my_fsm(
        .intr     (intr && CSR_MSTATUS_MIE), //anding to ebnable the interrupt or not
        .clk      (clk),
        .func3    (ir[14:12]),
        .RST      (RST),
        .opcode   (ir[6:0]),   // ir[6:0]
        .PC_WE    (PC_WE),
        .csr_WE   (csr_WE),
        .RF_WE    (RF_WE),
        .int_taken (int_taken),
        .memWE2   (memWE2),
        .memRDEN1 (MEM_RDEN1),
        .memRDEN2 (MEM_RDEN2),
        .mret_exec (mret_exec),
        .reset    (reset)   );
        
    CSR  my_csr (
        .CLK        (clk),
        .RST        (RST),
        .MRET_EXEC  (mret_exec),
        .INT_TAKEN  (int_taken),
        .ADDR       (ir[31:20]),
        .PC         (PC + 4),
        .WD         (ALU_result),
        .WR_EN      (csr_WE),
        .RD         (csr_RD),
        .CSR_MEPC   (CSR_MEPC),
        .CSR_MTVEC  (CSR_MTVEC),
        .CSR_MSTATUS_MIE (CSR_MSTATUS_MIE) );


    CU_DCDR my_cu_dcdr(
        .br_eq     (br_eq), 
        .br_lt     (br_lt), 
        .br_ltu    (br_ltu),
        .int_taken (int_taken),
        .opcode    (ir[6:0]),    
        .func7     (ir[30]),
        .func3     (ir[14:12]),    
        .ALU_FUN   (ALU_FUN),
        .PC_SEL    (PC_SEL),
        .srcA_SEL  (srcA_SEL),
        .srcB_SEL  (srcB_SEL), 
        .RF_SEL    (RF_SEL)   );


//new pc mux with interrupts
     mux_8t1_nb  #(.n(32)) PC_MUX(
       .SEL   (PC_SEL), 
       .D0    (PC + 4), 
       .D1    (jalr), 
       .D2    (branch), 
       .D3    (jal),
       .D4    (CSR_MTVEC),
       .D5    (CSR_MEPC),
       .D6    (0),
       .D7    (0),
       .D_OUT (data) );  
       
         reg_nb_sclr #(.n(32)) MY_PC ( //program counter instantiation
        .data_in  (data), 
        .ld       (PC_WE), 
        .clk      (clk), 
        .clr      (reset), 
        .data_out (PC)
 );  
 
 Memory OTTER_MEMORY ( //memory instantiation
        .MEM_CLK    (clk), 
        .MEM_RDEN1  (MEM_RDEN1),  
        .MEM_RDEN2  (MEM_RDEN2),  
        .MEM_WE2    (memWE2), 
        .MEM_ADDR1  (PC[15:2]), 
        .MEM_ADDR2  (MEM_ADDR2), 
        .MEM_DIN2   (rs2),   
        .MEM_SIZE   (ir[13:12]), 
        .MEM_SIGN   (ir[14]), 
        .IO_IN      (IOBUS_IN), 
        .IO_WR      (IOBUS_WR), 
        .MEM_DOUT1  (ir), 
        .MEM_DOUT2  (MEM_DOUT2)  );
     
//    IMMED_GEN_and_BAG MCUmem(
//    .reset(reset),
//    .PC_WE(PC_WE),
//    .PC_SEL(PC_SEL),
//    .CLK(clk),
//    .memWE2(memWE2),
//    .MEM_RDEN1(memRDEN1),
//    .MEM_RDEN2(memRDEN2),
//    .IOBUS_IN(iobus_in),
//    .MEM_ADDR2(ALU_result),
//    .MEM_DIN2(rs2),
//    .rs1(rs1),
//    .IOBUS_WR(iobus_wr),
//    .PC(PC),
//    .U_type(U_type),
//    .S_type(S_type),
//    .I_type(I_type),
//    .ir(ir),
//    .MEM_DOUT2(MEM_DOUT2)
//    ); 
    
    
    
     //IMMED_GEN
  assign I_type[31:11] = {21{ir[31]}}, //I-type instruction
         I_type[10:5] = ir[30:25],
         I_type[4:0] = ir[24:20];
  
  assign S_type[31:11] = {21{ir[31]}}, //S-type
         S_type[10:5] = ir[30:25],
         S_type[4:0] = ir[11:7];
  
  assign B_type[31:12] = {20{ir[31]}},  //B-type
         B_type[11] = ir[7],
         B_type[10:5] = ir[30:25],
         B_type[4:1] = ir[11:8],
         B_type[0] = 0;  
         
  assign U_type[31:12] = ir[31:12],    //U-type
         U_type[11:0] = 0;
  
  assign J_type[31:20] = {12{ir[31]}}, //J type
         J_type[19:12] = ir[19:12],
         J_type[11] = ir[20],
         J_type[10:1] = ir[30:21],
         J_type[0] = 0;  
         
//BAG
    assign jal = ((PC) + J_type),
           branch = ((PC) + B_type),
           jalr = (rs1 + I_type); //rs = 12 for this experiment

    
//    //REG MUX
    
    mux_4t1_nb  #(.n(32)) reg_MUX (
       .SEL   (RF_SEL), 
       .D0    (PC), 
       .D1    (csr_RD), //CSR_reg 
       .D2    (MEM_DOUT2), 
       .D3    (ALU_result),
       .D_OUT (w_data) ); 
 
 
    RegFile my_regfile (
    .w_data (w_data),
    .clk    (clk), 
    .en     (RF_WE),
    .adr1   (ir[19:15]),
    .adr2   (ir[24:20]),
    .w_adr  (ir[11:7]),
    .rs1    (rs1), 
    .rs2    (rs2)  );
    
//    //ALU srcA MUX
//   mux_2t1_nb #(.n(32)) srcA_MUX(
//       .SEL   (srcA_SEL), 
//       .D0    (rs1), 
//       .D1    (U_type), 
//       .D_OUT (srcA) );  

//ALU SRCA MUX WITH INTERRUPTS
  mux_4t1_nb  #(.n(32)) srcA_MUX  (
       .SEL   (srcA_SEL), 
       .D0    (rs1), 
       .D1    (U_type), 
       .D2    (~rs1), 
       .D3    (0),
       .D_OUT (srcA) );  
       
//    // ALU srcB MUX
//   mux_4t1_nb #(.n(32)) srcB_MUX(
//      .SEL   (srcB_SEL), 
//       .D0    (rs2), 
//       .D1    (I_type), //CSR_reg 
//       .D2    (S_type), 
//       .D3    (PC),
//       .D_OUT (srcB) );

//ALU NEW INTERRUPTS SRCB MUX
  mux_8t1_nb  #(.n(32)) srcB_mux  (
       .SEL   (srcB_SEL), 
       .D0    (rs2), 
       .D1    (I_type), 
       .D2    (S_type), 
       .D3    (PC),
       .D4    (csr_RD), //value of the CSR register at the address given
       .D5    (0),
       .D6    (0),
       .D7    (0),
       .D_OUT (srcB) );    
       
     //ALU
  ALUmod myALU(
    .srcA(srcA),
    .srcB(srcB), 
    .alu_fun(ALU_FUN),
    .result(ALU_result)
     );
     
  BRANCH_COND_GEN branch_cond_gen(
  .rs1(rs1),
  .rs2(rs2),
  .br_eq(br_eq),
  .br_lt(br_lt),
  .br_ltu(br_ltu)
  );


    assign iobus_out = rs2;
    assign iobus_addr = ALU_result;
 

endmodule