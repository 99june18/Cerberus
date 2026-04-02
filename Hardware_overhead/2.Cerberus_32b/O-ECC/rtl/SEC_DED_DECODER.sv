module SEC_DED_DECODER(
    input  logic [287:0] codeword_in,
    output logic         decode_result_out,
    output logic [271:0] data_out
);

    logic [15:0] syndrome;
    logic        decode_result;
    logic [287:0] decoded;

    assign syndrome[15] = ^(codeword_in & 288'b0110110010000100_0000000000000000_0101111100110001_1011010010101000_0111010111111010_0001000110111001_0001001001111100_1100101010111011_0111100111001101_1010010010011001_0010101101110101_0001011110000000_1111101000010111_0000100101110000_0101001000001010_1011001111111010_0110001001010000_1110110010101001);
    assign syndrome[14] = ^(codeword_in & 288'b1101100000001010_0000000000000000_1110101110010100_1100111010010101_0110100100010001_1111101110110000_0110111111000100_0000000111001010_1101100110011110_1000111101100010_0101110111111100_1110100100001001_1101100100011111_1101101110101010_0000011110000110_1111010100101001_1011011011111101_1000110110001010);
    assign syndrome[13] = ^(codeword_in & 288'b0110110110101100_0000000000000000_1101011011110100_0010111001000110_0101010011001001_0001100100011101_0000010000001100_0000101011101010_0110110101011010_1101111000110011_1010101000011101_1010000001010010_1110110110100010_0011001001000111_0011000000110001_0001101001010011_1011111110000000_0100001011011000);
    assign syndrome[12] = ^(codeword_in & 288'b0001000100010011_0000000000000000_1101110101000101_0000111011000011_0110111101100010_0101101111000001_1001011111100000_0000100011011000_0110100010111011_0111110100111111_1011111100101000_1010010011100011_1110101011111101_0000000110011100_1000111010101011_0100101100100010_1101111101010101_1101101110110011);
    assign syndrome[11] = ^(codeword_in & 288'b0111001101011110_0000000000000000_0110011101011111_1001001100011101_1011110100110101_1100111101010001_1110001110111110_1010011111101100_0111111011000010_1100111010001101_1110111100111011_0100101101010110_0100011110001001_0001001100001010_0011010011000001_0111010111011010_1110000001000010_1100110010011111);
    assign syndrome[10] = ^(codeword_in & 288'b1110110101001001_0000000000000000_1010100001110010_0100001111011001_1011010011100011_0111100001001010_1010100101001110_1110000111111100_1110100000001110_0101010110110001_0101111001110111_0110011111110001_1101000101111011_1000010110101111_1011110000001110_1001001001011110_1110001100100110_0011110010001001);
    assign syndrome[9] = ^(codeword_in & 288'b0011000110100000_0000000000000000_0011010000010101_1100101011010001_0011101011011100_0101100011111110_0111101101110111_0100000010110110_1111000101001001_0001000111010101_0101001001000110_0111100011000101_1001011100001110_0001110000111010_0011100111110011_1000010001100000_1011000111000110_0110011111100000);
    assign syndrome[8] = ^(codeword_in & 288'b1001100001111001_0000000000000000_0110000101011100_0001010110101011_0110110100101011_1010010000111110_1110000001101001_0111000101100110_1010110000001011_1001000100001011_1011010101100011_1011101010100001_0010011011100000_0010101101100101_1001101001000010_0111101000000011_1001000101101100_1000011101101101);
    assign syndrome[7] = ^(codeword_in & 288'b0000000000000000_1100100001001111_0111101001000001_0111011110001010_1001010111010000_0011000010101110_0010011011100011_0011101011110000_1011100100010100_0011001101101100_0010101010101011_0010100000010110_1110100001001010_0110101000000010_0001010011101001_1010101000011101_1000111011010001_0000101110010011);
    assign syndrome[6] = ^(codeword_in & 288'b0000000000000000_1011010000011110_1011010010100101_0101100010110001_0100100101010101_1001011000001100_0101100110011000_0100100110100100_1001000001001011_0011100101011011_1010000110001000_1110011100000001_0011011000001010_0101001111110001_0010000000101000_0011001100001001_1111000001011000_1100101001011100);
    assign syndrome[5] = ^(codeword_in & 288'b0000000000000000_0010111100001101_0110001001010001_1001101011101110_1110110111000110_0101110010110001_0010111000010001_0001011011011011_1011000010101101_0100111001010011_1000011011001100_0000011111001010_1000110011001011_1010011000100110_1001110000100110_0111110100100100_0000100010011100_1001100000011111);
    assign syndrome[4] = ^(codeword_in & 288'b0000000000000000_1000011100111011_1011111100010100_1100000001010110_0001101010011000_0100001011011100_1110101101001100_0001100010100101_1000101111100010_1111011111010110_0011110000010101_0010110111010001_0010100111011011_1011111010011000_1111011111011111_0110011011101011_1101100110001111_1001010000111011);
    assign syndrome[3] = ^(codeword_in & 288'b0000000000000000_1011111010101111_1101100001001011_0000100111110011_1101010000100100_1000010100101001_0001101110011010_1010010111011110_1100101000000110_1011111101111011_0000100111000000_1010100110010000_0011111110010010_1100011000001100_0011100000010001_0000001000101000_0111011111110100_0111100111100110);
    assign syndrome[2] = ^(codeword_in & 288'b0000000000000000_1110010000000101_0111000000111001_1000001110001111_1110000000101010_0101110100010010_0100111011111100_0100111011001000_1110110111101111_1100110111111000_0011110111001011_0011100100101010_1001011011110010_0000001101011000_0100100101000101_0001000100011001_1111101001000001_1001101111010010);
    assign syndrome[1] = ^(codeword_in & 288'b0000000000000000_0001001100011100_0100010000101100_1100001100100010_0010000001000100_1100001000011001_0100010111011001_1100110000011101_1110011100110000_1101101110111000_1111010110110100_1000001011111101_1011110001100010_0011010110011011_1000001001111011_0011001010010101_0101100011111001_0011000111011001);
    assign syndrome[0] = ^(codeword_in & 288'b0000000000000000_0110001000101110_0010010101110000_1001011000100100_1011100100001111_1011111000011100_0110101011011100_0001101101011101_0100001100001010_0111011001100011_0011101001101111_0001110001001111_1001001011100110_0110111010000110_1001001110000000_0101001011000101_0001001010011111_0000100100101010);

    always_comb begin
        case (syndrome)
            16'b0100010100000000: begin decoded = codeword_in ^ (288'b1 << 287); decode_result = 1'b0; end
            16'b1110110000000000: begin decoded = codeword_in ^ (288'b1 << 286); decode_result = 1'b0; end
            16'b1010111000000000: begin decoded = codeword_in ^ (288'b1 << 285); decode_result = 1'b0; end
            16'b0101101100000000: begin decoded = codeword_in ^ (288'b1 << 284); decode_result = 1'b0; end
            16'b1110010100000000: begin decoded = codeword_in ^ (288'b1 << 283); decode_result = 1'b0; end
            16'b1010010000000000: begin decoded = codeword_in ^ (288'b1 << 282); decode_result = 1'b0; end
            16'b0000100000000000: begin decoded = codeword_in ^ (288'b1 << 281); decode_result = 1'b0; end
            16'b0011111000000000: begin decoded = codeword_in ^ (288'b1 << 280); decode_result = 1'b0; end
            16'b1010001000000000: begin decoded = codeword_in ^ (288'b1 << 279); decode_result = 1'b0; end
            16'b0000110100000000: begin decoded = codeword_in ^ (288'b1 << 278); decode_result = 1'b0; end
            16'b0010001100000000: begin decoded = codeword_in ^ (288'b1 << 277); decode_result = 1'b0; end
            16'b0001100100000000: begin decoded = codeword_in ^ (288'b1 << 276); decode_result = 1'b0; end
            16'b0110110100000000: begin decoded = codeword_in ^ (288'b1 << 275); decode_result = 1'b0; end
            16'b1010100000000000: begin decoded = codeword_in ^ (288'b1 << 274); decode_result = 1'b0; end
            16'b0101100000000000: begin decoded = codeword_in ^ (288'b1 << 273); decode_result = 1'b0; end
            16'b0001010100000000: begin decoded = codeword_in ^ (288'b1 << 272); decode_result = 1'b0; end
            16'b0000000011011100: begin decoded = codeword_in ^ (288'b1 << 271); decode_result = 1'b0; end
            16'b0000000010000101: begin decoded = codeword_in ^ (288'b1 << 270); decode_result = 1'b0; end
            16'b0000000001101101: begin decoded = codeword_in ^ (288'b1 << 269); decode_result = 1'b0; end
            16'b0000000001001010: begin decoded = codeword_in ^ (288'b1 << 268); decode_result = 1'b0; end
            16'b0000000010101000: begin decoded = codeword_in ^ (288'b1 << 267); decode_result = 1'b0; end
            16'b0000000001111100: begin decoded = codeword_in ^ (288'b1 << 266); decode_result = 1'b0; end
            16'b0000000000111011: begin decoded = codeword_in ^ (288'b1 << 265); decode_result = 1'b0; end
            16'b0000000000110010: begin decoded = codeword_in ^ (288'b1 << 264); decode_result = 1'b0; end
            16'b0000000000001000: begin decoded = codeword_in ^ (288'b1 << 263); decode_result = 1'b0; end
            16'b0000000010000000: begin decoded = codeword_in ^ (288'b1 << 262); decode_result = 1'b0; end
            16'b0000000000011001: begin decoded = codeword_in ^ (288'b1 << 261); decode_result = 1'b0; end
            16'b0000000001010010: begin decoded = codeword_in ^ (288'b1 << 260); decode_result = 1'b0; end
            16'b0000000011111011: begin decoded = codeword_in ^ (288'b1 << 259); decode_result = 1'b0; end
            16'b0000000011101111: begin decoded = codeword_in ^ (288'b1 << 258); decode_result = 1'b0; end
            16'b0000000011011001: begin decoded = codeword_in ^ (288'b1 << 257); decode_result = 1'b0; end
            16'b0000000010111100: begin decoded = codeword_in ^ (288'b1 << 256); decode_result = 1'b0; end
            16'b0111010001011000: begin decoded = codeword_in ^ (288'b1 << 255); decode_result = 1'b0; end
            16'b1111100110101110: begin decoded = codeword_in ^ (288'b1 << 254); decode_result = 1'b0; end
            16'b0100111111110101: begin decoded = codeword_in ^ (288'b1 << 253); decode_result = 1'b0; end
            16'b1011001011011100: begin decoded = codeword_in ^ (288'b1 << 252); decode_result = 1'b0; end
            16'b1101010010011000: begin decoded = codeword_in ^ (288'b1 << 251); decode_result = 1'b0; end
            16'b1011101001010011: begin decoded = codeword_in ^ (288'b1 << 250); decode_result = 1'b0; end
            16'b1110100010110000: begin decoded = codeword_in ^ (288'b1 << 249); decode_result = 1'b0; end
            16'b1101100100010001: begin decoded = codeword_in ^ (288'b1 << 248); decode_result = 1'b0; end
            16'b0110000001000000: begin decoded = codeword_in ^ (288'b1 << 247); decode_result = 1'b0; end
            16'b0011110110101001: begin decoded = codeword_in ^ (288'b1 << 246); decode_result = 1'b0; end
            16'b1010010001000111: begin decoded = codeword_in ^ (288'b1 << 245); decode_result = 1'b0; end
            16'b1110111100110101: begin decoded = codeword_in ^ (288'b1 << 244); decode_result = 1'b0; end
            16'b0000100100001110: begin decoded = codeword_in ^ (288'b1 << 243); decode_result = 1'b0; end
            16'b0111101101010010: begin decoded = codeword_in ^ (288'b1 << 242); decode_result = 1'b0; end
            16'b0000110000001000: begin decoded = codeword_in ^ (288'b1 << 241); decode_result = 1'b0; end
            16'b1001101011101100: begin decoded = codeword_in ^ (288'b1 << 240); decode_result = 1'b0; end
            16'b1100101000110111: begin decoded = codeword_in ^ (288'b1 << 239); decode_result = 1'b0; end
            16'b0100011011010010: begin decoded = codeword_in ^ (288'b1 << 238); decode_result = 1'b0; end
            16'b1010000010000000: begin decoded = codeword_in ^ (288'b1 << 237); decode_result = 1'b0; end
            16'b1000100111100001: begin decoded = codeword_in ^ (288'b1 << 236); decode_result = 1'b0; end
            16'b0111001001101000: begin decoded = codeword_in ^ (288'b1 << 235); decode_result = 1'b0; end
            16'b1111000110000001: begin decoded = codeword_in ^ (288'b1 << 234); decode_result = 1'b0; end
            16'b0111111010100111: begin decoded = codeword_in ^ (288'b1 << 233); decode_result = 1'b0; end
            16'b0000110110001110: begin decoded = codeword_in ^ (288'b1 << 232); decode_result = 1'b0; end
            16'b1101011111101100: begin decoded = codeword_in ^ (288'b1 << 231); decode_result = 1'b0; end
            16'b0011011000111000: begin decoded = codeword_in ^ (288'b1 << 230); decode_result = 1'b0; end
            16'b1000000101101011: begin decoded = codeword_in ^ (288'b1 << 229); decode_result = 1'b0; end
            16'b0100111001011000: begin decoded = codeword_in ^ (288'b1 << 228); decode_result = 1'b0; end
            16'b1000110110100100: begin decoded = codeword_in ^ (288'b1 << 227); decode_result = 1'b0; end
            16'b0110100000110101: begin decoded = codeword_in ^ (288'b1 << 226); decode_result = 1'b0; end
            16'b0011000110111110: begin decoded = codeword_in ^ (288'b1 << 225); decode_result = 1'b0; end
            16'b0101111101001100: begin decoded = codeword_in ^ (288'b1 << 224); decode_result = 1'b0; end
            16'b0000110010101101: begin decoded = codeword_in ^ (288'b1 << 223); decode_result = 1'b0; end
            16'b1111000101101100: begin decoded = codeword_in ^ (288'b1 << 222); decode_result = 1'b0; end
            16'b1101111100100111: begin decoded = codeword_in ^ (288'b1 << 221); decode_result = 1'b0; end
            16'b1010111010011001: begin decoded = codeword_in ^ (288'b1 << 220); decode_result = 1'b0; end
            16'b0101101101110001: begin decoded = codeword_in ^ (288'b1 << 219); decode_result = 1'b0; end
            16'b1011110110101000: begin decoded = codeword_in ^ (288'b1 << 218); decode_result = 1'b0; end
            16'b0001001000010000: begin decoded = codeword_in ^ (288'b1 << 217); decode_result = 1'b0; end
            16'b1101100111100001: begin decoded = codeword_in ^ (288'b1 << 216); decode_result = 1'b0; end
            16'b1010011010110000: begin decoded = codeword_in ^ (288'b1 << 215); decode_result = 1'b0; end
            16'b1011011011100010: begin decoded = codeword_in ^ (288'b1 << 214); decode_result = 1'b0; end
            16'b1001110100001100: begin decoded = codeword_in ^ (288'b1 << 213); decode_result = 1'b0; end
            16'b1100101011010000: begin decoded = codeword_in ^ (288'b1 << 212); decode_result = 1'b0; end
            16'b1010001100010101: begin decoded = codeword_in ^ (288'b1 << 211); decode_result = 1'b0; end
            16'b0000101001101011: begin decoded = codeword_in ^ (288'b1 << 210); decode_result = 1'b0; end
            16'b1001010100100101: begin decoded = codeword_in ^ (288'b1 << 209); decode_result = 1'b0; end
            16'b0110110101000001: begin decoded = codeword_in ^ (288'b1 << 208); decode_result = 1'b0; end
            16'b0100100101001011: begin decoded = codeword_in ^ (288'b1 << 207); decode_result = 1'b0; end
            16'b0101111000110110: begin decoded = codeword_in ^ (288'b1 << 206); decode_result = 1'b0; end
            16'b0100010110000001: begin decoded = codeword_in ^ (288'b1 << 205); decode_result = 1'b0; end
            16'b1111011011100101: begin decoded = codeword_in ^ (288'b1 << 204); decode_result = 1'b0; end
            16'b0111111000100101: begin decoded = codeword_in ^ (288'b1 << 203); decode_result = 1'b0; end
            16'b0000100101101101: begin decoded = codeword_in ^ (288'b1 << 202); decode_result = 1'b0; end
            16'b0101100001010011: begin decoded = codeword_in ^ (288'b1 << 201); decode_result = 1'b0; end
            16'b1111100000001100: begin decoded = codeword_in ^ (288'b1 << 200); decode_result = 1'b0; end
            16'b1101001010110000: begin decoded = codeword_in ^ (288'b1 << 199); decode_result = 1'b0; end
            16'b0001111000010000: begin decoded = codeword_in ^ (288'b1 << 198); decode_result = 1'b0; end
            16'b1100001110101000: begin decoded = codeword_in ^ (288'b1 << 197); decode_result = 1'b0; end
            16'b1110101100110111: begin decoded = codeword_in ^ (288'b1 << 196); decode_result = 1'b0; end
            16'b1010011111011011: begin decoded = codeword_in ^ (288'b1 << 195); decode_result = 1'b0; end
            16'b0010001111010001: begin decoded = codeword_in ^ (288'b1 << 194); decode_result = 1'b0; end
            16'b0000011110000100: begin decoded = codeword_in ^ (288'b1 << 193); decode_result = 1'b0; end
            16'b1011100000101010: begin decoded = codeword_in ^ (288'b1 << 192); decode_result = 1'b0; end
            16'b0001110100010000: begin decoded = codeword_in ^ (288'b1 << 191); decode_result = 1'b0; end
            16'b0100101101010111: begin decoded = codeword_in ^ (288'b1 << 190); decode_result = 1'b0; end
            16'b0100111110110001: begin decoded = codeword_in ^ (288'b1 << 189); decode_result = 1'b0; end
            16'b1001001001001000: begin decoded = codeword_in ^ (288'b1 << 188); decode_result = 1'b0; end
            16'b0100011001111101: begin decoded = codeword_in ^ (288'b1 << 187); decode_result = 1'b0; end
            16'b0111000010100110: begin decoded = codeword_in ^ (288'b1 << 186); decode_result = 1'b0; end
            16'b1101101010111101: begin decoded = codeword_in ^ (288'b1 << 185); decode_result = 1'b0; end
            16'b0101111001011010: begin decoded = codeword_in ^ (288'b1 << 184); decode_result = 1'b0; end
            16'b0101100011001111: begin decoded = codeword_in ^ (288'b1 << 183); decode_result = 1'b0; end
            16'b1101011110010111: begin decoded = codeword_in ^ (288'b1 << 182); decode_result = 1'b0; end
            16'b1001101110000100: begin decoded = codeword_in ^ (288'b1 << 181); decode_result = 1'b0; end
            16'b1000101001101111: begin decoded = codeword_in ^ (288'b1 << 180); decode_result = 1'b0; end
            16'b1010110101011111: begin decoded = codeword_in ^ (288'b1 << 179); decode_result = 1'b0; end
            16'b1110111000010101: begin decoded = codeword_in ^ (288'b1 << 178); decode_result = 1'b0; end
            16'b0000111010001000: begin decoded = codeword_in ^ (288'b1 << 177); decode_result = 1'b0; end
            16'b0000001110100010: begin decoded = codeword_in ^ (288'b1 << 176); decode_result = 1'b0; end
            16'b1000110000001010: begin decoded = codeword_in ^ (288'b1 << 175); decode_result = 1'b0; end
            16'b1000011101000110: begin decoded = codeword_in ^ (288'b1 << 174); decode_result = 1'b0; end
            16'b0000110110001000: begin decoded = codeword_in ^ (288'b1 << 173); decode_result = 1'b0; end
            16'b0000000110110001: begin decoded = codeword_in ^ (288'b1 << 172); decode_result = 1'b0; end
            16'b1011000011010111: begin decoded = codeword_in ^ (288'b1 << 171); decode_result = 1'b0; end
            16'b0000100000101110: begin decoded = codeword_in ^ (288'b1 << 170); decode_result = 1'b0; end
            16'b1010100010100101: begin decoded = codeword_in ^ (288'b1 << 169); decode_result = 1'b0; end
            16'b0100110101001001: begin decoded = codeword_in ^ (288'b1 << 168); decode_result = 1'b0; end
            16'b1111111011111100: begin decoded = codeword_in ^ (288'b1 << 167); decode_result = 1'b0; end
            16'b0111110110101101: begin decoded = codeword_in ^ (288'b1 << 166); decode_result = 1'b0; end
            16'b1010111111010000: begin decoded = codeword_in ^ (288'b1 << 165); decode_result = 1'b0; end
            16'b1001011010101011: begin decoded = codeword_in ^ (288'b1 << 164); decode_result = 1'b0; end
            16'b1111110000101111: begin decoded = codeword_in ^ (288'b1 << 163); decode_result = 1'b0; end
            16'b0000111101011011: begin decoded = codeword_in ^ (288'b1 << 162); decode_result = 1'b0; end
            16'b1110001100101000: begin decoded = codeword_in ^ (288'b1 << 161); decode_result = 1'b0; end
            16'b1000000000110011: begin decoded = codeword_in ^ (288'b1 << 160); decode_result = 1'b0; end
            16'b0100011111111110: begin decoded = codeword_in ^ (288'b1 << 159); decode_result = 1'b0; end
            16'b1111111000001111: begin decoded = codeword_in ^ (288'b1 << 158); decode_result = 1'b0; end
            16'b1011111110100110: begin decoded = codeword_in ^ (288'b1 << 157); decode_result = 1'b0; end
            16'b1100101011100000: begin decoded = codeword_in ^ (288'b1 << 156); decode_result = 1'b0; end
            16'b1111110110011100: begin decoded = codeword_in ^ (288'b1 << 155); decode_result = 1'b0; end
            16'b0010100100000110: begin decoded = codeword_in ^ (288'b1 << 154); decode_result = 1'b0; end
            16'b0000100000011011: begin decoded = codeword_in ^ (288'b1 << 153); decode_result = 1'b0; end
            16'b1110001010010111: begin decoded = codeword_in ^ (288'b1 << 152); decode_result = 1'b0; end
            16'b1101100000110100: begin decoded = codeword_in ^ (288'b1 << 151); decode_result = 1'b0; end
            16'b1010101001010100: begin decoded = codeword_in ^ (288'b1 << 150); decode_result = 1'b0; end
            16'b0001000000110110: begin decoded = codeword_in ^ (288'b1 << 149); decode_result = 1'b0; end
            16'b0111000010000010: begin decoded = codeword_in ^ (288'b1 << 148); decode_result = 1'b0; end
            16'b1111011101100101: begin decoded = codeword_in ^ (288'b1 << 147); decode_result = 1'b0; end
            16'b1100010010101100: begin decoded = codeword_in ^ (288'b1 << 146); decode_result = 1'b0; end
            16'b0111110101011101: begin decoded = codeword_in ^ (288'b1 << 145); decode_result = 1'b0; end
            16'b1001001101100100: begin decoded = codeword_in ^ (288'b1 << 144); decode_result = 1'b0; end
            16'b1110100100011110: begin decoded = codeword_in ^ (288'b1 << 143); decode_result = 1'b0; end
            16'b0011110000110111: begin decoded = codeword_in ^ (288'b1 << 142); decode_result = 1'b0; end
            16'b1001000011011001: begin decoded = codeword_in ^ (288'b1 << 141); decode_result = 1'b0; end
            16'b0011011111011011: begin decoded = codeword_in ^ (288'b1 << 140); decode_result = 1'b0; end
            16'b0111100001101110: begin decoded = codeword_in ^ (288'b1 << 139); decode_result = 1'b0; end
            16'b1111110000111101: begin decoded = codeword_in ^ (288'b1 << 138); decode_result = 1'b0; end
            16'b0110100010111011: begin decoded = codeword_in ^ (288'b1 << 137); decode_result = 1'b0; end
            16'b0101011111011110: begin decoded = codeword_in ^ (288'b1 << 136); decode_result = 1'b0; end
            16'b1000111000010110: begin decoded = codeword_in ^ (288'b1 << 135); decode_result = 1'b0; end
            16'b0100001011111101: begin decoded = codeword_in ^ (288'b1 << 134); decode_result = 1'b0; end
            16'b0111010010001111: begin decoded = codeword_in ^ (288'b1 << 133); decode_result = 1'b0; end
            16'b1011011001111110: begin decoded = codeword_in ^ (288'b1 << 132); decode_result = 1'b0; end
            16'b1001100111001110: begin decoded = codeword_in ^ (288'b1 << 131); decode_result = 1'b0; end
            16'b0001101010010000: begin decoded = codeword_in ^ (288'b1 << 130); decode_result = 1'b0; end
            16'b0111000101111001: begin decoded = codeword_in ^ (288'b1 << 129); decode_result = 1'b0; end
            16'b1011111101101001: begin decoded = codeword_in ^ (288'b1 << 128); decode_result = 1'b0; end
            16'b0011100101100010: begin decoded = codeword_in ^ (288'b1 << 127); decode_result = 1'b0; end
            16'b0100111000000010: begin decoded = codeword_in ^ (288'b1 << 126); decode_result = 1'b0; end
            16'b1011100111010111: begin decoded = codeword_in ^ (288'b1 << 125); decode_result = 1'b0; end
            16'b0101011100010111: begin decoded = codeword_in ^ (288'b1 << 124); decode_result = 1'b0; end
            16'b1111110010011101: begin decoded = codeword_in ^ (288'b1 << 123); decode_result = 1'b0; end
            16'b0101110100110110: begin decoded = codeword_in ^ (288'b1 << 122); decode_result = 1'b0; end
            16'b1011111010100001: begin decoded = codeword_in ^ (288'b1 << 121); decode_result = 1'b0; end
            16'b1101100101001110: begin decoded = codeword_in ^ (288'b1 << 120); decode_result = 1'b0; end
            16'b0100000011101110: begin decoded = codeword_in ^ (288'b1 << 119); decode_result = 1'b0; end
            16'b1100011100101101: begin decoded = codeword_in ^ (288'b1 << 118); decode_result = 1'b0; end
            16'b1101110110000011: begin decoded = codeword_in ^ (288'b1 << 117); decode_result = 1'b0; end
            16'b1110110000010010: begin decoded = codeword_in ^ (288'b1 << 116); decode_result = 1'b0; end
            16'b0111100011100101: begin decoded = codeword_in ^ (288'b1 << 115); decode_result = 1'b0; end
            16'b1110011000110011: begin decoded = codeword_in ^ (288'b1 << 114); decode_result = 1'b0; end
            16'b0000111110000101: begin decoded = codeword_in ^ (288'b1 << 113); decode_result = 1'b0; end
            16'b1010110110010101: begin decoded = codeword_in ^ (288'b1 << 112); decode_result = 1'b0; end
            16'b0111000101001010: begin decoded = codeword_in ^ (288'b1 << 111); decode_result = 1'b0; end
            16'b0100111001000000: begin decoded = codeword_in ^ (288'b1 << 110); decode_result = 1'b0; end
            16'b0111011111011100: begin decoded = codeword_in ^ (288'b1 << 109); decode_result = 1'b0; end
            16'b1000001100000101: begin decoded = codeword_in ^ (288'b1 << 108); decode_result = 1'b0; end
            16'b0100101110011101: begin decoded = codeword_in ^ (288'b1 << 107); decode_result = 1'b0; end
            16'b1001010001110001: begin decoded = codeword_in ^ (288'b1 << 106); decode_result = 1'b0; end
            16'b1000110101100010: begin decoded = codeword_in ^ (288'b1 << 105); decode_result = 1'b0; end
            16'b1100110001111100: begin decoded = codeword_in ^ (288'b1 << 104); decode_result = 1'b0; end
            16'b1001011100111010: begin decoded = codeword_in ^ (288'b1 << 103); decode_result = 1'b0; end
            16'b0011111000110011: begin decoded = codeword_in ^ (288'b1 << 102); decode_result = 1'b0; end
            16'b0001010100000110: begin decoded = codeword_in ^ (288'b1 << 101); decode_result = 1'b0; end
            16'b0010110010011010: begin decoded = codeword_in ^ (288'b1 << 100); decode_result = 1'b0; end
            16'b0100000000100111: begin decoded = codeword_in ^ (288'b1 << 99); decode_result = 1'b0; end
            16'b0000101010000011: begin decoded = codeword_in ^ (288'b1 << 98); decode_result = 1'b0; end
            16'b0011100010100101: begin decoded = codeword_in ^ (288'b1 << 97); decode_result = 1'b0; end
            16'b0101011101010011: begin decoded = codeword_in ^ (288'b1 << 96); decode_result = 1'b0; end
            16'b1111011010100111: begin decoded = codeword_in ^ (288'b1 << 95); decode_result = 1'b0; end
            16'b1111110010000000: begin decoded = codeword_in ^ (288'b1 << 94); decode_result = 1'b0; end
            16'b1011000111011010: begin decoded = codeword_in ^ (288'b1 << 93); decode_result = 1'b0; end
            16'b1100011001001111: begin decoded = codeword_in ^ (288'b1 << 92); decode_result = 1'b0; end
            16'b1111000010111010: begin decoded = codeword_in ^ (288'b1 << 91); decode_result = 1'b0; end
            16'b0010101101101110: begin decoded = codeword_in ^ (288'b1 << 90); decode_result = 1'b0; end
            16'b1001101101001101: begin decoded = codeword_in ^ (288'b1 << 89); decode_result = 1'b0; end
            16'b0110111000011000: begin decoded = codeword_in ^ (288'b1 << 88); decode_result = 1'b0; end
            16'b0011100100111101: begin decoded = codeword_in ^ (288'b1 << 87); decode_result = 1'b0; end
            16'b0001010110110111: begin decoded = codeword_in ^ (288'b1 << 86); decode_result = 1'b0; end
            16'b0011010100000111: begin decoded = codeword_in ^ (288'b1 << 85); decode_result = 1'b0; end
            16'b1101010000011100: begin decoded = codeword_in ^ (288'b1 << 84); decode_result = 1'b0; end
            16'b0101111011110000: begin decoded = codeword_in ^ (288'b1 << 83); decode_result = 1'b0; end
            16'b1101001000000001: begin decoded = codeword_in ^ (288'b1 << 82); decode_result = 1'b0; end
            16'b1110011011111111: begin decoded = codeword_in ^ (288'b1 << 81); decode_result = 1'b0; end
            16'b1101110000110000: begin decoded = codeword_in ^ (288'b1 << 80); decode_result = 1'b0; end
            16'b0100010000111000: begin decoded = codeword_in ^ (288'b1 << 79); decode_result = 1'b0; end
            16'b0100000011001001: begin decoded = codeword_in ^ (288'b1 << 78); decode_result = 1'b0; end
            16'b0010000110110011: begin decoded = codeword_in ^ (288'b1 << 77); decode_result = 1'b0; end
            16'b0110101001010010: begin decoded = codeword_in ^ (288'b1 << 76); decode_result = 1'b0; end
            16'b1100001110010001: begin decoded = codeword_in ^ (288'b1 << 75); decode_result = 1'b0; end
            16'b0000011000111011: begin decoded = codeword_in ^ (288'b1 << 74); decode_result = 1'b0; end
            16'b0110100111111101: begin decoded = codeword_in ^ (288'b1 << 73); decode_result = 1'b0; end
            16'b1101110101000110: begin decoded = codeword_in ^ (288'b1 << 72); decode_result = 1'b0; end
            16'b0101010001010011: begin decoded = codeword_in ^ (288'b1 << 71); decode_result = 1'b0; end
            16'b1010000101000100: begin decoded = codeword_in ^ (288'b1 << 70); decode_result = 1'b0; end
            16'b1100011101100000: begin decoded = codeword_in ^ (288'b1 << 69); decode_result = 1'b0; end
            16'b1001001001010110: begin decoded = codeword_in ^ (288'b1 << 68); decode_result = 1'b0; end
            16'b0101111000011110: begin decoded = codeword_in ^ (288'b1 << 67); decode_result = 1'b0; end
            16'b0011010100101001: begin decoded = codeword_in ^ (288'b1 << 66); decode_result = 1'b0; end
            16'b0110111010100011: begin decoded = codeword_in ^ (288'b1 << 65); decode_result = 1'b0; end
            16'b0010010101000010: begin decoded = codeword_in ^ (288'b1 << 64); decode_result = 1'b0; end
            16'b0001010100110011: begin decoded = codeword_in ^ (288'b1 << 63); decode_result = 1'b0; end
            16'b1000000000010100: begin decoded = codeword_in ^ (288'b1 << 62); decode_result = 1'b0; end
            16'b0010111001011000: begin decoded = codeword_in ^ (288'b1 << 61); decode_result = 1'b0; end
            16'b1010111110111001: begin decoded = codeword_in ^ (288'b1 << 60); decode_result = 1'b0; end
            16'b0001011100101100: begin decoded = codeword_in ^ (288'b1 << 59); decode_result = 1'b0; end
            16'b0101110010110000: begin decoded = codeword_in ^ (288'b1 << 58); decode_result = 1'b0; end
            16'b1101000100010011: begin decoded = codeword_in ^ (288'b1 << 57); decode_result = 1'b0; end
            16'b0100001000010101: begin decoded = codeword_in ^ (288'b1 << 56); decode_result = 1'b0; end
            16'b0101101010010001: begin decoded = codeword_in ^ (288'b1 << 55); decode_result = 1'b0; end
            16'b0000101110010110: begin decoded = codeword_in ^ (288'b1 << 54); decode_result = 1'b0; end
            16'b0011001011100010: begin decoded = codeword_in ^ (288'b1 << 53); decode_result = 1'b0; end
            16'b0010001000011010: begin decoded = codeword_in ^ (288'b1 << 52); decode_result = 1'b0; end
            16'b1001010011010010: begin decoded = codeword_in ^ (288'b1 << 51); decode_result = 1'b0; end
            16'b0100010000110100: begin decoded = codeword_in ^ (288'b1 << 50); decode_result = 1'b0; end
            16'b1101011100110010: begin decoded = codeword_in ^ (288'b1 << 49); decode_result = 1'b0; end
            16'b0011101010011110: begin decoded = codeword_in ^ (288'b1 << 48); decode_result = 1'b0; end
            16'b1100011010000000: begin decoded = codeword_in ^ (288'b1 << 47); decode_result = 1'b0; end
            16'b0101100100110001: begin decoded = codeword_in ^ (288'b1 << 46); decode_result = 1'b0; end
            16'b1100100111110010: begin decoded = codeword_in ^ (288'b1 << 45); decode_result = 1'b0; end
            16'b1110110101100111: begin decoded = codeword_in ^ (288'b1 << 44); decode_result = 1'b0; end
            16'b0011000110100000: begin decoded = codeword_in ^ (288'b1 << 43); decode_result = 1'b0; end
            16'b0100101000110000: begin decoded = codeword_in ^ (288'b1 << 42); decode_result = 1'b0; end
            16'b1011010111011011: begin decoded = codeword_in ^ (288'b1 << 41); decode_result = 1'b0; end
            16'b1101100001100100: begin decoded = codeword_in ^ (288'b1 << 40); decode_result = 1'b0; end
            16'b1000100000010011: begin decoded = codeword_in ^ (288'b1 << 39); decode_result = 1'b0; end
            16'b1010111000010001: begin decoded = codeword_in ^ (288'b1 << 38); decode_result = 1'b0; end
            16'b1101001000111000: begin decoded = codeword_in ^ (288'b1 << 37); decode_result = 1'b0; end
            16'b1010110010000110: begin decoded = codeword_in ^ (288'b1 << 36); decode_result = 1'b0; end
            16'b1100110011011100: begin decoded = codeword_in ^ (288'b1 << 35); decode_result = 1'b0; end
            16'b0000010010100011: begin decoded = codeword_in ^ (288'b1 << 34); decode_result = 1'b0; end
            16'b1011110100010000: begin decoded = codeword_in ^ (288'b1 << 33); decode_result = 1'b0; end
            16'b0110000111010111: begin decoded = codeword_in ^ (288'b1 << 32); decode_result = 1'b0; end
            16'b0111111111010100: begin decoded = codeword_in ^ (288'b1 << 31); decode_result = 1'b0; end
            16'b1001110001011110: begin decoded = codeword_in ^ (288'b1 << 30); decode_result = 1'b0; end
            16'b1110111001001100: begin decoded = codeword_in ^ (288'b1 << 29); decode_result = 1'b0; end
            16'b0111001101011111: begin decoded = codeword_in ^ (288'b1 << 28); decode_result = 1'b0; end
            16'b0011000010110110: begin decoded = codeword_in ^ (288'b1 << 27); decode_result = 1'b0; end
            16'b0111000010001000: begin decoded = codeword_in ^ (288'b1 << 26); decode_result = 1'b0; end
            16'b1111010010001101: begin decoded = codeword_in ^ (288'b1 << 25); decode_result = 1'b0; end
            16'b0011011100011000: begin decoded = codeword_in ^ (288'b1 << 24); decode_result = 1'b0; end
            16'b0110001010111011: begin decoded = codeword_in ^ (288'b1 << 23); decode_result = 1'b0; end
            16'b1101101111001110: begin decoded = codeword_in ^ (288'b1 << 22); decode_result = 1'b0; end
            16'b0100010100001010: begin decoded = codeword_in ^ (288'b1 << 21); decode_result = 1'b0; end
            16'b1101000011101011: begin decoded = codeword_in ^ (288'b1 << 20); decode_result = 1'b0; end
            16'b0100000101110011: begin decoded = codeword_in ^ (288'b1 << 19); decode_result = 1'b0; end
            16'b0101011100111001: begin decoded = codeword_in ^ (288'b1 << 18); decode_result = 1'b0; end
            16'b0000111000010001: begin decoded = codeword_in ^ (288'b1 << 17); decode_result = 1'b0; end
            16'b0101000010010111: begin decoded = codeword_in ^ (288'b1 << 16); decode_result = 1'b0; end
            16'b1101100101110100: begin decoded = codeword_in ^ (288'b1 << 15); decode_result = 1'b0; end
            16'b1011101001001000: begin decoded = codeword_in ^ (288'b1 << 14); decode_result = 1'b0; end
            16'b1000011000001010: begin decoded = codeword_in ^ (288'b1 << 13); decode_result = 1'b0; end
            16'b0001010000111110: begin decoded = codeword_in ^ (288'b1 << 12); decode_result = 1'b0; end
            16'b1101110011101101: begin decoded = codeword_in ^ (288'b1 << 11); decode_result = 1'b0; end
            16'b1100111100010000: begin decoded = codeword_in ^ (288'b1 << 10); decode_result = 1'b0; end
            16'b0011001111000100: begin decoded = codeword_in ^ (288'b1 << 9); decode_result = 1'b0; end
            16'b0101001110001111: begin decoded = codeword_in ^ (288'b1 << 8); decode_result = 1'b0; end
            16'b1111111010001110: begin decoded = codeword_in ^ (288'b1 << 7); decode_result = 1'b0; end
            16'b0010001101001110: begin decoded = codeword_in ^ (288'b1 << 6); decode_result = 1'b0; end
            16'b1001001100011001: begin decoded = codeword_in ^ (288'b1 << 5); decode_result = 1'b0; end
            16'b0011100011110110: begin decoded = codeword_in ^ (288'b1 << 4); decode_result = 1'b0; end
            16'b1110110101110011: begin decoded = codeword_in ^ (288'b1 << 3); decode_result = 1'b0; end
            16'b0000100101101000: begin decoded = codeword_in ^ (288'b1 << 2); decode_result = 1'b0; end
            16'b0101100010111101: begin decoded = codeword_in ^ (288'b1 << 1); decode_result = 1'b0; end
            16'b1001110110110010: begin decoded = codeword_in ^ (288'b1 << 0); decode_result = 1'b0; end
            16'b0000000000000000: begin decoded = codeword_in; decode_result = 1'b0; end 
            default:            begin decoded = codeword_in; decode_result = 1'b1; end
        endcase
    end

    assign decode_result_out = decode_result;
    assign data_out          = decoded[287:16];

endmodule