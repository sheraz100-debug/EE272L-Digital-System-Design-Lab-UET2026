module memory(
    input logic [7:0] address,
    output logic [7:0] data
);
logic [7:0] nodes [0:255];
initial begin
    integer i;
    for(i=0;i<256;i=i+1)
        nodes[i]=0;
    nodes[0] = 3;
    nodes[1] = 10;
    nodes[3] = 6;
    nodes[4] = 20;
    nodes[6] = 0;
    nodes[7] = 30;

end
assign data = nodes[address];

endmodule