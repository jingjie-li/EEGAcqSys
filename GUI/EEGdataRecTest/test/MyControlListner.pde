// Controll Listener for Contoller


class choose_data_source_ControlListener implements ControlListener {
  int col;
  public void controlEvent(ControlEvent theEvent) {
  	  choose_data_source.close();
  	  Data_Source_Index = int(theEvent.getValue());
      println(Data_Source_Index);
      source_connected = false;
    println("i got an event from choose_data_source");
  }
}
boolean system_start = false;
class start_button_ControlListener implements ControlListener{
  public void controlEvent(ControlEvent theEvent){
    system_start = !system_start;
    pause_calibration_phase = !pause_calibration_phase;
    
  }
}

class OnOffButton_ControlListener implements ControlListener{
  int corresponding_channel_number;
  OnOffButton_ControlListener(int _channel_number)
  {
    corresponding_channel_number = _channel_number;
  }
public void controlEvent(ControlEvent theEvent) {
    updating_channel[corresponding_channel_number] = !updating_channel[corresponding_channel_number];
    print("button"+corresponding_channel_number);
    }
}
class choose_system_mode_ControlListener implements ControlListener {
  public void controlEvent(ControlEvent theEvent) {
  	choose_system_mode.close();
  	System_Mode_Index = int(theEvent.getValue());
    println("i got an event from choose_system_mode");
    println(System_Mode_Index);
    if (System_Mode_Index == BEHAVIORAL_TRAINING){
      win = new PWindow();
    }
  }
}

// class add_plot_ControlListener implements ControlListener{
//   public void controlEvent(ControlEvent theEvent){
//     switch(int(theEvent.getValue()))
//     {
//       case 0:
//         create_timeseries_window();
//       case 1:
//         create_FFT_window();
//       case 2:
//         create_Head_Plot();


//     }
//   }

// }

// FFT_Window
// class MaxFreq_ControlListener implements ControlListener {
// 	FFTConfig w_fft;
// 	MaxFreq_ControlListener(FFTConfig _fft){
// 		w_fft = _fft;
// 	}
//   public void controlEvent(ControlEvent theEvent) {
//   	int n = int(theEvent.getValue());
//  	w_fft.fft_plot.setXLim(0.1, w_fft.xLimOptions[n]); //update the xLim of the FFT_Plot
//   	fftMaxFrqSave = n; //save the xLim to variable for save/load settings
//   }
// }

// class VertScale_ControlListener implements ControlListener {
// 		FFTConfig w_fft;
// 	VertScale_ControlListener(FFTConfig _fft){
// 		w_fft = _fft;
// 	}
//   public void controlEvent(ControlEvent theEvent) {
//   int n = int(theEvent.getValue());
//   w_fft.fft_plot.setYLim(0.1, w_fft.yLimOptions[n]); //update the yLim of the FFT_Plot
//   fftMaxuVSave = n; //save the yLim to variable for save/load settings
//   }
// }

// class LogLin_ControlListener implements ControlListener {
// 		FFTConfig w_fft;
// 	LogLin_ControlListener(FFTConfig _fft){
// 		w_fft = _fft;
// 	}
//   public void controlEvent(ControlEvent theEvent) {
//   	int n = int(theEvent.getValue());
// 	  if (n==0) {
// 	    w_fft.fft_plot.setLogScale("y");
// 	    //store the current setting to save
// 	    fftLogLinSave = 0;
// 	  } else {
// 	    w_fft.fft_plot.setLogScale("");
// 	    //store the current setting to save
// 	    fftLogLinSave = 1;
// 	  }
//   }
// }

// class Smoothing_ControlListener implements ControlListener {
// 		FFTConfig w_fft;
// 	Smoothing_ControlListener(FFTConfig _fft){
// 		w_fft = _fft;
// 	}
//   public void controlEvent(ControlEvent theEvent) {
//   	int n = int(theEvent.getValue());
// 	  smoothFac_ind = n;
// 	  fftSmoothingSave = n;
//   }
// }

// class UnfiltFilt_ControlListener implements ControlListener {
// 		FFTConfig w_fft;
// 	UnfiltFilt_ControlListener(FFTConfig _fft){
// 		w_fft = _fft;
// 	}
//   public void controlEvent(ControlEvent theEvent) {
//   	int n = int(theEvent.getValue());
//     if (n==0) {
// 	    //have FFT use filtered data -- default
// 	    isFFTFiltered = true;
// 	  } else {
// 	    //have FFT use unfiltered data
// 	    isFFTFiltered = false;
// 	  }
//   }
// }
