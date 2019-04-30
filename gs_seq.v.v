`include "gs_1itr_complete.v"
`include "float_mult.v"
`include "float_add_subs_v2.v"
`include "mult_factor.v"

module gs_seq(input rstb,
              input clk,
              input req,
              input [31:0] numerator,
              input [31:0] denominator ,
              output reg NaN,
              output reg neg_infinite,
              output reg pos_infinite,
              output reg pos_zero,
              output reg neg_zero,
              output reg [31:0] out_division );

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

parameter A = 4'd1;
parameter B = 4'd2;
parameter C = 4'd3;
parameter D = 4'd4;
parameter E = 4'd5;
parameter F = 4'd6;
//parameter G = 4'd7;
parameter H = 4'd7;
reg [2:0] state;
reg [2:0] next_state;

reg [7:0] shift_required ;
reg [31:0] denominator_inRange;
reg [31:0] numerator_after_shift;
reg [31:0] N; 
reg [31:0] Di;
wire [31:0] N_after_compute; 
wire [31:0] D_after_compute;
reg ack;
//reg req;
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



    denominator_inRange = {1'b0 ,8'd126,mntsa};   // denominator will be in range from 0.5 to 1 
    shift_required =   8'd126 - expnt;   // exponent shift required in numerator for balancing.
    numerator_after_shift = {1'b0 ,(expnt_numerator + shift_required) , numerator[22:0]};  // numerator after exponent shift

end

gs_1itr gs_combo(.numerator_input(N),
                 .denominator_input(Di),
                 .numerator_out(N_after_compute),
                 .denominator_out(D_after_compute));
//state machine
always@(posedge clk or negedge rstb)begin
  if(!rstb)
       state <= A;
    else
      state <= next_state;
end

always@(*)begin
  case(state)
   A: if(req)next_state = B;
   B:        next_state = C;
   C:        next_state = D;
   D:        next_state = E;
   E:        next_state = F;
   F:        next_state = H;
//   G:        next_state = H;
   H: if(ack==1'b1 && req ==1'b1) next_state <= A;
   default:  next_state  = A;
  endcase
end

always@(posedge clk or negedge rstb)
 begin
   if(!rstb)
    begin
        ack <= 1'b0 ;
       // N_after_compute <= 0;
       // D_after_compute <=0;
    end
   else
    begin
     if(state == A && req)  begin 
                            {N,Di} <= {numerator_after_shift,denominator_inRange} ;
                            ack <=1'b0;
                            end
     if(state == B)           {N,Di} <= {N_after_compute,D_after_compute} ; 
     if(state == C)           {N,Di} <= {N_after_compute,D_after_compute} ; 
     if(state == D)           {N,Di} <= {N_after_compute,D_after_compute} ; 
     if(state == E)           {N,Di} <= {N_after_compute,D_after_compute} ; 
     if(state == F ) begin    {N,Di} <= {N_after_compute,D_after_compute} ;ack<=1'b1; end
     if(state == H )     if(state == H)  begin
                         //ack<=1'b1;
                        {N,Di} <= {N_after_compute,D_after_compute}  ;  
                         out_division <= N_after_compute;
                     end
    end
 end


endmodule
