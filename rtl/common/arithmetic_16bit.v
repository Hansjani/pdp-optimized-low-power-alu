// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Hans Jani

`timescale 1ns/1ps

module arithmetic_16bit (
    input [15:0] a,
    input [15:0] b,
    input cin,
    output [15:0] result,
    output cout
);

    wire c;

    arithmetic_8bit lower8bit(a[7:0], b[7:0], cin, result[7:0], c);
    arithmetic_8bit upper8bit(a[15:8], b[15:8], c, result[15:8], cout);

endmodule