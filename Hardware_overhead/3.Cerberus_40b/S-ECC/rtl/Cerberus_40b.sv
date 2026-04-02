module Cerberus_40b(
    input  wire [295:0] codeword_in,
    output wire         decode_result_out,
    output wire [255:0] data_out
);

    wire [39:0]  syndrome;
    wire         decode_result_1;
    wire         decode_result_2;
    wire         decode_result;
    wire [255:0] data_1;
    wire [255:0] data_2;
    wire [255:0] data;

    SYNDROME_GENERATOR syndrome_generator(
        .codeword_in  (codeword_in),
        .syndrome_out (syndrome)
    );

    SSE_CORRECTOR sse_corrector (
        .codeword_in       (codeword_in),
        .syndrome_in       (syndrome),
        .decode_result_out (decode_result_1),
        .data_out          (data_1)
    );

    DE_CORRECTOR de_corrector (
        .codeword_in   (codeword_in),
        .syndrome_in   (syndrome),
        .decode_result (decode_result_2),
        .data_out      (data_2)
    );

    DECISION decision(
        .decode_result_1_in (decode_result_1),
        .decode_result_2_in (decode_result_2),
        .data_1_in          (data_1),
        .data_2_in          (data_2),
        .decode_result_out  (decode_result),
        .data_out           (data)
    );

    assign data_out          = data;
    assign decode_result_out = decode_result;

endmodule
