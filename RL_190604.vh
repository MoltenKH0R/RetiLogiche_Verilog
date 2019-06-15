//DESCRIZIONE

module XXX(clock, reset_, x, d15_d0, z7_z0, a3_a0);

  input clock, reset_, x;
  input [15:0] d15_d0;

  output [3:0] a3_a0;
  output [7:0] z7_z0;

  reg [3:0] A3_A0;                assign a3_a0 = A3_A0;
  reg [7:0] OUT;                  assign z7_z0 = OUT;
  reg [3:0] COUNT;
  reg STAR;                       parameter S0=0, S1=1;

  parameter periodi=10;

  always @(reset_ == 0) begin STAR<=0; A3_A0<=0; COUNT<=periodi; OUT<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin COUNT<=COUNT-1; STAR<=(COUNT==2)?S1:S0; end
      S1: begin OUT<=d15_d0[7:0]; A3_A0<=(x==0)?d15_d0[15:12]:d15_d0[11:8]; COUNT<=periodi; STAR<=S0; end
    endcase
endmodule

//SINTESI-1

module XXX(clock, reset_, x, d15_d0, z7_z0, a3_a0);

  input clock, reset_, x;
  input [15:0] d15_d0;

  output [3:0] a3_a0;
  output [7:0] z7_z0;

  reg [3:0] A3_A0;                assign a3_a0 = A3_A0;
  reg [7:0] OUT;                  assign z7_z0 = OUT;
  reg [3:0] COUNT;
  reg STAR;                       parameter S0=0, S1=1;

  parameter periodi=10;

  //reg A3_A0
  always @(reset_ == 0) begin A3_A0<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin A3_A0<=A3_A0; end
      S1: begin A3_A0<=(x==0)?d15_d0[15:12]:d15_d0[11:8]; end
    endcase

  //reg OUT
  always @(reset_ == 0) begin OUT<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin OUT<=OUT; end
      S1: begin OUT<=d15_d0[7:0]; end
    endcase

  //reg COUNT
  always @(reset_ == 0) begin COUNT<=periodi; end
  always @(posedge clock) of (reset_ == 1) #3
    casex(STAR)
      S0: begin COUNT<=COUNT-1; end
      S1: begin COUNT<=periodi; end
    endcase

  //reg STAR
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(COUNT == 2)?S1:S2; end
      S1: begin STAR<=S0; end
    endcase
  endmodule

//SINTESI-2
module XXX(clock, reset_, x, d15_d0, z7_z0, a3_a0);

  input clock, reset_, x;
  input [15:0] d15_d0;

  output [3:0] a3_a0;
  output [7:0] z7_z0;

  reg [3:0] A3_A0;                assign a3_a0 = A3_A0;
  reg [7:0] OUT;                  assign z7_z0 = OUT;
  reg [3:0] COUNT;
  reg STAR;                       parameter S0=0, S1=1;

  parameter periodi=10;
  wire b0; assign b0 = (STAR == S0)?1:0;

  //reg A3_A0
  always @(reset_ == 0) begin A3_A0<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin A3_A0<=A3_A0; end;
      0: begin A3_A0<=(x==0)?d15_d0[15:12]:d15_d0[11:8]; end
    endcase

  //reg OUT
  always @(reset_ == 0) begin OUT<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin OUT<=OUT; end
      0: begin OUT<=d15_d0[7:0]; end
    endcase

  //reg COUNT
  always @(reset_ == 0) begin OUT<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin COUNT<=COUNT-1; end
      0: begin COUNT<=periodi; end
    endcase

  //reg STAR
  wire c0; c0 = (COUNT == 2)?1:0;
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(c0 == 1)?S1:S2; end
      S1: begin STAR<=S0; end
    endcase

//variabili di COMANDO

b0 = (STAR == S0)?1:0;

//variabili di controllo

c0 = (COUNT == 2)?1:0; ----> c0 = !COUNT[3:2] & COUNT[1] & !COUNT[0];

//SINTESI-3
module XXX(clock, reset_, x, d15_d0, z7_z0, a3_a0);

  input clock, reset_, x;
  input [15:0] d15_d0;

  output [3:0] a3_a0;
  output [7:0] z7_z0;

  wire b0, c0;
  Parte_Operativa PO(clock, reset_, x, d15_d0, z7_z0, a3_a0, b0, c0);
  Parte_Controllo PC(clock, reset_ b0, c0);
endmodule
module Parte_Operativa(clock, reset_ x, d15_d0, z7_z0, b0, c0);
  input clock, reset, x, b0;
  input [15:0] d15_d0;

  output c0;
  output [3:0] a3_a0;
  output [7:0] z7_z0;

  reg [3:0] A3_A0;                assign a3_a0 = A3_A0;
  reg [7:0] OUT;                  assign z7_z0 = OUT;
  reg [3:0] COUNT;
  parameter periodi=10;
  assign c0 = (COUNT == 2)?1:0; ----> c0 = !COUNT[3:2] & COUNT[1] & !COUNT[0];
  //reg A3_A0
  always @(reset_ == 0) begin A3_A0<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
    1: begin A3_A0<=A3_A0; end;
    0: begin A3_A0<=(x==0)?d15_d0[15:12]:d15_d0[11:8]; end
  endcase

  //reg OUT
  always @(reset_ == 0) begin OUT<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin OUT<=OUT; end
      0: begin OUT<=d15_d0[7:0]; end
    endcase

  //reg COUNT
  always @(reset_ == 0) begin OUT<=0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b0)
      1: begin COUNT<=COUNT-1; end
      0: begin COUNT<=periodi; end
    endcase
endmodule

module Parte_Controllo(clock, reset_ b0, c0);
  input clock, reset_, c0;
  output b0;

  reg STAR;                 parameter S0=0, S1=1;
  assign b0 = (STAR == S0)?1:0;

  //reg STAR
  wire c0; c0 = (COUNT == 2)?1:0;
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(c0 == 1)?S1:S2; end
      S1: begin STAR<=S0; end
    endcase
endmodule
