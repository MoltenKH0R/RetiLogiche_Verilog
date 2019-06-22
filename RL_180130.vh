//Descrizione
module XXX(clock, reset_, rxd, mw_, a9_a0, d7_d0);
  input clock, reset_, rxd;
  output mw_;
  output [7:0] d7_d0;
  output [9:0] a9_a0;

  reg MW_;                            assign mw_ = MW_;
  reg [17:0] BUFFER;                  assign d7_d0 = BUFFER[17:10]; assign a9_a0 = BUFFER[9:0];
  reg [4:0] COUNT;
  reg [3:0] WAIT;
  reg [2:0] STAR;                     parameter S0=0, S1=1, S2=2, S3=3, Wbit=4, Wstop=5;

  parameter start_bit=1'B0;

  always @(reset_ == 0) begin MW_<=1; STAR<=S0; end
  always @(osedge clock) if (reset_ == 1)
    casex(STAR)
      S0: begin COUNT<=18; WAIT<=11; STAR<=(rxd==start_bit)?Wbit:S0; end
      S1: begin BUFFER<={rxd,BUFFER[17:1]}; COUNT<=COUNT-1; WAIT<=7; STAR<=(COUNT==1)?Wstop:Wbit; end
      S2: begin MW_<=0; STAR<=S3; end
      S3: begin MW_<=1; STAR<=S0; end
      Wbit: begin WAIT<=WAIT-1; STAR<=(WAIT==1)?S1:Wbit; end
      Wstop: begin WAIT<=WAIT-1; STAR<=(WAIT==1)?S2:Wstop; end
    endcase
endmodule

//SINTESI-1
module XXX(clock, reset_, rxd, mw_, a9_a0, d7_d0);
  input clock, reset_, rxd;
  output mw_;
  output [7:0] d7_d0;
  output [9:0] a9_a0;

  reg MW_;                            assign mw_ = MW_;
  reg [17:0] BUFFER;                  assign d7_d0 = BUFFER[17:10]; assign a9_a0 = BUFFER[9:0];
  reg [4:0] COUNT;
  reg [3:0] WAIT;
  reg [2:0] STAR;                     parameter S0=0, S1=1, S2=2, S3=3, Wbit=4, Wstop=5;

  parameter start_bit=1'B0;

  //reg BUFFER
  always @(reset_ == 0) begin BUFFER<=BUFFER; end
  always @(posedge clock) if (reset_ == 1)
    casex(STAR)
      S1: begin BUFFER<={rxd,BUFFER[17:11]}; end
      S0,S2,S3,Wbit,Wstop: begin BUFFER<=BUFFER; end
    endcase

  //reg others
  always @(reset_ == 0) begin MW_<=1; STAR<=S0; end
  always @(osedge clock) if (reset_ == 1)
    casex(STAR)
      S0: begin COUNT<=18; WAIT<=11; STAR<=(rxd==start_bit)?Wbit:S0; end
      S1: begin COUNT<=COUNT-1; WAIT<=7; STAR<=(COUNT==1)?Wstop:Wbit; end
      S2: begin MW_<=0; STAR<=S3; end
      S3: begin MW_<=1; STAR<=S0; end
      Wbit: begin WAIT<=WAIT-1; STAR<=(WAIT==1)?S1:Wbit; end
      Wstop: begin WAIT<=WAIT-1; STAR<=(WAIT==1)?S2:Wstop; end
    endcase
endmodule

//SINTESI-2
module XXX(clock, reset_, rxd, mw_, a9_a0, d7_d0);
  input clock, reset_, rxd;
  output mw_;
  output [7:0] d7_d0;
  output [9:0] a9_a0;

  reg MW_;                            assign mw_ = MW_;
  reg [17:0] BUFFER;                  assign d7_d0 = BUFFER[17:10]; assign a9_a0 = BUFFER[9:0];
  reg [4:0] COUNT;
  reg [3:0] WAIT;
  reg [2:0] STAR;                     parameter S0=0, S1=1, S2=2, S3=3, Wbit=4, Wstop=5;

  parameter start_bit=1'B0;

  //reg BUFFER
  wire b0; assign b0=(STAR == S1)?1:0;
  always @(reset_ == 0) begin BUFFER<=BUFFER; end
  always @(posedge clock) if (reset_ == 1)
    casex(b0)
      1: begin BUFFER<={rxd,BUFFER[17:11]}; end
      0: begin BUFFER<=BUFFER; end
    endcase

  //reg others
  always @(reset_ == 0) begin MW_<=1; STAR<=S0; end
  always @(osedge clock) if (reset_ == 1)
    casex(STAR)
      S0: begin COUNT<=18; WAIT<=11; STAR<=(rxd==start_bit)?Wbit:S0; end
      S1: begin COUNT<=COUNT-1; WAIT<=7; STAR<=(COUNT==1)?Wstop:Wbit; end
      S2: begin MW_<=0; STAR<=S3; end
      S3: begin MW_<=1; STAR<=S0; end
      Wbit: begin WAIT<=WAIT-1; STAR<=(WAIT==1)?S1:Wbit; end
      Wstop: begin WAIT<=WAIT-1; STAR<=(WAIT==1)?S2:Wstop; end
    endcase
endmodule

//SINTESI-3
module XXX(clock, reset_, rxd, mw_, a9_a0, d7_d0);
  input clock, reset_, rxd;
  output mw_;
  output [7:0] d7_d0;
  output [9:0] a9_a0;
  wire b0;
  Parte_Operativa PO(clock, reset_, rxd, mw_, a9_a0, d7_d0, b0);
  Parte_Controllo PC(...);
endmodule

module Parte_Operativa(clock, reset_, rxd, mw_, a9_a0, d7_d0, b0);
  input clock, reset_, rxd, b0;
  output mw_;
  output[9:0] a9_a0;
  output[7:0] d7_d0;
  //reg BUFFER
  always @(reset_ == 0) begin BUFFER<=BUFFER; end
  always @(posedge clock) if (reset_ == 1)
    casex(b0)
      1: begin BUFFER<={rxd,BUFFER[17:11]}; end
      0: begin BUFFER<=BUFFER; end

  //reg others
  always @(reset_ == 0) begin MW_<=1; STAR<=S0; end
  always @(osedge clock) if (reset_ == 1)
    casex(STAR)
      S0: begin COUNT<=18; WAIT<=11; STAR<=(rxd==start_bit)?Wbit:S0; end
      S1: begin COUNT<=COUNT-1; WAIT<=7; STAR<=(COUNT==1)?Wstop:Wbit; end
      S2: begin MW_<=0; STAR<=S3; end
      S3: begin MW_<=1; STAR<=S0; end
      Wbit: begin WAIT<=WAIT-1; STAR<=(WAIT==1)?S1:Wbit; end
      Wstop: begin WAIT<=WAIT-1; STAR<=(WAIT==1)?S2:Wstop; end
    endcase
endmodule
