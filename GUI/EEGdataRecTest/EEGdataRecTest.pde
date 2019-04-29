import processing.serial.*; 
Serial myPort;    // The serial port

byte[] inBuffer = new byte[30];
byte[] inBufferWaste=new byte[52];
int lf = 10;      // ASCII linefeed 
boolean DAFlag=false;
boolean EnteringPloting=false;
int OffsetPosi=0;
  //int lf=854720;
int[] ECGdatas = new int[3];
int[] EEGdatas = new int[8];
float[] EEGdatasRead = new float[8];
int[] PPGDatas = new int[2];
float a=100,b=240;
int pointer=0;
int pointerPPG=0;
int pointerEEG=0;
int STAT=0;
float offsetSum = 0;
float[] displaydata = new float[1000]; //150Hz, 6.67s  150Hz, 200Hz sampleing rate, display 10s

float[] displayPPG1data = new float[333]; //200Hz sampleing rate, display 10s
float[] displayPPG2data = new float[333]; //200Hz sampleing rate, display 10s


float[] displayEEGdata = new float[1000]; //250Hz sampleing rate, display 4s

ComputeBaseline EEG_baseline = new ComputeBaseline();
ComputeBaseline PPG1_baseline = new ComputeBaseline();
ComputeBaseline PPG2_baseline = new ComputeBaseline();
ComputeBaseline EEG1_baseline = new ComputeBaseline();
IIRNotch NotchFilter = new IIRNotch();
LowPass LowPassFilter = new LowPass();
HighPass HighPassFilter = new HighPass();

float x_old = 1;
float y_old = 100;
float x = 1;
float y = 100;
class IIRNotch {
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

class ComputeBaseline {
  int datapointer;
  float datasum;
  float[] baselinedatas = new float[100];
  float meansumval=0;
  float baselineval=200;
  float prevdata=0;
  ComputeBaseline (){
    datapointer=0;
    datasum=0;
  }
  boolean isabnormal(float data){
    //return (abs(data-prevdata)>600&&prevdata!=0);
    return (abs(data-prevdata)>60000&&prevdata!=0);
  }
  boolean isabnormalin(float data){
    //return (abs(data-prevdata)>200&&prevdata!=0);
    return (abs(data-prevdata)>200000&&prevdata!=0);
  }
  void addEEGData(float data){
    if(datapointer>99){
      datapointer=0;
    }
    if(isabnormalin(data)){// delete abnomal val
      //data=prevdata;
    }
    baselinedatas[datapointer]=data;
    datapointer++;
    datasum++;
    prevdata=data;
  }
  float compute(float factor, float base){
    if(datasum>100){
      meansumval=0;
      for(int i=0;i<100;i++){
        meansumval+=baselinedatas[i];
      }
      if(abs(baselineval-((meansumval/100)*factor+base))>200){
        baselineval=(meansumval/100)*factor+base; //update baseline only while too large
      }
      return baselineval;
    }
    else{
      return 200;
    }
  }
}

void setup() {
  frameRate(30);
  size(1000, 800);
  printArray(Serial.list());
  myPort = new Serial(this, Serial.list()[2], 115200); 
  myPort.write('B');
  //inBufferWaste = myPort.readBytes(30);
  //myPort.clear();
  thread("readDataThread");
}

void draw() {
  background(200);
  drawEEGlines();
}
void displaybuffData(byte[] inBuffer){
  print(hex(inBuffer[0])+" ");
  for(int i=1;i<28;i++)
  {
    print(hex(inBuffer[i])+" ");
  }
  println(hex(inBuffer[28]));
}
void readDataThread(){
  myPort.clear();
  //myPort.readBytesUntil(lf, inBuffer);
  while(true){
    //int time = millis();
    //println("Bef port available: "+myPort.available());
    if (myPort.available() > 200){
      myPort.clear();
      DAFlag=false;
    }
    while (myPort.available() < 29){
      delay(1);
      //println("Waiting for UART Port");
    }
    //println("Aft port available: "+myPort.available());
    if (DAFlag) {
      inBuffer = myPort.readBytes(29);
      //displaybuffData(inBuffer);
      if(int(inBuffer[0])==192){
        STAT=(convertByte(inBuffer[0])<<16)+(convertByte(inBuffer[1])<<8)+convertByte(inBuffer[2]);
        print("STAT: "+hex(STAT)+" ");
        for(int ss=0;ss<8;ss++)
        {
          EEGdatas[ss]=(convertByte(inBuffer[(ss+1)*3])<<16)+(convertByte(inBuffer[(ss+1)*3+1])<<8)+convertByte(inBuffer[(ss+1)*3+2]);
          if(EEGdatas[ss]>=0x800000)
          {
            EEGdatas[ss]=-(((~EEGdatas[ss])&0x7fffff)+1);
          }
          //EEGdatas[6]=EEGdatas[6]-mean(float(offsetRcv));
          EEGdatasRead[ss]=(float(EEGdatas[ss])*4.5*2/16)/(2^24);//in mV
          //print("EEGData"+ss+": "+(EEGdatas[ss])+" ");
          print("EEGDataFloat"+ss+": "+(EEGdatasRead[ss])+" ");
        }
        println("EEGDataFloat6: "+EEGdatasRead[6]+"Offset: "+offsetSum/500);
        if(OffsetPosi<500){
          offsetSum+=EEGdatasRead[6];
          OffsetPosi++;
        }else{
          if(EnteringPloting==false){
            delay(10);
            myPort.write('S');
            EnteringPloting=true;
          }
          EEGdatasRead[6]-=offsetSum/500;
          //updateDataEEG(EEGdatasRead[6]);
          updateDataEEG(LowPassFilter.runfilter(NotchFilter.runfilter(EEGdatasRead[6])));
        }
        delay(1);
      }
    }else{//DAFlag=0
        myPort.readBytesUntil(lf, inBufferWaste);
        if(ifexist0D0A(inBufferWaste)){
          DAFlag=true;
        }
        delay(1);
    }
    delay(1);
    //println(millis() -time);
  }
}

boolean ifexist0D0A(byte[] inBufferWaste){
  boolean res=false;
  int Position0A=1;
  for(int i=1;i<30;i++){
    if(int(inBufferWaste[i])==10){//0x0A
      Position0A=i;
      break;
    }
  }
  if(int(inBufferWaste[Position0A-1])==13){//0x0D
    res=true;
  }else{
    res=false;
  }
  return res;
}

void stop() {
  myPort.write('T');
} 

void updateDataEEG(float EEGdata){
  if (pointerEEG>=999){
    pointerEEG=0;
  }
  EEG1_baseline.addEEGData(EEGdata);
  //if(EEG1_baseline.isabnormal(EEGdata)){
    //EEGdata=EEG1_baseline.prevdata;
  //}
  //a=1;
  a=0.01;
  //b=1800; 
  b=EEG1_baseline.compute(a,200);
  //b=-900; 
  println("baseline: "+b);
  displayEEGdata[pointerEEG]=abs((-a*(EEGdata)+b));//resize 0x1FFFFF
  println("Data to Display Converted: "+displayEEGdata[pointerEEG]);
  pointerEEG++;
}

void drawEEGlines() {
  //background(200);
  float y_old=displayEEGdata[999];
  for(int i=0;i<1000;i+=1){
    y=displayEEGdata[i];
    stroke(1);
    line(i,y_old,(i+1),y);
    y_old=y;
  }
  //point(pointer,displaydata[pointer]); 
}

int convertByte(byte data){
  int val=0;
  val=data;
  if(data<0){
    val=data+256;
  }
  return val;
}
