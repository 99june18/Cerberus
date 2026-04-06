module SSE_CORRECTOR(input [287:0] codeword_in,
                     input [31:0] syndrome_in,
                      output decode_result_out,
                      output [255:0] data_out
                      );
  reg [1:0] decode_result;
  reg [287:0] codeword;
  //wire [7:0] error_location_gdiv;
  wire [15:0] error_location_gfdiv;
  reg [15:0] error_location_gfexp;
  reg [15:0] error_value;
  wire [15:0] syndrome0,syndrome1;


    GFEXP gfexp_00(syndrome_in[31:16],syndrome0); // S0=a^n => n
    GFEXP gfexp_01(syndrome_in[15:0],syndrome1); // S1=a^m => m
    GFDIV error_value00(syndrome_in[15:0],syndrome_in[31:16], error_location_gfdiv);
    GFDIV error_value01(syndrome_in[31:16], error_location_gfdiv, error_value); 
    ERROR_LOCATION error_location(syndrome1, syndrome0, error_location_gfexp); 
    
   always_comb begin
     codeword=codeword_in;
     if(syndrome_in[15:0]!=16'b0000_0000_0000_0000 && syndrome_in[31:16]!=16'b0000_0000_0000_0000) begin
         case(error_location_gfexp)
            16'd16:  begin codeword[287:272]^=error_value; decode_result=1'b0; end 
            16'd32:  begin codeword[271:256]^=error_value; decode_result=1'b0; end 
            16'd48:  begin codeword[255:240]^=error_value; decode_result=1'b0; end 
            16'd64:  begin codeword[239:224]^=error_value; decode_result=1'b0; end 
            16'd80:  begin codeword[223:208]^=error_value; decode_result=1'b0; end 
            16'd96:  begin codeword[207:192]^=error_value; decode_result=1'b0; end 
            16'd112: begin codeword[191:176]^=error_value; decode_result=1'b0; end 
            16'd128: begin codeword[175:160]^=error_value; decode_result=1'b0; end 
            16'd144: begin codeword[159:144]^=error_value; decode_result=1'b0; end 
            16'd160: begin codeword[143:128]^=error_value; decode_result=1'b0; end 
            16'd176: begin codeword[127:112]^=error_value; decode_result=1'b0; end 
            16'd192: begin codeword[111:96]^=error_value; decode_result=1'b0; end 
            16'd208: begin codeword[95:80]^=error_value; decode_result=1'b0; end 
            16'd224: begin codeword[79:64]^=error_value; decode_result=1'b0; end 
            16'd240: begin codeword[63:48]^=error_value; decode_result=1'b0; end 
            16'd256: begin codeword[47:32]^=error_value; decode_result=1'b0; end 
            default: begin decode_result=1'b1; end // DUE
         endcase
     end
     if(syndrome_in[15:0]==16'b0000_0000_0000_0000 && syndrome_in[31:16]!=16'b0000_0000_0000_0000)begin 
        codeword[31:16]^=syndrome_in[31:16]; // error correction
        decode_result=1'b0; //CE
     end
     if(syndrome_in[15:0]!=16'b0000_0000_0000_0000 && syndrome_in[31:16]==16'b0000_0000_0000_0000)begin 
        codeword[15:0]^=syndrome_in[15:0]; // error correction
        decode_result=1'b0; //CE
     end
     if(syndrome_in[31:0]==32'b0000_0000_0000_0000_0000_0000_0000_0000) begin 
        decode_result=1'b0; // NE
     end
   end
  
  assign decode_result_out = decode_result;
  assign data_out = codeword[287:32];

endmodule
