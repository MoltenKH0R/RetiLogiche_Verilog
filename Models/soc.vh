//------------------------------------------------------------------------------
module Formatore_di_Impulsi_Soc_Eoc(clock, reset_, soc, eoc, numero, out);
  input clock, reset_, eoc;
  output soc, out;
  input [7:0] numero;

  reg SOC; assign soc=SOC;
  reg OUT; assign out=OUT;
  reg [7:0] COUNT;
  reg [1:0] STAR; parameter S0='B00, S1='B01, S2='B10;

  always @(reset_==0) #1 begin STAR<=S0; OUT<=0; SOC<=0; end
  always @(posedge clock) if (reset_==1) #3
    casex(STAR)
      S0: begin OUT<=0; SOC<=1; STAR<=(eoc==1)?S0:S1; end
      S1: begin SOC<=0; COUNT<=numero; STAR<=(eoc==0)?S1:S2; end
      S2: begin OUT<=1; COUNT<=COUNT-1; STAR<=(COUNT==1)?S0:S2; end
    endcase
  endmodule


//-SINTESI1---------------------------------------------------------------------
module Formatore_di_Impulsi_Soc_Eoc(clock, reset_, soc, eoc, numero, out);
  input clock, reset_, eoc;
  output soc, out;
  input [7:0] numero;

  reg SOC; assign soc=SOC;
  reg OUT; assign out=OUT;
  reg [1:0] STAR; parameter S0='B00, S1='B01, S2='B10;
  reg [7:0] COUNT;

    //reg SOC
  always @(reset_ == 0) #1 begin SOC<=0; end
  always @(posedge clock) if(reset_ == 1) #3
    casex(STAR)
      S0: begin SOC<=1; end
      S1: begin SOC<=0; end
      S2: begin SOC<=SOC; end
    endcase

    //reg OUT
  always @ (reset_ == 0) #1 begin OUT<=0; end
  always @ (posedge clock) if (reset_ == 1)#3
    casex(STAR)
      S0: begin OUT<=0; end
      S1: begin OUT<=OUT; end
      S2: begin OUT<=1; end
    endcase

    //reg STAR
  always @ (reset_ == 0) #1 begin STAR<=S0; end
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(eoc==1)?S0:S1; end
      S1: begin STAR<=(eoc==0)?S1:S2; end
      S2: begin STAR<=(COUNT==1)?S0:S2; end
  endcase

    //reg COUNT
  always @ (reset_ == 0) #1 begin COUNT<=COUNT; end
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin COUNT<=COUNT; end
      S1: begin COUNT<=numero; end
      S2: begin COUNT<=COUNT-1; end
    endcase
  endmodule
//-variabili di comando e di stato----------------------------------------------

wire b1, b0; assign{b1, b0} = (STAR==S0)?'B00:
                              (STAR==S1)?'B01:
                              (STAR==S2)?'B1X:
                              /*defauldt*/'BXX;
wire c1, c0; assign c1 = (eoc == 1)?1:0;
             assign c0 = (COUNT == 1 )?1:0;
//-SINTESI2---------------------------------------------------------------------
module Formatore_di_Impulsi_Soc_Eoc(clock, reset_, soc, eoc, numero, out);
  input clock, reset_, eoc;
  output soc, out;
  input [7:0] numero;

  reg SOC; assign soc=SOC;
  reg OUT; assign out=OUT;
  reg [1:0] STAR; parameter S0='B00, S1='B01, S2='B10;
  reg [7:0] COUNT;

  wire b1, b0; assign{b1, b0} = (STAR==S0)?'B00:
                                (STAR==S1)?'B01:
                                (STAR==S2)?'B1X:
                                /*defauldt*/'BXX;
  wire c1, c0; assign c1 = eoc;
               assign c0 = COUNT;

    //reg SOC
  always @(reset_ == 0) #1 begin SOC<=0; end
  always @(posedge clock) if(reset_ == 1) #3
    casex({b1,b0})
      B00: begin SOC<=1; end
      B01: begin SOC<=0; end
      B10: begin SOC<=SOC; end
    endcase

    //reg OUT
  always @ (reset_ == 0) #1 begin OUT<=0; end
  always @ (posedge clock) if (reset_ == 1)#3
    casex({b1,b0})
      B00: begin OUT<=0; end
      B01: begin OUT<=OUT; end
      B10: begin OUT<=1; end
    endcase

    //reg STAR
  always @ (reset_ == 0) #1 begin STAR<=S0; end
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: begin STAR<=(c1==1)?S0:S1; end
      S1: begin STAR<=(c1==0)?S1:S2; end
      S2: begin STAR<=(c0==1)?S0:S2; end
  endcase

    //reg COUNT
  always @ (reset_ == 0) #1 begin COUNT<=COUNT; end
  always @ (posedge clock) if (reset_ == 1) #3
    casex({b1,b0})
      B00: begin COUNT<=COUNT; end
      B01: begin COUNT<=numero; end
      B10: begin COUNT<=COUNT-1; end
    endcase
  endmodule

//-SINTESI3---------------------------------------------------------------------
module Formatore_di_Impulsi_Soc_Eoc(clock, reset_, soc, eoc, numero, out);
  input clock, reset_, eoc;
  output soc, out;
  input [7:0] numero;

  wire b1,b0,c1,c0;

  Parte_Operativa PO(clock, reset_, soc, eoc, numero, out, b1, b0, c1, c0);
  Parte_Controllo PC(clock, reset_, b1, b0, c1, c0);
endmodule

module Parte_Operativa(clock, reset_, soc, eoc, numero, out, b1, b0, c1, c0);
  input clock, reset_, eoc, b1, b0;
  output soc, out, c1, c0;
  input [7:0] numero;

  reg OUT; assign out=OUT;
  reg [7:0] COUNT;
  reg SOC; assign soc=SOC;

  assign c1 = (eoc == 1)?'B1:'B0;
  assign c0 = (COUNT == 1)?'B1:'B0;

  always @ (reset_ == 0) #1 SOC<=0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex({b1,b0})
      B00: begin SOC<=1; end
      B01: begin SOC<=0; end
      B10: begin SOC<=SOC; end
    endcase

  always @ (reset_ == 0) #1 OUT<=0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex({b1,b0})
      B00: begin OUT<=0; end
      B01: begin OUT<=OUT; end
      B10: begin OUT<=1; end
    endcase

  always @ (reset_ == 0) #1 COUNT<=COUNT;
  always @ (posedge clock) if (reset_ == 1) #3
    casex({b1,b0})
      B00: begin COUNT<=COUNT; end
      B01: begin COUNT<=numero; end
      B10: begin COUNT<=COUNT-1; end
    endcase
endmodule

module Parte_Controllo(clock, reset_, b1, b0, c1, c0);
  input clock, reset_, c1, c0;
  output b1, b0;

  reg [1:0] parameter S0='B00, S1='B01, S2='B10;
  assign {b1,b0} = (STAR==S0)?'B00:
                   (STAR==S1)?'B01:
                   (STAR==S2)?'B1X:
                  /*defauldt*/'BXX;

  always @ (reset_ == 0) #1 STAR<=S0;
  always @ (posedge clock) if (reset_ == 1) #3
    casex(STAR)
      S0: STAR<=(c1)?S0:S1;
      S1: STAR<=(c1)?S2:S1;
      S2: STAR<=(c0)?S0:S2;
    endcase
  endmodule
