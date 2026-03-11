`timescale 1ns / 1ps

module adder_subtractor_tb(); 
    // 1. Parameter - The core of the generic design
    parameter WIDTH = 32;

    // 2. Signals - Defined based on the WIDTH parameter
    reg [WIDTH-1:0] a_tb, b_tb;
    reg             carry_in_tb, action_tb;
    wire [WIDTH-1:0] result_tb;
    wire            flag_zero_tb, flag_carry_out_tb, flag_overflow_tb, flag_negative_tb;

    // 3. Unit Under Test (UUT) Instance
    // Passing the WIDTH parameter to the instantiated module
    adder_subtractor #(WIDTH) uut (
        .a(a_tb),
        .b(b_tb),
        .carry_in(carry_in_tb),
        .action(action_tb),
        .result(result_tb),
        .flag_zero(flag_zero_tb),
        .flag_carry_out(flag_carry_out_tb),
        .flag_overflow(flag_overflow_tb),
        .flag_negative(flag_negative_tb)
    );

    // 4. Manual Stimulus Block
    initial begin 
        // VCD file generation for GTKWave analysis
        $dumpfile("adder_subtractor_results.vcd");
        $dumpvars(0, adder_subtractor_tb);

        $display("Starting Manual Adder-Subtractor Test (WIDTH = %0d)...", WIDTH);

        // --- Test 1: Simple Addition (10 + 5 = 15) ---
        a_tb = 32'd10; b_tb = 32'd5; action_tb = 0; carry_in_tb = 0;
        #10; 

        // --- Test 2: Simple Subtraction (10 - 5 = 5) ---
        // Note: For subtraction, action=1 and carry_in=1 to complete 2's complement logic
        a_tb = 32'd10; b_tb = 32'd5; action_tb = 1; carry_in_tb = 1;
        #10;

        // --- Test 3: Negative Flag Check (5 - 10 = -5) ---
        a_tb = 32'd5; b_tb = 32'd10; action_tb = 1; carry_in_tb = 1;
        #10; 

        // --- Test 4: Zero Flag Check (100 - 100 = 0) ---
        a_tb = 32'd100; b_tb = 32'd100; action_tb = 1; carry_in_tb = 1;
        #10;

        // --- Test 5: Signed Overflow Check (Positive + Positive = Negative) ---
        // Max positive signed value (e.g., 0111...111)
        a_tb = {1'b0, {(WIDTH-1){1'b1}}}; // Generates 0111...111
        b_tb = 1; action_tb = 0; carry_in_tb = 0;
        #10; 

        // --- Test 6: Carry Out Check (All Ones + 1 = 0 with Carry) ---
        a_tb = {WIDTH{1'b1}}; // Generates 111...111
        b_tb = 1; action_tb = 0; carry_in_tb = 0;
        #10; 

        $display("Adder-Subtractor simulation finished!");
        $finish;
    end

endmodule