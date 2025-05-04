module main_CPU(we_data, we_ins, add_ins, add_data, input_ins, input_data, clk, rst, out_cpu, done);

input clk, rst, we_data, we_ins;
input[31:0] input_data, input_ins;
input [9:0] add_ins, add_data;
output[31:0] out_cpu;
output done;

reg [31:0] PC_in;
wire [31:0] PC_out;
wire[31:0] data_write, instruction;
reg [9:0] data_write_addr; 
reg [9:0] data_read_addr;
wire enable_data;
wire [4:0]ALUctrl;
wire [1:0] ALUSrc;
wire jump, branch, MemtoReg, MemWrite, done, RegWrite;
wire [1:0] RegDsT;
wire [5:0] opcode, func;
wire [25:0] jump_add;
wire [31:0] imm_val;
wire [4:0] rs, rt;
reg [4:0] rd;
wire [31:0] shamt;
wire [31:0] WB_data;
wire [31:0] branch_addr;
wire [31:0] temp_addr;
reg [31:0] jump_addr; 
wire [31:0] rs_data, rt_data; 
wire [31:0] data1, data_res;
reg [31:0] hi_reg, lo_reg;
wire hi_lo_write;
wire [31:0] hi_out, lo_out;
reg[31:0] data2;
wire zero;
wire branch_taken;

// Instruction memory
dist_mem_gen_0 inst_mem (
    .a(add_ins),        
    .d(input_ins),        
    .dpra(PC_out[9:0]),  
    .clk(clk),    
    .we(we_ins),      
    .dpo(instruction)    
);

// Data memory
dist_mem_gen_0 data_mem (
    .a(data_write_addr),        
    .d(data_write),        
    .dpra(data_read_addr),  
    .clk(clk),    
    .we(enable_data),      
    .dpo(out_cpu)    
);

PC_change pc(clk, rst, done, PC_in, PC_out);
Control controller(opcode, func, RegDsT, ALUctrl, branch, MemtoReg, MemWrite, ALUSrc, RegWrite, jump, done);
ALU alu(ALUctrl, data1, data2, data_res, zero, hi_reg, lo_reg, hi_out, lo_out);
register_file RF(rs, rt, rd, rs_data, rt_data, WB_data, RegWrite, rst, clk); 

assign opcode = instruction[31:26];
assign jump_add = instruction[25:0];
assign imm_val = {{16{instruction[15]}}, instruction[15:0]};
assign func = instruction[5:0];
assign rs = instruction[25:21];
assign rt = instruction[20:16];
assign shamt = {27'd0, instruction[10:6]};
assign temp_addr = PC_out + 1;
assign data1 = rs_data;
assign data_write = (rst == 1) ? input_data : rt_data;
// Only enable data writes when not in reset or when explicitly requested during reset
assign enable_data = (rst == 1) ? we_data : MemWrite;
assign WB_data = (MemtoReg) ? out_cpu : ((RegDsT == 2'd2) ? (PC_out + 1) : data_res);
assign branch_addr = PC_out + 1 + imm_val;
assign hi_lo_write = (ALUctrl == 5'd19) || (ALUctrl == 5'd20) || (ALUctrl == 5'd21);
// Branch condition based on ALU control
assign branch_taken = (ALUctrl == 5'd10) ? zero : // BEQ: branch if equal (zero=1)
                      (ALUctrl == 5'd9) ? !zero : // BNE: branch if not equal (zero=0)
                      1'b0;              // Default: no branch

always@(*) begin
    if(RegDsT == 2'd2)
        rd <= 5'd31;  // $ra for JAL
    else if(RegDsT == 2'd1)
        rd <= instruction[15:11];  // rd field for R-type
    else
        rd <= instruction[20:16];  // rt field for I-type
end 

always @(*) begin
    if(ALUSrc == 2'h2)
        data2 <= shamt;  // For shift instructions
    else if (ALUSrc == 2'h1)
        data2 <= imm_val;  // For immediate instructions
    else
        data2 <= rt_data;  // For register-register operations
end

always@(*) begin
    if(done)
        data_read_addr <= add_data;
    else 
        data_read_addr <= data_res[9:0];
end

always@(*) begin
    if(rst)
        data_write_addr <= add_data;
    else 
        data_write_addr <= data_res[9:0];
end

always@(*) begin
    if(opcode == 0 && func == 6'd8)  // JR instruction
        jump_addr <= rs_data;  // Jump to address in rs
    else
        jump_addr <= {temp_addr[31:26], jump_add};  // J/JAL instructions
end

always@(*) begin
    if(branch == 1 && branch_taken)  // Only take branch if branch signal is set and condition is met
        PC_in <= branch_addr;
    else if(jump == 1)
        PC_in <= jump_addr;
    else
        PC_in <= PC_out + 1;
end

always@(posedge clk or posedge rst) begin
    if (rst) begin
        hi_reg <= 32'd0;
        lo_reg <= 32'd0;
    end 
    else if (hi_lo_write) begin
        hi_reg <= hi_out;
        lo_reg <= lo_out;
    end
end

endmodule

