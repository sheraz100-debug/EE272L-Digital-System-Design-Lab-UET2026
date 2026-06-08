module a7top
(
    input  logic [15:0] switch,
    input  logic [4:0]  push_button,
    input  logic        clk,

    output logic        aud_pwm,
    output logic        aud_sd,

    output logic [15:0] led,
    output logic [7:0]  an,
    output logic [6:0]  abcdefg,
    output logic [7:0]  pmod_a
);

    logic rst;

    logic [9:0] code;

    logic next_sample;

    logic [7:0] count_dac_samples;

    // reset
    assign rst = push_button[0];

    // Square wave generator
    SQ_WAVE_GEN SQ_WAVE_GEN (
        .clk(clk),
        .rst(rst),
        .next_sample(next_sample),
        .code(code),
        .count_dac_samples(count_dac_samples)
    );

    // DAC
    DAC DAC (
        .clk(clk),
        .rst(rst),
        .code(code),
        .next_sample(next_sample),
        .pwm(aud_pwm)
    );

    // Audio enable
    assign aud_sd = switch[0];

    // LEDs mirror switches
    assign led = switch;

    // unused outputs
    assign an = 8'hFF;

    assign abcdefg = 7'h7F;

    assign pmod_a = 8'h00;

endmodule