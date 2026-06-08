
module ripple_carry_tb;
logic [2:0] a1;
logic [2:0] b1;
logic Cin;
logic [2:0] sum;
logic Cout;
ripple_carry MEA (
.A(a1),
.B(b1),
.Cin(Cin),
.sum(sum),
.Cout(Cout)
);
initial begin
a1 = 3'b000; b1 = 3'b000; Cin = 0;
#10;
a1 = 3'b001; b1 = 3'b010; Cin = 0;
#10;
a1 = 3'b011; b1 = 3'b001; Cin = 1;
#10;
a1 = 3'b101; b1 = 3'b010; Cin = 0;
#10;
a1 = 3'b111; b1 = 3'b111; Cin = 0;
#10;
a1 = 3'b111; b1 = 3'b111; Cin = 1;
#10;
end
endmodule
