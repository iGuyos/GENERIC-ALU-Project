module logic_unit #(parameter WIDTH = 32)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input [2:0] opcode,
    output reg [WIDTH-1:0] out
);
    always @(*) begin
        case(opcode)
            3'b000: out = a&b; // AND
            3'b001: out = a|b; // OR
            3'b010: out = a^b; // XOR
            3'b011: out = ~(a|b); // NOR
            3'b100: out = ~(a&b); // NAND
            3'b101: out = ~(a^b); // XNOR
            3'b110: out = ~a; // NOT a
            default: out = {WIDTH{1'b0}}; // Default case
        endcase
    end
endmodule