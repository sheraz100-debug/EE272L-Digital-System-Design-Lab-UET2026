module thunderbird_tb();

    // 1. Signals for driving the FSM
    logic clk;
    logic reset;
    logic left;
    logic right;
    logic lc, lb, la, ra, rb, rc;

    // 2. Instantiate the Unit Under Test (UUT)
    thunderbird_fsm uut (
        .clk(clk),
        .reset(reset),
        .left(left),
        .right(right),
        .lc(lc), .lb(lb), .la(la), 
        .ra(ra), .rb(rb), .rc(rc)
    );

    // 3. Clock Generation (Clock period = 10 units)
    always #5 clk = ~clk;

    // 4. Stimulus Process
    initial begin
        // Initialize Inputs
        clk = 0;
        reset = 1;
        left = 0;
        right = 0;

        // Reset the system
        #15 reset = 0;
        
        // --- Test Case 1: Left Turn Sequence ---
        // Lab says: LA -> LA+LB -> LA+LB+LC -> OFF [cite: 49]
        #10 left = 1;
        #10 left = 0; // Signal release kar dein, sequence pura hona chahiye [cite: 51]
        #40;          // Wait for sequence to finish (3 states + return to IDLE)

        // --- Test Case 2: Right Turn Sequence ---
        // Lab says: RA -> RA+RB -> RA+RB+RC -> OFF [cite: 53]
        #10 right = 1;
        #10 right = 0;
        #40;

        // --- Test Case 3: Hazard Mode (Simultaneous Left and Right) ---
        // Humne decide kiya tha ke Dono 1 hon to Hazard mode chale [cite: 55]
        #10 left = 1; right = 1;
        #10 left = 0; right = 0;
        #30;

        // --- Test Case 4: Reset during operation ---
        #10 left = 1;
        #15 reset = 1; // Sequence ke beech mein reset dabana 
        #10 reset = 0;

        #100 $finish;
    end

    // 5. Monitor the outputs in the console
    initial begin
        $monitor("Time=%0t | State: L=%b R=%b | Lights: LC=%b LB=%b LA=%b RA=%b RB=%b RC=%b", 
                 $time, left, right, lc, lb, la, ra, rb, rc);
    end

endmodule