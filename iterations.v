module iterations(input [31:0] x_i , 
                  input  [31:0] denominator_inRange,
                  output [31:0] x_ii);

wire NaN;
wire neg_infinite;
wire pos_infinite;
wire pos_zero;
wire neg_zero;
wire [31:0] D_xi;
wire [31:0] two_minus_D_xi;
//D.xi
float_mult fmi(.a(x_i),
               .b(denominator_inRange),
               .NaN(NaN),
               .neg_infinite(neg_infinite),
               .pos_infinite(pos_infinite),
               .pos_zero(pos_zero),
               .neg_zero(neg_zero),
               .out_mult(D_xi));

// performing (2 - D.xi)
float_add_subs_v2 fasi(
                  .a({~D_xi[31],D_xi[30:0]}),
                  .b(32'h40000000),  // 2
                  .NaN(NaN),
                  .neg_infinite(neg_infinite),
                  .pos_infinite(pos_infinite),
                  .pos_zero(pos_zero),
                  .neg_zero(neg_zero),
                  .out_final(two_minus_D_xi));  

float_mult fmi2(.a(x_i),
               .b(two_minus_D_xi),
               .NaN(NaN),
               .neg_infinite(neg_infinite),
               .pos_infinite(pos_infinite),
               .pos_zero(pos_zero),
               .neg_zero(neg_zero),
               .out_mult(x_ii));

endmodule

