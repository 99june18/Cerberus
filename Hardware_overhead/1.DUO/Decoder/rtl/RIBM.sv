module RIBM(
    input  [7:0] syndrome [5:0],
    output [7:0] lambda[3:0],
    output [7:0] omega [2:0]
);

    // Triple-symbol-correction inversionless BM / RiBM
    //
    // State length = omega(3) + lambda(4) + 6 shifts + 1 extra = 11
    //
    // Final extraction:
    //   omega  = delta_6[0:2]
    //   lambda = delta_6[3:6]

    wire [7:0] delta_0[10:0];
    wire [7:0] delta_1[10:0];
    wire [7:0] delta_2[10:0];
    wire [7:0] delta_3[10:0];
    wire [7:0] delta_4[10:0];
    wire [7:0] delta_5[10:0];
    wire [7:0] delta_6[10:0];

    wire [7:0] theta_0[10:0];
    wire [7:0] theta_1[10:0];
    wire [7:0] theta_2[10:0];
    wire [7:0] theta_3[10:0];
    wire [7:0] theta_4[10:0];
    wire [7:0] theta_5[10:0];
    wire [7:0] theta_6[10:0];

    wire [4:0] k_0;
    wire [4:0] k_1;
    wire [4:0] k_2;
    wire [4:0] k_3;
    wire [4:0] k_4;
    wire [4:0] k_5;
    wire [4:0] k_6;

    wire [7:0] gamma_0;
    wire [7:0] gamma_1;
    wire [7:0] gamma_2;
    wire [7:0] gamma_3;
    wire [7:0] gamma_4;
    wire [7:0] gamma_5;
    wire [7:0] gamma_6;

    wire cond_0;
    wire cond_1;
    wire cond_2;
    wire cond_3;
    wire cond_4;
    wire cond_5;

    // Initialization
    assign delta_0[0] = syndrome[0];
    assign delta_0[1] = syndrome[1];
    assign delta_0[2] = syndrome[2];
    assign delta_0[3] = syndrome[3];
    assign delta_0[4] = syndrome[4];
    assign delta_0[5] = syndrome[5];
    assign delta_0[6] = 8'h00;
    assign delta_0[7] = 8'h00;
    assign delta_0[8] = 8'h00;
    assign delta_0[9]  = 8'h01;
    assign delta_0[10] = 8'h00;

    assign theta_0[0] = syndrome[0];
    assign theta_0[1] = syndrome[1];
    assign theta_0[2] = syndrome[2];
    assign theta_0[3] = syndrome[3];
    assign theta_0[4] = syndrome[4];
    assign theta_0[5] = syndrome[5];
    assign theta_0[6] = 8'h00;
    assign theta_0[7] = 8'h00;
    assign theta_0[8] = 8'h00;
    assign theta_0[9]  = 8'h01;
    assign theta_0[10] = 8'h00;

    assign k_0     = 5'd8;
    assign gamma_0 = 8'h01;

    assign delta_1[10] = 8'h00;
    assign theta_1[10] = 8'h00;
    assign delta_2[10] = 8'h00;
    assign theta_2[10] = 8'h00;
    assign delta_3[10] = 8'h00;
    assign theta_3[10] = 8'h00;
    assign delta_4[10] = 8'h00;
    assign theta_4[10] = 8'h00;
    assign delta_5[10] = 8'h00;
    assign theta_5[10] = 8'h00;
    assign delta_6[10] = 8'h00;
    assign theta_6[10] = 8'h00;

    // -------------------------
    // Stage 0: r = 0, r+1 = 1
    // -------------------------
    wire [7:0] imm_0_0[9:0];
    wire [7:0] imm_1_0[9:0];
    genvar g_0;
    generate
        for (g_0 = 0; g_0 < 10; g_0 = g_0 + 1) begin : RIBM_STAGE_0
            GFMULT mul_g (gamma_0, delta_0[g_0+1], imm_0_0[g_0]);
            GFMULT mul_t (delta_0[0], theta_0[g_0],   imm_1_0[g_0]);
            assign delta_1[g_0] = imm_0_0[g_0] ^ imm_1_0[g_0];
            assign theta_1[g_0] = cond_0 ? delta_0[g_0+1] : theta_0[g_0];
        end
    endgenerate

    assign cond_0  = (delta_0[0] != 8'h00) && (k_0[3] == 1'b1);
    assign gamma_1 = cond_0 ? delta_0[0] : gamma_0;
    assign k_1     = cond_0 ? ~k_0       : (k_0 + 5'd1);

    // -------------------------
    // Stage 1: r = 1, r+1 = 2
    // -------------------------
    wire [7:0] imm_0_1[9:0];
    wire [7:0] imm_1_1[9:0];
    genvar g_1;
    generate
        for (g_1 = 0; g_1 < 10; g_1 = g_1 + 1) begin : RIBM_STAGE_1
            GFMULT mul_g (gamma_1, delta_1[g_1+1], imm_0_1[g_1]);
            GFMULT mul_t (delta_1[0], theta_1[g_1],   imm_1_1[g_1]);
            assign delta_2[g_1] = imm_0_1[g_1] ^ imm_1_1[g_1];
            assign theta_2[g_1] = cond_1 ? delta_1[g_1+1] : theta_1[g_1];
        end
    endgenerate

    assign cond_1  = (delta_1[0] != 8'h00) && (k_1[3] == 1'b1);
    assign gamma_2 = cond_1 ? delta_1[0] : gamma_1;
    assign k_2     = cond_1 ? ~k_1       : (k_1 + 5'd1);

    // -------------------------
    // Stage 2: r = 2, r+1 = 3
    // -------------------------
    wire [7:0] imm_0_2[9:0];
    wire [7:0] imm_1_2[9:0];
    genvar g_2;
    generate
        for (g_2 = 0; g_2 < 10; g_2 = g_2 + 1) begin : RIBM_STAGE_2
            GFMULT mul_g (gamma_2, delta_2[g_2+1], imm_0_2[g_2]);
            GFMULT mul_t (delta_2[0], theta_2[g_2],   imm_1_2[g_2]);
            assign delta_3[g_2] = imm_0_2[g_2] ^ imm_1_2[g_2];
            assign theta_3[g_2] = cond_2 ? delta_2[g_2+1] : theta_2[g_2];
        end
    endgenerate

    assign cond_2  = (delta_2[0] != 8'h00) && (k_2[3] == 1'b1);
    assign gamma_3 = cond_2 ? delta_2[0] : gamma_2;
    assign k_3     = cond_2 ? ~k_2       : (k_2 + 5'd1);

    // -------------------------
    // Stage 3: r = 3, r+1 = 4
    // -------------------------
    wire [7:0] imm_0_3[9:0];
    wire [7:0] imm_1_3[9:0];
    genvar g_3;
    generate
        for (g_3 = 0; g_3 < 10; g_3 = g_3 + 1) begin : RIBM_STAGE_3
            GFMULT mul_g (gamma_3, delta_3[g_3+1], imm_0_3[g_3]);
            GFMULT mul_t (delta_3[0], theta_3[g_3],   imm_1_3[g_3]);
            assign delta_4[g_3] = imm_0_3[g_3] ^ imm_1_3[g_3];
            assign theta_4[g_3] = cond_3 ? delta_3[g_3+1] : theta_3[g_3];
        end
    endgenerate

    assign cond_3  = (delta_3[0] != 8'h00) && (k_3[3] == 1'b1);
    assign gamma_4 = cond_3 ? delta_3[0] : gamma_3;
    assign k_4     = cond_3 ? ~k_3       : (k_3 + 5'd1);

    // -------------------------
    // Stage 4: r = 4, r+1 = 5
    // -------------------------
    wire [7:0] imm_0_4[9:0];
    wire [7:0] imm_1_4[9:0];
    genvar g_4;
    generate
        for (g_4 = 0; g_4 < 10; g_4 = g_4 + 1) begin : RIBM_STAGE_4
            GFMULT mul_g (gamma_4, delta_4[g_4+1], imm_0_4[g_4]);
            GFMULT mul_t (delta_4[0], theta_4[g_4],   imm_1_4[g_4]);
            assign delta_5[g_4] = imm_0_4[g_4] ^ imm_1_4[g_4];
            assign theta_5[g_4] = cond_4 ? delta_4[g_4+1] : theta_4[g_4];
        end
    endgenerate

    assign cond_4  = (delta_4[0] != 8'h00) && (k_4[3] == 1'b1);
    assign gamma_5 = cond_4 ? delta_4[0] : gamma_4;
    assign k_5     = cond_4 ? ~k_4       : (k_4 + 5'd1);

    // -------------------------
    // Stage 5: r = 5, r+1 = 6
    // -------------------------
    wire [7:0] imm_0_5[9:0];
    wire [7:0] imm_1_5[9:0];
    genvar g_5;
    generate
        for (g_5 = 0; g_5 < 10; g_5 = g_5 + 1) begin : RIBM_STAGE_5
            GFMULT mul_g (gamma_5, delta_5[g_5+1], imm_0_5[g_5]);
            GFMULT mul_t (delta_5[0], theta_5[g_5],   imm_1_5[g_5]);
            assign delta_6[g_5] = imm_0_5[g_5] ^ imm_1_5[g_5];
            assign theta_6[g_5] = cond_5 ? delta_5[g_5+1] : theta_5[g_5];
        end
    endgenerate

    assign cond_5  = (delta_5[0] != 8'h00) && (k_5[3] == 1'b1);
    assign gamma_6 = cond_5 ? delta_5[0] : gamma_5;
    assign k_6     = cond_5 ? ~k_5       : (k_5 + 5'd1);

    assign omega[0] = delta_6[0];
    assign omega[1] = delta_6[1];
    assign omega[2] = delta_6[2];

    assign lambda[0] = delta_6[3];
    assign lambda[1] = delta_6[4];
    assign lambda[2] = delta_6[5];
    assign lambda[3] = delta_6[6];

endmodule