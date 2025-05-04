module Control(
    input  wire [5:0] opcode,    // instruction[31:26]
    input  wire [5:0] func,      // instruction[5:0]
    output reg  [1:0] RegDsT,    // 00 = rt, 01 = rd, 10 = $31 (for jal)
    output reg  [4:0] ALUctrl,   // ALU operation code
    output reg        branch,    // 1 = conditional branch (beq/bne)
    output reg        MemtoReg,  // 1 = write back from data memory
    output reg        MemWrite,  // 1 = write to data memory
    output reg  [1:0] ALUSrc,    // 00 = reg, 01 = imm, 10 = shamt (for shifts)
    output reg        RegWrite,  // 1 = write to register file
    output reg        jump,      // 1 = unconditional jump (j, jal, jr)
    output reg        done       // 1 = halt (we use 0xFFFFFFFF sentinel)
);

    always @(*) begin
        // 1) Default all controls low/zero
        RegDsT   = 2'b00;
        ALUctrl  = 5'd0;
        branch   = 1'b0;
        MemtoReg = 1'b0;
        MemWrite = 1'b0;
        ALUSrc   = 2'b00;
        RegWrite = 1'b0;
        jump     = 1'b0;
        done     = 1'b0;

    
        if (opcode == 6'h3F && func == 6'h3F) begin
            done = 1'b1;
        end
        else begin
            case (opcode)
                // -----------------------------------
                // R-type (opcode == 0)
                // -----------------------------------
                6'h00: begin
                    ALUSrc   = 2'b00;   // both operands from regs
                    MemtoReg = 1'b0;
                    MemWrite = 1'b0;
                    RegWrite = 1'b1;    // write back to GPR
                    RegDsT   = 2'b01;   // write into rd

                    case (func)
                        6'h20, 6'h21: ALUctrl = 5'd0;   // add/addu
                        6'h22, 6'h23: ALUctrl = 5'd1;   // sub/subu
                        6'h24:       ALUctrl = 5'd2;   // and
                        6'h25:       ALUctrl = 5'd3;   // or
                        6'h26:       ALUctrl = 5'd4;   // xor
                        6'h27:       ALUctrl = 5'd8;   // nor
                        6'h00:       begin ALUctrl = 5'd5; ALUSrc = 2'b10; end // sll
                        6'h04:       begin ALUctrl = 5'd5; ALUSrc = 2'b00; end // sllv
                        6'h02:       begin ALUctrl = 5'd6; ALUSrc = 2'b10; end // srl
                        6'h06:       begin ALUctrl = 5'd6; ALUSrc = 2'b00; end // srlv
                        6'h03:       begin ALUctrl = 5'd7; ALUSrc = 2'b10; end // sra
                        6'h07:       begin ALUctrl = 5'd7; ALUSrc = 2'b00; end // srav
                        6'h2A:       ALUctrl = 5'd11;  // slt
                        6'h2B:       ALUctrl = 5'd12;  // sltu
                        6'h18:       ALUctrl = 5'd19;  // mult
                        // you can add func→ctrl mappings for madd/maddu here
                        6'h08: begin                   // jr
                            jump     = 1'b1;
                            RegWrite = 1'b0;           // jr does not write GPR
                        end
                        default:    ALUctrl = 5'd0;
                    endcase
                end

                // -----------------------------------
                // I-type ALU immediates
                // -----------------------------------
                6'h08, 6'h09: begin   // addi / addiu
                    ALUSrc   = 2'b01;
                    ALUctrl  = 5'd0;
                    RegWrite = 1'b1;
                    RegDsT   = 2'b00;  // write into rt
                end
                6'h0C: begin  // andi
                    ALUSrc   = 2'b01;
                    ALUctrl  = 5'd2;
                    RegWrite = 1'b1;
                    RegDsT   = 2'b00;
                end
                6'h0D: begin  // ori
                    ALUSrc   = 2'b01;
                    ALUctrl  = 5'd3;
                    RegWrite = 1'b1;
                    RegDsT   = 2'b00;
                end
                6'h0E: begin  // xori
                    ALUSrc   = 2'b01;
                    ALUctrl  = 5'd4;
                    RegWrite = 1'b1;
                    RegDsT   = 2'b00;
                end
                6'h0A: begin  // slti
                    ALUSrc   = 2'b01;
                    ALUctrl  = 5'd11;
                    RegWrite = 1'b1;
                    RegDsT   = 2'b00;
                end
                6'h0B: begin  // sltiu
                    ALUSrc   = 2'b01;
                    ALUctrl  = 5'd12;
                    RegWrite = 1'b1;
                    RegDsT   = 2'b00;
                end
                6'h0F: begin  // lui
                    ALUSrc   = 2'b01;   // immediate is in2
                    ALUctrl  = 5'd15;
                    RegWrite = 1'b1;
                    RegDsT   = 2'b00;
                end

                // -----------------------------------
                // Memory
                // -----------------------------------
                6'h23: begin  // lw
                    ALUSrc   = 2'b01;
                    ALUctrl  = 5'd0;    // add base + offset
                    RegWrite = 1'b1;
                    MemtoReg = 1'b1;
                    RegDsT   = 2'b00;
                end
                6'h2B: begin  // sw
                    ALUSrc   = 2'b01;
                    ALUctrl  = 5'd0;
                    MemWrite = 1'b1;
                end

                // -----------------------------------
                // Branches
                // -----------------------------------
                6'h04: begin  // beq
                    branch  = 1'b1;
                    ALUSrc  = 2'b00;
                    ALUctrl = 5'd10;   // compare for equality
                end
                6'h05: begin  // bne
                    branch  = 1'b1;
                    ALUSrc  = 2'b00;
                    ALUctrl = 5'd9;    // compare for inequality
                end

                // -----------------------------------
                // J-type
                // -----------------------------------
                6'h02, 6'h03: begin  // j / jal
                    jump     = 1'b1;
                    RegWrite = (opcode == 6'h03);  // jal writes return addr
                    RegDsT   = (opcode == 6'h03) ? 2'b10 : 2'b00;  // write into $31 for jal
                end
                default: ;
            endcase
        end
    end

endmodule
