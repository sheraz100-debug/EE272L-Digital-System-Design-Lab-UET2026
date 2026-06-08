module const_mult_3_tb;

logic [3:0] x1;
logic [3:0] p1;

localparam period = 10;

// Unit Under Test
const_mult_3 UUT (
    .x(x1),
    .p(p1)
);

initial
begin
    // Provide different input combinations

    x1 = 4'b0000; // 0 → 0
    #period;

    x1 = 4'b0001; // 1 → 3
    #period;

    x1 = 4'b0010; // 2 → 6
    #period;

    x1 = 4'b0011; // 3 → 9
    #period;

    x1 = 4'b0100; // 4 → 12
    #period;

    x1 = 4'b0101; // 5 → 15
    #period;

    x1 = 4'b0110; // 6 → 18 (overflow)
    #period;

    x1 = 4'b0111; // 7 → 21 (overflow)
    #period;

    x1 = 4'b1000; // 8 → 24 (overflow)
    #period;

    x1 = 4'b1001; // 9 → 27 (overflow)
    #period;

    x1 = 4'b1010; // 10 → 30 (overflow)
    #period;

    x1 = 4'b1011; // 11 → 33 (overflow)
    #period;

    x1 = 4'b1100; // 12 → 36 (overflow)
    #period;

    x1 = 4'b1101; // 13 → 39 (overflow)
    #period;

    x1 = 4'b1110; // 14 → 42 (overflow)
    #period;

    x1 = 4'b1111; // 15 → 45 (overflow)
    #period;

    $stop;
end

initial
begin
    $monitor("Time=%0t | X=%b (%0d) | P=%b (%0d)", 
              $time, x1, x1, p1, p1);
end

endmodule