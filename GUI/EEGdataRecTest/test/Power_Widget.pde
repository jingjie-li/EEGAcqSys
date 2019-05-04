


////////////////////////////////////////////////////
//
//    W_BandPowers.pde
//
//    This is a band power visualization widget!
//    (Couldn't think up more)
//    This is for visualizing the power of each brainwave band: delta, theta, alpha, beta, gamma
//    Averaged over all channels
//
//    Created by: Wangshu Sun, May 2017
//
///////////////////////////////////////////////////,

final int DELTA= 0;
final int THETA = 1;
final int ALPHA = 2;
final int BETA = 3; 
final int GAMMA = 4; 

static class BandPowerConfig{

  static GPlot plot3;
  static String bands[] = {"DELTA", "THETA", "ALPHA", "BETA", "GAMMA"};
  
  static int[] processing_band_low_Hz = {
    1, 4, 8, 13, 30
  }; //lower bound for each frequency band of interest (2D classifier only)
  static int[] processing_band_high_Hz = {
    4, 8, 13, 30, 55
  };  //upper bound for each frequency band of interest
  static float[][] avgPowerInBins = new float[num_chan][processing_band_low_Hz.length];
  static float[]headWidePower = new float[processing_band_low_Hz.length];;
  static GPointsArray points3 = new GPointsArray(headWidePower.length);

}


void initiate_bandpower_plot(PApplet p){

    //This is the protocol for setting up dropdowns.
    //Note that these 3 dropdowns correspond to the 3 global functions below
    //You just need to make sure the "id" (the 1st String) has the same name as the corresponding function
    // addDropdown("Dropdown1", "Drop 1", Arrays.asList("A", "B"), 0);
    // addDropdown("Dropdown2", "Drop 2", Arrays.asList("C", "D", "E"), 1);
    // addDropdown("Dropdown3", "Drop 3", Arrays.asList("F", "G", "H", "I"), 3);

    // Setup for the third plot
    
    BandPowerConfig.plot3 = new GPlot(p);
    
    BandPowerConfig.plot3.setPos(678 - control_panel_pos_x, 597 - control_panel_pos_y);
    BandPowerConfig.plot3.setDim(478, 217);
    BandPowerConfig.plot3.setLogScale("y");
    BandPowerConfig.plot3.setYLim(0.1, 100);
    BandPowerConfig.plot3.setXLim(0, 5);
    BandPowerConfig.plot3.getYAxis().setNTicks(9);
    BandPowerConfig.plot3.getTitle().setTextAlignment(LEFT);
    BandPowerConfig.plot3.getTitle().setRelativePos(0);
    BandPowerConfig.plot3.getYAxis().getAxisLabel().setText("(uV)^2 / Hz per channel");
    BandPowerConfig.plot3.getYAxis().getAxisLabel().setTextAlignment(RIGHT);
    BandPowerConfig.plot3.getYAxis().getAxisLabel().setRelativePos(1);
    // plot3.setPoints(points3);
    BandPowerConfig.plot3.startHistograms(GPlot.VERTICAL);
    BandPowerConfig.plot3.getHistogram().setDrawLabels(true);
    //plot3.getHistogram().setRotateLabels(true);
    BandPowerConfig.plot3.getHistogram().setBgColors(new color[] {
      color(0, 0, 255, 50), color(0, 0, 255, 100),
      color(0, 0, 255, 150), color(0, 0, 255, 200)
    }
    );


  }

  void bandpower_update(){
    FFT[] temp_fftBuff = FFTConfig.fftBuff.clone();
    for(int Ichan = 0; Ichan < EegReceiverConfig.nchan; Ichan++){
     for (int i = 0; i < BandPowerConfig.processing_band_low_Hz.length; i++) {
        float sum = 0;
        // int binNum = 0;
        for (int Ibin = 0; Ibin <= FFTConfig.nfft/2; Ibin ++) { // loop over FFT bins
          float FFT_freq_Hz = temp_fftBuff[Ichan].indexToFreq(Ibin);   // center frequency of this bin
          float psdx = 0;
          // if the frequency matches a band
          if (FFT_freq_Hz >= BandPowerConfig.processing_band_low_Hz[i] && FFT_freq_Hz < BandPowerConfig.processing_band_high_Hz[i]) {
            if (Ibin != 0 && Ibin !=FFTConfig.nfft/2) {
              psdx = temp_fftBuff[Ichan].getBand(Ibin) * temp_fftBuff[Ichan].getBand(Ibin) * FFTConfig.nfft/EegReceiverConfig.getSampleRateSafe() / 4;
            }
            else {
              psdx = temp_fftBuff[Ichan].getBand(Ibin) * temp_fftBuff[Ichan].getBand(Ibin) * FFTConfig.nfft/EegReceiverConfig.getSampleRateSafe();
            }
            sum += psdx;
            // binNum ++;
          }
        }
        BandPowerConfig.avgPowerInBins[Ichan][i] = sum;   // total power in a band
        // println(i, binNum, sum);
      }
     //end the loop over channels.
    for (int i = 0; i < BandPowerConfig.processing_band_low_Hz.length; i++) {
      float sum = 0;

      for (int j = 0; j < EegReceiverConfig.nchan; j++) {
        sum += BandPowerConfig.avgPowerInBins[j][i];
      }
      BandPowerConfig.headWidePower[i] = sum/EegReceiverConfig.nchan;   // averaging power over all channels
    }
    }


    BandPowerConfig.points3.add(DELTA + 0.5, BandPowerConfig.headWidePower[DELTA], "DELTA");
    BandPowerConfig.points3.add(THETA + 0.5, BandPowerConfig.headWidePower[THETA], "THETA");
    BandPowerConfig.points3.add(ALPHA + 0.5, BandPowerConfig.headWidePower[ALPHA], "ALPHA");
    BandPowerConfig.points3.add(BETA + 0.5, BandPowerConfig.headWidePower[BETA], "BETA");
    BandPowerConfig.points3.add(GAMMA + 0.5,BandPowerConfig.headWidePower[GAMMA], "GAMMA");

    BandPowerConfig.plot3.setPoints(BandPowerConfig.points3);
    BandPowerConfig.plot3.getTitle().setText("Band Power");
    
  }

  void bandpower_draw(){
    //put your code here... //remember to refer to x,y,w,h which are the positioning variables of the Widget class
    // Draw the third plot
    BandPowerConfig.plot3.beginDraw();
    BandPowerConfig.plot3.drawBackground();
    BandPowerConfig.plot3.drawBox();
    BandPowerConfig.plot3.drawYAxis();
    BandPowerConfig.plot3.drawTitle();
    BandPowerConfig.plot3.drawHistograms();
    BandPowerConfig.plot3.endDraw();

  }
