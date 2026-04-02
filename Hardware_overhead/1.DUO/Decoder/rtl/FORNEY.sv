module FORNEY(
    input  [7:0] lambda[3:0],   // λ0, λ1, λ2, λ3
    input  [7:0] omega [2:0],   // ω0, ω1, ω2
    output [7:0] magnitude[37:0]
);

    // Triple-symbol-correction Forney
    // E_i = X_i^{-1} * Ω(X_i) / Λ'(X_i), X_i = α^i
    // Ω(X_i)   = ω0 + ω1*X_i + ω2*X_i^2
    // Λ'(X_i)  = λ1 + λ3*X_i^2    (characteristic-2 derivative)

    wire [7:0] table_x   [37:0];
    wire [7:0] table_x2  [37:0];
    wire [7:0] table_inv [37:0];

    wire [7:0] omega_v [37:0];
    wire [7:0] lambda_v[37:0];
    wire [7:0] div_v   [37:0];
    wire [7:0] imm_0   [37:0];
    wire [7:0] imm_1   [37:0];
    wire [7:0] imm_2   [37:0];

    assign table_x[0]   = 8'd1;   // α^0
    assign table_x2[0]  = 8'd1;   // α^0
    assign table_inv[0] = 8'd1;   // α^(-0)
    assign table_x[1]   = 8'd2;   // α^1
    assign table_x2[1]  = 8'd4;   // α^2
    assign table_inv[1] = 8'd175;   // α^(-1)
    assign table_x[2]   = 8'd4;   // α^2
    assign table_x2[2]  = 8'd16;   // α^4
    assign table_inv[2] = 8'd248;   // α^(-2)
    assign table_x[3]   = 8'd8;   // α^3
    assign table_x2[3]  = 8'd64;   // α^6
    assign table_inv[3] = 8'd124;   // α^(-3)
    assign table_x[4]   = 8'd16;   // α^4
    assign table_x2[4]  = 8'd95;   // α^8
    assign table_inv[4] = 8'd62;   // α^(-4)
    assign table_x[5]   = 8'd32;   // α^5
    assign table_x2[5]  = 8'd35;   // α^10
    assign table_inv[5] = 8'd31;   // α^(-5)
    assign table_x[6]   = 8'd64;   // α^6
    assign table_x2[6]  = 8'd140;   // α^12
    assign table_inv[6] = 8'd160;   // α^(-6)
    assign table_x[7]   = 8'd128;   // α^7
    assign table_x2[7]  = 8'd142;   // α^14
    assign table_inv[7] = 8'd80;   // α^(-7)
    assign table_x[8]   = 8'd95;   // α^8
    assign table_x2[8]  = 8'd134;   // α^16
    assign table_inv[8] = 8'd40;   // α^(-8)
    assign table_x[9]   = 8'd190;   // α^9
    assign table_x2[9]  = 8'd166;   // α^18
    assign table_inv[9] = 8'd20;   // α^(-9)
    assign table_x[10]   = 8'd35;   // α^10
    assign table_x2[10]  = 8'd38;   // α^20
    assign table_inv[10] = 8'd10;   // α^(-10)
    assign table_x[11]   = 8'd70;   // α^11
    assign table_x2[11]  = 8'd152;   // α^22
    assign table_inv[11] = 8'd5;   // α^(-11)
    assign table_x[12]   = 8'd140;   // α^12
    assign table_x2[12]  = 8'd222;   // α^24
    assign table_inv[12] = 8'd173;   // α^(-12)
    assign table_x[13]   = 8'd71;   // α^13
    assign table_x2[13]  = 8'd153;   // α^26
    assign table_inv[13] = 8'd249;   // α^(-13)
    assign table_x[14]   = 8'd142;   // α^14
    assign table_x2[14]  = 8'd218;   // α^28
    assign table_inv[14] = 8'd211;   // α^(-14)
    assign table_x[15]   = 8'd67;   // α^15
    assign table_x2[15]  = 8'd137;   // α^30
    assign table_inv[15] = 8'd198;   // α^(-15)
    assign table_x[16]   = 8'd134;   // α^16
    assign table_x2[16]  = 8'd154;   // α^32
    assign table_inv[16] = 8'd99;   // α^(-16)
    assign table_x[17]   = 8'd83;   // α^17
    assign table_x2[17]  = 8'd214;   // α^34
    assign table_inv[17] = 8'd158;   // α^(-17)
    assign table_x[18]   = 8'd166;   // α^18
    assign table_x2[18]  = 8'd185;   // α^36
    assign table_inv[18] = 8'd79;   // α^(-18)
    assign table_x[19]   = 8'd19;   // α^19
    assign table_x2[19]  = 8'd90;   // α^38
    assign table_inv[19] = 8'd136;   // α^(-19)
    assign table_x[20]   = 8'd38;   // α^20
    assign table_x2[20]  = 8'd55;   // α^40
    assign table_inv[20] = 8'd68;   // α^(-20)
    assign table_x[21]   = 8'd76;   // α^21
    assign table_x2[21]  = 8'd220;   // α^42
    assign table_inv[21] = 8'd34;   // α^(-21)
    assign table_x[22]   = 8'd152;   // α^22
    assign table_x2[22]  = 8'd145;   // α^44
    assign table_inv[22] = 8'd17;   // α^(-22)
    assign table_x[23]   = 8'd111;   // α^23
    assign table_x2[23]  = 8'd250;   // α^46
    assign table_inv[23] = 8'd167;   // α^(-23)
    assign table_x[24]   = 8'd222;   // α^24
    assign table_x2[24]  = 8'd9;   // α^48
    assign table_inv[24] = 8'd252;   // α^(-24)
    assign table_x[25]   = 8'd227;   // α^25
    assign table_x2[25]  = 8'd36;   // α^50
    assign table_inv[25] = 8'd126;   // α^(-25)
    assign table_x[26]   = 8'd153;   // α^26
    assign table_x2[26]  = 8'd144;   // α^52
    assign table_inv[26] = 8'd63;   // α^(-26)
    assign table_x[27]   = 8'd109;   // α^27
    assign table_x2[27]  = 8'd254;   // α^54
    assign table_inv[27] = 8'd176;   // α^(-27)
    assign table_x[28]   = 8'd218;   // α^28
    assign table_x2[28]  = 8'd25;   // α^56
    assign table_inv[28] = 8'd88;   // α^(-28)
    assign table_x[29]   = 8'd235;   // α^29
    assign table_x2[29]  = 8'd100;   // α^58
    assign table_inv[29] = 8'd44;   // α^(-29)
    assign table_x[30]   = 8'd137;   // α^30
    assign table_x2[30]  = 8'd207;   // α^60
    assign table_inv[30] = 8'd22;   // α^(-30)
    assign table_x[31]   = 8'd77;   // α^31
    assign table_x2[31]  = 8'd221;   // α^62
    assign table_inv[31] = 8'd11;   // α^(-31)
    assign table_x[32]   = 8'd154;   // α^32
    assign table_x2[32]  = 8'd149;   // α^64
    assign table_inv[32] = 8'd170;   // α^(-32)
    assign table_x[33]   = 8'd107;   // α^33
    assign table_x2[33]  = 8'd234;   // α^66
    assign table_inv[33] = 8'd85;   // α^(-33)
    assign table_x[34]   = 8'd214;   // α^34
    assign table_x2[34]  = 8'd73;   // α^68
    assign table_inv[34] = 8'd133;   // α^(-34)
    assign table_x[35]   = 8'd243;   // α^35
    assign table_x2[35]  = 8'd123;   // α^70
    assign table_inv[35] = 8'd237;   // α^(-35)
    assign table_x[36]   = 8'd185;   // α^36
    assign table_x2[36]  = 8'd179;   // α^72
    assign table_inv[36] = 8'd217;   // α^(-36)
    assign table_x[37]   = 8'd45;   // α^37
    assign table_x2[37]  = 8'd114;   // α^74
    assign table_inv[37] = 8'd195;   // α^(-37)

    genvar gi;
    generate
        for (gi = 0; gi < 38; gi = gi + 1) begin : FORNEY_GEN
            GFMULT gmult_w1 (omega[1],  table_x[gi],  imm_0[gi]);
            GFMULT gmult_w2 (omega[2],  table_x2[gi], imm_1[gi]);
            assign omega_v[gi] = omega[0] ^ imm_0[gi] ^ imm_1[gi];

            GFMULT gmult_l3 (lambda[3], table_x2[gi], imm_2[gi]);
            assign lambda_v[gi] = lambda[1] ^ imm_2[gi];

            GFDIV gdiv_i (omega_v[gi], lambda_v[gi], div_v[gi]);
            GFMULT gmult_out (div_v[gi], table_inv[gi], magnitude[gi]);
        end
    endgenerate

endmodule