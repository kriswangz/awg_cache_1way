`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UESTC
// Engineer: Chris Wang.
// 
// Create Date: 2020/12/10 20:24:18
// Design Name: 
// Module Name: ic_dram
// Project Name: 
// Target Devices: xcku040-ffva1156-2-e
// Tool Versions: vivado 2017.2
// Description: use distributed ram to generate Icache
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

//  implement instruction cache.
//  TODO: brust function is not supported, add it.  
//  Read latency is 2 clocks(using distributed RAM), inlcuding cpu read and read dma interface.
//  if you wanna get data from cache, set cpu_addr_i and assert cpu_read_valid_i simultaneously,
//  if tag_hit, the program will return ic_data and assert ack at 3 clocks later.
//  it is same for the other module.
//  if tag_miss, the program will read data from DMA CTRL's read channel, latency is also 3 clocks.


/************************************************************************

    cpu_addr_i          ____xxxxxxx______________________________________
    cpu_read_valid_i    ____|▔▔▔|______________________________________

    ic_data_o           _______________________________________zzzzzz____
    ic_read_dma_ack_i   ____|▔▔▔|____|▔▔▔|____|▔▔▔|____|▔▔▔|____     

**************************************************************************/

module ic_dram(
    
    input   clk, 
    input   rst_n,


    //user control pannel definition
    input               start,
    input               stop,
    input   [32:0]      first_addr,

    // interface with cpu
    input   [32:0]      cpu_read_addr,
    input   [0:0]       cpu_read_valid,
    output  [127:0]     ic_data,
    output  [0:0]       cpu_read_ack,

    //interface with DMA CTRL
    output  [32:0]      ic_read_dma_addr,
    output  [0:0]       ic_read_dma_valid,
    input   [0:0]       ic_read_dma_ack,
    input   [127:0]     ic_read_dma_data

);

//tag ram addr and data width.
parameter tag_dw    =   20;
parameter tag_aw    =   9;

//data ram
parameter ram_dw    =   128;
parameter ram_aw    =   9;

wire    [0:0]               tag_wea;
wire    [tag_aw - 1 : 0]    tag_addra;
wire    [tag_dw - 1 : 0]    tag_dina;
wire    [tag_aw - 1 : 0]    tag_addrb;
wire    [tag_dw - 1 : 0]    tag_doutb;

wire    [0:0]               ram_wea;
wire    [ram_aw - 1 : 0]    ram_addra;
wire    [ram_dw - 1 : 0]    ram_dina;
wire    [ram_aw - 1 : 0]    ram_addrb;
wire    [ram_dw - 1 : 0]    ram_doutb;

ic_fsm #(

    .CACHE_DEPTH(512))  
u_ic_fsm (
    .clk                     ( clk                          ),
    .rst_n                   ( rst_n                        ),
    .start                   ( start                        ),
    .stop                    ( stop                         ),
    .first_addr              ( first_addr         [32 : 0]  ),

    .cpu_read_addr           ( cpu_read_addr      [32 : 0]  ),
    .cpu_read_valid          ( cpu_read_valid               ),
    .ic_read_dma_ack         ( ic_read_dma_ack              ),
    .ic_read_dma_data        ( ic_read_dma_data   [127 : 0] ),

    

    .ic_data                 ( ic_data            [127 : 0] ),
    .cpu_read_ack            ( cpu_read_ack                 ),
    .ic_read_dma_addr        ( ic_read_dma_addr   [32 : 0]  ),
    .ic_read_dma_valid       ( ic_read_dma_valid            ),
    .tag_hit                 ( tag_hit                      ),
    .tag_miss                ( tag_miss                     ),
    
    .tag_wea                 ( tag_wea                      ),
    .tag_addra               ( tag_addra          [8 : 0]   ),
    .tag_dina                ( tag_dina           [19 : 0]  ),
    .tag_addrb               ( tag_addrb          [8 : 0]   ),
    .tag_doutb               ( tag_doutb          [19 : 0]  ),
    
    .ram_wea                 ( ram_wea                      ),
    .ram_addra               ( ram_addra          [8 : 0]   ),
    .ram_dina                ( ram_dina           [127 : 0] ),
    .ram_addrb               ( ram_addrb          [8 : 0]   ),
    .ram_doutb               ( ram_doutb          [127 : 0] )
);

//instr cache's tag ram
ic_ram #(
    .ram_dw ( tag_dw ),
    .ram_aw ( tag_aw ))
 u_tag_ram (

    .clk                     ( clk                     ),
    .rst_n                   ( rst_n                   ),
    .wea                     ( tag_wea                 ),
    .addra                   ( tag_addra  [tag_aw - 1 : 0] ),
    .dina                    ( tag_dina   [tag_dw - 1 : 0] ),
    .addrb                   ( tag_addrb  [tag_aw - 1 : 0] ),

    .doutb                   ( tag_doutb  [tag_dw - 1 : 0] )
);

//instr cache's data ram
ic_ram #(
    .ram_dw ( ram_dw ),
    .ram_aw ( ram_aw ))
 u_data_ram (

    .clk                     ( clk                     ),
    .rst_n                   ( rst_n                   ),
    .wea                     ( ram_wea                 ),
    .addra                   ( ram_addra  [ram_aw - 1 : 0] ),
    .dina                    ( ram_dina   [ram_dw - 1 : 0] ),
    .addrb                   ( ram_addrb  [ram_aw - 1 : 0] ),

    .doutb                   ( ram_doutb  [ram_dw - 1 : 0] )
);
endmodule