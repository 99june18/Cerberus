`timescale 1ns/1ps

module TB_testbench;

  logic [7:0] data [31:0];
  logic [7:0] parity [5:0];
  logic [7:0] decode_data [31:0];

  integer i;

  DECODER dut (
    .data(data),
    .parity(parity),
    .decode_data(decode_data)
  );

  task clear_all;
    begin
      for (i = 0; i < 32; i = i + 1)
        data[i] = 8'h00;
      for (i = 0; i < 6; i = i + 1)
        parity[i] = 8'h00;
    end
  endtask

  task check_zero(input string tag);
    integer j;
    integer err;
    begin
      #1;
      err = 0;
      for (j = 0; j < 32; j = j + 1) begin
        if (decode_data[j] !== 8'h00)
          err = err + 1;
      end

      if (err == 0) begin
        $display("[PASS] %s", tag);
      end
      else begin
        $display("[FAIL] %s, nonzero decoded symbols = %0d", tag, err);
        for (j = 0; j < 32; j = j + 1) begin
          if (decode_data[j] !== 8'h00)
            $display("  decode_data[%0d] = 0x%02h", j, decode_data[j]);
        end
      end
    end
  endtask

  initial begin
    $display("======================================");
    $display("  DECODER TB for RS(38,32), t = 3");
    $display("======================================");

    // no error
    clear_all();
    check_zero("no error");

    // 1-symbol error
    clear_all();
    data[5] = 8'hA6;
    check_zero("1 symbol error @ data[5]");

    // 2-symbol errors
    clear_all();
    data[0]  = 8'h1F;
    data[20] = 8'hC3;
    check_zero("2 symbol errors @ data[0], data[20]");

    // 3-symbol errors in data
    clear_all();
    data[2]  = 8'h9A;
    data[17] = 8'h55;
    data[31] = 8'hE1;
    check_zero("3 symbol errors @ data[2], data[17], data[31]");

    // 3-symbol errors including parity
    clear_all();
    data[7]   = 8'h12;
    parity[1] = 8'h34;
    parity[5] = 8'h56;
    check_zero("3 symbol errors @ data[7], parity[1], parity[5]");
    $finish;
  end

endmodule