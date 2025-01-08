module Prgm_counter(
    input clk,
    input reset,
    input [31:0] PC_next,
    output reg [31:0] PC
);
    // Initialize PC to 0
    initial begin
        PC = 32'b0;
    end

    // Synchronous process triggered on the rising edge of clk
    always @(posedge clk) begin
        if (reset) 
            PC <= 32'b0;  // Reset to all zeros
        else
            PC <= PC_next; 
    end
endmodule

module instructionmem(clk, reset, PC, instruction_out);
  input clk, reset;
  input [31:0] PC;
  output [31:0] instruction_out;
 
  reg [31:0] memory [63:0]; // 64 words, each 32-bit wide
  integer k;

  assign instruction_out = memory[PC >> 2]; // Fetch instruction

  always @(posedge clk) begin
    if (reset == 1'b1) begin
      for (k = 0; k < 64; k = k + 1)
        memory[k] = 32'b0; // Correct indexing
    end
  end
endmodule

module PCplus4(
    input [31:0] PC,
    input [31:0] const4,
    output [31:0] PC4
    );
    assign PC4 = PC+const4;
endmodule

module PCmux(PC4,PCSrc,PC_next,PCtrg);//A>PC+4,c>PCnext
input PCSrc;
input [31:0]PC4;
input [31:0]PCtrg;
output [31:0]PC_next;
assign PC_next=PCSrc?PCtrg:PC4;
endmodule


