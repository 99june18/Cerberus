module SEC_DED_DECODER(
    input  logic [295:0] codeword_in,
    output logic         decode_result_out,
    output logic [279:0] data_out
);

    logic [15:0]  syndrome;
    logic         decode_result;
    logic [295:0] decoded;

    assign syndrome[15] = ^(codeword_in & 296'b01101100_10000100_00000000_00000000_10011011_00010111_01001101_11111000_10010011_00100011_10111100_11101010_00010010_01111100_01000010_11011111_01111001_11001101_01100001_01100100_00101011_01110101_00010111_10000000_11111010_00010111_00001001_01110000_01010010_00001010_10110011_11111010_01100010_01010000_11101100_10101001_10001100);
    assign syndrome[14] = ^(codeword_in & 296'b11011000_00001010_00000000_00000000_10000101_10000101_10001101_01011000_01001110_10000110_11110010_11011001_01101111_11000100_10100101_01101110_11011001_10011110_11010110_01111100_01011101_11111100_11101001_00001001_11011001_00011111_11011011_10101010_00000111_10000110_11110101_00101001_10110110_11111101_10001101_10001010_10101011);
    assign syndrome[13] = ^(codeword_in & 296'b01101101_10101100_00000000_00000000_01011101_10011100_11000101_00010111_11010000_00110100_00101111_01011011_00000100_00001100_11011001_01001010_01101101_01011010_00010000_00100111_10101010_00011101_10100000_01010010_11101101_10100010_00110010_01000111_00110000_00110001_00011010_01010011_10111111_10000000_01000010_11011000_10101001);
    assign syndrome[12] = ^(codeword_in & 296'b00010001_00010011_00000000_00000000_10001010_10100011_00001001_00100101_11011011_01011101_11111011_11001000_10010111_11100000_10001011_11110010_01101000_10111011_10000101_01001101_10111111_00101000_10100100_11100011_11101010_11111101_00000001_10011100_10001110_10101011_01001011_00100010_11011111_01010101_11011011_10110011_01010011);
    assign syndrome[11] = ^(codeword_in & 296'b01110011_01011110_00000000_00000000_11111110_10100110_10101000_01110110_10101101_11010010_10101101_01111011_11100011_10111110_01110011_00011111_01111110_11000010_00101111_01111001_11101111_00111011_01001011_01010110_01000111_10001001_00010011_00001010_00110100_11000001_01110101_11011010_11100000_01000010_11001100_10011111_11111001);
    assign syndrome[10] = ^(codeword_in & 296'b11101101_01001001_00000000_00000000_01001111_11011000_01100101_01101111_01010111_10101001_10011001_00001010_10101001_01001110_00110100_01111011_11101000_00001110_01000010_10011100_01011110_01110111_01100111_11110001_11010001_01111011_10000101_10101111_10111100_00001110_10010010_01011110_11100011_00100110_00111100_10001001_00011100);
    assign syndrome[9] = ^(codeword_in & 296'b00110001_10100000_00000000_00000000_00100011_10101111_01110101_00000100_00001111_00101100_01100000_00101011_01111011_01110111_10101011_11010011_11110001_01001001_00000010_11100100_01010010_01000110_01111000_11000101_10010111_00001110_00011100_00111010_00111001_11110011_10000100_01100000_10110001_11000110_01100111_11100000_10000111);
    assign syndrome[8] = ^(codeword_in & 296'b10011000_01111001_00000000_00000000_10111111_00000001_01000110_11001001_01111010_11011111_00000100_00110111_11100000_01101001_10101000_11111100_10101100_00001011_00110101_00100101_10110101_01100011_10111010_10100001_00100110_11100000_00101011_01100101_10011010_01000010_01111010_00000011_10010001_01101100_10000111_01101101_00110100);
    assign syndrome[7] = ^(codeword_in & 296'b00000000_00000000_11100101_11001000_01111111_01101010_00011000_01100101_00010100_10111110_01010010_10000100_00100110_11100011_01111111_00001011_10111001_00010100_10011101_11110101_00101010_10101011_00101000_00010110_11101000_01001010_01101010_00000010_00010100_11101001_10101010_00011101_10001110_11010001_00001011_10010011_00000011);
    assign syndrome[6] = ^(codeword_in & 296'b00000000_00000000_00100101_10101110_00011110_10010010_00101010_10000011_00001001_11010100_11011010_00011111_01011001_10011000_10000101_01001111_10010000_01001011_11000101_00110101_10100001_10001000_11100111_00000001_00110110_00001010_01010011_11110001_00100000_00101000_00110011_00001001_11110000_01011000_11001010_01011100_10110110);
    assign syndrome[5] = ^(codeword_in & 296'b00000000_00000000_00010110_00100000_01000011_00001110_10001000_11101111_01001001_10111111_01101101_00001101_00101110_00010001_01000000_01110110_10110000_10101101_00011000_10111000_10000110_11001100_00000111_11001010_10001100_11001011_10100110_00100110_10011100_00100110_01111101_00100100_00001000_10011100_10011000_00011111_11101110);
    assign syndrome[4] = ^(codeword_in & 296'b00000000_00000000_01011100_10101100_11001001_10101101_10000100_01111101_01001000_01111110_11010100_10010011_11101011_01001100_00100111_00110011_10001011_11100010_11101010_01001100_00111100_00010101_00101101_11010001_00101001_11011011_10111110_10011000_11110111_11011111_01100110_11101011_11011001_10001111_10010100_00111011_00000100);
    assign syndrome[3] = ^(codeword_in & 296'b00000000_00000000_11001111_10110000_00110111_00001011_00100000_10011001_11100011_01010100_11101010_01011001_00011011_10011010_00100001_10100111_11001010_00000110_00111011_01000000_00001001_11000000_10101001_10010000_00111111_10010010_11000110_00001100_00111000_00010001_00000010_00101000_01110111_11110100_01111001_11100110_00011001);
    assign syndrome[2] = ^(codeword_in & 296'b00000000_00000000_00111101_11000010_01111000_11010011_11100001_00010010_10000111_10011101_01111010_01000010_01001110_11111100_11001100_10010110_11101101_11101111_01011111_10110000_00111101_11001011_00111001_00101010_10010110_11110010_00000011_01011000_01001001_01000101_00010001_00011001_11111010_01000001_10011011_11010010_01011110);
    assign syndrome[1] = ^(codeword_in & 296'b00000000_00000000_01111110_11001110_01011011_01111100_01010101_10011101_01000111_01010010_00100100_10100011_01000101_11011001_10101110_01101000_11100111_00110000_10101001_01011010_11110101_10110100_10000010_11111101_10111100_01100010_00110101_10011011_10000010_01111011_00110010_10010101_01011000_11111001_00110001_11011001_00001001);
    assign syndrome[0] = ^(codeword_in & 296'b00000000_00000000_11111001_10101001_11100100_01111101_10100111_11011011_10011001_10001011_10110000_10001111_01101010_11011100_11010000_11100101_01000011_00001010_11100000_00110111_00111010_01101111_00011100_01001111_10010010_11100110_01101110_10000110_10010011_10000000_01010010_11000101_00010010_10011111_00001001_00101010_01100101);

    always_comb begin
        case (syndrome)
            16'b0100010100000000: begin decoded = codeword_in ^ (296'b1 << 295); decode_result = 1'b0; end
            16'b1110110000000000: begin decoded = codeword_in ^ (296'b1 << 294); decode_result = 1'b0; end
            16'b1010111000000000: begin decoded = codeword_in ^ (296'b1 << 293); decode_result = 1'b0; end
            16'b0101101100000000: begin decoded = codeword_in ^ (296'b1 << 292); decode_result = 1'b0; end
            16'b1110010100000000: begin decoded = codeword_in ^ (296'b1 << 291); decode_result = 1'b0; end
            16'b1010010000000000: begin decoded = codeword_in ^ (296'b1 << 290); decode_result = 1'b0; end
            16'b0000100000000000: begin decoded = codeword_in ^ (296'b1 << 289); decode_result = 1'b0; end
            16'b0011111000000000: begin decoded = codeword_in ^ (296'b1 << 288); decode_result = 1'b0; end
            16'b1010001000000000: begin decoded = codeword_in ^ (296'b1 << 287); decode_result = 1'b0; end
            16'b0000110100000000: begin decoded = codeword_in ^ (296'b1 << 286); decode_result = 1'b0; end
            16'b0010001100000000: begin decoded = codeword_in ^ (296'b1 << 285); decode_result = 1'b0; end
            16'b0001100100000000: begin decoded = codeword_in ^ (296'b1 << 284); decode_result = 1'b0; end
            16'b0110110100000000: begin decoded = codeword_in ^ (296'b1 << 283); decode_result = 1'b0; end
            16'b1010100000000000: begin decoded = codeword_in ^ (296'b1 << 282); decode_result = 1'b0; end
            16'b0101100000000000: begin decoded = codeword_in ^ (296'b1 << 281); decode_result = 1'b0; end
            16'b0001010100000000: begin decoded = codeword_in ^ (296'b1 << 280); decode_result = 1'b0; end
            16'b0000000010001001: begin decoded = codeword_in ^ (296'b1 << 279); decode_result = 1'b0; end
            16'b0000000010011011: begin decoded = codeword_in ^ (296'b1 << 278); decode_result = 1'b0; end
            16'b0000000011000111: begin decoded = codeword_in ^ (296'b1 << 277); decode_result = 1'b0; end
            16'b0000000000110111: begin decoded = codeword_in ^ (296'b1 << 276); decode_result = 1'b0; end
            16'b0000000000011111: begin decoded = codeword_in ^ (296'b1 << 275); decode_result = 1'b0; end
            16'b0000000011111110: begin decoded = codeword_in ^ (296'b1 << 274); decode_result = 1'b0; end
            16'b0000000000101010: begin decoded = codeword_in ^ (296'b1 << 273); decode_result = 1'b0; end
            16'b0000000011001101: begin decoded = codeword_in ^ (296'b1 << 272); decode_result = 1'b0; end
            16'b0000000011011111: begin decoded = codeword_in ^ (296'b1 << 271); decode_result = 1'b0; end
            16'b0000000010000110: begin decoded = codeword_in ^ (296'b1 << 270); decode_result = 1'b0; end
            16'b0000000001111001: begin decoded = codeword_in ^ (296'b1 << 269); decode_result = 1'b0; end
            16'b0000000000001000: begin decoded = codeword_in ^ (296'b1 << 268); decode_result = 1'b0; end
            16'b0000000011010011: begin decoded = codeword_in ^ (296'b1 << 267); decode_result = 1'b0; end
            16'b0000000001010010: begin decoded = codeword_in ^ (296'b1 << 266); decode_result = 1'b0; end
            16'b0000000001000110: begin decoded = codeword_in ^ (296'b1 << 265); decode_result = 1'b0; end
            16'b0000000000000001: begin decoded = codeword_in ^ (296'b1 << 264); decode_result = 1'b0; end
            16'b1101100100010001: begin decoded = codeword_in ^ (296'b1 << 263); decode_result = 1'b0; end
            16'b0010110010110111: begin decoded = codeword_in ^ (296'b1 << 262); decode_result = 1'b0; end
            16'b0000101110001101: begin decoded = codeword_in ^ (296'b1 << 261); decode_result = 1'b0; end
            16'b1010100111001110: begin decoded = codeword_in ^ (296'b1 << 260); decode_result = 1'b0; end
            16'b1011110111010110: begin decoded = codeword_in ^ (296'b1 << 259); decode_result = 1'b0; end
            16'b0110110111001001: begin decoded = codeword_in ^ (296'b1 << 258); decode_result = 1'b0; end
            16'b1001111111101010: begin decoded = codeword_in ^ (296'b1 << 257); decode_result = 1'b0; end
            16'b1110011110111010: begin decoded = codeword_in ^ (296'b1 << 256); decode_result = 1'b0; end
            16'b0111111001010100: begin decoded = codeword_in ^ (296'b1 << 255); decode_result = 1'b0; end
            16'b0000010010000111: begin decoded = codeword_in ^ (296'b1 << 254); decode_result = 1'b0; end
            16'b0001101010010011: begin decoded = codeword_in ^ (296'b1 << 253); decode_result = 1'b0; end
            16'b1010010001000111: begin decoded = codeword_in ^ (296'b1 << 252); decode_result = 1'b0; end
            16'b0010011010111011: begin decoded = codeword_in ^ (296'b1 << 251); decode_result = 1'b0; end
            16'b1110101000110011: begin decoded = codeword_in ^ (296'b1 << 250); decode_result = 1'b0; end
            16'b1001101011101100: begin decoded = codeword_in ^ (296'b1 << 249); decode_result = 1'b0; end
            16'b1101001100011101: begin decoded = codeword_in ^ (296'b1 << 248); decode_result = 1'b0; end
            16'b0110100000110101: begin decoded = codeword_in ^ (296'b1 << 247); decode_result = 1'b0; end
            16'b1010011100000110: begin decoded = codeword_in ^ (296'b1 << 246); decode_result = 1'b0; end
            16'b0000111001001101: begin decoded = codeword_in ^ (296'b1 << 245); decode_result = 1'b0; end
            16'b0000001010000010: begin decoded = codeword_in ^ (296'b1 << 244); decode_result = 1'b0; end
            16'b1101100011100000: begin decoded = codeword_in ^ (296'b1 << 243); decode_result = 1'b0; end
            16'b1110011100010011: begin decoded = codeword_in ^ (296'b1 << 242); decode_result = 1'b0; end
            16'b0000000101000001: begin decoded = codeword_in ^ (296'b1 << 241); decode_result = 1'b0; end
            16'b1111011000000111: begin decoded = codeword_in ^ (296'b1 << 240); decode_result = 1'b0; end
            16'b1000000101101011: begin decoded = codeword_in ^ (296'b1 << 239); decode_result = 1'b0; end
            16'b1100110110110001: begin decoded = codeword_in ^ (296'b1 << 238); decode_result = 1'b0; end
            16'b1001110010110000: begin decoded = codeword_in ^ (296'b1 << 237); decode_result = 1'b0; end
            16'b1110100000011111: begin decoded = codeword_in ^ (296'b1 << 236); decode_result = 1'b0; end
            16'b1100010100111011: begin decoded = codeword_in ^ (296'b1 << 235); decode_result = 1'b0; end
            16'b0011111010110010: begin decoded = codeword_in ^ (296'b1 << 234); decode_result = 1'b0; end
            16'b0010110001100101: begin decoded = codeword_in ^ (296'b1 << 233); decode_result = 1'b0; end
            16'b0011010111111011: begin decoded = codeword_in ^ (296'b1 << 232); decode_result = 1'b0; end
            16'b1011100000001101: begin decoded = codeword_in ^ (296'b1 << 231); decode_result = 1'b0; end
            16'b0111010100111010: begin decoded = codeword_in ^ (296'b1 << 230); decode_result = 1'b0; end
            16'b0000100100001000: begin decoded = codeword_in ^ (296'b1 << 229); decode_result = 1'b0; end
            16'b1011010110000001: begin decoded = codeword_in ^ (296'b1 << 228); decode_result = 1'b0; end
            16'b0101101101110001: begin decoded = codeword_in ^ (296'b1 << 227); decode_result = 1'b0; end
            16'b0100111010000110: begin decoded = codeword_in ^ (296'b1 << 226); decode_result = 1'b0; end
            16'b1101011100001110: begin decoded = codeword_in ^ (296'b1 << 225); decode_result = 1'b0; end
            16'b1001111001101111: begin decoded = codeword_in ^ (296'b1 << 224); decode_result = 1'b0; end
            16'b0100110111100101: begin decoded = codeword_in ^ (296'b1 << 223); decode_result = 1'b0; end
            16'b0001100101011010: begin decoded = codeword_in ^ (296'b1 << 222); decode_result = 1'b0; end
            16'b1010011010110000: begin decoded = codeword_in ^ (296'b1 << 221); decode_result = 1'b0; end
            16'b0011100111111110: begin decoded = codeword_in ^ (296'b1 << 220); decode_result = 1'b0; end
            16'b0001011110110101: begin decoded = codeword_in ^ (296'b1 << 219); decode_result = 1'b0; end
            16'b0111001111111100: begin decoded = codeword_in ^ (296'b1 << 218); decode_result = 1'b0; end
            16'b1100100110110011: begin decoded = codeword_in ^ (296'b1 << 217); decode_result = 1'b0; end
            16'b1001010100100101: begin decoded = codeword_in ^ (296'b1 << 216); decode_result = 1'b0; end
            16'b1101110001011001: begin decoded = codeword_in ^ (296'b1 << 215); decode_result = 1'b0; end
            16'b0101001011111100: begin decoded = codeword_in ^ (296'b1 << 214); decode_result = 1'b0; end
            16'b1111101000101111: begin decoded = codeword_in ^ (296'b1 << 213); decode_result = 1'b0; end
            16'b1101010011010101: begin decoded = codeword_in ^ (296'b1 << 212); decode_result = 1'b0; end
            16'b1011110001101100: begin decoded = codeword_in ^ (296'b1 << 211); decode_result = 1'b0; end
            16'b1010100100110010: begin decoded = codeword_in ^ (296'b1 << 210); decode_result = 1'b0; end
            16'b0111000011001100: begin decoded = codeword_in ^ (296'b1 << 209); decode_result = 1'b0; end
            16'b0011110000100000: begin decoded = codeword_in ^ (296'b1 << 208); decode_result = 1'b0; end
            16'b1101000010010011: begin decoded = codeword_in ^ (296'b1 << 207); decode_result = 1'b0; end
            16'b1111100000001100: begin decoded = codeword_in ^ (296'b1 << 206); decode_result = 1'b0; end
            16'b1000101100000010: begin decoded = codeword_in ^ (296'b1 << 205); decode_result = 1'b0; end
            16'b0110100101011000: begin decoded = codeword_in ^ (296'b1 << 204); decode_result = 1'b0; end
            16'b1111111001101001: begin decoded = codeword_in ^ (296'b1 << 203); decode_result = 1'b0; end
            16'b0000000111100001: begin decoded = codeword_in ^ (296'b1 << 202); decode_result = 1'b0; end
            16'b1010111101010111: begin decoded = codeword_in ^ (296'b1 << 201); decode_result = 1'b0; end
            16'b0110101101111011: begin decoded = codeword_in ^ (296'b1 << 200); decode_result = 1'b0; end
            16'b0001110100010000: begin decoded = codeword_in ^ (296'b1 << 199); decode_result = 1'b0; end
            16'b0100101101010111: begin decoded = codeword_in ^ (296'b1 << 198); decode_result = 1'b0; end
            16'b0100111110110001: begin decoded = codeword_in ^ (296'b1 << 197); decode_result = 1'b0; end
            16'b1001001001001000: begin decoded = codeword_in ^ (296'b1 << 196); decode_result = 1'b0; end
            16'b0100011001111101: begin decoded = codeword_in ^ (296'b1 << 195); decode_result = 1'b0; end
            16'b0111000010100110: begin decoded = codeword_in ^ (296'b1 << 194); decode_result = 1'b0; end
            16'b1101101010111101: begin decoded = codeword_in ^ (296'b1 << 193); decode_result = 1'b0; end
            16'b0101111001011010: begin decoded = codeword_in ^ (296'b1 << 192); decode_result = 1'b0; end
            16'b0101100011001111: begin decoded = codeword_in ^ (296'b1 << 191); decode_result = 1'b0; end
            16'b1101011110010111: begin decoded = codeword_in ^ (296'b1 << 190); decode_result = 1'b0; end
            16'b1001101110000100: begin decoded = codeword_in ^ (296'b1 << 189); decode_result = 1'b0; end
            16'b1000101001101111: begin decoded = codeword_in ^ (296'b1 << 188); decode_result = 1'b0; end
            16'b1010110101011111: begin decoded = codeword_in ^ (296'b1 << 187); decode_result = 1'b0; end
            16'b1110111000010101: begin decoded = codeword_in ^ (296'b1 << 186); decode_result = 1'b0; end
            16'b0000111010001000: begin decoded = codeword_in ^ (296'b1 << 185); decode_result = 1'b0; end
            16'b0000001110100010: begin decoded = codeword_in ^ (296'b1 << 184); decode_result = 1'b0; end
            16'b0111001101000111: begin decoded = codeword_in ^ (296'b1 << 183); decode_result = 1'b0; end
            16'b1010100010100101: begin decoded = codeword_in ^ (296'b1 << 182); decode_result = 1'b0; end
            16'b0100111110011010: begin decoded = codeword_in ^ (296'b1 << 181); decode_result = 1'b0; end
            16'b0010110010000001: begin decoded = codeword_in ^ (296'b1 << 180); decode_result = 1'b0; end
            16'b0011001110000110: begin decoded = codeword_in ^ (296'b1 << 179); decode_result = 1'b0; end
            16'b0100010011010110: begin decoded = codeword_in ^ (296'b1 << 178); decode_result = 1'b0; end
            16'b1001101010010010: begin decoded = codeword_in ^ (296'b1 << 177); decode_result = 1'b0; end
            16'b0111101011011000: begin decoded = codeword_in ^ (296'b1 << 176); decode_result = 1'b0; end
            16'b1001001100001101: begin decoded = codeword_in ^ (296'b1 << 175); decode_result = 1'b0; end
            16'b1111011101100011: begin decoded = codeword_in ^ (296'b1 << 174); decode_result = 1'b0; end
            16'b0101010100111011: begin decoded = codeword_in ^ (296'b1 << 173); decode_result = 1'b0; end
            16'b1001111100110100: begin decoded = codeword_in ^ (296'b1 << 172); decode_result = 1'b0; end
            16'b1110110111000010: begin decoded = codeword_in ^ (296'b1 << 171); decode_result = 1'b0; end
            16'b1100100101101101: begin decoded = codeword_in ^ (296'b1 << 170); decode_result = 1'b0; end
            16'b1111111011111100: begin decoded = codeword_in ^ (296'b1 << 169); decode_result = 1'b0; end
            16'b1000111011011001: begin decoded = codeword_in ^ (296'b1 << 168); decode_result = 1'b0; end
            16'b0100011111111110: begin decoded = codeword_in ^ (296'b1 << 167); decode_result = 1'b0; end
            16'b1111111000001111: begin decoded = codeword_in ^ (296'b1 << 166); decode_result = 1'b0; end
            16'b1011111110100110: begin decoded = codeword_in ^ (296'b1 << 165); decode_result = 1'b0; end
            16'b1100101011100000: begin decoded = codeword_in ^ (296'b1 << 164); decode_result = 1'b0; end
            16'b1111110110011100: begin decoded = codeword_in ^ (296'b1 << 163); decode_result = 1'b0; end
            16'b0010100100000110: begin decoded = codeword_in ^ (296'b1 << 162); decode_result = 1'b0; end
            16'b0000100000011011: begin decoded = codeword_in ^ (296'b1 << 161); decode_result = 1'b0; end
            16'b1110001010010111: begin decoded = codeword_in ^ (296'b1 << 160); decode_result = 1'b0; end
            16'b1101100000110100: begin decoded = codeword_in ^ (296'b1 << 159); decode_result = 1'b0; end
            16'b1010101001010100: begin decoded = codeword_in ^ (296'b1 << 158); decode_result = 1'b0; end
            16'b0001000000110110: begin decoded = codeword_in ^ (296'b1 << 157); decode_result = 1'b0; end
            16'b0111000010000010: begin decoded = codeword_in ^ (296'b1 << 156); decode_result = 1'b0; end
            16'b1111011101100101: begin decoded = codeword_in ^ (296'b1 << 155); decode_result = 1'b0; end
            16'b1100010010101100: begin decoded = codeword_in ^ (296'b1 << 154); decode_result = 1'b0; end
            16'b0111110101011101: begin decoded = codeword_in ^ (296'b1 << 153); decode_result = 1'b0; end
            16'b1001001101100100: begin decoded = codeword_in ^ (296'b1 << 152); decode_result = 1'b0; end
            16'b0101000011010011: begin decoded = codeword_in ^ (296'b1 << 151); decode_result = 1'b0; end
            16'b1100010001010101: begin decoded = codeword_in ^ (296'b1 << 150); decode_result = 1'b0; end
            16'b1000100100011011: begin decoded = codeword_in ^ (296'b1 << 149); decode_result = 1'b0; end
            16'b0110000110101100: begin decoded = codeword_in ^ (296'b1 << 148); decode_result = 1'b0; end
            16'b0000100010111110: begin decoded = codeword_in ^ (296'b1 << 147); decode_result = 1'b0; end
            16'b0101100111000100: begin decoded = codeword_in ^ (296'b1 << 146); decode_result = 1'b0; end
            16'b0100111000011100: begin decoded = codeword_in ^ (296'b1 << 145); decode_result = 1'b0; end
            16'b1001100111001110: begin decoded = codeword_in ^ (296'b1 << 144); decode_result = 1'b0; end
            16'b0000011010100100: begin decoded = codeword_in ^ (296'b1 << 143); decode_result = 1'b0; end
            16'b1101101010011010: begin decoded = codeword_in ^ (296'b1 << 142); decode_result = 1'b0; end
            16'b1110101111100101: begin decoded = codeword_in ^ (296'b1 << 141); decode_result = 1'b0; end
            16'b0100110011100111: begin decoded = codeword_in ^ (296'b1 << 140); decode_result = 1'b0; end
            16'b0101110000110010: begin decoded = codeword_in ^ (296'b1 << 139); decode_result = 1'b0; end
            16'b1111011111010001: begin decoded = codeword_in ^ (296'b1 << 138); decode_result = 1'b0; end
            16'b0010000000000011: begin decoded = codeword_in ^ (296'b1 << 137); decode_result = 1'b0; end
            16'b0011100111000001: begin decoded = codeword_in ^ (296'b1 << 136); decode_result = 1'b0; end
            16'b0011100101100010: begin decoded = codeword_in ^ (296'b1 << 135); decode_result = 1'b0; end
            16'b0100111000000010: begin decoded = codeword_in ^ (296'b1 << 134); decode_result = 1'b0; end
            16'b1011100111010111: begin decoded = codeword_in ^ (296'b1 << 133); decode_result = 1'b0; end
            16'b0101011100010111: begin decoded = codeword_in ^ (296'b1 << 132); decode_result = 1'b0; end
            16'b1111110010011101: begin decoded = codeword_in ^ (296'b1 << 131); decode_result = 1'b0; end
            16'b0101110100110110: begin decoded = codeword_in ^ (296'b1 << 130); decode_result = 1'b0; end
            16'b1011111010100001: begin decoded = codeword_in ^ (296'b1 << 129); decode_result = 1'b0; end
            16'b1101100101001110: begin decoded = codeword_in ^ (296'b1 << 128); decode_result = 1'b0; end
            16'b0100000011101110: begin decoded = codeword_in ^ (296'b1 << 127); decode_result = 1'b0; end
            16'b1100011100101101: begin decoded = codeword_in ^ (296'b1 << 126); decode_result = 1'b0; end
            16'b1101110110000011: begin decoded = codeword_in ^ (296'b1 << 125); decode_result = 1'b0; end
            16'b1110110000010010: begin decoded = codeword_in ^ (296'b1 << 124); decode_result = 1'b0; end
            16'b0111100011100101: begin decoded = codeword_in ^ (296'b1 << 123); decode_result = 1'b0; end
            16'b1110011000110011: begin decoded = codeword_in ^ (296'b1 << 122); decode_result = 1'b0; end
            16'b0000111110000101: begin decoded = codeword_in ^ (296'b1 << 121); decode_result = 1'b0; end
            16'b1010110110010101: begin decoded = codeword_in ^ (296'b1 << 120); decode_result = 1'b0; end
            16'b0111000101001010: begin decoded = codeword_in ^ (296'b1 << 119); decode_result = 1'b0; end
            16'b0100111001000000: begin decoded = codeword_in ^ (296'b1 << 118); decode_result = 1'b0; end
            16'b0111011111011100: begin decoded = codeword_in ^ (296'b1 << 117); decode_result = 1'b0; end
            16'b1000001100000101: begin decoded = codeword_in ^ (296'b1 << 116); decode_result = 1'b0; end
            16'b0100101110011101: begin decoded = codeword_in ^ (296'b1 << 115); decode_result = 1'b0; end
            16'b1001010001110001: begin decoded = codeword_in ^ (296'b1 << 114); decode_result = 1'b0; end
            16'b1000110101100010: begin decoded = codeword_in ^ (296'b1 << 113); decode_result = 1'b0; end
            16'b1100110001111100: begin decoded = codeword_in ^ (296'b1 << 112); decode_result = 1'b0; end
            16'b1001011100111010: begin decoded = codeword_in ^ (296'b1 << 111); decode_result = 1'b0; end
            16'b0011111000110011: begin decoded = codeword_in ^ (296'b1 << 110); decode_result = 1'b0; end
            16'b0001010100000110: begin decoded = codeword_in ^ (296'b1 << 109); decode_result = 1'b0; end
            16'b0010110010011010: begin decoded = codeword_in ^ (296'b1 << 108); decode_result = 1'b0; end
            16'b0100000000100111: begin decoded = codeword_in ^ (296'b1 << 107); decode_result = 1'b0; end
            16'b0000101010000011: begin decoded = codeword_in ^ (296'b1 << 106); decode_result = 1'b0; end
            16'b0011100010100101: begin decoded = codeword_in ^ (296'b1 << 105); decode_result = 1'b0; end
            16'b0101011101010011: begin decoded = codeword_in ^ (296'b1 << 104); decode_result = 1'b0; end
            16'b1111011010100111: begin decoded = codeword_in ^ (296'b1 << 103); decode_result = 1'b0; end
            16'b1111110010000000: begin decoded = codeword_in ^ (296'b1 << 102); decode_result = 1'b0; end
            16'b1011000111011010: begin decoded = codeword_in ^ (296'b1 << 101); decode_result = 1'b0; end
            16'b1100011001001111: begin decoded = codeword_in ^ (296'b1 << 100); decode_result = 1'b0; end
            16'b1111000010111010: begin decoded = codeword_in ^ (296'b1 << 99); decode_result = 1'b0; end
            16'b0010101101101110: begin decoded = codeword_in ^ (296'b1 << 98); decode_result = 1'b0; end
            16'b1001101101001101: begin decoded = codeword_in ^ (296'b1 << 97); decode_result = 1'b0; end
            16'b0110111000011000: begin decoded = codeword_in ^ (296'b1 << 96); decode_result = 1'b0; end
            16'b0011100100111101: begin decoded = codeword_in ^ (296'b1 << 95); decode_result = 1'b0; end
            16'b0001010110110111: begin decoded = codeword_in ^ (296'b1 << 94); decode_result = 1'b0; end
            16'b0011010100000111: begin decoded = codeword_in ^ (296'b1 << 93); decode_result = 1'b0; end
            16'b1101010000011100: begin decoded = codeword_in ^ (296'b1 << 92); decode_result = 1'b0; end
            16'b0101111011110000: begin decoded = codeword_in ^ (296'b1 << 91); decode_result = 1'b0; end
            16'b1101001000000001: begin decoded = codeword_in ^ (296'b1 << 90); decode_result = 1'b0; end
            16'b1110011011111111: begin decoded = codeword_in ^ (296'b1 << 89); decode_result = 1'b0; end
            16'b1101110000110000: begin decoded = codeword_in ^ (296'b1 << 88); decode_result = 1'b0; end
            16'b0100010000111000: begin decoded = codeword_in ^ (296'b1 << 87); decode_result = 1'b0; end
            16'b0100000011001001: begin decoded = codeword_in ^ (296'b1 << 86); decode_result = 1'b0; end
            16'b0010000110110011: begin decoded = codeword_in ^ (296'b1 << 85); decode_result = 1'b0; end
            16'b0110101001010010: begin decoded = codeword_in ^ (296'b1 << 84); decode_result = 1'b0; end
            16'b1100001110010001: begin decoded = codeword_in ^ (296'b1 << 83); decode_result = 1'b0; end
            16'b0000011000111011: begin decoded = codeword_in ^ (296'b1 << 82); decode_result = 1'b0; end
            16'b0110100111111101: begin decoded = codeword_in ^ (296'b1 << 81); decode_result = 1'b0; end
            16'b1101110101000110: begin decoded = codeword_in ^ (296'b1 << 80); decode_result = 1'b0; end
            16'b0101010001010011: begin decoded = codeword_in ^ (296'b1 << 79); decode_result = 1'b0; end
            16'b1010000101000100: begin decoded = codeword_in ^ (296'b1 << 78); decode_result = 1'b0; end
            16'b1100011101100000: begin decoded = codeword_in ^ (296'b1 << 77); decode_result = 1'b0; end
            16'b1001001001010110: begin decoded = codeword_in ^ (296'b1 << 76); decode_result = 1'b0; end
            16'b0101111000011110: begin decoded = codeword_in ^ (296'b1 << 75); decode_result = 1'b0; end
            16'b0011010100101001: begin decoded = codeword_in ^ (296'b1 << 74); decode_result = 1'b0; end
            16'b0110111010100011: begin decoded = codeword_in ^ (296'b1 << 73); decode_result = 1'b0; end
            16'b0010010101000010: begin decoded = codeword_in ^ (296'b1 << 72); decode_result = 1'b0; end
            16'b0001010100110011: begin decoded = codeword_in ^ (296'b1 << 71); decode_result = 1'b0; end
            16'b1000000000010100: begin decoded = codeword_in ^ (296'b1 << 70); decode_result = 1'b0; end
            16'b0010111001011000: begin decoded = codeword_in ^ (296'b1 << 69); decode_result = 1'b0; end
            16'b1010111110111001: begin decoded = codeword_in ^ (296'b1 << 68); decode_result = 1'b0; end
            16'b0001011100101100: begin decoded = codeword_in ^ (296'b1 << 67); decode_result = 1'b0; end
            16'b0101110010110000: begin decoded = codeword_in ^ (296'b1 << 66); decode_result = 1'b0; end
            16'b1101000100010011: begin decoded = codeword_in ^ (296'b1 << 65); decode_result = 1'b0; end
            16'b0100001000010101: begin decoded = codeword_in ^ (296'b1 << 64); decode_result = 1'b0; end
            16'b0101101010010001: begin decoded = codeword_in ^ (296'b1 << 63); decode_result = 1'b0; end
            16'b0000101110010110: begin decoded = codeword_in ^ (296'b1 << 62); decode_result = 1'b0; end
            16'b0011001011100010: begin decoded = codeword_in ^ (296'b1 << 61); decode_result = 1'b0; end
            16'b0010001000011010: begin decoded = codeword_in ^ (296'b1 << 60); decode_result = 1'b0; end
            16'b1001010011010010: begin decoded = codeword_in ^ (296'b1 << 59); decode_result = 1'b0; end
            16'b0100010000110100: begin decoded = codeword_in ^ (296'b1 << 58); decode_result = 1'b0; end
            16'b1101011100110010: begin decoded = codeword_in ^ (296'b1 << 57); decode_result = 1'b0; end
            16'b0011101010011110: begin decoded = codeword_in ^ (296'b1 << 56); decode_result = 1'b0; end
            16'b1100011010000000: begin decoded = codeword_in ^ (296'b1 << 55); decode_result = 1'b0; end
            16'b0101100100110001: begin decoded = codeword_in ^ (296'b1 << 54); decode_result = 1'b0; end
            16'b1100100111110010: begin decoded = codeword_in ^ (296'b1 << 53); decode_result = 1'b0; end
            16'b1110110101100111: begin decoded = codeword_in ^ (296'b1 << 52); decode_result = 1'b0; end
            16'b0011000110100000: begin decoded = codeword_in ^ (296'b1 << 51); decode_result = 1'b0; end
            16'b0100101000110000: begin decoded = codeword_in ^ (296'b1 << 50); decode_result = 1'b0; end
            16'b1011010111011011: begin decoded = codeword_in ^ (296'b1 << 49); decode_result = 1'b0; end
            16'b1101100001100100: begin decoded = codeword_in ^ (296'b1 << 48); decode_result = 1'b0; end
            16'b1000100000010011: begin decoded = codeword_in ^ (296'b1 << 47); decode_result = 1'b0; end
            16'b1010111000010001: begin decoded = codeword_in ^ (296'b1 << 46); decode_result = 1'b0; end
            16'b1101001000111000: begin decoded = codeword_in ^ (296'b1 << 45); decode_result = 1'b0; end
            16'b1010110010000110: begin decoded = codeword_in ^ (296'b1 << 44); decode_result = 1'b0; end
            16'b1100110011011100: begin decoded = codeword_in ^ (296'b1 << 43); decode_result = 1'b0; end
            16'b0000010010100011: begin decoded = codeword_in ^ (296'b1 << 42); decode_result = 1'b0; end
            16'b1011110100010000: begin decoded = codeword_in ^ (296'b1 << 41); decode_result = 1'b0; end
            16'b0110000111010111: begin decoded = codeword_in ^ (296'b1 << 40); decode_result = 1'b0; end
            16'b0111111111010100: begin decoded = codeword_in ^ (296'b1 << 39); decode_result = 1'b0; end
            16'b1001110001011110: begin decoded = codeword_in ^ (296'b1 << 38); decode_result = 1'b0; end
            16'b1110111001001100: begin decoded = codeword_in ^ (296'b1 << 37); decode_result = 1'b0; end
            16'b0111001101011111: begin decoded = codeword_in ^ (296'b1 << 36); decode_result = 1'b0; end
            16'b0011000010110110: begin decoded = codeword_in ^ (296'b1 << 35); decode_result = 1'b0; end
            16'b0111000010001000: begin decoded = codeword_in ^ (296'b1 << 34); decode_result = 1'b0; end
            16'b1111010010001101: begin decoded = codeword_in ^ (296'b1 << 33); decode_result = 1'b0; end
            16'b0011011100011000: begin decoded = codeword_in ^ (296'b1 << 32); decode_result = 1'b0; end
            16'b0110001010111011: begin decoded = codeword_in ^ (296'b1 << 31); decode_result = 1'b0; end
            16'b1101101111001110: begin decoded = codeword_in ^ (296'b1 << 30); decode_result = 1'b0; end
            16'b0100010100001010: begin decoded = codeword_in ^ (296'b1 << 29); decode_result = 1'b0; end
            16'b1101000011101011: begin decoded = codeword_in ^ (296'b1 << 28); decode_result = 1'b0; end
            16'b0100000101110011: begin decoded = codeword_in ^ (296'b1 << 27); decode_result = 1'b0; end
            16'b0101011100111001: begin decoded = codeword_in ^ (296'b1 << 26); decode_result = 1'b0; end
            16'b0000111000010001: begin decoded = codeword_in ^ (296'b1 << 25); decode_result = 1'b0; end
            16'b0101000010010111: begin decoded = codeword_in ^ (296'b1 << 24); decode_result = 1'b0; end
            16'b1101100101110100: begin decoded = codeword_in ^ (296'b1 << 23); decode_result = 1'b0; end
            16'b1011101001001000: begin decoded = codeword_in ^ (296'b1 << 22); decode_result = 1'b0; end
            16'b1000011000001010: begin decoded = codeword_in ^ (296'b1 << 21); decode_result = 1'b0; end
            16'b0001010000111110: begin decoded = codeword_in ^ (296'b1 << 20); decode_result = 1'b0; end
            16'b1101110011101101: begin decoded = codeword_in ^ (296'b1 << 19); decode_result = 1'b0; end
            16'b1100111100010000: begin decoded = codeword_in ^ (296'b1 << 18); decode_result = 1'b0; end
            16'b0011001111000100: begin decoded = codeword_in ^ (296'b1 << 17); decode_result = 1'b0; end
            16'b0101001110001111: begin decoded = codeword_in ^ (296'b1 << 16); decode_result = 1'b0; end
            16'b1111111010001110: begin decoded = codeword_in ^ (296'b1 << 15); decode_result = 1'b0; end
            16'b0010001101001110: begin decoded = codeword_in ^ (296'b1 << 14); decode_result = 1'b0; end
            16'b1001001100011001: begin decoded = codeword_in ^ (296'b1 << 13); decode_result = 1'b0; end
            16'b0011100011110110: begin decoded = codeword_in ^ (296'b1 << 12); decode_result = 1'b0; end
            16'b1110110101110011: begin decoded = codeword_in ^ (296'b1 << 11); decode_result = 1'b0; end
            16'b0000100101101000: begin decoded = codeword_in ^ (296'b1 << 10); decode_result = 1'b0; end
            16'b0101100010111101: begin decoded = codeword_in ^ (296'b1 << 9); decode_result = 1'b0; end
            16'b1001110110110010: begin decoded = codeword_in ^ (296'b1 << 8); decode_result = 1'b0; end
            16'b1110101001100000: begin decoded = codeword_in ^ (296'b1 << 7); decode_result = 1'b0; end
            16'b0001100000100101: begin decoded = codeword_in ^ (296'b1 << 6); decode_result = 1'b0; end
            16'b0110100101100001: begin decoded = codeword_in ^ (296'b1 << 5); decode_result = 1'b0; end
            16'b0001110101001100: begin decoded = codeword_in ^ (296'b1 << 4); decode_result = 1'b0; end
            16'b1110110000101110: begin decoded = codeword_in ^ (296'b1 << 3); decode_result = 1'b0; end
            16'b1000011101110101: begin decoded = codeword_in ^ (296'b1 << 2); decode_result = 1'b0; end
            16'b0101001011100100: begin decoded = codeword_in ^ (296'b1 << 1); decode_result = 1'b0; end
            16'b0111101010001011: begin decoded = codeword_in ^ (296'b1 << 0); decode_result = 1'b0; end
            16'b0000000000000000: begin decoded = codeword_in; decode_result = 1'b0; end // NE
            default:            begin decoded = codeword_in; decode_result = 1'b1; end // DUE
        endcase
    end

    assign decode_result_out = decode_result;
    assign data_out          = decoded[295:16];

endmodule
