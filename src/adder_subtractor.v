module adder_subtractor #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a,
    input [WIDTH-1:0] b,
    input carry_in,
    input action, // 0 for addition, 1 for subtraction
    output reg [WIDTH-1:0] result,
    output reg flag_zero, flag_carry_out, flag_overflow, flag_negative
);

    // Using WIDTH to make internal registers generic
    reg [WIDTH:0] temp_result; // WIDTH + 1 bits
    reg [WIDTH-1:0] b_mux; 

    always @(*) begin
        // 1. Prepare B (invert bits if subtraction)
        b_mux = action ? ~b : b; 

        // 2. Perform arithmetic: A + B_modified + Carry_in
        temp_result = a + b_mux + carry_in; 

        // 3. Extract results and update flags
        result = temp_result[WIDTH-1:0];
        
        // Zero Flag: Simplified comparison
        flag_zero = (result == {WIDTH{1'b0}}); 
        
        // Carry Out: The extra bit (bit 32 in a 32-bit setup)
        flag_carry_out = temp_result[WIDTH]; 
        
        // Overflow: Logic is correct - compare sign bits
        flag_overflow = (a[WIDTH-1] == b_mux[WIDTH-1]) && (result[WIDTH-1] != a[WIDTH-1]);
        
        // Negative Flag: Most Significant Bit (MSB)
        flag_negative = result[WIDTH-1]; 
    end
endmodule