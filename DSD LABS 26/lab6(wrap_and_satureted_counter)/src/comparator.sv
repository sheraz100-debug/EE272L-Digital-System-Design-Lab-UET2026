module comparator #(parameter N = 4)(
    input  logic [N-1:0] a,
    input  logic [N-1:0] b,
    output logic equal,
    output logic greater,
    output logic less
);
    always_comb begin
        equal   = (a == b);
        greater = (a > b);
        less    = (a < b);
    end
endmodule