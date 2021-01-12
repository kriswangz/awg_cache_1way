`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2020/06/29 20:24:18
// Design Name: 
// Module Name: ic_ram
// Project Name: 
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

//interface: read_valid read_addr, read_data, read_ack

module  cpu_top(
    
    input           clk,
    input           rst_n,
    
    input           start,
    input           stop,
    
    //read interface from ddr, it should be connected to instr read ports in ddr3 module.
    output 	[31:0]	instr_mem_s_axi_araddr,
	output 	[1:0]	instr_mem_s_axi_arburst,
	output 	[3:0]	instr_mem_s_axi_arcache,
	output	[3:0]	instr_mem_s_axi_arid,
	output 	[7:0]	instr_mem_s_axi_arlen,
	output 	[0:0]	instr_mem_s_axi_arlock,
	output 	[2:0]	instr_mem_s_axi_arprot,
	output 	[3:0]	instr_mem_s_axi_arqos,
	input 			instr_mem_s_axi_arready,
	input	[3:0]	instr_mem_s_axi_rid,
	output 	[2:0]	instr_mem_s_axi_arsize,
	output 			instr_mem_s_axi_arvalid,
	input 	[127:0]	instr_mem_s_axi_rdata,
	input 			instr_mem_s_axi_rlast,
	output 			instr_mem_s_axi_rready,
	input 	[1:0]	instr_mem_s_axi_rresp,
	input 			instr_mem_s_axi_rvalid,
   
	//axi-stream bus.
	//send descriptor to axi-stream fifo.
	input           axis_ready,
	output  [31:0]  axis_data,
	output          axis_valid,
	output          axis_last
    
);

// ic_dram Parameters
parameter tag_dw  = 20 ;
parameter tag_aw  = 9  ;
parameter ram_dw  = 128;
parameter ram_aw  = 9  ;

// Parameters of Axi Master Bus Interface M0_AXI_READ
//channel base addr, the real address is base_addr + read_addr.
parameter  C_M0_AXI_READ_TARGET_SLAVE_BASE_ADDR	= 32'h00000000;  
parameter integer C_M0_AXI_READ_BURST_LEN		= 1;
parameter integer C_M0_AXI_READ_ID_WIDTH		= 4;
parameter integer C_M0_AXI_READ_ADDR_WIDTH		= 32;
parameter integer C_M0_AXI_READ_DATA_WIDTH		= 128;
parameter integer C_M0_AXI_READ_ARUSER_WIDTH	= 0;
parameter integer C_M0_AXI_READ_RUSER_WIDTH		= 0;

//instr_get module with Icache module
wire                cpu_read_ack;
wire    [127:0]     cpu_read_data;
wire    [31:0]      cpu_read_addr;
wire                cpu_read_valid;

//Icache module with ddr read module
//dma is called here, but actually this module will read instr from ddr module
//which is casced with serval crossbar that is used for data width converter.
wire                ic_read_dma_valid;
wire    [31:0]      ic_read_dma_addr;
wire                ic_read_dma_ack;
wire    [127:0]     ic_read_dma_data;

wire                generate_down;
wire    [127:0]     segment_instruc;
wire                segment_instruc_valid;



//ic_get inst
instruction_get instruction_get_ch1(

	.clk(clk),
	.rstn(rst_n), 
	
	//start or stop signal need a one pulse signal, level sigal used in here
	//may result in erros in time diagram.
	.start(start),
	.stop(stop),
	.start_addr(32'd0),
	
	//instr_module need a read_down signal which is delayed for several clocks
	//by read_valid, it indicates a transcation is over.
	//Here, i connect it to the same ack signal. 
	.read_valid(cpu_read_ack),
	.read_done(cpu_read_ack),
	.read_data(cpu_read_data),
	
	.axi_araddr(cpu_read_addr),   //read address 
    .axi_read_txn(cpu_read_valid), // read en
    
	.generate_done(generate_done),
	
	.segment_instruc(segment_instruc),
	.segment_instruc_valid(segment_instruc_valid)
);

//ic_dram inst
ic_dram #(
    .tag_dw ( tag_dw ),
    .tag_aw ( tag_aw ),
    .ram_dw ( ram_dw ),
    .ram_aw ( ram_aw ))
 u_ic_dram (
    .clk                     ( clk                        ),
    .rst_n                   ( rst_n                      ),
    
    .start                   ( start                      ),
    .stop                    ( stop                       ),
    .first_addr              ( 32'd0  ),
    
    //cpu read instr cache channel
    .cpu_read_addr           ( cpu_read_addr  ),
    .cpu_read_valid          ( cpu_read_valid   ),
    .ic_data                 ( cpu_read_data ),
    .cpu_read_ack            ( cpu_read_ack   ),
    
    //cache read ddr channel
    .ic_read_dma_ack         ( ic_read_dma_ack            ),
    .ic_read_dma_data        ( ic_read_dma_data   [127:0] ),
    //read address in ic_dram module is 33bits in general, but axi lite's read address is 32bits
    .ic_read_dma_addr        ( ic_read_dma_addr   [31:0]  ),   
    .ic_read_dma_valid       ( ic_read_dma_valid          )
);

//ic_descriptor_gen inst
descriptor_generator descriptor_generator_ch1(
	.clk(clk),
	.rstn(rst_n),
	.instrcution(segment_instruc),
	.instrc_valid(segment_instruc_valid),
	.generate_done(generate_done),
	.axis_ready(axis_ready),
	.axis_data(axis_data),
	.axis_valid(axis_valid),
	.axis_last(axis_last)
);
    
// read interface, instr from ddr
//instruction_mem_wrapper instruction_mem_ch1
//   (
//	.axi4_aclk(clk),
//	.axi4_aresetn(rst_n),
//	.axi4_rtxn(axi_read_txn),//rtxn must enable after read address valid or together
//	.instr_read_addr(axi_araddr),
//	.instr_read_data(read_data),
//    .instr_read_valid(read_valid),
//	//axi4 ports, it should be connected to ddr ports
//	.instr_mem_s_axi_araddr(instr_mem_s_axi_araddr),
//	.instr_mem_s_axi_arburst(instr_mem_s_axi_arburst),
//	.instr_mem_s_axi_arcache(instr_mem_s_axi_arcache),
//	.instr_mem_s_axi_arid(instr_mem_s_axi_arid),  
//	.instr_mem_s_axi_arlen(instr_mem_s_axi_arlen),
//	.instr_mem_s_axi_arlock(instr_mem_s_axi_arlock),
//	.instr_mem_s_axi_arprot(instr_mem_s_axi_arprot),
//	.instr_mem_s_axi_arqos(instr_mem_s_axi_arqos),
//	.instr_mem_s_axi_arready(instr_mem_s_axi_arready),
//	.instr_mem_s_axi_rid(instr_mem_s_axi_rid),
//	.instr_mem_s_axi_arsize(instr_mem_s_axi_arsize),
//	.instr_mem_s_axi_arvalid(instr_mem_s_axi_arvalid),
//	.instr_mem_s_axi_rdata(instr_mem_s_axi_rdata),
//	.instr_mem_s_axi_rlast(instr_mem_s_axi_rlast),
//	.instr_mem_s_axi_rready(instr_mem_s_axi_rready),
//	.instr_mem_s_axi_rresp(instr_mem_s_axi_rresp),
//	.instr_mem_s_axi_rvalid(instr_mem_s_axi_rvalid),
//	
//	.read_error(),
//	.read_txn_done(read_done)
//	);	
	
m_axi4_read_top #(
    .C_M0_AXI_READ_TARGET_SLAVE_BASE_ADDR ( 32'd0 ),
    .C_M0_AXI_READ_BURST_LEN              ( 1     ),
    .C_M0_AXI_READ_ID_WIDTH               ( 4     ),
    .C_M0_AXI_READ_ADDR_WIDTH             ( 32    ),
    .C_M0_AXI_READ_DATA_WIDTH             ( 128   ),
    .C_M0_AXI_READ_ARUSER_WIDTH           ( 0     ),
    .C_M0_AXI_READ_RUSER_WIDTH            ( 0     ))
 m_axi_read_instr_inst (
 
    .m0_axi4_rtxn            ( ic_read_dma_valid ),  // read dma valid will deassert until ack is asserted.
    .instrc_read_addr        ( ic_read_dma_addr   [31:0] ),
    .instrc_read_data        ( ic_read_dma_data   [127:0] ),
    .instrc_read_valid       ( ic_read_dma_ack ),
    .m0_axi_read_txn_done    ( ),
        
    // axi read channel 
    .m0_axi_read_aclk        ( clk    ),
    .m0_axi_read_aresetn     ( rst_n  ),

    .m0_axi_read_rid         ( instr_mem_s_axi_rid                ),
    .m0_axi_read_rdata       ( instr_mem_s_axi_rdata              ),
    .m0_axi_read_rresp       ( instr_mem_s_axi_rresp              ),
    .m0_axi_read_rlast       ( instr_mem_s_axi_rlast              ),
    .m0_axi_read_ruser       ( 1'b0 ),
    .m0_axi_read_rvalid      ( instr_mem_s_axi_rvalid             ),
    .m0_axi_read_rready      ( instr_mem_s_axi_rready             ),
    
    .m0_axi_read_error       ( ),
    
    //address channel 
    .m0_axi_read_arid        ( instr_mem_s_axi_arid     ),
    .m0_axi_read_araddr      ( instr_mem_s_axi_araddr  [31 : 0]   ),
    .m0_axi_read_arvalid     ( instr_mem_s_axi_arvalid            ),
    .m0_axi_read_arready     ( instr_mem_s_axi_arready            ),
    .m0_axi_read_arlen       ( instr_mem_s_axi_arlen              ),
    .m0_axi_read_arsize      ( instr_mem_s_axi_arsize             ),
    .m0_axi_read_arburst     ( instr_mem_s_axi_arburst            ),
    .m0_axi_read_arlock      ( instr_mem_s_axi_arlock             ),
    .m0_axi_read_arcache     ( instr_mem_s_axi_arcache            ),
    .m0_axi_read_arprot      ( instr_mem_s_axi_arprot             ),
    .m0_axi_read_arqos       ( instr_mem_s_axi_arqos              ),
    .m0_axi_read_aruser      ( ) //non connect

);

endmodule
