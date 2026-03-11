`timescale 1ns / 1ps

module alu_dual_system_tb();

    // --- Signals for 32-bit ALU ---
    reg [31:0] a32, b32;
    wire [31:0] res32;
    wire z32, c32, v32, n32;

    // --- Signals for 8-bit ALU ---
    reg [7:0] a8, b8;
    wire [7:0] res8;
    wire z8, c8, v8, n8;

    reg [4:0] control;

    // Instantiate 32-bit ALU
    alu_generic #(.WIDTH(32)) uut32 (
        .a(a32), .b(b32), .alu_control(control),
        .result(res32), .flag_zero(z32), .flag_carry_out(c32), 
        .flag_overflow(v32), .flag_negative(n32)
    );

    // Instantiate 8-bit ALU
    alu_generic #(.WIDTH(8)) uut8 (
        .a(a8), .b(b8), .alu_control(control),
        .result(res8), .flag_zero(z8), .flag_carry_out(c8), 
        .flag_overflow(v8), .flag_negative(n8)
    );

    
    task check_all;
        input [31:0] exp_res;
        input exp_z, exp_c, exp_v, exp_n;
        input is_32bit; // 1 for checking 32-bit ALU, 0 for 8-bit
        input [511:0] msg;
        
        // Internal variables to hold the current values we are checking
        reg [31:0] current_res;
        reg current_z, current_c, current_v, current_n;
        
        begin
            #1; // Delay to allow combinational logic to propagate!
            
            // Pick which ALU we are currently verifying
            if (is_32bit) begin
                current_res = res32; current_z = z32; current_c = c32; 
                current_v = v32; current_n = n32;
            end else begin
                current_res = {24'b0, res8}; current_z = z8; current_c = c8; 
                current_v = v8; current_n = n8;
            end

            if (current_res !== exp_res || current_z !== exp_z || 
                current_c !== exp_c || current_v !== exp_v || current_n !== exp_n) begin
                $display("--- FAIL: %0s ---", msg);
                $display("  Result   | Exp: %h, Got: %h", exp_res, current_res);
                $display("  Flags    | Exp: {Z:%b C:%b V:%b N:%b}, Got: {Z:%b C:%b V:%b N:%b}", 
                          exp_z, exp_c, exp_v, exp_n, current_z, current_c, current_v, current_n);
            end else begin
                $display("PASS: %0s | Res: %h | Flags: {Z:%b C:%b V:%b N:%b}", 
                          msg, current_res, current_z, current_c, current_v, current_n);
            end
        end
    endtask

initial begin
        $dumpfile("alu_dual_results.vcd");
        $dumpvars(0, alu_dual_system_tb);

        $display("--- Starting Comprehensive Dual-Width Verification ---");

        // --- ARITHMETIC TESTS ---

        // 1. Simple Addition: 100 + 50 (32-bit) and 10 + 5 (8-bit)
        control = 5'b01000; // ADD operation
        a32 = 32'd100; b32 = 32'd50;
        a8  = 8'd10;   b8  = 8'd5;
        // Calls now use 7 arguments: (exp_res, Z, C, V, N, is_32bit, msg)
        check_all(32'd150, 1'b0, 1'b0, 1'b0, 1'b0, 1, "32-bit Simple Add");
        check_all(32'd15,  1'b0, 1'b0, 1'b0, 1'b0, 0, "8-bit Simple Add");

        // 2. Zero Flag Test (Subtraction): 500 - 500
        control = 5'b01100; // SUB operation
        a32 = 32'd500; b32 = 32'd500;
        a8  = 8'd20;   b8  = 8'd20;
        check_all(32'd0, 1'b1, 1'b1, 1'b0, 1'b0, 1, "32-bit Zero Result");
        check_all(32'd0, 1'b1, 1'b1, 1'b0, 1'b0, 0, "8-bit Zero Result");

        // 3. Signed Overflow Test: 120 + 10 in 8-bit (Result > 127)
        control = 5'b01000; // ADD
        a8 = 8'd120; b8 = 8'd10; 
        // 120+10 = 130 (signed 8-bit wraps to -126 / 0x82)
        check_all(32'h82, 1'b0, 1'b0, 1'b1, 1'b1, 0, "8-bit Signed Overflow");

        // --- LOGIC TESTS ---

        // 4. NOR Operation
        control = 5'b00011; // NOR
        a32 = 32'hFFFF_0000; b32 = 32'h0000_FFFF;
        check_all(32'h0, 1'b1, 1'b0, 1'b0, 1'b0, 1, "32-bit Logic NOR Zero");

        // --- SHIFTER TESTS ---

        // 5. Arithmetic Right Shift (Sign Extension)
        control = 5'b10010; // SRA
        a8 = 8'b1000_0000; b8 = 8'd2; // -128 >> 2 = -32 (0xE0)
        check_all(32'hE0, 1'b0, 1'b0, 1'b0, 1'b1, 0, "8-bit SRA Negative");

        $display("--- All Dual-Width Tests Completed ---");
        $finish;
    end
endmodule