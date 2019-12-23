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

//-SINTESI1---------------------------------------------------------------------
module Formatore_di_Impulsi(clock, reset_, numero, dav_, rfd, out);
  input clock, reset_, dav_;
  input [7:0] numero;
  output out, rfd;

  reg OUT; assign out=OUT;
  reg RFD; assign rfd=RFD;
  reg [7:0] COUNT;
  reg [1:0] STAR; parameter S0='B00, S1='B01, S2='B10;

  //--reg OUT
  always @ (reset_ == 0) #1 OUT<=0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0,S2: OUT<=0;
      S1: OUT<=1;
    endcase
  //--reg RFD
  always @ (reset_ == 0) #1 RFD<=1;
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: RFD<=1;
      S1,S2: RFD<=0;
    endcase
  //--reg COUNT
  always @ (reset_ == 0) #1 COUNT<=COUNT;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: COUNT<=numero;
      S1: COUNT<=COUNT-1;
      S2: COUNT<=COUNT;
    endcase
  //--reg STAR
  always @ (reset_ == 0) #1 STAR<=S0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: STAR<=(dav_==1)?S0:S1;
      S1: STAR<=(COUNT==1)?S2:S1;
      S2: STAR<=(dav_==1)?S0:S2;
    endcase
endmodule

//--Lista variabili di comando e di controllo ----------------------------------
wire b0; assign b0 = (STAR == S1)?1:0;
wire b1; assign b1 = (STAR == S0)?1:0;
wire b3,b2; assign {b3,b2} = (STAR == S0)?'B00:(STAR == S1)?'B01:'B1X;

assign {b3,b2,b1,b0} = (STAR == S0)?'B0010:(STAR == S1)?'B0101:'B1X00;


wire c1; assign c1 = dav_;
wire c0; assign c0 = (~COUNT[7] & ... & ~COUNT[1] & COUNT[0]);

//--SINTESI2--------------------------------------------------------------------
module Formatore_di_Impulsi(clock, reset_, numero, dav_, rfd, out);
  input clock, reset_, dav_;
  input [7:0] numero;
  output out, rfd;

  reg OUT; assign out=OUT;
  reg RFD; assign rfd=RFD;
  reg [7:0] COUNT;
  reg [1:0] STAR; parameter S0='B00, S1='B01, S2='B10;

  wire b0; assign b0 = (STAR == S1)?1:0;
  wire b1; assign b1 = (STAR == S0)?1:0;
  wire b3,b2; assign {b3,b2} = (STAR == S0)?'B00:(STAR == S1)?'B01:'B1X;

  wire c1; assign c1 = dav_;
  wire c0; assign c0 = (~COUNT[7]) & ... & (~COUNT[1]) & COUNT[0];

  //reg OUT
  always @ (reset_ == 0) #1 OUT<=0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(b0)
      'B1: OUT<=1;
      'B0: OUT<=0;
    endcase
  //reg RFD
  always @ (reset_ == 0) #1 RFD<=1;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(b1)
      'B1: RFD<=1;
      'B0: RFD<=0;
    endcase
  //reg COUNT
  always @ (reset_ == 0) #1 COUNT<=COUNT;
  always @ (posedge clock) if (reset_ == 1) #3
    casex({b3,b2})
      'B00: COUNT<=numero;
      'B01: COUNT<=COUNT-1;
      'B1?: COUNT<=COUNT;
    endcase
  //reg STAR
  always @ (reset_ == 0) #1 STAR<=S0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: STAR<=(c1)?S0:S1;
      S1: STAR<=(c0)?S2:S1;
      S2: STAR<=(c1)?S0:S2;
    endcase
endmodule

//--SINTESI3--------------------------------------------------------------------
module Formatore_di_Impulsi(clock, reset_, numero, rfd, dav_, out);
  input clock, reset_, dav_;
  input [7:0] numero;
  output out, rfd;

  wire b3, b2, b1, b0, c1, c0;

  Parte_Operativa PO(clock, reset_, numero, rfd, dav_, out, b3, b2, b1, b0, c1, c0);
  Parte_Controllo PC(clock, reset_, b3, b2, b1, b0, c1, c0);
endmodule
module  Parte_Operativa(clock, reset_, numero, rfd, dav_, out, b3, b2, b1, b0, c1, c0);
  input clock, reset_, dav_, b3, b2, b1, b0;
  input [7:0] numero;
  output rfd, out, c1, c0;

  reg RFD; assign rfd=RFD;
  reg OUT; assign out=OUT;
  reg [7:0] COUNT;

  assign c1 = (dav_ == 1)?1:0;
  assign c0 = (COUNT == 1)?1:0;

  //reg OUT
  always @ (reset_ == 0) #1 OUT<=0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(b0)
      'B0: OUT<=0;
      'B1: OUT<=1;
    endcase
  //reg RFD
  always @ (reset_ == 0) #1 RFD<=1;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(b1)
      'B1: RFD<=1;
      'B0: RFD<=0;
    endcase
  //ref COUNT
  always @ (reset_ == 0) #1 COUNT<=COUNT
  always @ (posedge clock) if (reset_ == 1) #3
    casex({b3,b2})
      'B00: COUNT<=numero;
      'B01: COUNT<=COUNT-1;
      'B1X: COUNT<=COUNT;
    endcase
endmodule

module Parte_Controllo(clock, reset_, b3, b2, b1, b0, c1, c0);
  input clock, reset_, c1, c0;
  output b3, b2, b1, b0;

  reg [1:0] STAR; parameter S0='B00, S1='B01, S2='B10;

  assign {b3,b2,b1,b0} = (STAR == S0)?'B0010:(STAR == S1)?'B0101:'B1X00;

  always @ (reset_ == 0) #1 STAR<=S0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: STAR<=(c1)?S0:S1;
      S1: STAR<=(c0)?S2:S1;
      S2: STAR<=(c1)?S0:S2;
    endcase
endmodule
