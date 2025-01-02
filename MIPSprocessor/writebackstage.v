module MUX(ALUResult, readData, ResultSrc, Result);
    input [31:0]ALUResult, readData;
    input ResultSrc;
    output [31:0]Result;

    assign Result = (ResultSrc) ? readData : ALUResult;
endmodule
