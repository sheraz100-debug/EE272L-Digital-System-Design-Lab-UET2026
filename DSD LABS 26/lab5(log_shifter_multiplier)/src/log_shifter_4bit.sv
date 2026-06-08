module log_shifter_4bit (
    input  logic [3:0] x,
    input  logic [1:0] s,
    input  logic en,
    output logic [3:0] y
);
    logic [3:0] temp;

    always_comb begin
        case (s)
            2'b00: temp = x;
            2'b01: temp = x << 1;
            2'b10: temp = x << 2;
            2'b11: temp = x << 3;
        endcase

        y = en ? temp : 4'b0000;
    end
endmodule