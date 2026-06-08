module const_mult_3 (
    input  logic [3:0] x,
    output logic [3:0] p
);
    logic [3:0] shift1, shift0;
    logic cout;

    // X << 1
    log_shifter_4bit sh1 (
        .x(x),
        .s(2'b01),
        .en(1'b1),
        .y(shift1)
    );

    // X << 0
    log_shifter_4bit sh0 (
        .x(x),
        .s(2'b00),
        .en(1'b1),
        .y(shift0)
    );

    // Add
    rca_4bit adder (
        .a(shift1),
        .b(shift0),
        .cin(1'b0),
        .sum(p),
        .cout(cout)
    );
endmodule