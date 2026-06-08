module shift_register(
    input logic clk,rst,shift_enable,
    input logic serial_input,
    output logic [3:0] parallel_out
   
);
always_ff @(posedge clk or posedge rst) begin
    if(rst)
      parallel_out <= 4'd0;

    else if (shift_enable) begin
        //parallel_out <= parallel_out >>1;
        //parallel_out[3] = serial_input;
        parallel_out = {serial_input,parallel_out[3:1]};
        //cancatenation add two different bits of group{1,011} = 1011
    end
end    

endmodule