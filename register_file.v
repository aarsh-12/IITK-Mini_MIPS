module register_file(rs, rt, rd, rs_data, rt_data, rd_data, RegWrite, rst, clk);
    input rst, clk, RegWrite;
    input [4:0]rs, rt, rd;
    output [31:0] rs_data, rt_data;
    input [31:0] rd_data;
    reg [31:0] RF[31:0];
    
    assign rs_data = RF[rs];
    assign rt_data = RF[rt];
    
    integer i;
    always@(posedge clk or posedge rst) begin 
        if(rst) begin
            for(i = 0; i <= 31; i = i+1)
                RF[i] <= 0;
        end
        else if(RegWrite && rd != 0) 
            RF[rd] <= rd_data;
    end
endmodule
