//
// RISC-V RV32I CPU
//
module riscv(

	input wire				 clk,
	input wire				 rst,        // high is reset
	
    // inst_mem
	input wire[31:0]         inst_i,
	output wire[31:0]        inst_addr_o,
	output wire              inst_ce_o,	//chip enable, always be 1 in this lab

    // data_mem
	input wire[31:0]         data_i,      // load data from data_mem
	output wire              data_we_o,
    output wire              data_ce_o,
	output wire[31:0]        data_addr_o,
	output wire[31:0]        data_o       // store data to  data_mem

);

//  instance your module  below
wire clrn = !rst;

wire 	    PCSrc;									 // MUX choose signal
wire [31:0] pc;                                      // program counter
wire [31:0] inst;                                    // instruction
wire [31:0] pc_o;                                    // program counter
wire [36:0] inst_decode;							 // instruction decode, if inst_decode == 1, means ex instruction is the corresponding inst 
wire [31:0] imm; 									 // the extended immediate 
wire [4:0]  rd1;									 // = rs1
wire [4:0]  rd2;									 // = rs2
wire [4:0]  wr;								     	 // reg to write
wire 		i_load;	  							     // MentoReg
wire        wreg;	   								 // if == 1, write register
wire [31:0] read_data1;
wire [31:0] read_data2;
wire [31:0] m_addr;									 // mem or i/o addr
wire [31:0] d_t_mem;                                 // store data
wire 		wmem;									 // write memory
wire   		rmem;									 // read memory
wire [31:0] data_2_rf;								 // data write to register file
wire [31:0] alu_out;								 // alu output
wire [31:0] mem_out;                                 // mem output
wire [31:0] next_pc;                                 // next pc

assign data_ce_o = rmem | wmem;
assign data_we_o = wmem;
assign data_addr_o = m_addr;
assign data_o = d_t_mem;
assign inst_addr_o = pc;
assign inst_ce_o = 1;

risc_v_32_if IF(clk,clrn,inst_i,next_pc,PCSrc,pc,inst);

risc_v_32_id ID(inst,pc,pc_o,inst_decode,imm,rd1,rd2,wr);

risc_v_32_regfile regfile(clk,clrn,rd1,rd2,wr,data_2_rf,wreg,read_data1,read_data2);

risc_v_32_ex EX(pc_o,read_data1,read_data2,inst,inst_decode,imm,m_addr,d_t_mem,wreg,wmem,rmem,i_load,alu_out,next_pc,PCSrc);

risc_v_32_mem MEM(m_addr,data_i,inst_decode,mem_out);

risc_v_32_wb WB(mem_out,alu_out,i_load,data_2_rf);


endmodule