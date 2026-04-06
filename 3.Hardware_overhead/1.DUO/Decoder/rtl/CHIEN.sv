module CHIEN(
    input  [7:0] lambda[3:0],
    output [37:0] locator
);

    // Triple-symbol-correction locator search
    // Evaluate Λ(X_i) = λ0 + λ1*X_i + λ2*X_i^2 + λ3*X_i^3, X_i = α^i

    wire [7:0] x1 [37:0];
    wire [7:0] x2 [37:0];
    wire [7:0] x3 [37:0];
    wire [7:0] imm_1[37:0];
    wire [7:0] imm_2[37:0];
    wire [7:0] imm_3[37:0];

    assign x1[0] = 8'd1;   // α^0
    assign x2[0] = 8'd1;   // α^0
    assign x3[0] = 8'd1;   // α^0
    assign x1[1] = 8'd2;   // α^1
    assign x2[1] = 8'd4;   // α^2
    assign x3[1] = 8'd8;   // α^3
    assign x1[2] = 8'd4;   // α^2
    assign x2[2] = 8'd16;   // α^4
    assign x3[2] = 8'd64;   // α^6
    assign x1[3] = 8'd8;   // α^3
    assign x2[3] = 8'd64;   // α^6
    assign x3[3] = 8'd190;   // α^9
    assign x1[4] = 8'd16;   // α^4
    assign x2[4] = 8'd95;   // α^8
    assign x3[4] = 8'd140;   // α^12
    assign x1[5] = 8'd32;   // α^5
    assign x2[5] = 8'd35;   // α^10
    assign x3[5] = 8'd67;   // α^15
    assign x1[6] = 8'd64;   // α^6
    assign x2[6] = 8'd140;   // α^12
    assign x3[6] = 8'd166;   // α^18
    assign x1[7] = 8'd128;   // α^7
    assign x2[7] = 8'd142;   // α^14
    assign x3[7] = 8'd76;   // α^21
    assign x1[8] = 8'd95;   // α^8
    assign x2[8] = 8'd134;   // α^16
    assign x3[8] = 8'd222;   // α^24
    assign x1[9] = 8'd190;   // α^9
    assign x2[9] = 8'd166;   // α^18
    assign x3[9] = 8'd109;   // α^27
    assign x1[10] = 8'd35;   // α^10
    assign x2[10] = 8'd38;   // α^20
    assign x3[10] = 8'd137;   // α^30
    assign x1[11] = 8'd70;   // α^11
    assign x2[11] = 8'd152;   // α^22
    assign x3[11] = 8'd107;   // α^33
    assign x1[12] = 8'd140;   // α^12
    assign x2[12] = 8'd222;   // α^24
    assign x3[12] = 8'd185;   // α^36
    assign x1[13] = 8'd71;   // α^13
    assign x2[13] = 8'd153;   // α^26
    assign x3[13] = 8'd180;   // α^39
    assign x1[14] = 8'd142;   // α^14
    assign x2[14] = 8'd218;   // α^28
    assign x3[14] = 8'd220;   // α^42
    assign x1[15] = 8'd67;   // α^15
    assign x2[15] = 8'd137;   // α^30
    assign x3[15] = 8'd125;   // α^45
    assign x1[16] = 8'd134;   // α^16
    assign x2[16] = 8'd154;   // α^32
    assign x3[16] = 8'd9;   // α^48
    assign x1[17] = 8'd83;   // α^17
    assign x2[17] = 8'd214;   // α^34
    assign x3[17] = 8'd72;   // α^51
    assign x1[18] = 8'd166;   // α^18
    assign x2[18] = 8'd185;   // α^36
    assign x3[18] = 8'd254;   // α^54
    assign x1[19] = 8'd19;   // α^19
    assign x2[19] = 8'd90;   // α^38
    assign x3[19] = 8'd50;   // α^57
    assign x1[20] = 8'd38;   // α^20
    assign x2[20] = 8'd55;   // α^40
    assign x3[20] = 8'd207;   // α^60
    assign x1[21] = 8'd76;   // α^21
    assign x2[21] = 8'd220;   // α^42
    assign x3[21] = 8'd229;   // α^63
    assign x1[22] = 8'd152;   // α^22
    assign x2[22] = 8'd145;   // α^44
    assign x3[22] = 8'd234;   // α^66
    assign x1[23] = 8'd111;   // α^23
    assign x2[23] = 8'd250;   // α^46
    assign x3[23] = 8'd146;   // α^69
    assign x1[24] = 8'd222;   // α^24
    assign x2[24] = 8'd9;   // α^48
    assign x3[24] = 8'd179;   // α^72
    assign x1[25] = 8'd227;   // α^25
    assign x2[25] = 8'd36;   // α^50
    assign x3[25] = 8'd228;   // α^75
    assign x1[26] = 8'd153;   // α^26
    assign x2[26] = 8'd144;   // α^52
    assign x3[26] = 8'd226;   // α^78
    assign x1[27] = 8'd109;   // α^27
    assign x2[27] = 8'd254;   // α^54
    assign x3[27] = 8'd210;   // α^81
    assign x1[28] = 8'd218;   // α^28
    assign x2[28] = 8'd25;   // α^56
    assign x3[28] = 8'd13;   // α^84
    assign x1[29] = 8'd235;   // α^29
    assign x2[29] = 8'd100;   // α^58
    assign x3[29] = 8'd104;   // α^87
    assign x1[30] = 8'd137;   // α^30
    assign x2[30] = 8'd207;   // α^60
    assign x3[30] = 8'd161;   // α^90
    assign x1[31] = 8'd77;   // α^31
    assign x2[31] = 8'd221;   // α^62
    assign x3[31] = 8'd116;   // α^93
    assign x1[32] = 8'd154;   // α^32
    assign x2[32] = 8'd149;   // α^64
    assign x3[32] = 8'd65;   // α^96
    assign x1[33] = 8'd107;   // α^33
    assign x2[33] = 8'd234;   // α^66
    assign x3[33] = 8'd182;   // α^99
    assign x1[34] = 8'd214;   // α^34
    assign x2[34] = 8'd73;   // α^68
    assign x3[34] = 8'd204;   // α^102
    assign x1[35] = 8'd243;   // α^35
    assign x2[35] = 8'd123;   // α^70
    assign x3[35] = 8'd253;   // α^105
    assign x1[36] = 8'd185;   // α^36
    assign x2[36] = 8'd179;   // α^72
    assign x3[36] = 8'd42;   // α^108
    assign x1[37] = 8'd45;   // α^37
    assign x2[37] = 8'd114;   // α^74
    assign x3[37] = 8'd15;   // α^111

    genvar gi;
    generate
        for (gi = 0; gi < 38; gi = gi + 1) begin : CHIEN_GEN
            GFMULT gmult_l1(lambda[1], x1[gi], imm_1[gi]);
            GFMULT gmult_l2(lambda[2], x2[gi], imm_2[gi]);
            GFMULT gmult_l3(lambda[3], x3[gi], imm_3[gi]);
            assign locator[gi] = ((lambda[0] ^ imm_1[gi] ^ imm_2[gi] ^ imm_3[gi]) == 8'h00);
        end
    endgenerate

endmodule