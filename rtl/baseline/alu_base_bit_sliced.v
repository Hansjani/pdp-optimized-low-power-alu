`timescale 1ns/1ps

module alu_base_bit_sliced (
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
    // Internal Signals
    // -------------------------------
    wire [31:0] arith_res;
    wire [31:0] logic_res;
    wire [31:0] shift_res;
    wire [31:0] b_mod;
    wire cin;

    // -------------------------------
    // Generate initial carry
    // -------------------------------
    assign cin =
        (opcode == 4'b0001) ? 1'b1 : // SUB
        (opcode == 4'b0010) ? 1'b1 : // INC
        (opcode == 4'b0011) ? 1'b0 : // DEC
                             1'b0;

    // -------------------------------
    // Modify B for overflow detection (only SUB needs inversion)
    // -------------------------------

    assign b_mod =
        (opcode == 4'b0001) ? ~b :           // SUB
        (opcode == 4'b0010) ? 32'b0 :        // INC
        (opcode == 4'b0011) ? 32'hFFFFFFFF : // DEC
                             b;

    // -------------------------------
    // Instantiate Modules
    // -------------------------------

    arithmetic_32bit arithu(
        .a(a),
        .b(b_mod),
        .cin(cin),
        .result(arith_res),
        .cout(cout)
    );

    logic_unit logicu(
        .a(a),
        .b(b),
        .opcode(opcode[1:0]),
        .result(logic_res)
    );

    shift_unit shiftu(
        .a(a),
        .opcode(opcode[1:0]),
        .result(shift_res)
    );

    // -------------------------------
    // Result Selection (MUX)
    // -------------------------------
    always @(*) begin
        case (opcode[3:2])
            2'b00: result = arith_res; // Arithmetic
            2'b01: result = logic_res; // Logic
            2'b10: result = shift_res; // Shift
            default: result = a;       // Safe default
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
    assign c =
        (opcode == 4'b0000) ? cout :   // ADD
        (opcode == 4'b0001) ? ~cout :  // SUB
        (opcode == 4'b0010) ? cout :   // INC
        (opcode == 4'b0011) ? ~cout :  // DEC
        1'b0;

    // Overflow only for ADD and SUB
    wire is_add_sub;
    assign is_add_sub = (opcode == 4'b0000) || // ADD
                        (opcode == 4'b0001);   // SUB

    assign v = is_add_sub ? (
                (a[31] & b_mod[31] & ~result[31]) |
                (~a[31] & ~b_mod[31] & result[31])
              ) : 1'b0;

endmodule