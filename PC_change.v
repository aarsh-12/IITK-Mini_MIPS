module PC_change(clk, rst, done, PC_in, PC_out);
    input rst, clk, done;
    input [31:0] PC_in;
    output reg[31:0] PC_out;
    
    always@(posedge clk or posedge rst) begin
        if(rst) 
            PC_out <= 0;
        else if (!done) 
            PC_out <= PC_in;
        else 
            PC_out <= PC_out;
    end
endmodule
