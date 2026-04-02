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

    genvar g;
    generate
        for (g = 0; g < N_SYM; g = g + 1) begin : GEN_SYMBOLS
            assign sym_word[g] = codeword_in[287 - (g*16) -: 16];
        end
    endgenerate

    // GF syndromes and t=1 RiBM outputs.
    logic [15:0] syndrome0_gf;
    logic [15:0] syndrome1_gf;
    logic [15:0] lambda0_ribm;
    logic [15:0] lambda1_ribm;

    // Chien search and selected location / magnitude.
    logic [17:0] chien_hit;
    logic [4:0]  hit_index;
    logic [4:0]  hit_count;
    logic        chien_onehot;
    logic [15:0] err_symbol;

    // Corrected codeword candidate.
    logic [287:0] codeword_next;

    function automatic logic [15:0] gf_mul16(
        input logic [15:0] a,
        input logic [15:0] b
    );
        logic [15:0] aa;
        logic [15:0] bb;
        logic [15:0] prod;
        begin
            aa   = a;
            bb   = b;
            prod = 16'h0000;

            for (int k = 0; k < 16; k++) begin
                if (bb[0]) begin
                    prod = prod ^ aa;
                end

                bb = bb >> 1;

                if (aa[15]) begin
                    aa = (aa << 1) ^ GF_REDUCE;
                end else begin
                    aa = (aa << 1);
                end
            end

            gf_mul16 = prod;
        end
    endfunction

    // -------------------------------------------------------------------------
    // 1) GF syndrome generation
    // -------------------------------------------------------------------------
    always_comb begin
        syndrome0_gf = 16'h0000;
        syndrome1_gf = 16'h0000;

        for (int j = 0; j < N_SYM; j++) begin
            if (sym_word[j] != 16'h0000) begin
                syndrome0_gf = syndrome0_gf ^ gf_mul16(sym_word[j], COEFF_A[j]);
                syndrome1_gf = syndrome1_gf ^ gf_mul16(sym_word[j], COEFF_B[j]);
            end
        end
    end

    // -------------------------------------------------------------------------
    // 2) t=1 RiBM
    //    For t=1 the locator is directly Lambda(x) = S1 + S0*x.
    // -------------------------------------------------------------------------
    assign lambda0_ribm = syndrome1_gf;
    assign lambda1_ribm = syndrome0_gf;

    // -------------------------------------------------------------------------
    // 3) Chien search over 18 symbol locations
    // -------------------------------------------------------------------------
    always_comb begin
        chien_hit  = '0;
        hit_index  = 5'd0;
        hit_count  = 5'd0;

        if ((lambda0_ribm != 16'h0000) && (lambda1_ribm != 16'h0000)) begin
            for (int j = 0; j < N_SYM; j++) begin
                chien_hit[j] = ((lambda0_ribm ^ gf_mul16(lambda1_ribm, CHIEN_X[j])) == 16'h0000);
                if (chien_hit[j]) begin
                    hit_index = j[4:0];
                    hit_count = hit_count + 5'd1;
                end
            end
        end
    end

    assign chien_onehot = (hit_count == 5'd1);

    // -------------------------------------------------------------------------
    // 4) Error magnitude: e = S0 / A_j = S0 * A_j^(-1)
    // -------------------------------------------------------------------------
    always_comb begin
        if (chien_onehot) begin
            err_symbol = gf_mul16(lambda1_ribm, COEFF_A_INV[hit_index]);
        end else begin
            err_symbol = 16'h0000;
        end
    end
    // -------------------------------------------------------------------------
    // Final correction / output selection
    // -------------------------------------------------------------------------
    always_comb begin
        codeword_next      = codeword_in;
        decode_result_out  = 1'b1; 

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
