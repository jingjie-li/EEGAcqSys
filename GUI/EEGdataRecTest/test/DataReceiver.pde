//readEEG channel
import processing.serial.*;
int lf=10;

//class ComputeBaseline {
//  int datapointer;
//  float datasum;
//  float[] baselinedatas = new float[100];
//  float meansumval=0;
//  float baselineval=200;
//  float prevdata=0;
//  ComputeBaseline (){
//    datapointer=0;
//    datasum=0;
//  }
//  boolean isabnormal(float data){
//    //return (abs(data-prevdata)>600&&prevdata!=0);
//    return (abs(data-prevdata)>60000&&prevdata!=0);
//  }
//  boolean isabnormalin(float data){
//    //return (abs(data-prevdata)>200&&prevdata!=0);
//    return (abs(data-prevdata)>200000&&prevdata!=0);
//  }
//  void addEEGData(float data){
//    if(datapointer>99){
//      datapointer=0;
//    }
//    if(isabnormalin(data)){// delete abnomal val
//      //data=prevdata;
//    }
//    baselinedatas[datapointer]=data;
//    datapointer++;
//    datasum++;
//    prevdata=data;
//  }
//  float compute(float factor, float base){
//    if(datasum>100){
//      meansumval=0;
//      for(int i=0;i<100;i++){
//        meansumval+=baselinedatas[i];
//      }
//      if(abs(baselineval-((meansumval/100)*factor+base))>200){
//        baselineval=(meansumval/100)*factor+base; //update baseline only while too large
//      }
//      return baselineval;
//    }
//    else{
//      return 200;
//    }
//  }
//}


Serial myPort;    // The serial port

byte[] inBuffer = new byte[31];
byte[] inBufferWaste=new byte[52];
//int lf = 10;      // ASCII linefeed 
boolean DAFlag=false;
boolean EnteringPloting=false;



static class EegReceiverConfig{
  static int nchan = num_chan;
  static int eeg_buff_size = getSampleRateSafe() * 5; // 5 seconds is the maximum time for the 
  static float[][] eeg_data_buff = new float[num_chan][eeg_buff_size];
  static float[][] eeg_data_buff_copy = new float[num_chan][eeg_buff_size];
  static float[] channel_baseline = new float[num_chan];
  final static int UPDATE_MILLIS = 40;
  static int nPointsPerUpdate = int(round(float(UPDATE_MILLIS) * getSampleRateSafe()/ 1000.f));
  static int points_count = 0;
  static float[][] update_data_eeg_buff = new float[num_chan][nPointsPerUpdate];
  static boolean entering_ploting=false;
  static int offset_posi = 0; 
  static Serial myPort;
  static int getSampleRateSafe()
  {
    return 250;
  }
}

void setup_serial_port()
{
      EegReceiverConfig.myPort = new Serial(this, Serial.list()[5], 115200); 
      EegReceiverConfig.myPort.write('B');

}



void read_data_thread(){
  
  EegReceiverConfig.myPort.clear();  
  //EegReceiverConfig.myPort.readBytesUntil(lf, inBuffer);

while(true){  
  
    while (EegReceiverConfig.myPort.available() < 30){
            delay(1);
          }
      if (DAFlag) {
          
          inBuffer[25]=0;inBuffer[26]=0;inBuffer[27]=0;inBuffer[28]=0;
          //myPort.readBytesUntil(lf, inBuffer); // until 0x0A
          inBuffer = EegReceiverConfig.myPort.readBytes(29);
          //displaybuffData(inBufferWaste);
          float[] temp = data_transform(inBuffer);
          printArray(temp);
          for(int i = 0; i < EegReceiverConfig.nchan; i++){
           
            EegReceiverConfig.update_data_eeg_buff[i][EegReceiverConfig.points_count] = temp[i];
          }
          
          //println(EegReceiverConfig.update_data_eeg_buff[1]);
          //println(EegReceiverConfig.eeg_data_buff[1]);
          EegReceiverConfig.points_count++;
          if (EegReceiverConfig.points_count > (EegReceiverConfig.nPointsPerUpdate - 1)){
              for(int i = 0; i < EegReceiverConfig.nchan; i++){
              append_Shift(EegReceiverConfig.eeg_data_buff[i], EegReceiverConfig.update_data_eeg_buff[i]);
              EegReceiverConfig.eeg_data_buff_copy[i] = EegReceiverConfig.eeg_data_buff[i].clone();
            }
              EegReceiverConfig.points_count = 0;

          }
          

          delay(1);
        }
        else{//DAFlag=0
            EegReceiverConfig.myPort.readBytesUntil(lf, inBufferWaste);
            if(ifexist0D0A(inBufferWaste)){
              DAFlag=true;
            }
            delay(1);
      }
    delay(2);
  }
}



boolean ifexist0D0A(byte[] inBufferWaste){
  print("ifexist");
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

void append_Shift(float[] data, float[] newData) {
      while(true){
        int nshift = newData.length;
        int end = data.length-nshift;
        for (int i=0; i < end; i++) {
          data[i]=data[i+nshift];  //shift data points down by 1
        }
        for (int i=0; i<nshift; i++) {
          data[end+i] = newData[i];  //append new data
        }
        break;
    }

  
}


//void updateDataEEG(float eeg_data[]){
//  for(int i = 0; i < EegReceiverConfig.nchan; i++)

//  //if(EEG1_baseline.isabnormal(EEGdata)){
//    //EEGdata=EEG1_baseline.prevdata;
//  //}
//  a=0.01;
//  //b=1800; 
//  //b=EEG1_baseline.compute(a,200);
//  b=-900; 
//  println("baseline: "+b);
//  displayEEGdata[pointerEEG]=abs((-a*(float(EEGdata))+b));//resize 0x1FFFFF
//  println("baseline computed: "+displayEEGdata[pointerEEG]);
//  pointerEEG++;
//}

int size_STAT_Byte = 1; 
int size_Channel_Byte = 3; 

//EEG Data Transform
float[] data_transform(byte[] data_packet){
  //println("data_transform");
  //verify the data_packet. 
  int[] eeg_datas = new int[8];
  float[]  eeg_datas_read = new float[8];
  int meta_data = 0;
  if ((int(data_packet[0])==192))// && ((int)(data_packet[27])) == 13 && ((int)(data_packet[28]))== 10)
  {
        //print(hex(data_packet[0])+" ");
        //for(int i = 1;i < 28 ; i++)
        //{
        //  print(hex(data_packet[i])+" ");
        //}
        //println(hex(data_packet[28]));
        meta_data = ((convert_byte(inBuffer[0])<<16)+(convert_byte(inBuffer[1])<<8)+convert_byte(inBuffer[2]));
        //print("STAT: "+hex(meta_data)+" ");
        for(int ss=0;ss<8;ss++)
        {
          eeg_datas[ss]=(convert_byte(inBuffer[(ss+size_STAT_Byte)*size_Channel_Byte])<<16)+
          (convert_byte(inBuffer[( ss + size_STAT_Byte)*size_Channel_Byte+1])<<8)+
          convert_byte(inBuffer[( ss + size_STAT_Byte )*size_Channel_Byte+2]);
          if(eeg_datas[ss]>=0x800000)
          {
            eeg_datas[ss]=-(((~eeg_datas[ss])&0x7fffff)+1);
          }
          
          eeg_datas_read[ss]=float(eeg_datas[ss])*2.5*1000*16/(2^24);
          //print("EEGData"+ss+": "+(eeg_datas_read[ss])+" ");
        }
        
          if(EegReceiverConfig.offset_posi < 500){
            for(int i = 0; i < EegReceiverConfig.nchan; i++)
            {
              EegReceiverConfig.channel_baseline[i] += eeg_datas_read[i];
              EegReceiverConfig.offset_posi++; 
            }
          }
          else{
            for(int i = 0; i < EegReceiverConfig.nchan; i++){
                      eeg_datas_read[i] -= EegReceiverConfig.channel_baseline[i];
                      //print("EEGData"+i+": "+(eeg_datas_read[i])+" ");       
            }
            
            if(EegReceiverConfig.entering_ploting==false){

                for(int i = 0; i < EegReceiverConfig.nchan; i++) EegReceiverConfig.channel_baseline[i] = - EegReceiverConfig.channel_baseline[i];
                delay(50);
                EegReceiverConfig.myPort.write('P');
                EegReceiverConfig.entering_ploting=true;
              
            }
            
            
          }
       

      return eeg_datas_read;
    }
    else{
      return eeg_datas_read;
    }
}


int convert_byte(byte data){
    int val=0;
    val=data;
    if(data<0){
      val=data+256;
    }
    return val;
  }

void displaybuffData(byte[] inBuffer){
  print(hex(inBuffer[0])+" ");
  for(int i=1;i<28;i++)
  {
    print(hex(inBuffer[i])+" ");
  }
  println(hex(inBuffer[28]));
}
