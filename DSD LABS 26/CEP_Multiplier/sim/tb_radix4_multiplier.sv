// =======================================================================
// Module Name: tb_radix4_multiplier
// Description: Self-Checking Testbench for Parameterized Radix-4 Multiplier
// Phase 4 Deliverable - Verification and Cycle-Count Analysis
// =======================================================================
`timescale 1ns/1ps

module tb_radix4_multiplier();

    // 1. Parameters & Interface Signals
    parameter N = 6; // Matching the N=6 configuration from the manual trace
    
    logic                 clk;
    logic                 rst_n;
    logic                 start;
    logic signed [N-1:0]  X;
    logic signed [N-1:0]  Y;
    logic signed [2*N-1:0] P;
    logic                 done;
    logic [1:0]           state_led;

    // 2. Instantiate the Unit Under Test (UUT)
    radix4_multiplier #(.N(N)) uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .X(X),
        .Y(Y),
        .P(P),
        .done(done),
        .state_led(state_led)
    );

    // 3. Clock Generation (50 MHz Simulation Clock -> 20ns Period)
    always #10 clk = ~clk;

    // Internal tracking variables for verification
    int cycle_count;
    logic signed [2*N-1:0] expected_product;

    // 4. Automated Verification Task
    task automatic run_multiplier_test(
        input logic signed [N-1:0] test_X, 
        input logic signed [N-1:0] test_Y
    );
        begin
            // Calculate the expected golden result
            expected_product = test_X * test_Y;

            // Apply inputs on a clean clock edge
            @(posedge clk);
            X = test_X;
            Y = test_Y;
            start = 1'b1;
            
            @(posedge clk);
            start = 1'b0; // De-assert start immediately (Pulse)

            // Reset and track the execution cycle duration
            cycle_count = 0;

            // Count the exact number of clock cycles spent in computation
            while (!done) begin
                @(posedge clk);
                if (uut.current_state == uut.ST_CALC) begin
                    cycle_count = cycle_count + 1;
                end
            end

            // Assert verification results
            $display("----------------------------------------------------------------");
            $display("[TEST EVALUATION] Multiplier(X) = %d | Multiplicand(Y) = %d", test_X, test_Y);
            $display("Hardware Output P = %d | Golden Reference = %d", P, expected_product);
            $display("Cycles Spent in ST_CALC State = %d (Required N/2 = %d)", cycle_count, (N/2));
            
            // Core Requirement Check 1: Mathematical Accuracy
            if (P === expected_product) begin
                $display(">>> ACCURACY CHECK: PASSED");
            end else begin
                $display(">>> ACCURACY CHECK: FAILED! **ERROR**");
            end

            // Core Requirement Check 2: Dynamic Execution Speed Constraint
            if (cycle_count === (N/2)) begin
                $display(">>> TIMING CONSTRAINT (N/2 Cycles): PASSED");
            end else begin
                $display(">>> TIMING CONSTRAINT (N/2 Cycles): FAILED! **ERROR**");
            end
            
            @(posedge clk);
        end
    endtask

    // 5. Main Simulation Stimulus Execution Block
    initial begin
        // Initialize Inputs
        clk   = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        X     = '0;
        Y     = '0;

        // Apply System Reset
        #40;
        rst_n = 1'b1;
        #20;

        $display("====================================================================");
        $display("     STARTING PHASE 4: RADIX-4 BOOTH MULTIPLIER VERIFICATION       ");
        $display("====================================================================");

        // --- DIRECTED TEST CASES ---
        
        // Test 1: Your Exact Configuration (Positive Multiplier X = 13, Negative Multiplicand Y = -3)
        run_multiplier_test(6'd13, -6'd3);

        // Test 2: Negative Multiplier, Positive Multiplicand (X = -3, Y = 13)
        run_multiplier_test(-6'd3, 6'd13);

        // Test 3: Standard Positive Alignment (X = 7, Y = 5)
        run_multiplier_test(6'd7, 6'd5);

        // Test 4: Both Negative Values (X = -5, Y = -6)
        run_multiplier_test(-6'd5, -6'd6);

        // Test 5: Multiplications with Boundary Zero Condition
        run_multiplier_test(6'd0, -6'd12);
        run_multiplier_test(-6'd15, 6'd0);

        // --- EXTREME EDGE CASE / OVERFLOW BOUNDARY TESTING ---
        
        // Test 6: Maximum Positive Values for 6-bit Signed Integers (+31)
        run_multiplier_test(6'd31, 6'd31);

        // Test 7: Minimum Most-Negative Boundary Edge for 6-bit Signed Integers (-32)
        run_multiplier_test(-6'd32, -6'd32);

        // --- RANDOMIZED ARRAYS TESTING LOOP ---
        $display("\n====================================================================");
        $display("                 RUNNING RANDOMIZED TEST VECTORS                    ");
        $display("====================================================================");
        for (int i = 0; i < 5; i++) begin
            logic signed [N-1:0] rand_X;
            logic signed [N-1:0] rand_Y;
            
            rand_X = $urandom_range(0, (2**N)-1);
            rand_Y = $urandom_range(0, (2**N)-1);
            
            run_multiplier_test(rand_X, rand_Y);
        end

        $display("====================================================================");
        $display("               SIMULATION SUITE EXECUTION COMPLETE                  ");
        $display("====================================================================");
        $finish;
    end

endmodule