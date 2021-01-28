module descriptor_generator(
	input			clk,
	input			rstn,
	input [127:0]	instrcution,
	input 			instrc_valid,
	output			generate_done,

	output	reg		desc_gen_last,

	input			axis_ready,
	output[31:0]	axis_data,
	output			axis_valid,
	output			axis_last
);
	wire[32:0]		ddr_address;
	wire[25:0]		buff_length;
	wire[15:0]		segment_times;

	wire 			generate_done_axi_stream;

	wire			next_data;
	// reg				write_en;
	reg		[15:0]	segment_num;
	reg		[2:0]	data_num;
	reg		[31:0]	data_gen;
	reg				tvalid;

	//jump instrcution parameter determination
	assign	ddr_address		= instrc_valid ? instrcution[96:64]	:ddr_address;
	assign	buff_length		= instrc_valid ? instrcution[57:32]	:buff_length;
	assign	segment_times	= instrc_valid ? instrcution[19:4]	:segment_times;

	assign	next_data 		= axis_ready&tvalid;		//the axis_valid signal cause timing loop;
	assign	axis_last		= data_num==3'd7 ?1'b1:1'b0;
	assign	axis_data		= data_gen;
	assign	axis_valid		= tvalid&(~generate_done_axi_stream);	//data valid signal align data
	
	//generate_dwon signal is used for pipline, pretrigger data acquisition
	assign	generate_done	= ( (segment_num == segment_times - 16'd1) && (data_num == 3'd2) ) ? 1'b1:1'b0;
	assign	generate_done_axi_stream	=	( segment_num >= segment_times ) ? 1'b1:1'b0;


	always @(posedge clk or negedge rstn) begin
		if(!rstn)begin
			desc_gen_last	<=	1'b0;
		end
		
		//instc_valid always has one clock delay after generate_done_axi_stream
		else if( generate_done_axi_stream )begin
			desc_gen_last	<=	1'b1;
		end

		else if( instrc_valid )begin
			desc_gen_last	<=	1'b0;
		end

		else begin
			desc_gen_last	<=	desc_gen_last;
		end
	end

	//assign	desc_gen_last	=	generate_done_axi_stream;
	// assign	desc_gen_last	=	axis_last && ((segment_num == segment_times - 16'd1));

always @(posedge clk or negedge rstn)//must use timing loop
	begin 
		if(!rstn)
			tvalid <= 1'b0;
		else
			tvalid <= instrc_valid|( (~generate_done_axi_stream) & tvalid);
	end

always @(posedge clk or negedge rstn)
	begin
		if(!rstn)
			begin
				data_num 		<='d0;
				segment_num		<='d0;
			end
		else if(generate_done_axi_stream)
			begin
				data_num 		<='d0;
				segment_num		<='d0;
			end
		else if(next_data)
			begin
				data_num 		<= data_num + 3'd1;
			if(data_num==3'd7)
				segment_num		<= segment_num+16'd1;
			else
				segment_num		<= segment_num;
			end
		else
				data_num 		<= data_num;
	end
always @(*)
	begin
		if(!rstn)
			data_gen <='d0;
		else case(data_num)
			3'd0:data_gen <=32'h80002000;
			3'd1:data_gen <=32'h0;
			3'd2:data_gen <=ddr_address[31:0];
			3'd3:data_gen <={31'd0,ddr_address[32]};
			3'd4:data_gen <=32'h0;
			3'd5:data_gen <=32'h0;
			3'd6:data_gen <={6'b000011,buff_length};
			3'd7:data_gen <=32'h0;
			default:data_gen <=32'h0;
		endcase
	end

endmodule
