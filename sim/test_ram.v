module tb_ic_ram;    

// ic_ram Parameters
parameter PERIOD  = 10         ;
parameter ram_dw  = 128        ;
parameter ram_aw  = 9          ;
parameter dp      = 1 << ram_aw;

parameter ram_depth = 16;

// ic_ram Inputs
reg   clk                                  = 0 ;
reg   rst_n								   = 0 ;
reg   wea                                  = 0 ;

reg   [ram_aw - 1 : 0]  addra              = 0 ;
reg   [ram_dw - 1 : 0]  dina               = 0 ;
reg   [ram_aw - 1 : 0]  addrb              = 0 ;

// ic_ram Outputs
wire  [ram_dw - 1 : 0]  doutb              ;


initial
begin
    forever #(PERIOD/2)  clk=~clk;
end

initial
begin
    #1 rst_n  =  1;
end

ic_ram #(
    .ram_dw ( ram_dw ),
    .ram_aw ( ram_aw )
    )
 u_ic_ram (
    .clk                     ( clk                     ),
	.rst_n                   ( rst_n                   ),
    .wea                     ( wea                     ),
    .addra                   ( addra  [ram_aw - 1 : 0] ),
    .dina                    ( dina   [ram_dw - 1 : 0] ),
    .addrb                   ( addrb  [ram_aw - 1 : 0] ),

    .doutb                   ( doutb  [ram_dw - 1 : 0] )
);

integer i;

initial
begin
    //写使能时使用for循环遍历每个地址，给地址0写入1，给地址1写入2···给地址255写100
    for (i = 0; i < ram_depth; i = i + 1) 
    begin
	@(posedge clk) 
        begin
	    addra = i;
		wea = 1;
	    dina = dina  + 1;
	end
    end
    
    //读使能时再将 刚才写入的值一一读出来
    for (i = 0; i < ram_depth; i = i + 1) 
    begin
	@(posedge clk)
		wea = 0;
		addrb = i;
    end 

    #20000 $finish;
end

endmodule