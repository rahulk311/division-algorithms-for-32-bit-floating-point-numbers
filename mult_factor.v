//`include "float_add_subs_v2.v"
module mult_factor(
                   input [31:0] f_i,                  
                   output [31:0] f_ii);

//wire [31:0] f1;
///assign f1 = f_i;
// finding fi = 2 - di( or denominator_inRange)
wire invalid_output;
float_add_subs_v2 fasm( 
                  .a(32'b0_1000000_00000000_00000000_00000000), // 2 in float
                  .b({1'b1,f_i[30:0]}),
                  .NaN(invalid_output),
                  .neg_infinite(invalid_output),
                  .pos_infinite(invalid_output),
                  .pos_zero(invalid_output),
                  .neg_zero(invalid_output),
                  .out_final(f_ii));
endmodule
