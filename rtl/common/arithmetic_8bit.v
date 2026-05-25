`timescale 1ns/1ps

module arithmetic_8bit (
    input [7:0] a,
    input [7:0] b,
    input cin,
    output [7:0] result,
    output cout
);

    wire c;

    arithmetic_4bit lower4bit(a[3:0], b[3:0], cin, result[3:0], c);
    arithmetic_4bit upper4bit(a[7:4], b[7:4], c, result[7:4], cout);

endmodule