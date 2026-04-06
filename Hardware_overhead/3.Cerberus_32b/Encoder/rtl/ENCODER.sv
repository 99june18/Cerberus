module ENCODER(input [255:0] data_in,
                      output [287:0] codeword_out);

  wire [31:0] parity;

  localparam [255:0] PM00 = 256'h0765b541ff84f07f8b4cf2cc09776053eca1966b06a617e387047fa7f39af75c;
  localparam [255:0] PM01 = 256'h1f892c1246e32047c4e3f623869d2138d2786b515c9fad7021ff047d01805037;
  localparam [255:0] PM02 = 256'ha1d7d55784af1c4b0e8413ee9882554b7f926f4a7609060ef693e34fa9643df5;
  localparam [255:0] PM03 = 256'h4f6db9a7ecce7d96b8201a4caa4efbc5de32577f6189c1f5f38a99cd24842661;
  localparam [255:0] PM04 = 256'hbf84030c9fc5e1aaa2ec6e66f406cb26ab5aab49b8f8aee45aedb518c486dcfa;
  localparam [255:0] PM05 = 256'h32617ba52da9d626401ac4ac5ddcdb42a703eea09bbc618b4a85cc7d12926266;
  localparam [255:0] PM06 = 256'h27c9d2b044723ff5fdc64a8963e4e2959753d8ab862a1eca4b400d352600a11d;
  localparam [255:0] PM07 = 256'h130619cd1e7d8e6d5d962305311abca36542c7cfcf2b5ca9ab212a2bf3171563;
  localparam [255:0] PM08 = 256'hbd1701045d3f0bc1730266ec666fc2b2ea18d0f5ab10c80d76b6cd437b3fb452;
  localparam [255:0] PM09 = 256'h2e24b8d389710e992fd2b3600981396186bc32d9c29a3fb52ce00bfbe723c056;
  localparam [255:0] PM10 = 256'h474d17b42d022bedc4083ca2c6a7b2d58572bd801eb9bd81a794a6b68e9b1289;
  localparam [255:0] PM11 = 256'hb0c467708a430058f8b6fd65148b725569c867a958380eba4ced2d84ad145abc;
  localparam [255:0] PM12 = 256'hda3e05c2a6ea79c67542b24fbc5018f7b56e93675b91ef4029a540190ad5a47b;
  localparam [255:0] PM13 = 256'h1b9b8aae72d2500b5503c1b4d0420871d28e22997f9192542c3a0cba10e2ebf6;
  localparam [255:0] PM14 = 256'h638a9957f829542275fa3a11fd6556c5b82eebf08b5919342be69f80b1bed05c;
  localparam [255:0] PM15 = 256'h42fef4b6c40b72f0517a416ab59f770b9628c1ff66d38d3bbc7a471408491b59;
  localparam [255:0] PM16 = 256'h2c8dcfb1850eb5a83884a7034b5b04f63f02ffdc8daed03a8d355bb427dae836;
  localparam [255:0] PM17 = 256'h0ac469b1a487362ccf6f1a4abe144150d52fe22031219d2e7c434fd9712edade;
  localparam [255:0] PM18 = 256'h8587946abfe7ac113077d3004c4585877eb4c9d662334f3644f726ca8a854567;
  localparam [255:0] PM19 = 256'h4b29a9c020986233151577f3b8cf885fc5df0508ead3436e60e31c98738ae14a;
  localparam [255:0] PM20 = 256'h2c191f7ab1b6e843b820448bfe18bbcf3197551401df47ce98f52c9c732ee110;
  localparam [255:0] PM21 = 256'hf769158abcb785953417e241c8a4acf02169e874e86c512cb9202a400d5da2d2;
  localparam [255:0] PM22 = 256'h4f21ddd7c6ffad838645a20ce6474c081a0c3d7e27468ac8e33d47b5b860754c;
  localparam [255:0] PM23 = 256'h1f5d22a208f449cf94174c3ffd0c5b6ac1ec87876ff67710b215abe8f37c5be0;
  localparam [255:0] PM24 = 256'h2f68eae840c60d43dd9c6a7b7e1afd95287d3a721fde3299f5b4b18848c5f4e3;
  localparam [255:0] PM25 = 256'h9ad25ec501ec0f78bd3a8d3dba469b4feed6a15e78b450062c5faf519e4043c9;
  localparam [255:0] PM26 = 256'h67d68cf4ac8fcd1748cc0259c1a01c6e7bbb28166578b6b13a0c292575e74e02;
  localparam [255:0] PM27 = 256'hdc3da82ee450117bf6dcbf8bd01cd6b673de6723634441e3f990162a4cd7e1b7;
  localparam [255:0] PM28 = 256'he9ecfd40e2024920233c8ba9176009d6d59bb0ab3dfa4004fd2be31ce85eeb1c;
  localparam [255:0] PM29 = 256'hb5089cc1418d00650b0bebdfdbb96df2a5a1649e44ee24f3ad3327f7d8dcf16f;
  localparam [255:0] PM30 = 256'hafc0343171d5b22578d06e20eb5706c97c78ba69d2e0b1c089e033f522c7b020;
  localparam [255:0] PM31 = 256'haa76397efbdc08f7e24028befe8bd29f0fe2af77614c488fe9286b17f831b83c;

  assign parity[0]  = ^(data_in & PM00);
  assign parity[1]  = ^(data_in & PM01);
  assign parity[2]  = ^(data_in & PM02);
  assign parity[3]  = ^(data_in & PM03);
  assign parity[4]  = ^(data_in & PM04);
  assign parity[5]  = ^(data_in & PM05);
  assign parity[6]  = ^(data_in & PM06);
  assign parity[7]  = ^(data_in & PM07);
  assign parity[8]  = ^(data_in & PM08);
  assign parity[9]  = ^(data_in & PM09);
  assign parity[10] = ^(data_in & PM10);
  assign parity[11] = ^(data_in & PM11);
  assign parity[12] = ^(data_in & PM12);
  assign parity[13] = ^(data_in & PM13);
  assign parity[14] = ^(data_in & PM14);
  assign parity[15] = ^(data_in & PM15);
  assign parity[16] = ^(data_in & PM16);
  assign parity[17] = ^(data_in & PM17);
  assign parity[18] = ^(data_in & PM18);
  assign parity[19] = ^(data_in & PM19);
  assign parity[20] = ^(data_in & PM20);
  assign parity[21] = ^(data_in & PM21);
  assign parity[22] = ^(data_in & PM22);
  assign parity[23] = ^(data_in & PM23);
  assign parity[24] = ^(data_in & PM24);
  assign parity[25] = ^(data_in & PM25);
  assign parity[26] = ^(data_in & PM26);
  assign parity[27] = ^(data_in & PM27);
  assign parity[28] = ^(data_in & PM28);
  assign parity[29] = ^(data_in & PM29);
  assign parity[30] = ^(data_in & PM30);
  assign parity[31] = ^(data_in & PM31);

  // Systematic placement
  assign codeword_out[287:32] = data_in[255:0];
  assign codeword_out[31:0]   = parity;

endmodule