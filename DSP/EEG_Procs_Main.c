/********************************************************************
* 文件名： 	数码管显示程序
* 描述:  	执行该程序，数码管显示数字从0000~9999递增				 

**********************************************************************/
/********************************************************************
程序说明：	

			更换控制平台，仅需更改IO口初始化、宏定义 以及spi初始化
********************************************************************/

#include "DSP2833x_Device.h"     // DSP2833x Headerfile Include File
#include "DSP2833x_Examples.h"   // DSP2833x Examples Include File
/********************************宏定义数码管位选 IO 接口*******************************************/
#define  SET_BIT4	GpioDataRegs.GPASET.bit.GPIO16	 = 1 		//与外设板 8_LEDS 端子的 IO52 对应					
#define  RST_BIT4	GpioDataRegs.GPACLEAR.bit.GPIO16 = 1		//与外设板 8_LEDS 端子的 IO52 对应
#define  SET_BIT3   GpioDataRegs.GPASET.bit.GPIO17	 = 1		//与外设板 8_LEDS 端子的 IO53 对应
#define  RST_BIT3	GpioDataRegs.GPACLEAR.bit.GPIO17 = 1		//与外设板 8_LEDS 端子的 IO53 对应
#define  SET_BIT2   GpioDataRegs.GPBSET.bit.GPIO62	 = 1		//与外设板 8_LEDS 端子的 IO54 对应
#define  RST_BIT2	GpioDataRegs.GPBCLEAR.bit.GPIO62 = 1		//与外设板 8_LEDS 端子的 IO54 对应
#define  SET_BIT1   GpioDataRegs.GPBSET.bit.GPIO63	 = 1		//与外设板 8_LEDS 端子的 IO55 对应
#define  RST_BIT1	GpioDataRegs.GPBCLEAR.bit.GPIO63 = 1		//与外设板 8_LEDS 端子的 IO55 对应
/*****************************************************************************************************/


/*********************************************函数申明************************************************/
void delay(Uint32 t);
void DisData_Trans(Uint16 data);
void Sellect_Bit(Uint16 i);
void Init_LEDS_Gpio(void);
void spi_xmit(Uint16 a);
void spi_fifo_init(void);
void spi_init(void);
void delay(Uint32 t);
void scib_init(void);
void scib_fifo_init(void);
void scib_xmit(int a);
Uint16 spi_rcv(void);
/*****************************************************************************************************/

/************************************定义相关变量*********************************************/
unsigned char msg[10]={0xC0,0xf9,0xA4,0xB0,0x99,0x92,0x82,0xF8,0x80,0x90};	//段码：0~9
unsigned char DisData_Bit[4] = {0};											//存放拆分后的四位数字
Uint16 DisData = 0;															//显示的数字
Uint16 Loop = 0;															//循环扫描变量
Uint16 Spi_Rcv_Data = 0;

/*****************************************************************************************************/

/******************************数码管位选 IO 接口初始化*******************************************/
  
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

    EDIS;  
    
    RST_BIT1;
    RST_BIT2;
    RST_BIT3;
    RST_BIT4;   
}
/*****************************************************************************************************/


/******************************数码管位选函数（从低位到高位扫描）***************************************************/
void Sellect_Bit(Uint16 i)
{
	switch(i)
	{
		case 0:
			RST_BIT4;									//关断数码管第四位	
			SET_BIT1;									//选通数码管第一位
			break;

		case 1:
			RST_BIT1;									//关断数码管第一位
			SET_BIT2;									//选通数码管第二位
			break;

		case 2:
			RST_BIT2;									//关断数码管第二位
			SET_BIT3;									//选通数码管第三位
			break;

		case 3:
			RST_BIT3;									//关断数码管第三位
			SET_BIT4;									//选通数码管第四位
			break;

		default:
			break;
	}
}
/*****************************************************************************************************/

/************************** 拆分要显示的四位数保存到数组DisData_Trans【】*****************************/
void DisData_Trans(Uint16 data)
{
	DisData_Bit[3] = data / 1000;						//千位数
	DisData_Bit[2] = data % 1000 / 100 ;				//百位数
	DisData_Bit[1] = data % 100 / 10;					//十位数
	DisData_Bit[0] = data % 10;							//个位数
}
/*****************************************************************************************************/



/*********************************************延时函数************************************************/
void delay(Uint32 t)
{
	Uint32 i = 0;
	for (i = 0; i < t; i++);
}
/*****************************************************************************************************/

/*********************************************Spi初始化************************************************/

void spi_init()
{    
	SpiaRegs.SPICCR.all =0x004F;	             			// Reset on, rising edge, 16-bit char bits
	                                             			//0x000F对应Rising Edge，0x004F对应Falling Edge  
	SpiaRegs.SPICTL.all =0x0006;    		     			// Enable master mode, normal phase,
                                                 			// enable talk, and SPI int disabled.
	SpiaRegs.SPIBRR =0x007F;									
    SpiaRegs.SPICCR.all =0x00DF;		         			// Relinquish SPI from Reset   
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


/****************************************Spi模块FIFO设置**********************************************/
void spi_fifo_init()										
{
// Initialize SPI FIFO registers
    SpiaRegs.SPIFFTX.all=0xE040;
    SpiaRegs.SPIFFRX.all=0x204f;
    SpiaRegs.SPIFFCT.all=0x0;
}  

/*****************************************************************************************************/

/*********************************************Spi发送************************************************/

void spi_xmit(Uint16 a)
{
    SpiaRegs.SPITXBUF=a;
}    
/*****************************************************************************************************/
Uint16 spi_rcv(void)
{
	while(SpiaRegs.SPIFFRX.bit.RXFFST !=1) { } 
	Spi_Rcv_Data=SpiaRegs.SPIRXBUF;	
	return Spi_Rcv_Data;
}

void main(void)
{

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

	for(;;)
	{
		
		DisData_Trans(DisData);									//拆分四位数
		for(Loop=0;Loop<4;Loop++)								//分别显示四位
		{
			Sellect_Bit(Loop);									//选择要扫描的数码管位
			spi_xmit(msg[DisData_Bit[Loop]]);					//串行输出要显示的数字
			//scib_xmit(msg[DisData_Bit[Loop]]&0xff);
			delay(25000);										//延时配合人眼反应时间
			scib_xmit(0x55);
		}

		DisData++;												//显示数字自加
		if(DisData > 9999)										//防止溢出 归零
		DisData = 0;
	}


} 	


//===========================================================================
// No more.
//===========================================================================

