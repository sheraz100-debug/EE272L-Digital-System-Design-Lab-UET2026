module datapath(
    input logic clk,
    input logic rst,
    input logic load_next,
    input logic load_sum,
    input logic next_select,
    input logic sum_select,
    input logic Address_select,
    output logic Next_Zero,
    input logic [7:0]memory_data,
    output logic [15:0]result,
    output logic [7:0]memory_address
);
logic [15:0]sum_register;  
logic [7:0]next_register;

assign memory_address = (Address_select == 1'b0) ? next_register : next_register + 8'd1;
assign Next_Zero = (memory_data==8'd0);
//Next_register
always_ff @(posedge clk or posedge rst) begin
    if(rst) begin
        next_register <= 0;
    end 
    else if (load_next) begin
        if(next_select) begin
            next_register <= memory_data;
        end
        else begin
        next_register<=0;
    end
    end
    
end
//Sum Register
always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        sum_register<=0;
        
    end 
    else if (load_sum) begin
        if(sum_select) begin
            sum_register <= sum_register + memory_data;
        end
        else begin
        sum_register<=0;
    end
    end
    
end
assign result = sum_register;
endmodule