class IIRNotch {
  //clea 50 Hz 
  float[] w0=new float[3];
  float[] IIR_50Notch_A=new float[3];
  float[] IIR_50Notch_B=new float[3];
  float y0=0;
  IIRNotch(){
    IIR_50Notch_A[0]=1;
    IIR_50Notch_A[1]=-0.482936741845509;
    IIR_50Notch_A[2]=0.562816125444333;
    IIR_50Notch_B[0]=0.781408062722166;
    IIR_50Notch_B[1]=-0.482936741845509;
    IIR_50Notch_B[2]=0.781408062722166;
    w0[0]=0;
    w0[1]=0;
    w0[2]=0;
  }
  float runfilter(float convertval){
    w0[0]=IIR_50Notch_A[0]*convertval-IIR_50Notch_A[1]*w0[1]-IIR_50Notch_A[2]*w0[2];
    y0=IIR_50Notch_B[0]*w0[0]+IIR_50Notch_B[1]*w0[1]+IIR_50Notch_B[2]*w0[2];
    w0[2]=w0[1];
    w0[1]=w0[0];
    return y0;
  }
}


class LowPass {
  //
  float[] w0=new float[3];
  float[] LP_A=new float[3];
  float[] LP_B=new float[3];
  float y0=0;
  LowPass(){
    LP_A[0]=1;
    LP_A[1]=-0.369527377351241;
    LP_A[2]=0.195815712655833;
    LP_B[0]=0.206572083826148;
    LP_B[1]=0.413144167652296;
    LP_B[2]=0.206572083826148;
    w0[0]=0;
    w0[1]=0;
    w0[2]=0;
  }
  float runfilter(float convertval){
    w0[0]=LP_A[0]*convertval-LP_A[1]*w0[1]-LP_A[2]*w0[2];
    y0=LP_B[0]*w0[0]+LP_B[1]*w0[1]+LP_B[2]*w0[2];
    w0[2]=w0[1];
    w0[1]=w0[0];
    return y0;
  }
}

class HighPass {
  float[] w0={0,0,0};
  float[] HP_A={1,-1.822694925196308,0.837181651256023};
  float[] HP_B={0.914969144113083,-1.829938288226165,0.914969144113083};
  float y0=0;
  HighPass(){
  }
  float runfilter(float convertval){
    w0[0]=HP_A[0]*convertval-HP_A[1]*w0[1]-HP_A[2]*w0[2];
    y0=HP_B[0]*w0[0]+HP_B[1]*w0[1]+HP_B[2]*w0[2];
    w0[2]=w0[1];
    w0[1]=w0[0];
    return y0;
  }
}
