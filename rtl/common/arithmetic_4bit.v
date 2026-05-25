`timescale 1ns/1ps

module arithmetic_4bit (
    input [3:0] a,
    input [3:0] b,
    input cin,
    output [3:0] result,
    output cout
);

    wire c1, c2, c3;

    arithmetic_1bit u0 (a[0], b[0], cin, result[0], c1);
    arithmetic_1bit u1 (a[1], b[1], c1, result[1], c2);
    arithmetic_1bit u2 (a[2], b[2], c2, result[2], c3);
    arithmetic_1bit u3 (a[3], b[3], c3, result[3], cout);

endmodule