module tinyproc(input clk, output reg[7:0] result = 0);
    reg[10:0] program_mem[0:255];
    reg[7:0] data_mem[0:255];
    reg[7:0] ip = 8'hff;
    wire[7:0] ip_nxt = (instr[10:8] == 3'b100 && accumulator[7]) ? instr[7:0] : ip + 1;
    reg[10:0] instr = 0;
    reg[7:0] accumulator = 0;
    reg[7:0] index = 0;
    reg[7:0] memory_operand = 0;
    wire[7:0] data_addr = instr[7:0] + index;
    integer i;

    initial begin
        $readmemh("program.hex", program_mem);
        for (i = 0; i < 255; i = i + 1) data_mem[i] = 0;
    end

    always @(negedge clk) begin
        if (instr[10:8] == 3'b011)
            data_mem[data_addr] <= accumulator;
        else
            memory_operand <= data_mem[data_addr];
    end

    always @(posedge clk) begin
        ip <= ip_nxt;
        instr <= program_mem[ip_nxt];
        index <= (instr[10:8] == 3'b101) ? memory_operand : 0;
        case (instr[10:8])
            3'b000: accumulator <= accumulator + memory_operand; // Add
            3'b001: accumulator <= accumulator - memory_operand; // Sub
            3'b110: accumulator <= accumulator & memory_operand; // And
            3'b010: accumulator <= instr[7:0];    // Load immediate
            3'b011: if (instr[7:0] == 0) result <= accumulator; // Output
        endcase
    end
endmodule
