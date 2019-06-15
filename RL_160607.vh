//DESCRIZIONE

module XX(clock, reset_, z, r1, r2, out);

  input clock, reset_, r1, r2;
  output z;
  output [7:0] out;

  reg Z;                              assign z = Z;
  reg [7:0] OUT;                      assign out = OUT;
  reg [7:0] COUNT;
  reg [7:0] RITARDO;
  reg [1:0] STAR;                     parameter [1:0] S0=0, S1=1, S2=2, S3=3;

  parameter cicli = 500;

  always @(reset_ == 0) begin STAR<=0; COUNT<=cicli; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin Z<=1; COUNT<=COUNT-1; STAR<=S1; end
      S1: begin COUNT<=COUNT-1; RITARDO<=RITARDO+(r1&(!r2)); STAR<=(r2==0)?S1:S2; end
      S2: begin COUNT<=COUNT-1; Z<=0; STAR<=(r2==1)?S2:S3; end
      S3: begin COUNT<=(COUNT == 1)?cicli:(COUNT-1); OUT<=(COUNT == 1)?RITARDO:OUT; STAR<=(COUNT == 1)?S0:S3; end
    endcase
endmodule

//SINTESI-1


module XX(clock, reset_, z, r1, r2, out);

  input clock, reset_, r1, r2;
  output z;
  output [7:0] out;

  reg Z;                              assign z = Z;
  reg [7:0] OUT;                      assign out = OUT;
  reg [7:0] COUNT;
  reg [7:0] RITARDO;
  reg [1:0] STAR;                     parameter [1:0] S0=0, S1=1, S2=2, S3=3;

  parameter cicli = 500;

  //reg Z
  always @(reset_ == 0) begin Z<=Z; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin Z<=1; end
      S2: begin Z<=0; end
      S1,S3: begin Z<=Z; end
    endcase

  //reg OUT
  always @(reset_ == 0) begin OUT<=OUT; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S3: begin OUT<=(COUNT == 1)?RITARDO:OUT; end
      S0,S1,S2: begin OUT<=OUT; end
    endcase

  //reg COUNT
  always @(reset_ == 0) begin COUNT<=cicli; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S3: begin COUNT<=(COUNT == 1)?cicli:(COUNT-1); end
      S0,S1,S2: begin COUNT<=COUNT-1; end
    endcase

  //reg RITARDO
  always @(reset_ == 0) begin RITARDO<=RITARDO; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S1: begin RITARDO<=RITARDO+(r1&(!r2)); end
      S0: begin RITARDO<=0; end
      S2,S3: begin RITARDO<=RITARDO; end
    endcase

  //reg STAR
  always @(reset_ == 0) begin STAR<=S0; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=S1; end
      S1: begin STAR<=(r2==0)?S1:S2; end
      S2: begin STAR<=(r2==1)?S2:S3; end
      S3: begin STAR<=(COUNT==1)?S0:S3; end
    endcase
  endmodule

  //SINTESI-2

  module XX(clock, reset_, z, r1, r2, out);

    input clock, reset_, r1, r2;
    output z;
    output [7:0] out;

    reg Z;                              assign z = Z;
    reg [7:0] OUT;                      assign out = OUT;
    reg [7:0] COUNT;
    reg [7:0] RITARDO;
    reg [1:0] STAR;                     parameter [1:0] S0=0, S1=1, S2=2, S3=3;

    parameter cicli = 500;

    //reg Z
    wire b1,b0; assign {b1,b0} = (STAR == S0)?'B00:(STAR == S2)?'B10:BX1;
    always @(reset_ == 0) begin Z<=Z; end
    always @(posedge clock) if (reset_ == 1) #3
      casex({b1, b0})
        'B00: begin Z<=1; end
        'B10: begin Z<=0; end
        'BX1: begin Z<=Z; end
      endcase

    //reg OUT
    wire b2; assign b2 = (STAR == S3)?1:0;
    always @(reset_ == 0) begin OUT<=OUT; end
    always @(posedge clock) if (reset_ == 1) #3
      casex(b2)
        1: begin OUT<=(COUNT == 1)?RITARDO:OUT; end
        0: begin OUT<=OUT; end
      endcase

    //reg COUNT
    always @(reset_ == 0) begin COUNT<=cicli; end
    always @(posedge clock) if (reset_ == 1) #3
      casex(b2)
        1: begin COUNT<=(COUNT == 1)?cicli:(COUNT-1); end
        0: begin COUNT<=COUNT-1; end
      endcase

    //reg RITARDO
    wire b4, b3; assign {b4, b3} = (STAR == S2)?'B00:(STAR == S1)?'B01:'B1X;
    always @(reset_ == 0) begin RITARDO<=RITARDO; end
    always @(posedge clock) if (reset_ == 0) #3
      casex({b4,b3})
        'B00: begin RITARDO<=0; end
        'B01: begin RITARDO<=RITARDO+(r1&(!r2)); end
        'B1X: begin RITARDO<=RITARDO; end
      endcase

    //reg STAR
    wire c1; assign c1 = (r2 == 1)?1:0;
    wire c0; assign c0 = (COUNT == 1)?1:0;
    always @(reset_ == 0) begin STAR<=S0; end
    always @(posedge clock) if (reset_ == 1) #3
      casex(STAR)
        S0: begin STAR<=S1; end
        S1: begin STAR<=(c1 == 0)?S1:S2; end
        S2: begin STAR<=(c1 == 1)?S2:S3; end
        S3: begin STAR<=(c0 == 1)?S0:S3; end
      endcase
endmodule

//variabili di comando
{b4,b3,b2,b1,b0} = (STAR == S0)?'B00000:
             (STAR == S1)?'B010X1:
             (STAR == S2)?'B1X010:'B1X1X1;

//variabili di controllo

c1 = (r2 == 1)?1:0; ----> c1 = r2;
c0 = (COUNT == 1);  ----> c0 = !COUNT[7:1] & COUNT[0];

//SINTESI-3

module XX(clock, reset_, z, r1, r2, out);

  input clock, reset_, r1, r2;
  output z;
  output [7:0] out;
  wire b2, b1, b0, c1, c0;

  Parte_Operativa PO(clock, reset_, z, r1, r2, out, b4, b3, b2, b1, b0, c1, c0);
  Parte_Controllo PC(clock, reset_, b4, b3, b2, b1, b0, c1, c0);
endmodule

module Parte_Operativa(clock, reset_, z, r1, r2, out, b4, b3, b2, b1, b0, c1, c0);

  input clock, reset_, r1, r2, b4, b3, b2, b1, b0;
  output z, c1, c0;
  output [7:0] out;

  reg Z;                              assign z = Z;
  reg [7:0] OUT;                      assign out = OUT;
  reg [7:0] COUNT;
  reg [7:0] RITARDO;
  assign {b4,b3,b2,b1,b0} = (STAR == S0)?'B00000:
                            (STAR == S1)?'B010X1:
                            (STAR == S2)?'B1X010:'B1X1X1;
  assign c1 = r2;
  assign c0 = !COUNT[7:1] & COUNT[0];

  parameter cicli = 500;

  //reg Z
  always @(reset_ == 0) begin Z<=Z; end
  always @(posedge clock) if (reset_ == 1) #3
    casex({b1, b0})
      'B00: begin Z<=1; end
      'B10: begin Z<=0; end
      'BX1: begin Z<=Z; end
    endcase

  //reg OUT
  always @(reset_ == 0) begin OUT<=OUT; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b2)
      1: begin OUT<=(COUNT == 1)?RITARDO:OUT; end
      0: begin OUT<=OUT; end
    endcase

  //reg COUNT
  always @(reset_ == 0) begin COUNT<=cicli; end
  always @(posedge clock) if (reset_ == 1) #3
    casex(b2)
      1: begin COUNT<=(COUNT == 1)?cicli:(COUNT-1); end
      0: begin COUNT<=COUNT-1; end
    endcase

  //reg RITARDO
  always @(reset_ == 0) begin RITARDO<=RITARDO; end
  always @(posedge clock) if (reset_ == 0) #3
    casex({b4,b3})
      'B00: begin RITARDO<=0; end
      'B01: begin RITARDO<=RITARDO+(r1&(!r2)); end
      'B1X: begin RITARDO<=RITARDO; end
    endcase
endmodule

module Parte_Controllo(clock, reset_, b4, b3, b2, b1, b0, c1, c0);
  input clock, reset_, c1, c0;
  output b4, b3, b2, b1, b0;

  reg [1:0] STAR; parameter [1:0] S0=0, S1=1, S2=2, S3=3;
  assign {b4,b3,b2,b1,b0} = (STAR == S0)?'B00000:
                            (STAR == S1)?'B010X1:
                            (STAR == S2)?'B1X010:'B1X1X1;
  assign c1 = r2;
  assign c0 = !COUNT[7:1] & COUNT[0];

  //reg STAR 
  always @(reset_ == 0) begin STAR<=S0;
  always @(posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=S1; end
      S1: begin STAR<=(c1 == 0)?S1:S2; end
      S2: begin STAR<=(c1 == 1)?S2:S3; end
      S3: begin STAR<=(c0 == 1)?S0:S3; end
    endcase
endmodule
