// SPDX-License-Identifier: MIT
// Copyright (c) 2026 Hans Jani

`timescale 1ns/1ps
(* keep_hierarchy = "yes" *)

module arithmetic_32bit (
    input [31:0] a,
    input [31:0] b,
    input cin,
    output [31:0] result,
    output cout
);

    wire c;

    arithmetic_16bit lower16bit(a[15:0], b[15:0], cin, result[15:0], c);
    arithmetic_16bit upper16bit(a[31:16], b[31:16], c, result[31:16], cout);

endmodule