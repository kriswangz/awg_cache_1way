`timescale 1ns / 1ps

module m_axi4_read_top #
	(
		// Users to add parameters here

		// User parameters ends
		// Do not modify the parameters beyond this line


		// Parameters of Axi Master Bus Interface M0_AXI_READ
		parameter  C_M0_AXI_READ_TARGET_SLAVE_BASE_ADDR	= 32'h00000000,
		parameter integer C_M0_AXI_READ_BURST_LEN		= 1,
		parameter integer C_M0_AXI_READ_ID_WIDTH		= 4,
		parameter integer C_M0_AXI_READ_ADDR_WIDTH		= 32,
		parameter integer C_M0_AXI_READ_DATA_WIDTH		= 128,
		parameter integer C_M0_AXI_READ_ARUSER_WIDTH	= 0,
		parameter integer C_M0_AXI_READ_RUSER_WIDTH		= 0
	)
	(
		// Users to add ports here

		// User ports ends
		// Do not modify the ports beyond this line


		// Ports of Axi Master Bus Interface M0_AXI_READ
		input 										m0_axi4_rtxn,
		input 	[C_M0_AXI_READ_ADDR_WIDTH-1 : 0] 	instrc_read_addr,
		output 	[C_M0_AXI_READ_DATA_WIDTH-1 : 0] 	instrc_read_data,
		output										instrc_read_valid,
		output   									m0_axi_read_txn_done,
		output   									m0_axi_read_error,
		input   									m0_axi_read_aclk,
		input   									m0_axi_read_aresetn,
		output  [C_M0_AXI_READ_ID_WIDTH-1 : 0] 		m0_axi_read_arid,
		output  [C_M0_AXI_READ_ADDR_WIDTH-1 : 0] 	m0_axi_read_araddr,
		output  [7 : 0] 							m0_axi_read_arlen,
		output  [2 : 0] 							m0_axi_read_arsize,
		output  [1 : 0] 							m0_axi_read_arburst,
		output   									m0_axi_read_arlock,
		output  [3 : 0]	 							m0_axi_read_arcache,
		output  [2 : 0] 							m0_axi_read_arprot,
		output  [3 : 0] 							m0_axi_read_arqos,
		output  [C_M0_AXI_READ_ARUSER_WIDTH-1 : 0] 	m0_axi_read_aruser,
		output   									m0_axi_read_arvalid,
		input   									m0_axi_read_arready,
		input  [C_M0_AXI_READ_ID_WIDTH-1 : 0] 		m0_axi_read_rid,
		input  [C_M0_AXI_READ_DATA_WIDTH-1 : 0] 	m0_axi_read_rdata,
		input  [1 : 0] 								m0_axi_read_rresp,
		input   									m0_axi_read_rlast,
		input  [C_M0_AXI_READ_RUSER_WIDTH-1 : 0] 	m0_axi_read_ruser,
		input   									m0_axi_read_rvalid,
		output   									m0_axi_read_rready
	);
// Instantiation of Axi Bus Interface M0_AXI_READ
	m_axi4_read_v1_0_M0_AXI_READ # ( 
		.C_M_TARGET_SLAVE_BASE_ADDR(C_M0_AXI_READ_TARGET_SLAVE_BASE_ADDR),
		.C_M_AXI_BURST_LEN(C_M0_AXI_READ_BURST_LEN),
		.C_M_AXI_ID_WIDTH(C_M0_AXI_READ_ID_WIDTH),
		.C_M_AXI_ADDR_WIDTH(C_M0_AXI_READ_ADDR_WIDTH),
		.C_M_AXI_DATA_WIDTH(C_M0_AXI_READ_DATA_WIDTH),
		.C_M_AXI_ARUSER_WIDTH(C_M0_AXI_READ_ARUSER_WIDTH),
		.C_M_AXI_RUSER_WIDTH(C_M0_AXI_READ_RUSER_WIDTH)
	) m_axi4_read_v1_0_M0_AXI_READ_inst (
		.INIT_AXI_RTXN(m0_axi4_rtxn),
		.READ_ADDR(instrc_read_addr),
		.INSTRUCTION(instrc_read_data),
		.INSTR_VALID(instrc_read_valid),
		.TXN_DONE(m0_axi_read_txn_done),
		.ERROR(m0_axi_read_error),
		.M_AXI_ACLK(m0_axi_read_aclk),
		.M_AXI_ARESETN(m0_axi_read_aresetn),
		.M_AXI_ARID(m0_axi_read_arid),
		.M_AXI_ARADDR(m0_axi_read_araddr),
		.M_AXI_ARLEN(m0_axi_read_arlen),
		.M_AXI_ARSIZE(m0_axi_read_arsize),
		.M_AXI_ARBURST(m0_axi_read_arburst),
		.M_AXI_ARLOCK(m0_axi_read_arlock),
		.M_AXI_ARCACHE(m0_axi_read_arcache),
		.M_AXI_ARPROT(m0_axi_read_arprot),
		.M_AXI_ARQOS(m0_axi_read_arqos),
		.M_AXI_ARUSER(m0_axi_read_aruser),
		.M_AXI_ARVALID(m0_axi_read_arvalid),
		.M_AXI_ARREADY(m0_axi_read_arready),
		.M_AXI_RID(m0_axi_read_rid),
		.M_AXI_RDATA(m0_axi_read_rdata),
		.M_AXI_RRESP(m0_axi_read_rresp),
		.M_AXI_RLAST(m0_axi_read_rlast),
		.M_AXI_RUSER(m0_axi_read_ruser),
		.M_AXI_RVALID(m0_axi_read_rvalid),
		.M_AXI_RREADY(m0_axi_read_rready)
	);

	// Add user logic here

	// User logic ends

	endmodule
