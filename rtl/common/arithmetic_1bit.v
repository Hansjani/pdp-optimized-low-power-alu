// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Hans Jani

`timescale 1ns/1ps

module arithmetic_1bit (
    input  a,
    input  b,
    input  cin,
    output sum,
    output cout
);

    assign sum  = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));

endmodule