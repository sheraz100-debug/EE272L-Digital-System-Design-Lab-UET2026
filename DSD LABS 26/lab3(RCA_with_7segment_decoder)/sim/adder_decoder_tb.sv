module adder_decoder_tb;

    // Inputs
    logic [2:0] a;
    logic [2:0] b;
    logic       c_in;
    logic [2:0] sel; // Corrected: 3-bit bus

    // Outputs
    logic [6:0] seg; // 7-bit bus (seg[6]=A, ..., seg[0]=G)
    logic [7:0] an;  // 8-bit bus for 8 anodes

    // Instantiate the Unit Under Test (UUT)
    top_adder_decoder MEA (
        .a(a),
        .b(b),
        .c_in(c_in),
        .sel(sel),   
        .seg(seg),
        .an(an)
    );

    initial begin
        // Display header
        $display("a\tb\tc_in\tresult(seg)\tan");

        // Test Case 1: a = 3, b = 4, c_in = 0, sel = 7
        a = 3; b = 4; c_in = 0; sel = 7;

        // wait 10ns for the logic to ripple through
        #10;
        $display("%b\t%b\t%b\t%b\t%b", a, b, c_in, seg, an);

        // Assert expected outputs for result '7'
        if (seg != 7'b0001111)
            $display("ERROR:seg_output_incorrect");
        else
            $display("PASS:seg_output_correct");

        // Assert expected output for AN7 active
        if (an != 8'b01111111)
            $display("ERROR:an_output_incorrect");
        else
            $display("PASS:an_output_correct");

        $display("Now its your turn!");
        $stop; // Useful to pause the simulation in Questa
    end
endmodule