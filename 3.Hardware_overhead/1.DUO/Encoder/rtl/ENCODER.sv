module ENCODER (
    input  [7:0] data[31:0],
    output [7:0] parity[5:0],
    output [7:0] codeword[37:0]
);

    wire [7:0] syn_ac_5[31:0];
    wire [7:0] syn_ac_4[31:0];
    wire [7:0] syn_ac_3[31:0];
    wire [7:0] syn_ac_2[31:0];
    wire [7:0] syn_ac_1[31:0];
    wire [7:0] syn_ac_0[31:0];

    GFMULT gmult_000(data[0 ], 8'b0100_1001      , syn_ac_5[31]);
    GFMULT gmult_001(data[1 ], 8'b0011_0101      , syn_ac_5[30]);
    GFMULT gmult_002(data[2 ], 8'b0000_1110      , syn_ac_5[29]);
    GFMULT gmult_003(data[3 ], 8'b0110_0110      , syn_ac_5[28]);
    GFMULT gmult_004(data[4 ], 8'b1011_1101      , syn_ac_5[27]);
    GFMULT gmult_005(data[5 ], 8'b1010_1111      , syn_ac_5[26]);
    GFMULT gmult_006(data[6 ], 8'b0100_0000      , syn_ac_5[25]);
    GFMULT gmult_007(data[7 ], 8'b0101_0100      , syn_ac_5[24]);
    GFMULT gmult_008(data[8 ], 8'b0010_1011      , syn_ac_5[23]);
    GFMULT gmult_009(data[9 ], 8'b1111_0011      , syn_ac_5[22]);
    GFMULT gmult_010(data[10], 8'b0011_0001      , syn_ac_5[21]);
    GFMULT gmult_011(data[11], 8'b0111_0110      , syn_ac_5[20]);
    GFMULT gmult_012(data[12], 8'b0100_1000      , syn_ac_5[19]);
    GFMULT gmult_013(data[13], 8'b1010_0111      , syn_ac_5[18]);
    GFMULT gmult_014(data[14], 8'b1110_1111      , syn_ac_5[17]);
    GFMULT gmult_015(data[15], 8'b1100_0111      , syn_ac_5[16]);
    GFMULT gmult_016(data[16], 8'b0000_1010      , syn_ac_5[15]);
    GFMULT gmult_017(data[17], 8'b0010_0101      , syn_ac_5[14]);
    GFMULT gmult_018(data[18], 8'b0101_1100      , syn_ac_5[13]);
    GFMULT gmult_019(data[19], 8'b0101_0000      , syn_ac_5[12]);
    GFMULT gmult_020(data[20], 8'b1111_1001      , syn_ac_5[11]);
    GFMULT gmult_021(data[21], 8'b1110_1000      , syn_ac_5[10]);
    GFMULT gmult_022(data[22], 8'b0110_0111      , syn_ac_5[ 9]);
    GFMULT gmult_023(data[23], 8'b1010_1101      , syn_ac_5[ 8]);
    GFMULT gmult_024(data[24], 8'b1000_1010      , syn_ac_5[ 7]);
    GFMULT gmult_025(data[25], 8'b0001_1100      , syn_ac_5[ 6]);
    GFMULT gmult_026(data[26], 8'b0101_0011      , syn_ac_5[ 5]);
    GFMULT gmult_027(data[27], 8'b1000_0011      , syn_ac_5[ 4]);
    GFMULT gmult_028(data[28], 8'b1110_1011      , syn_ac_5[ 3]);
    GFMULT gmult_029(data[29], 8'b0110_0000      , syn_ac_5[ 2]);
    GFMULT gmult_030(data[30], 8'b1011_1011      , syn_ac_5[ 1]);
    GFMULT gmult_031(data[31], 8'b0010_0010      , syn_ac_5[ 0]);
//------------------------------------------------------------------------------------//
    GFMULT gmult_032(data[0 ], 8'b1101_0010      , syn_ac_4[31]);
    GFMULT gmult_033(data[1 ], 8'b1011_0001      , syn_ac_4[30]);
    GFMULT gmult_034(data[2 ], 8'b0010_1100      , syn_ac_4[29]);
    GFMULT gmult_035(data[3 ], 8'b0010_1010      , syn_ac_4[28]);
    GFMULT gmult_036(data[4 ], 8'b0100_1110      , syn_ac_4[27]);
    GFMULT gmult_037(data[5 ], 8'b0111_1111      , syn_ac_4[26]);
    GFMULT gmult_038(data[6 ], 8'b1101_1100      , syn_ac_4[25]);
    GFMULT gmult_039(data[7 ], 8'b0010_0110      , syn_ac_4[24]);
    GFMULT gmult_040(data[8 ], 8'b0010_0100      , syn_ac_4[23]);
    GFMULT gmult_041(data[9 ], 8'b0001_0010      , syn_ac_4[22]);
    GFMULT gmult_042(data[10], 8'b0110_1110      , syn_ac_4[21]);
    GFMULT gmult_043(data[11], 8'b1111_1101      , syn_ac_4[20]);
    GFMULT gmult_044(data[12], 8'b0011_1110      , syn_ac_4[19]);
    GFMULT gmult_045(data[13], 8'b1100_0001      , syn_ac_4[18]);
    GFMULT gmult_046(data[14], 8'b0111_0000      , syn_ac_4[17]);
    GFMULT gmult_047(data[15], 8'b1110_1000      , syn_ac_4[16]);
    GFMULT gmult_048(data[16], 8'b1100_1000      , syn_ac_4[15]);
    GFMULT gmult_049(data[17], 8'b1100_0001      , syn_ac_4[14]);
    GFMULT gmult_050(data[18], 8'b0100_1100      , syn_ac_4[13]);
    GFMULT gmult_051(data[19], 8'b0101_0011      , syn_ac_4[12]);
    GFMULT gmult_052(data[20], 8'b0010_0110      , syn_ac_4[11]);
    GFMULT gmult_053(data[21], 8'b1111_0101      , syn_ac_4[10]);
    GFMULT gmult_054(data[22], 8'b0100_0100      , syn_ac_4[ 9]);
    GFMULT gmult_055(data[23], 8'b0100_1001      , syn_ac_4[ 8]);
    GFMULT gmult_056(data[24], 8'b1011_1110      , syn_ac_4[ 7]);
    GFMULT gmult_057(data[25], 8'b1100_0111      , syn_ac_4[ 6]);
    GFMULT gmult_058(data[26], 8'b1010_1011      , syn_ac_4[ 5]);
    GFMULT gmult_059(data[27], 8'b0010_0110      , syn_ac_4[ 4]);
    GFMULT gmult_060(data[28], 8'b0111_0000      , syn_ac_4[ 3]);
    GFMULT gmult_061(data[29], 8'b0111_0111      , syn_ac_4[ 2]);
    GFMULT gmult_062(data[30], 8'b1001_1000      , syn_ac_4[ 1]);
    GFMULT gmult_063(data[31], 8'b1011_1000      , syn_ac_4[ 0]);
//------------------------------------------------------------------------------------//
    GFMULT gmult_064(data[0 ], 8'b0110_1001      , syn_ac_3[31]);
    GFMULT gmult_065(data[1 ], 8'b0011_1000      , syn_ac_3[30]);
    GFMULT gmult_066(data[2 ], 8'b1011_0000      , syn_ac_3[29]);
    GFMULT gmult_067(data[3 ], 8'b0101_1001      , syn_ac_3[28]);
    GFMULT gmult_068(data[4 ], 8'b0101_1111      , syn_ac_3[27]);
    GFMULT gmult_069(data[5 ], 8'b0000_1101      , syn_ac_3[26]);
    GFMULT gmult_070(data[6 ], 8'b0010_1001      , syn_ac_3[25]);
    GFMULT gmult_071(data[7 ], 8'b0110_1010      , syn_ac_3[24]);
    GFMULT gmult_072(data[8 ], 8'b1100_1000      , syn_ac_3[23]);
    GFMULT gmult_073(data[9 ], 8'b1101_1011      , syn_ac_3[22]);
    GFMULT gmult_074(data[10], 8'b1111_1100      , syn_ac_3[21]);
    GFMULT gmult_075(data[11], 8'b0111_1101      , syn_ac_3[20]);
    GFMULT gmult_076(data[12], 8'b1110_0100      , syn_ac_3[19]);
    GFMULT gmult_077(data[13], 8'b1000_1011      , syn_ac_3[18]);
    GFMULT gmult_078(data[14], 8'b0011_0110      , syn_ac_3[17]);
    GFMULT gmult_079(data[15], 8'b1001_0100      , syn_ac_3[16]);
    GFMULT gmult_080(data[16], 8'b0100_1110      , syn_ac_3[15]);
    GFMULT gmult_081(data[17], 8'b0000_1100      , syn_ac_3[14]);
    GFMULT gmult_082(data[18], 8'b0011_0111      , syn_ac_3[13]);
    GFMULT gmult_083(data[19], 8'b0111_1101      , syn_ac_3[12]);
    GFMULT gmult_084(data[20], 8'b1100_1111      , syn_ac_3[11]);
    GFMULT gmult_085(data[21], 8'b1101_0111      , syn_ac_3[10]);
    GFMULT gmult_086(data[22], 8'b1010_0011      , syn_ac_3[ 9]);
    GFMULT gmult_087(data[23], 8'b1100_1010      , syn_ac_3[ 8]);
    GFMULT gmult_088(data[24], 8'b0101_0110      , syn_ac_3[ 7]);
    GFMULT gmult_089(data[25], 8'b1100_0000      , syn_ac_3[ 6]);
    GFMULT gmult_090(data[26], 8'b0010_0101      , syn_ac_3[ 5]);
    GFMULT gmult_091(data[27], 8'b0011_0110      , syn_ac_3[ 4]);
    GFMULT gmult_092(data[28], 8'b1011_1100      , syn_ac_3[ 3]);
    GFMULT gmult_093(data[29], 8'b0011_1111      , syn_ac_3[ 2]);
    GFMULT gmult_094(data[30], 8'b0010_1000      , syn_ac_3[ 1]);
    GFMULT gmult_095(data[31], 8'b0000_1101      , syn_ac_3[ 0]);
//------------------------------------------------------------------------------------//
    GFMULT gmult_096(data[0 ], 8'b1001_1101      , syn_ac_2[31]);
    GFMULT gmult_097(data[1 ], 8'b1110_0110      , syn_ac_2[30]);
    GFMULT gmult_098(data[2 ], 8'b1011_0100      , syn_ac_2[29]);
    GFMULT gmult_099(data[3 ], 8'b1010_1010      , syn_ac_2[28]);
    GFMULT gmult_100(data[4 ], 8'b0100_1000      , syn_ac_2[27]);
    GFMULT gmult_101(data[5 ], 8'b0000_0100      , syn_ac_2[26]);
    GFMULT gmult_102(data[6 ], 8'b1111_1011      , syn_ac_2[25]);
    GFMULT gmult_103(data[7 ], 8'b1011_0010      , syn_ac_2[24]);
    GFMULT gmult_104(data[8 ], 8'b1011_1100      , syn_ac_2[23]);
    GFMULT gmult_105(data[9 ], 8'b1100_0101      , syn_ac_2[22]);
    GFMULT gmult_106(data[10], 8'b0001_1100      , syn_ac_2[21]);
    GFMULT gmult_107(data[11], 8'b1100_1101      , syn_ac_2[20]);
    GFMULT gmult_108(data[12], 8'b0111_0100      , syn_ac_2[19]);
    GFMULT gmult_109(data[13], 8'b0111_0101      , syn_ac_2[18]);
    GFMULT gmult_110(data[14], 8'b0010_1000      , syn_ac_2[17]);
    GFMULT gmult_111(data[15], 8'b0111_1011      , syn_ac_2[16]);
    GFMULT gmult_112(data[16], 8'b1101_0110      , syn_ac_2[15]);
    GFMULT gmult_113(data[17], 8'b1011_1101      , syn_ac_2[14]);
    GFMULT gmult_114(data[18], 8'b0110_1001      , syn_ac_2[13]);
    GFMULT gmult_115(data[19], 8'b1000_0010      , syn_ac_2[12]);
    GFMULT gmult_116(data[20], 8'b0011_0100      , syn_ac_2[11]);
    GFMULT gmult_117(data[21], 8'b1100_0110      , syn_ac_2[10]);
    GFMULT gmult_118(data[22], 8'b0110_0101      , syn_ac_2[ 9]);
    GFMULT gmult_119(data[23], 8'b1100_1111      , syn_ac_2[ 8]);
    GFMULT gmult_120(data[24], 8'b0110_0111      , syn_ac_2[ 7]);
    GFMULT gmult_121(data[25], 8'b1010_0000      , syn_ac_2[ 6]);
    GFMULT gmult_122(data[26], 8'b1001_0101      , syn_ac_2[ 5]);
    GFMULT gmult_123(data[27], 8'b0010_1111      , syn_ac_2[ 4]);
    GFMULT gmult_124(data[28], 8'b1011_0100      , syn_ac_2[ 3]);
    GFMULT gmult_125(data[29], 8'b0101_1110      , syn_ac_2[ 2]);
    GFMULT gmult_126(data[30], 8'b1100_1011      , syn_ac_2[ 1]);
    GFMULT gmult_127(data[31], 8'b0101_0011      , syn_ac_2[ 0]);
//------------------------------------------------------------------------------------//
    GFMULT gmult_128(data[0 ], 8'b0100_1010      , syn_ac_1[31]);
    GFMULT gmult_129(data[1 ], 8'b0100_1100      , syn_ac_1[30]);
    GFMULT gmult_130(data[2 ], 8'b0001_1110      , syn_ac_1[29]);
    GFMULT gmult_131(data[3 ], 8'b0110_1111      , syn_ac_1[28]);
    GFMULT gmult_132(data[4 ], 8'b1000_1000      , syn_ac_1[27]);
    GFMULT gmult_133(data[5 ], 8'b1111_0100      , syn_ac_1[26]);
    GFMULT gmult_134(data[6 ], 8'b1111_0000      , syn_ac_1[25]);
    GFMULT gmult_135(data[7 ], 8'b0011_1001      , syn_ac_1[24]);
    GFMULT gmult_136(data[8 ], 8'b0011_0110      , syn_ac_1[23]);
    GFMULT gmult_137(data[9 ], 8'b0110_0110      , syn_ac_1[22]);
    GFMULT gmult_138(data[10], 8'b0100_1101      , syn_ac_1[21]);
    GFMULT gmult_139(data[11], 8'b1110_1100      , syn_ac_1[20]);
    GFMULT gmult_140(data[12], 8'b1100_0111      , syn_ac_1[19]);
    GFMULT gmult_141(data[13], 8'b1101_0111      , syn_ac_1[18]);
    GFMULT gmult_142(data[14], 8'b0011_0110      , syn_ac_1[17]);
    GFMULT gmult_143(data[15], 8'b0100_1010      , syn_ac_1[16]);
    GFMULT gmult_144(data[16], 8'b0111_0001      , syn_ac_1[15]);
    GFMULT gmult_145(data[17], 8'b0010_1110      , syn_ac_1[14]);
    GFMULT gmult_146(data[18], 8'b1111_0111      , syn_ac_1[13]);
    GFMULT gmult_147(data[19], 8'b1100_1001      , syn_ac_1[12]);
    GFMULT gmult_148(data[20], 8'b0111_0000      , syn_ac_1[11]);
    GFMULT gmult_149(data[21], 8'b0111_0010      , syn_ac_1[10]);
    GFMULT gmult_150(data[22], 8'b1111_0110      , syn_ac_1[ 9]);
    GFMULT gmult_151(data[23], 8'b0101_0100      , syn_ac_1[ 8]);
    GFMULT gmult_152(data[24], 8'b1110_1000      , syn_ac_1[ 7]);
    GFMULT gmult_153(data[25], 8'b1010_0010      , syn_ac_1[ 6]);
    GFMULT gmult_154(data[26], 8'b1111_0000      , syn_ac_1[ 5]);
    GFMULT gmult_155(data[27], 8'b0001_0010      , syn_ac_1[ 4]);
    GFMULT gmult_156(data[28], 8'b0110_1011      , syn_ac_1[ 3]);
    GFMULT gmult_157(data[29], 8'b1010_1000      , syn_ac_1[ 2]);
    GFMULT gmult_158(data[30], 8'b1001_1011      , syn_ac_1[ 1]);
    GFMULT gmult_159(data[31], 8'b0001_1101      , syn_ac_1[ 0]);
//------------------------------------------------------------------------------------//
    GFMULT gmult_160(data[0 ], 8'b0111_1110      , syn_ac_0[31]);
    GFMULT gmult_161(data[1 ], 8'b1111_1111      , syn_ac_0[30]);
    GFMULT gmult_162(data[2 ], 8'b0101_1001      , syn_ac_0[29]);
    GFMULT gmult_163(data[3 ], 8'b0010_1001      , syn_ac_0[28]);
    GFMULT gmult_164(data[4 ], 8'b0000_0011      , syn_ac_0[27]);
    GFMULT gmult_165(data[5 ], 8'b0101_1101      , syn_ac_0[26]);
    GFMULT gmult_166(data[6 ], 8'b0010_0110      , syn_ac_0[25]);
    GFMULT gmult_167(data[7 ], 8'b0110_1101      , syn_ac_0[24]);
    GFMULT gmult_168(data[8 ], 8'b1110_0001      , syn_ac_0[23]);
    GFMULT gmult_169(data[9 ], 8'b1001_0011      , syn_ac_0[22]);
    GFMULT gmult_170(data[10], 8'b0001_1001      , syn_ac_0[21]);
    GFMULT gmult_171(data[11], 8'b0011_0110      , syn_ac_0[20]);
    GFMULT gmult_172(data[12], 8'b1110_0000      , syn_ac_0[19]);
    GFMULT gmult_173(data[13], 8'b1011_0011      , syn_ac_0[18]);
    GFMULT gmult_174(data[14], 8'b1111_1000      , syn_ac_0[17]);
    GFMULT gmult_175(data[15], 8'b0100_1011      , syn_ac_0[16]);
    GFMULT gmult_176(data[16], 8'b0000_1100      , syn_ac_0[15]);
    GFMULT gmult_177(data[17], 8'b0100_0110      , syn_ac_0[14]);
    GFMULT gmult_178(data[18], 8'b1011_1010      , syn_ac_0[13]);
    GFMULT gmult_179(data[19], 8'b0011_1111      , syn_ac_0[12]);
    GFMULT gmult_180(data[20], 8'b1000_1110      , syn_ac_0[11]);
    GFMULT gmult_181(data[21], 8'b0101_1111      , syn_ac_0[10]);
    GFMULT gmult_182(data[22], 8'b1111_0000      , syn_ac_0[ 9]);
    GFMULT gmult_183(data[23], 8'b0100_1111      , syn_ac_0[ 8]);
    GFMULT gmult_184(data[24], 8'b1011_1110      , syn_ac_0[ 7]);
    GFMULT gmult_185(data[25], 8'b1001_1100      , syn_ac_0[ 6]);
    GFMULT gmult_186(data[26], 8'b0101_0010      , syn_ac_0[ 5]);
    GFMULT gmult_187(data[27], 8'b0101_1010      , syn_ac_0[ 4]);
    GFMULT gmult_188(data[28], 8'b0000_1110      , syn_ac_0[ 3]);
    GFMULT gmult_189(data[29], 8'b0010_0100      , syn_ac_0[ 2]);
    GFMULT gmult_190(data[30], 8'b1111_0100      , syn_ac_0[ 1]);
    GFMULT gmult_191(data[31], 8'b1010_1010      , syn_ac_0[ 0]);

    assign parity[0] = syn_ac_0[31] ^ syn_ac_0[30] ^ syn_ac_0[29] ^ syn_ac_0[28] ^ syn_ac_0[27] ^ syn_ac_0[26] ^ syn_ac_0[25] ^ 
    syn_ac_0[24] ^ syn_ac_0[23] ^ syn_ac_0[22] ^ syn_ac_0[21] ^ syn_ac_0[20] ^ syn_ac_0[19] ^ syn_ac_0[18] ^ syn_ac_0[17] ^ 
    syn_ac_0[16] ^ syn_ac_0[15] ^ syn_ac_0[14] ^ syn_ac_0[13] ^ syn_ac_0[12] ^ syn_ac_0[11] ^ syn_ac_0[10] ^ syn_ac_0[9] ^ 
    syn_ac_0[8] ^ syn_ac_0[7] ^ syn_ac_0[6] ^ syn_ac_0[5] ^ syn_ac_0[4] ^ syn_ac_0[3] ^ syn_ac_0[2] ^ syn_ac_0[1] ^ syn_ac_0[0];

    assign parity[1] = syn_ac_1[31] ^ syn_ac_1[30] ^ syn_ac_1[29] ^ syn_ac_1[28] ^ syn_ac_1[27] ^ syn_ac_1[26] ^ syn_ac_1[25] ^ 
    syn_ac_1[24] ^ syn_ac_1[23] ^ syn_ac_1[22] ^ syn_ac_1[21] ^ syn_ac_1[20] ^ syn_ac_1[19] ^ syn_ac_1[18] ^ syn_ac_1[17] ^ 
    syn_ac_1[16] ^ syn_ac_1[15] ^ syn_ac_1[14] ^ syn_ac_1[13] ^ syn_ac_1[12] ^ syn_ac_1[11] ^ syn_ac_1[10] ^ syn_ac_1[9] ^ 
    syn_ac_1[8] ^ syn_ac_1[7] ^ syn_ac_1[6] ^ syn_ac_1[5] ^ syn_ac_1[4] ^ syn_ac_1[3] ^ syn_ac_1[2] ^ syn_ac_1[1] ^ syn_ac_1[0];

    assign parity[2] = syn_ac_2[31] ^ syn_ac_2[30] ^ syn_ac_2[29] ^ syn_ac_2[28] ^ syn_ac_2[27] ^ syn_ac_2[26] ^ syn_ac_2[25] ^ 
    syn_ac_2[24] ^ syn_ac_2[23] ^ syn_ac_2[22] ^ syn_ac_2[21] ^ syn_ac_2[20] ^ syn_ac_2[19] ^ syn_ac_2[18] ^ syn_ac_2[17] ^ 
    syn_ac_2[16] ^ syn_ac_2[15] ^ syn_ac_2[14] ^ syn_ac_2[13] ^ syn_ac_2[12] ^ syn_ac_2[11] ^ syn_ac_2[10] ^ syn_ac_2[9] ^ 
    syn_ac_2[8] ^ syn_ac_2[7] ^ syn_ac_2[6] ^ syn_ac_2[5] ^ syn_ac_2[4] ^ syn_ac_2[3] ^ syn_ac_2[2] ^ syn_ac_2[1] ^ syn_ac_2[0];

    assign parity[3] = syn_ac_3[31] ^ syn_ac_3[30] ^ syn_ac_3[29] ^ syn_ac_3[28] ^ syn_ac_3[27] ^ syn_ac_3[26] ^ syn_ac_3[25] ^ 
    syn_ac_3[24] ^ syn_ac_3[23] ^ syn_ac_3[22] ^ syn_ac_3[21] ^ syn_ac_3[20] ^ syn_ac_3[19] ^ syn_ac_3[18] ^ syn_ac_3[17] ^ 
    syn_ac_3[16] ^ syn_ac_3[15] ^ syn_ac_3[14] ^ syn_ac_3[13] ^ syn_ac_3[12] ^ syn_ac_3[11] ^ syn_ac_3[10] ^ syn_ac_3[9] ^ 
    syn_ac_3[8] ^ syn_ac_3[7] ^ syn_ac_3[6] ^ syn_ac_3[5] ^ syn_ac_3[4] ^ syn_ac_3[3] ^ syn_ac_3[2] ^ syn_ac_3[1] ^ syn_ac_3[0];

    assign parity[4] = syn_ac_4[31] ^ syn_ac_4[30] ^ syn_ac_4[29] ^ syn_ac_4[28] ^ syn_ac_4[27] ^ syn_ac_4[26] ^ syn_ac_4[25] ^ 
    syn_ac_4[24] ^ syn_ac_4[23] ^ syn_ac_4[22] ^ syn_ac_4[21] ^ syn_ac_4[20] ^ syn_ac_4[19] ^ syn_ac_4[18] ^ syn_ac_4[17] ^ 
    syn_ac_4[16] ^ syn_ac_4[15] ^ syn_ac_4[14] ^ syn_ac_4[13] ^ syn_ac_4[12] ^ syn_ac_4[11] ^ syn_ac_4[10] ^ syn_ac_4[9] ^ 
    syn_ac_4[8] ^ syn_ac_4[7] ^ syn_ac_4[6] ^ syn_ac_4[5] ^ syn_ac_4[4] ^ syn_ac_4[3] ^ syn_ac_4[2] ^ syn_ac_4[1] ^ syn_ac_4[0];

    assign parity[5] = syn_ac_5[31] ^ syn_ac_5[30] ^ syn_ac_5[29] ^ syn_ac_5[28] ^ syn_ac_5[27] ^ syn_ac_5[26] ^ syn_ac_5[25] ^ 
    syn_ac_5[24] ^ syn_ac_5[23] ^ syn_ac_5[22] ^ syn_ac_5[21] ^ syn_ac_5[20] ^ syn_ac_5[19] ^ syn_ac_5[18] ^ syn_ac_5[17] ^ 
    syn_ac_5[16] ^ syn_ac_5[15] ^ syn_ac_5[14] ^ syn_ac_5[13] ^ syn_ac_5[12] ^ syn_ac_5[11] ^ syn_ac_5[10] ^ syn_ac_5[9] ^ 
    syn_ac_5[8] ^ syn_ac_5[7] ^ syn_ac_5[6] ^ syn_ac_5[5] ^ syn_ac_5[4] ^ syn_ac_5[3] ^ syn_ac_5[2] ^ syn_ac_5[1] ^ syn_ac_5[0];

    assign codeword[37:6] = data[31:0];
    assign codeword[5:0]  = parity[5:0];
endmodule