module instruction_get(
input 		clk,
input 		rstn,
input		start,
input		stop,
input[31:0]	start_addr,

input		read_done, //from instruction mem module 
input[127:0]read_data,
input		read_valid,

input		generate_done,
input		desc_gen_last,

output[31:0]axi_araddr,
output		axi_read_txn,

output[127:0]segment_instruc,
output		 segment_instruc_valid
);

localparam	SEGMENT_OPERATION 	= 3'b101;   //wafeform generation sheet :波形合成方案
localparam	JUM_OPERATION		= 3'b111;       //

localparam 	IDLE 				  = 	3'b000;             //the steps of waveform generation, state IDLE wouldnt
localparam	GET_1ST_INSTRUC		  = 	3'b001;       //play the role in the circle
localparam  WAIT_GENERATE		  = 	3'b011;
localparam	GET_INSTRUC			  = 	3'b010;
localparam  DECODE_INSTRUC		  = 	4'b110;
localparam	JUMP_COMPARE  		  = 	4'b100;

reg	[2:0]	cstate;
reg	[2:0]	nstate;

integer 	i;

reg			read_valid_temp;
reg [127:0]	read_data_temp;

wire		segment_en;	       //instrcution contain segment operaation code
wire		jump_en;	         //instrcution contain jump operaation code
wire [31:0]	jump_addr;	   //instrcution jump address
wire [15:0]	counter_num;   //the number of jump times counter
wire [15:0] jump_times;	   //the jump times

reg			read_en;
reg	 [31:0]	read_addr;

reg  [15:0] counter_jump[7:0];//jump counters

assign 		axi_araddr 		= read_addr;
//assign 		axi_read_txn	= read_en;
assign 		axi_read_txn	= (!read_en_reg2) && read_en_reg1;

/********jump instrcution transport***********/
assign		segment_en 				= read_data_temp[127:125]==SEGMENT_OPERATION ? 1'b1:1'b0;
assign		segment_instruc 		= read_data_temp;
assign		segment_instruc_valid	= read_valid_temp;
/********jump instrcution parameter determination***********/     // read_data_temp's bits wrong??????
assign		jump_en					= read_data_temp[127:125]==JUM_OPERATION ? 1'b1:1'b0;
assign		jump_addr				= read_data_temp[127:125]==JUM_OPERATION ? read_data_temp[95:64]:jump_addr;
assign		counter_num				= read_data_temp[127:125]==JUM_OPERATION ? read_data_temp[47:32]:counter_num;
assign		jump_times				= read_data_temp[127:125]==JUM_OPERATION ? read_data_temp[15:0] :jump_times;

reg read_en_reg1;
reg read_en_reg2;

always @(posedge clk or negedge rstn)begin
	if(!rstn)begin
		read_en_reg1 <=	1'b0;
		read_en_reg2 <= 1'b0;
	end

	else begin
		read_en_reg1 <=	read_en;
		read_en_reg2 <= read_en_reg1;
	end
end

//time machine
always @(posedge clk)
	begin
		if(!rstn)
			cstate 	<= IDLE;
		else
			cstate	<= nstate;
	end
always @(*)
	begin
		case(cstate[2:0])
			IDLE:
				if(start)
					nstate 	=	GET_1ST_INSTRUC;
				else
					nstate	=	IDLE;

			//first instruction must be segement instruction
			GET_1ST_INSTRUC:
				if(read_valid) //wait for read done signal from module : instruction_mem
					nstate	=	WAIT_GENERATE;
				else
					nstate	=	GET_1ST_INSTRUC;

			WAIT_GENERATE:
				if(generate_done) //wait for generation done signal from module : Descriptor Generator 
				begin
					if(stop)
						nstate  =  IDLE;
					else
						nstate	=	GET_INSTRUC;
				end
				else
					nstate	=	WAIT_GENERATE;
			GET_INSTRUC:
				if(read_valid)
					nstate	=	DECODE_INSTRUC;
				else
					nstate	=	GET_INSTRUC;
			

			DECODE_INSTRUC:               //judge statement : segment or jump
			 	//wait previous segement generating done
				if(segment_en)begin

					if(desc_gen_last)
						nstate	=	WAIT_GENERATE;
					else nstate = DECODE_INSTRUC;

				end
					
				else if(jump_en)
					nstate	=	JUMP_COMPARE;
				else
					nstate	=	IDLE;
			JUMP_COMPARE:
					nstate	=	GET_INSTRUC;
			default:
					nstate	=	IDLE;
		endcase
	end
always @(posedge clk)
	begin
		if(!rstn)
			begin
				for(i=0;i<7;i=i+1)
				begin
					counter_jump[i] <= 'd0;
				end
					read_en			<= 1'b0;
					read_addr		<= 'd0;
			end
		else begin
			case(cstate[2:0])
				IDLE:
					begin

						for(i=0;i<7;i=i+1)
						begin
							counter_jump[i] <='d0;
						end

						read_en		<= 1'b0;
						read_addr	<= 32'd0;

					end
				GET_1ST_INSTRUC:
					begin
						
						read_addr	<= start_addr;
						read_en 	<= 1'b1;

						if(read_valid)
							read_data_temp	<= read_data;
						else
							read_data_temp	<= read_data_temp;//latch read data

						if(read_data[127:125]==SEGMENT_OPERATION)
							read_valid_temp	<= read_valid;    //if read data[127:125] is 3'b101,then read_valid would assert.
						else
							read_valid_temp <= 1'b0;

					end
				
				WAIT_GENERATE:
					begin

						read_en 	<= 1'b0;
						read_valid_temp <= 1'b0;

						if(generate_done)
							read_addr	<= read_addr + 32'd16;   
						else
							read_addr	<= read_addr;

					end
				GET_INSTRUC:
					begin
						
						read_en 	<= 1'b1;

						if(read_valid)
							read_data_temp	<= read_data;
						else
							read_data_temp	<= read_data_temp;//latch read data
							
					end
				DECODE_INSTRUC:
					begin
						
						if(desc_gen_last)
							read_valid_temp	<= 1'b1;
						else
							read_valid_temp <= 1'b0;

						//when jump instruvtion is read valid, disable read data and deassert read_valid
						//signal which is used by descriptor_generator.v
						read_en 	<= 1'b0;

						if(jump_en)
						begin
							if(counter_num!=0)
							counter_jump[counter_num]<= counter_jump[counter_num] +16'd1;
							else
							counter_jump[counter_num]<= counter_jump[counter_num];
						end
					end
				JUMP_COMPARE:
					begin

						read_en 	<= 1'b0;
						read_valid_temp <= 1'b0;

						// if(counter_jump[counter_num]==jump_times)begin
						// 	read_addr	<= read_addr+32'd16;
						// 	counter_jump[counter_num]<= 16'd0;
						// end
						// else begin
						// 	read_addr	<= jump_addr;
						// end

						if(counter_jump[counter_num]<jump_times)
							read_addr	<= jump_addr;
						else
						
						begin
							read_addr	<= read_addr+32'd16;
							counter_jump[counter_num]<= 16'd0;
						end

					end

			endcase
		end
	end
endmodule
