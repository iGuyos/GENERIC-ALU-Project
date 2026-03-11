// 1. Timescale definition
`timescale 1ns / 1ps

module logic_unit_tb();
    // 2. Define parameters for opcodes (for readability)
    parameter OP_AND  = 3'b000;
    parameter OP_OR   = 3'b001;
    parameter OP_XOR  = 3'b010;
    parameter OP_NOR  = 3'b011;
    parameter OP_NAND = 3'b100;
    parameter OP_XNOR = 3'b101;
    parameter OP_NOT  = 3'b110;

    // 4. Declare signals to connect to the Unit Under Test (UUT)
    reg [31:0] a_tb;
    reg [31:0] b_tb;
    reg [2:0]  opcode_tb;

    wire [31:0] out_tb;

    // 5. Instantiate the Unit Under Test (UUT)
    logic_unit uut (
        .a(a_tb),               // Connect DUT port 'a' to TB signal 'a_tb'
        .b(b_tb),               // Connect DUT port 'b' to TB signal 'b_tb'
        .opcode(opcode_tb),     // Connect DUT port 'opcode' to TB signal 'opcode_tb'
        .out(out_tb)            // Connect DUT port 'out' to TB signal 'out_tb'
    );

    initial begin
        // --- VCD Waveform Dumping setup ---
        // $dumpfile creates the VCD (Value Change Dump) file containing simulation data.
        $dumpfile("logic_unit_results.vcd"); 
        // $dumpvars tells the simulator which variables to record. (0 means all variables in this scope)
        $dumpvars(0, logic_unit_tb);

        // --- Initialize all inputs at time 0 ---
        a_tb = 32'b0;
        b_tb = 32'b0;
        opcode_tb = 3'b0;
        // Wait 10 ns to establish a clean starting point.
        #10; 
        
        // ==========================================
        // Test Case 1: Bitwise AND (Opcode 000)
        // ==========================================
        // Test logic: 0xA (1010) AND 0x5 (0101) = 0x0
        a_tb      = 32'hAAAAAAAA; // Alternating pattern 1010...
        b_tb      = 32'h55555555; // Alternating pattern 0101...
        opcode_tb = OP_AND;
        // The delay #10 is crucial; it allows the logical gates time to compute.
        #10; 
        
        // ==========================================
        // Test Case 2: Bitwise OR (Opcode 001)
        // ==========================================
        opcode_tb = OP_OR; 
        #10;

        // ==========================================
        // Test Case 3: Bitwise XOR (Opcode 010)
        // ========================================== 
        a_tb      = 32'h12345678;
        b_tb      = 32'h12345678; // Same number
        opcode_tb = OP_XOR;
        #10;

        // ==========================================
        // Test Case 4: Bitwise NOR (Opcode 011)
        // ==========================================
        a_tb      = 32'h0;
        b_tb      = 32'h0;
        opcode_tb = OP_NOR;
        #10;

        // ==========================================
        // Test Case 5: Bitwise NAND (Opcode 100)
        // ==========================================
        a_tb      = 32'hFFFFFFFF;
        b_tb      = 32'hFFFFFFFF;
        opcode_tb = OP_NAND;
        #10;

        // ==========================================
        // Test Case 6: Bitwise NOT A (Opcode 110)
        // ==========================================
        a_tb      = 32'hFFFFFFFF;
        b_tb      = 32'h11111111; // Value is ignored
        opcode_tb = OP_NOT;
        #10;

        // --- Simulation Finish ---
        // Add a small final delay.
        #20;
        $display("Simulation for logic_unit finished!");
        $finish; 
    end

endmodule