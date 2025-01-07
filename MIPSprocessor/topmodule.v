module MIPS_TOP(
input clk,
input reset,
output [31:0]Result
);

wire [31:0] instruction_address;
wire [31:0] instruction;
wire [4:0] rd;
wire [4:0] rs1;
wire [4:0] rs2;
wire [6:0] opcode;
wire [2:0] funct3;
wire [6:0] funct7;
wire [31:0] immv;
wire [31:0]PC_next;
wire zero;
wire PCSrc;
wire ResultSrc;
wire MemWrite;
wire [3:0] ALUControl;
wire  ALUSrc;
wire [2:0] ImmSrc;
wire RegWrite;
wire [31:0]immExt;
wire [31:0]rd1;
wire [31:0]rd2;
wire [31:0]B;
wire [31:0]PCtrg;
wire [31:0]PC4;
wire [31:0]ALUResult;
wire [31:0]readData;


Prgm_counter(
.clk(clk),
.reset(reset),
.PC_next(PC_next),
.PC(instruction_address)
);

instructionmem(
.clk(clk),
.reset(reset),
.PC(instruction_address),
.instruction_out(instruction)
);

InstDecoder(
    .instruction(instruction),
    .rd(rd),
    .rs1(rs1),
    .rs2(rs2),
    .opcode(opcode),
    .funct3(funct3),
    .funct7(funct7),
    .immv(immv)  // Sign-extended immediate (32-bits)
    );
    
 ControlUnit(
      .opcode(opcode),
     .funct3(funct3),
      .funct7(funct7),
     .zero(zero),
    .PCSrc(PCSrc),
     .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
     .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
     .ImmSrc(ImmSrc),
    .RegWrite(RegWrite)
    );
  ImmExtender(
    .instruction(immv),         // The 32-bit instruction
    .ImmSrc(ImmSrc),              // Control signal to specify the immediate type
    .immExt(immExt)         // Extended immediate output
);

registerfile (
    .clk(clk),                // Clock signal
    .reset(reset),              // Reset signal (active high)
    .rs1(rs1),          // Read address 1
    .rs2(rs2),          // Read address 2
    .rd(rd),           // Write address
    .WD(Result),          // Write data
    .write_enable(RegWrite),       // Write enable signal
    .rd1(rd1),        // Read data 1
    .rd2(rd2)         // Read data 2
);
alumux(
.rd2(rd2),
.immExt(immExt),
.ALUSrc(ALUSrc),
.B(B)
);
 PCtarget(
 .PC(instruction_address),
 .immExt(immExt),
 .PCtrg(PCtrg));
 
 PCplus4(
    .PC(instruction_address),
    .const4(32'd4),
    .PC4(PC4)
    );
    
  PCmux(
  .PC4(PC4),
  .PCSrc(PCSrc),
  .PC_next(PC_next),
  .PCtrg(PCtrg)
);

 ALU(
    .zero(zero),                    
    .ALUResult(ALUResult),        
    .a(rd1),
    .b(B),                  
    .ALUControl(ALUControl),             
    .opcode(opcode)
);

 DataMemory (
    .clk(clk),
    .MemWrite(MemWrite),
    .ALUResult(ALUResult),  
    .WriteData(rd2),
    .readData(readData)  
);

MUX(
    .ALUResult(ALUResult), 
    .readData(readData),
    .ResultSrc(ResultSrc),
    .Result(Result)
    );
    

endmodule
