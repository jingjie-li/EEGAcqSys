final static int num_chan = 8;
final static boolean eeg_buff_lock = true;
IIRNotch[] NotchFilter = new IIRNotch[8];
LowPass[] LowPassFilter = new LowPass[8];
void initiate_filter(){
	for(int i = 0; i< num_chan; i++)
	{
		NotchFilter[i] = new IIRNotch();
		LowPassFilter[i] = new LowPass();
	}
}
