//DESCRIZIONE

module XXX(clock, reset_, dav_, rfd, enne, a13_a0, d7_d0, campione);
  input clock, reset_, dav_;
  input [3:0] enne;
  input [7:0] d7_d0;

  output rfd;
  output [7:0] campione;
  output [13:0] a13_a0;

  reg RFD;                      assign rfd = RFD;
  reg [7:0] CAMPIONE;           assign campione = CAMPIONE;
  reg [13:0] A13_A0;            assign a13_a0 = A13_A0;
  reg [10:0] COUNT;
  reg [1:0] STAR;               parameter [1:0] S0=0, S1=1, S2=2, S3=3;

  parameter cicli = 1024;

  always @(reset_ == 0) begin STAR<=S0; RFD<=0; COUNT<=cicli; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin RFD<=1; CAMPIONE<='H00; A13_A0<=(enne*cicli); STAR<=(dav_ == 1)?S0:S1 end
      S1: begin RFD<=0; STAR<=(dav_ == 0)?S1:S2; end
      S2: begin CAMPIONE<=d7_d0; STAR<=S3; end
      S3: begin COUNT<=(COUNT == 1)?cicli:(COUNT-1); A13_A0<=A13_A0+1; STAR<=(COUNT == 1)?S0:S3; end
    endcase
endmodule

// SINTESI-1

module XXX(clock, reset_, dav_, rfd, enne, a13_a0, d7_d0, campione);
  input clock, reset_, dav_;
  input [3:0] enne;
  input [7:0] d7_d0;

  output rfd;
  output [7:0] campione;
  output [13:0] a13_a0;

  reg RFD;                      assign rfd = RFD;
  reg [7:0] CAMPIONE;           assign campione = CAMPIONE;
  reg [13:0] A13_A0;            assign a13_a0 = A13_A0;
  reg [10:0] COUNT;
  reg [1:0] STAR;               parameter [1:0] S0=0, S1=1, S2=2, S3=3;

  parameter cicli = 1024;

  //reg RFD
  always @(reset_ == 0) begin RFD<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin RFD<=1; end
      S1: begin RFD<=0; end
      S2,S3: begin RFD<=RFD; end
    endcase

    //reg CAMPIONE
    always @(reset_ == 0) begin CAMPIONE<=CAMPIONE;
    always @(posedge clock) if (reset_ == 1) #3
      casex(STAR)
        S0: begin CAMPIONE<='H00; end
        S2: begin CAMPIONE<=d7_d0; end
        S1,S3: begin CAMPIONE<=CAMPIONE; end
      endcase

  //reg A13_A0
  always @(reset_ == 0) begin A13_A0<=A13_A0; end
  always @(posedge clock) #3
    casex(STAR)
      S0: begin A13_A0<=(enne*cicli); end
      S1,S2: begin A13_A0<=A13_A0; end
      S3: begin A13_A0<=A13_A0+1; end
    endcase

  //reg COUNT
  always @(reset_ == 0) begin COUNT<=cicli; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0,S1,S2: begin COUNT<=COUNT; end
      S3: begin COUNT<=(COUNT == 1)?cicli:(COUNT-1); end
    endcase

  //reg STAR
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(dav_ == 1)?S0:S1; end
      S1: begin STAR<=(dav_ == 0)?S1:S2; end
      S2: begin STAR<=S3; end
      S3: begin STAR<=(COUNT == 1)?S0:S3; end
      endcase
endmodule

// SINTESI-2

module XXX(clock, reset_, dav_, rfd, enne, a13_a0, d7_d0, campione);
  input clock, reset_, dav_;
  input [3:0] enne;
  input [7:0] d7_d0;

  output rfd;
  output [7:0] campione;
  output [13:0] a13_a0;

  reg RFD;                      assign rfd = RFD;
  reg [7:0] CAMPIONE;           assign campione = CAMPIONE;
  reg [13:0] A13_A0;            assign a13_a0 = A13_A0;
  reg [10:0] COUNT;
  reg [1:0] STAR;               parameter [1:0] S0=0, S1=1, S2=2, S3=3;

  parameter cicli = 1024;

  //reg RFD
  wire b1,b0; assign {b1,b0} = (STAR == S0)?'B00:(STAR == S1)?'B01:'B1X;
  always @(reset_ == 0) begin RFD<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex({b1, b0})
      'B00: begin RFD<=1; end
      'B01: begin RFD<=0; end
      'B1X: begin RFD<=RFD; end
    endcase
  //reg CAMPIONE
  always @(reset_ == 0) begin CAMPIONE<=CAMPIONE; end
  always @(posedge clock) if (reset_ == 1) #3
    casex({b3, b2}); assign {b3,b2} = (STAR == S0)?'B00:(STAR == S2)?'B10:'BX1;
      'B00: begin CAMPIONE<='H00; end
      'B10: begin CAMPIONE<=d7_d0; end
      'BX1: begin CAMPIONE<=CAMPIONE; end
    endcase
  
  //reg A13_A0
  wire b3,b2; assign {b5,b4} = (STAR == S0)?'B00:(STAR == S3)?'B10:'BX1;
  always @(reset_ == 0) begin A13_A0<A13_A0; end
  always @(posedge clock) if (reset_ ==1) #3
    casex({b5, b4})
      'B00: begin A13_A0<=(enne*cicli); end
      'B10: begin A13_A0<=A13_A0+1; end
      'BX1: begin A13_A0<=A13_A0; end
    endcase

  //reg COUNT
  wire b6; assign b6 = (STAR == S3)?1:0;
  always @(reset_ == 0) begin COUNT<=cicli; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b6)
      0: begin COUNT<=COUNT; end
      1: begin COUNT<=(COUNT == 1)?cicli:(COUNT-1); end
    endcase

  //reg STAR
  wire c1; assign c1 = (dav_ == 1)?1:0;
  wire c0; assign c0 = (COUNT == 1)?1:0;
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(c1 == 1)?S0:S1; end
      S1: begin STAR<=(c1 == 0)?S1:S2; end
      S2: begin STAR<=S3; end
      S3: begin STAR<=(c0 == 1)?S0:S3; end
    endcase
endmodule

//VARIABILI DI COMANDO
{b6,b5,b4,b3,b2,b1,b0} = (STAR == S0)?'B0000000:
                         (STAR == S1)?'B0X1X101:
                         (STAR == S2)?'B0X1101X:'B110X11X;

//VARIABILI DI CONDIZIONAMENTO
c1 = (dav_ == 1)?1:0 ----> c1 = dav_;
c0 = (COUNT == 1);   ----> c0 = ~COUNT[10:1] & COUNT[0];

//SINTESI-3

module XXX(clock, reset_, dav_, rfd, enne, a13_a0, d7_d0, campione);
  input clock, reset_, dav_;
  input [3:0] enne;
  input [7:0] d7_d0;

  output rfd;
  output [7:0] campione;
  output [13:0] a13_a0;
  wire b6,b5,b4,b3,b2,b1,b0,c1,c0;
  Parte_Operativa PO(clock, reset_, dav_, rfd, enne, a13_a0, d7_d0, campione, b6, b5, b4, b3, b2, b1, b0, c1, c0);
  Parte_Controllo PC(clock, reset_, b6, b5, b4, b3, b2, b1, b0, c1, c0);
  parameter cicli = 1024;

endmodule

module Parte_Operativa(clock, reset_, dav_, rfd, enne, a13_a0, d7_d0, campione, b6, b5, b4, b3, b2, b1, b0, c1, c0);
  input clock, reset_, dav_, b6, b5, b4, b3, b2, b1, b0;
  input [3:0] enne;
  input [7:0] d7_d0;

  output rfd, c1, c0;
  output [7:0] campione;
  output [13:0] a13_a0;

  reg RFD;                      assign rfd = RFD;
  reg [7:0] CAMPIONE;           assign campione = CAMPIONE;
  reg [13:0] A13_A0;            assign a13_a0 = A13_A0;
  reg [10:0] COUNT;

  assign c1 = dav_;
  assign c0 = ~COUNT[10:1] & COUNT[0];

  parameter cicli = 1024;

  //reg RFD
  always @(reset_ == 0) begin RFD<=0;
  always @(posedge clock) if (reset_ == 1) #3
    casex({b1,b0})
      'B00: begin RFD<=1; end
      'B01: begin RFD<=0; end
      'B1X: begin RFD<=RFD; end
    endcase
    //reg CAMPIONE
    always @(reset_ == 0) begin CAMPIONE<=CAMPIONE; end
    always @(posedge clock) if (reset_ == 1) #3
      casex({b3, b2}); assign {b3,b2} = (STAR == S0)?'B00:(STAR == S2)?'B10:'BX1;
        'B00: begin CAMPIONE<='H00; end
        'B10: begin CAMPIONE<=d7_d0; end
        'BX1: begin CAMPIONE<=CAMPIONE; end
      endcase

    //reg A13_A0
    wire b3,b2; assign {b5,b4} = (STAR == S0)?'B00:(STAR == S3)?'B10:'BX1;
    always @(reset_ == 0) begin A13_A0<A13_A0; end
    always @(posedge clock) if (reset_ ==1) #3
      casex({b5, b4})
        'B00: begin A13_A0<=(enne*cicli); end
        'B10: begin A13_A0<=A13_A0+1; end
        'BX1: begin A13_A0<=A13_A0; end
      endcase

    //reg COUNT
    wire b6; assign b6 = (STAR == S3)?1:0;
    always @(reset_ == 0) begin COUNT<=cicli; end
    always @(posedge clock) if (reset_ == 1) #3
      casex(b6)
        0: begin COUNT<=COUNT; end
        1: begin COUNT<=(COUNT == 1)?cicli:(COUNT-1); end
      endcase

endmodule

module Parte_Controllo(clock, reset_, b6, b5, b4, b3, b2, b1, b0, c1, c0);
  input clock, reset_, c1, c0;
  output b6, b5 , b4, b3, b2, b1, b0;

  reg [1:0] STAR; parameter [1:0] S0=0, S1=1, S2=2, S3=3;
  assign {b6,b5,b4,b3,b2,b1,b0} = (STAR == S0)?'B0000000:
                           (STAR == S1)?'B0X1X101:
                           (STAR == S2)?'B0X1101X:'B110X11X;
  //reg STAR
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(c1 == 1)?S0:S1; end
      S1: begin STAR<=(c1 == 0)?S1:S2; end
      S3: begin STAR<=(c0 == 1)?S0:S3; end
      S2: begin STAR<=S3; end
    endcase
endmodule
