`timescale 1ns / 1ps

/*
Company: RSCL
Engineer: Ben Robles
 
Create Date: 11/07/2026 10:39:50 PM
Design Name: RC4 s-array block
Module Name: sarray_block
Project Name: SDP-OpenLane
Target Devices: SKY130A
Tool Versions: xvlog Vivado 2026.1 
*/

module sarray(
                input wire CLK_IN,
                input wire [7:0] read_addr,
                input wire write_en,
                input wire [7:0] write_addr,
                input wire [7:0] write_data,
                output reg  [7:0] read_data
            );

    wire [2:0] read_select;
    wire [4:0] local_read_addr;

    wire [2:0] write_select;
    wire [4:0] local_write_addr;

    assign read_select      = read_addr[7:5];
    assign local_read_addr  = read_addr[4:0];

    assign write_select     = write_addr[7:5];
    assign local_write_addr = write_addr[4:0];

    wire write_en_0;
    wire write_en_1;
    wire write_en_2;
    wire write_en_3;
    wire write_en_4;
    wire write_en_5;
    wire write_en_6;
    wire write_en_7;

    assign write_en_0 = write_en && (write_select == 3'd0);
    assign write_en_1 = write_en && (write_select == 3'd1);
    assign write_en_2 = write_en && (write_select == 3'd2);
    assign write_en_3 = write_en && (write_select == 3'd3);
    assign write_en_4 = write_en && (write_select == 3'd4);
    assign write_en_5 = write_en && (write_select == 3'd5);
    assign write_en_6 = write_en && (write_select == 3'd6);
    assign write_en_7 = write_en && (write_select == 3'd7);

    wire [7:0] read_data_0;
    wire [7:0] read_data_1;
    wire [7:0] read_data_2;
    wire [7:0] read_data_3;
    wire [7:0] read_data_4;
    wire [7:0] read_data_5;
    wire [7:0] read_data_6;
    wire [7:0] read_data_7;

    sarray_block sarray_1 (
        .CLK_IN (CLK_IN),
        .read_addr (local_read_addr),
        .read_data (read_data_0),
        .write_en (write_en_0),
        .write_addr (local_write_addr),
        .write_data (write_data)
    );

    sarray_block sarray_2 (
        .CLK_IN (CLK_IN),
        .read_addr (local_read_addr),
        .read_data (read_data_1),
        .write_en (write_en_1),
        .write_addr (local_write_addr),
        .write_data (write_data)
    );

    sarray_block sarray_3 (
        .CLK_IN (CLK_IN),
        .read_addr (local_read_addr),
        .read_data (read_data_2),
        .write_en (write_en_2),
        .write_addr (local_write_addr),
        .write_data (write_data)
    );

    sarray_block sarray_4 (
        .CLK_IN (CLK_IN),
        .read_addr (local_read_addr),
        .read_data (read_data_3),
        .write_en (write_en_3),
        .write_addr (local_write_addr),
        .write_data (write_data)
    );

    sarray_block sarray_5 (
        .CLK_IN (CLK_IN),
        .read_addr (local_read_addr),
        .read_data (read_data_4),
        .write_en (write_en_4),
        .write_addr (local_write_addr),
        .write_data (write_data)
    );

    sarray_block sarray_6 (
        .CLK_IN (CLK_IN),
        .read_addr (local_read_addr),
        .read_data (read_data_5),
        .write_en (write_en_5),
        .write_addr (local_write_addr),
        .write_data (write_data)
    );

    sarray_block sarray_7 (
        .CLK_IN (CLK_IN),
        .read_addr (local_read_addr),
        .read_data (read_data_6),
        .write_en (write_en_6),
        .write_addr (local_write_addr),
        .write_data (write_data)
    );

    sarray_block sarray_8 (
        .CLK_IN (CLK_IN),
        .read_addr (local_read_addr),
        .read_data (read_data_7),
        .write_en (write_en_7),
        .write_addr (local_write_addr),
        .write_data (write_data)
    );

    always @* begin
        case (read_select)
            3'd0: read_data = read_data_0;
            3'd1: read_data = read_data_1;
            3'd2: read_data = read_data_2;
            3'd3: read_data = read_data_3;
            3'd4: read_data = read_data_4;
            3'd5: read_data = read_data_5;
            3'd6: read_data = read_data_6;
            3'd7: read_data = read_data_7;
            default: read_data = 8'hxx;
        endcase
    end

endmodule