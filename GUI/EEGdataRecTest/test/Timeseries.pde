
import grafica.*;
import controlP5.*;



static class TimeSeriesConfig {
	public static int num_data_channel;
	public static GPlot plot;
	public static GPointsArray points;
	public static int nPoints; //
	public static int vert_scale;
	public static int window_length;
	public static ChannelBar[] channel_vis; // visualize each channel Plot
	//channel Bar has unified style
	public static int channel_bar_height; 
	public static int channel_bar_width;
	public static int first_channel_bar_pos_x;
	public static int first_channel_bar_pos_y;
	//sampling  
	public static int sampling_rate = EegReceiverConfig.getSampleRateSafe();
	
	public static int buff_length;
	public static float[][] timeseries_buff;
	static int[] vert_scale_list ={50,100,200,400,1000,10000};
	static int[] window_length_list = {2000,5000,100000};
	public static int num_seconds;
  public static ScrollableList vert_scale_control;
  public static ScrollableList window_length_control;

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

void channel_bar_udpate(){
  while(true){
    for(int i = 0 ; i < num_chan; i ++){
        
        TimeSeriesConfig.channel_vis[i].update();
        }
    delay(EegReceiverConfig.UPDATE_MILLIS - 10);
    //delay(1000);
  }
}

color[] channelColors = {
  color(129, 129, 129),
  color(124, 75, 141),
  color(54, 87, 158),
  color(49, 113, 89),
  color(221, 178, 13),
  color(253, 94, 52),
  color(224, 56, 45),
  color(162, 82, 49)
};
color bgColor = color(1, 18, 41);


class ChannelBar{


  int channel_number; //duh
  int pos_x, pos_y, channelbar_width, channelbar_height;

  //structure of the channel Bar
  int edge_button_length ;
  int button_plotleft_length ;
  int plotright_end_length ;
  

  boolean isOn; //true means data is streaming and channel is active on hardware ... this will send message to OpenBCI Hardware
  Button onOffButton;
  int on_off_diameter;

  GPlot plot; //the actual grafica-based GPlot that will be rendering the Time Series trace
  public GPointsArray channelPoints;
  int nPoints;
  float timeBetweenPoints;

  color channelColor; //color of plot trace

  boolean isAutoscale; //when isAutoscale equals true, the y-axis of each channelBar will automatically update to scale to the largest visible amplitude
  int autoScaleYLim = 0;

  TextBox voltageValue;
  TextBox impValue;

  boolean drawVoltageValue;
  boolean drawImpValue;

  float[] data_buff;
  PApplet parent;
  TimeSeriesConfig data;
  ChannelBar(PApplet _parent, int _channel_number){ // channel number, x/y location, height, width
    
  	// location variable
  	channel_number = _channel_number;
    pos_x = TimeSeriesConfig.first_channel_bar_pos_x;
    pos_y = TimeSeriesConfig.first_channel_bar_pos_y + (channel_number-1) * TimeSeriesConfig.channel_bar_height;
    channelbar_width = TimeSeriesConfig.channel_bar_width;
    channelbar_height = TimeSeriesConfig.channel_bar_height;
    //structure of the channel Bar
    edge_button_length = 1;
    button_plotleft_length = 1;
    plotright_end_length = 1;
    
    on_off_diameter = int(channelbar_height/2);
    
    plot = new GPlot(_parent);

    parent = _parent;

    

   //  .setColorNotPressed(channelColors[(channel_number-1)%8]) //Set channel button background colors
  	// .textColorNotActive = color(255) //Set channel button text to white
   //  .hasStroke(false);
    
    


    // generateChannelBar(_x,_y,_w,_h);

    edge_button_length = round(channelbar_width*0.005);
    button_plotleft_length = round(channelbar_width*0.01);
    plotright_end_length = round(channelbar_width*0.005);
    plot.setPos(pos_x +edge_button_length+button_plotleft_length+ on_off_diameter, pos_y);
    plot.setDim(channelbar_width- edge_button_length - button_plotleft_length - on_off_diameter - plotright_end_length , channelbar_height);
    onOffButton = cp5_2.addButton(str(channel_number))
    				.setPosition(pos_x + edge_button_length, pos_y + (int)(channelbar_height/2))
    				.setSize(on_off_diameter,on_off_diameter);
    // onOffButton = new Button(5,6,7,8,"test");
    
    plot.setMar(0f, 0f, 0f, 0f);
    plot.setLineColor((int)channelColors[(channel_number-1)]);
    plot.setXLim(-5,0);
    plot.setYLim(-10,10);
    plot.setPointSize(2);
    plot.setPointColor(0);
    // magic number resolve later
    if(channel_number == 8){
      plot.getXAxis().setAxisLabelText("Time (s)");
    }

    // plot.setBgColor(color(31,69,110));

    nPoints = EegReceiverConfig.getSampleRateSafe() * (int)(TimeSeriesConfig.window_length_list[TimeSeriesConfig.window_length]/1000);// false
    channelPoints = new GPointsArray(nPoints);
    timeBetweenPoints = (float)TimeSeriesConfig.num_seconds / (float)nPoints;

    for (int i = 0; i < nPoints; i++) {
      float time = -(float)TimeSeriesConfig.num_seconds + (float)i*timeBetweenPoints;
      // float time = (-float(num_seconds))*(float(i)/float(nPoints));
      // float filt_uV_value = TimeSeriesConfigBuffY_filtY_uV[channel_number-1][TimeSeriesConfigBuffY_filtY_uV.length-nPoints];
      float filt_uV_value = 0.0; //0.0 for all points to start
      GPoint tempPoint = new GPoint(time, filt_uV_value);
      channelPoints.set(i, tempPoint);
    }

    plot.setPoints(channelPoints); //set the plot with 0.0 for all channelPoints to start

    voltageValue = new TextBox("", pos_x + channelbar_width - plotright_end_length, pos_y + channelbar_height);
    voltageValue.textColor = color(bgColor);
    voltageValue.alignH = RIGHT;
    // voltageValue.alignV = TOP;
    voltageValue.drawBackground = true;
    voltageValue.backgroundColor = color(255,255,255,125);

    // impValue = new TextBox("", x + 36 + 4 + impButton_diameter + 2, y + h);
    // impValue.textColor = color(bgColor);
    // impValue.alignH = LEFT;
    // // impValue.alignV = TOP;
    // impValue.drawBackground = true;
    // impValue.backgroundColor = color(255,255,255,125);

    drawVoltageValue = true;
    // drawImpValue = false;

  }
 void generateChannelBar(int _x,int _y, int _w, int _h){

    pos_x = _x;
    pos_y = _y;
    channelbar_width = _w;
    channelbar_height = _h;
    on_off_diameter = int(channelbar_height/2);

      //structure of the channel Bar
    edge_button_length = round(channelbar_width*0.005);
    button_plotleft_length = round(channelbar_width*0.01);
    plotright_end_length = round(channelbar_width*0.005);
    plot.setPos(pos_x +edge_button_length+button_plotleft_length+ on_off_diameter, pos_y);
    plot.setDim(channelbar_width - edge_button_length - button_plotleft_length - on_off_diameter - plotright_end_length , channelbar_height);
    onOffButton = cp5_2.addButton(str(channel_number))
    				.setPosition(pos_x + edge_button_length, pos_y + (int)(channelbar_height/2))
    				.setSize(on_off_diameter,on_off_diameter);
    // onOffButton.setDim(on_off_diameter,on_off_diameter);

}
void update(){

    //update the voltage value text string
    String text_format; 
    float val; //<>//

    //update the voltage values
    //val = TimeSeriesConfigProcessing.TimeSeriesConfig_std_uV[channel_number-1]

    // val = EegReceiverConfig.eeg_TimeSeriesConfig_buff[channel_number][EegReceiverConfig.eeg_TimeSeriesConfig_buff[channel_number].length - 1];
    // voltageValue.string = String.format(gettext_format(val),val) + " uVrms";



    // if (is_railed != null) {
    //   if (is_railed[channel_number-1].is_railed == true) {
    //     voltageValue.string = "RAILED";
    //   } else if (is_railed[channel_number-1].is_railed_warn == true) {
    //     voltageValue.string = "NEAR RAILED - " + String.format(gettext_format(val),val) + " uVrms";
    //   }
    // }

    //update the impedance values
    // val = TimeSeriesConfig_elec_imp_ohm[channel_number-1]/1000;
    // impValue.string = String.format(gettext_format(val),val) + " kOhm";
    // if (is_railed != null) {
    //   if (is_railed[channel_number-1].is_railed == true) {
    //     impValue.string = "RAILED";
    //   }
    // }

    // update TimeSeriesConfig in plot
    updatePlotPoints();
  }
  public void reconfig_plot(int _num_seconds, int y_scale){;};

  private String gettext_format(float val) {
    String text_format;
      if (val > 100.0f) {
        text_format = "%.0f";
      } else if (val > 10.0f) {
        text_format = "%.1f";
      } else {
        text_format = "%.2f";
      }
      return text_format;
  }
  

  void updatePlotPoints(){
    // update data in plot
    //printArray(EegReceiverConfig.eeg_data_buff_copy[channel_number - 1][EegReceiverConfig.eeg_data_buff_copy[channel_number - 1].length - nPoints]);
    // timing 1s cool just 1ms //<>//
    //setting the points   
    //GPointsArray channelPoints =  new GPointsArray(nPoints);
    nPoints = EegReceiverConfig.getSampleRateSafe() * (int)(TimeSeriesConfig.window_length_list[TimeSeriesConfig.window_length]/1000);// false
    TimeSeriesConfig.num_seconds = TimeSeriesConfig.window_length_list[int(TimeSeriesConfig.window_length_control.getValue())];
    for (int i = 0; i < nPoints; i++) 
    //for (int i = 0 ;i < nPoints; i++)  
    {          
      
        float time = -(float)TimeSeriesConfig.num_seconds + (float)(i)*timeBetweenPoints;
        float filt_uV_value;
       //  //float time = -(float)num_seconds + (float)(i)*timeBetweenPoints;
       // //float time = -(float)TimeSeriesConfig.num_seconds + (float)i*timeBetweenPoints;
       switch(int(choose_data_source.getValue()))
       {

        case 0: 
                source_connected = true;
                filt_uV_value = random(int(TimeSeriesConfig.vert_scale_list[0]));// keep random scale constant, so you can tell the difference between difference vert scale
                
                break;

        case 1:
                filt_uV_value = EegReceiverConfig.eeg_data_buff_copy[channel_number - 1][i + EegReceiverConfig.eeg_data_buff_copy[channel_number-1].length - nPoints];
                eeGDisplayCalibration[channel_number-1].addEEGData(filt_uV_value);
                float baseline = eeGDisplayCalibration[channel_number-1].compute(1,200);
                filt_uV_value = abs((-(filt_uV_value)+baseline));//resize 0x1FFFFF

                break;
        
        default:
                filt_uV_value=0;
                println("wrong_resources");

       }
      //if( channel_number == 4){
      //        print("un_filtered_valie:");
      //        println(filt_uV_value);
      //        print("baseline:");
      //        println(EegReceiverConfig.channel_baseline[6]);
      //}
      GPoint tempPoint = new GPoint(time, filt_uV_value);//filt_uV_value);
      channelPoints.set(i, tempPoint);
    }
    
    

     //reset the plot with updated channelPoints
    
  
  plot.setPoints(channelPoints);
  }

  void draw_(){
    pushStyle();
    //draw channel holder background
    stroke(31,69,110, 50);
    fill(255);
    rect(pos_x,pos_y,channelbar_width,channelbar_height);

    //draw plot
    stroke(31,69,110, 50);
    fill(color(125,30,12,30));

    //rect(pos_x + edge_button_length + button_plotleft_length + on_off_diameter, pos_y, channelbar_width - edge_button_length - button_plotleft_length - on_off_diameter, channelbar_height);
    
    plot.beginDraw();
    //plot.drawBox(); // we won't draw this eventually ...
    plot.setXLim(-TimeSeriesConfig.num_seconds,0);
     plot.setYLim(-TimeSeriesConfig.vert_scale_list[int(TimeSeriesConfig.vert_scale_control.getValue())],TimeSeriesConfig.vert_scale_list[int(TimeSeriesConfig.vert_scale_control.getValue())]);
    plot.drawGridLines(0);
    plot.drawLines();
    
    // plot.drawPoints();
    // plot.drawYAxis();
    //if(channel_number == TimeSeriesConfig.num_data_channel){ //only draw the x axis label on the bottom channel bar
    //  plot.drawXAxis();
    //  plot.getXAxis().draw();
    //}
    
    plot.endDraw();
    
    //if(drawVoltageValue){
    //  voltageValue.draw();
    //}
    // update_data_buff(data_buff);
    popStyle();
  }



  
  




  public GPointsArray get_channelPoints()
  {
    return channelPoints;
  }
  void setDrawImp(boolean _trueFalse){
    drawImpValue = _trueFalse;
  }

  // int nPointsBasedOnDataSource(){
  //   return num_seconds * (int)getSampleRateSafe();
  // }

}




class TextBox {
  public int x, y;
  public color textColor;
  public color backgroundColor;
  private PFont font;
  private int fontSize;
  public String string;
  public boolean drawBackground;
  public int backgroundEdge_pixels;
  public int alignH,alignV;
  public PFont p5 = createFont(PFont.list()[1], 32);
//  textBox(String s,int x1,int y1) {
//    textBox(s,x1,y1,0);
//  }
  TextBox(String s, int x1, int y1) {
    string = s; x = x1; y = y1;
    backgroundColor = color(255,255,255);
    textColor = color(0,0,0);
    fontSize = 12;
    font = p5;
    backgroundEdge_pixels = 1;
    drawBackground = false;
    alignH = LEFT;
    alignV = BOTTOM;
  }
  public void setFontSize(int size) {
    fontSize = size;
    font = p5;
  }
  public void draw() {
    //define text
    noStroke();
    textFont(font);

    //draw the box behind the text
    if (drawBackground == true) {
      int w = int(round(textWidth(string)));
      int xbox = x - backgroundEdge_pixels;
      switch (alignH) {
        case LEFT:
          xbox = x - backgroundEdge_pixels;
          break;
        case RIGHT:
          xbox = x - w - backgroundEdge_pixels;
          break;
        case CENTER:
          xbox = x - int(round(w/2.0)) - backgroundEdge_pixels;
          break;
      }
      w = w + 2*backgroundEdge_pixels;
      int h = int(textAscent())+2 * backgroundEdge_pixels;
      int ybox = y - int(round(textAscent())) - backgroundEdge_pixels -2;
      fill(backgroundColor);
      rect(xbox,ybox,w,h);
    }
    //draw the text itself
    fill(textColor);
    textAlign(alignH,alignV);
    text(string,x,y);
    strokeWeight(1);
  }
};
public ComputeBaseline[] eeGDisplayCalibration;
void initiate_timesieres_subwindow(PApplet p, ControlP5 cp5 ){
  
  print("initiate timeseries window");
  
  //setup the controllers
  TimeSeriesConfig.vert_scale_control = cp5.addScrollableList("Vert_Scale")
  .setPosition(1062 - control_panel_pos_x,114 - control_panel_pos_y)
  .setSize(81,115)
  .setBarHeight(23)
  .setItemHeight(23)
  .addItems(Arrays.asList("50 uv","100 uv","200 uv","400 uv","1000 uv","10000"))
  .setOpen(false)
  .setType(ControlP5.LIST)
  .setFont(font)
  .setValue(0);

   TimeSeriesConfig.window_length_control = cp5.addScrollableList("Window")
  .setPosition(1166 -  control_panel_pos_x,114 - control_panel_pos_y)
  .setSize(81,69)
  .setBarHeight(23)
  .setItemHeight(23)
  .addItems(Arrays.asList("2s","5s", "10s"))
  .setOpen(false)
  .setValue(1)
  .setType(ControlP5.LIST).setFont(font);


  TimeSeriesConfig.channel_bar_width = 1139;
  TimeSeriesConfig.channel_bar_height = 50;
  TimeSeriesConfig.first_channel_bar_pos_x = 106 - control_panel_pos_x;
  TimeSeriesConfig.first_channel_bar_pos_y = 144 -  control_panel_pos_y;
  TimeSeriesConfig.num_data_channel = 8;

  TimeSeriesConfig.sampling_rate = EegReceiverConfig.getSampleRateSafe();
  TimeSeriesConfig.buff_length = TimeSeriesConfig.sampling_rate * TimeSeriesConfig.num_seconds;
  TimeSeriesConfig.vert_scale = 0;
  TimeSeriesConfig.window_length = 1;
  TimeSeriesConfig.timeseries_buff = new float[TimeSeriesConfig.num_data_channel][TimeSeriesConfig.buff_length];
  TimeSeriesConfig.channel_vis = new ChannelBar[TimeSeriesConfig.num_data_channel];
  TimeSeriesConfig.num_seconds = TimeSeriesConfig.window_length_list[int(TimeSeriesConfig.window_length_control.getValue())];
  for (int i  = 0; i < TimeSeriesConfig.num_data_channel; i++)
    for (int j = 0; j < TimeSeriesConfig.buff_length; j ++)
      TimeSeriesConfig.timeseries_buff[i][j] = random(10);
  eeGDisplayCalibration = new ComputeBaseline[8];
  for (int i =0; i < 8;i++)
  {
    eeGDisplayCalibration[i] = new ComputeBaseline();
  }
  intialize_channel_bars(p);


}



void intialize_channel_bars(PApplet p){
  
  for (int i = 0; i < TimeSeriesConfig.num_data_channel; i++){
    TimeSeriesConfig.channel_vis[i] = new ChannelBar(p, i+1);
}
}
