/* *********************************************************************** */
/* This is code for designing and testing a 4-bit Central Processing Unit (CPU) 
capable of performing some arithmetic, logical, and LOAD instruction.*/

/* Half Adder */
module HA (x,y, Sum, Co);
input x,y;
output Sum,Co;
//Boolean expressions of Sum and Carry of HA
assign Sum = x^y;
assign Co= x&y;
endmodule

/* Full Adder */
module FA (x,y,z,Co,Sum); //full adder with cascading halfadders
input x,y,z;
output Sum,Co;
wire S1,C1,C2; //intermediate signals
//Instantiate the halfadders
HA HA1 (x,y, S1,C1);
HA HA2 (S1,z, Sum,C2);
or g1(Co,C2,C1);
endmodule
/* *********************************************************************** */

/*** CODE OF 4x1 MUX using structural modeling ***/
/* 4x1 MUX CODE BEGINS HERE */
module MUX41g(Y,I0,I1,I2,I3,S0,S1);
input I0,I1,I2,I3,S0,S1;
output Y;
wire T1,T2,T3,T4,S0bar,S1bar;
not (S0bar, S0);
not (S1bar, S1);
and (T1, I0, S0bar, S1bar);
and (T2, I1, S0, S1bar);
and (T3, I2, S0bar, S1);
and (T4, I3, S0, S1);
or (Y,T1,T2,T3,T4);
endmodule
/* 4x1 MUX CODE ENDS HERE */
/* *********************************************************************** */


/*** CODE OF 1-BIT ALU using structural modeling ***/
/* 1- BIT ALU CODE BEGINS HERE */
module ALU1bit(Result,Co,a,b,Cin,b_invert,Operation);
input a,b,Cin,b_invert;
input [1:0] Operation;
output Result,Co;
wire T1,T2,T3,T4;
xor(T1,b_invert,b);
and(T2,a,T1);
or(T3,a,T1);
FA FA1(a,T1,Cin,Co,T4);
MUX41g MUX41(Result,T2,T3,T4,1'b0,Operation[0],Operation[1]);
endmodule
/* 1- BIT ALU CODE ENDS HERE */
/* *********************************************************************** */


/*** CODE OF 4-BIT ALU using hierarchical modeling ***/
/* 4- BIT ALU CODE BEGINS HERE */
module ALU4bit(Result,overflow,A,B,Operation);
input [3:0] A,B;
input [2:0] Operation;
output [3:0] Result;
output overflow;
wire C0,C1,C2;
ALU1bit ALU1(Result[0],C0,A[0],B[0],Operation[2],Operation[2],Operation[1:0]);
ALU1bit ALU2(Result[1],C1,A[1],B[1],C0,Operation[2],Operation[1:0]);
ALU1bit ALU3(Result[2],C2,A[2],B[2],C1,Operation[2],Operation[1:0]);
ALU1bit ALU4(Result[3],overlow,A[3],B[3],C2,Operation[2],Operation[1:0]);
endmodule
/* 4- BIT ALU CODE ENDS HERE */
/* *********************************************************************** */



/* CODE OF Load Instruction DECODER using ternary operators */
// Load Inst. decoder. 0 if 100, 1 otherwise
module LIDecoder(out,In);
input [2:0] In;
output out;
assign out= (In[2]&~In[1]&~In[0])?0:1;
endmodule
/* Load Inst. DECODER CODE ENDS HERE */
/* *********************************************************************** */


/* CODE OF QUADRUPLE 2x1 MUX using ternary operators */
// QUADRUPLE 2x1 MUX CODE STARTS HERE
module Quad21MUX(Y,I0,I1,S);
input [3:0] I0,I1;
input S;
output [3:0] Y;
assign Y=(~S)?I0:I1;
endmodule
/* QUADRUPLE 2x1 MUX CODE ENDS HERE */
/* *********************************************************************** */


/* 1-BIT D-FF USING BEHAVIORAL MODELING (NEG EDGE TRIGGER)*/
//D flip-flop
module DFlipFlopFE(Q,D,Clk);
input D,Clk; 
output reg Q;
always @(negedge Clk) 
begin
 Q <= D; 
end 
endmodule
//1- BIT DFF ENDS HERE
/* *********************************************************************** */


/* 9-bit INSTRUCTION REGISTER USING 1-bit DFF */
// Instruction register
module Register9Bit(Out,In,Clk);
input [8:0] In;
input Clk;
output [8:0] Out;
DFlipFlopFE df0(Out[0],In[0],Clk);
DFlipFlopFE df1(Out[1],In[1],Clk);
DFlipFlopFE df2(Out[2],In[2],Clk);
DFlipFlopFE df3(Out[3],In[3],Clk);
DFlipFlopFE df4(Out[4],In[4],Clk);
DFlipFlopFE df5(Out[5],In[5],Clk);
DFlipFlopFE df6(Out[6],In[6],Clk);
DFlipFlopFE df7(Out[7],In[7],Clk);
DFlipFlopFE df8(Out[8],In[8],Clk);
endmodule
/* INSTRUCTION REGISTER ENDS HERE */
/* *********************************************************************** */


/* 4-bit register file implemented in behavioral modeling */
module register_file (Read_Reg1,Read_Reg2,Write_Reg,Write_Data,Read_Data1,Read_Data2,CLK);
input [1:0] Read_Reg1,Read_Reg2,Write_Reg;
input [3:0] Write_Data;
input CLK;
output [3:0] Read_Data1,Read_Data2;
reg [3:0] Register[0:3];
assign Read_Data1 = Register[Read_Reg1];
assign Read_Data2 = Register[Read_Reg2];
initial Register[0] = 0;
always @(negedge CLK)
Register[Write_Reg] <= Write_Data;
endmodule
/* *********************************************************************** */


// FINAL CPU MODULE STARTS HERE *//
module CPU_4bit (Instruction, Write_Data, CLK);
input [8:0] Instruction; // 9-bits of instructions
input CLK; // clock
output [3:0] Write_Data; // 4bit output of cpu
wire [8:0] IR; // instruction register
// Declare more wires as needed
wire [3:0]A;
wire [3:0]B;
wire [3:0]Result;

/* INSTANTIATE ALL THE MODULES AS PER FIGURE 1. The OP code and other fiels of this
register that have to be
passed to other modules must be represented by their respective
indices (see the register file instance below).
*/

// Define the module for the Instruction Register and instatiate it here.
Register9Bit register(IR,Instruction,CLK);

// Define the module for the quadruple 2x1 mux and instatiate it here.
Quad21MUX q21(Write_Data,IR[5:2],Result,dectomux);

// Define the module for the LI decoder and instantiate it here.
LIDecoder lid(dectomux,IR[8:6]);

// register file (the module definition is incuded in this file)
register_file regs(IR[5:4],IR[3:2],IR[1:0],Write_Data,A,B,CLK);

// Define a module for the ALU and instantiate it here.
ALU4bit alu(Result,overflow,A,B,IR[8:6]);

endmodule
/* *********************************************************************** */




/* *********************************************************************** */

/* TESTBENCH. USE IT TO TEST THE CIRCUIT*/


// Test module. Add more instructions as provided in the test program.
module tb_CPU_4bit();
   reg [8:0] Instruction;
   reg CLK;
   wire [3:0] Write_Data;
   CPU_4bit cpu1 (Instruction, Write_Data, CLK);

   initial
   begin
      // LI  $2, 15  # load decimal 15 in $2; $2=1111, which is -1 in 2's comp
        #0 Instruction = 9'b100111110; 
        #0 CLK=1;
        #1 CLK=0; // negative edge - execute instruction

/* Machine code for the test program instructions are input here.
   Use the format shown above. Pay attention to the register
   order - the destination register is first in the assembly code
   and last (LSB) in the machine code.
   After each instruction a negative edge must be generated.
*/
	  
      //LI  $3, 8        # load decimal 8 (unsigned binary) into $3; $3= 1000, which is -8 in 2's comp
        #1 Instruction = 9'b100100011; 
        #1 CLK=1;
        #1 CLK=0; // negative edge - execute instruction
	  
      //AND $1, $2, $3   # $1 = $2 AND $3 ($1= 1000)
        #1 Instruction = 9'b000101101; 
        #1 CLK=1;
        #1 CLK=0; // negative edge - execute instruction
	  
      //SUB $3, $1, $2   # $3 = $1 - $2 = -8 - (-1) = -7 ($3=1001, which is -7 in 2's complement)
        #1 Instruction = 9'b110011011; 
        #1 CLK=1;
        #1 CLK=0; // negative edge - execute instruction
 
 
      //ADD $1, $2, $3   # $1 = $2 + $3 = -1 + (-7) = -8  ($1=1000, which is -8 in 2's complement)
        #1 Instruction = 9'b010101101; 
        #1 CLK=1;
        #1 CLK=0; // negative edge - execute instruction

      //SUB $2, $3, $1   # $2 = $3 - $1 = -7 - (-8) = 1 ($3= 0001, which is +1 in 2's comp)
        #1 Instruction = 9'b110110110; 
        #1 CLK=1;
        #1 CLK=0; // negative edge - execute instruction
 
      //OR  $3, $1, $2   # $3 = $1 OR $2 = 1001 ($3= 1000 | 0001= 1001)
        #1 Instruction = 9'b001011011; 
        #1 CLK=1;
        #1 CLK=0; // negative edge - execute instruction
   end

endmodule
/* *********************************************************************** */