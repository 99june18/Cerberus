module TB();

wire [287:0] codeword_in;
wire decode_result_out;
wire [255:0] data_out;
wire [15:0] error_value_out;
wire [15:0] syndrome0_out;
wire [15:0] syndrome1_out;
 
reg [287:0] codeword;

initial begin
    //codeword[287:272] = 16'b1010_0011_1010_0011; // error value
    //codeword[271:0]   = 272'b0;  

    //codeword[287:272] = 16'b0; 
    //codeword[271:256] = 16'b0010_1010_0101_0111; // error value
    //codeword[255:0]   = 256'b0; 

    codeword[287] = 1'b1;                     // error value
    codeword[286:200] = 87'b0;
    codeword[199] = 1'b1;                     // error value
    codeword[198:0] = 199'b0;

    //codeword[287:150] = 138'b0;
    //codeword[149] = 1'b1;                     // error value
    //codeword[148:100] = 49'b0;
    //codeword[99] = 1'b1;                      // error value
    //codeword[98:0] = 99'b0;
end

assign codeword_in = codeword;

  Cerberus_32b decoder(codeword_in, decode_result_out, data_out);

  initial begin
    # 20;
    $display("codeword :           %b",codeword_in);
    $display("data :               %b",data_out);
    $display("decode_result_out :  %b",decode_result_out);
  end

endmodule