module binary_to_bcd(
    input  logic [4:0] binary,   // 5-bit binary input
    output logic [3:0] tens,     // BCD tens digit
    output logic [3:0] ones      // BCD ones digit
);

always_comb
begin
    tens = binary / 10;   // decimal tens
    ones = binary % 10;   // decimal ones
end

endmodule