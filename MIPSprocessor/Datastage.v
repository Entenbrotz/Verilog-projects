module DataMemory (
    input wire clk,
    input wire MemWrite,
    input wire [31:0] ALUResult,  
    input wire [31:0] WriteData,
    output reg [31:0] readData  
);

    reg [31:0] memory [0:1023]; // Memory size of 1024 words (4 KB)
    wire [9:0] address = ALUResult[11:2]; // Extracting the address from ALUResult (4-byte word alignment)

    // Synchronous read and write
    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address] <= WriteData; // Non-blocking assignment for write
        end
        readData <= memory[address]; // Non-blocking assignment for read
    end

endmodule
