module ERROR_LOCATION(input [15:0] syndrome0,
                      input [15:0] syndrome1,
                      output [15:0] error_location_out);

   assign error_location_out = (syndrome1 > syndrome0) ? syndrome1-syndrome0 : syndrome0-syndrome1;

endmodule


