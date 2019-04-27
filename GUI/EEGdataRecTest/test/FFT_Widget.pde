// FFT[] fftBuff = new FFT[nchan];    //from the minim library
// boolean isFFTFiltered = true; //yes by default ... this is used in dataProcessing.pde to determine which uV array feeds the FFT calculation

// class FFTData{
//  //to see all core variables/methods of the Widget class, refer to Widget.pde

//   //put your custom variables here...
//   GPlot fft_plot; //create an fft plot for each active channel
//   GPointsArray[] fft_points;  //create an array of points for each channel of data (4, 8, or 16)
//   int[] lineColor = {
//     (int)color(129, 129, 129),
//     (int)color(124, 75, 141),
//     (int)color(54, 87, 158),
//     (int)color(49, 113, 89),
//     (int)color(221, 178, 13),
//     (int)color(253, 94, 52),
//     (int)color(224, 56, 45),
//     (int)color(162, 82, 49),

//     (int)color(129, 129, 129),
//     (int)color(221, 178, 13),
//     (int)color(253, 94, 52),
//     (int)color(224, 56, 45),
//     (int)color(162, 82, 49)
//   };

//   int[] xLimOptions = {20, 40, 60, 100, 120, 250, 500, 800};
//   int[] yLimOptions = {10, 50, 100, 1000};

//   int xLim = xLimOptions[2];  //maximum value of x axis ... in this case 20 Hz, 40 Hz, 60 Hz, 120 Hz
//   int xMax = xLimOptions[xLimOptions.length-1];   //maximum possible frequency in FFT
//   int FFT_indexLim = int(1.0*xMax*(getNfftSafe()/getSampleRateSafe()));   // maxim value of FFT index
//   int yLim = yLimOptions[2];  //maximum value of y axis ... 100 uV

//   //Used to save settings
//   int fftMaxFrqSave = xLim;
//   int fftMaxuVSave = yLim;
//   ScrollableList max_freq_list;
//   ScrollableList vert_scale_list;
//   ScrollableList log_lin_list;
//   ScrollableList smoothing_list;
//   ScrollableList fft_filter_list;
// }

// FFTData FFT_data =  new FFTData(); 

// void initialize_FFT_plot(PApplet _parent,ControlP5 cp5){
//      //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

//     //FFT plot settings,
//     // fftMaxFrqSave = 2;
//     // fftMaxuVSave = 2;
//     // fftLogLinSave = 0;
//     // fftSmoothingSave = 3;
//     // fftFilterSave = 0;

//     //This is the protocol for setting up dropdowns.
//     //Note that these 3 dropdowns correspond to the 3 global functions below
//     //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
//     pushStyle();
//     textMode(CENTER);
//     text("MaxFreq",78 - control_panel_pos_x, 522- control_panel_pos_y);
//     text("Max uv",197 - control_panel_pos_x, 522- control_panel_pos_y);
//     text("Log/Lin",303 - control_panel_pos_x, 522- control_panel_pos_y);
//     text("Smooth",415 - control_panel_pos_x, 522- control_panel_pos_y);
//     text("Filters",529 - control_panel_pos_x, 522- control_panel_pos_y);
//     popStyle();
//     max_freq_list = cp5
//     .addScrollableList("MaxFreq")
//     .setPosition(129 - control_panel_pos_x, 519 - control_panel_pos_y).setSize(57,22*max_freq_list.length)
//     .setBarHeight(22)
//     .setItemHeight(22)
//     .addItems(Arrays.asList(fftMaxFrqArray))
//     .setOpen(false)
//     .setValue(2).setFont(font);
//     max_freq_list.getCaptionLabel().setText("Max Freq");

//     vert_scale_list = cp5
//     .addScrollableList("VertScale")
//     .setPosition(245 - control_panel_pos_x, 519 - control_panel_pos_y)
//     .setSize(57,22*max_freq_list.length).setBarHeight(22)
//     .setItemHeight(22)
//     .addItems(Arrays.asList(fftVertScaleArray))
//     .setOpen(false)
//     .setValue(2).setFont(font);
//     vert_scale_list.getCaptionLabel().setText("Vert Scale");

//     log_lin_list = cp5.addScrollableList("LogLin").setPosition(356 - control_panel_pos_x, 519 - control_panel_pos_y).setSize(57,22*vert_scale_list.length).setBarHeight(22)
//     .setItemHeight(22)
//     .addItems(Arrays.asList(fftLogLinArray))
//     .setOpen(false)
//     .setValue(0).setFont(font);
//     log_lin_list.getCaptionLabel().setText("Log Lin");

//     smoothing_list = cp5.addScrollableList("Smoothing").setPosition(470 - control_panel_pos_x, 519 - control_panel_pos_y).setSize(57,22*smoothing_list.length).setBarHeight(22)
//     .setItemHeight(22)
//     .addItems(rrays.asList(fftSmoothingArray))
//     .setOpen(false)
//     .setValue(3).setFont(font);
//     smoothing_list.getCaptionLabel().setText("Smoothing");

//     fft_filter_list = cp5.addScrollableList("fft_filter").setPosition(574 - control_panel_pos_x, 519 - control_panel_pos_y).setSize(57,22*fft_filter_list.length).setBarHeight(22)
//     .setItemHeight(22)
//     .addItems(Arrays.asList(fftFilterArray))
//     .setOpen(false)
//     .setValue(0).setFont(font);
//     fft_filter_list.getCaptionLabel().setText("fft fliter");

//     fft_points = new GPointsArray[nchan];
//     // println("fft_points.length: " + fft_points.length);
//     //setup GPlot for FFT
//     fft_plot =  new GPlot(_parent, x, y-navHeight, w, h+navHeight); //based on container dimensions
//     fft_plot.getXAxis().setAxisLabelText("Frequency (Hz)");
//     fft_plot.getYAxis().setAxisLabelText("Amplitude (uV)");
//     //fft_plot.setMar(50,50,50,50); //{ bot=60, left=70, top=40, right=30 } by default
//     fft_plot.setMar(60, 70, 40, 30); //{ bot=60, left=70, top=40, right=30 } by default
//     fft_plot.setLogScale("y");

//     fft_plot.setYLim(0.1, yLim);
//     int _nTicks = int(yLim/10 - 1); //number of axis subdivisions
//     fft_plot.getYAxis().setNTicks(_nTicks);  //sets the number of axis divisions...
//     fft_plot.setXLim(0.1, xLim);
//     fft_plot.getYAxis().setDrawTickLabels(true);
//     fft_plot.setPointSize(2);
//     fft_plot.setPointColor(0);

//     //setup points of fft point arrays
//     for (int i = 0; i < fft_points.length; i++) {
//       fft_points[i] = new GPointsArray(FFT_indexLim);
//     }

//     //fill fft point arrays
//     for (int i = 0; i < fft_points.length; i++) { //loop through each channel
//       for (int j = 0; j < FFT_indexLim; j++) {
//         //GPoint temp = new GPoint(i, 15*noise(0.1*i));
//         //println(i + " " + j);
//         GPoint temp = new GPoint(j, 0);
//         fft_points[i].set(j, temp);
//       }
//     }

//     //map fft point arrays to fft plots
//     fft_plot.setPoints(fft_points[0]);
//   }

// void update(){

//   super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
//   float sr = getSampleRateSafe();
//   int nfft = getNfftSafe();

//   //put your code here...
//   //update the points of the FFT channel arrays
//   //update fft point arrays
//   // println("LENGTH = " + fft_points.length);
//   // println("LENGTH = " + fftBuff.length);
//   // println("LENGTH = " + FFT_indexLim);
//   for (int i = 0; i < fft_points.length; i++) {
//     for (int j = 0; j < FFT_indexLim + 2; j++) {  //loop through frequency domain data, and store into points array
//       //GPoint powerAtBin = new GPoint(j, 15*random(0.1*j));
//       GPoint powerAtBin;

//       // println("i = " + i);
//       // float a = getSampleRateSafe();
//       // float aa = fftBuff[i].getBand(j);
//       // float b = fftBuff[i].getBand(j);
//       // float c = Nfft;

//       //println("Sample rate: "+ sr + " -- Nfft: " + nfft);
//       powerAtBin = new GPoint((1.0*sr/nfft)*j, fftBuff[i].getBand(j));
//       fft_points[i].set(j, powerAtBin);
//       // GPoint powerAtBin = new GPoint((1.0*getSampleRateSafe()/Nfft)*j, fftBuff[i].getBand(j));

//       //println("=========================================");
//       //println(j);
//       //println(fftBuff[i].getBand(j) + " :: " + fft_points[i].getX(j) + " :: " + fft_points[i].getY(j));
//       //println("=========================================");
//     }
//   }

//   //remap fft point arrays to fft plots
//   fft_plot.setPoints(fft_points[0]);

// }

// void draw_FFT(){

//   //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
//   pushStyle();

//   //draw FFT Graph w/ all plots
//   noStroke();
//   fft_plot.beginDraw();
//   fft_plot.drawBackground();
//   fft_plot.drawBox();
//   fft_plot.drawXAxis();
//   fft_plot.drawYAxis();
//   //fft_plot.drawTopAxis();
//   //fft_plot.drawRightAxis();
//   //fft_plot.drawTitle();
//   fft_plot.drawGridLines(2);
//   //here is where we will update points & loop...
//   for (int i = 0; i < fft_points.length; i++) {
//     fft_plot.setLineColor(lineColor[i]);
//     fft_plot.setPoints(fft_points[i]);
//     fft_plot.drawLines();
//     // fft_plot.drawPoints(); //draw points
//   }
//   fft_plot.endDraw();

//   //for this widget need to redraw the grey bar, bc the FFT plot covers it up...
//   fill(200, 200, 200);
//   rect(x, y - navHeight, w, navHeight); //button bar

//   popStyle();

// }

// void screenResized(){
//   super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

//   //put your code here...
//   //update position/size of FFT plot
//   fft_plot.setPos(x, y-navHeight);//update position
//   fft_plot.setOuterDim(w, h+navHeight);//update dimensions

// }

// void mousePressed(){
//   super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)

//   //put your code here...

// }

// void mouseReleased(){
//   super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)

//   //put your code here...

// }





// int getNfftSafe() {
//   int sampleRate = (int)getSampleRateSafe();
//   switch (sampleRate) {
//     case 1000:
//       return 1024;
//     case 1600:
//       return 2048;
//     case 125:
//     case 200:
//     case 250:
//     default:
//       return 256;
//   }
// }
// //These functions need to be global! These functions are activated when an item from the corresponding dropdown is selected
// //triggered when there is an event in the MaxFreq. Dropdown
// void MaxFreq(int n) {
//   /* request the selected item based on index n */
//   w_fft.fft_plot.setXLim(0.1, w_fft.xLimOptions[n]); //update the xLim of the FFT_Plot
//   fftMaxFrqSave = n; //save the xLim to variable for save/load settings
//   closeAllDropdowns();
// }

// //triggered when there is an event in the VertScale Dropdown
// void VertScale(int n) {

//   w_fft.fft_plot.setYLim(0.1, w_fft.yLimOptions[n]); //update the yLim of the FFT_Plot
//   fftMaxuVSave = n; //save the yLim to variable for save/load settings
//   closeAllDropdowns();
// }

// //triggered when there is an event in the LogLin Dropdown
// void LogLin(int n) {
//   if (n==0) {
//     w_fft.fft_plot.setLogScale("y");
//     //store the current setting to save
//     fftLogLinSave = 0;
//   } else {
//     w_fft.fft_plot.setLogScale("");
//     //store the current setting to save
//     fftLogLinSave = 1;
//   }
//   closeAllDropdowns();
// }

// //triggered when there is an event in the Smoothing Dropdown
// void Smoothing(int n) {
//   smoothFac_ind = n;
//   fftSmoothingSave = n;
//   closeAllDropdowns();
// }

// //triggered when there is an event in the UnfiltFilt Dropdown
// void UnfiltFilt(int n) {
//   if (n==0) {
//     //have FFT use filtered data -- default
//     isFFTFiltered = true;
//   } else {
//     //have FFT use unfiltered data
//     isFFTFiltered = false;
//   }
//   closeAllDropdowns();
// }

// void initializeFFTObjects(FFT[] fftBuff, float[][] dataBuffY_uV, int Nfft, float fs_Hz) {

//   float[] fooData;
//   for (int Ichan=0; Ichan < nchan; Ichan++) {
//     //make the FFT objects...Following "SoundSpectrum" example that came with the Minim library
//     //fftBuff[Ichan] = new FFT(Nfft, fs_Hz);  //I can't have this here...it must be in setup
//     fftBuff[Ichan].window(FFT.HAMMING);

//     //do the FFT on the initial data
//     if (isFFTFiltered == true) {
//       fooData =  dataBuffY_uV[Ichan];  //use the filtered data for the FFT
//     } else {
//       fooData = dataBuffY_uV[Ichan];  //use the raw data for the FFT
//     }
//     fooData = Arrays.copyOfRange(fooData, fooData.length-Nfft, fooData.length);
//     fftBuff[Ichan].forward(fooData); //compute FFT on this channel of data
//   }
// }
