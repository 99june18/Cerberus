module Cerberus_32b(input [287:0] codeword_in,
                      output decode_result_out,
                      output [255:0] data_out
                      );

  wire [31:0] syndrome;
  wire [15:0] error_value;
  wire decode_result_1;
  wire decode_result_2;
  wire decode_result;
  reg [287:0] codeword;
  wire [255:0] data_1;
  wire [255:0] data_2;
  wire [255:0] data;

  SYNDROME_GENERATOR syndrome_generator(codeword_in,syndrome);
  SSE_CORRECTOR sse_corrector (codeword_in, syndrome, decode_result_1, data_1);
  DE_CORRECTOR de_corrector (codeword_in, syndrome, decode_result_2, data_2);
  DECISION decision(decode_result_1, decode_result_2, data_1, data_2, decode_result, data);

  assign data_out = data;
  assign decode_result_out = decode_result; 

endmodule
