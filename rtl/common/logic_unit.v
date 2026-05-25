`timescale 1ns/1ps
(* keep_hierarchy = "yes" *)

module logic_unit (
    input  [31:0] a,
    input  [31:0] b,
    input  [1:0] opcode, // 00=AND, 01=OR, 10=XOR, 11=NOT
    output reg [31:0] result
);

    always @(*) begin
        case(opcode)
            2'b00: result = a & b;
            2'b01: result = a | b;
            2'b10: result = a ^ b;
            2'b11: result = ~a;
        endcase
    end

endmodule