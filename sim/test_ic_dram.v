`timescale  1ns / 1ps

module tb_ic_dram;   

// ic_dram Parameters
parameter PERIOD  = 10 ;
parameter tag_dw  = 20 ;
parameter tag_aw  = 9  ;
parameter ram_dw  = 128;
parameter ram_aw  = 9  ;


parameter   ram_depth   =   512;
parameter   cache_read_latency  =   2;    
// ic_dram Inputs
reg   clk                                  = 0 ;
reg   rst_n                                = 0 ;
reg   [32:0]  first_addr                   = 0 ;
reg   [32:0]  cpu_read_addr                = 0 ;
reg   [0:0]  cpu_read_valid                = 0 ;
reg   [0:0]  ic_read_dma_ack               = 0 ;
reg   [127:0]  ic_read_dma_data            = 0 ;

// ic_dram Outputs
wire  [127:0]  ic_data                     ;
wire  [0:0]  cpu_read_ack                  ;
wire  [32:0]  ic_read_dma_addr             ;
wire  [0:0]  ic_read_dma_valid             ;


initial
begin
    forever #(2)  clk=~clk;
end

initial
begin
    //  2 clock reset
    #(PERIOD*2) rst_n  =  1;
end

ic_dram #(
    .tag_dw ( tag_dw ),
    .tag_aw ( tag_aw ),
    .ram_dw ( ram_dw ),
    .ram_aw ( ram_aw ))
 u_ic_dram (
    .clk                     ( clk                        ),
    .rst_n                   ( rst_n                      ),
    .first_addr              ( first_addr         [32:0]  ),
    .cpu_read_addr           ( cpu_read_addr      [32:0]  ),
    .cpu_read_valid          ( cpu_read_valid     [0:0]   ),
    .ic_read_dma_ack         ( ic_read_dma_ack    [0:0]   ),
    .ic_read_dma_data        ( ic_read_dma_data   [127:0] ),

    .ic_data                 ( ic_data            [127:0] ),
    .cpu_read_ack            ( cpu_read_ack       [0:0]   ),
    .ic_read_dma_addr        ( ic_read_dma_addr   [32:0]  ),
    .ic_read_dma_valid       ( ic_read_dma_valid  [0:0]   )
);

integer i;

initial
begin
    
    //preload ram data
    for (i = 0; i < ram_depth; i = i + 1)
    begin
    	@(posedge clk)begin
                
                wait(ic_read_dma_valid == 1);
                repeat(cache_read_latency) @(posedge clk);
                ic_read_dma_ack = 1;
                ic_read_dma_data = i;

                repeat(1) @(posedge clk) ic_read_dma_ack = 0;
    	    end
    	    
    end
    
    //read data from cache
    for (i = 0; i < 2; i = i + 1)begin
        @(posedge clk) begin
            cpu_read_addr = i * 16;
            cpu_read_valid = 1'b1;
        end
        
        @(posedge clk) begin
            cpu_read_addr = i * 16;
            cpu_read_valid = 1'b0;
        end
        
        @(posedge clk) begin
            cpu_read_addr = i * 16;
            cpu_read_valid = 1'b0;
        end
        
        repeat(2) @(posedge clk);
        
    end    
     

    
    @(posedge clk) begin
        cpu_read_addr = 16*513;
        cpu_read_valid = 1'b1;
    end
    
    @(posedge clk) begin
        cpu_read_addr = 16*513;
        cpu_read_valid = 1'b0;
    end
    
   //refill
    for (i = 0; i < ram_depth; i = i + 1)
    begin
    	@(posedge clk)begin
                
                wait(ic_read_dma_valid == 1);
                repeat(cache_read_latency) @(posedge clk);
                ic_read_dma_ack = 1;
                ic_read_dma_data = i;

                repeat(1) @(posedge clk) ic_read_dma_ack = 0;
    	    end
    	    
    end
//    for (i = 0; i < ram_depth; i = i + 1) 
//    begin
//	@(posedge clk)
//		wea = 0;
//		addrb = i;
//    end 

    #20000 $finish;
end

endmodule