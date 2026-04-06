module DECISION(input decode_result_1_in,
               input decode_result_2_in,
               input [255:0] data_1_in,
               input [255:0] data_2_in,
               output decode_result_out,
               output [255:0] data_out
                      );
  reg [1:0] decode_result;
  reg [15:0] Error_location_gfexp;
  reg [3:0] Error_location_reg;
  reg [7:0] Error_value;
  wire [7:0] Syndrome0,Syndrome1;

   assign decode_result_out = (decode_result_1_in < decode_result_2_in) ? decode_result_1_in : decode_result_2_in; 
   assign data_out = (decode_result_1_in < decode_result_2_in) ? data_1_in : data_2_in;



endmodule
