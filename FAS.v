module  FAS (data_valid, data, clk, rst, fir_d, fir_valid, fft_valid, done, freq,
 fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8,
 fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);
input clk, rst;
input data_valid;
input [15:0] data; //S IIIIIII FFFFFFFF

output fir_valid, fft_valid;
output signed [15:0] fir_d;
output signed [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
output signed [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
output done;
output [3:0] freq; 

reg fir_valid, fft_valid;
reg signed [15:0] fir_d;
reg signed [31:0] fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8;
reg signed [31:0] fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0;
reg done;
reg [3:0] freq; 


//=======================FRR=====================
// 存要用的 data
reg signed [15:0] data_reg[31:0];
// 計算什麼時候要開始把資料輸出 fir_d
reg [10:0] count_fir;
// 取得 coeff
` include "./dat/FIR_coefficient.dat"
// loop 用
reg [5:0] i, j;
// 用來存 data*coeff
reg signed [35:0] s0, s1, s2, s3, s4, s5, s6, s7, s8, s9, s10, s11, s12, s13, s14, s15, sum;


// 處理把資料往後移
always @(posedge clk or posedge rst)
begin
    if (rst) begin
       // 把 data_reg reset 成 0
       for (i = 0 ; i < 31 ; i=i+1) begin
           data_reg[i] <= 16'd0;
       end
       count_fir <= 0;
    end
    else begin
        // 都要往後退一格
        for ( j = 0 ; j < 31; j=j+1) begin
            data_reg[j+1] <= data_reg[j];
        end
        data_reg[0] <= data;
        // c = c +1
        count_fir <= count_fir + 1'b1; 
    end
end

// 計算 sum
always @(posedge clk or posedge rst) begin
    if (rst) begin
        //sum 
        sum  <= 36'd0;
        s0   <= 36'd0;
        s1   <= 36'd0;
        s2   <= 36'd0;
        s3   <= 36'd0;
        s4   <= 36'd0;
        s5   <= 36'd0;
        s6   <= 36'd0;
        s7   <= 36'd0;
        s8   <= 36'd0;
        s9   <= 36'd0;
        s10  <= 36'd0;
        s11  <= 36'd0;
        s12  <= 36'd0;
        s13  <= 36'd0;
        s14  <= 36'd0;
        s15  <= 36'd0;
    end
    else begin        
        //datapath pipeline
        s0   <= (data_reg[0] +data_reg[31]) * FIR_C00;
        s1   <= (data_reg[1] +data_reg[30]) * FIR_C01;
        s2   <= (data_reg[2] +data_reg[29]) * FIR_C02;
        s3   <= (data_reg[3] +data_reg[28]) * FIR_C03;
        s4   <= (data_reg[4] +data_reg[27]) * FIR_C04;
        s5   <= (data_reg[5] +data_reg[26]) * FIR_C05;
        s6   <= (data_reg[6] +data_reg[25]) * FIR_C06;
        s7   <= (data_reg[7] +data_reg[24]) * FIR_C07;
        s8   <= (data_reg[8] +data_reg[23]) * FIR_C08;
        s9   <= (data_reg[9] +data_reg[22]) * FIR_C09;
        s10  <= (data_reg[10]+data_reg[21]) * FIR_C10;
        s11  <= (data_reg[11]+data_reg[20]) * FIR_C11;
        s12  <= (data_reg[12]+data_reg[19]) * FIR_C12;
        s13  <= (data_reg[13]+data_reg[18]) * FIR_C13;
        s14  <= (data_reg[14]+data_reg[17]) * FIR_C14;
        s15  <= (data_reg[15]+data_reg[16]) * FIR_C15;
        // 這是前一次結果的 sum
        sum  <= (s0+s1)+(s2+s3)+(s4+s5)+(s6+s7)+(s8+s9)+(s10+s11)+(s12+s13)+(s14+s15);
        // sum 四捨五入
        fir_d <= sum[31:16]+sum[31];
        if (count_fir > 33) begin
            fir_valid<=1;
        end
        // 還不知道什麼時候要 down
        /*
        if (count_fir > 1024) begin
            fir_valid<=0;
            count_fir<=0;
        end
        */
    end
end

//=======================FFT===============================
// 會用的 w 參數
// W_real
parameter signed [31:0] W_R0 = 32'h00010000;
parameter signed [31:0] W_R1 = 32'h0000EC83;
parameter signed [31:0] W_R2 = 32'h0000B504;
parameter signed [31:0] W_R3 = 32'h000061F7;
parameter signed [31:0] W_R4 = 32'h00000000;
parameter signed [31:0] W_R5 = 32'hFFFF9E09;
parameter signed [31:0] W_R6 = 32'hFFFF4AFC;
parameter signed [31:0] W_R7 = 32'hFFFF137D;
// W_imag
parameter signed [31:0] W_I0 = 32'h00000000;
parameter signed [31:0] W_I1 = 32'hFFFF9E09;
parameter signed [31:0] W_I2 = 32'hFFFF4AFC;
parameter signed [31:0] W_I3 = 32'hFFFF137D;
parameter signed [31:0] W_I4 = 32'hFFFF0000;
parameter signed [31:0] W_I5 = 32'hFFFF137D;
parameter signed [31:0] W_I6 = 32'hFFFF4AFC;
parameter signed [31:0] W_I7 = 32'hFFFF9E09;


// 存要處理的 16 筆資料
reg signed [15:0] fir_reg[15:0];
reg signed [79:0] xr0, xr1, xr2, xr3, xr4, xr5, xr6, xr7, xr8, xr9, xr10, xr11, xr12, xr13, xr14, xr15;
reg signed [79:0] xi0, xi1, xi2, xi3, xi4, xi5, xi6, xi7, xi8, xi9, xi10, xi11, xi12, xi13, xi14, xi15;

// 計算是否滿16筆 (1111) 則再收一筆就16了
reg [4:0] count_fft;

// 控制下一個計算
reg stage1, stage2, stage3, stage4; //1:s1 2:s2 3:s3 4:s4

// 負責存 fir_d
always @(posedge clk or posedge rst) begin
    if (rst) begin
        fir_reg[0]  <= 16'b0; 
        fir_reg[1]  <= 16'b0; 
        fir_reg[2]  <= 16'b0;
        fir_reg[3]  <= 16'b0;
        fir_reg[4]  <= 16'b0;
        fir_reg[5]  <= 16'b0;
        fir_reg[6]  <= 16'b0;
        fir_reg[7]  <= 16'b0;
        fir_reg[8]  <= 16'b0;
        fir_reg[9]  <= 16'b0;
        fir_reg[10] <= 16'b0;
        fir_reg[11] <= 16'b0;
        fir_reg[12] <= 16'b0;
        fir_reg[13] <= 16'b0;
        fir_reg[14] <= 16'b0;
        fir_reg[15] <= 16'b0;
        count_fft <= 5'b0;
        stage1 <= 1'b0;
        stage2 <= 1'b0;
        stage3 <= 1'b0;
        stage4 <= 1'b0;
        xr0 <= 80'b0;
        xr1 <= 80'b0;
        xr2 <= 80'b0;
        xr3 <= 80'b0;
        xr4 <= 80'b0;
        xr5 <= 80'b0;
        xr6 <= 80'b0;
        xr7 <= 80'b0;
        xr8 <= 80'b0;
        xr9 <= 80'b0;
        xr10 <= 80'b0;
        xr11 <= 80'b0;
        xr12 <= 80'b0;
        xr13 <= 80'b0;
        xr14 <= 80'b0;
        xr15 <= 80'b0;
        xi0 <= 80'b0;
        xi1 <= 80'b0;
        xi2 <= 80'b0;
        xi3 <= 80'b0;
        xi4 <= 80'b0;
        xi5 <= 80'b0;
        xi6 <= 80'b0;
        xi7 <= 80'b0;
        xi8 <= 80'b0;
        xi9 <= 80'b0;
        xi10 <= 80'b0;
        xi11 <= 80'b0;
        xi12 <= 80'b0;
        xi13 <= 80'b0;
        xi14 <= 80'b0;
        xi15 <= 80'b0;
    end
    else begin
        // 先確認可以用 fir_d 的值
        if ( count_fir > 34) begin
            fir_reg[count_fft] <= fir_d; //第一筆就是正確的值 15
            count_fft <= count_fft + 1'b1; //16
            if (count_fft == 5'b10000) begin //15
                count_fft <= 5'b1;
                stage1 <= 1'b1;
                xr0 <= fir_reg[0];
                xr1 <= fir_reg[1];
                xr2 <= fir_reg[2];
                xr3 <= fir_reg[3];
                xr4 <= fir_reg[4];
                xr5 <= fir_reg[5];
                xr6 <= fir_reg[6];
                xr7 <= fir_reg[7];
                xr8 <= fir_reg[8];
                xr9 <= fir_reg[9];
                xr10 <= fir_reg[10];
                xr11 <= fir_reg[11];
                xr12 <= fir_reg[12];
                xr13 <= fir_reg[13];
                xr14 <= fir_reg[14];
                xr15 <= fir_reg[15];
                fir_reg[0] <=fir_d;
            end 

        end        
    end
end

// calc for stage 1 
always @(posedge clk or posedge rst) begin
    if (stage1 == 1) begin
        xr0 <= xr0 + xr8;
        xi0 <= xi0 + xi8;
        xr8 <=  ((xr0-xr8)*W_R0)/*+((xi8-xi0)*W_I0)*/;
        xi8 <=  /*((xr0-xr8)*W_I0)+*/((xi0-xi8)*W_R0);

        xr1 <= xr1 + xr9;
        xi1 <= xi1 + xi9;
        xr9 <=  ((xr1-xr9)*W_R1)+((xi9-xi1)*W_I1);
        xi9 <=  ((xr1-xr9)*W_I1)+((xi1-xi9)*W_R1);

        xr2 <= xr2 + xr10;
        xi2 <= xi2 + xi10;
        xr10 <= ((xr2-xr10)*W_R2)+((xi10-xi2)*W_I2);
        xi10 <= ((xr2-xr10)*W_I2)+((xi2-xi10)*W_R2);

        xr3 <= xr3 + xr11;
        xi3 <= xi3 + xi11;
        xr11 <= ((xr3-xr11)*W_R3)+((xi11-xi3)*W_I3);
        xi11 <= ((xr3-xr11)*W_I3)+((xi3-xi11)*W_R3);

        xr4 <= xr4 + xr12;
        xi4 <= xi4 + xi12;
        xr12 <= /*((xr4-xr12)*W_R4)+*/((xi12-xi4)*W_I4);
        xi12 <= ((xr4-xr12)*W_I4)/*+((xi4-xi12)*W_R4)*/;

        xr5 <= xr5 + xr13;
        xi5 <= xi5 + xi13;
        xr13 <= ((xr5-xr13)*W_R5)+((xi13-xi5)*W_I5);
        xi13 <= ((xr5-xr13)*W_I5)+((xi5-xi13)*W_R5);

        xr6 <= xr6 + xr14;
        xi6 <= xi6 + xi14;
        xr14 <= ((xr6-xr14)*W_R6)+((xi14-xi6)*W_I6);
        xi14 <= ((xr6-xr14)*W_I6)+((xi6-xi14)*W_R6);

        xr7 <= xr7 + xr15;
        xi7 <= xi7 + xi15;
        xr15 <= ((xr7-xr15)*W_R7)+((xi15-xi7)*W_I7);
        xi15 <= ((xr7-xr15)*W_I7)+((xi7-xi15)*W_R7);

        stage1 <= 1'b0;
        stage2 <= 1'b1;
    end
end


//calc for stage 2
always @(posedge clk or posedge rst) begin
    if (stage2 == 1) begin
        xr0 <= xr0 + xr4;
        xi0 <= xi0 + xi4;
        xr4 <= ((xr0-xr4)*W_R0)/*+((xi4-xi0)*W_I0)*/;
        xi4 <= /*((xr0-xr4)*W_I0)+*/((xi0-xi4)*W_R0);

        xr1 <= xr1 + xr5;
        xi1 <= xi1 + xi5;
        xr5 <= ((xr1-xr5)*W_R2)+((xi5-xi1)*W_I2);
        xi5 <= ((xr1-xr5)*W_I2)+((xi1-xi5)*W_R2);

        xr2 <= xr2 + xr6;
        xi2 <= xi2 + xi6;
        xr6 <= /*((xr2-xr6)*W_R4)+*/((xi6-xi2)*W_I4);
        xi6 <= ((xr2-xr6)*W_I4)/*+((xi2-xi6)*W_R4)*/;

        xr3 <= xr3 + xr7;
        xi3 <= xi3 + xi7;
        xr7 <= ((xr3-xr7)*W_R6)+((xi7-xi3)*W_I6);
        xi7 <= ((xr3-xr7)*W_I6)+((xi3-xi7)*W_R6);

        xr8 <= xr8 + xr12;
        xi8 <= xi8 + xi12;
        xr12 <= ((xr8-xr12)*W_R0)/*+((xi12-xi8)*W_I0)*/;
        xi12 <= /*((xr8-xr12)*W_I0)+*/((xi8-xi12)*W_R0);

        xr9 <= xr9 + xr13;
        xi9 <= xi9 + xi13;
        xr13 <= ((xr9-xr13)*W_R2)+((xi13-xi9)*W_I2);
        xi13 <= ((xr9-xr13)*W_I2)+((xi9-xi13)*W_R2);

        xr10 <= xr10 + xr14;
        xi10 <= xi10 + xi14;
        xr14 <= /*((xr10-xr14)*W_R4)+*/((xi14-xi10)*W_I4);
        xi14 <= ((xr10-xr14)*W_I4)/*+((xi10-xi14)*W_R4)*/;

        xr11 <= xr11 + xr15;
        xi11 <= xi11 + xi15;
        xr15 <= ((xr11-xr15)*W_R6)+((xi15-xi11)*W_I6);
        xi15 <= ((xr11-xr15)*W_I6)+((xi11-xi15)*W_R6);

        stage2 <= 1'b0;
        stage3 <= 1'b1;
    end
end

//calc for stage 3
always @(posedge clk or posedge rst) begin
    if (stage3 == 1) begin
        xr0 <= xr0 + xr2;
        xi0 <= xi0 + xi2;
        xr2 <= ((xr0-xr2)*W_R0)/*+((xi2-xi0)*W_I0)*/;
        xi2 <= /*((xr0-xr2)*W_I0)+*/((xi0-xi2)*W_R0);

        xr1 <= xr1 + xr3;
        xi1 <= xi1 + xi3;
        xr3 <= /*((xr1-xr3)*W_R4)+*/((xi3-xi1)*W_I4);
        xi3 <= ((xr1-xr3)*W_I4)/*+((xi1-xi3)*W_R4)*/;

        xr4 <= xr4 + xr6;
        xi4 <= xi4 + xi6;
        xr6 <= ((xr4-xr6)*W_R0)/*+((xi6-xi4)*W_I0)*/;
        xi6 <= /*((xr4-xr6)*W_I0)+*/((xi4-xi6)*W_R0);

        xr5 <= xr5 + xr7;
        xi5 <= xi5 + xi7;
        xr7 <= /*((xr5-xr7)*W_R4)+*/((xi7-xi5)*W_I4);
        xi7 <= ((xr5-xr7)*W_I4)/*+((xi5-xi7)*W_R4)*/;

        xr8 <= xr8 + xr10;
        xi8 <= xi8 + xi10;
        xr10 <= ((xr8-xr10)*W_R0)/*+((xi10-xi8)*W_I0)*/;
        xi10 <= /*((xr8-xr10)*W_I0)+*/((xi8-xi10)*W_R0);

        xr9 <= xr9 + xr11;
        xi9 <= xi9 + xi11;
        xr11 <= /*((xr9-xr11)*W_R4)+*/((xi11-xi9)*W_I4);
        xi11 <= ((xr9-xr11)*W_I4)/*+((xi9-xi11)*W_R4)*/;

        xr12 <= xr12 + xr14;
        xi12 <= xi12 + xi14;
        xr14 <= ((xr12-xr14)*W_R0)/*+((xi14-xi12)*W_I0)*/;
        xi14 <= /*((xr12-xr14)*W_I0)+*/((xi12-xi14)*W_R0);

        xr13 <= xr13 + xr15;
        xi13 <= xi13 + xi15;
        xr15 <= /*((xr13-xr15)*W_R4)+*/((xi15-xi13)*W_I4);
        xi15 <= ((xr13-xr15)*W_I4)/*+((xi13-xi15)*W_R4)*/;
        stage3 <= 1'b0;
        stage4 <= 1'b1;
        //fft_valid <= 1'b1;
    end
end


// calc for stage 4
//先處理數字
wire signed [79:0] yr0, yr1, yr2, yr3, yr4, yr5, yr6, yr7, yr8, yr9, yr10, yr11, yr12, yr13, yr14, yr15;
wire signed [79:0] yi0, yi1, yi2, yi3, yi4, yi5, yi6, yi7, yi8, yi9, yi10, yi11, yi12, yi13, yi14, yi15;
assign yr0 = xr0 + xr1;
assign yi0 = xi0 + xi1;
assign yr1 = ((xr0-xr1)*W_R0)/*+((xi1-xi0)*W_I0)*/;
assign yi1 = /*((xr0-xr1)*W_I0)+*/((xi0-xi1)*W_R0);

assign yr2 = xr2 + xr3;
assign yi2 = xi2 + xi3;
assign yr3 = ((xr2-xr3)*W_R0)/*+((xi3-xi2)*W_I0)*/;
assign yi3 = /*((xr2-xr3)*W_I0)+*/((xi2-xi3)*W_R0);

assign yr4 = xr4 + xr5;
assign yi4 = xi4 + xi5;
assign yr5 = ((xr4-xr5)*W_R0)/*+((xi5-xi4)*W_I0)*/;
assign yi5 = /*((xr4-xr5)*W_I0)+*/((xi4-xi5)*W_R0);

assign yr6 = xr6 + xr7;
assign yi6 = xi6 + xi7;
assign yr7 = ((xr6-xr7)*W_R0)/*+((xi7-xi6)*W_I0)*/;
assign yi7 = /*((xr6-xr7)*W_I0)+*/((xi6-xi7)*W_R0);

assign yr8 = xr8 + xr9;
assign yi8 = xi8 + xi9;
assign yr9 = ((xr8-xr9)*W_R0)/*+((xi9-xi8)*W_I0)*/;
assign yi9 = /*((xr8-xr9)*W_I0)+*/((xi8-xi9)*W_R0);

assign yr10 = xr10 + xr11;
assign yi10 = xi10 + xi11;
assign yr11 = ((xr10-xr11)*W_R0)/*+((xi11-xi10)*W_I0)*/;
assign yi11 = /*((xr10-xr11)*W_I0)+*/((xi10-xi11)*W_R0);

assign yr12 = xr12 + xr13;
assign yi12 = xi12 + xi13;
assign yr13 = ((xr12-xr13)*W_R0)/*+((xi13-xi12)*W_I0)*/;
assign yi13 = /*((xr12-xr13)*W_I0)+*/((xi12-xi13)*W_R0);

assign yr14 = xr14 + xr15;
assign yi14 = xi14 + xi15;
assign yr15 = ((xr14-xr15)*W_R0)/*+((xi15-xi14)*W_I0)*/;
assign yi15 = /*((xr14-xr15)*W_I0)+*/((xi14-xi15)*W_R0);
//只做截取的部分
always @(posedge clk or posedge rst) begin
    if(stage4 == 1) begin
        xr0  <= 80'b0;
        xi0  <= 80'b0;
        xr1  <= 80'b0;
        xi1  <= 80'b0;
        xr2  <= 80'b0;
        xi2  <= 80'b0;
        xr3  <= 80'b0;
        xi3  <= 80'b0;
        xr4  <= 80'b0;
        xi4  <= 80'b0;
        xr5  <= 80'b0;
        xi5  <= 80'b0;
        xr6  <= 80'b0;
        xi6  <= 80'b0;
        xr7  <= 80'b0;
        xi7  <= 80'b0;
        xr8  <= 80'b0;
        xi8  <= 80'b0;
        xr9  <= 80'b0;
        xi9  <= 80'b0;
        xr10 <= 80'b0;
        xi10 <= 80'b0;
        xr11 <= 80'b0;
        xi11 <= 80'b0;
        xr12 <= 80'b0;
        xi12 <= 80'b0;
        xr13 <= 80'b0;
        xi13 <= 80'b0;
        xr14 <= 80'b0;
        xi14 <= 80'b0;
        xr15 <= 80'b0;
        xi15 <= 80'b0;

    
        fft_d0  <= {yr0[15:0], yi0[15:0]};
        fft_d1  <= {yr8[31:16], yi8[31:16]};
        fft_d2  <= {yr4[31:16], yi4[31:16]};
        fft_d3  <= {yr12[47:32], yi12[47:32]};
        fft_d4  <= {yr2[31:16], yi2[31:16]};
        fft_d5  <= {yr10[47:32], yi10[47:32]};
        fft_d6  <= {yr6[47:32], yi6[47:32]};
        fft_d7  <= {yr14[63:48], yi14[63:48]};
        fft_d8  <= {yr1[31:16], yi1[31:16]};
        fft_d9  <= {yr9[47:32], yi9[47:32]};
        fft_d10 <= {yr5[47:32], yi5[47:32]};
        fft_d11 <= {yr13[63:48], yi13[63:48]};
        fft_d12 <= {yr3[47:32], yi3[47:32]};
        fft_d13 <= {yr11[63:48], yi11[63:48]};
        fft_d14 <= {yr7[63:48], yi7[63:48]};
        fft_d15 <= {yr15[79:64], yi15[79:64]};
        fft_valid<=1'b1;
        stage4 <= 1'b0;
        stage5 <=1'b1; //開始做分析
    end
end


//=======================Analysis======================
// 算值
reg signed [31:0] f0, f1, f2, f3, f4, f5, f6, f7, f8, f9, f10, f11, f12, f13, f14, f15;
always @(posedge clk or posedge rst) begin
    if (fft_valid == 1'b1) begin
        fft_valid <= 1'b0;
    end
    // 可以用 fft_d0 來看了
    if (stage5 <= 1'b1) begin
        f0 <= (fft_d0[31:16]*fft_d0[31:16])+(fft_d0[15:0]*fft_d0[15:0]);
        f1 <= (fft_d1[31:16]*fft_d1[31:16])+(fft_d1[15:0]*fft_d1[15:0]);
        f2 <= (fft_d2[31:16]*fft_d2[31:16])+(fft_d2[15:0]*fft_d2[15:0]);
        f3 <= (fft_d3[31:16]*fft_d3[31:16])+(fft_d3[15:0]*fft_d3[15:0]);
        f4 <= (fft_d4[31:16]*fft_d4[31:16])+(fft_d4[15:0]*fft_d4[15:0]);
        f5 <= (fft_d5[31:16]*fft_d5[31:16])+(fft_d5[15:0]*fft_d5[15:0]);
        f6 <= (fft_d6[31:16]*fft_d6[31:16])+(fft_d6[15:0]*fft_d6[15:0]);
        f7 <= (fft_d7[31:16]*fft_d7[31:16])+(fft_d7[15:0]*fft_d7[15:0]);
        f8 <= (fft_d8[31:16]*fft_d8[31:16])+(fft_d8[15:0]*fft_d8[15:0]);
        f9 <= (fft_d9[31:16]*fft_d9[31:16])+(fft_d9[15:0]*fft_d9[15:0]);
        f10 <= (fft_d10[31:16]*fft_d10[31:16])+(fft_d10[15:0]*fft_d10[15:0]);
        f11 <= (fft_d11[31:16]*fft_d11[31:16])+(fft_d11[15:0]*fft_d11[15:0]);
        f12 <= (fft_d12[31:16]*fft_d12[31:16])+(fft_d12[15:0]*fft_d12[15:0]);
        f13 <= (fft_d13[31:16]*fft_d13[31:16])+(fft_d13[15:0]*fft_d13[15:0]);
        f14 <= (fft_d14[31:16]*fft_d14[31:16])+(fft_d14[15:0]*fft_d14[15:0]);
        f15 <= (fft_d15[31:16]*fft_d15[31:16])+(fft_d15[15:0]*fft_d15[15:0]);
    end

end

endmodule

