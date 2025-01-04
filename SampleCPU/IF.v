`include "lib/defines.vh"       //// 该文件定义了一个指令获取模块 IF，用于从指令存储器中获取指令，并将其传递给指令解码阶段（ID）
module IF(
    input wire clk,//时钟信号
    input wire rst,//复位信号
    input wire [`StallBus-1:0] stall,//暂停信号

    // input wire flush,
    // input wire [31:0] new_pc,

    input wire [`BR_WD-1:0] br_bus,//分支总线信号

    output wire [`IF_TO_ID_WD-1:0] if_to_id_bus,// 传给ID阶段的数据总线

    output wire inst_sram_en,// 指令SRAM使能信号
    output wire [3:0] inst_sram_wen,// 指令SRAM写使能信号
    output wire [31:0] inst_sram_addr,// 指令SRAM地址信号
    output wire [31:0] inst_sram_wdata // 指令SRAM写数据信号
);
    reg [31:0] pc_reg;// 程序计数器寄存器
    reg ce_reg;// 指令存储器使能寄存器
    wire [31:0] next_pc;// 下一个程序计数器值
    wire br_e;// 分支使能信号
    wire [31:0] br_addr;// 分支地址

    assign {// 从分支总线信号中提取分支使能信号和分支地址
        br_e,
        br_addr
    } = br_bus;


    always @ (posedge clk) begin// 时钟上升沿触发，更新程序计数器
        if (rst) begin
            pc_reg <= 32'hbfbf_fffc;// 复位时，程序计数器初始化为特定值
        end
        else if (stall[0]==`NoStop) begin
            pc_reg <= next_pc;// 如果没有暂停信号，更新程序计数器
        end
    end

    always @ (posedge clk) begin// 时钟上升沿触发，更新指令存储器使能信号
        if (rst) begin
            ce_reg <= 1'b0;// 复位时，指令存储器使能信号为0
        end
        else if (stall[0]==`NoStop) begin
            ce_reg <= 1'b1;// 如果没有暂停信号，使能指令存储器
        end
    end


    assign next_pc = br_e ? br_addr // 计算下一个程序计数器值
                   : pc_reg + 32'h4;// 如果有分支信号，使用分支地址，否则，程序计数器加4

    // 指令SRAM信号分配
    assign inst_sram_en = ce_reg;// 指令SRAM使能信号
    assign inst_sram_wen = 4'b0;// 指令SRAM写使能信号为0，由于是读取操作所以固定为0
    assign inst_sram_addr = pc_reg;// 指令SRAM地址信号为当前程序计数器值
    assign inst_sram_wdata = 32'b0;// 指令SRAM写数据信号为0，由于是读取操作所以固定为0
    assign if_to_id_bus = {// 传给ID阶段的数据总线
        ce_reg,
        pc_reg
    };

endmodule