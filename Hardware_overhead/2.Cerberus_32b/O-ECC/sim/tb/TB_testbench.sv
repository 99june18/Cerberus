module TB();

wire [287:0] codeword_in;
wire [271:0] data_out;
wire decode_result_out;
reg [287:0] codeword;

initial begin
    //1 bit error
    //codeword[287] = 1'b1;
    //codeword[286:0] = 287'b0;

    // Middle 1 bit error
    codeword[287:143] = 145'b0;
    codeword[142] = 1'b1;
    codeword[141:0] = 142'b0;

    // 2 bit error
    //codeword[287] = 1'b1;
    //codeword[286:143] = 144'b0;
    //codeword[142] = 1'b1;
    //codeword[141:0] = 142'b0;

    // Bounded 3 bit error.
    //codeword[287:285] = 3'b111;
    //codeword[284:0] = 285'b0;

end

assign codeword_in = codeword;

  SEC_DED_DECODER decoder (codeword_in,decode_result_out,data_out);


  initial begin
    # 20;
    $display("codeword :      %b",codeword_in);
    $display("data :          %b",data_out);
    $display("decode result : %b",decode_result_out);
  end

// Decode result : 0 (CE or NE)
// Decode result : 1 (DUE)
endmodule