module SSE_CORRECTOR (
    input  logic [287:0] codeword_in,
    input  logic [31:0]  syndrome_in,
    output logic         decode_result_out,
    output logic [255:0] data_out
);
    localparam int N_SYM = 18;
    // GF(2^16) primitive polynomial
    localparam logic [15:0] GF_REDUCE = 16'h100B;

    // GF(2^16) symbol-level parity-check coefficients
    localparam logic [15:0] COEFF_A     [0:N_SYM-1] = '{16'h00A2, 16'h3B00, 16'h1A2E, 16'hEC53, 16'hB530, 16'hD292, 16'h08B8, 16'h5031, 16'h7FE2, 16'h7897, 16'h469C, 16'h528E, 16'hE56F, 16'h1C22, 16'hCCA8, 16'h0163, 16'h2BFE, 16'h2E9B};
    localparam logic [15:0] COEFF_B     [0:N_SYM-1] = '{16'hBC0B, 16'hE956, 16'hA06A, 16'h0CE0, 16'hB33C, 16'h4291, 16'hA0AC, 16'h4A64, 16'h5949, 16'hFD7D, 16'h9813, 16'h9394, 16'h5094, 16'h4739, 16'h1A06, 16'h0FAB, 16'h8204, 16'hCA42};
    localparam logic [15:0] COEFF_A_INV [0:N_SYM-1] = '{16'h3B5A, 16'h93C4, 16'h0996, 16'h14D5, 16'h5689, 16'hBBE5, 16'h0DC3, 16'h91B6, 16'h965C, 16'h477B, 16'h026A, 16'hA6C3, 16'h3FF7, 16'h06F8, 16'hD54E, 16'h8C4B, 16'hF92A, 16'h6115};
    localparam logic [15:0] CHIEN_X     [0:N_SYM-1] = '{16'hAB96, 16'h9045, 16'hEB3C, 16'h4FC1, 16'h7503, 16'hF266, 16'h10E0, 16'h9B96, 16'hD3D1, 16'h79E2, 16'hCBA5, 16'hFF4F, 16'h08C1, 16'h36CF, 16'h2B67, 16'h7400, 16'h59AD, 16'hB3C6};

    // Split 288-bit codeword into 18 GF(2^16) symbols.
    logic [15:0] sym_word [0:N_SYM-1];

    logic [15:0] sym_pow     [0:N_SYM-1][0:15];
    logic [15:0] lambda1_pow [0:15];

    // Per-symbol contributions to the two GF syndromes.
    logic [15:0] synd0_term [0:N_SYM-1];
    logic [15:0] synd1_term [0:N_SYM-1];

    // Per-location Chien evaluation term: lambda1 * X_j
    logic [15:0] chien_term [0:N_SYM-1];

    // GF syndromes and t=1 RiBM outputs.
    logic [15:0] syndrome0_gf;
    logic [15:0] syndrome1_gf;
    logic [15:0] lambda0_ribm;
    logic [15:0] lambda1_ribm;

    // Chien search and selected location / magnitude.
    logic [4:0]  hit_index;
    logic        found_hit;
    logic        multi_hit;
    logic        chien_onehot;
    logic [15:0] coeff_inv_sel;
    logic [15:0] err_symbol;

    // Corrected codeword candidate.
    logic [287:0] codeword_next;

    function automatic logic [15:0] gf_xtime16(
        input logic [15:0] a
    );
        begin
            if (a[15]) begin
                gf_xtime16 = (a << 1) ^ GF_REDUCE;
            end else begin
                gf_xtime16 = (a << 1);
            end
        end
    endfunction

    genvar g;
    generate
        for (g = 0; g < N_SYM; g = g + 1) begin : GEN_SYMBOLS
            assign sym_word[g] = codeword_in[287 - (g*16) -: 16];
        end
    endgenerate

    always_comb begin
        for (int j = 0; j < N_SYM; j++) begin
            sym_pow[j][0] = sym_word[j];
            for (int k = 1; k < 16; k++) begin
                sym_pow[j][k] = gf_xtime16(sym_pow[j][k-1]);
            end
        end
    end

    always_comb begin
        syndrome0_gf = 16'h0000;
        syndrome1_gf = 16'h0000;

        for (int j = 0; j < N_SYM; j++) begin
            synd0_term[j] = 16'h0000;
            synd1_term[j] = 16'h0000;

            for (int k = 0; k < 16; k++) begin
                if (COEFF_A[j][k]) synd0_term[j] = synd0_term[j] ^ sym_pow[j][k];
                if (COEFF_B[j][k]) synd1_term[j] = synd1_term[j] ^ sym_pow[j][k];
            end

            syndrome0_gf = syndrome0_gf ^ synd0_term[j];
            syndrome1_gf = syndrome1_gf ^ synd1_term[j];
        end
    end

    // -------------------------------------------------------------------------
    // 1) t=1 RiBM
    //    For t=1 the locator is directly Lambda(x) = S1 + S0*x.
    // -------------------------------------------------------------------------
    assign lambda0_ribm = syndrome1_gf;
    assign lambda1_ribm = syndrome0_gf;

    always_comb begin
        lambda1_pow[0] = lambda1_ribm;
        for (int k = 1; k < 16; k++) begin
            lambda1_pow[k] = gf_xtime16(lambda1_pow[k-1]);
        end
    end

    // -------------------------------------------------------------------------
    // 2) Chien search over 18 symbol locations
    // -------------------------------------------------------------------------
    always_comb begin
        for (int j = 0; j < N_SYM; j++) begin
            chien_term[j] = 16'h0000;
            for (int k = 0; k < 16; k++) begin
                if (CHIEN_X[j][k]) chien_term[j] = chien_term[j] ^ lambda1_pow[k];
            end
        end
    end

    always_comb begin
        hit_index = 5'd0;
        found_hit = 1'b0;
        multi_hit = 1'b0;

        if ((lambda0_ribm != 16'h0000) && (lambda1_ribm != 16'h0000)) begin
            for (int j = 0; j < N_SYM; j++) begin
                if ((lambda0_ribm ^ chien_term[j]) == 16'h0000) begin
                    if (!found_hit) begin
                        found_hit = 1'b1;
                        hit_index = j[4:0];
                    end else begin
                        multi_hit = 1'b1;
                    end
                end
            end
        end
    end

    assign chien_onehot = found_hit & ~multi_hit;

    // -------------------------------------------------------------------------
    // 3) Error magnitude: e = S0 / A_j = S0 * A_j^(-1)
    // -------------------------------------------------------------------------
    always_comb begin
        coeff_inv_sel = 16'h0000;
        unique case (hit_index)
            5'd0: coeff_inv_sel = 16'h3B5A;
            5'd1: coeff_inv_sel = 16'h93C4;
            5'd2: coeff_inv_sel = 16'h0996;
            5'd3: coeff_inv_sel = 16'h14D5;
            5'd4: coeff_inv_sel = 16'h5689;
            5'd5: coeff_inv_sel = 16'hBBE5;
            5'd6: coeff_inv_sel = 16'h0DC3;
            5'd7: coeff_inv_sel = 16'h91B6;
            5'd8: coeff_inv_sel = 16'h965C;
            5'd9: coeff_inv_sel = 16'h477B;
            5'd10: coeff_inv_sel = 16'h026A;
            5'd11: coeff_inv_sel = 16'hA6C3;
            5'd12: coeff_inv_sel = 16'h3FF7;
            5'd13: coeff_inv_sel = 16'h06F8;
            5'd14: coeff_inv_sel = 16'hD54E;
            5'd15: coeff_inv_sel = 16'h8C4B;
            5'd16: coeff_inv_sel = 16'hF92A;
            5'd17: coeff_inv_sel = 16'h6115;
            default: coeff_inv_sel = 16'h0000;
        endcase
    end

    always_comb begin
        err_symbol = 16'h0000;
        if (chien_onehot) begin
            for (int k = 0; k < 16; k++) begin
                if (coeff_inv_sel[k]) err_symbol = err_symbol ^ lambda1_pow[k];
            end
        end
    end

    // -------------------------------------------------------------------------
    // Final correction / output selection
    // -------------------------------------------------------------------------
    always_comb begin
        codeword_next     = codeword_in;
        decode_result_out = 1'b1;

        if (syndrome_in == 32'h0000) begin
            decode_result_out = 1'b0;
        end else if (chien_onehot && (err_symbol != 16'h0000)) begin
            codeword_next[287 - (hit_index*16) -: 16] =
                codeword_in[287 - (hit_index*16) -: 16] ^ err_symbol;
            decode_result_out = 1'b0;
        end else begin
            decode_result_out = 1'b1;
        end
    end

    assign data_out = codeword_next[287:32];

endmodule
