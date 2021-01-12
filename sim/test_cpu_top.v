`timescale  1ns / 1ps

module tb_cpu_top;

// cpu_top Parameters
parameter PERIOD                                = 10          ;
parameter tag_dw                                = 20          ;
parameter tag_aw                                = 9           ;
parameter ram_dw                                = 128         ;
parameter ram_aw                                = 9           ;
parameter C_M0_AXI_READ_TARGET_SLAVE_BASE_ADDR  = 32'h00000000;
parameter C_M0_AXI_READ_BURST_LEN               = 1           ;
parameter C_M0_AXI_READ_ID_WIDTH                = 4           ;
parameter C_M0_AXI_READ_ADDR_WIDTH              = 32          ;
parameter C_M0_AXI_READ_DATA_WIDTH              = 128         ;
parameter C_M0_AXI_READ_ARUSER_WIDTH            = 0           ;
parameter C_M0_AXI_READ_RUSER_WIDTH             = 0           ;

// cpu_top Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   start                                = 0 ;
reg   stop                                 = 0 ;
reg   instr_mem_s_axi_arready              = 0 ;
reg   [3:0]  instr_mem_s_axi_rid           = 0 ;
reg   [127:0]  instr_mem_s_axi_rdata       = 0 ;
reg   instr_mem_s_axi_rlast                = 0 ;
reg   [1:0]  instr_mem_s_axi_rresp         = 0 ;
reg   instr_mem_s_axi_rvalid               = 0 ;
reg   axis_ready                           = 0 ;

// cpu_top Outputs
wire  [31:0]  instr_mem_s_axi_araddr       ;
wire  [1:0]  instr_mem_s_axi_arburst       ;
wire  [3:0]  instr_mem_s_axi_arcache       ;
wire  [3:0]  instr_mem_s_axi_arid          ;
wire  [7:0]  instr_mem_s_axi_arlen         ;
wire  [0:0]  instr_mem_s_axi_arlock        ;
wire  [2:0]  instr_mem_s_axi_arprot        ;
wire  [3:0]  instr_mem_s_axi_arqos         ;
wire  [2:0]  instr_mem_s_axi_arsize        ;
wire  instr_mem_s_axi_arvalid              ;
wire  instr_mem_s_axi_rready               ;
wire  [31:0]  axis_data                    ;
wire  axis_valid                           ;
wire  axis_last                            ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

cpu_top #(
    .tag_dw                               ( tag_dw                               ),
    .tag_aw                               ( tag_aw                               ),
    .ram_dw                               ( ram_dw                               ),
    .ram_aw                               ( ram_aw                               ),
    .C_M0_AXI_READ_TARGET_SLAVE_BASE_ADDR ( C_M0_AXI_READ_TARGET_SLAVE_BASE_ADDR ),
    .C_M0_AXI_READ_BURST_LEN              ( C_M0_AXI_READ_BURST_LEN              ),
    .C_M0_AXI_READ_ID_WIDTH               ( C_M0_AXI_READ_ID_WIDTH               ),
    .C_M0_AXI_READ_ADDR_WIDTH             ( C_M0_AXI_READ_ADDR_WIDTH             ),
    .C_M0_AXI_READ_DATA_WIDTH             ( C_M0_AXI_READ_DATA_WIDTH             ),
    .C_M0_AXI_READ_ARUSER_WIDTH           ( C_M0_AXI_READ_ARUSER_WIDTH           ),
    .C_M0_AXI_READ_RUSER_WIDTH            ( C_M0_AXI_READ_RUSER_WIDTH            ))
 u_cpu_top (
    .clk                      ( clk                              ),
    .rst_n                    ( rst_n                            ),
    .start                    ( start                            ),
    .stop                     ( stop                             ),
    .instr_mem_s_axi_arready  ( instr_mem_s_axi_arready          ),
    .instr_mem_s_axi_rid      ( instr_mem_s_axi_rid      [3:0]   ),
    .instr_mem_s_axi_rdata    ( instr_mem_s_axi_rdata    [127:0] ),
    .instr_mem_s_axi_rlast    ( instr_mem_s_axi_rlast            ),
    .instr_mem_s_axi_rresp    ( instr_mem_s_axi_rresp    [1:0]   ),
    .instr_mem_s_axi_rvalid   ( instr_mem_s_axi_rvalid           ),
    .axis_ready               ( axis_ready                       ),

    .instr_mem_s_axi_araddr   ( instr_mem_s_axi_araddr   [31:0]  ),
    .instr_mem_s_axi_arburst  ( instr_mem_s_axi_arburst  [1:0]   ),
    .instr_mem_s_axi_arcache  ( instr_mem_s_axi_arcache  [3:0]   ),
    .instr_mem_s_axi_arid     ( instr_mem_s_axi_arid     [3:0]   ),
    .instr_mem_s_axi_arlen    ( instr_mem_s_axi_arlen    [7:0]   ),
    .instr_mem_s_axi_arlock   ( instr_mem_s_axi_arlock   [0:0]   ),
    .instr_mem_s_axi_arprot   ( instr_mem_s_axi_arprot   [2:0]   ),
    .instr_mem_s_axi_arqos    ( instr_mem_s_axi_arqos    [3:0]   ),
    .instr_mem_s_axi_arsize   ( instr_mem_s_axi_arsize   [2:0]   ),
    .instr_mem_s_axi_arvalid  ( instr_mem_s_axi_arvalid          ),
    .instr_mem_s_axi_rready   ( instr_mem_s_axi_rready           ),
    .axis_data                ( axis_data                [31:0]  ),
    .axis_valid               ( axis_valid                       ),
    .axis_last                ( axis_last                        )
);

initial
begin
    axis_ready = 1;

    repeat (2 ) @(posedge clk) start = 0;

    repeat (2 ) @(posedge clk) start = 1;
    
    @(posedge clk) start = 0;

end

endmodule