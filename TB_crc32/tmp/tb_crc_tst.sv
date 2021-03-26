module crc32;

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------
  //
  // G(x) = x32 + x26 + x23 + x22 + x16 + x12 + x11 + x10 + x8 + x7 + x5 + x4 + x2 + x1 + 1
  //
  function bit [31:0] crc_32x1 (input bit [31:0] crc, input bit d);
    bit msb;
  begin
    msb       = crc[31];
    crc_32x1  = crc << 1;

    crc_32x1[ 0] = d ^ msb;
    crc_32x1[ 1] = d ^ msb ^ crc[ 0];
    crc_32x1[ 2] = d ^ msb ^ crc[ 1];
    crc_32x1[ 4] = d ^ msb ^ crc[ 3];
    crc_32x1[ 5] = d ^ msb ^ crc[ 4];
    crc_32x1[ 7] = d ^ msb ^ crc[ 6];
    crc_32x1[ 8] = d ^ msb ^ crc[ 7];
    crc_32x1[10] = d ^ msb ^ crc[ 9];
    crc_32x1[11] = d ^ msb ^ crc[10];
    crc_32x1[12] = d ^ msb ^ crc[11];
    crc_32x1[16] = d ^ msb ^ crc[15];
    crc_32x1[22] = d ^ msb ^ crc[21];
    crc_32x1[23] = d ^ msb ^ crc[22];
    crc_32x1[26] = d ^ msb ^ crc[25];
  end
  endfunction
  //
  //
  //
  function bit [31:0] crc_32x8(input bit [31:0] crc, input bit [7:0] data);
    int i;
  begin
    crc_32x8 = crc;
    for (i = 8; i > 0; i--) begin
      crc_32x8 = crc_32x1 (crc_32x8, data[i-1]);
    end
  end
  endfunction

  //------------------------------------------------------------------------------------------------------
  //
  //------------------------------------------------------------------------------------------------------

  int unsigned crc32_tx, crc32_rx;
  byte unsigned data [128];

  initial begin : main
  //
  // generate tx packet
  //
    // init crc
    crc32_tx = 32'hFFFF_FFFF;
    // count crc
    for (int i = 0; i < 128; i++) begin
      data[i]  = $urandom;
      crc32_tx = crc_32x8(crc32_tx, data[i]);
    end
    // put crc to data packet, we must to put " The complement of this 32-bit sequence is the CRC-32. "
    crc32_tx = ~crc32_tx;
  //
  // receive rx packet
  //
    // init crc
    crc32_rx = 32'hFFFF_FFFF;
    // count crc
    for (int i = 0; i < 128; i++) begin
      crc32_rx = crc_32x8(crc32_rx, data[i]);
    end
    crc32_rx = crc_32x8(crc32_rx, crc32_tx[31:24]);
    crc32_rx = crc_32x8(crc32_rx, crc32_tx[23:16]);
    crc32_rx = crc_32x8(crc32_rx, crc32_tx[15: 8]);
    crc32_rx = crc_32x8(crc32_rx, crc32_tx[7 : 0]);
    // check with magic world 32'hC704DD7B
    if (crc32_rx != 32'hC704DD7B)
      $display("get bad crc %h", crc32_rx);
    else
      $display("get good crc %h", crc32_rx);
  end

endmodule