module DECODER(
    input  [7:0] data[31:0],
    input  [7:0] parity[5:0],
    output [7:0] decode_data[31:0]
);

    wire [7:0] syndrome[5:0];
    wire [7:0] lambda[3:0];
    wire [7:0] omega[2:0];
    wire [7:0] magnitude[37:0];
    wire [37:0] locator;

    SYNDROME_GENERATOR syndrome_generator(data, parity, syndrome);
    RIBM ribm(syndrome, lambda, omega);
    CHIEN chien(lambda, locator);
    FORNEY forney(lambda, omega, magnitude);

    assign decode_data[0] = locator[0] ? (data[0] ^ magnitude[0]) : data[0];
    assign decode_data[1] = locator[1] ? (data[1] ^ magnitude[1]) : data[1];
    assign decode_data[2] = locator[2] ? (data[2] ^ magnitude[2]) : data[2];
    assign decode_data[3] = locator[3] ? (data[3] ^ magnitude[3]) : data[3];
    assign decode_data[4] = locator[4] ? (data[4] ^ magnitude[4]) : data[4];
    assign decode_data[5] = locator[5] ? (data[5] ^ magnitude[5]) : data[5];
    assign decode_data[6] = locator[6] ? (data[6] ^ magnitude[6]) : data[6];
    assign decode_data[7] = locator[7] ? (data[7] ^ magnitude[7]) : data[7];
    assign decode_data[8] = locator[8] ? (data[8] ^ magnitude[8]) : data[8];
    assign decode_data[9] = locator[9] ? (data[9] ^ magnitude[9]) : data[9];
    assign decode_data[10] = locator[10] ? (data[10] ^ magnitude[10]) : data[10];
    assign decode_data[11] = locator[11] ? (data[11] ^ magnitude[11]) : data[11];
    assign decode_data[12] = locator[12] ? (data[12] ^ magnitude[12]) : data[12];
    assign decode_data[13] = locator[13] ? (data[13] ^ magnitude[13]) : data[13];
    assign decode_data[14] = locator[14] ? (data[14] ^ magnitude[14]) : data[14];
    assign decode_data[15] = locator[15] ? (data[15] ^ magnitude[15]) : data[15];
    assign decode_data[16] = locator[16] ? (data[16] ^ magnitude[16]) : data[16];
    assign decode_data[17] = locator[17] ? (data[17] ^ magnitude[17]) : data[17];
    assign decode_data[18] = locator[18] ? (data[18] ^ magnitude[18]) : data[18];
    assign decode_data[19] = locator[19] ? (data[19] ^ magnitude[19]) : data[19];
    assign decode_data[20] = locator[20] ? (data[20] ^ magnitude[20]) : data[20];
    assign decode_data[21] = locator[21] ? (data[21] ^ magnitude[21]) : data[21];
    assign decode_data[22] = locator[22] ? (data[22] ^ magnitude[22]) : data[22];
    assign decode_data[23] = locator[23] ? (data[23] ^ magnitude[23]) : data[23];
    assign decode_data[24] = locator[24] ? (data[24] ^ magnitude[24]) : data[24];
    assign decode_data[25] = locator[25] ? (data[25] ^ magnitude[25]) : data[25];
    assign decode_data[26] = locator[26] ? (data[26] ^ magnitude[26]) : data[26];
    assign decode_data[27] = locator[27] ? (data[27] ^ magnitude[27]) : data[27];
    assign decode_data[28] = locator[28] ? (data[28] ^ magnitude[28]) : data[28];
    assign decode_data[29] = locator[29] ? (data[29] ^ magnitude[29]) : data[29];
    assign decode_data[30] = locator[30] ? (data[30] ^ magnitude[30]) : data[30];
    assign decode_data[31] = locator[31] ? (data[31] ^ magnitude[31]) : data[31];

endmodule