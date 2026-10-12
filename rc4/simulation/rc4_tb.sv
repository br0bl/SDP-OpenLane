`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Reconfigurable Space Computing Lab
// Engineer: Ben Robles
// 
// Create Date: 10/11/2026 05:19:52 PM
// Design Name: RC4 Testbench
// Module Name: rc4_tb
// Project Name: RC4
// Target Devices: ASIC
// Tool Versions: Vivado 2026.1
// Description: 
// 
// Dependencies: 
// 
// Revision: 0.01
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rc4_tb();

    parameter KEY_SIZE=32;          
    parameter PLAINTEXT_SIZE=32;

    logic clk;
    logic rst_n;
    
    logic [7:0] KEY [0:31];
    logic [7:0] PLAINTEXT [0:31];
    logic [7:0] KNOWN_CIPHERTEXT [0:31];
    logic [7:0] CAPTURED_CIPHERTEXT [0:31];

    logic [7:0] key_byte;
    logic [7:0] plain_byte;
    logic start;
    logic stop;
    logic hold;
    logic start_key_cpy;
    logic busy;
    logic read_plaintext;
    logic [7:0] enc_byte;

    rc4 rc4_dut(
        .CLK_IN(clk),
        .RESET_N_IN(rst_n),
        .KEY_SIZE_IN(KEY_SIZE),
        .KEY_BYTE_IN(key_byte),
        .PLAIN_BYTE_IN(plain_byte),
        .START_IN(start),
        .STOP_IN(stop),
        .HOLD_IN(hold),
        .START_KEY_CPY_OUT(start_key_cpy),
        .BUSY_OUT(busy),
        .READ_PLAINTEXT_OUT(read_plaintext),
        .ENC_BYTE_OUT(enc_byte)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // Generate key and known ciphertext with a python script
    
endmodule
