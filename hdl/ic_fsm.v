`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UESTC
// Engineer: Chris Wang.
// 
// Create Date: 2020/12/10 20:24:18
// Design Name: awg_10g
// Module Name: ic_dram
// Project Name: 
// Target Devices: xcku040-ffva1156-2-e
// Tool Versions: vivado 2017.2
// Description: use distributed ram to generate Icache, this file is icache state machine.
// 
// Dependencies: 
// 
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ic_fsm(
        //clock and reset
        input   clk,
        input   rst_n,
        
        //start or stop should be a signal like a pulse, asserts only a cycle of clk.
        //when stop is asserted by host, start signal should be updated again.
        input   start,
        input   stop,

        //interface with cpu
        input           [32 : 0]    cpu_read_addr,    // data from cpu
        input                       cpu_read_valid,

        output  reg     [127 : 0]   ic_data,     // if hit, data_o = ram_doutb, or data is not valid.
        output  reg                 cpu_read_ack,

        //interface with DMA CTRL
        input           [32 : 0]    first_addr, //instr's first read addr from host control.

        output  reg     [32 : 0]    ic_read_dma_addr,    // miss hit: read from ddr.
        output  reg                 ic_read_dma_valid,

        input                       ic_read_dma_ack,
        input           [127 : 0]   ic_read_dma_data,
        
        // cache status signals
        output   reg                tag_hit,
        output   reg                tag_miss,

        //internal signals
        output  reg                 tag_wea,            //enable write operations           
        output  reg     [8 : 0]     tag_addra,        //write addr into tag ram
        output  reg     [19 : 0]    tag_dina,          //write data into ic ram
        output  reg     [8 : 0]     tag_addrb,        //read addr into tag ram
        input           [19 : 0]    tag_doutb,
        // tag data is read in ic_top and is only used for judge cache is hit or miss

        output  reg                 ram_wea,            //enable write operations 
        output  reg     [8 : 0]     ram_addra,        //wr         ite addr
        output  reg     [127 : 0]   ram_dina,          //write data 
        output  reg     [8 : 0]     ram_addrb,        //read addr
        input           [127 : 0]   ram_doutb         //read data from ic_ram
    );
    
    parameter  CACHE_DEPTH = 512; 
    
    
    localparam  IDLE        =   3'b000;
    localparam  IS_PRELOAD  =   3'b001;
    localparam  PREFILL     =   3'b011;
    localparam  FETCH       =   3'b010;
    localparam  REFILL      =   3'b110;

   

    reg     [9:0]       cnt_prefill;
    reg     [9:0]       cnt_refill;
    reg     [2:0]       nstate;
    reg     [2:0]       cstate;    

    reg                 preload_over;
    reg                 refill_down;
    reg     [32:0]      cpu_addr_reg;

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)  cstate  <=  IDLE;
    else        cstate  <=  nstate;
end    

always @(*)begin
    case(cstate)

        IDLE:begin
        
            if(start)  nstate = IS_PRELOAD;
            
            else nstate = IDLE;   
                        
        end
        
        IS_PRELOAD:begin
        
            if(preload_over)begin

                if(cpu_read_valid) nstate = FETCH;

                else if(stop)  nstate = IDLE;

                else nstate = IS_PRELOAD;

            end
            
            else nstate = PREFILL;
            
        end

        PREFILL:begin
        
            //according to hdl, cnt is counting from 0x01, so top boundary is cache depth.
            if(cnt_prefill == CACHE_DEPTH)   nstate = FETCH;
            
            else if(stop) nstate = IDLE; 
            
            else nstate = PREFILL;
            
        end

        //state machine will change untill tag_hit or tag_miss is deceted.
        FETCH:begin
            
            // cpu_read_valid need deasserts, and time machine will turn into IS_PRELOAD.
            if( tag_hit && (!cpu_read_valid) ) nstate = IS_PRELOAD;
            
            else if( tag_miss ) nstate = REFILL;
            
            else nstate = FETCH;
            
        end

        REFILL:begin
        
            if(cnt_refill   ==  CACHE_DEPTH)   nstate = IS_PRELOAD;
            
            else if(stop) nstate =  IDLE;
            
            else nstate =  REFILL;     
        end

        default: nstate = IDLE;

    endcase
end

always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin

                ic_data             <=      128'd0;
                cpu_read_ack        <=      1'b0;
                
                ic_read_dma_addr    <=      33'd0;  
                ic_read_dma_valid   <=      1'b0;

                tag_wea             <=      1'b0;
                tag_addra           <=      9'd0;
                tag_dina            <=      20'd0;
                tag_addrb           <=      9'd0;

                ram_wea             <=      1'b0;
                ram_addra           <=      9'd0;
                ram_dina            <=      20'd0;
                ram_addrb           <=      9'd0;
                
                preload_over        <=      'b0;         
                refill_down         <=      'b0;
                
    end
    else begin
        case(cstate)
            IDLE: begin
                //ic_data             <=      128'd0;   //data  would not change in ic_data bus when state return to idle.
                cpu_read_ack        <=      1'b0;

                //update instr read addr, this register is updated by host from axi lite channel.
                ic_read_dma_addr    <=      128'd0;   
                ic_read_dma_valid   <=      1'b0;

                tag_wea             <=      1'b0;
                tag_addra           <=      9'd0;
                tag_dina            <=      20'd0;
                tag_addrb           <=      9'd0;

                ram_wea             <=      1'b0;
                ram_addra           <=      9'd0;
                ram_dina            <=      20'd0;
                ram_addrb           <=      9'd0;

                cnt_prefill         <=      10'd0;
                cnt_refill          <=      10'd0;
                
                //when stop signal is asserted, cache should be updated into idle state.
                preload_over        <=      'b0;                 

            end
            
            IS_PRELOAD:begin
                //ic_data             <=      128'd0;   //data  would not change in ic_data bus when state return to idle.
                cpu_read_ack        <=      1'b0;

                //update instr read addr, this register is updated by host from axi lite channel.
                ic_read_dma_addr    <=      first_addr;   
                ic_read_dma_valid   <=      1'b0;

                tag_wea             <=      1'b0;
                tag_addra           <=      9'd0;
                tag_dina            <=      20'd0;
                tag_addrb           <=      9'd0;

                ram_wea             <=      1'b0;
                ram_addra           <=      9'd0;
                ram_dina            <=      20'd0;
                ram_addrb           <=      9'd0;

                cnt_prefill         <=      10'd0;
                cnt_refill          <=      10'd0;
                
                
            end

            //preload data form address which is loaded by host(first address).
            PREFILL:begin
                if(ic_read_dma_ack) begin
                    ic_read_dma_addr    <=      ic_read_dma_addr    +   33'd16;
                    ic_read_dma_valid   <=      1'b0;
                    cnt_prefill         <=      cnt_prefill     +   10'd1;

                    //write data into tag ram and data ram
                    tag_wea             <=      1'b1;
                    tag_addra           <=      ic_read_dma_addr[12:4];
                    tag_dina            <=      ic_read_dma_addr[32:13];

                    ram_wea             <=      1'b1;
                    ram_addra           <=      ic_read_dma_addr[12:4];
                    ram_dina            <=      ic_read_dma_data[127:0];                    

                end

                //reset cnt_prefill count when it reaches the most boundary.
                else if(cnt_prefill     ==      CACHE_DEPTH)begin
                    cnt_prefill         <=      'd0;
                    ic_read_dma_valid   <=      1'b0;
                    preload_over        <=      'd1;    //jump preload operation and step into fetch function.

                    tag_wea             <=      1'b0;
                    ram_wea             <=      1'b0;   
                end
                
                //stay in read operation.
                else begin
                    ic_read_dma_valid   <=      1'b1;
                    ic_read_dma_addr    <=      ic_read_dma_addr;
                    //cnt_prefill         <=      cnt_prefill;  //synthesis tools like vivado will geneate latch automaticly 
                end

            end
            
            FETCH:begin
            
                tag_addrb           <=      cpu_read_addr[12:4];

                ram_addrb           <=      cpu_read_addr[12:4];
                     
                if(tag_hit)begin
                    ic_data             <=      ram_doutb;
                    cpu_read_ack        <=      'b1;
                end
                else if(tag_miss)begin
                    //update read address which is ready for refill operation.
                    ic_read_dma_addr    <=      cpu_read_addr;          
                    cpu_read_ack        <=      'b0;
                end 

            end

            REFILL:begin

                if(ic_read_dma_ack) begin
                    ic_read_dma_addr    <=      ic_read_dma_addr    +   33'd16;
                    ic_read_dma_valid   <=      1'b0;
                    cnt_refill          <=      cnt_refill          +   10'd1;

                    //write data into tag ram and data ram
                    tag_wea             <=      1'b1;
                    tag_addra           <=      ic_read_dma_addr[12:4];
                    tag_dina            <=      ic_read_dma_addr[32:13];

                    ram_wea             <=      1'b1;
                    ram_addra           <=      ic_read_dma_addr[12:4];
                    ram_dina            <=      ic_read_dma_data[127:0];  
                    
                    //cnt has not been into 'd1 yet
                    if(cnt_refill       ==      'd0) begin      
                        ic_data             <=      ic_read_dma_data;
                        cpu_read_ack        <=      'b1;                 
                    end
                    else begin
                        ic_data             <=      'd0; //TODO! i am not sure whether latch should be used here
                        cpu_read_ack        <=      'b0;
                    end
                end

                //reset cnt_prefill count when it reaches the most boundary.
                else if(cnt_refill      ==      CACHE_DEPTH - 'd1)begin
                    cnt_refill          <=      'd0;
                    ic_read_dma_valid   <=      1'b0;
                    tag_wea             <=      1'b0;
                    ram_wea             <=      1'b0;
                    
                    ic_data             <=      'd0; 
                    cpu_read_ack        <=      'b0;
                end
                
                //stay in read operation.
                else begin
                    ic_read_dma_valid   <=      1'b1;
                    ic_read_dma_addr    <=      ic_read_dma_addr;

                    ic_data             <=      'd0; 
                    cpu_read_ack        <=      'b0;
                end
            end

        endcase
    end
end

//data will output immeditately, so we need generate tag hit or miss signal in negedge clock.
//then fsm will detect it and step into next state.
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        tag_hit             <=      'b0;
        tag_miss            <=      'b0;
    end
    else if( (tag_doutb    ==      cpu_read_addr[32:13]) && (cstate == FETCH) )begin
        tag_hit             <=      'b1;
        tag_miss            <=      'b0;
    end

    else if( (tag_doutb    !=      cpu_read_addr[32:13]) && (cstate == FETCH) )begin
        tag_hit             <=      'b0;
        tag_miss            <=      'b1;
    end
    else begin
        tag_hit             <=      'b0;
        tag_miss            <=      'b0;
    end
end

endmodule
