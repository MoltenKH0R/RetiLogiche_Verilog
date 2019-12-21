//------------------------------------------------------------------------------
module Formatore_di_Impulsi(clock, reset_, numero, dav_, rfd, out);
  input clock, reset_, dav_;
  input [7:0] numero;
  output rfd;
  output out;
  reg OUT; assign out=OUT;
  reg RFD; assign rfd=RFD;
  reg [7:0] COUNT;
  reg star [1:0] STAR; parameter S0='B00, S1='B01, S2='B10;
  always @(reset_ == 0) #1 begin STAR<=S0; RFD<=1; OUT<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin RFD<=1; OUT<=0; COUNT<=mumero; STAR<=(dav_==1)?S0:S1; end
      S1: begin RFD<=0; OUT<=1; COUNT<=COUNT-1; STAR<=(COUNT==1)?S2:S1; end
      S2: begin RFD<=0; OUT<=0; STAR<=(dav_==1)?S0:S2; end
    endcase
  endmodule
  
