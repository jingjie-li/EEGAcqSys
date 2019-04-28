import controlP5.*;
import java.util.*;
import g4p_controls.*; 

boolean test_mode = true;

ControlP5 cp5;
ControlP5 cp5_2;

ScrollableList choose_system_mode;
ScrollableList choose_data_source;
ScrollableList add_plot;
Button start_button;

int System_Mode_Index = -1;
String[] System_Mode_Name = {"SIGNAL_VISUALIZATION","BEHAVIORAL_TRAINING","TRAINING_COLLECTED_DATA","CONTROL_CURSOR"};
int SIGNAL_VISUALIZATION = 0; 
int BEHAVIORAL_TRAINING = 1;
int TRAINING_COLLECTED_DATA = 2; 
int CONTROL_CURSOR = 3; 

int Data_Source_Index = -1;
String[] Data_Source_Name = {"SYNTHETIC_SIGNAL","SUPER_DENTRITE","PLAY_BACK"};
int SYNTHETIC_SIGNAL = 0;
int SUPER_DENTRITE = 1;
int PLAY_BACK = 2;


//window_config
int control_panel_pos_x;
  int control_panel_pos_y; 
  int control_panel_width;
  int control_panel_height;
  int window_height;
String[] Plot_Name = {"Timeseries", "FFT Plot","Head Plot"};


//
TimeSeriesConfig TimeSeriesConfig = new TimeSeriesConfig();
PFont pfont;
ControlFont font = new ControlFont(pfont,20);
boolean source_connected = false;

void settings(){
  size(1183,900);
  
}

void setup(){
     surface.setLocation(control_panel_pos_x, control_panel_pos_y);

  frameRate(40);
  //surface.setAlwaysOnTop(true); //force the screen to stay on the top!
  control_panel_pos_x = 75;
  control_panel_pos_y = 44; 
  control_panel_width = 1183;
  control_panel_height = 63;
  window_height = 837;
 
  initiate_control_panel();
  initiate_timesieres_subwindow(this, cp5);
  // lines = loadStrings("Users/liusitan/Downloads/ADS1299TEST(1).txt");
  if(!test_mode){
    thread("read_data_thread");
      setup_serial_port();
  }
  //thread("channel_bar_udpate");


}
String[] lines; //<>//
void write_date()
{

}

void draw(){
  

	background(240); //<>//
  pushStyle();
  
  fill(color(#57068C));
  rect(0,0,control_panel_width,control_panel_height);
  fill(color(#C4C4C4));
  rect(0, control_panel_height, control_panel_width, window_height);
  popStyle();
  rectMode(CORNER);
  stroke(color(#000000));
  fill(color(#ffffff));
  rect(0,control_panel_height + window_height - 28, control_panel_width, 14);
  rect(0,control_panel_height + window_height - 14, control_panel_width, 14);
  fill(0);

  text("System Mode:" + ((System_Mode_Index >= 0 )? System_Mode_Name[System_Mode_Index] : "SYSTEM_CLOSED")
    + "Data Source:" + ((Data_Source_Index >= 0 )? Data_Source_Name[Data_Source_Index] : "NOT_SELECTED"),0 , control_panel_height+window_height - 14);
  fill(0);
  text("Connection State:" + (source_connected?"Success":"Failed"),0,control_panel_height + window_height);

  if ((System_Mode_Index == BEHAVIORAL_TRAINING) && (Data_Source_Index >= 0 )){
      start_button.setVisible(true);
    }
    // light up the Datea_source scorllableilst
    if ((System_Mode_Index >= 0) && (System_Mode_Index < 2) ){
      choose_data_source.setVisible(true);
    }
  if (System_Mode_Index >= 0)
  
      {
       
        for (int i = 0; i < TimeSeriesConfig.num_data_channel; i++)
      {
    TimeSeriesConfig.channel_vis[i].update();
    TimeSeriesConfig.channel_vis[i].draw_();
        }
  

  }

  
  cp5_2.draw();
  cp5.draw();
  //TimeSeriesConfig.channel_vis[0].get_plot().defaultDraw();
  
}



void initiate_control_panel(){
pushStyle();
  fill(color(#57068C));
  strokeWeight(4);
  line(665,509,665,362+509);
  line(control_panel_pos_x,81,control_panel_pos_x+control_panel_width,81);
  popStyle();
  pfont = createFont("Arial",20,true); // use true/false for smooth/no-smooth
  font = new ControlFont(pfont,20);
  
  
  font.setSize(12);
  cp5 = new ControlP5(this);
  cp5_2 = new ControlP5(this);
  cp5.setAutoDraw(false);
  cp5_2.setAutoDraw(false);
  choose_system_mode = cp5.addScrollableList("System_Mode")
                          .setPosition(14, 11)
                          .setSize(185,164)
                         .setBarHeight(41)
                         .setItemHeight(41)
                         //.setColor(color(#57068C))
                         .addItems(System_Mode_Name)
                         .addListener(new choose_system_mode_ControlListener())
                         .setType(ControlP5.LIST).setFont(font).close();
  

  choose_data_source = cp5.addScrollableList("Signal_Source").setPosition(216, 11)
     .setSize(139, 123)
     .setBarHeight(41)
     .setItemHeight(41)
     //.setColor(#57068C)
     .addItems(Data_Source_Name)
     .addListener(new choose_data_source_ControlListener())
     .setType(ControlP5.LIST)
     .setFont(font)
     .close()
     .setVisible(false);
  
  font.setSize(20);
  choose_system_mode.getCaptionLabel().setText("System Mode").setFont(font).setLineHeight(200);
  choose_system_mode.setColorBackground(color(#57068C));
  choose_data_source.getCaptionLabel().setText("Signal Source").setFont(font).setLineHeight(200);
  choose_data_source.setColorBackground(color(#57068C));
  start_button = cp5.addButton("Start")
                  .setPosition(1119 - 73, 11)
                  .setSize(91,41)
                  .addListener(new start_button_ControlListener())
                  .setView(new start_button_view()).setVisible(false);
  font.setSize(8);
}
void create_timeseries_window(){
  
  println("timeseries_window created");

}

void create_FFT_window(){
  println("FFT_window created");
}
void create_Head_Plot(){
  println("head plot created");
}
