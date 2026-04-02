module TB();

wire [295:0] codeword_in;
wire decode_result_out;
wire [255:0] data_out;
 
reg [295:0] codeword;

initial begin
    //codeword[295:280] = 16'b1010_0011_1010_0011; // error value
    //codeword[279:0]   = 280'b0;  

    codeword[295:248] = 48'b0;
    codeword[247:232] = 16'b1001_1111_0101_0001; // error value
    codeword[231:0]   = 232'b0; 

    //codeword[295:150] = 146'b0;
    //codeword[149] = 1'b1;
    //codeword[148:100] = 49'b0;
    //codeword[99] = 1'b1;
    //codeword[98:0] = 99'b0;

    //codeword[295:202] = 94'b0;
    //codeword[201] = 1'b1;
    //codeword[200:151] = 50'b0;
    //codeword[150] = 1'b1;
    //codeword[149:0] = 150'b0;
end

assign codeword_in = codeword;

  Cerberus_40b decoder(codeword_in, decode_result_out, data_out);

  initial begin
    # 20;
    $display("codeword :           %b",codeword_in);
    $display("data :               %b",data_out);
    $display("decode_result_out :  %b",decode_result_out);
  end

endmodule