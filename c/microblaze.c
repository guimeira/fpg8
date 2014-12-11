#include <stdio.h>
#include "platform.h"
#include "xparameters.h"
#include "xiomodule.h"

void print(char *str);

const u8 fontData[] = {
		//Low resolution fonts taken from
		//http://devernay.free.fr/hacks/chip8/C8TECH10.HTM#font
		//0
		0xF0,0x90,0x90,0x90,0xF0,
		//1
		0x20,0x60,0x20,0x20,0x70,
		//2
		0xF0,0x10,0xF0,0x80,0xF0,
		//3
		0xF0,0x10,0xF0,0x10,0xF0,
		//4
		0x90,0x90,0xF0,0x10,0x10,
		//5
		0xF0,0x80,0xF0,0x10,0xF0,
		//6
		0xF0,0x80,0xF0,0x90,0xF0,
		//7
		0xF0,0x10,0x20,0x40,0x40,
		//8
		0xF0,0x90,0xF0,0x90,0xF0,
		//9
		0xF0,0x90,0xF0,0x10,0xF0,
		//A
		0xF0,0x90,0xF0,0x90,0x90,
		//B
		0xE0,0x90,0xE0,0x90,0xE0,
		//C
		0xF0,0x80,0x80,0x80,0xF0,
		//D
		0xE0,0x90,0x90,0x90,0xE0,
		//E
		0xF0,0x80,0xF0,0x80,0xF0,
		//F
		0xF0,0x80,0xF0,0x80,0x80,
		//High resolution fonts taken from David Winter's Chip-8 emulator
		//http://devernay.free.fr/hacks/chip8/
		//0
		0x3C, 0x7E, 0xC3, 0xC3, 0xC3, 0xC3, 0xC3, 0xC3, 0x7E, 0x3C,
		//1
		0x18, 0x38, 0x58, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x3C,
		//2
		0x3E, 0x7F, 0xC3, 0x06, 0x0C, 0x18, 0x30, 0x60, 0xFF, 0xFF,
		//3
		0x3C, 0x7E, 0xC3, 0x03, 0x0E, 0x0E, 0x03, 0xC3, 0x7E, 0x3C,
		//4
		0x06, 0x0E, 0x1E, 0x36, 0x66, 0xC6, 0xFF, 0xFF, 0x06, 0x06,
		//5
		0xFF, 0xFF, 0xC0, 0xC0, 0xFC, 0xFE, 0x03, 0xC3, 0x7E, 0x3C,
		//6
		0x3E, 0x7C, 0xC0, 0xC0, 0xFC, 0xFE, 0xC3, 0xC3, 0x7E, 0x3C,
		//7
		0xFF, 0xFF, 0x03, 0x06, 0x0C, 0x18, 0x30, 0x60, 0x60, 0x60,
		//8
		0x3C, 0x7E, 0xC3, 0xC3, 0x7E, 0x7E, 0xC3, 0xC3, 0x7E, 0x3C,
		//9
		0x3C, 0x7E, 0xC3, 0xC3, 0x7F, 0x3F, 0x03, 0x03, 0x3E, 0x7C
};

//Constants:
const u8 GPO1_DATA_POSITION = 0;
const u32 GPO1_DATA_BITS = (0xFF << 0);

const u8 GPO1_ADDRESS_POSITION = 8;
const u32 GPO1_ADDRESS_BITS = (0xFFF << 8);

const u8 GPO1_WRITE_POSITION = 20;
const u32 GPO1_WRITE_BIT = (1 << 20);

const u8 GPO1_START_POSITION = 21;
const u32 GPO1_START_BIT = (1 << 21);

const u8 GPO1_STEP_POSITION = 22;
const u32 GPO1_STEP_BIT = (1 << 22);

const u8 GPO1_READREG_POSITION = 23;
const u32 GPO1_READREG_BITS = (0xF << 23);

const u8 GPO1_DEBUG_POSITION = 27;
const u32 GPO1_DEBUG_BIT = (1 << 27);

const u8 GPO2_SLOWDOWN_POSITION = 16;
const u32 GPO2_SLOWDOWN_BITS = (0xFFFF << 16);

const u8 GPI1_MEMBUSY_POSITION = 0;
const u32 GPI1_MEMBUSY_BIT = 1;

const u8 GPI1_STOPPED_POSITION = 1;
const u32 GPI1_STOPPED_BIT = (1 << 1);

const u8 GPI1_REGVAL_POSITION = 2;
const u32 GPI1_REGVAL_BITS = (0xFF << 2);

const u8 GPI1_CURRENTI_POSITION = 10;
const u32 GPI1_CURRENTI_BITS = (0xFFFF << 10);

const u8 GPI2_CURRENTIR_POSITION = 0;
const u32 GPI2_CURRENTIR_BITS = (0xFFFF);

const u8 GPI2_CURRENTPC_POSITION = 16;
const u32 GPI2_CURRENTPC_BITS = (0xFFFF << 16);

const u8 CMD_ECHO = 0x00;
const u8 CMD_LOADGAME = 0x01;
const u8 CMD_SETDEBUG = 0x02;
const u8 CMD_START = 0x03;
const u8 CMD_STOP = 0x04;
const u8 CMD_READREGS = 0x05;
const u8 CMD_READPC = 0x06;
const u8 CMD_READIR = 0x07;
const u8 CMD_READI = 0x08;
const u8 CMD_KEYPRESS = 0x09;
const u8 CMD_KEYRELEASE = 0x0A;
const u8 CMD_SETSLOWDOWN = 0x0B;
const u8 CMD_STEP = 0x0C;
const u8 CMD_WAITHALT = 0x0D;

//Global variables:
XIOModule iomodule;
u8 uartData[4096];
u32 gpo1,gpo2,gpi1,gpi2;

inline void setDataBits(u8 data) {
	gpo1 &= ~GPO1_DATA_BITS;
	gpo1 |= data << GPO1_DATA_POSITION;
}

inline void setAddressBits(u16 address) {
	gpo1 &= ~GPO1_ADDRESS_BITS;
	gpo1 |= address << GPO1_ADDRESS_POSITION;
}

inline void setReadRegBits(u8 reg) {
	gpo1 &= ~GPO1_READREG_BITS;
	gpo1 |= reg << GPO1_READREG_POSITION;
}

inline void setWriteBit(u8 write) {
	gpo1 &= ~GPO1_WRITE_BIT;
	gpo1 |= write << GPO1_WRITE_POSITION;
}

inline void setDebugBit(u8 debug) {
	gpo1 &= ~GPO1_DEBUG_BIT;
	gpo1 |= debug << GPO1_DEBUG_POSITION;
}

inline void setStartBit(u8 start) {
	gpo1 &= ~GPO1_START_BIT;
	gpo1 |= start << GPO1_START_POSITION;
}

inline void setStepBit(u8 step) {
	gpo1 &= ~GPO1_STEP_BIT;
	gpo1 |= step << GPO1_STEP_POSITION;
}

inline u8 getMemoryBusyBit() {
	return (gpi1 & GPI1_MEMBUSY_BIT) >> GPI1_MEMBUSY_POSITION;
}

inline u8 getStoppedBit() {
	return (gpi1 & GPI1_STOPPED_BIT) >> GPI1_STOPPED_POSITION;
}

inline u8 getRegValue() {
	return (gpi1 & GPI1_REGVAL_BITS) >> GPI1_REGVAL_POSITION;
}

inline u16 getIValue() {
	return (gpi1 & GPI1_CURRENTI_BITS) >> GPI1_CURRENTI_POSITION;
}

inline u16 getPcValue() {
	return (gpi2 & GPI2_CURRENTPC_BITS) >> GPI2_CURRENTPC_POSITION;
}

inline u16 getIrValue() {
	return (gpi2 & GPI2_CURRENTIR_BITS) >> GPI2_CURRENTIR_POSITION;
}

inline void setKeyState(u8 key, u8 state) {
	key &= 0xF;
	state &= 1;
	gpo2 &= ~(1 << key);
	gpo2 |= (state << key);
}

inline void setSlowDownBits(u16 slowDown) {
	gpo2 &= ~GPO2_SLOWDOWN_BITS;
	gpo2 |= slowDown << GPO2_SLOWDOWN_POSITION;
}

inline void gpo1Commit() {
	XIOModule_DiscreteWrite(&iomodule,1,gpo1);
}

inline void gpo2Commit() {
	XIOModule_DiscreteWrite(&iomodule,2,gpo2);
}

inline void gpi1Read() {
	gpi1 = XIOModule_DiscreteRead(&iomodule,1);
}

inline void gpi2Read() {
	gpi2 = XIOModule_DiscreteRead(&iomodule,2);
}

void waitForMemory() {
	do {
		gpi1Read();
	} while(getMemoryBusyBit());
}

u8 waitForHalt() {
	u8 tries = 10;

	do {
		gpi1Read();
		tries--;
	} while(!getStoppedBit() && tries);

	if(tries > 0) {
		return 1;
	} else {
		return 0;
	}
}

/**
 * Reads a specified number of bytes from the UART.
 */
void uartRead(u16 numBytes, u8 *data) {
	u16 counter = 0;
	while(counter < numBytes) {
		u16 numRead;
		while((numRead = XIOModule_Recv(&iomodule,data,numBytes-counter)) == 0);
		counter += numRead;
		data += numRead;
	}
}

/**
 * Writes a specified number of bytes to the UART.
 */
void uartWrite(u16 numBytes, u8 *data) {
	u16 counter = 0;
	while(counter < numBytes) {
		u16 numWritten;
		while((numWritten = XIOModule_Send(&iomodule,data,numBytes-counter)) == 0);
		counter += numWritten;
		data += numWritten;
	}
}

/**
 * Echo command handler.
 * Simply echoes back 5 bytes of data to the computer.
 */
void handleEcho() {
	uartRead(5,uartData+1);
	uartData[0] = CMD_ECHO;
	uartWrite(6,uartData);
}

/**
 * LoadGame command handler.
 * Stops the processor and loads a game into the memory.
 */
void handleLoadGame() {
	//Read program size:
	uartRead(2,uartData);
	u16 programSize = (uartData[0] << 8) | uartData[1];

	//Read the program itself:
	uartRead(programSize,uartData);

	u16 currentAddress = 0;
	u16 i;

	//Write the font data:
	for(i = 0; i < sizeof(fontData); i++) {
		setAddressBits(currentAddress);
		setDataBits(fontData[i]);
		setWriteBit(1);
		gpo1Commit();

		waitForMemory();

		setWriteBit(0);
		gpo1Commit();

		currentAddress++;
	}

	//Write the game data:
	currentAddress = 0x200;

	for(i = 0; i < programSize; i++) {
		setAddressBits(currentAddress);
		setDataBits(uartData[i]);
		setWriteBit(1);
		gpo1Commit();

		waitForMemory();

		setWriteBit(0);
		gpo1Commit();

		currentAddress++;
	}

	uartData[0] = CMD_LOADGAME;
	uartWrite(1,uartData);
}

void handleSetDebugMode() {
	uartRead(1,uartData);
	if(uartData[0]) {
		setDebugBit(1);
	} else {
		setDebugBit(0);
	}
	gpo1Commit();
	uartData[0] = CMD_SETDEBUG;
	uartWrite(1,uartData);
}

void handleStartProcessor() {
	setStartBit(1);
	gpo1Commit();
	uartData[0] = CMD_START;
	uartWrite(1,uartData);
}

void handleStopProcessor() {
	setStartBit(0);
	gpo1Commit();
	uartData[0] = CMD_STOP;
	uartWrite(1,uartData);
}

void handleReadRegisters() {
	u8 i;

	for(i = 0; i < 16; i++) {
		setReadRegBits(i);
		gpo1Commit();
		gpi1Read();
		uartData[i] = getRegValue();
	}

	uartData[i] = CMD_READREGS;
	uartWrite(17,uartData);
}

void handleReadPc() {
	gpi2Read();
	u16 pc = getPcValue();
	uartData[0] = (pc >> 8);
	uartData[1] = (pc & 0xFF);
	uartData[2] = CMD_READPC;
	uartWrite(3,uartData);
}

void handleReadIr() {
	gpi2Read();
	u16 ir = getIrValue();
	uartData[0] = (ir >> 8);
	uartData[1] = (ir & 0xFF);
	uartData[2] = CMD_READIR;
	uartWrite(3,uartData);
}

void handleReadI() {
	gpi1Read();
	u16 i = getIValue();
	uartData[0] = (i >> 8);
	uartData[1] = (i & 0xFF);
	uartData[2] = CMD_READI;
	uartWrite(3,uartData);
}

void handleKeyPress() {
	uartRead(1,uartData);
	setKeyState(uartData[0],1);
	gpo2Commit();
	uartData[0] = CMD_KEYPRESS;
	uartWrite(1,uartData);
}

void handleKeyRelease() {
	uartRead(1,uartData);
	setKeyState(uartData[0],0);
	gpo2Commit();
	uartData[0] = CMD_KEYRELEASE;
	uartWrite(1,uartData);
}

void handleSetSlowDown() {
	uartRead(2,uartData);
	setSlowDownBits((uartData[0] << 8) | uartData[1]);
	gpo2Commit();
	uartData[0] = CMD_SETSLOWDOWN;
	uartWrite(1,uartData);
}

void handleStep() {
	setStepBit(1);
	gpo1Commit();
	setStepBit(0);
	gpo1Commit();
	uartData[0] = CMD_STEP;
	uartWrite(1,uartData);
}

void handleWaitForHalt() {
	u8 halt = waitForHalt();
	uartData[0] = halt;
	uartData[1] = CMD_WAITHALT;
	uartWrite(2,uartData);
}

void (*handlers[])() = {
		handleEcho,
		handleLoadGame,
		handleSetDebugMode,
		handleStartProcessor,
		handleStopProcessor,
		handleReadRegisters,
		handleReadPc,
		handleReadIr,
		handleReadI,
		handleKeyPress,
		handleKeyRelease,
		handleSetSlowDown,
		handleStep,
		handleWaitForHalt
};

int main()
{
    init_platform();
    XIOModule_Initialize(&iomodule,XPAR_IOMODULE_0_DEVICE_ID);
    XIOModule_Start(&iomodule);
    XIOModule_CfgInitialize(&iomodule,NULL,1);

    while(1) {
    	//Read command from computer:
    	uartRead(1,uartData);

    	//If it's a known command, execute it:
    	if(uartData[0] < sizeof(handlers)) {
    		handlers[uartData[0]]();
    	}
    }

    return 0;
}
