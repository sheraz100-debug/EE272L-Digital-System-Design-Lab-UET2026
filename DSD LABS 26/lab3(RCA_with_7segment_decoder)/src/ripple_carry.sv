module ripple_carry(
    input logic [2:0]a,
    input logic [2:0]b,
    input logic cin,
    output logic [2:0]sum,
    output logic cout

);
    logic c1,c2;
    full_adder FA0(a[0],b[0],cin,sum[0],c1);
    full_adder FA1(a[1],b[1],c1,sum[1],c2);
    full_adder FA2(a[2],b[2],c2,sum[2],cout);

endmodule