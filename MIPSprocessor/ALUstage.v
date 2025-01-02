module alumux( B,rd2,immExt,ALUSrc); //B>PC
input [31:0]rd2;
input [31:0] immExt;
input ALUSrc;
output [31:0]B;
assign B = ALUSrc?immExt:rd2;
endmodule


`define R           7'b0110011
`define I           7'b0010011
`define ILoading    7'b0000011
`define S           7'b0100011
`define B           7'b1100011
`define JALInstr    7'b1101111
`define JALRInstr   7'b1100111
`define LUIInstr    7'b0110111
`define AUIPCInstr  7'b0010111

`define ALU_ADD     4'b0000
`define ALU_SUB     4'b0001
`define ALU_SLL     4'b0010
`define ALU_SRL     4'b0011
`define ALU_SRA     4'b0100
`define ALU_AND     4'b0101
`define ALU_OR      4'b0110
`define ALU_XOR     4'b0111
`define ALU_SLT     4'b1000
`define ALU_SLTU    4'b1001
`define ALU_PASS_B  4'b1010
`define ALU_DEFAULT 4'b1111

module ALU(
    output reg zero,                    
    output reg [31:0] ALUResult,        
    input [31:0] a, b,                  
    input [3:0] ALUControl,             
    input [6:0] opcode
);

    reg signed [31:0] signed_a, signed_b;
    reg [31:0] unsigned_a, unsigned_b;

    always @(*) begin
        signed_a = a;
        signed_b = b;
        unsigned_a = a;
        unsigned_b = b;
        zero = 0;
        ALUResult = 0;

        case(ALUControl)
            `ALU_ADD: begin
                case(opcode)
                    `R, `I, `ILoading, `S, `AUIPCInstr: ALUResult = a + b; // ADD operations
                    `JALInstr, `JALRInstr: ALUResult = a + 4;             // Increment PC
                    `LUIInstr: ALUResult = b;                             // LUI operation
                    default: ALUResult = a + b;
                endcase
            end

            `ALU_SUB: begin
                case(opcode)
                    `R: ALUResult = a - b; // SUB operation
                    `B: begin              // Branch operations
                        ALUResult = a - b;
                        zero = (ALUResult == 0);
                    end
                    default: ALUResult = a - b;
                endcase
            end

            `ALU_AND: ALUResult = a & b; // AND operation
            `ALU_OR:  ALUResult = a | b; // OR operation
            `ALU_XOR: ALUResult = a ^ b; // XOR operation

            `ALU_SLL: ALUResult = a << b[4:0]; // SLL operation
            `ALU_SRL: ALUResult = a >> b[4:0]; // SRL operation
            `ALU_SRA: ALUResult = signed_a >>> b[4:0]; // SRA operation

            `ALU_SLT: begin
                case(opcode)
                    `R, `I: ALUResult = (signed_a < signed_b) ? 32'd1 : 32'd0; // SLT operation
                    `B: begin
                        case(ALUControl)
                            `ALU_SLT: ALUResult = (signed_a < signed_b) ? 32'd1 : 32'd0;
                            `ALU_SLTU: ALUResult = (unsigned_a < unsigned_b) ? 32'd1 : 32'd0;
                            default: ALUResult = 32'd0;
                        endcase
                        zero = (ALUResult == 1);
                    end
                    default: ALUResult = (signed_a < signed_b) ? 32'd1 : 32'd0;
                endcase
            end

            `ALU_PASS_B: ALUResult = b; // Pass-through B

            default: ALUResult = 32'd0; // Default case
        endcase
    end
endmodule


module PCtarget(PC,immExt,PCtrg);//B>PC
input [31:0]PC;
input [31:0]immExt;
output [31:0]PCtrg;
assign PCtrg = PC + 4 + immExt;
endmodule

