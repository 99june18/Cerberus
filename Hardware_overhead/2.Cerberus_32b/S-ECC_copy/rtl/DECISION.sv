module DECISION(
    input         decode_result_1_in,
    input         decode_result_2_in,
    input  [255:0] data_1_in,
    input  [255:0] data_2_in,
    output        decode_result_out,
    output [255:0] data_out
);
    assign decode_result_out = decode_result_1_in & decode_result_2_in;

    assign data_out = (decode_result_2_in == 1'b0) ? data_2_in :
                      (decode_result_1_in == 1'b0) ? data_1_in :
                      data_2_in;
endmodule
