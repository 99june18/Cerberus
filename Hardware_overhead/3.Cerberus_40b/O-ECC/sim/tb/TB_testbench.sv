module TB();

wire [295:0] codeword_in;
wire [279:0] data_out;
wire decode_result_out;
reg [295:0] codeword;

initial begin
    //1 bit error
    //codeword[295] = 1'b1;
    //codeword[294:0] = 295'b0;

    // Middle 1 bit error
    codeword[295:143] = 153'b0;
    codeword[142] = 1'b1;
    codeword[141:0] = 142'b0;

    // 2 bit error
    //codeword[295] = 1'b1;
    //codeword[294:143] = 152'b0;
    //codeword[142] = 1'b1;
    //codeword[141:0] = 142'b0;
end

assign codeword_in = codeword;

  SEC_DED_DECODER decoder (codeword_in,decode_result_out,data_out);

  initial begin
    # 20;
    $display("codeword :      %b",codeword_in);
    $display("data :          %b",data_out);
    $display("decode result : %b",decode_result_out);
  end

endmodule