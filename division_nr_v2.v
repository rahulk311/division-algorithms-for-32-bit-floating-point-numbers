module division_nr_v2( input [31:0] numerator,
                    input [31:0] denominator ,
                    output reg NaN,
                    output reg neg_infinite,
                    output reg pos_infinite,
                    output reg pos_zero,
                    output reg neg_zero,
                    output [31:0] out_division );
      
wire [7:0] expnt_numerator;

wire out_sign;
wire sign;
wire [7:0] expnt;
wire [22:0] mntsa;

assign sign  = denominator[31];
assign expnt = denominator[30:23];
assign mntsa = denominator[22:0];
assign expnt_numerator = numerator[30:23];
assign out_sign = numerator[31] ^ denominator[31];

wire NaN1;
wire neg_infinite1;
wire pos_infinite1;
wire pos_zero1;
wire neg_zero1;

reg [7:0] shift_required ;
reg [31:0] denominator_inRange;
reg [31:0] numerator_after_shift;

wire [31:0] out_unsigned;
wire [31:0] p1;
wire [31:0] x0;
wire [31:0] x1;
wire [31:0] x2;
wire [31:0] x3;

// x0 = 48/17 - (32/17)*d    => x0 = p2 - p1 ,  p2 = 48/17 , p1 = 32/17*d .
// 48/17 in 32bit floating point is : 0_10000000_01101001_01101001_0110101
// 32/17 in 32bit floating point is : 0_01111111_11100001_11100001_1110001

//multiplication (-32/17 * d) where d is in between from 0.5 to 1.
 float_mult fm1(.a(32'b1_01111111_11100001_11100001_1110001),     //-32/17 in floatin point
               .b({denominator_inRange}),
               .NaN(NaN1),
               .neg_infinite(neg_infinite1),
               .pos_infinite(pos_infinite1),
               .pos_zero(pos_zero1),
               .neg_zero(neg_zero1),
               .out_mult(p1));

//addition 48/17 and p1
 float_add_subs_v2 fas2(
                  .a(p1),
                  .b(32'b0_10000000_01101001_01101001_0110101), //p2
                  .NaN(NaN1),
                  .neg_infinite(neg_infinite1),
                  .pos_infinite(pos_infinite1),
                  .pos_zero(pos_zero1),
                  .neg_zero(neg_zero1),
                  .out_final(x0));                
//iterations                
iterations i1(.x_i(x0),
              .denominator_inRange(denominator_inRange),
              .x_ii(x1));

iterations i2(.x_i(x1),
              .denominator_inRange(denominator_inRange),
              .x_ii(x2));

iterations i3(.x_i(x2),
              .denominator_inRange(denominator_inRange),
              .x_ii(x3));

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

  denominator_inRange = {1'b0 , 8'd126,mntsa};   // denominator will be in range from 0.5 to 1 
  shift_required =   8'd126 - expnt;   // exponent shift required in numerator for balancing.

  numerator_after_shift = {1'b0 ,(expnt_numerator + shift_required) , numerator[22:0]};  // numerator after exponent shift
 
end

//final multiplication (1/d)*numerator
 float_mult fm5(.a(x3),     //  final value of reciprocal after 3rd iteration
               .b(numerator_after_shift),    // input
               .NaN(NaN1),                   //output
               .neg_infinite(neg_infinite1), // output
               .pos_infinite(pos_infinite1), // output    
               .pos_zero(pos_zero1),         // output
               .neg_zero(neg_zero1),         // output
               .out_mult(out_unsigned));     // output

//assigning output to zero if denominator is infinite else output will be (out_signed,out_signed)
 assign out_division = ((denominator[30:23] == 8'd255 && denominator[22:0]==23'd0)||(numerator[30:23] == 8'd0 && numerator[22:0] ==23'd0)) ? 32'h00000000 : {out_sign, out_unsigned[30:0]};
endmodule

