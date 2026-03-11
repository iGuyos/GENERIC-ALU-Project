`timescale 1ns / 1ps

module shifter_unit_tb();
    // 1. Parameters - Control the width from here
    parameter WIDTH = 32;
    localparam S_WIDTH = $clog2(WIDTH);

    // 2. Signals
    reg [WIDTH-1:0] a_tb;
    reg [S_WIDTH-1:0] shift_amount_tb;
    reg [1:0] shift_type_tb;
    wire [WIDTH-1:0] result_tb;

    // 3. Unit Under Test (UUT) Instance
    shifter_unit #(
        .WIDTH(WIDTH),
        .S_WIDTH(S_WIDTH)
    ) uut (
        .a(a_tb),
        .shift_amount(shift_amount_tb),
        .shift_type(shift_type_tb),
        .result(result_tb)
    );

    // 4. Manual Stimulus Block
    initial begin
        // Setup for GTKWave
        $dumpfile("shifter_results.vcd");
        $dumpvars(0, shifter_unit_tb);

        $display("Starting Manual Shifter Test (WIDTH = %0d)...", WIDTH);

        // --- Initialize ---
        a_tb = 0; shift_amount_tb = 0; shift_type_tb = 0;
        #10;

        // Test 1: Logical Left Shift (SLL)
        // Example: 15 (8'h0F) << 2 = 60 (8'h3C)
        a_tb = 32'd15; shift_amount_tb = 5'd2; shift_type_tb = 2'b00;
        #10;

        // Test 2: Logical Right Shift (SRL)
        // Example: 16 (8'h10) >> 2 = 4 (8'h04)
        a_tb = 32'd16; shift_amount_tb = 5'd2; shift_type_tb = 2'b01;
        #10;

        // Test 3: Arithmetic Right Shift (SRA) - Critical Test
        // Loading a negative number (MSB = 1) to see sign extension
        a_tb = {1'b1, {(WIDTH-1){1'b0}}}; // Example: 0x80000000
        shift_amount_tb = 5'd4; shift_type_tb = 2'b10;
        #10;

        // Test 4: Maximum Shift
        // Shifting by WIDTH-1
        a_tb = {WIDTH{1'b1}}; 
        shift_amount_tb = 31; 
        shift_type_tb = 2'b01; // SRL
        #10;

        // Test 5: No Shift
        a_tb = 32'hDEADBEEF; shift_amount_tb = 5'd0; shift_type_tb = 2'b00;
        #10;

        $display("Shifter Unit manual simulation finished!");
        $finish;
    end
endmodule