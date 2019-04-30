module gs_1itr(input [31:0] numerator_input,
               input [31:0] denominator_input,
               output  [31:0] numerator_out,
               output  [31:0] denominator_out);

wire [31:0] multiplication_factor;
wire [31:0] n1;
wire [31:0] d1;
mult_factor mf1(.f_i(denominator_input),
                .f_ii(multiplication_factor));

float_mult fm_denom_1(.a(multiplication_factor),     
                      .b(denominator_input),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                      .out_mult(d1/*denominator_out*/));

float_mult fm_num_1(.a(multiplication_factor),     
                    .b(numerator_input),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                    .out_mult(n1/*numerator_out*/));

assign numerator_out = n1;
assign denominator_out = d1;
endmodule             
