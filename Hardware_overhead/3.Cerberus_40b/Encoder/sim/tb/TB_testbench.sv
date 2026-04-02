module TB();

wire [255:0] data_in;
wire [295:0] codeword_out;
 
reg [255:0] data;

initial begin
    data[255:240]  = 16'b1010_0011_1010_0011;
    data[239:0]    = 240'b0;  
end

assign data_in = data;

  ENCODER encoder(data_in, codeword_out);


  initial begin
    # 20;
    $display("data :     %b",data_in);
    $display("codeword : %b",codeword_out);
  end

endmodule
