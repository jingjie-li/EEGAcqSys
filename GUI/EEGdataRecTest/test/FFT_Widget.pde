import ddf.minim.*;
import ddf.minim.analysis.*;
 boolean isFFTFiltered = true; //yes by default ... this is used in dataProcessing.pde to determine which uV array feeds the FFT calculation

 static class FFTConfig{
  //to see all core variables/methods of the Widget class, refer to Widget.pde

   //put your custom variables here...
   static GPlot fft_plot; //create an fft plot for each active channel
   static FFT[] fftBuff;    //from the minim library
   static GPointsArray[] fft_points;  //create an array of points for each channel of data (4, 8, or 16)
   static int[] lineColor;

   static int[] xLimOptions = {20, 40, 60, 100, 120, 250, 500, 800};
   static int[] yLimOptions = {10, 50, 100, 1000};

   static int xLim = xLimOptions[2];  //maximum value of x axis ... in this case 20 Hz, 40 Hz, 60 Hz, 120 Hz
   static int xMax = xLimOptions[xLimOptions.length-1];   //maximum possible frequency in FFT
   static int FFT_indexLim;   // maxim value of FFT index
   static int yLim = yLimOptions[2];  //maximum value of y axis ... 100 uV

   //Used to save settings
   static int fftMaxFrqSave = xLim;
   static int fftMaxuVSave = yLim;
   static ScrollableList max_freq_list;
   static ScrollableList vert_scale_list;
   static ScrollableList log_lin_list;
   static ScrollableList smoothing_list;
   static ScrollableList fft_filter_list;
   static float fs_Hz;
   static int nfft;

 }
 void initializeFFTConfig(PApplet p){
  int[] lineColor = {
     (int)color(129, 129, 129),
     (int)color(124, 75, 141),
     (int)color(54, 87, 158),
     (int)color(49, 113, 89),
     (int)color(221, 178, 13),
     (int)color(253, 94, 52),
     (int)color(224, 56, 45),
     (int)color(162, 82, 49),

     (int)color(129, 129, 129),
     (int)color(221, 178, 13),
     (int)color(253, 94, 52),
     (int)color(224, 56, 45),
     (int)color(162, 82, 49)
   };
     FFTConfig.lineColor = lineColor;
     FFTConfig.FFT_indexLim = int(1.0*FFTConfig.xMax*(getNfftSafe()/EegReceiverConfig.getSampleRateSafe()));
     FFTConfig.fft_points = new GPointsArray[num_chan];
     FFTConfig.fft_plot =  new GPlot(p, 0, 552-control_panel_pos_x, 578, 319);
     FFTConfig.fftBuff = new FFT[num_chan];
     FFTConfig.fs_Hz = EegReceiverConfig.getSampleRateSafe();
     FFTConfig.nfft = getNfftSafe();
     for(int i = 0; i < num_chan; i++){
        FFTConfig.fftBuff[i] = new FFT(FFTConfig.nfft, FFTConfig.fs_Hz);
   }
 }

 void initialize_FFT_plot(PApplet _parent){
      //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)
    
     //FFT plot settings,
     // fftMaxFrqSave = 2;
     // fftMaxuVSave = 2;
     // fftLogLinSave = 0;
     // fftSmoothingSave = 3;
     // fftFilterSave = 0;

     //This is the protocol for setting up dropdowns.
     //Note that these 3 dropdowns correspond to the 3 global functions below
     //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
     initializeFFTConfig(this);
     pushStyle();
     textMode(CENTER);
     text("MaxFreq",78 - control_panel_pos_x, 522- control_panel_pos_y);
     text("Max uv",197 - control_panel_pos_x, 522- control_panel_pos_y);
     text("Log/Lin",303 - control_panel_pos_x, 522- control_panel_pos_y);
     text("Smooth",415 - control_panel_pos_x, 522- control_panel_pos_y);
     text("Filters",529 - control_panel_pos_x, 522- control_panel_pos_y);
     popStyle();
     //FFTConfig.max_freq_list = cp5_2
     //.addScrollableList("MaxFreq")
     //.setPosition(129 - control_panel_pos_x, 519 - control_panel_pos_y).setSize(57,22*max_freq_list.length)
     //.setBarHeight(22)
     //.setItemHeight(22)
     //.addItems(Arrays.asList(fftMaxFrqArray))
     //.setOpen(false)
     //.setValue(2).setFont(font);
     //FFTConfig.max_freq_list.getCaptionLabel().setText("Max Freq");

     //FFTConfig.vert_scale_list = cp5_2
     //.addScrollableList("VertScale")
     //.setPosition(245 - control_panel_pos_x, 519 - control_panel_pos_y)
     //.setSize(57,22*max_freq_list.length).setBarHeight(22)
     //.setItemHeight(22)
     //.addItems(Arrays.asList(fftVertScaleArray))
     //.setOpen(false)
     //.setValue(2).setFont(font);
     //FFTConfig.vert_scale_list.getCaptionLabel().setText("Vert Scale");

     //FFTConfig.log_lin_list = cp5_2.addScrollableList("LogLin").setPosition(356 - control_panel_pos_x, 519 - control_panel_pos_y).setSize(57,22*vert_scale_list.length).setBarHeight(22)
     //.setItemHeight(22)
     //.addItems(Arrays.asList(fftLogLinArray))
     //.setOpen(false)
     //.setValue(0).setFont(font);
     //FFTConfig.log_lin_list.getCaptionLabel().setText("Log Lin");

     //FFTConfig.smoothing_list = cp5_2.addScrollableList("Smoothing").setPosition(470 - control_panel_pos_x, 519 - control_panel_pos_y).setSize(57,22*smoothing_list.length).setBarHeight(22)
     //.setItemHeight(22)
     //.addItems(rrays.asList(fftSmoothingArray))
     //.setOpen(false)
     //.setValue(3).setFont(font);
     //FFTConfig.smoothing_list.getCaptionLabel().setText("Smoothing");

     //FFTConfig.fft_filter_list = cp5_2.addScrollableList("fft_filter").setPosition(574 - control_panel_pos_x, 519 - control_panel_pos_y).setSize(57,22*fft_filter_list.length).setBarHeight(22)
     //.setItemHeight(22)
     //.addItems(Arrays.asList(fftFilterArray))
     //.setOpen(false)
     //.setValue(0).setFont(font);
     //FFTConfig.fft_filter_list.getCaptionLabel().setText("fft fliter");

     
     // println("fft_points.length: " + fft_points.length);
     //setup GPlot for FFT
      //based on container dimensions
     FFTConfig.fft_plot.getXAxis().setAxisLabelText("Frequency (Hz)");
     FFTConfig.fft_plot.getYAxis().setAxisLabelText("Amplitude (uV)");
     //fft_plot.setMar(50,50,50,50); //{ bot=60, left=70, top=40, right=30 } by default
     FFTConfig.fft_plot.setMar(60, 70, 40, 30); //{ bot=60, left=70, top=40, right=30 } by default
     FFTConfig.fft_plot.setLogScale("y");

     FFTConfig.fft_plot.setYLim(0.1, FFTConfig.yLim);
     int _nTicks = int(FFTConfig.yLim/10 - 1); //number of axis subdivisions
     FFTConfig.fft_plot.getYAxis().setNTicks(_nTicks);  //sets the number of axis divisions...
     FFTConfig.fft_plot.setXLim(0.1, FFTConfig.xLim);
     FFTConfig.fft_plot.getYAxis().setDrawTickLabels(true);
     FFTConfig.fft_plot.setPointSize(2);
     FFTConfig.fft_plot.setPointColor(0);

     //setup points of fft point arrays
     for (int i = 0; i < FFTConfig.fft_points.length; i++) {
       FFTConfig.fft_points[i] = new GPointsArray(FFTConfig.FFT_indexLim);
     }

     //fill fft point arrays
     for (int i = 0; i < FFTConfig.fft_points.length; i++) { //loop through each channel
       for (int j = 0; j < FFTConfig.FFT_indexLim; j++) {
         //GPoint temp = new GPoint(i, 15*noise(0.1*i));
         //println(i + " " + j);
         GPoint temp = new GPoint(j, 0);
         FFTConfig.fft_points[i].set(j, temp);
       }
     }
     //map fft point arrays to fft plots
   }

 void update(){

   //put your code here...
   //update the points of the FFT channel arrays
   //update fft point arrays
   // println("LENGTH = " + fft_points.length);
   // println("LENGTH = " + fftBuff.length);
   // println("LENGTH = " + FFT_indexLim);
   for (int i = 0; i < FFTConfig.fft_points.length; i++) {
     for (int j = 0; j < FFTConfig.FFT_indexLim + 2; j++) {  //loop through frequency domain data, and store into points array
       //GPoint powerAtBin = new GPoint(j, 15*random(0.1*j));
       GPoint powerAtBin;

       // println("i = " + i);
       // float a = getSampleRateSafe();
       // float aa = fftBuff[i].getBand(j);
       // float b = fftBuff[i].getBand(j);
       // float c = Nfft;

       //println("Sample rate: "+ sr + " -- Nfft: " + nfft);
       powerAtBin = new GPoint((1.0* FFTConfig.fs_Hz/ FFTConfig.nfft)*j, FFTConfig.fftBuff[i].getBand(j));
       FFTConfig.fft_points[i].set(j, powerAtBin);
       // GPoint powerAtBin = new GPoint((1.0*getSampleRateSafe()/Nfft)*j, fftBuff[i].getBand(j));

       //println("=========================================");
       //println(j);
       //println(fftBuff[i].getBand(j) + " :: " + fft_points[i].getX(j) + " :: " + fft_points[i].getY(j));
       //println("=========================================");
     }
   }

   //remap fft point arrays to fft plots


 }

 void FFT_draw(){

   //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
   pushStyle();

   //draw FFT Graph w/ all plots
   noStroke();
   FFTConfig.fft_plot.beginDraw();
   FFTConfig.fft_plot.drawBackground();
   FFTConfig.fft_plot.drawBox();
   FFTConfig.fft_plot.drawXAxis();
   FFTConfig.fft_plot.drawYAxis();
   //fft_plot.drawTopAxis();
   //fft_plot.drawRightAxis();
   //fft_plot.drawTitle();
   FFTConfig.fft_plot.drawGridLines(2);
   //here is where we will update points & loop...
   for (int i = 0; i < FFTConfig.fft_points.length; i++) {
     FFTConfig.fft_plot.setLineColor(FFTConfig.lineColor[i]);
     FFTConfig.fft_plot.setPoints(FFTConfig.fft_points[i]);
     FFTConfig.fft_plot.drawLines();
     // fft_plot.drawPoints(); //draw points
   }
   FFTConfig.fft_plot.endDraw();

   //for this widget need to redraw the grey bar, bc the FFT plot covers it up...
   // fill(200, 200, 200);
   // rect(x, y - navHeight, w, navHeight); //button bar

   popStyle();

 }

 int getNfftSafe()
 {
   switch(int(EegReceiverConfig.getSampleRateSafe())) {
     case 1000:
       return 1024;
     case 1600:
       return 2048;
     case 125:
     case 200:
     case 250:
     default:
       return 256;
   }
 }

 void FFT_update() {

   float[] fooData;
   for (int Ichan=0; Ichan < num_chan; Ichan++) {
     //make the FFT objects...Following "SoundSpectrum" example that came with the Minim library
     FFTConfig.fftBuff[Ichan] = new FFT(FFTConfig.nfft, FFTConfig.fs_Hz);  //I can't have this here...it must be in setup
     FFTConfig.fftBuff[Ichan].window(FFT.HAMMING);

     //do the FFT on the initial data
     if (isFFTFiltered == true) {
       fooData = EegReceiverConfig.eeg_data_buff_copy[Ichan];  //use the filtered data for the FFT
     } else {
       fooData = EegReceiverConfig.eeg_data_buff_copy[Ichan];  //use the raw data for the FFT
     }
     fooData = Arrays.copyOfRange(fooData, fooData.length-FFTConfig.nfft, fooData.length);
    FFTConfig.fftBuff[Ichan].forward(fooData); //compute FFT on this channel of data
   }
    for (int i = 0; i < FFTConfig.fft_points.length; i++) {
     for (int j = 0; j < FFTConfig.FFT_indexLim + 2; j++) {  //loop through frequency domain data, and store into points array
       GPoint powerAtBin;
       powerAtBin = new GPoint((1.0* FFTConfig.fs_Hz/ FFTConfig.nfft)*j, FFTConfig.fftBuff[i].getBand(j)/10000);
       FFTConfig.fft_points[i].set(j, powerAtBin);
     }}
 }
