module float_add_subs_v2(input [31:0] a,
                 input [31:0] b,
                 output reg NaN,
                 output reg neg_infinite,
                 output reg pos_infinite,
                 output reg pos_zero,
                 output reg neg_zero,
                 output [31:0] out_final);

wire [31:0] a1;
wire [31:0] b1;
wire [7:0] initial_exponent;
wire subtraction_operation;
wire [7:0] exponent_difference;
wire [23:0] a1_significand;
wire [23:0] b1_significand;
wire [23:0] b1_significand_after_shift;
wire [7:0] expo_sum;
wire [7:0] expo_substraction;
wire [24:0] mantissa_difference;
wire [24:0] mantissa_sum;
wire [24:0] mantissa_sum_final;
wire [23:0] mantissa_out;
wire [7:0] expo_out;
reg [7:0] expo_subs_after_shift;
reg [7:0] expo_subs_final;
reg [24:0] mantissa_difference_after_shift;
reg [24:0] mantissa_difference_final;
reg [4:0]  i = 5'd22;

//  //if e=255 , mant=0, S=1 then >>  -infinite
//  // if e=255 , mant=0, S=0 then >> +infinite
//  // if e =255 , mant != 0 then >> NaN
//  // if e =0, mant=0 , s=1 >> -0 
//  // if e =0, mant=0 , s=1 >> +0
//  // if e =0, mant!=0 , value will be un-normalised (-1)**s*2**(-126)*(0.f)

always@(*)
begin 
   if(a1[31] ==1'b1 && a1[30:23] == 8'd255 && a1[22:0]==23'd0 )               neg_infinite = 1'b1;    else neg_infinite = 1'b0;
   if(b1[31] ==1'b0 && b1[30:23] == 8'd255 && b1[22:0]==23'd0 )               pos_infinite = 1'b1;     else pos_infinite = 1'b0;
   if(a1[31] ==1'b1 && a1[30:23] == 8'd0   && a1[22:0] ==23'd0)               neg_zero     = 1'b1;      else neg_zero     = 1'b0;
   if(b1[31] ==1'b1 && b1[30:23] == 8'd0   && b1[22:0] ==23'd0)                pos_zero     = 1'b1;     else pos_zero     = 1'b0;

   if(( a1[30:23]== 8'd255 && a1[22:0] != 23'd0) || (b1[30:23] == 8'd255 && b1[22:0] !=23'd0 ))  NaN = 1'b1;     else NaN = 1'b0;
end

assign {a1,b1} 		= (a[30:0] > b[30:0] ) ? {a,b} : {b,a};  //assigning larger number to a1 and smaller number to b1 excluding sign bit
assign  exponent_difference = a1[30:23] - b1[30:23];       //calculate difference in exponent
assign subtraction_operation = a1[31] ^ b1[31];            // if the sign bits are different we need to substract else we need to add
assign a1_significand  = {1'b1 , a1[22:0]};                //add hidden bit to mantissa of a1 
assign b1_significand  = {1'b1 , b1[22:0]};                //add hidden bit to mantissa of b1
//add hidden bit and shift the smaller number's mantissa by exponent difference
assign b1_significand_after_shift  = (exponent_difference < 5'd23) ? ({1'b1,b1[22:0]} >> exponent_difference):(24'd0);

// find difference and sum between two mantissas.
assign mantissa_difference	= a1_significand - b1_significand_after_shift;
assign mantissa_sum     		= a1_significand + b1_significand_after_shift;

//if 25th bit is 1 of  mantissa_sum then shift it right by 1 to make the hidden bit 1 and hence increment the expo_out by one
assign mantissa_sum_final    = (mantissa_sum[24] ==1'b1) ? (mantissa_sum >> 1) : mantissa_sum ;
assign expo_sum        = (mantissa_sum[24]==1'b1) ? (a1[30:23] +1'b1) : a1[30:23];

// addition operation --  assign final output
assign  out_final = (subtraction_operation == 1'b0) ? ({a1[31],expo_sum,mantissa_sum_final[22:0]}): ({a1[31],expo_subs_final,mantissa_difference_final[22:0]});

//for subtraction
always@(*)
 begin
 expo_subs_final = 8'h00;
 mantissa_difference_final  = 25'h0000;
  if(subtraction_operation)
    begin
                mantissa_difference_after_shift = mantissa_difference;
                expo_subs_after_shift = a1[30:23];
               for(i=0; i<=5'd23; i = i+1) 
                begin
                 if(mantissa_difference_after_shift[23]!=1'b1)
                  begin
                      mantissa_difference_after_shift = mantissa_difference_after_shift << 1'b1 ;
                      expo_subs_after_shift = expo_subs_after_shift - 1'b1;
                  end
                end    
                 mantissa_difference_final = mantissa_difference_after_shift;
                 expo_subs_final = expo_subs_after_shift;      
                 i =5'd0;
    end 
 end
endmodule
