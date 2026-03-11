module shifter_unit #(
    parameter WIDTH  = 32,
    parameter S_WIDTH = 5)//Set to 5 for 32 bit, can be adjusted for different widths.
    (
    input [WIDTH-1:0] a,
    input [S_WIDTH-1:0] shift_amount, // 5 bits to represent shift amounts from 0 to 31
    input [1:0] shift_type, // 2 bits to represent shift types (logical left, logical right, arithmetic right)
    output reg [WIDTH-1:0] result
);
    always @(*) begin
        case(shift_type)
            2'b00: result = a << shift_amount; // Logical left shift
            2'b01: result = a >> shift_amount; // Logical right shift
            2'b10: result = $signed(a) >>> shift_amount; // Arithmetic right shift
            default: result = a; // No shift
        endcase  

    end
endmodule