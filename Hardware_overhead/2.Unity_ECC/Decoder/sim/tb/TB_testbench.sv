module TB();

wire [287:0] codeword_in;
//wire [3:0] Error_location_out;
wire decode_result_out;
wire [255:0] data_out;
wire [15:0] error_value_out;
wire [15:0] syndrome0_out;
wire [15:0] syndrome1_out;
 
reg [287:0] codeword;

initial begin
    //codeword[287:272] = 16'b1010_0011_1010_0011; // error value
    //codeword[271:0]   = 272'b0;  

    //codeword[287] = 1'b1;                     // error value
    //codeword[286:200] = 87'b0;
    //codeword[199] = 1'b1;                     // error value
    //codeword[198:0] = 199'b0;
end

assign codeword_in = codeword;

  UNITY_DECODER decoder(codeword_in, decode_result_out, data_out);

  initial begin
    # 20;
    $display("codeword :           %b",codeword_in);
    $display("data :               %b",data_out);
    $display("decode_result_out :  %b",decode_result_out);
  end

endmodule