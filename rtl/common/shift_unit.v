`timescale 1ns/1ps
(* keep_hierarchy = "yes" *)

module shift_unit (
    input  [31:0] a,
    input  [1:0] opcode, // 00=SHL, 01=SHR, 10=SaR
    output reg [31:0] result
);

    always @(*) begin
        case(opcode)
            2'b00: result = a << 1;
            2'b01: result = a >> 1;
            2'b10: result = $signed(a) >>> 1;
            default: result = a;
        endcase
    end

endmodule