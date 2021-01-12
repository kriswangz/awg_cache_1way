`timescale  1ns / 1ps

module tb_ic_fsm;    

// ic_fsm Parameters 
parameter PERIOD  = 10;
parameter cache_depth = 2;
parameter cache_read_latency = 2;

// ic_fsm Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   [32 : 0]  cpu_read_addr              = 0 ;
reg   cpu_read_valid                       = 0 ;
reg   [32 : 0]  first_addr                 = 0 ;
reg   ic_read_dma_ack                      = 0 ;
reg   [127 : 0]  ic_read_dma_data          = 0 ;
reg   [19 : 0]  tag_doutb                  = 0 ;
reg   [127 : 0]  ram_doutb                 = 0 ;

// ic_fsm Outputs
wire  [127 : 0]  ic_data                   ;
wire  cpu_read_ack                         ;
wire  [32 : 0]  ic_read_dma_addr           ;
wire  ic_read_dma_valid                    ;
wire  tag_hit                              ;
wire  tag_miss                             ;
wire  tag_wea                              ;
wire  [8 : 0]  tag_addra                   ;
wire  [19 : 0]  tag_dina                   ;
wire  [8 : 0]  tag_addrb                   ;
wire  ram_wea                              ;
wire  [8 : 0]  ram_addra                   ;
wire  [127 : 0]  ram_dina                  ;
wire  [8 : 0]  ram_addrb                   ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #(PERIOD*2) rst_n  =  1;
end

ic_fsm  u_ic_fsm (
    .clk                     ( clk                          ),
    .rst_n                   ( rst_n                        ),
    .cpu_read_addr           ( cpu_read_addr      [32 : 0]  ),
    .cpu_read_valid          ( cpu_read_valid               ),
    .first_addr              ( first_addr         [32 : 0]  ),
    .ic_read_dma_ack         ( ic_read_dma_ack              ),
    .ic_read_dma_data        ( ic_read_dma_data   [127 : 0] ),
    .tag_doutb               ( tag_doutb          [19 : 0]  ),
    .ram_doutb               ( ram_doutb          [127 : 0] ),

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
    .ram_wea                 ( ram_wea                      ),
    .ram_addra               ( ram_addra          [8 : 0]   ),
    .ram_dina                ( ram_dina           [127 : 0] ),
    .ram_addrb               ( ram_addrb          [8 : 0]   )
);

integer i;

initial
begin
        @(posedge clk);
        wait(ic_read_dma_valid == 1);
        repeat(cache_read_latency) @(posedge clk);
        ic_read_dma_ack = 1;
        ic_read_dma_data = 1;

        repeat(1) @(posedge clk) ic_read_dma_ack = 0;

        @(posedge clk);
        wait(ic_read_dma_valid == 1);
        ic_read_dma_ack = 1;
        ic_read_dma_data = 2;

        repeat(5) @(posedge clk) ic_read_dma_ack = 0;  

        @(posedge clk) 
        cpu_read_addr   =   0;
        cpu_read_valid  =   1;

        @(posedge clk) 
        cpu_read_addr   =   0;
        cpu_read_valid  =   0;

    #20000 $finish;
end

endmodule