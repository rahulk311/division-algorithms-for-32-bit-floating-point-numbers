module float_mult(
                  input [31:0] a,
                  input [31:0] b,
                  output reg NaN,
                  output reg neg_infinite,
                  output reg pos_infinite,
                  output reg pos_zero,
                  output reg neg_zero,
                  output reg [31:0] out_mult 
                );
wire  out_sign;                 
wire sign_a ;
wire sign_b ;
wire [7:0] expo_a ;
wire [7:0] expo_b ;
wire [22:0] mant_b;
wire [22:0] mant_a;
wire [23:0] sigf_a;
wire [23:0] sigf_b;
reg [7:0] out_expo;
reg [22:0] out_mant;
reg [48:0] mant_mult;
reg [5:0] i ;

assign sign_a = a[31];
assign sign_b = b[31];
assign mant_b = b[22:0];
assign mant_a = a[22:0];
assign expo_a = a[30:23];
assign expo_b = b[30:23];
assign sigf_a = {1'b1,mant_a};
assign sigf_b = {1'b1,mant_b};

assign out_sign = (sign_a == sign_b) ? (1'b0) : (1'b1);

always @(*)
        begin
          
   if((a[31] ==1'b1 && a[30:23] == 8'd255 && a[22:0]==23'd0 ) || (b[31] ==1'b1 && b[30:23] == 8'd255 && b[22:0]==23'd0 ))   
       neg_infinite = 1'b1;    
   else 
       neg_infinite = 1'b0;

   if((a[31] ==1'b0 && a[30:23] == 8'd255 && a[22:0]==23'd0) || (b[31] ==1'b0 && b[30:23] == 8'd255 && b[22:0]==23'd0))    
       pos_infinite = 1'b1;    
   else 
       pos_infinite = 1'b0;

   if((a[31] ==1'b1 && a[30:23] == 8'd0   && a[22:0] ==23'd0) || (b[31] ==1'b1 && b[30:23] == 8'd0   && b[22:0] ==23'd0))               
       neg_zero     = 1'b1;      
   else 
       neg_zero     = 1'b0;

   if((a[31] ==1'b1 && a[30:23] == 8'd0   && a[22:0] ==23'd0) || (b[31] ==1'b1 && b[30:23] == 8'd0   && b[22:0] ==23'd0))           
       pos_zero     = 1'b1; 
   else 
       pos_zero     = 1'b0;

   if(( a[30:23]== 8'd255 && a[22:0] != 23'd0) || (b[30:23] == 8'd255 && b[22:0] !=23'd0 ))  
       NaN = 1'b1;    
   else 
       NaN = 1'b0;  
          
   
//   if(out_expo >= 8'd255)      NaN = 1'b1; 
        
  //  else 
    //  begin 
       out_mult = 32'h0000;
       out_mant = 32'h0000;
		 out_expo = (expo_a + expo_b)-8'b01111111; //-127
         mant_mult = sigf_a * sigf_b;
            
       
       if(mant_mult[47])
          begin
             out_mant = mant_mult[46:24];
             out_expo = out_expo + 1'b1;
             out_mult = ({out_sign,out_expo,out_mant});
          end
       else if(mant_mult[46])
               begin
                 out_mant = mant_mult[45:23];
                 out_mult = ({out_sign,out_expo,out_mant});
               end
                    
	  else 
         begin
            for(i =0 ; i<6'd48 ; i = i+1)
                begin
          
        		  if(mant_mult[46])
                     begin
                       out_mult = ({out_sign,out_expo,out_mant});
                     end
                  else 
                     begin
                        mant_mult = mant_mult <<1;
                        out_expo = out_expo-1'b1;
                        out_mant = mant_mult[45:23];
                     end
                end
         end
      end
//end
endmodule
