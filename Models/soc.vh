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
