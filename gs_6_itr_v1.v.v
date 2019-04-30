module gs_6itr_v1(
          input [31:0] numerator,
          input [31:0] denominator ,
          output reg NaN,
          output reg neg_infinite,
          output reg pos_infinite,
          output reg pos_zero,
          output reg neg_zero,
          output [31:0] out_division );

wire [7:0] expnt_numerator;

wire [7:0] expnt;
wire [22:0] mntsa; 
assign expnt = denominator[30:23];
assign mntsa = denominator[22:0];
assign expnt_numerator = numerator[30:23];
//assign out_sign = numerator[31] ^ denominator[31];

//wire NaN1;
//wire neg_infinite1;
//wire pos_infinite1;
//wire pos_zero1;
//wire neg_zero1;

wire [31:0] f1;
wire [31:0] f2;
wire [31:0] f3;
wire [31:0] f4;
wire [31:0] f5;
wire [31:0] f6;

wire [31:0] d1;
wire [31:0] d2;
wire [31:0] d3;
wire [31:0] d4;
wire [31:0] d5;
wire [31:0] d6;

wire [31:0] n1;
wire [31:0] n2;
wire [31:0] n3;
wire [31:0] n4;
wire [31:0] n5;
wire [31:0] n6;
wire invalid_output;

reg [7:0] shift_required ;
reg [31:0] denominator_inRange;
reg [31:0] numerator_after_shift;
                
always@(*)
 begin
   //some corner cases
    if(numerator[31] ==1'b1 && numerator[30:23] == 8'd255 && numerator[22:0]==23'd0 ) 
       neg_infinite = 1'b1; else neg_infinite = 1'b0;
    
    if(numerator[31] ==1'b0 && numerator[30:23] == 8'd255 && numerator[22:0]==23'd0 ) 
       pos_infinite = 1'b1; else pos_infinite = 1'b0;
    
    if(numerator[31] ==1'b1 && numerator[30:23] == 8'd0   && numerator[22:0] ==23'd0)  
       neg_zero     = 1'b1; else neg_zero     = 1'b0;
    
    if(numerator[31] ==1'b0 && numerator[30:23] == 8'd0   && numerator[22:0] ==23'd0) 
       pos_zero     = 1'b1; else pos_zero     = 1'b0;
    
    if((numerator[30:23] == 8'd255 && numerator != 23'd0)              //NaN      
                            ||      
       (denominator[30:23] == 8'd255 && denominator[20:0] !=23'd0)     //NaN
                            ||        
       ((numerator[30:23] == 8'd0  && numerator[22:0] ==23'd0) &&      //when both numbers are zero
        (denominator[30:23] == 8'd0 && denominator[22:0] ==23'd0)) 
                            || 
       ((numerator[30:23] == 8'd255 && numerator[22:0]==23'd0) &&     //when both numbers are infinite
        (denominator[30:23] == 8'd255 && denominator[22:0] ==23'd0))  
                            ||       
       ((numerator[30:23] == 8'd0  && numerator[22:0] ==23'd0) &&     //numerator is zero and denominator is infinite
        (denominator[30:23] == 8'd255 && denominator[22:0] ==23'd0)) 
                            ||
       ((denominator[30:23] == 8'd255 && denominator[22:0] ==23'd0) &&  //numerator is infinite and denominator is zero         
       (numerator[30:23] == 8'd0  && numerator[22:0] ==23'd0))) 
      begin  
         NaN = 1'b1;    // in above cases output of division is not a number{NaN}
      end
      else NaN = 1'b0;
  // corner cases end

  denominator_inRange = {1'b0 ,8'd126,mntsa};   // denominator will be in range from 0.5 to 1 
  shift_required =   8'd126 - expnt;   // exponent shift required in numerator for balancing.

  numerator_after_shift = {1'b0 ,(expnt_numerator + shift_required) , numerator[22:0]};  // numerator after exponent shift
 
end
//1st multiplication factor
mult_factor mf1(.f_i(denominator_inRange),
                .f_ii(f1));

float_mult fm_denom_1(.a(f1),     
                      .b(denominator_inRange),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                      .out_mult(d1));

float_mult fm_num_1(.a(f1),     
                    .b(numerator_after_shift),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                    .out_mult(n1));
//////////////////////////////////
mult_factor mf2(.f_i(d1),
                .f_ii(f2));

float_mult fm_denom_2(.a(f2),     
                      .b(d1),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                      .out_mult(d2));

float_mult fm_num_2(.a(f2),     
                    .b(n1),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                    .out_mult(n2));

////////////////////////
mult_factor mf3(.f_i(d2),
                .f_ii(f3));

float_mult fm_denom_3(.a(f3),     
                      .b(d2),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                      .out_mult(d3));

float_mult fm_num_3(.a(f3),     
                    .b(n2),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                    .out_mult(n3));
////////////////////////////////////////////////////////
mult_factor mf4(.f_i(d3),
                .f_ii(f4));

float_mult fm_denom_4(.a(f4),     
                      .b(d3),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                      .out_mult(d4));

float_mult fm_num_4(.a(f4),     
                    .b(n3),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                    .out_mult(n4));
////////////////////////////////////////////////////////
mult_factor mf5(.f_i(d4),
                .f_ii(f5));

float_mult fm_denom_5(.a(f5),     
                      .b(d4),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                      .out_mult(d5));

float_mult fm_num_5(.a(f5),     
                    .b(n4),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                    .out_mult(n5));
////////////////////////////////////////////////////////
mult_factor mf6(.f_i(d5),
                .f_ii(f6));

float_mult fm_denom_6(.a(f6),     
                      .b(d5),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                     .out_mult(d6));

float_mult fm_num_6(.a(f5),     
                    .b(n5),
                      .NaN(),
                      .neg_infinite(),
                      .pos_infinite(),
                      .pos_zero(),
                      .neg_zero(),
                   .out_mult(n6));
assign out_division = (numerator[31] ^ denominator[31]) ? ({1'b1,n6[30:0]}) : n6;
endmodule
