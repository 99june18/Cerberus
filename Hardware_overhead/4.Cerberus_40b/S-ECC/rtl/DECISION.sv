module DECISION(
    input  wire        decode_result_1_in,
    input  wire        decode_result_2_in,
    input  wire [255:0] data_1_in,
    input  wire [255:0] data_2_in,
    output wire        decode_result_out,
    output wire [255:0] data_out
);

    assign decode_result_out = (decode_result_1_in == 1'b0) ? 1'b0 :
                               (decode_result_2_in == 1'b0) ? 1'b0 : 1'b1;

    assign data_out = (decode_result_1_in == 1'b0) ? data_1_in :
                      (decode_result_2_in == 1'b0) ? data_2_in : data_1_in;

endmodule
