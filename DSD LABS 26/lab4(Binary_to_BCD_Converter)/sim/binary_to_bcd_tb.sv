`timescale 1ns/1ps

module binary_to_bcd_tb;

logic [4:0] binary;
logic [3:0] tens;
logic [3:0] ones;

localparam PERIOD = 80;

binary_to_bcd UUT (
    .binary(binary),
    .tens(tens),
    .ones(ones)
);

initial
begin
    binary = 5'b11111;   // binary 13
    #PERIOD;

    binary = 5'd5;   // decimal 5
    #PERIOD;

    binary = 5'd10;  // decimal 10
    #PERIOD;

    binary = 5'd19;  // decimal 19
    #PERIOD;

    binary = 5'd31;  // decimal 31
    #PERIOD;

    $stop;
end

endmodule