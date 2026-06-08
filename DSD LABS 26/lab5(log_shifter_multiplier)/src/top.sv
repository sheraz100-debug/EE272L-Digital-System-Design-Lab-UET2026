module top (
    input  logic [3:0] sw,
    output logic [6:0] seg,
    output logic [7:0] an
);
    logic [3:0] product;

    const_mult_3 mult (
        .x(sw),
        .p(product)
    );

    seven_seg disp (
        .digit(product),
        .seg(seg)
    );

    // Enable first display only
    assign an = 8'b11111110;
endmodule