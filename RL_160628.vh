//DESCRIZIONE
module UU(clock, reset_, dav_, rfd, xc, xv, a0, d7_d0);
  input clock, reset_, dav_;
  output a0, rfd;

  input [7:0] xc, d7_d0;
  output [7:0] xv;

  reg A0, RFD;                                    assign a0=A0; assign rfd=RFD;
  reg [7:0] XV, XC, MBR, DIST_da_A;               assign xv=XV;
  reg [2:0] STAR;                 parameter S0=0, S1=1, S2=2, S3=3, S4=4;

  function [7:0] distanza;
    input [7:0] x1, x2;
    distanza = (x1>x2)?(x1-x2):(x2-x1);
  endfunction

  always @(reset_ == 0) begin STAR<=S0; RFD<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin RFD<=1; XC<=xc; STAR<=(dav_ == 1)?S0:S1; end
      S1: begin RFD<=0; A0<=0; STAR<=S2; end
      S2: begin MBR<=d7_d0; DIST_da_A<=distanza(XC, d7_d0); A0<=1; STAR<=S3; end
      S3: begin XV<=(DIST_da_A < distanza(XC,d7-d0))?MBR:d7_d0; STAR<=S4; end
      S4: begin STAR<=(dav_==0)?S4:S0; end
    endcase
endmodule

//SINTESI-1

module UU(clock, reset_, dav_, rfd, xc, xv, a0, d7_d0);
  input clock, reset_, dav_;
  output a0, rfd;

  input [7:0] xc, d7_d0;
  output [7:0] xv;

  reg A0, RFD;                                    assign a0=A0; assign rfd=RFD;
  reg [7:0] XV, XC, MBR, DIST_da_A;               assign xv=XV;
  reg [2:0] STAR;                 parameter S0=0, S1=1, S2=2, S3=3, S4=4;

  function [7:0] distanza;
    input [7:0] x1, x2;
    distanza = (x1>x2)?(x1-x2):(x2-x1);
  endfunction

  //reg A0
  always @(reset_ == 0) begin A0<=A0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S1: begin A0<=0; end
      S2: begin A0<=1; end
      S0,S3,S4: begin A0<=A0; end
    endcase

  //reg RFD
  always @(reset_ == 0) begin RFD<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin RFD<=1; end
      S1: begin RFD<=0; end
      S2,S3,S4: begin RFD<=RFD; end
    endcase

  //reg XV
  always @(reset_ == 0) begin XV<=XV; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S3: begin XV<=(DIST_da_A < distanza(XC,d7_d0))?MBR:d7_d0; end
      S0,S1,S2,S4: begin XV<=XV; end
    endcase

  //reg XC
  always @(reset_ == 0) begin XC<=XC; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin XC<=xc; end
      S1,S2,S3,S4: begin XC<=XC; end
    endcase

  //reg MBR
  always @(reset_ == 0) begin MBR<=MBR; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S2: begin MBR<=d7_d0; end
      S0,S1,S3,S4: begin MBR<=MBR; end
    endcase

  //reg DIST_da_A
  always @(reset_ == 0) begin DIST_da_A<=DIST_da_A; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S2: begin DIST_da_A<=distanza(XC,d7_d0); end
      S0,S1,S3,S4: begin DIST_da_A<=DIST_da_A; end
    endcase

  //reg STAR
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(dav_ == 1)?S0:S1; end
      S1: begin STAR<=S2; end
      S2: begin STAR<=S3; end
      S3: begin STAR<=S4; end
      S4: begin STAR<=(dav_ == 0)?S4:S0; end
    endcase
endmodule

//SINTESI-2

module UU(clock, reset_, dav_, rfd, xc, xv, a0, d7_d0);
  input clock, reset_, dav_;
  output a0, rfd;

  input [7:0] xc, d7_d0;
  output [7:0] xv;

  reg A0, RFD;                                    assign a0=A0; assign rfd=RFD;
  reg [7:0] XV, XC, MBR, DIST_da_A;               assign xv=XV;
  reg [2:0] STAR;                 parameter S0=0, S1=1, S2=2, S3=3, S4=4;

  function [7:0] distanza;
    input [7:0] x1, x2;
    distanza = (x1>x2)?(x1-x2):(x2-x1);
  endfunction

  //reg A0
  wire b6,b5; assign {b6,b5} = (STAR ==1)?'B00:(STAR == S2)?'B01:'B1X;
  always @(reset_ == 0) begin A0<=A0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex({b6,b5})
      'B00: begin A0<=0; end
      'B01: begin A0<=1; end
      'B1X: begin A0<=A0; end
    endcase

  //reg RFD
  wire b3,b4; assign {b4,b3} = (STAR == S0)?'B00:(STAR == S1)?'B01:B1X;
  always @(reset_ == 0) begin RFD<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex({b4,b3}})
      'B00: begin RFD<=1; end
      'B01: begin RFD<=0; end
      'B1X: begin RFD<=RFD; end
    endcase

  //reg XV
  wire b2; assign b2 = (STAR == S3)?1:0
  always @(reset_ == 0) begin XV<=XV; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b2)
      1: begin XV<=(DIST_da_A < distanza(XC,d7_d0))?MBR:d7_d0; end
      0: begin XV<=XV; end
    endcase

  //reg XC
  wire b1; assign b1 = (STAR == S0)?1:0;
  always @(reset_ == 0) begin XC<=XC; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b1)
      1: begin XC<=xc; end
      0: begin XC<=XC; end
    endcase

  //reg MBR
  wire b0; assign b0 = (STAR == S2)?1:0
  always @(reset_ == 0) begin MBR<=MBR; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin MBR<=d7_d0; end
      0: begin MBR<=MBR; end
    endcase

  //reg DIST_da_A
  always @(reset_ == 0) begin DIST_da_A<=DIST_da_A; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin DIST_da_A<=distanza(XC,d7_d0); end
      0: begin DIST_da_A<=DIST_da_A; end
    endcase

  //reg STAR
  wire c0; assign c0=(dav_==1)?1:0;
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(c0 == 1)?S0:S1; end
      S1: begin STAR<=S2; end
      S2: begin STAR<=S3; end
      S3: begin STAR<=S4; end
      S4: begin STAR<=(c0 == 0)?S4:S0; end
    endcase
endmodule

//SINTESI-3
module UU(clock, reset_, dav_, rfd, xc, xv, a0, d7_d0);
  input clock, reset_, dav_;
  output a0, rfd;

  input [7:0] xc, d7_d0;
  output [7:0] xv;
  wire b6,b5,b4,b3,b2,b1,b0,c0;
  Parte_Operativa PO(clock, reset_, dav_, rfd, xc, xv, a0, d7_d0, b6, b5, b4, b3, b2, b1, b0, c0);
  Parte_controllo PC(Clock, reset_, b6, b5, b4, b3, b2, b1, b0, c0);
endmodule

module Parte_Operativa(clock, reset_, dav_, rfd, xc, xv, a0, d7_d0, b6, b5, b4, b3, b2, b1, b0, c0);
  input clock, reset_, dav_, b6, b5, b4, b3, b2, b1, b0;
  input [7:0] xc, d7_d0;

  output c0, a0, rfd;
  output [7:0] xv;

  reg A0, RFD;                                    assign a0=A0; assign rfd=RFD;
  reg [7:0] XV, XC, MBR, DIST_da_A;               assign xv=XV;

  assign c0 = dav_;

  function [7:0] distanza;
    input [7:0] x1, x2;
    distanza = (x1>x2)?(x1-x2):(x2-x1);
  endfunction

  //reg A0
  wire b6,b5; assign {b6,b5} = (STAR ==1)?'B00:(STAR == S2)?'B01:'B1X;
  always @(reset_ == 0) begin A0<=A0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex({b6,b5})
      'B00: begin A0<=0; end
      'B01: begin A0<=1; end
      'B1X: begin A0<=A0; end
    endcase

  //reg RFD
  wire b3,b4; assign {b4,b3} = (STAR == S0)?'B00:(STAR == S1)?'B01:B1X;
  always @(reset_ == 0) begin RFD<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex({b4,b3}})
      'B00: begin RFD<=1; end
      'B01: begin RFD<=0; end
      'B1X: begin RFD<=RFD; end
    endcase

  //reg XV
  wire b2; assign b2 = (STAR == S3)?1:0
  always @(reset_ == 0) begin XV<=XV; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b2)
      1: begin XV<=(DIST_da_A < distanza(XC,d7_d0))?MBR:d7_d0; end
      0: begin XV<=XV; end
    endcase

  //reg XC
  wire b1; assign b1 = (STAR == S0)?1:0;
  always @(reset_ == 0) begin XC<=XC; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b1)
      1: begin XC<=xc; end
      0: begin XC<=XC; end
    endcase

  //reg MBR
  wire b0; assign b0 = (STAR == S2)?1:0
  always @(reset_ == 0) begin MBR<=MBR; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin MBR<=d7_d0; end
      0: begin MBR<=MBR; end
    endcase

  //reg DIST_da_A
  always @(reset_ == 0) begin DIST_da_A<=DIST_da_A; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin DIST_da_A<=distanza(XC,d7_d0); end
      0: begin DIST_da_A<=DIST_da_A; end
    endcase
endmodule

module Parte_controllo(Clock, reset_, b6, b5, b4, b3, b2, b1, b0, c0);
  input c0, clock, reset_;
  output b6, b5, b4, b3, b2, b1, b0;

  reg [2:0] STAR; parameter S0=0, S1=1, S2=2, S3=3, S4=4;
  assign{b6,b5,b4,b3,b2,b1,b0}=(STAR==S0)?'B010001X:
                               (STAR==S1)?'B0000100:
                               (STAR==S2)?'B1001X01:
                               (STAR==S3)?'B0011X1X:'B0001X1X;

  //reg STAR
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(c0 == 1)?S0:S1; end
      S1: begin STAR<=S2; end
      S2: begin STAR<=S3; end
      S3: begin STAR<=S4; end
      S4: begin STAR<=(c0 == 0)?S4:S0; end
    endcase
endmodule
