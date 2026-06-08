module full_adder
(
    input logic A,
    input logic B,
    input logic Cin,
    output logic sum,
    output logic Cout
);
  assign sum  = A ^ B ^ Cin;
  assign Cout = (A & B) | (B & Cin) | (A & Cin);
endmodule
