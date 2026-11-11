`timescale 1ns / 1ps

/*
Company: RSCL
Engineer: Ben Robles
 
Create Date: 11/07/2026 10:39:50 PM
Design Name: RC4 s-array block
Module Name: sarray_block
Project Name: SDP-OpenLane
Target Devices: SKY130A, GF180MCUD
Tool Versions: xvlog Vivado 2026.1 

Revision: 6.00
Revision 5.00 - File created
Revision 6.00 - Made a bus for write address and data. Added block generation

*/

module sarray(
                input wire CLK_IN,
                input wire [7:0] read_addr,
                input wire write_en,
                input wire [63:0] write_addr_bus,
                input wire [63:0] write_data_bus,
                output reg  [7:0] read_data
            );

    wire [2:0] read_select;
    wire [4:0] local_read_addr;
    wire [63:0] read_data_bus;

    wire [2:0] write_select;

    assign read_select = read_addr[7:5];
    assign local_read_addr = read_addr[4:0];

    assign write_select = write_addr_bus[7:5];

    genvar k;
    generate
        for(k = 0; k < 8; k = k + 1) begin: sarray_g_blk
            wire blk_write_en;
            assign blk_write_en = write_en && (write_select == k);

            sarray_block sarray_u_blk (
                .CLK_IN(CLK_IN),
                .read_addr(local_read_addr),
                .read_data(read_data_bus[8*k +: 8]),
                .write_en(blk_write_en),
                .write_addr(write_addr_bus[8*k +: 5]),
                .write_data(write_data_bus[8*k +: 8])
            );
        end
    endgenerate

    always @* begin
        case (read_select)
            3'd0: read_data = read_data_bus[7:0];
            3'd1: read_data = read_data_bus[15:8];
            3'd2: read_data = read_data_bus[23:16];
            3'd3: read_data = read_data_bus[31:24];
            3'd4: read_data = read_data_bus[39:32];
            3'd5: read_data = read_data_bus[47:40];
            3'd6: read_data = read_data_bus[55:48];
            3'd7: read_data = read_data_bus[63:56];
            default: read_data = 8'hxx;
        endcase
    end

endmodule