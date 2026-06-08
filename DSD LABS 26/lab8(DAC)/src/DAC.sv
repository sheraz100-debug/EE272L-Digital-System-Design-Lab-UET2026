module DAC #(

    parameter CYCLES_PER_WINDOW = 1024,

    parameter CODE_WIDTH = $clog2(CYCLES_PER_WINDOW)

)(

    input  logic clk,

    input  logic rst,

    input  logic [CODE_WIDTH-1:0] code,

    output logic next_sample,

    output logic pwm,

    output logic [CODE_WIDTH-1:0] count_out

);

    logic [CODE_WIDTH-1:0] count;

    // Counter
    always_ff @(posedge clk or posedge rst) begin

        if (rst)
            count <= 0;

        else
            count <= count + 1;

    end

    // next_sample pulse
    always_ff @(posedge clk or posedge rst) begin

        if (rst)
            next_sample <= 0;

        else if (count == CYCLES_PER_WINDOW-1)
            next_sample <= 1;

        else
            next_sample <= 0;

    end

    // PWM generation
    assign pwm =
        (code == CYCLES_PER_WINDOW-1) ? 1'b1 :
        (count < code);

    assign count_out = count;

endmodule