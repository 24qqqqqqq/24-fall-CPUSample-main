`include "defines.vh"
module regfile(
    input wire clk,// 时钟信号
    input wire [4:0] raddr1,// 读取地址1和读取地址2，分别用于指定要读取的寄存器地址
    output wire [31:0] rdata1,// 读取数据1和读取数据2，分别用于输出读取的寄存器数据
    input wire [4:0] raddr2,
    output wire [31:0] rdata2,
    
    input wire we,// 写使能信号，用于指定是否写入寄存器
    input wire [4:0] waddr,// 写入地址，用于指定要写入的寄存器地址
    input wire [31:0] wdata,// 写入数据，用于指定要写入的寄存器数据

    input wire hi_r,// 读取hi和lo寄存器的使能信号，高位寄存器
    input wire hi_we,// 写入hi和lo寄存器的使能信号，高位寄存器
    input wire [31:0] hi_data,// 写入hi和lo寄存器的数据，高位寄存器
    input wire lo_r,// 读取hi和lo寄存器的使能信号，低位寄存器
    input wire lo_we,// 写入hi和lo寄存器的使能信号，低位寄存器
    input wire [31:0] lo_data,// 写入hi和lo寄存器的数据，低位寄存器
    output wire [31:0] hilo_data// 从高位或低位寄存器读取的数据
);
    //自己加的hilo寄存器
    reg  [31:0] hi_o;
    reg  [31:0] lo_o;
    // write
    always @ (posedge clk) begin
        if (hi_we) begin
            hi_o <=  hi_data;
        end
    end
    always @ (posedge clk) begin
        if (lo_we) begin
            lo_o <= lo_data;
        end
    end
    //read
    assign hilo_data = (hi_r) ? hi_o 
                      :(lo_r) ? lo_o
                      : (32'b0);


    reg [31:0] reg_array [31:0];
    // write
    always @ (posedge clk) begin
        if (we && waddr!=5'b0) begin
            reg_array[waddr] <= wdata;
        end
    end

    // read out 1
    assign rdata1 = (raddr1 == 5'b0) ? 32'b0 : reg_array[raddr1];

    // read out2
    assign rdata2 = (raddr2 == 5'b0) ? 32'b0 : reg_array[raddr2];
endmodule