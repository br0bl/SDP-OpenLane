`timescale 1ns / 1ps
(* keep_hierarchy = "yes" *)

/*
Company: RSCL
Engineer: Ben Robles
 
Create Date: 11/07/2026 10:39:50 PM
Design Name: RC4 s-array block
Module Name: sarray_block
Project Name: SDP-OpenLane
Target Devices: SKY130A, GF180MCUD
Tool Versions: xvlog Vivado 2026.1

Revision: 5.00
Revision 5.00 - File created

*/

module sarray_block (
                        input wire CLK_IN,
                        input wire [4:0] read_addr,
                        input wire write_en,
                        input wire [4:0] write_addr,
                        input wire [7:0] write_data,
                        output wire [7:0] read_data
                    );

    reg [7:0] mem [0:31];

    assign read_data = mem[read_addr];

    always @(posedge CLK_IN) begin
        if (write_en)
            mem[write_addr] <= write_data;
    end

endmodule