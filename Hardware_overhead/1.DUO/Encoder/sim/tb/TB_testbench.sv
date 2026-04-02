`timescale 1ns/1ps

module TB_encoder;

  logic [7:0] data[31:0];
  logic [7:0] parity[5:0];
  logic [7:0] codeword[37:0];
  logic [7:0] syn[5:0];

  integer i;

  ENCODER dut (
    .data(data),
    .parity(parity),
    .codeword(codeword)
  );

  SYNDROME_GENERATOR sg (
    .data(data),
    .parity(parity),
    .syn(syn)
  );

  task clear_data;
    begin
      for (i = 0; i < 32; i = i + 1)
        data[i] = 8'h00;
    end
  endtask

  task check_zero_syndrome(input string tag);
    integer k;
    integer err;
    begin
      #1;
      err = 0;
      for (k = 0; k < 6; k = k + 1) begin
        if (syn[k] !== 8'h00) err = err + 1;
      end

      if (err == 0) begin
        $display("[PASS] %s", tag);
      end
      else begin
        $display("[FAIL] %s (nonzero syndromes=%0d)", tag, err);
        for (k = 0; k < 6; k = k + 1) begin
          if (syn[k] !== 8'h00)
            $display("  syn[%0d] = 0x%02h", k, syn[k]);
        end
      end
    end
  endtask

  initial begin
    $display("== TB_encoder: RS(38,32), 8b, t=3 ==");

    // --- all zero ---
    clear_data();
    check_zero_syndrome("all zero");

    // --- single nonzero symbol ---
    clear_data();
    data[5] = 8'hA6;
    check_zero_syndrome("single symbol @5");

    // --- multiple nonzero symbols ---
    clear_data();
    data[0]  = 8'h1F;
    data[17] = 8'h55;
    data[31] = 8'hE1;
    check_zero_syndrome("3 symbols @(0,17,31)");

    // --- deterministic pattern ---
    clear_data();
    for (i = 0; i < 32; i = i + 1)
      data[i] = i[7:0] ^ 8'h5A;
    check_zero_syndrome("deterministic pattern");

    $finish;
  end

endmodule