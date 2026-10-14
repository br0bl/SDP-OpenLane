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
// Revision: 1.00
// Revision 0.01 - File Created
// Revision 1.00 - Working first pass
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rc4_tb();

    logic clk;
    logic rst_n;

    // ---- ---- ---- ---- ---- ---- ---- ----
    //              LOAD MEMORY
    // ---- ---- ---- ---- ---- ---- ---- ----

    logic [7:0] METADATA [0:1];
    logic [7:0] KEY [0:15];
    logic [7:0] PLAINTEXT [0:255];
    logic [7:0] KNOWN_CIPHERTEXT [0:255];

    int key_size;
    int plaintext_size;

    initial begin
        $readmemh("metadata.mem",   METADATA);
        $readmemh("key.mem",        KEY);
        $readmemh("plaintext.mem",  PLAINTEXT);
        $readmemh("ciphertext.mem", KNOWN_CIPHERTEXT);      

        key_size = int'(METADATA[0]);
        plaintext_size = int'(METADATA[1]);
    end

    // ---- ---- ---- ---- ---- ---- ---- ----
    //              RC4 INTERFACE
    // ---- ---- ---- ---- ---- ---- ---- ----

    logic [7:0] key_byte;
    logic [7:0] plain_byte;
    logic start;
    logic stop;
    logic hold;
    logic start_key_cpy;
    logic busy;
    logic read_plaintext;
    logic [7:0] enc_byte;

    logic [7:0] CAPTURED_CIPHERTEXT [0:255];

    rc4 rc4_dut(
        .CLK_IN(clk),
        .RESET_N_IN(rst_n),
        .KEY_SIZE_IN(key_size),
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

    // ---- ---- ---- ---- ---- ---- ---- ----
    //                  CLOCK
    // ---- ---- ---- ---- ---- ---- ---- ----

    initial clk = 0;
    always #2 clk = ~clk;

    // ---- ---- ---- ---- ---- ---- ---- ----
    //               KEYSTREAM
    // ---- ---- ---- ---- ---- ---- ---- ----

    logic sending_key;
    int key_counter;

    always_ff @(posedge clk) begin
        if (!rst_n || stop) begin
            sending_key <= 0;
            key_counter <= 0;
            key_byte    <= 0;
        end 
        else if (start_key_cpy || sending_key) begin
            key_byte    <= KEY[key_counter];
            key_counter <= key_counter + 1;
            sending_key <= (key_counter + 1 < key_size);
        end 
        else begin
            key_byte <= 0;
        end
    end

    // ---- ---- ---- ---- ---- ---- ---- ----
    //             I/O STREAM 
    // ---- ---- ---- ---- ---- ---- ---- ----

    logic sending;
    logic drive_valid;
    logic dut_valid;
    int plain_counter;
    int cipher_counter;

    always_ff @(posedge clk) begin
        if (!rst_n || stop) begin
            sending       <= 0;
            drive_valid   <= 0;
            dut_valid     <= 0;
            plain_counter <= 0;
            cipher_counter <= 0;
            plain_byte    <= 0;
        end
        else begin
            drive_valid <= 0;

            if (read_plaintext || sending) begin
                if (plain_counter < plaintext_size) begin
                    plain_byte    <= PLAINTEXT[plain_counter];
                    drive_valid   <= 1;
                    plain_counter <= plain_counter + 1;
                    sending       <= (plain_counter + 1 < plaintext_size);
                end
            end

            dut_valid <= drive_valid;

            if (dut_valid) begin
                CAPTURED_CIPHERTEXT[cipher_counter] <= enc_byte;
                cipher_counter <= cipher_counter + 1;
            end
        end
    end

    // ---- ---- ---- ---- ---- ---- ---- ----
    //             MAIN
    // ---- ---- ---- ---- ---- ---- ---- ----

    int error;
    int x;

    initial begin
        rst_n = 0;
        start = 0;
        stop  = 0;
        hold  = 0;
        error = 0;
        
        @(negedge clk) rst_n = 1;
        start <= 1;

        @(negedge clk) start <= 0;

        wait (cipher_counter == plaintext_size);
        #1;

        for (x = 0; x < plaintext_size; x++) begin
            if (KNOWN_CIPHERTEXT[x] !== CAPTURED_CIPHERTEXT[x]) begin
                $display("[!] The known ciphertext does not match the captured ciphertext --> Element ID: %d / Known: 0x%H / Captured: 0x%H ", x, KNOWN_CIPHERTEXT[x], CAPTURED_CIPHERTEXT[x]);
                error++;
            end
        end    

        if(error !== 0) $display("Test failed %0d mismatches", error);
        else $display("Test passed");
        $finish;
    end
    
endmodule
