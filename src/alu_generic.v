module alu_generic #(
    parameter WIDTH = 32
)(
    input [WIDTH-1:0] a, b,
    input [4:0]       alu_control,
    output reg [WIDTH-1:0] result,
    output flag_zero, flag_carry_out, flag_overflow, flag_negative
);

    // 1. Dynamic calculation for shift bits
    localparam S_WIDTH = $clog2(WIDTH); 

    // 2. Internal wires for sub-module results and adder flags
    wire [WIDTH-1:0] logic_res, adder_res, shifter_res;
    wire adder_c, adder_v; // Internal wires for arithmetic-specific flags

    // 3. Logic Unit Instance
    logic_unit #(WIDTH) logic_inst (
        .a(a), .b(b), .opcode(alu_control[2:0]), .out(logic_res)
    );

    // 4. Adder/Subtractor Instance
    // Note: We only take Carry and Overflow from here
    adder_subtractor #(WIDTH) adder_inst (
        .a(a), .b(b), .action(alu_control[2]), .carry_in(alu_control[2]),
        .result(adder_res), 
        .flag_carry_out(adder_c), 
        .flag_overflow(adder_v)
        // Zero and Negative are calculated at the top level
    );

    // 5. Shifter Unit Instance
    shifter_unit #(
        .WIDTH(WIDTH), 
        .S_WIDTH(S_WIDTH)
    ) shifter_inst (
        .a(a), 
        .shift_amount(b[S_WIDTH-1:0]), 
        .shift_type(alu_control[1:0]), 
        .result(shifter_res)
    );

    // 6. Main Output MUX
    always @(*) begin
        case (alu_control[4:3])
            2'b00: result = logic_res;   // Logic Mode
            2'b01: result = adder_res;   // Arithmetic Mode
            2'b10: result = shifter_res; // Shift Mode
            default: result = {WIDTH{1'b0}};
        endcase
    end

    // 7. Final Flag Logic (Universal)
    // Zero Flag: True if the FINAL multiplexed result is zero
    // Equation: $$flag\_zero = (result == 0)$$
    assign flag_zero     = (result == {WIDTH{1'b0}});

    // Negative Flag: True if the MSB of the FINAL result is 1
    // Equation: $$flag\_negative = result[WIDTH-1]$$
    assign flag_negative = result[WIDTH-1];

    // Carry and Overflow: Only active during Arithmetic mode (2'b01)
    assign flag_carry_out = (alu_control[4:3] == 2'b01) ? adder_c : 1'b0;
    assign flag_overflow  = (alu_control[4:3] == 2'b01) ? adder_v : 1'b0;

    always @(result) begin
        #2; // Wait for combinational logic to settle

        // 1. Generic Zero Flag Check
        // Equation: $flag\_zero = 1 \iff result = 0$
        assert(flag_zero == (result == {WIDTH{1'b0}})) 
        else $error("[ALU %0d-bit] Z-Flag Error! Result=%h", WIDTH, result);

        // 2. Generic Negative Flag Check
        // Checks the MSB regardless of the current WIDTH
        assert(flag_negative == result[WIDTH-1]) 
        else $error("[ALU %0d-bit] N-Flag Error!", WIDTH);

        // 3. Generic Arithmetic Check (Addition/Subtraction)
        if (alu_control[4:3] == 2'b01) begin
            if (alu_control[2] == 0) // ADD mode
                assert(result == a + b) else $error("[ALU %0d-bit] Add Math Error", WIDTH);
            else // SUB mode
                assert(result == a - b) else $error("[ALU %0d-bit] Sub Math Error", WIDTH);
        end
    end

endmodule