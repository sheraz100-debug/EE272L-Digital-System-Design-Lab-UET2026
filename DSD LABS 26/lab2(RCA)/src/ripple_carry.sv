module ripple_carry(
    input logic[2:0]A,
    input logic[2:0]B,
    input Cin,
    output logic [2:0]sum,
    output logic Cout
);
logic c1,c2;
full_adder FA0(A[0],B[0],Cin,sum[0],c1);
full_adder FA1(A[1],B[1],c1,sum[1],c2);
full_adder FA2(A[2],B[2],c2,sum[2],Cout);
endmodule