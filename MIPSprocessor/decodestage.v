`define OPCODE_RTYPE    7'b0110011
`define OPCODE_ITYPE    7'b0010011
`define OPCODE_STYPE    7'b0100011
`define OPCODE_LTYPE    7'b0000011
`define OPCODE_BTYPE    7'b1100011
`define OPCODE_UTYPE    7'b0110111
`define OPCODE_UTYPE_AUIPC 7'b0010111
`define OPCODE_JTYPE    7'b1101111
`define OPCODE_JTYPE_JALR 7'b1100111

module InstDecoder(
    input [31:0] instruction,
    output reg [4:0] rd,
    output reg [4:0] rs1,
    output reg [4:0] rs2,
    output reg [6:0] opcode,
    output reg [2:0] funct3,
    output reg [6:0] funct7,
    output reg [31:0] immv  // Sign-extended immediate (32-bits)
);
    
    always @(*) begin
        // Initialize all outputs to 0
        rd = 5'b0;
        rs1 = 5'b0;
        rs2 = 5'b0;
        funct3 = 3'b0;
        funct7 = 7'b0;
        opcode = instruction[6:0];
        immv = 32'b0;  // Initialize immediate to zero

        case (opcode)
            `OPCODE_RTYPE: begin  // R-type
                rd = instruction[11:7];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                funct3 = instruction[14:12];
                funct7 = instruction[31:25];
            end
            
            `OPCODE_ITYPE: begin  // I-type
                rd = instruction[11:7];
                rs1 = instruction[19:15];
                funct3 = instruction[14:12];
                immv = {{20{instruction[31]}}, instruction[31:20]};  // Sign-extend the immediate (I-type)
            end
            
            `OPCODE_STYPE: begin  // S-type
                funct3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                immv = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};  // Sign-extend the immediate (S-type)
            end
            
            `OPCODE_LTYPE: begin  // Load-type instructions
                funct3 = instruction[14:12];          // Extract funct3 (LB, LH, LW, etc.)
                rs1 = instruction[19:15];             // Extract base register (rs1)
                rd = instruction[11:7];               // Extract destination register (rd)
                immv = {{20{instruction[31]}}, instruction[31:20]};  // Sign-extend immediate (12-bit offset)
            end

            `OPCODE_BTYPE: begin  // B-type
                funct3 = instruction[14:12];
                rs1 = instruction[19:15];
                rs2 = instruction[24:20];
                immv = {{19{instruction[31]}}, instruction[7], instruction[30:25], instruction[11:8], 1'b0};  // Sign-extend the immediate (B-type)
            end
            
            `OPCODE_UTYPE, `OPCODE_UTYPE_AUIPC: begin  // U-type (LUI or AUIPC)
                rd = instruction[11:7];               // rd field (destination register)
                immv = {instruction[31:12], 12'b0};    // U-type immediate (bits [31:12])
            end
            
            `OPCODE_JTYPE: begin  // J-type (JAL)
                rd = instruction[11:7];  // Extract the destination register (rd)
                immv = {{12{instruction[31]}}, instruction[19:12], instruction[20], instruction[30:21], 1'b0};  // J-type immediate (bit manipulation)
            end
        
            `OPCODE_JTYPE_JALR: begin  // J-type (JALR)
                rd = instruction[11:7];  // Extract the destination register (rd)
                rs1 = instruction[19:15];  // Extract the source register (rs1)
                immv = {{20{instruction[31]}}, instruction[31:20]};  // JALR immediate (bit manipulation)
            end
            
            default: begin
                // error case (invalid opcode)
                rd = 5'b11111;  // Invalid rd (all 1's to signal error)
                rs1 = 5'b11111; // Invalid rs1
                rs2 = 5'b11111; // Invalid rs2
                funct3 = 3'b111; // Invalid funct3
                funct7 = 7'b1111111; // Invalid funct7
                immv = 32'bx; // Don't care (invalid immediate)
            end
        endcase
    end
endmodule

module ControlUnit(
    input [6:0] opcode,
    input [2:0] funct3,
    input [6:0] funct7,
    input zero,
    output reg PCSrc,
    output reg ResultSrc,
    output reg MemWrite,
    output reg [3:0] ALUControl,
    output reg ALUSrc,
    output reg [2:0] ImmSrc,
    output reg RegWrite
    );

    always @(*) begin
        
        // Default values
        PCSrc = 0;
        ResultSrc = 0;
        MemWrite = 0;
        ALUControl = 4'b0000;
        ALUSrc = 0;
        ImmSrc = 3'b000;
        RegWrite = 0;

        case (opcode)
        
            7'b0110011: begin   // R-Type
                RegWrite = 1;
                ALUSrc = 0;
                ResultSrc = 0;
                ImmSrc = 3'b000;
                case ({funct7, funct3})
                    10'b0000000_000: ALUControl = 4'b0000; // ADD
                    10'b0100000_000: ALUControl = 4'b0001; // SUB
                    10'b0000000_001: ALUControl = 4'b0010; // SLL
                    10'b0000000_101: ALUControl = 4'b0011; // SRL
                    10'b0100000_101: ALUControl = 4'b0100; // SRA
                    10'b0000000_010: ALUControl = 4'b0101; // SLT
                    10'b0000000_011: ALUControl = 4'b0110; // SLTU
                    10'b0000000_100: ALUControl = 4'b0111; // XOR
                    10'b0000000_110: ALUControl = 4'b1000; // OR
                    10'b0000000_111: ALUControl = 4'b1001; // AND
                    default: ALUControl = 4'b1111;         // Undefined or NOP
                endcase
            end

            7'b0010011: begin  // I-Type
                RegWrite = 1;
                ALUSrc = 1;
                ResultSrc = 0;
                case (funct3)
                    3'b000: begin 
                        ALUControl = 4'b0000; // ADDI
                        ImmSrc = 3'b000; // Standard immediate
                    end
                    3'b010: begin 
                        ALUControl = 4'b0011; // SLTI
                        ImmSrc = 3'b000;
                    end
                    3'b100: begin 
                        ALUControl = 4'b0111; // XORI
                        ImmSrc = 3'b000;
                    end
                    3'b110: begin 
                        ALUControl = 4'b0011; // ORI
                        ImmSrc = 3'b000;
                    end
                    3'b111: begin 
                        ALUControl = 4'b0010; // ANDI
                        ImmSrc = 3'b000;
                    end
                    3'b001: begin 
                        ALUControl = 4'b0100; // SLLI
                        ImmSrc = 3'b100; // Shift immediate
                    end
                    3'b101: begin 
                        ALUControl = (funct7 == 7'b0000000) ? 4'b0101 : 4'b0110; // SRLI/SRAI
                        ImmSrc = 3'b100; // Shift immediate
                    end
                    default: begin 
                        ALUControl = 4'b0000;
                        ImmSrc = 3'b000;
                    end
                endcase
            end

            7'b0000011: begin  // L-Type (Load Instructions)
                RegWrite = 1;
                ALUSrc = 1;
                ResultSrc = 1;
                MemWrite = 0;
                ALUControl = 4'b0000; // Addition for address calculation
                ImmSrc = 3'b000;
            end

            7'b0100011: begin  // S-Type
                RegWrite = 0;
                ALUSrc = 1;
                MemWrite = 1;
                ALUControl = 4'b0000; // Addition for address calculation
                ImmSrc = 3'b001;
            end

            7'b1100011: begin  // B-Type
                RegWrite = 0;
                ALUSrc = 0;
                MemWrite = 0;
                ImmSrc = 3'b010; // Branch immediate format

                // Set ALUControl for branch comparison
                case (funct3)
                    3'b000: ALUControl = 4'b0010; // BEQ: Subtraction for equality
                    3'b001: ALUControl = 4'b0010; // BNE: Subtraction for inequality
                    3'b100: ALUControl = 4'b0101; // BLT: Signed comparison
                    3'b101: ALUControl = 4'b0101; // BGE: Signed comparison
                    3'b110: ALUControl = 4'b0110; // BLTU: Unsigned comparison
                    3'b111: ALUControl = 4'b0110; // BGEU: Unsigned comparison
                    default: ALUControl = 4'b0000; // Default to no-op if unrecognized
                endcase

                // Determine PCSrc based on zero flag and branch type
                case (funct3)
                    3'b000: PCSrc = zero;           // BEQ
                    3'b001: PCSrc = !zero;          // BNE
                    3'b100: PCSrc = !zero;          // BLT: Adjust based on ALU output
                    3'b101: PCSrc = zero;           // BGE
                    3'b110: PCSrc = !zero;          // BLTU
                    3'b111: PCSrc = zero;           // BGEU
                    default: PCSrc = 0;             // Default case
                endcase
            end

            7'b1101111: begin // JAL (J-Type)
                RegWrite = 1;
                ALUSrc = 0;
                PCSrc = 1;
                ImmSrc = 3'b011;
            end

            7'b1100111: begin // JALR (J-Type)
                RegWrite = 1;
                ALUSrc = 1;
                PCSrc = 1;
                ImmSrc = 3'b000;
            end

            7'b0110111: begin // LUI (U-Type)
                RegWrite = 1;
                ALUSrc = 1;
                ImmSrc = 3'b100;
            end

            7'b0010111: begin // AUIPC (U-Type)
                RegWrite = 1;
                ALUSrc = 1;
                ImmSrc = 3'b100;
            end

            default: begin
                // Reset unused control signals
                PCSrc = 0;
                ResultSrc = 0;
                MemWrite = 0;
                ALUControl = 4'b0000;
                ALUSrc = 0;
                ImmSrc = 3'b000;
                RegWrite = 0;
            end
        endcase
    end
endmodule

module ImmExtender(
    input [31:0] instruction,         // The 32-bit instruction
    input [2:0] ImmSrc,              // Control signal to specify the immediate type
    output reg [31:0] immExt         // Extended immediate output
);

    always @(*) begin
        case (ImmSrc)
            3'b000: // I-Type (Immediate)
                immExt = {{20{instruction[31]}}, instruction[31:20]}; // Sign-extend bits [31:20] to 32-bits

            3'b001: // S-Type (Store)
                immExt = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // Sign-extend with bits from [31:25] and [11:7]

            3'b010: // B-Type (Branch)
                immExt = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; 
                // Sign-extend and reconstruct the immediate for branch address calculation
                // Immediate format for B-type: imm[12] imm[10:5] imm[4:1] imm[11] imm[0]

            3'b011: // J-Type (Jump)
                immExt = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
                // Sign-extend and reconstruct the immediate for jump address calculation
                // Immediate format for J-type: imm[20] imm[10:1] imm[11] imm[19:12] imm[30:21] imm[0]

            3'b100: // U-Type (LUI/AUIPC)
                immExt = {instruction[31:12], 12'b0}; // Zero-extend the upper 20 bits, set lower 12 to 0
                // Used in LUI (Load Upper Immediate) and AUIPC (Add Upper Immediate to PC)

            3'b101: // Immediate for shifts (optional, zero-extend)
                immExt = {27'b0, instruction[24:20]}; // Zero-extend the shift amount [24:20] into the lower bits

            default: // Default case if ImmSrc is undefined
                immExt = 32'b0;  // Zero-extend if no valid ImmSrc is provided
        endcase
    end
endmodule

module registerfile (
    input clk,                // Clock signal
    input reset,              // Reset signal (active high)
    input [4:0] rs1,          // Read address 1
    input [4:0] rs2,          // Read address 2
    input [4:0] rd,           // Write address
    input [31:0] WD,          // Write data
    input write_enable,       // Write enable signal
    output [31:0] rd1,        // Read data 1
    output [31:0] rd2         // Read data 2
);

reg [31:0] registers [31:0];  // 32 registers, each 32 bits wide
integer k;

// Synchronous logic for reset and write operations
always @(posedge clk) begin
    if (reset == 1'b1) begin
        // Reset all registers to 0
        for (k = 0; k < 32; k = k + 1) begin
            registers[k] <= 32'h0;
        end
    end else if (write_enable == 1'b1) begin
        // Write data to the specified register
        registers[rd] <= WD;
    end
end

// Combinational logic for read operations
assign rd1 = (reset == 1'b0) ? registers[rs1] : 32'h0;
assign rd2 = (reset == 1'b0) ? registers[rs2] : 32'h0;

endmodule
