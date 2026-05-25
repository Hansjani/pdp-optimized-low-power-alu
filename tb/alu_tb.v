`timescale 1ns/1ps

module alu_tb;

reg  [31:0] a, b;
reg  [3:0]  opcode;

wire [31:0] result;
wire cout, z, c, n, v;

// =========================================================
// DUT SELECTION (FIXED)
// =========================================================

`ifdef BASELINE
    alu_base_bit_sliced dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .cout(cout),
        .z(z),
        .c(c),
        .n(n),
        .v(v)
    );

`elsif OP_ISO
    alu_op_iso dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .cout(cout),
        .z(z),
        .c(c),
        .n(n),
        .v(v)
    );

`elsif CLK_GATE
    alu_clk_gate dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .cout(cout),
        .z(z),
        .c(c),
        .n(n),
        .v(v)
    );

`elsif MULTI_VT
    alu_multi_vt dut (
        .a(a),
        .b(b),
        .opcode(opcode),
        .result(result),
        .cout(cout),
        .z(z),
        .c(c),
        .n(n),
        .v(v)
    );

`else
    initial begin
        $display("❌ ERROR: No DUT selected");
        $finish;
    end
`endif

// =========================================================
// VCD CONTROL (FINAL FIX - CORRECT)
// =========================================================

reg [1023:0] dumpfile;

initial begin

    // ✅ Take filename from script
    if ($value$plusargs("VCD_OUTPUT=%s", dumpfile)) begin
        $display("Writing VCD to: %s", dumpfile);
        $dumpfile(dumpfile);
    end else begin
        $display("Using default VCD file");
        $dumpfile("waves/default.vcd");
    end

    // 🔥 Dump ONLY DUT hierarchy (BEST for OpenROAD)
    $dumpvars(0, alu_tb);

end

// =========================================================
// GOLDEN MODEL
// =========================================================
reg [31:0] exp_result;
reg exp_c, exp_z, exp_n, exp_v;

integer i;
integer errors;

task compute_expected;
    reg [32:0] temp;
    reg [31:0] b_mod;
begin
    case (opcode[3:2])

        2'b00: begin
            case (opcode[1:0])
                2'b00: temp = a + b;
                2'b01: temp = a + (~b) + 1;
                2'b10: temp = a + 1;
                2'b11: temp = a - 1;
            endcase

            exp_result = temp[31:0];

            // Carry
            case (opcode)
                4'b0000: exp_c = cout;   // ADD
                4'b0001: exp_c = ~cout;  // SUB
                4'b0010: exp_c = cout;   // INC
                4'b0011: exp_c = ~cout;  // DEC
                default: exp_c = 0;
            endcase

            // Overflow
            if (opcode == 4'b0000) begin
                exp_v = (a[31] == b[31]) && (exp_result[31] != a[31]);
            end
            else if (opcode == 4'b0001) begin
                b_mod = ~b;
                exp_v = (a[31] == b_mod[31]) && (exp_result[31] != a[31]);
            end
            else begin
                exp_v = 0;
            end

        end

        2'b01: begin
            case (opcode[1:0])
                2'b00: exp_result = a & b;
                2'b01: exp_result = a | b;
                2'b10: exp_result = a ^ b;
                2'b11: exp_result = ~a;
            endcase
            exp_c = 0;
            exp_v = 0;
        end

        2'b10: begin
            case (opcode[1:0])
                2'b00: exp_result = a << 1;
                2'b01: exp_result = a >> 1;
                2'b10: exp_result = $signed(a) >>> 1;
                default: exp_result = a;
            endcase
            exp_c = 0;
            exp_v = 0;
        end

        default: begin
            exp_result = a;
            exp_c = 0;
            exp_v = 0;
        end
    endcase

    exp_z = (exp_result == 0);
    exp_n = exp_result[31];
end
endtask

// =========================================================
// TEST SEQUENCE
// =========================================================
initial begin

    errors = 0;

    $display("\n==============================");
    $display("Starting Unified ALU Test...");
    $display("==============================\n");

    #1;

    // Edge cases
    a=0; b=0; opcode=0; #5; compute_expected(); check_result("Edge1");
    a=32'hFFFFFFFF; b=1; opcode=0; #5; compute_expected(); check_result("Edge2");
    a=32'h7FFFFFFF; b=1; opcode=0; #5; compute_expected(); check_result("Edge3");

    // Random
    for (i=0; i<1000; i=i+1) begin
        a = $random;
        b = $random;
        opcode = ($random % 12 + 12) % 12;
        #5;
        compute_expected();
        check_result("Random");
    end

    if (errors == 0)
        $display("✅ ALL PASSED");
    else
        $display("❌ %0d ERRORS", errors);

    $finish;
end

// =========================================================
// CHECK TASK
// =========================================================
task check_result(input [100*8:0] name);
begin
    if (result !== exp_result ||
        c !== exp_c ||
        z !== exp_z ||
        n !== exp_n ||
        v !== exp_v) begin

        $display("❌ FAIL (%s)", name);
        $display("A=%h B=%h OPCODE=%b", a,b,opcode);
        $display("RES=%h EXP=%h", result, exp_result);

        errors = errors + 1;
    end
end
endtask

endmodule