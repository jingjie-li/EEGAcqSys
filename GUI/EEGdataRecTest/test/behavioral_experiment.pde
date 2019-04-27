
// PWindow win;
// boolean pause_calibration_phase = false;
// public void settings() {
//   size(320, 240);  

// }

// void setup() { 
//   surface.setLocation(20,20);
//   win = new PWindow();
//   //  println(displayHeight);
//   //println(displayWidth);
//   //println(width);
//   //println(height);
// }

// void draw() {
//   background(255, 0, 0);
//   fill(255);
//   //rect(10, 10, frameCount, 10);
//   textSize(100);
//   text("R",100,100);
//   line(100,100,200,200);

// }

// void mousePressed() {
//   println("mousePressed in primary window");
//   if(win == null) win = new PWindow();
// } 

// class PWindow extends PApplet {
//     int size_rect  = 150;
//     int size_character = 150;
//     int size_cross = 150;

//   PWindow() {
//     super();

//     PApplet.runSketch(new String[] {this.getClass().getSimpleName()}, this);
//   }

//   void settings() {
//   fullScreen();
//   //println(size_rect);
//   //println(displayHeight);
//   //println(width);
//   //println(height);
//   //size(1000,1000); 
//   }

//   void setup() {
//     background(0);
//     start_time_count = millis();

//   }
// boolean interval_turn = true;
// int time_mill = millis();
// boolean start_calibration = false;
// int start_time_count = 0; 
// int count_down_time_count = 0;
// int count_down_time_second = 3;
// int count_down_font_size = 400;
// String[] count_down_vis = {"1","2","3"};
// int a;
// void draw() {
//      background(0);
//      if(!start_calibration)
//      {
//        rectMode(CORNER);
//        if(count_down_time_second > 0)
//        {
//          a = (millis() - start_time_count);
//          if ( a >= 1999){
//           start_time_count = millis();
//           count_down_time_second = count_down_time_second - 1;
//          }
//          else{
//            int temp_size = (int)(count_down_font_size - ((a) * count_down_font_size)/2000);
//            textSize(temp_size);
//            //textSize(count_down_font_size);
//            text(count_down_vis[count_down_time_second - 1], (int)(displayWidth/2) - (int)(temp_size/4), (int)(displayHeight/2)+(int)(temp_size/4));
//          }
         
//        }
//        else
//        {
//          start_calibration = !start_calibration;
//          time_mill = millis();
//          return;
//        }
//      }
       
//      else
//      {if (pause_calibration_phase)
//      {
//       textSize(size_character);
//       text("PAUSE",(int)(displayWidth/2) - (int)(size_character/12)*20, (int)(displayHeight/2)+(int)(size_character/4));
      
//      ;}
//      else
//      {
//        if (interval_turn)
//      {
//        draw_interval();
//      if (millis() - time_mill >= 2000){
//       time_mill = millis();
//       interval_turn = false;

//        }  
//      }
//      else
//      {
//        trial_draw_character('l');
//        if(millis() - time_mill >= 2000){
//          interval_turn = true; 
//          time_mill = millis();
//        }
//      }
//    }
//      }
     
     

//   }

  

//   void mousePressed() {
//     pause_calibration_phase = !pause_calibration_phase;
//   }
  
//   void exit()
//   {
//     dispose();
//     win = null;
//   }
//   void draw_interval()
// {
//   pushStyle();
//   stroke(color(#C4C4C4));
//   strokeWeight(5);

//   line((int)(displayWidth/2),(int)(displayHeight/2) - int(size_cross/2),(int)(displayWidth/2),(int)(displayHeight/2) + int(size_cross/2));
//   line( (int)(displayWidth/2) - int(size_cross/2), (int)(displayHeight/2),(int)(displayWidth/2) + int(size_cross/2),(int)(displayHeight/2));

//   popStyle();
// }
// void trial_draw_rect(char class_n){
//   fill(color(#C4C4C4));
//   switch(class_n){
//   case 'l':
//       rect(0,(int)(displayHeight/2) - (int)(size_rect/2), size_rect, size_rect);
//   case 'r':
//       rect(displayWidth,(int)(displayHeight/2) - (int)(size_rect/2), size_rect, size_rect);
//   case 'f':
//       rect((int)(displayWidth/2), displayHeight, size_rect, size_rect);
//   };
// }

// void trial_draw_character(char class_n)
// {
//   pushStyle();
//   fill(color(#C4C4C4));
//   textSize(size_character);
//   rectMode(CORNER);
//   switch(class_n){
//     case 'l':
//          text("L",(int)(displayWidth/2) - (int)(size_character/4), (int)(displayHeight/2)+(int)(size_character/4));
//          break;
//     case 'r':
//          text("R",(int)(displayWidth/2) - (int)(size_character/4), (int)(displayHeight/2)+(int)(size_character/4));
//          break;
//     case 'f':
//          text("F",(int)(displayWidth/2) - (int)(size_character/4), (int)(displayHeight/2)+(int)(size_character/4));
//          break;
//   }
  
  
//     popStyle();
// }
// }