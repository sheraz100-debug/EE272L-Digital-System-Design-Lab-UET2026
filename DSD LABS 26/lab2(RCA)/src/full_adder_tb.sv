module full_adder_tb();
logic a1;
logic b1;
logic c1;
logic sum1;
logic carry1;
full_adder MEA (
.A(a1),
.B(b1),
.Cin(c1),
.sum(sum1),
.Cout(carry1)
);
initial begin
// Provide different combinations of the inputs to check validity of code
a1 = 0; b1 = 0; c1 = 0;
#10;
a1 = 0; b1 = 0; c1 = 1;
#10;
a1 = 0; b1 = 1; c1 = 0;
#10;
a1 = 0; b1 = 1; c1 = 1;
#10;
a1 = 1; b1 = 0; c1 = 0;
#10;
a1 = 1; b1 = 0; c1 = 1;
#10;
a1 = 1; b1 = 1; c1 = 0;
#10
a1 = 1; b1 = 1; c1 = 1;
#10;
$stop;
end
endmodule
