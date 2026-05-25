`timescale 1ns/1ps

module alu_op_iso (
    input  [31:0] a,
    input  [31:0] b,
    input  [3:0]  opcode,

    output reg [31:0] result,
    output cout,

    // Flags
    output z,  // Zero
    output c,  // Carry
    output n,  // Negative
    output v   // Overflow

    // Debug ports
    // output [31:0]carry_debug
);

    // -------------------------------
    //Operation Decode
    // -------------------------------

    wire is_arith = (opcode[3:2] == 2'b00);
    wire is_logic = (opcode[3:2] == 2'b01);
    wire is_shift = (opcode[3:2] == 2'b10);

    // -------------------------------
    // Internal Signals
    // -------------------------------
    wire [31:0] arith_res;
    wire [31:0] logic_res;
    wire [31:0] shift_res;
    wire [31:0] b_mod;
    wire cin;
    wire [1:0] op_logic = is_logic ? opcode[1:0] : 2'b00;
    wire [1:0] op_shift = is_shift ? opcode[1:0] : 2'b00;
    wire is_add = (opcode == 4'b0000);
    wire is_sub = (opcode == 4'b0001);
    wire is_inc = (opcode == 4'b0010);
    wire is_dec = (opcode == 4'b0011);
    wire is_add_sub = is_add | is_sub;

    // -------------------------------
    // Generate initial carry (ONLY when needed)
    // -------------------------------

    assign cin = is_arith && (is_sub || is_inc);

    // -------------------------------
    // Modify B for overflow detection (only SUB needs inversion)(ONLY when arithmetic unit is active)
    // -------------------------------

    wire [31:0] b_arith_pre;

    assign b_arith_pre =
        is_sub ? ~b :
        is_inc ? 32'b0 :
        is_dec ? 32'hFFFFFFFF :
        b;

    assign b_mod = is_arith ? b_arith_pre : 32'b0;

    // -------------------------------
    // Operand Isolation (Coarse Grain)
    // -------------------------------

    wire [31:0] a_arith = is_arith ? a : 32'b0;
    wire [31:0] b_arith = b_mod;

    wire [31:0] a_logic = is_logic ? a : 32'b0;
    wire [31:0] b_logic = is_logic ? b : 32'b0;

    wire [31:0] a_shift = is_shift ? a : 32'b0;

    // -------------------------------
    // Instantiate Modules
    // -------------------------------

    arithmetic_32bit arithu(
        .a(a_arith),
        .b(b_arith),
        .cin(cin),
        .result(arith_res),
        .cout(cout)
    );

    logic_unit logicu(
        .a(a_logic),
        .b(b_logic),
        .opcode(op_logic),
        .result(logic_res)
    );

    shift_unit shiftu(
        .a(a_shift),
        .opcode(op_shift),
        .result(shift_res)
    );

    // -------------------------------
    // Result Selection (MUX)
    // -------------------------------
    always @(*) begin
        case (opcode[3:2])
            2'b00: result = arith_res;
            2'b01: result = logic_res;
            2'b10: result = shift_res;
            default: result = 32'b0;
        endcase
    end

    // -------------------------------
    // FLAGS
    // -------------------------------

    // Zero flag
    assign z = (result == 32'b0);

    // Negative flag (MSB)
    assign n = result[31];

    // Carry flag (valid only for arithmetic)
    assign c = is_arith ? (
        is_add ? cout :
        is_sub ? ~cout :
        is_inc ? cout :
        is_dec ? ~cout :
        1'b0
    ) : 1'b0;

    // Overflow only for ADD and SUB
    assign v = (is_arith && is_add_sub) ? (
                (a_arith[31] & b_arith[31] & ~result[31]) |
                (~a_arith[31] & ~b_arith[31] & result[31])
            ) : 1'b0;
endmodule