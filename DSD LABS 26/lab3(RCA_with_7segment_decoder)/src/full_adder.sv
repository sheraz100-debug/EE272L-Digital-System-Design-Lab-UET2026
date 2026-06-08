module full_adder(

    input  logic a,
    input  logic b,
    input  logic c,
    output logic sum,
    output logic carry
);

    // Full Adder Logic
    assign sum   = a ^ b ^ c;
    assign carry = (a & b) | (b & c) | (a & c);

endmodule