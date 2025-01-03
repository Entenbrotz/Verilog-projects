module DataMemory (
    input wire clk, // Clock signal for synchronous operation
    input wire MemWrite, // Control signal to enable memory write
    input wire [31:0] ALUResult,  // Address input (calculated by ALU)
    input wire [31:0] WriteData, // Data to be written into memory
    output reg [31:0] readData  // Data read from memory
);

    reg [31:0] memory [0:1023]; // Memory size of 1024 words (4 KB)
    wire [9:0] address = ALUResult[11:2]; // Extracting the address from ALUResult (4-byte word alignment)

    // Synchronous read and write
    always @(posedge clk) begin
        if (MemWrite) begin
            memory[address] <= WriteData; // Write data into memory at specified address
        end
        readData <= memory[address]; // Read data from memory at specified address
    end

endmodule
