final static int num_chan = 8;
final static boolean eeg_buff_lock = true;
IIRNotch[] NotchFilter = new IIRNotch[num_chan];
LowPass[] LowPassFilter = new LowPass[num_chan];
HighPass[] HighPassFilter = new HighPass[num_chan];
void initiate_filter(){
	for(int i = 0; i< num_chan; i++)
	{
		NotchFilter[i] = new IIRNotch();
		LowPassFilter[i] = new LowPass();
    HighPassFilter[i] = new HighPass();

	}
}
boolean[] updating_channel = new boolean[8];
