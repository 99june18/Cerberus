module SYNDROME_GENERATOR(input [287:0] codeword_in,
                      output [31:0] syndrome_out);

  wire [15:0] parity_1 [16:0];
  wire [15:0] parity_2 [16:0]; 

  // first syndrome
  GFMULT gmult_00(codeword_in[287:272],16'b0001_0000_0000_1011, parity_1[16]); 
  GFMULT gmult_01(codeword_in[271:256],16'b0001_1011_1111_1110, parity_1[15]);
  GFMULT gmult_02(codeword_in[255:240],16'b0100_1100_0011_0101, parity_1[14]); 
  GFMULT gmult_03(codeword_in[239:224],16'b0101_1100_0010_0100, parity_1[13]); 
  GFMULT gmult_04(codeword_in[223:208],16'b1111_0111_0010_1111, parity_1[12]); 
  GFMULT gmult_05(codeword_in[207:192],16'b1111_1100_1111_1101, parity_1[11]); 
  GFMULT gmult_06(codeword_in[191:176],16'b1111_1010_0111_0001, parity_1[10]); 
  GFMULT gmult_07(codeword_in[175:160],16'b1110_0110_0100_0111, parity_1[9]);
  GFMULT gmult_08(codeword_in[159:144],16'b1010_1111_0011_1111, parity_1[8]); 
  GFMULT gmult_09(codeword_in[143:128],16'b0001_0100_1101_1111, parity_1[7]); 
  GFMULT gmult_10(codeword_in[127:112],16'b1110_0010_1011_0001, parity_1[6]); 
  GFMULT gmult_11(codeword_in[111:96], 16'b0101_0111_0001_0000, parity_1[5]); 
  GFMULT gmult_12(codeword_in[95:80],  16'b0111_0111_1101_1011, parity_1[4]); 
  GFMULT gmult_13(codeword_in[79:64],  16'b0100_0111_1101_0111, parity_1[3]); 
  GFMULT gmult_14(codeword_in[63:48],  16'b0110_1011_0110_0101, parity_1[2]); 
  GFMULT gmult_15(codeword_in[47:32],  16'b0000_1011_0010_1111, parity_1[1]); 
  GFMULT gmult_16(codeword_in[31:16],  16'b0000_0000_0000_0001, parity_1[0]);

  // Second syndrome
  GFMULT gmult_17(codeword_in[287:272],16'b0001_1011_1111_1110, parity_2[16]); 
  GFMULT gmult_18(codeword_in[271:256],16'b0101_1100_0010_0100, parity_2[15]); 
  GFMULT gmult_19(codeword_in[255:240],16'b1111_1100_1111_1101, parity_2[14]); 
  GFMULT gmult_20(codeword_in[239:224],16'b1110_0110_0100_0111, parity_2[13]); 
  GFMULT gmult_21(codeword_in[223:208],16'b0001_0100_1101_1111, parity_2[12]); 
  GFMULT gmult_22(codeword_in[207:192],16'b0101_0111_0001_0000, parity_2[11]); 
  GFMULT gmult_23(codeword_in[191:176],16'b0100_0111_1101_0111, parity_2[10]); 
  GFMULT gmult_24(codeword_in[175:160],16'b0000_1011_0010_1111, parity_2[9]); 
  GFMULT gmult_25(codeword_in[159:144],16'b1110_0111_0011_0011, parity_2[8]); 
  GFMULT gmult_26(codeword_in[143:128],16'b0101_1010_0101_0101, parity_2[7]); 
  GFMULT gmult_27(codeword_in[127:112],16'b0100_1110_1000_0000, parity_2[6]);
  GFMULT gmult_28(codeword_in[111:96], 16'b1111_0001_1001_1100, parity_2[5]); 
  GFMULT gmult_29(codeword_in[95:80],  16'b1100_1111_0011_0101, parity_2[4]); 
  GFMULT gmult_30(codeword_in[79:64],  16'b1011_1010_0011_0010, parity_2[3]); 
  GFMULT gmult_31(codeword_in[63:48],  16'b1100_0011_1000_1101, parity_2[2]); 
  GFMULT gmult_32(codeword_in[47:32],  16'b0001_0110_1001_1110, parity_2[1]); 
  GFMULT gmult_33(codeword_in[15:0],   16'b0000_0000_0000_0001, parity_2[0]); 

  assign syndrome_out[31:16] = parity_1[16] ^ parity_1[15] ^ parity_1[14] ^ parity_1[13] ^ parity_1[12] ^ parity_1[11] ^ parity_1[10] ^ parity_1[9]
  ^ parity_1[8] ^ parity_1[7] ^ parity_1[6] ^ parity_1[5] ^ parity_1[4] ^ parity_1[3] ^ parity_1[2] ^ parity_1[1] ^ parity_1[0];
  
  assign syndrome_out[15:0]  = parity_2[16] ^ parity_2[15] ^ parity_2[14] ^ parity_2[13] ^ parity_2[12] ^ parity_2[11] ^ parity_2[10] ^ parity_2[9] ^ 
  parity_2[8] ^ parity_2[7] ^ parity_2[6] ^ parity_2[5] ^ parity_2[4] ^ parity_2[3] ^ parity_2[2] ^ parity_2[1] ^ parity_2[0];

endmodule

