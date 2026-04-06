module SYNDROME_GENERATOR(
    input [7:0] data[31:0],
    input [7:0] parity[5:0], 
    output [7:0] syn[5:0]
);

    wire [7:0] syn_ac_5[37:0];
    wire [7:0] syn_ac_4[37:0];
    wire [7:0] syn_ac_3[37:0];
    wire [7:0] syn_ac_2[37:0];
    wire [7:0] syn_ac_1[37:0];
    wire [7:0] syn_ac_0[37:0];


    GFMULT gmult_00(data[0]     ,8'b0000_0001       ,syn_ac_5[37]);         // a^0
    GFMULT gmult_01(data[1]     ,8'b0000_0010       ,syn_ac_5[36]);         // a^1
    GFMULT gmult_02(data[2]     ,8'b0000_0100       ,syn_ac_5[35]);         // a^2
    GFMULT gmult_03(data[3]     ,8'b0000_1000       ,syn_ac_5[34]);         // a^3
    GFMULT gmult_04(data[4]     ,8'b0001_0000       ,syn_ac_5[33]);         // a^4
    GFMULT gmult_05(data[5]     ,8'b0010_0000       ,syn_ac_5[32]);         // a^5
    GFMULT gmult_06(data[6]     ,8'b0100_0000       ,syn_ac_5[31]);         // a^6
    GFMULT gmult_07(data[7]     ,8'b1000_0000       ,syn_ac_5[30]);         // a^7
    GFMULT gmult_08(data[8]     ,8'b0101_1111       ,syn_ac_5[29]);         // a^8
    GFMULT gmult_09(data[9]     ,8'b1011_1110       ,syn_ac_5[28]);         // a^9
    GFMULT gmult_10(data[10]    ,8'b0010_0011       ,syn_ac_5[27]);         // a^10
    GFMULT gmult_11(data[11]    ,8'b0100_0110       ,syn_ac_5[26]);         // a^11
    GFMULT gmult_12(data[12]    ,8'b1000_1100       ,syn_ac_5[25]);         // a^12
    GFMULT gmult_13(data[13]    ,8'b0100_0111       ,syn_ac_5[24]);         // a^13
    GFMULT gmult_14(data[14]    ,8'b1000_1110       ,syn_ac_5[23]);         // a^14
    GFMULT gmult_15(data[15]    ,8'b0100_0011       ,syn_ac_5[22]);         // a^15
    GFMULT gmult_16(data[16]    ,8'b1000_0110       ,syn_ac_5[21]);         // a^16
    GFMULT gmult_17(data[17]    ,8'b0101_0011       ,syn_ac_5[20]);         // a^17
    GFMULT gmult_18(data[18]    ,8'b1010_0110       ,syn_ac_5[19]);         // a^18
    GFMULT gmult_19(data[19]    ,8'b0001_0011       ,syn_ac_5[18]);         // a^19
    GFMULT gmult_20(data[20]    ,8'b0010_0110       ,syn_ac_5[17]);         // a^20
    GFMULT gmult_21(data[21]    ,8'b0100_1100       ,syn_ac_5[16]);         // a^21
    GFMULT gmult_22(data[22]    ,8'b1001_1000       ,syn_ac_5[15]);         // a^22
    GFMULT gmult_23(data[23]    ,8'b0110_1111       ,syn_ac_5[14]);         // a^23
    GFMULT gmult_24(data[24]    ,8'b1101_1110       ,syn_ac_5[13]);         // a^24
    GFMULT gmult_25(data[25]    ,8'b1110_0011       ,syn_ac_5[12]);         // a^25
    GFMULT gmult_26(data[26]    ,8'b1001_1001       ,syn_ac_5[11]);         // a^26
    GFMULT gmult_27(data[27]    ,8'b0110_1101       ,syn_ac_5[10]);         // a^27
    GFMULT gmult_28(data[28]    ,8'b1101_1010       ,syn_ac_5[9]);          // a^28
    GFMULT gmult_29(data[29]    ,8'b1110_1011       ,syn_ac_5[8]);          // a^29
    GFMULT gmult_30(data[30]    ,8'b1000_1001       ,syn_ac_5[7]);          // a^30
    GFMULT gmult_31(data[31]    ,8'b0100_1101       ,syn_ac_5[6]);          // a^31
    GFMULT gmult_32(parity[0]   ,8'b1001_1010       ,syn_ac_5[5]);          // a^32
    GFMULT gmult_33(parity[1]   ,8'b0110_1011       ,syn_ac_5[4]);          // a^33
    GFMULT gmult_34(parity[2]   ,8'b1101_0110       ,syn_ac_5[3]);          // a^34
    GFMULT gmult_35(parity[3]   ,8'b1111_0011       ,syn_ac_5[2]);          // a^35
    GFMULT gmult_36(parity[4]   ,8'b1011_1001       ,syn_ac_5[1]);          // a^36
    GFMULT gmult_37(parity[5]   ,8'b0010_1101       ,syn_ac_5[0]);          // a^37
//------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------//
    GFMULT gmult_38(data[0]     ,8'b0000_0001       ,syn_ac_4[37]);         // a^0
    GFMULT gmult_39(data[1]     ,8'b0000_0100       ,syn_ac_4[36]);         // a^2
    GFMULT gmult_40(data[2]     ,8'b0001_0000       ,syn_ac_4[35]);         // a^4
    GFMULT gmult_41(data[3]     ,8'b0100_0000       ,syn_ac_4[34]);         // a^6
    GFMULT gmult_42(data[4]     ,8'b0101_1111       ,syn_ac_4[33]);         // a^8
    GFMULT gmult_43(data[5]     ,8'b0010_0011       ,syn_ac_4[32]);         // a^10
    GFMULT gmult_44(data[6]     ,8'b1000_1100       ,syn_ac_4[31]);         // a^12
    GFMULT gmult_45(data[7]     ,8'b1000_1110       ,syn_ac_4[30]);         // a^14
    GFMULT gmult_46(data[8]     ,8'b1000_0110       ,syn_ac_4[29]);         // a^16
    GFMULT gmult_47(data[9]     ,8'b1010_0110       ,syn_ac_4[28]);         // a^18
    GFMULT gmult_48(data[10]    ,8'b0010_0110       ,syn_ac_4[27]);         // a^20
    GFMULT gmult_49(data[11]    ,8'b1001_1000       ,syn_ac_4[26]);         // a^22
    GFMULT gmult_50(data[12]    ,8'b1101_1110       ,syn_ac_4[25]);         // a^24
    GFMULT gmult_51(data[13]    ,8'b1001_1001       ,syn_ac_4[24]);         // a^26
    GFMULT gmult_52(data[14]    ,8'b1101_1010       ,syn_ac_4[23]);         // a^28
    GFMULT gmult_53(data[15]    ,8'b1000_1001       ,syn_ac_4[22]);         // a^30
    GFMULT gmult_54(data[16]    ,8'b1001_1010       ,syn_ac_4[21]);         // a^32
    GFMULT gmult_55(data[17]    ,8'b1101_0110       ,syn_ac_4[20]);         // a^34
    GFMULT gmult_56(data[18]    ,8'b1011_1001       ,syn_ac_4[19]);         // a^36
    GFMULT gmult_57(data[19]    ,8'b0101_1010       ,syn_ac_4[18]);         // a^38
    GFMULT gmult_58(data[20]    ,8'b0011_0111       ,syn_ac_4[17]);         // a^40
    GFMULT gmult_59(data[21]    ,8'b1101_1100       ,syn_ac_4[16]);         // a^42
    GFMULT gmult_60(data[22]    ,8'b1001_0001       ,syn_ac_4[15]);         // a^44
    GFMULT gmult_61(data[23]    ,8'b1111_1010       ,syn_ac_4[14]);         // a^46
    GFMULT gmult_62(data[24]    ,8'b0000_1001       ,syn_ac_4[13]);         // a^48
    GFMULT gmult_63(data[25]    ,8'b0010_0100       ,syn_ac_4[12]);         // a^50
    GFMULT gmult_64(data[26]    ,8'b1001_0000       ,syn_ac_4[11]);         // a^52
    GFMULT gmult_65(data[27]    ,8'b1111_1110       ,syn_ac_4[10]);         // a^54
    GFMULT gmult_66(data[28]    ,8'b0001_1001       ,syn_ac_4[9]);          // a^56
    GFMULT gmult_67(data[29]    ,8'b0110_0100       ,syn_ac_4[8]);          // a^58
    GFMULT gmult_68(data[30]    ,8'b1100_1111       ,syn_ac_4[7]);          // a^60
    GFMULT gmult_69(data[31]    ,8'b1101_1101       ,syn_ac_4[6]);          // a^62
    GFMULT gmult_70(parity[0]   ,8'b1001_0101       ,syn_ac_4[5]);          // a^64
    GFMULT gmult_71(parity[1]   ,8'b1110_1010       ,syn_ac_4[4]);          // a^66
    GFMULT gmult_72(parity[2]   ,8'b0100_1001       ,syn_ac_4[3]);          // a^68
    GFMULT gmult_73(parity[3]   ,8'b0111_1011       ,syn_ac_4[2]);          // a^70
    GFMULT gmult_74(parity[4]   ,8'b1011_0011       ,syn_ac_4[1]);          // a^72
    GFMULT gmult_75(parity[5]   ,8'b0111_0010       ,syn_ac_4[0]);          // a^74
//------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------//
    GFMULT gmult_76(data[0]     ,8'b0000_0001       ,syn_ac_3[37]);         // a^0
    GFMULT gmult_77(data[1]     ,8'b0000_1000       ,syn_ac_3[36]);         // a^3
    GFMULT gmult_78(data[2]     ,8'b0100_0000       ,syn_ac_3[35]);         // a^6
    GFMULT gmult_79(data[3]     ,8'b1011_1110       ,syn_ac_3[34]);         // a^9
    GFMULT gmult_80(data[4]     ,8'b1000_1100       ,syn_ac_3[33]);         // a^12
    GFMULT gmult_81(data[5]     ,8'b0100_0011       ,syn_ac_3[32]);         // a^15
    GFMULT gmult_82(data[6]     ,8'b1010_0110       ,syn_ac_3[31]);         // a^18
    GFMULT gmult_83(data[7]     ,8'b0100_1100       ,syn_ac_3[30]);         // a^21
    GFMULT gmult_84(data[8]     ,8'b1101_1110       ,syn_ac_3[29]);         // a^24
    GFMULT gmult_85(data[9]     ,8'b0110_1101       ,syn_ac_3[28]);         // a^27
    GFMULT gmult_86(data[10]    ,8'b1000_1001       ,syn_ac_3[27]);         // a^30
    GFMULT gmult_87(data[11]    ,8'b0110_1011       ,syn_ac_3[26]);         // a^33
    GFMULT gmult_88(data[12]    ,8'b1011_1001       ,syn_ac_3[25]);         // a^36
    GFMULT gmult_89(data[13]    ,8'b1011_0100       ,syn_ac_3[24]);         // a^39
    GFMULT gmult_90(data[14]    ,8'b1101_1100       ,syn_ac_3[23]);         // a^42
    GFMULT gmult_91(data[15]    ,8'b0111_1101       ,syn_ac_3[22]);         // a^45
    GFMULT gmult_92(data[16]    ,8'b0000_1001       ,syn_ac_3[21]);         // a^48
    GFMULT gmult_93(data[17]    ,8'b0100_1000       ,syn_ac_3[20]);         // a^51
    GFMULT gmult_94(data[18]    ,8'b1111_1110       ,syn_ac_3[19]);         // a^54
    GFMULT gmult_95(data[19]    ,8'b0011_0010       ,syn_ac_3[18]);         // a^57
    GFMULT gmult_96(data[20]    ,8'b1100_1111       ,syn_ac_3[17]);         // a^60
    GFMULT gmult_97(data[21]    ,8'b1110_0101       ,syn_ac_3[16]);         // a^63
    GFMULT gmult_98(data[22]    ,8'b1110_1010       ,syn_ac_3[15]);         // a^66
    GFMULT gmult_99(data[23]    ,8'b1001_0010       ,syn_ac_3[14]);         // a^69
    GFMULT gmult_100(data[24]   ,8'b1011_0011       ,syn_ac_3[13]);         // a^72
    GFMULT gmult_101(data[25]   ,8'b1110_0100       ,syn_ac_3[12]);         // a^75
    GFMULT gmult_102(data[26]   ,8'b1110_0010       ,syn_ac_3[11]);         // a^78
    GFMULT gmult_103(data[27]   ,8'b1101_0010       ,syn_ac_3[10]);         // a^81
    GFMULT gmult_104(data[28]   ,8'b0000_1101       ,syn_ac_3[9]);          // a^84
    GFMULT gmult_105(data[29]   ,8'b0110_1000       ,syn_ac_3[8]);          // a^87
    GFMULT gmult_106(data[30]   ,8'b1010_0001       ,syn_ac_3[7]);          // a^90
    GFMULT gmult_107(data[31]   ,8'b0111_0100       ,syn_ac_3[6]);          // a^93
    GFMULT gmult_108(parity[0]  ,8'b0100_0001       ,syn_ac_3[5]);          // a^96
    GFMULT gmult_109(parity[1]  ,8'b1011_0110       ,syn_ac_3[4]);          // a^99
    GFMULT gmult_110(parity[2]  ,8'b1100_1100       ,syn_ac_3[3]);          // a^102
    GFMULT gmult_111(parity[3]  ,8'b1111_1101       ,syn_ac_3[2]);          // a^105
    GFMULT gmult_112(parity[4]  ,8'b0010_1010       ,syn_ac_3[1]);          // a^108
    GFMULT gmult_113(parity[5]  ,8'b0000_1111       ,syn_ac_3[0]);          // a^111
//------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------//
    GFMULT gmult_114(data[0]     ,8'b0000_0001       ,syn_ac_2[37]);         // a^0
    GFMULT gmult_115(data[1]     ,8'b0001_0000       ,syn_ac_2[36]);         // a^4
    GFMULT gmult_116(data[2]     ,8'b0101_1111       ,syn_ac_2[35]);         // a^8
    GFMULT gmult_117(data[3]     ,8'b1000_1100       ,syn_ac_2[34]);         // a^12
    GFMULT gmult_118(data[4]     ,8'b1000_0110       ,syn_ac_2[33]);         // a^16
    GFMULT gmult_119(data[5]     ,8'b0010_0110       ,syn_ac_2[32]);         // a^20
    GFMULT gmult_120(data[6]     ,8'b1101_1110       ,syn_ac_2[31]);         // a^24
    GFMULT gmult_121(data[7]     ,8'b1101_1010       ,syn_ac_2[30]);         // a^28
    GFMULT gmult_122(data[8]     ,8'b1001_1010       ,syn_ac_2[29]);         // a^32
    GFMULT gmult_123(data[9]     ,8'b1011_1001       ,syn_ac_2[28]);         // a^36
    GFMULT gmult_124(data[10]    ,8'b0011_0111       ,syn_ac_2[27]);         // a^40
    GFMULT gmult_125(data[11]    ,8'b1001_0001       ,syn_ac_2[26]);         // a^44
    GFMULT gmult_126(data[12]    ,8'b0000_1001       ,syn_ac_2[25]);         // a^48
    GFMULT gmult_127(data[13]    ,8'b1001_0000       ,syn_ac_2[24]);         // a^52
    GFMULT gmult_128(data[14]    ,8'b0001_1001       ,syn_ac_2[23]);         // a^56
    GFMULT gmult_129(data[15]    ,8'b1100_1111       ,syn_ac_2[22]);         // a^60
    GFMULT gmult_130(data[16]    ,8'b1001_0101       ,syn_ac_2[21]);         // a^64
    GFMULT gmult_131(data[17]    ,8'b0100_1001       ,syn_ac_2[20]);         // a^68
    GFMULT gmult_132(data[18]    ,8'b1011_0011       ,syn_ac_2[19]);         // a^72
    GFMULT gmult_133(data[19]    ,8'b1001_0111       ,syn_ac_2[18]);         // a^76
    GFMULT gmult_134(data[20]    ,8'b0110_1001       ,syn_ac_2[17]);         // a^80
    GFMULT gmult_135(data[21]    ,8'b0000_1101       ,syn_ac_2[16]);         // a^84
    GFMULT gmult_136(data[22]    ,8'b1101_0000       ,syn_ac_2[15]);         // a^88
    GFMULT gmult_137(data[23]    ,8'b0011_1010       ,syn_ac_2[14]);         // a^92
    GFMULT gmult_138(data[24]    ,8'b0100_0001       ,syn_ac_2[13]);         // a^96
    GFMULT gmult_139(data[25]    ,8'b0011_0011       ,syn_ac_2[12]);         // a^100
    GFMULT gmult_140(data[26]    ,8'b1101_0001       ,syn_ac_2[11]);         // a^104
    GFMULT gmult_141(data[27]    ,8'b0010_1010       ,syn_ac_2[10]);         // a^108
    GFMULT gmult_142(data[28]    ,8'b0001_1110       ,syn_ac_2[9]);          // a^112
    GFMULT gmult_143(data[29]    ,8'b1011_1111       ,syn_ac_2[8]);          // a^116
    GFMULT gmult_144(data[30]    ,8'b0101_0111       ,syn_ac_2[7]);          // a^120
    GFMULT gmult_145(data[31]    ,8'b0000_1100       ,syn_ac_2[6]);          // a^124
    GFMULT gmult_146(parity[0]   ,8'b1100_0000       ,syn_ac_2[5]);          // a^128
    GFMULT gmult_147(parity[1]   ,8'b0110_0101       ,syn_ac_2[4]);          // a^132
    GFMULT gmult_148(parity[2]   ,8'b1100_1101       ,syn_ac_2[3]);          // a^136
    GFMULT gmult_149(parity[3]   ,8'b1011_0101       ,syn_ac_2[2]);          // a^140
    GFMULT gmult_150(parity[4]   ,8'b1111_0111       ,syn_ac_2[1]);          // a^144
    GFMULT gmult_151(parity[5]   ,8'b1111_0100       ,syn_ac_2[0]);          // a^148
//------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------//
    GFMULT gmult_152(data[0]     ,8'b0000_0001      ,syn_ac_0[37]);         // a^0
    GFMULT gmult_153(data[1]     ,8'b0100_0000      ,syn_ac_0[36]);         // a^6
    GFMULT gmult_154(data[2]     ,8'b1000_1100      ,syn_ac_0[35]);         // a^12
    GFMULT gmult_155(data[3]     ,8'b1010_0110      ,syn_ac_0[34]);         // a^18
    GFMULT gmult_156(data[4]     ,8'b1101_1110      ,syn_ac_0[33]);         // a^24
    GFMULT gmult_157(data[5]     ,8'b1000_1001      ,syn_ac_0[32]);         // a^30
    GFMULT gmult_158(data[6]     ,8'b1011_1001      ,syn_ac_0[31]);         // a^36
    GFMULT gmult_159(data[7]     ,8'b1101_1100      ,syn_ac_0[30]);         // a^42
    GFMULT gmult_160(data[8]     ,8'b0000_1001      ,syn_ac_0[29]);         // a^48
    GFMULT gmult_161(data[9]     ,8'b1111_1110      ,syn_ac_0[28]);         // a^54
    GFMULT gmult_162(data[10]    ,8'b1100_1111      ,syn_ac_0[27]);         // a^60
    GFMULT gmult_163(data[11]    ,8'b1110_1010      ,syn_ac_0[26]);         // a^66
    GFMULT gmult_164(data[12]    ,8'b1011_0011      ,syn_ac_0[25]);         // a^72
    GFMULT gmult_165(data[13]    ,8'b1110_0010      ,syn_ac_0[24]);         // a^78
    GFMULT gmult_166(data[14]    ,8'b0000_1101      ,syn_ac_0[23]);         // a^84
    GFMULT gmult_167(data[15]    ,8'b1010_0001      ,syn_ac_0[22]);         // a^90
    GFMULT gmult_168(data[16]    ,8'b0100_0001      ,syn_ac_0[21]);         // a^96
    GFMULT gmult_169(data[17]    ,8'b1100_1100      ,syn_ac_0[20]);         // a^102
    GFMULT gmult_170(data[18]    ,8'b0010_1010      ,syn_ac_0[19]);         // a^108
    GFMULT gmult_171(data[19]    ,8'b0111_1000      ,syn_ac_0[18]);         // a^114
    GFMULT gmult_172(data[20]    ,8'b0101_0111      ,syn_ac_0[17]);         // a^120
    GFMULT gmult_173(data[21]    ,8'b0011_0000      ,syn_ac_0[16]);         // a^126
    GFMULT gmult_174(data[22]    ,8'b0110_0101      ,syn_ac_0[15]);         // a^132
    GFMULT gmult_175(data[23]    ,8'b1101_0101      ,syn_ac_0[14]);         // a^138
    GFMULT gmult_176(data[24]    ,8'b1111_0111      ,syn_ac_0[13]);         // a^144
    GFMULT gmult_177(data[25]    ,8'b0011_0001      ,syn_ac_0[12]);         // a^150
    GFMULT gmult_178(data[26]    ,8'b0010_0101      ,syn_ac_0[11]);         // a^156
    GFMULT gmult_179(data[27]    ,8'b0101_1001      ,syn_ac_0[10]);         // a^162
    GFMULT gmult_180(data[28]    ,8'b0101_0001      ,syn_ac_0[9]);          // a^168
    GFMULT gmult_181(data[29]    ,8'b1110_1111      ,syn_ac_0[8]);          // a^174
    GFMULT gmult_182(data[30]    ,8'b1010_1100      ,syn_ac_0[7]);          // a^180
    GFMULT gmult_183(data[31]    ,8'b1110_0000      ,syn_ac_0[6]);          // a^186
    GFMULT gmult_184(parity[0]   ,8'b1000_1101      ,syn_ac_0[5]);          // a^192
    GFMULT gmult_185(parity[1]   ,8'b1110_0110      ,syn_ac_0[4]);          // a^198
    GFMULT gmult_186(parity[2]   ,8'b0101_0010      ,syn_ac_0[3]);          // a^204
    GFMULT gmult_187(parity[3]   ,8'b0010_1111      ,syn_ac_0[2]);          // a^210
    GFMULT gmult_188(parity[4]   ,8'b0110_0111      ,syn_ac_0[1]);          // a^216
    GFMULT gmult_189(parity[5]   ,8'b0101_0101      ,syn_ac_0[0]);          // a^222
//------------------------------------------------------------------------------------//
//------------------------------------------------------------------------------------//
    GFMULT gmult_190(data[0]     ,8'b0000_0001      ,syn_ac_1[37]);         // a^0
    GFMULT gmult_191(data[1]     ,8'b0010_0000      ,syn_ac_1[36]);         // a^5
    GFMULT gmult_192(data[2]     ,8'b0010_0011      ,syn_ac_1[35]);         // a^10
    GFMULT gmult_193(data[3]     ,8'b0100_0011      ,syn_ac_1[34]);         // a^15
    GFMULT gmult_194(data[4]     ,8'b0010_0110      ,syn_ac_1[33]);         // a^20
    GFMULT gmult_195(data[5]     ,8'b1110_0011      ,syn_ac_1[32]);         // a^25
    GFMULT gmult_196(data[6]     ,8'b1000_1001      ,syn_ac_1[31]);         // a^30
    GFMULT gmult_197(data[7]     ,8'b1111_0011      ,syn_ac_1[30]);         // a^35
    GFMULT gmult_198(data[8]     ,8'b0011_0111      ,syn_ac_1[29]);         // a^40
    GFMULT gmult_199(data[9]     ,8'b0111_1101      ,syn_ac_1[28]);         // a^45
    GFMULT gmult_200(data[10]    ,8'b0010_0100      ,syn_ac_1[27]);         // a^50
    GFMULT gmult_201(data[11]    ,8'b1010_0011      ,syn_ac_1[26]);         // a^55
    GFMULT gmult_202(data[12]    ,8'b1100_1111      ,syn_ac_1[25]);         // a^60
    GFMULT gmult_203(data[13]    ,8'b0111_0101      ,syn_ac_1[24]);         // a^65
    GFMULT gmult_204(data[14]    ,8'b0111_1011      ,syn_ac_1[23]);         // a^70
    GFMULT gmult_205(data[15]    ,8'b1110_0100      ,syn_ac_1[22]);         // a^75
    GFMULT gmult_206(data[16]    ,8'b0110_1001      ,syn_ac_1[21]);         // a^80
    GFMULT gmult_207(data[17]    ,8'b0001_1010      ,syn_ac_1[20]);         // a^85
    GFMULT gmult_208(data[18]    ,8'b1010_0001      ,syn_ac_1[19]);         // a^90
    GFMULT gmult_209(data[19]    ,8'b1000_1111      ,syn_ac_1[18]);         // a^95
    GFMULT gmult_210(data[20]    ,8'b0011_0011      ,syn_ac_1[17]);         // a^100
    GFMULT gmult_211(data[21]    ,8'b1111_1101      ,syn_ac_1[16]);         // a^105
    GFMULT gmult_212(data[22]    ,8'b1010_1000      ,syn_ac_1[15]);         // a^110
    GFMULT gmult_213(data[23]    ,8'b1111_0000      ,syn_ac_1[14]);         // a^115
    GFMULT gmult_214(data[24]    ,8'b0101_0111      ,syn_ac_1[13]);         // a^120
    GFMULT gmult_215(data[25]    ,8'b0001_1000      ,syn_ac_1[12]);         // a^125
    GFMULT gmult_216(data[26]    ,8'b1110_0001      ,syn_ac_1[11]);         // a^130
    GFMULT gmult_217(data[27]    ,8'b1100_1001      ,syn_ac_1[10]);         // a^135
    GFMULT gmult_218(data[28]    ,8'b1011_0101      ,syn_ac_1[9]);          // a^140
    GFMULT gmult_219(data[29]    ,8'b1011_0001      ,syn_ac_1[8]);          // a^145
    GFMULT gmult_220(data[30]    ,8'b0011_0001      ,syn_ac_1[7]);          // a^150
    GFMULT gmult_221(data[31]    ,8'b1011_1101      ,syn_ac_1[6]);          // a^155
    GFMULT gmult_222(parity[0]   ,8'b1110_1110      ,syn_ac_1[5]);          // a^160
    GFMULT gmult_223(parity[1]   ,8'b0111_0110      ,syn_ac_1[4]);          // a^165
    GFMULT gmult_224(parity[2]   ,8'b0001_1011      ,syn_ac_1[3]);          // a^170
    GFMULT gmult_225(parity[3]   ,8'b1000_0001      ,syn_ac_1[2]);          // a^175
    GFMULT gmult_226(parity[4]   ,8'b1010_1100      ,syn_ac_1[1]);          // a^180
    GFMULT gmult_227(parity[5]   ,8'b0111_0000      ,syn_ac_1[0]);          // a^185

    
    assign syn[0] = syn_ac_0[37] ^ syn_ac_0[36] ^ syn_ac_0[35] ^ syn_ac_0[34] ^ syn_ac_0[33] ^ syn_ac_0[32] ^ 
    syn_ac_0[31] ^ syn_ac_0[30] ^ syn_ac_0[29] ^ syn_ac_0[28] ^ syn_ac_0[27] ^ 
    syn_ac_0[26] ^ syn_ac_0[25] ^ syn_ac_0[24] ^ syn_ac_0[23] ^ syn_ac_0[22] ^ syn_ac_0[21] ^ syn_ac_0[20] ^ 
    syn_ac_0[19] ^ syn_ac_0[18] ^ syn_ac_0[17] ^ syn_ac_0[16]^ syn_ac_0[15] ^ syn_ac_0[14] ^ syn_ac_0[13] ^ 
    syn_ac_0[12] ^ syn_ac_0[11] ^ syn_ac_0[10] ^ syn_ac_0[9] ^ syn_ac_0[8] ^ syn_ac_0[7] ^ syn_ac_0[6] ^ 
    syn_ac_0[5] ^ syn_ac_0[4] ^ syn_ac_0[3] ^ syn_ac_0[2] ^ syn_ac_0[1] ^ syn_ac_0[0];

    assign syn[1] = syn_ac_1[37] ^ syn_ac_1[36] ^ syn_ac_1[35] ^ syn_ac_1[34] ^ syn_ac_1[33] ^ syn_ac_1[32] ^ 
    syn_ac_1[31] ^ syn_ac_1[30] ^ syn_ac_1[29] ^ syn_ac_1[28] ^ syn_ac_1[27] ^ 
    syn_ac_1[26] ^ syn_ac_1[25] ^ syn_ac_1[24] ^ syn_ac_1[23] ^ syn_ac_1[22] ^ syn_ac_1[21] ^ syn_ac_1[20] ^ 
    syn_ac_1[19] ^ syn_ac_1[18] ^ syn_ac_1[17] ^ syn_ac_1[16]^ syn_ac_1[15] ^ syn_ac_1[14] ^ syn_ac_1[13] ^ 
    syn_ac_1[12] ^ syn_ac_1[11] ^ syn_ac_1[10] ^ syn_ac_1[9] ^ syn_ac_1[8] ^ syn_ac_1[7] ^ syn_ac_1[6] ^ 
    syn_ac_1[5] ^ syn_ac_1[4] ^ syn_ac_1[3] ^ syn_ac_1[2] ^ syn_ac_1[1] ^ syn_ac_1[0];

    assign syn[2] = syn_ac_2[37] ^ syn_ac_2[36] ^ syn_ac_2[35] ^ syn_ac_2[34] ^ syn_ac_2[33] ^ syn_ac_2[32] ^ 
    syn_ac_2[31] ^ syn_ac_2[30] ^ syn_ac_2[29] ^ syn_ac_2[28] ^ syn_ac_2[27] ^ 
    syn_ac_2[26] ^ syn_ac_2[25] ^ syn_ac_2[24] ^ syn_ac_2[23] ^ syn_ac_2[22] ^ syn_ac_2[21] ^ syn_ac_2[20] ^ 
    syn_ac_2[19] ^ syn_ac_2[18] ^ syn_ac_2[17] ^ syn_ac_2[16]^ syn_ac_2[15] ^ syn_ac_2[14] ^ syn_ac_2[13] ^ 
    syn_ac_2[12] ^ syn_ac_2[11] ^ syn_ac_2[10] ^ syn_ac_2[9] ^ syn_ac_2[8] ^ syn_ac_2[7] ^ syn_ac_2[6] ^ 
    syn_ac_2[5] ^ syn_ac_2[4] ^ syn_ac_2[3] ^ syn_ac_2[2] ^ syn_ac_2[1] ^ syn_ac_2[0];

    assign syn[3] = syn_ac_3[37] ^ syn_ac_3[36] ^ syn_ac_3[35] ^ syn_ac_3[34] ^ syn_ac_3[33] ^ syn_ac_3[32] ^ 
    syn_ac_3[31] ^ syn_ac_3[30] ^ syn_ac_3[29] ^ syn_ac_3[28] ^ syn_ac_3[27] ^ 
    syn_ac_3[26] ^ syn_ac_3[25] ^ syn_ac_3[24] ^ syn_ac_3[23] ^ syn_ac_3[22] ^ syn_ac_3[21] ^ syn_ac_3[20] ^ 
    syn_ac_3[19] ^ syn_ac_3[18] ^ syn_ac_3[17] ^ syn_ac_3[16]^ syn_ac_3[15] ^ syn_ac_3[14] ^ syn_ac_3[13] ^ 
    syn_ac_3[12] ^ syn_ac_3[11] ^ syn_ac_3[10] ^ syn_ac_3[9] ^ syn_ac_3[8] ^ syn_ac_3[7] ^ syn_ac_3[6] ^ 
    syn_ac_3[5] ^ syn_ac_3[4] ^ syn_ac_3[3] ^ syn_ac_3[2] ^ syn_ac_3[1] ^ syn_ac_3[0];

    assign syn[4] = syn_ac_4[37] ^ syn_ac_4[36] ^ syn_ac_4[35] ^ syn_ac_4[34] ^ syn_ac_4[33] ^ syn_ac_4[32] ^ 
    syn_ac_4[31] ^ syn_ac_4[30] ^ syn_ac_4[29] ^ syn_ac_4[28] ^ syn_ac_4[27] ^ 
    syn_ac_4[26] ^ syn_ac_4[25] ^ syn_ac_4[24] ^ syn_ac_4[23] ^ syn_ac_4[22] ^ syn_ac_4[21] ^ syn_ac_4[20] ^ 
    syn_ac_4[19] ^ syn_ac_4[18] ^ syn_ac_4[17] ^ syn_ac_4[16]^ syn_ac_4[15] ^ syn_ac_4[14] ^ syn_ac_4[13] ^ 
    syn_ac_4[12] ^ syn_ac_4[11] ^ syn_ac_4[10] ^ syn_ac_4[9] ^ syn_ac_4[8] ^ syn_ac_4[7] ^ syn_ac_4[6] ^ 
    syn_ac_4[5] ^ syn_ac_4[4] ^ syn_ac_4[3] ^ syn_ac_4[2] ^ syn_ac_4[1] ^ syn_ac_4[0];

    assign syn[5] = syn_ac_5[37] ^ syn_ac_5[36] ^ syn_ac_5[35] ^ syn_ac_5[34] ^ syn_ac_5[33] ^ syn_ac_5[32] ^ 
    syn_ac_5[31] ^ syn_ac_5[30] ^ syn_ac_5[29] ^ syn_ac_5[28] ^ syn_ac_5[27] ^ 
    syn_ac_5[26] ^ syn_ac_5[25] ^ syn_ac_5[24] ^ syn_ac_5[23] ^ syn_ac_5[22] ^ syn_ac_5[21] ^ syn_ac_5[20] ^ 
    syn_ac_5[19] ^ syn_ac_5[18] ^ syn_ac_5[17] ^ syn_ac_5[16]^ syn_ac_5[15] ^ syn_ac_5[14] ^ syn_ac_5[13] ^ 
    syn_ac_5[12] ^ syn_ac_5[11] ^ syn_ac_5[10] ^ syn_ac_5[9] ^ syn_ac_5[8] ^ syn_ac_5[7] ^ syn_ac_5[6] ^ 
    syn_ac_5[5] ^ syn_ac_5[4] ^ syn_ac_5[3] ^ syn_ac_5[2] ^ syn_ac_5[1] ^ syn_ac_5[0];

endmodule