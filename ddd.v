# multiplication-matrix

[코드2]
Verilog Code for Matrix Multiplication - for 2 by 2 Matrices
Here is the Verilog code for a simple matrix multiplier. The input matrices are of fixed size 2 by 2 and so the output matrix is also fixed at 2 by 2. I have kept the size of each matrix element as 8 bits.

Verilog doesn't allow you to have multi dimensional arrays as inputs or output ports. So I have converted the three dimensional input and output ports to one dimensional array. Inside the module I have created 3D temporary variables which are initialized to the inputs at the beginning of the always statement. 

The matrix multiplier is also synthesisable. When synthesised for Virtex 4 fpga, using Xilinx XST, a maximum combinational path delay of 9 ns was obtained. 

Matrix multiplier:

//Module for calculating Res = A*B
//Where A,B and C are 2 by 2 matrices.
module Mat_mult(A,B,Res);

    //input and output ports.
    //The size 32 bits which is 2*2=4 elements,each of which is 8 bits wide.    
    input [31:0] A;
    input [31:0] B;
    output [31:0] Res;
    //internal variables    
    reg [31:0] Res;
    reg [7:0] A1 [0:1][0:1];
    reg [7:0] B1 [0:1][0:1];
    reg [7:0] Res1 [0:1][0:1]; 
    integer i,j,k;

    always@ (A or B)
    begin
    //Initialize the matrices-convert 1 D to 3D arrays
        {A1[0][0],A1[0][1],A1[1][0],A1[1][1]} = A;
        {B1[0][0],B1[0][1],B1[1][0],B1[1][1]} = B;
        i = 0;
        j = 0;
        k = 0;
        {Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]} = 32'd0; //initialize to zeros.
        //Matrix multiplication
        for(i=0;i < 2;i=i+1)
            for(j=0;j < 2;j=j+1)
                for(k=0;k < 2;k=k+1)
                    Res1[i][j] = Res1[i][j] + (A1[i][k] * B1[k][j]);
        //final output assignment - 3D array to 1D array conversion.            
        Res = {Res1[0][0],Res1[0][1],Res1[1][0],Res1[1][1]};            
    end 

endmodule

Testbench Code:

module tb;

    // Inputs
    reg [31:0] A;
    reg [31:0] B;
    // Outputs
    wire [31:0] Res;

    // Instantiate the Unit Under Test (UUT)
    Mat_mult uut (
        .A(A), 
        .B(B), 
        .Res(Res)
    );

    initial begin
        // Apply Inputs
        A = 0;  B = 0;  #100;
        A = {8'd1,8'd2,8'd3,8'd4};
        B = {8'd5,8'd6,8'd7,8'd8};
    end
      
endmodule

[코드3]
Below is the Verilog code for 3x3 Systolic Array Matrix Multiplier (let me give it a name in short:SAMM !).
I am going to take this code as an example for several other articles that i am publishing in the blog.
So keep an eye on this always !

//===================================
`timescale 1ns/1ps
//----------------------------------------------------------------
module sam3( a_row0,a_row1,a_row2, //matrix a inputs
b_col0,b_col1,b_col2, //matrix b inputs
c_row0,c_row1,c_row2, //output matrix c
en,reset,clock,mult_over);//control signals
output reg [9:0] c_row0,c_row1,c_row2;
output reg mult_over;
//output mult_over;
input [3:0] a_row0,a_row1,a_row2,b_col0,b_col1,b_col2;
input en,reset,clock;
reg [3:0] aa_row0[2:0],aa_row1[2:0],aa_row2[2:0],bb_col0[2:0],bb_col1[2:0],bb_col2[2:0];//memory to hold matrix a and b;a:rowwise;b:columnwise
reg [9:0] out_reg00,out_reg01,out_reg02,out_reg10,out_reg11,out_reg12,out_reg20,out_reg21,out_reg22;//output registers to hold matrix c
//reg [9:0] cc_row0[2:0],cc_row1[2:0],cc_row2[2:0];
//reg mult_over,all_over;
reg [3:0] q;
//wire [3:0] q;
wire [9:0] cc_row_00,cc_row_01,cc_row_02,cc_row_10,cc_row_11,cc_row_12,cc_row_20,cc_row_21,cc_row_22;
//===========================================================
always @(posedge clock)
begin
if(en & !reset)
q<=q+1;
else
q<=0;
if(q>=11) mult_over=1; else mult_over=0; //multiplication is over after 11 clock cycles
//5+3 clock cycles to fill the systolic processor pipeline stage
//3 clock cycle for multiplication
end
//============================================================
//count_clock clock_counter(.en(en),.reset(reset),.clock(clock),.q(q),.mult_over(mult_over));
//============================================================
//============================================================
always @(posedge clock)
begin
if((!en) & reset)
begin
aa_row0[0]<=0;aa_row0[1]<=0;aa_row0[2]<=0;
aa_row1[0]<=0;aa_row1[1]<=0;aa_row1[2]<=0;
aa_row2[0]<=0;aa_row2[1]<=0;aa_row2[2]<=0;
bb_col0[0]<=0;bb_col0[1]<=0;bb_col0[2]<=0;
bb_col1[0]<=0;bb_col1[1]<=0;bb_col1[2]<=0;
bb_col2[0]<=0;bb_col2[1]<=0;bb_col2[2]<=0;
out_reg00<=0;out_reg01<=0;out_reg02<=0;
out_reg10<=0;out_reg11<=0;out_reg12<=0;
out_reg20<=0;out_reg21<=0;out_reg22<=0;
c_row0<=0;
c_row1<=0;
c_row2<=0;
end
else
begin
aa_row0[0]<=a_row0;aa_row0[1]<=aa_row0[0];aa_row0[2]<=aa_row0[1];
aa_row1[0]<=a_row1;aa_row1[1]<=aa_row1[0];aa_row1[2]<=aa_row1[1];
aa_row2[0]<=a_row2;aa_row2[1]<=aa_row2[0];aa_row2[2]<=aa_row2[1];
bb_col0[0]<=b_col0;bb_col0[1]<=bb_col0[0];bb_col0[2]<=bb_col0[1];
bb_col1[0]<=b_col1;bb_col1[1]<=bb_col1[0];bb_col1[2]<=bb_col1[1];
bb_col2[0]<=b_col2;bb_col2[1]<=bb_col2[0];bb_col2[2]<=bb_col2[1];
//end
if(!mult_over) //if multiplication is over send result to output one by one
begin //else update output registers with accumulated results
c_row0<=0;
c_row1<=0;
c_row2<=0;
out_reg00<=cc_row_00;
out_reg01<=cc_row_01;
out_reg02<=cc_row_02;

out_reg10<=cc_row_10;
out_reg11<=cc_row_11;
out_reg12<=cc_row_12;
out_reg20<=cc_row_20;
out_reg21<=cc_row_21;
out_reg22<=cc_row_22;
end
else
begin
c_row0<=out_reg00;out_reg00<=out_reg01;out_reg01<=out_reg02;
c_row1<=out_reg10;out_reg10<=out_reg11;out_reg11<=out_reg12;
c_row2<=out_reg20;out_reg20<=out_reg21;out_reg21<=out_reg22;
end
end
end //end of if-else loop
//==============================================================
//instantiate macs
//===================================================================
mac mac00(.row_element(aa_row0[0]),.col_element(bb_col0[0]),.mac_out(cc_row_00),.reset(reset),.clock(clock));
mac mac01(.row_element(aa_row0[1]),.col_element(bb_col1[0]),.mac_out(cc_row_01),.reset(reset),.clock(clock));
mac mac02(.row_element(aa_row0[2]),.col_element(bb_col2[0]),.mac_out(cc_row_02),.reset(reset),.clock(clock));
mac mac10(.row_element(aa_row1[0]),.col_element(bb_col0[1]),.mac_out(cc_row_10),.reset(reset),.clock(clock));
mac mac11(.row_element(aa_row1[1]),.col_element(bb_col1[1]),.mac_out(cc_row_11),.reset(reset),.clock(clock));
mac mac12(.row_element(aa_row1[2]),.col_element(bb_col2[1]),.mac_out(cc_row_12),.reset(reset),.clock(clock));
mac mac20(.row_element(aa_row2[0]),.col_element(bb_col0[2]),.mac_out(cc_row_20),.reset(reset),.clock(clock));
mac mac21(.row_element(aa_row2[1]),.col_element(bb_col1[2]),.mac_out(cc_row_21),.reset(reset),.clock(clock));
mac mac22(.row_element(aa_row2[2]),.col_element(bb_col2[2]),.mac_out(cc_row_22),.reset(reset),.clock(clock));
endmodule

Tags: Verilog
