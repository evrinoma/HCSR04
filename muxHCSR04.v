module muxHCSR04(sw0, data, out);
input wire sw0;
input wire [15:0] data;
output wire [7:0] out;

assign out = (!sw0)? data[15:8] : data[7:0];

endmodule
