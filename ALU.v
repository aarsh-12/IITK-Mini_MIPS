module ALU (ALUctrl, data1, data2, out, zero, hi_reg, lo_reg, hi_out, lo_out); 
    input [4:0]ALUctrl; 
    input[31:0] data1, data2, hi_reg, lo_reg;   
    output reg[31:0] out, hi_out, lo_out;     
    output zero;   
    
    always @(*) begin 
        hi_out = hi_reg; 
        lo_out = lo_reg; 
        out = 32'd0;  
        
        case (ALUctrl)  
            5'd0:  out = data1 + data2;                     // ADD/ADDI/LW/SW 
            5'd1:  out = data1 - data2;                     // SUB 
            5'd2:  out = data1 & data2;                     // AND/ANDI 
            5'd3:  out = data1 | data2;                     // OR/ORI 
            5'd4:  out = data1 ^ data2;                     // XOR/XORI 
            5'd5:  out = data2 << data1[4:0];               // SLL/SLLV 
            5'd6:  out = data2 >> data1[4:0];               // SRL/SRLV 
            5'd7:  out = $signed(data2) >>> data1[4:0];     // SRA/SRAV 
            5'd8:  out = ~(data1 | data2);                  // NOR 
            5'd9:  out = ($signed(data1) != $signed(data2)); // BNE 
            5'd10: out = ($signed(data1) == $signed(data2)); // BEQ 
            5'd11: out = ($signed(data1) < $signed(data2));  // SLT 
            5'd12: out = (data1 < data2);                    // SLTU 
            5'd13: out = ($signed(data1) <= $signed(data2)); // BLEZ/BLT 
            5'd14: out = ($signed(data1) > $signed(data2));  // BGTZ 
            5'd15: out = {data2[15:0], 16'b0};               // LUI 
            5'd16: out = ~data1;                             // NOT (custom) 
            5'd17: out = ($signed(data1) >= $signed(data2)); // BGTE (custom) 
            5'd18: out = (data1 > data2);                    // BGTU (custom)  
            5'd19: begin  // MULT 
                {hi_out, lo_out} = $signed(data1) * $signed(data2); 
                out = lo_out; 
            end  
            5'd20: begin  // MADD 
                {hi_out, lo_out} = {hi_reg, lo_reg} + ($signed(data1) * $signed(data2)); 
                out = lo_out; 
            end  
            5'd21: begin  // MADDU 
                {hi_out, lo_out} = {hi_reg, lo_reg} + (data1 * data2); 
                out = lo_out; 
            end  
            default: out = 32'd0;  
        endcase 
    end 
    
    assign zero = (out == 32'd0);  
endmodule
