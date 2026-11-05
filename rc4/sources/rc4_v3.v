`timescale 1ns / 1ps
/*
Company: RSCL
Engineer: Ben Robles
 
Create Date: 11/04/2026 04:31:15 PM
Design Name: RC4 v3
Module Name: rc4_v3
Project Name: SDP-OpenLane
Target Devices: SKY130A
Tool Versions: xvlog Vivado 2026.1 
  
Revision: 3.00
Revision 1.00 - Existing IP
Revision 2.00 - ASIC Optimization 
Revision 3.00 - Aggressive ASIC Optimization 

Additional Comments: Changes made in revision 2.00: (Still works with original testbench)
    1. Removed s-array from reset block and added its own initilization state
    2. Removed key from reset block as it always gets overwritten by key_cpy
    3. Split each KSA iteration into read, calculate, and swap cycles to reduce simultaneous array access
    4. Changed key_cpy to start KSA with i, j, and key index at zero for its new iterative calculations

    Change made in revision 3.00: (New testbench, rc4_cocotb_v3)
    1. Gave every S-array one read and write path
    2. Split PRGA iteration into eight clocks per byte to reduce simultaneous array access

MIT License

Copyright (c) 2021 Matthias Konrath

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

module rc4_v3(
                input wire CLK_IN,
                input wire RESET_N_IN,
                input wire [7:0] KEY_SIZE_IN,
                input wire [7:0] KEY_BYTE_IN,
                input wire [7:0] PLAIN_BYTE_IN,
                input wire START_IN,
                input wire STOP_IN,
                input wire HOLD_IN,
                output reg START_KEY_CPY_OUT,
                output reg BUSY_OUT,
                output reg READ_PLAINTEXT_OUT,
                output reg [7:0] ENC_BYTE_OUT
          );
    
    localparam [4:0]
        IDLE          = 5'd0,
        INIT_S        = 5'd1,
        KEY_CPY       = 5'd2,
        KSA_READ_I    = 5'd3,
        KSA_CALC_J    = 5'd4,
        KSA_READ_J    = 5'd5,
        KSA_WRITE_I   = 5'd6,
        KSA_WRITE_J   = 5'd7,
        KSA_ADVANCE   = 5'd8,
        PRGA          = 5'd9,
        PRGA_READ_I   = 5'd10,
        PRGA_CALC_J   = 5'd11,
        PRGA_READ_J   = 5'd12,
        PRGA_WRITE_I  = 5'd13,
        PRGA_WRITE_J  = 5'd14,
        PRGA_READ_T   = 5'd15,
        PRGA_OUTPUT   = 5'd16;
    
    reg [4:0] fsm;
    reg [7:0] array_s [0:255];
    reg [7:0] init_index;
    reg [7:0] key [0:31];
    reg [7:0] key_length;
    reg [7:0] key_cpy_counter;
    reg [7:0] key_index;

    reg [7:0] ksa_counter;
    reg [7:0] ksa_j;
    reg [7:0] prga_counter;
    reg [7:0] prga_j;
    reg [7:0] array_selector;
    reg [7:0] s_i;
    reg [7:0] s_j;
    reg [7:0] s_t;

    reg [7:0] s_read_addr;
    reg s_write_en;
    reg [7:0] s_write_addr;
    reg [7:0] s_write_data;
    wire [7:0] s_read_data;

    assign s_read_data = array_s[s_read_addr];

    always @* begin
        // ---- ---- ---- ---- ---- ---- ---- ----
        //          Combinational Read
        // ---- ---- ---- ---- ---- ---- ---- ----
        s_read_addr = 8'd0;
        case (fsm)
            KSA_READ_I:  s_read_addr = ksa_counter;
            KSA_READ_J:  s_read_addr = ksa_j;
            PRGA_READ_I: s_read_addr = prga_counter;
            PRGA_READ_J: s_read_addr = prga_j;
            PRGA_READ_T: s_read_addr = array_selector;
            default:     s_read_addr = 8'd0;
        endcase
    end

    always @* begin
        // ---- ---- ---- ---- ---- ---- ---- ----
        //         Combinational Write 
        // ---- ---- ---- ---- ---- ---- ---- ----
        s_write_en   = 1'b0;
        s_write_addr = 8'd0;
        s_write_data = 8'd0;
        case (fsm)
            INIT_S: begin
                s_write_en   = 1'b1;
                s_write_addr = init_index;
                s_write_data = init_index;
            end
            KSA_WRITE_I: begin
                s_write_en   = 1'b1;
                s_write_addr = ksa_counter;
                s_write_data = s_j;
            end
            KSA_WRITE_J: begin
                s_write_en   = 1'b1;
                s_write_addr = ksa_j;
                s_write_data = s_i;
            end
            PRGA_WRITE_I: begin
                s_write_en   = 1'b1;
                s_write_addr = prga_counter;
                s_write_data = s_j;
            end
            PRGA_WRITE_J: begin
                s_write_en   = 1'b1;
                s_write_addr = prga_j;
                s_write_data = s_i;
            end
            default: begin end
        endcase
    end


    always@(posedge CLK_IN) begin
        // ---- ---- ---- ---- ---- ---- ---- ----
        //            Clocked Write
        // ---- ---- ---- ---- ---- ---- ---- ----
        if(RESET_N_IN && !STOP_IN && s_write_en)
            array_s[s_write_addr] <= s_write_data;
    end

    /*
    RC4 - FSM
    States:
        IDLE        --> Nothing happens here (state after STOP signal or a reset)
        ----
        INIT_S      --> Initialzes s array
            |
        KEY_CPY     --> The key gets copied into the internal storage
            |
        KSA         --> The Key-Scheduling-Alorithm is executed (Each iteration takes six clocks)
            |
        PRGA <---|  --> The Psoudo-Random-Generation-Algorithm is executed (continous output is generated)
            |____|
    */
    
    always @(posedge CLK_IN) begin 
        // ---- ---- ---- ---- ---- ---- ---- ----
        //              RESET
        // ---- ---- ---- ---- ---- ---- ---- ----
        if (!RESET_N_IN || STOP_IN) begin
            fsm <= IDLE;
            START_KEY_CPY_OUT <= 1'b0;
            BUSY_OUT <= 1'b0;
            READ_PLAINTEXT_OUT <= 1'b0;
            ENC_BYTE_OUT <= 8'd0;
            key_length <= 8'd0;
            key_cpy_counter <= 8'd0;
            init_index <= 8'd0;
            key_index <= 8'd0;
            ksa_counter <= 8'd0;
            ksa_j <= 8'd0;
            prga_counter <= 8'd0;
            prga_j <= 8'd0;
            array_selector <= 8'd0;
            s_i <= 8'd0;
            s_j <= 8'd0;
            s_t <= 8'd0;
        end 
        else begin
            START_KEY_CPY_OUT <= 1'b0;
            READ_PLAINTEXT_OUT <= 1'b0;

            case(fsm)
            // ---- ---- ---- ---- ---- ---- ---- ----
            //                  IDLE
            // ---- ---- ---- ---- ---- ---- ---- ----
            IDLE: begin
                if (START_IN) begin
                    fsm <= INIT_S;
                    BUSY_OUT <= 1'b1;
                    init_index <= 8'd0;
                end
            end
            // ---- ---- ---- ---- ---- ---- ---- ----
            //                 INIT_S
            // ---- ---- ---- ---- ---- ---- ---- ----
            INIT_S: begin
                if(init_index == 8'hFF) begin
                    fsm <= KEY_CPY;
                    START_KEY_CPY_OUT <= 1'b1;
                end
                else init_index <= init_index + 8'd1;
            end
            // ---- ---- ---- ---- ---- ---- ---- ----
            //                KEY COPY
            // ---- ---- ---- ---- ---- ---- ---- ----
            KEY_CPY: begin
                if (START_KEY_CPY_OUT) begin
                    key_length <= KEY_SIZE_IN;
                    key_cpy_counter <= 8'd0;
                end
                else begin
                    key[key_cpy_counter] <= KEY_BYTE_IN;

                    if (key_cpy_counter == key_length - 8'd1) begin
                        key_cpy_counter <= 8'd0;
                        ksa_counter <= 8'd0;
                        ksa_j <= 8'd0;
                        key_index <= 8'd0;
                        fsm <= KSA_READ_I;
                    end
                    else begin
                        key_cpy_counter <= key_cpy_counter + 8'd1;
                    end
                end 
            end 
            // ---- ---- ---- ---- ---- ---- ---- ----
            //      Key-Scheduling-Alorithm (KSA)
            // ---- ---- ---- ---- ---- ---- ---- ----
            KSA_READ_I: begin
                s_i <= s_read_data;
                fsm <= KSA_CALC_J;
            end

            KSA_CALC_J: begin
                ksa_j <= ksa_j + s_i + key[key_index];
                fsm <= KSA_READ_J;
            end

            KSA_READ_J: begin
                s_j <= s_read_data;
                fsm <= KSA_WRITE_I;
            end

            KSA_WRITE_I: begin
                fsm <= KSA_WRITE_J;
            end

            KSA_WRITE_J: begin
                fsm <= KSA_ADVANCE;
            end

            KSA_ADVANCE: begin
                if (ksa_counter == 8'hFF) begin
                    prga_counter <= 8'd0;
                    prga_j <= 8'd0;
                    fsm <= PRGA;
                end
                else begin
                    ksa_counter <= ksa_counter + 8'd1;

                    if (key_index == key_length - 8'd1)
                        key_index <= 8'd0;
                    else
                        key_index <= key_index + 8'd1;

                    fsm <= KSA_READ_I;
                end
            end
            // ---- ---- ---- ---- ---- ---- ---- ----
            // Psoudo-Random-Generation-Algorithm (PRGA)
            // ---- ---- ---- ---- ---- ---- ---- ----
            PRGA: begin
                if (!HOLD_IN) begin
                    prga_counter <= prga_counter + 8'd1;
                    fsm <= PRGA_READ_I;
                end
            end

            PRGA_READ_I: begin
                s_i <= s_read_data;
                fsm <= PRGA_CALC_J;
            end

            PRGA_CALC_J: begin
                prga_j <= prga_j + s_i;
                fsm <= PRGA_READ_J;
            end

            PRGA_READ_J: begin
                s_j <= s_read_data;
                fsm <= PRGA_WRITE_I;
            end

            PRGA_WRITE_I: begin
                fsm <= PRGA_WRITE_J;
            end

            PRGA_WRITE_J: begin
                array_selector <= s_i + s_j;
                fsm <= PRGA_READ_T;
            end

            PRGA_READ_T: begin
                s_t <= s_read_data;
                READ_PLAINTEXT_OUT <= 1'b1;
                fsm <= PRGA_OUTPUT;
            end

            PRGA_OUTPUT: begin
                ENC_BYTE_OUT <= s_t ^ PLAIN_BYTE_IN;
                fsm <= PRGA;
            end
            default: fsm <= IDLE;
        endcase
        end 
    end
endmodule