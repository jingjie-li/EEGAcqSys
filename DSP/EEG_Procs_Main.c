/********************************************************************
* �ļ����� 	�������ʾ����
* ����:  	ִ�иó����������ʾ���ִ�0000~9999����				 

**********************************************************************/
/********************************************************************
����˵����	

			��������ƽ̨���������IO�ڳ�ʼ�����궨�� �Լ�spi��ʼ��
********************************************************************/

#include "DSP2833x_Device.h"     // DSP2833x Headerfile Include File
#include "DSP2833x_Examples.h"   // DSP2833x Examples Include File
/********************************�궨�������λѡ IO �ӿ�*******************************************/
#define  SET_BIT4	GpioDataRegs.GPASET.bit.GPIO16	 = 1 		//������� 8_LEDS ���ӵ� IO52 ��Ӧ					
#define  RST_BIT4	GpioDataRegs.GPACLEAR.bit.GPIO16 = 1		//������� 8_LEDS ���ӵ� IO52 ��Ӧ
#define  SET_BIT3   GpioDataRegs.GPASET.bit.GPIO17	 = 1		//������� 8_LEDS ���ӵ� IO53 ��Ӧ
#define  RST_BIT3	GpioDataRegs.GPACLEAR.bit.GPIO17 = 1		//������� 8_LEDS ���ӵ� IO53 ��Ӧ
#define  SET_BIT2   GpioDataRegs.GPBSET.bit.GPIO62	 = 1		//������� 8_LEDS ���ӵ� IO54 ��Ӧ
#define  RST_BIT2	GpioDataRegs.GPBCLEAR.bit.GPIO62 = 1		//������� 8_LEDS ���ӵ� IO54 ��Ӧ
#define  SET_BIT1   GpioDataRegs.GPBSET.bit.GPIO63	 = 1		//������� 8_LEDS ���ӵ� IO55 ��Ӧ
#define  RST_BIT1	GpioDataRegs.GPBCLEAR.bit.GPIO63 = 1		//������� 8_LEDS ���ӵ� IO55 ��Ӧ
#define LED1_OFF		GpioDataRegs.GPASET.bit.GPIO0 = 1							//LED D10 on
#define LED1_ON			GpioDataRegs.GPACLEAR.bit.GPIO0 = 1						//LED D10 off
#define LED2_OFF		GpioDataRegs.GPASET.bit.GPIO1 = 1							//LED D11 on
#define LED2_ON			GpioDataRegs.GPACLEAR.bit.GPIO1 = 1						//LED D11 off
#define LED3_OFF		GpioDataRegs.GPASET.bit.GPIO2 = 1							//LED D12 on
#define LED3_ON			GpioDataRegs.GPACLEAR.bit.GPIO2 = 1						//LED D12 off
#define LED4_OFF		GpioDataRegs.GPASET.bit.GPIO3 = 1							//LED D13 on
#define LED4_ON			GpioDataRegs.GPACLEAR.bit.GPIO3 = 1						//LED D13 off
/*****************************************************************************************************/


/*********************************************��������************************************************/
void delay(Uint32 t);
void Init_LEDS_Gpio(void);
void spi_xmit(Uint16 a);
void spi_fifo_init(void);
void spi_init(void);
void delay(Uint32 t);
void scib_init(void);
void scib_fifo_init(void);
void scib_xmit(int a);
Uint16 spi_send(Uint16 b);
Uint16 spi_rcv(void);
Uint16 ads1299_read2reg(Uint16 addr, Uint16 nums);
void scib_msg(char *msg);
void ads1299_WREG(Uint16 addr, Uint16 nums, Uint16 *Data);
void ads1299_RDATAC(Uint16 *Data_Rcv);
void ads1299_SendUARTRaw(Uint16 *Data_Rcv);
void ads1299_ConvRcvData(Uint16 *Data_Rcv, Uint32 *EEGCH1, Uint32 *EEGCH2, Uint32 *EEGCH3, Uint32 *EEGCH4, Uint32 *EEGCH5, Uint32 *EEGCH6, Uint32 *EEGCH7,Uint32 *EEGCH8, Uint32 *STAT_Data);
/*****************************************************************************************************/

/************************************������ر���*********************************************/
//unsigned char msg[10]={0xC0,0xf9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90};	//���룺0~9
//unsigned char DisData_Bit[4] = {0};											//��Ų�ֺ����λ����
//Uint16 DisData = 0;	
unsigned char data_to_send=0x30;														//��ʾ������
Uint16 Loop = 0;
Uint16 i = 0;	
Uint16 ads_addr=0;														//ѭ��ɨ�����
Uint16 Spi_Rcv_Data = 0;
Uint16 Sci_Send_Data = 0;
Uint16 Spi_Send_Data = 0;
Uint16 ADS_Rcv_Data = 0;
Uint16 ADS1299_Rcv_Data = 0;
Uint16 Data_Rcv[27]={0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
Uint16 Data[8]={0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000};
//Uint32 8Ch_Data[8]={0,0,0,0,0,0,0,0};
Uint32 EEGCH1=0,EEGCH2=0,EEGCH3=0,EEGCH4=0,EEGCH5=0,EEGCH6=0,EEGCH7=0,EEGCH8=0;
Uint32 STAT_Data=0;
char chr; //received bytes

/*****************************************************************************************************/

/******************************Init GPIOs*******************************************/
  
void Init_LEDS_Gpio(void)
{  
    EALLOW;
   
	
	GpioCtrlRegs.GPAPUD.bit.GPIO16= 0;   					// Enable pullup on GPIO11
    GpioDataRegs.GPASET.bit.GPIO16 = 1;   					// Load output latch
    GpioCtrlRegs.GPAMUX2.bit.GPIO16 = 0;  					// GPIO16 = GPIO
    GpioCtrlRegs.GPADIR.bit.GPIO16 = 1;   					// GPIO16 = output

	GpioCtrlRegs.GPAPUD.bit.GPIO17= 0;   					// Enable pullup on GPIO11
    GpioDataRegs.GPASET.bit.GPIO17 = 1;   					// Load output latch
    GpioCtrlRegs.GPAMUX2.bit.GPIO17 = 0;  					// GPIO16 = GPIO
    GpioCtrlRegs.GPADIR.bit.GPIO17 = 1;   					// GPIO16 = output
    
	GpioCtrlRegs.GPBPUD.bit.GPIO62 = 0;   					// Enable pullup on GPIO11
    GpioDataRegs.GPBSET.bit.GPIO62 = 1;   					// Load output latch
    GpioCtrlRegs.GPBMUX2.bit.GPIO62 = 0;  					// GPIO17 = GPIO
    GpioCtrlRegs.GPBDIR.bit.GPIO62 = 1;   					// GPIO17 = output
    
	GpioCtrlRegs.GPBPUD.bit.GPIO63 = 0;   					// Enable pullup on GPIO11
    GpioDataRegs.GPBSET.bit.GPIO63 = 1;   					// Load output latch
    GpioCtrlRegs.GPBMUX2.bit.GPIO63 = 0;  					// GPIO19 = GPIO
    GpioCtrlRegs.GPBDIR.bit.GPIO63 = 1;   					// GPIO19 = output
    
    
    GpioCtrlRegs.GPAMUX1.bit.GPIO15 = 0;   //congifure input
    GpioCtrlRegs.GPADIR.bit.GPIO15 = 0;   
    
     //LED D10 
	GpioCtrlRegs.GPAPUD.bit.GPIO0 = 0;   									// Enable pullup on GPIO11
    GpioDataRegs.GPASET.bit.GPIO0 = 1;   									// Load output latch
    GpioCtrlRegs.GPAMUX1.bit.GPIO0 = 0;  									// GPIO11 = GPIO
    GpioCtrlRegs.GPADIR.bit.GPIO0 = 1;   									// GPIO11 = output    
	//LED D11
	GpioCtrlRegs.GPAPUD.bit.GPIO1 = 0;   									// Enable pullup on GPIO11
    GpioDataRegs.GPASET.bit.GPIO1 = 1;   									// Load output latch
    GpioCtrlRegs.GPAMUX1.bit.GPIO1 = 0;  									// GPIO11 = GPIO
    GpioCtrlRegs.GPADIR.bit.GPIO1 = 1;   									// GPIO11 = output    
	//LED D12
	GpioCtrlRegs.GPAPUD.bit.GPIO2 = 0;   									// Enable pullup on GPIO11
    GpioDataRegs.GPASET.bit.GPIO2 = 1;   									// Load output latch
    GpioCtrlRegs.GPAMUX1.bit.GPIO2 = 0;  									// GPIO11 = GPIO
    GpioCtrlRegs.GPADIR.bit.GPIO2 = 1;   									// GPIO11 = output   
	//LED D13    
    GpioCtrlRegs.GPAPUD.bit.GPIO3 = 0;   									// Enable pullup on GPIO11
    GpioDataRegs.GPASET.bit.GPIO3 = 1;   									// Load output latch
    GpioCtrlRegs.GPAMUX1.bit.GPIO3 = 0;  									// GPIO11 = GPIO
    GpioCtrlRegs.GPADIR.bit.GPIO3 = 1;   									// GPIO11 = output  

    EDIS;  
    
    RST_BIT1;
    RST_BIT2;
    RST_BIT3;
    SET_BIT4;   
    LED1_OFF;
    LED2_OFF;
    LED3_OFF;
    LED4_OFF;
}
/*****************************************************************************************************/

/*********************************************Delay Functions************************************************/
void delay(Uint32 t)
{
	Uint32 i = 0;
	for (i = 0; i < t; i++);
}
/*****************************************************************************************************/
void ads1299_WREG(Uint16 addr, Uint16 nums, Uint16 *Data)//data must be prepared with data[i]<<8&0xff00
{
	addr=((addr<<8)|0x4000|nums);
	nums++;//convert L-1
	Spi_Send_Data=addr&0xff00;
	addr=(addr<<8)&0xff00;
	spi_xmit(Spi_Send_Data);
	spi_xmit(addr);
	for(i=0;i<nums;i++)//while(nums>0)
	{
		spi_xmit(Data[i]);
		//num--;
	}
	while (SpiaRegs.SPIFFRX.bit.RXFFST != (nums+2)) {}//do not exceed 16
	for(i=0;i<nums+2;i++)//while(nums>0)
	{
		Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
	}
}

void ads1299_RDATAC(Uint16 *Data_Rcv)
{
	spi_xmit(0x00);//Status Reg
	spi_xmit(0x00);
	spi_xmit(0x00);
	spi_xmit(0x00);//Channel 1
	spi_xmit(0x00);
	spi_xmit(0x00);
	spi_xmit(0x00);//Channel 2
	spi_xmit(0x00);
	spi_xmit(0x00);
	spi_xmit(0x00);//Channel 3
	spi_xmit(0x00);
	spi_xmit(0x00);  //got first 12s
	spi_xmit(0x00);//Channel 4
	spi_xmit(0x00);
	spi_xmit(0x00);  //to 15
	while (SpiaRegs.SPIFFRX.bit.RXFFST != 12) {}
	*(Data_Rcv)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+1)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+2)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+3)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+4)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+5)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+6)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+7)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+8)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+9)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+10)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+11)=SpiaRegs.SPIRXBUF;
	spi_xmit(0x00);//Channel 5
	spi_xmit(0x00);
	spi_xmit(0x00);
	spi_xmit(0x00);//Channel 6
	spi_xmit(0x00);
	spi_xmit(0x00);
	spi_xmit(0x00);//Channel 7
	spi_xmit(0x00);
	spi_xmit(0x00);
	spi_xmit(0x00);//Channel 8
	spi_xmit(0x00);
	spi_xmit(0x00);
	while (SpiaRegs.SPIFFRX.bit.RXFFST != 15) {}
	*(Data_Rcv+12)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+13)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+14)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+15)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+16)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+17)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+18)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+19)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+20)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+21)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+22)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+23)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+24)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+25)=SpiaRegs.SPIRXBUF;
	*(Data_Rcv+26)=SpiaRegs.SPIRXBUF;
}

void ads1299_SendUARTRaw(Uint16 *Data_Rcv)
{
	Uint32 i = 0;
	for (i=0;i<27;i++)
	{
		scib_xmit(*(Data_Rcv+i));
		//scib_xmit(0x0055);
	}
	scib_xmit(0x0d);
	scib_xmit(0x0a); //0D0A for terminate sign
}

void ads1299_ConvRcvData(Uint16 *Data_Rcv, Uint32 *EEGCH1, Uint32 *EEGCH2, Uint32 *EEGCH3, Uint32 *EEGCH4, Uint32 *EEGCH5, Uint32 *EEGCH6, Uint32 *EEGCH7,Uint32 *EEGCH8, Uint32 *STAT_Data)
{
	*(STAT_Data)=(Uint32)Data_Rcv[0]<<16+(Uint32)Data_Rcv[1]<<8+(Uint32)Data_Rcv[2];
	*(EEGCH1)=(Uint32)Data_Rcv[3]<<16+(Uint32)Data_Rcv[4]<<8+(Uint32)Data_Rcv[5];
	*(EEGCH2)=(Uint32)Data_Rcv[6]<<16+(Uint32)Data_Rcv[7]<<8+(Uint32)Data_Rcv[8];
	*(EEGCH3)=(Uint32)Data_Rcv[9]<<16+(Uint32)Data_Rcv[10]<<8+(Uint32)Data_Rcv[11];
	*(EEGCH4)=(Uint32)Data_Rcv[12]<<16+(Uint32)Data_Rcv[13]<<8+(Uint32)Data_Rcv[14];
	*(EEGCH5)=(Uint32)Data_Rcv[15]<<16+(Uint32)Data_Rcv[16]<<8+(Uint32)Data_Rcv[17];
	*(EEGCH6)=(Uint32)Data_Rcv[18]<<16+(Uint32)Data_Rcv[19]<<8+(Uint32)Data_Rcv[20];
	*(EEGCH7)=(Uint32)Data_Rcv[21]<<16+(Uint32)Data_Rcv[22]<<8+(Uint32)Data_Rcv[23];
	*(EEGCH8)=(Uint32)Data_Rcv[24]<<16+(Uint32)Data_Rcv[25]<<8+(Uint32)Data_Rcv[26];
}

Uint16 ads1299_read2reg(Uint16 addr, Uint16 nums)
{
	//RST_BIT4; //ACT AS CS
	Spi_Send_Data=((addr<<8)|0x2000|nums);
	
	spi_xmit(Spi_Send_Data&0xff00);
	spi_xmit((Spi_Send_Data<<8)&0xff00);
	
	//delay(1000);
	
	spi_xmit(0x00);
	spi_xmit(0x00);
	
	//delay(1000);
	while (SpiaRegs.SPIFFRX.bit.RXFFST != 4) {}
	//SET_BIT4; //ACT AS CS
	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
	//delay(100000);
	while(SpiaRegs.SPIFFRX.bit.RXFFST <2) {} 
	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
	//delay(1000);
	while(SpiaRegs.SPIFFRX.bit.RXFFST >1) {} 
	ADS1299_Rcv_Data=SpiaRegs.SPIRXBUF;	
	ADS1299_Rcv_Data += Spi_Rcv_Data<<8;
	return ADS1299_Rcv_Data;
	
}

/*********************************************Init SPI************************************************/

void spi_init()
{ 
	SpiaRegs.SPICCR.all =0x0007;     //8 bit length
	//SpiaRegs.SPICCR.all =0x000f;       //falling edge 16bits
	//SpiaRegs.SPICCR.all =0x004F;	             			// Reset on, rising edge, 16-bit char bits
	                                             			//0x000F��ӦRising Edge��0x004F��ӦFalling Edge  
	SpiaRegs.SPICTL.all =0x0006;    		     			// Enable master mode, normal phase,
                                                 			// enable talk, and SPI int disabled.
	SpiaRegs.SPIBRR =0x007F;
	SpiaRegs.SPICCR.all =0x0087;									
    //SpiaRegs.SPICCR.all =0x008F;		         			// Relinquish SPI from Reset   
    SpiaRegs.SPIPRI.bit.FREE = 1;                			// Set so breakpoints don't disturb xmission
}
/*****************************************************************************************************/
void scib_init()
{
    // Note: Clocks were turned on to the Scib peripheral
    // in the InitSysCtrl() function

 	ScibRegs.SCICCR.all =0x0007;   // 1 stop bit,  No loopback
                                   // No parity,8 char bits,
                                   // async mode, idle-line protocol
	ScibRegs.SCICTL1.all =0x0003;  // enable TX, RX, internal SCICLK,
                                   // Disable RX ERR, SLEEP, TXWAKE
	ScibRegs.SCICTL2.all =0x0003;
	ScibRegs.SCICTL2.bit.TXINTENA =1;
	ScibRegs.SCICTL2.bit.RXBKINTENA =1;
	#if (CPU_FRQ_150MHZ)
	      ScibRegs.SCIHBAUD    =0x0000;  // 115200 baud @LSPCLK = 37.5MHz. BRR = 39.6901 0x28
	      ScibRegs.SCILBAUD    =0x0028;
	#endif
	#if (CPU_FRQ_100MHZ)
      ScibRegs.SCIHBAUD    =0x0000;  // 115200 baud @LSPCLK = 20MHz. BRR = 20.7014   0x15
      ScibRegs.SCILBAUD    =0x0015;
	#endif
	ScibRegs.SCICTL1.all =0x0023;  // Relinquish SCI from Reset
}


void scib_fifo_init()
{
    ScibRegs.SCIFFTX.all=0xE040;
    ScibRegs.SCIFFRX.all=0x204f;
    ScibRegs.SCIFFCT.all=0x0;

}

void scib_xmit(int a)
{
    while (ScibRegs.SCIFFTX.bit.TXFFST != 0) {}
    ScibRegs.SCITXBUF=a;

}

void scib_msg(char * msg)
{
    int i;
    i = 0;
    while(msg[i] != '\0')
    {
        scib_xmit(msg[i]);
        i++;
    }
}


/****************************************Spi FIFO Init**********************************************/
void spi_fifo_init()										
{
// Initialize SPI FIFO registers
    SpiaRegs.SPIFFTX.all=0xE040;
    SpiaRegs.SPIFFRX.bit.RXFIFORESET=0;
    SpiaRegs.SPIFFRX.all=0x204f;
    SpiaRegs.SPIFFCT.all=0x0;
    //delay(5000);
    //SpiaRegs.SPIFFRX.bit.RXFIFORESET=1;
}  

/*****************************************************************************************************/

/*********************************************Spi Xmit************************************************/

void spi_xmit(Uint16 a)
{
    SpiaRegs.SPITXBUF=a;
}

Uint16 spi_send(Uint16 b)
{
	SpiaRegs.SPITXBUF=b;
	while(SpiaRegs.SPIFFRX.bit.RXFFST <1) {} 
	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;
	return Spi_Rcv_Data;
}    
/*****************************************************************************************************/
Uint16 spi_rcv(void)
{
	while(SpiaRegs.SPIFFRX.bit.RXFFST <1) { } 
	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
	return Spi_Rcv_Data;
}

void main(void)
{

   char *msg;
   Uint32 ii = 0;
   //Uint16 *Data_Rcv;
// Step 1. Initialize System Control:
// PLL, WatchDog, enable Peripheral Clocks
// This example function is found in the DSP280x_SysCtrl.c file.
   InitSysCtrl();
   

// Step 2. Initalize GPIO: 
// This example function is found in the DSP280x_Gpio.c file and
// illustrates how to set the GPIO to it's default state.
// InitGpio();  // Skipped for this example  
// Setup only the GP I/O only for SPI-A functionality
   EALLOW;
   GpioCtrlRegs.GPAMUX1.all = 0x0;    // GPIO pin
   GpioCtrlRegs.GPADIR.all = 0xFF;     // Output pin
   GpioDataRegs.GPADAT.all =0xFF;     // Close LEDs
   EDIS;


   InitSpiaGpio();  												//2802  SPIB 
   InitScibGpio();
   Init_LEDS_Gpio();

// Step 3. Clear all interrupts and initialize PIE vector table:
// Disable CPU interrupts 
   DINT;

// Initialize PIE control registers to their default state.
// The default state is all PIE interrupts disabled and flags
// are cleared.  
// This function is found in the DSP280x_PieCtrl.c file.
   InitPieCtrl();

// Disable CPU interrupts and clear all CPU interrupt flags:
   IER = 0x0000;
   IFR = 0x0000;
   
// Initialize the PIE vector table with pointers to the shell Interrupt 
// Service Routines (ISR).  
// This will populate the entire table, even if the interrupt
// is not used in this example.  This is useful for debug purposes.
// The shell ISR routines are found in DSP280x_DefaultIsr.c.
// This function is found in DSP280x_PieVect.c.
   InitPieVectTable();
	
// Step 4. Initialize all the Device Peripherals:
// This function is found in DSP280x_InitPeripherals.c
// InitPeripherals(); // Not required for this example
   spi_fifo_init();	  // Initialize the Spi FIFO
   spi_init();		  // init SPI
   
   scib_fifo_init();	   // Initialize the SCI FIFO
   scib_init();  // Initalize SCI for echoback
   
   
   SET_BIT1; //PWD IO63
   SET_BIT2; //RST IO62
   RST_BIT3; //START
   SET_BIT4; //ACT AS CS
   delay(500);
   
   //RST_BIT4;
   spi_xmit(0x0200);// wake up
   //SET_BIT4;
   delay(100);
   //RST_BIT4;
   spi_xmit(0x0600);// reset
   //SET_BIT4;
   delay(100);	
   //RST_BIT4;
   spi_xmit(0x1100);//enable reading
   //SET_BIT4;
   //delay(1000);
   while (SpiaRegs.SPIFFRX.bit.RXFFST != 3) {}
   Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
   Spi_Rcv_Data=SpiaRegs.SPIRXBUF;
   Spi_Rcv_Data=SpiaRegs.SPIRXBUF;
   
   msg = "\r\n\Start ADS1299 SPI Interface Testing\0";
   scib_msg(msg);

   ADS_Rcv_Data=ads1299_read2reg(0x00,0x01);//3e96 for default
   
   Data[0]=0x9600;Data[1]=0xc000;
   ads1299_WREG(0x01,0x01,Data);
   //CH1-8
   Data[0]=0x0100;Data[1]=0x0100;Data[2]=0x0100;Data[3]=0x0100;Data[4]=0x0100;Data[5]=0x0100;Data[6]=0x0100;Data[7]=0x0100;
   ads1299_WREG(0x05,0x07,Data);
   //MISC REF
   //Data[0]=0x2000;Data[1]=0x0000;
   //ads1299_WREG(0x15,0x01,Data);
   
   ADS_Rcv_Data=ads1299_read2reg(0x01,0x01);//95c0 if correct
   
   while(1)
   {
   LED1_OFF;
   while(ScibRegs.SCIFFRX.bit.RXFFST <1) { }
   chr=ScibRegs.SCIRXBUF.all;
   LED1_ON;
   LED2_ON;
   LED3_ON;
   switch(chr)
   {
   	case 'B': //processing baseline mode
   	 LED3_ON;
   	 LED2_OFF;
   	 Data[0]=0x9600;Data[1]=0xc000;
     ads1299_WREG(0x01,0x01,Data);
     Data[0]=0x0100;Data[1]=0x0100;Data[2]=0x0100;Data[3]=0x0100;Data[4]=0x0100;Data[5]=0x0100;Data[6]=0x0100;Data[7]=0x0100;
     ads1299_WREG(0x05,0x07,Data);
     //Prepar for reading data
   	SET_BIT3; //START!
   	spi_xmit(0x1000);// RDATAC command
   	while (SpiaRegs.SPIFFRX.bit.RXFFST != 1) {}
   	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
   	for(ii=0;ii<600;ii++)
   	{
   	  	while (GpioDataRegs.GPADAT.bit.GPIO15==1) {} //DRDY is in high
   	  	ads1299_RDATAC(Data_Rcv);
   	  	//ads1299_ConvRcvData(Data_Rcv,&EEGCH1,&EEGCH2,&EEGCH3,&EEGCH4,&EEGCH5,&EEGCH6,&EEGCH7,&EEGCH8,&STAT_Data);
   	  	ads1299_SendUARTRaw(Data_Rcv);
   	}
   	 break;
   	case 'S'://Signal Acqusision mode
   	 LED3_OFF;
   	 LED2_ON;
     Data[0]=0x9600;Data[1]=0xc000;
     ads1299_WREG(0x01,0x01,Data);
     //Data[0]=0x5000;Data[1]=0x5000;Data[2]=0x5000;Data[3]=0x5000;Data[4]=0x5000;Data[5]=0x5000;Data[6]=0x5000;Data[7]=0x5000;
     //Data[0]=0x0000;Data[1]=0x0000;Data[2]=0x0000;Data[3]=0x0000;Data[4]=0x0000;Data[5]=0x0000;Data[6]=0x0000;Data[7]=0x0000;
     //Data[0]=0x6000;Data[1]=0x6000;Data[2]=0x6000;Data[3]=0x6000;Data[4]=0x6000;Data[5]=0x6000;Data[6]=0x6000;Data[7]=0x6000;
     Data[0]=0x3000;Data[1]=0x3000;Data[2]=0x3000;Data[3]=0x3000;Data[4]=0x3000;Data[5]=0x3000;Data[6]=0x3000;Data[7]=0x3000;
     ads1299_WREG(0x05,0x07,Data);
     //MISC REF
     Data[0]=0x2000;Data[1]=0x0000;
     ads1299_WREG(0x15,0x01,Data);
   	//Prepar for reading data
   	SET_BIT3; //START!
   	spi_xmit(0x1000);// RDATAC command
   	while (SpiaRegs.SPIFFRX.bit.RXFFST != 1) {}
   	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
   	
   	for(;;)
   	{
   	  	while (GpioDataRegs.GPADAT.bit.GPIO15==1) {} //DRDY is in high
   	  	ads1299_RDATAC(Data_Rcv);
   	  	//ads1299_ConvRcvData(Data_Rcv,&EEGCH1,&EEGCH2,&EEGCH3,&EEGCH4,&EEGCH5,&EEGCH6,&EEGCH7,&EEGCH8,&STAT_Data);
   	  	ads1299_SendUARTRaw(Data_Rcv);
   	  	if(ScibRegs.SCIFFRX.bit.RXFFST >0) 
   	  	{
   	  		RST_BIT3;
   	  		break;//received something, stop the running
   	  	}
   	}
   	 break;
   	case 'T': //test signal plotting mode
   	 LED3_OFF;
   	 LED2_ON;
     Data[0]=0x9600;Data[1]=0xd000;
     ads1299_WREG(0x01,0x01,Data);
     Data[0]=0x0500;Data[1]=0x0500;Data[2]=0x0500;Data[3]=0x0500;Data[4]=0x0500;Data[5]=0x0500;Data[6]=0x0500;Data[7]=0x0500;
     ads1299_WREG(0x05,0x07,Data);
   	//Prepar for reading data
   	SET_BIT3; //START!
   	spi_xmit(0x1000);// RDATAC command
   	while (SpiaRegs.SPIFFRX.bit.RXFFST != 1) {}
   	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
   	
   	for(;;)
   	{
   	  	while (GpioDataRegs.GPADAT.bit.GPIO15==1) {} //DRDY is in high
   	  	ads1299_RDATAC(Data_Rcv);
   	  	//ads1299_ConvRcvData(Data_Rcv,&EEGCH1,&EEGCH2,&EEGCH3,&EEGCH4,&EEGCH5,&EEGCH6,&EEGCH7,&EEGCH8,&STAT_Data);
   	  	ads1299_SendUARTRaw(Data_Rcv);
   	  	if(ScibRegs.SCIFFRX.bit.RXFFST >0) 
   	  	{
   	  		RST_BIT3;
   	  		break;//received something, stop the running
   	  	}
   	}
   	break;
   case 'E': //Exit Mode
    LED3_OFF;
   	LED2_OFF;
    break;
   }
   }
   
	//for(;;)
	//{
		//for(i=0;i<23;i++)
		//{
		//ADS_Rcv_Data=ads1299_read2reg(ads_addr,0x01);
		//delay(25000);										//��ʱ������۷�Ӧʱ��
		//scib_xmit(0x55);
		//msg = "\r\n\Read Reg:0x\0";
		//scib_msg(msg);
		//data_to_send = ads_addr+0x30;
		//scib_xmit(data_to_send);
		//msg = "  Results:0x\0";
		//scib_msg(msg);
		//Sci_Send_Data=((ADS_Rcv_Data>>8)&0x00ff);
		//data_to_send = Sci_Send_Data+0x30;
		//scib_xmit(data_to_send);
		//Sci_Send_Data=(ADS_Rcv_Data&0x00ff);
		//data_to_send = Sci_Send_Data+0x30;
		//scib_xmit(data_to_send);
		//delay(25000);
		//ads_addr++;
		//}
	//}


} 	


//===========================================================================
// No more.
//===========================================================================

