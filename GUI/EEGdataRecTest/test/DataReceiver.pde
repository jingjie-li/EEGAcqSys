//readEEG channel
import processing.serial.*;

int lf=10;




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
static class DataStorage{
  
  static File dataPath;
  static String data_path;
  static PrintWriter[] output= new PrintWriter[EegReceiverConfig.nchan];

}
void setup_serial_port()
{
      EegReceiverConfig.myPort = new Serial(this, Serial.list()[5], 115200); 
      EegReceiverConfig.myPort.write('B');

}




void read_data_thread(){
    if(test_software_mode)
  {

    int ii = 0;

    while(true)
    {
      int time_ = millis();
      float[][] test_signal = new float[8][30];
      for(int j = 0; j<test_signal.length;j++){
      for(int i = 0; i<test_signal[j].length;i++){
        
        test_signal[j][i] = random(100);
      }
      }
    while(millis() - time_<30){delay(2);}
     
        for( int i = 0; i< num_chan; i++){
        if(updating_channel[i]) 
        {
          append_Shift(EegReceiverConfig.eeg_data_buff_copy[i],test_signal[i]);
           //println(EegReceiverConfig.eeg_data_buff_copy[i][EegReceiverConfig.eeg_data_buff_copy.length - 1]);
           
        }
        }
       ii = ii+30;
      }
      
      
    }
  

  else{
        setup_serial_port();

    if(write_to_file == true)
    {
      for(int i = 0; i < EegReceiverConfig.nchan;i ++)
      {
            DataStorage.output[i] = createWriter(DataStorage.data_path +"/" + "channel_" + i+".txt"); 
      }
    }
  EegReceiverConfig.myPort.clear(); 
  initiate_filter();
  //EegReceiverConfig.myPort.readBytesUntil(lf, inBuffer);
while(true){  

  
  
  
   if (EegReceiverConfig.myPort.available() > 200){
      EegReceiverConfig.myPort.clear();
      DAFlag=false;
    }

    while (EegReceiverConfig.myPort.available() < 29){    
            delay(1);
          }
      if (DAFlag) {
          //myPort.readBytesUntil(lf, inBuffer); // until 0x0A
          inBuffer = EegReceiverConfig.myPort.readBytes(29);
          float[] temp = data_transform(inBuffer);
          for(int i = 0; i < EegReceiverConfig.nchan; i++){
           
            EegReceiverConfig.update_data_eeg_buff[i][EegReceiverConfig.points_count] = temp[i];
           if(write_to_file == true) DataStorage.output[i].println(temp[i]);
          }
          //println(EegReceiverConfig.update_data_eeg_buff[1]);
          //println(EegReceiverConfig.eeg_data_buff[1]);
          EegReceiverConfig.points_count++;
          if (EegReceiverConfig.points_count > (EegReceiverConfig.nPointsPerUpdate - 1)){
              for(int i = 0; i < EegReceiverConfig.nchan; i++){
              append_Shift(EegReceiverConfig.eeg_data_buff[i], EegReceiverConfig.update_data_eeg_buff[i]);
              if(updating_channel[i]) EegReceiverConfig.eeg_data_buff_copy[i] = EegReceiverConfig.eeg_data_buff[i].clone();
              }
              
              EegReceiverConfig.points_count = 0;
              // println(EegReceiverConfig.eeg_data_buff_copy[0][EegReceiverConfig.eeg_data_buff_copy[0].length - 1]);
              
            }
          
          source_connected = true;
          delay(1);
        }
        else{//DAFlag=0
            EegReceiverConfig.myPort.readBytesUntil(lf, inBufferWaste);
            if(ifexist0D0A(inBufferWaste)){
              DAFlag=true;
             
            }
            delay(1);
      }
    delay(1);
  }
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
void append_Shift(float[] data, float newData) {

        int end = data.length-1;
        for (int i=0; i < end; i++) {
          data[i]=data[i+1];  //shift data points down by 1
        }
        data[end] = newData;  //append new data

}

int size_STAT_Byte = 1; 
int size_Channel_Byte = 3; 

//EEG Data Transform
float[] data_transform(byte[] data_packet){
  //println("data_transform");
  //verify the data_packet. 
  int[] eeg_datas = new int[8];
  float[]  eeg_datas_read = new float[8];
  int meta_data  = 0;
  if ((int(data_packet[0])==192))// && ((int)(data_packet[27])) == 13 && ((int)(data_packet[28]))== 10)
  {

        meta_data = ((convert_byte(data_packet[0])<<16)+(convert_byte(data_packet[1])<<8)+convert_byte(data_packet[2]));

        for(int ss=0;ss<8;ss++)
        {
          eeg_datas[ss]=(convert_byte(data_packet[(ss+size_STAT_Byte)*size_Channel_Byte])<<16)+
          (convert_byte(data_packet[( ss + size_STAT_Byte)*size_Channel_Byte+1])<<8)+
          convert_byte(data_packet[( ss + size_STAT_Byte )*size_Channel_Byte+2]);
          if(eeg_datas[ss]>=0x800000)
          {
            eeg_datas[ss]=-(((~eeg_datas[ss])&0x7fffff)+1);
          }
          
          eeg_datas_read[ss]=(float(eeg_datas[ss])*4.5*2/16)/(2^24);;
          print("EEGData"+ss+": "+(eeg_datas_read[ss])+" ");
        }
          if(EegReceiverConfig.offset_posi < 500){
            for(int i = 0; i < EegReceiverConfig.nchan; i++)
            {
              EegReceiverConfig.channel_baseline[i] +=  eeg_datas_read[i]/500;
            }
            EegReceiverConfig.offset_posi++;
            
          }
          else{
            // for(int i = 0; i< EegReceiverConfig.nchan; i++)println("EEGbaseline"+""+i+""+EegReceiverConfig.channel_baseline[i]);

            for(int i = 0; i < EegReceiverConfig.nchan; i++){
                      eeg_datas_read[i] -= EegReceiverConfig.channel_baseline[i];
                      eeg_datas_read[i] = HighPassFilter[i].runfilter(LowPassFilter[i].runfilter(NotchFilter[i].runfilter(eeg_datas_read[i])));
                      //print("EEGDataFloat"+i+": "+(eeg_datas_read[i])+" ");

            }
            
            if(EegReceiverConfig.entering_ploting==false){

                for(int i = 0; i < EegReceiverConfig.nchan; i++) EegReceiverConfig.channel_baseline[i] = - EegReceiverConfig.channel_baseline[i];
                delay(50);
                if(test_hardware_mode)EegReceiverConfig.myPort.write('T');
                else EegReceiverConfig.myPort.write('S');
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
