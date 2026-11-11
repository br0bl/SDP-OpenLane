`timescale 1ns / 1ps
(* keep_hierarchy = "yes" *)

/*
Company: RSCL
Engineer: Ben Robles
 
Create Date: 11/10/2026 4:20:22 PM
Design Name: RC4 s-array write path
Module Name: sarray_write
Project Name: SDP-OpenLane
Target Devices: SKY130A, GF180MCUD
Tool Versions: xvlog Vivado 2026.1

Revision: 6.00
Revision 6.00 - File created

*/

module sarray_write (
                        input wire [4:0] fsm,
                        input wire [7:0] init_index,
                        input wire [7:0] ksa_counter,
                        input wire [7:0] ksa_j,
                        input wire [7:0] prga_counter,
                        input wire [7:0] prga_j,
                        input wire [7:0] s_i,
                        input wire [7:0] s_j,
                        output reg [7:0] write_addr,
                        output reg [7:0] write_data
                    );

    localparam [4:0] 
        INIT_S = 5'd1, 
        KSA_WRITE_I = 5'd8, 
        KSA_WRITE_J = 5'd9,
        PRGA_WRITE_I = 5'd17, 
        PRGA_WRITE_J = 5'd18;

    always @* begin
        write_addr = 8'd0;
        write_data = 8'd0;

        case (fsm)
            INIT_S: begin
                write_addr = init_index;
                write_data = init_index;
            end
            KSA_WRITE_I: begin
                write_addr = ksa_counter;
                write_data = s_j;
            end
            KSA_WRITE_J: begin
                write_addr = ksa_j;
                write_data = s_i;
            end
            PRGA_WRITE_I: begin
                write_addr = prga_counter;
                write_data = s_j;
            end
            PRGA_WRITE_J: begin
                write_addr = prga_j;
                write_data = s_i;
            end
            default: begin end
        endcase
    end
endmodule