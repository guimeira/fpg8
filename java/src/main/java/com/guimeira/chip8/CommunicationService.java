package com.guimeira.chip8;

import java.util.Random;

import jssc.SerialPort;
import jssc.SerialPortException;
import jssc.SerialPortList;

public class CommunicationService {
	private SerialPort serialPort;
	private static final byte CMD_ECHO = 0x00;
	private static final byte CMD_LOAD_GAME = 0x01;
	private static final byte CMD_SET_DEBUG = 0x02;
	private static final byte CMD_START = 0x03;
	private static final byte CMD_STOP = 0x04;
	private static final byte CMD_READ_REGS = 0x05;
	private static final byte CMD_READ_PC = 0x06;
	private static final byte CMD_READ_IR = 0x07;
	private static final byte CMD_READ_I = 0x08;
	private static final byte CMD_KEY_PRESS = 0x09;
	private static final byte CMD_KEY_RELEASE = 0x0A;
	private static final byte CMD_SET_SLOW_DOWN = 0x0B;
	private static final byte CMD_STEP = 0x0C;
	private static final byte CMD_WAIT_HALT = 0x0D;
	
	public CommunicationService(String portName) throws SerialPortException {
		serialPort = new SerialPort(portName);
		serialPort.openPort();
		serialPort.setParams(SerialPort.BAUDRATE_9600, SerialPort.DATABITS_8, SerialPort.STOPBITS_1, SerialPort.PARITY_NONE);
	}
	
	public static String[] getSerialPorts() {
		return SerialPortList.getPortNames();
	}
	
	public boolean testConnection() {
		try {
			byte[] bytes = new byte[5];
			new Random().nextBytes(bytes);
			serialPort.writeByte(CMD_ECHO);
			serialPort.writeBytes(bytes);
			byte[] response = serialPort.readBytes(6);
			
			if(response[0] == CMD_ECHO) {
				for(int i = 0; i < 5; i++) {
					if(response[i+1] != bytes[i]) {
						return false;
					}
				}
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean loadGame(byte[] game) {
		try {
			//Write the command:
			serialPort.writeByte(CMD_LOAD_GAME);
			
			//Write the game size using two bytes:
			int gameSize = game.length;
			serialPort.writeByte((byte)((gameSize >>> 8) & 0xFF));
			serialPort.writeByte((byte)(gameSize & 0xFF));
			
			//Write the game:
			serialPort.writeBytes(game);
			
			byte[] answer = serialPort.readBytes(1);
			
			if(answer[0] == CMD_LOAD_GAME) {
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean setDebug(boolean enabled) {
		try {
			//Write the command:
			serialPort.writeByte(CMD_SET_DEBUG);
			
			//Write the value:
			serialPort.writeByte(enabled ? (byte)1 : (byte)0);
			
			byte[] answer = serialPort.readBytes(1);
			
			if(answer[0] == CMD_SET_DEBUG) {
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean startProcessor() {
		try {
			//Write the command:
			serialPort.writeByte(CMD_START);
			
			byte[] answer = serialPort.readBytes(1);
			
			if(answer[0] == CMD_START) {
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean stopProcessor() {
		try {
			//Write the command:
			serialPort.writeByte(CMD_STOP);
			
			byte[] answer = serialPort.readBytes(1);
			
			if(answer[0] == CMD_STOP) {
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public int[] readRegisters() {
		try {
			//Write the command:
			serialPort.writeByte(CMD_READ_REGS);
			
			byte[] answer = serialPort.readBytes(17);
			
			if(answer[16] == CMD_READ_REGS) {
				int[] ret = new int[16];
				for(int i = 0; i < 16; i++) {
					ret[i] = answer[i] & 0xFF;
				}
				return ret;
			} else {
				return null;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return null;
		}
	}
	
	public int readPC() {
		try {
			//Write the command:
			serialPort.writeByte(CMD_READ_PC);
			
			byte[] answer = serialPort.readBytes(3);
			
			if(answer[2] == CMD_READ_PC) {
				int ret = ((answer[0]&0xFF) << 8) | (answer[1]&0xFF);
				return ret;
			} else {
				return -1;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return -1;
		}
	}
	
	public int readIR() {
		try {
			//Write the command:
			serialPort.writeByte(CMD_READ_IR);
			
			byte[] answer = serialPort.readBytes(3);
			
			if(answer[2] == CMD_READ_IR) {
				int ret = ((answer[0]&0xFF) << 8) | (answer[1]&0xFF);
				return ret;
			} else {
				return -1;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return -1;
		}
	}
	
	public int readI() {
		try {
			//Write the command:
			serialPort.writeByte(CMD_READ_I);
			
			byte[] answer = serialPort.readBytes(3);
			
			if(answer[2] == CMD_READ_I) {
				int ret = ((answer[0]&0xFF) << 8) | (answer[1]&0xFF);
				return ret;
			} else {
				return -1;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return -1;
		}
	}
	
	public boolean keyPress(byte key) {
		try {
			//Write the command:
			serialPort.writeByte(CMD_KEY_PRESS);
			
			//Write the key:
			serialPort.writeByte(key);
			
			byte[] answer = serialPort.readBytes(1);
			
			if(answer[0] == CMD_KEY_PRESS) {
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean keyRelease(byte key) {
		try {
			//Write the command:
			serialPort.writeByte(CMD_KEY_RELEASE);
			
			//Write the key:
			serialPort.writeByte(key);
			
			byte[] answer = serialPort.readBytes(1);
			
			if(answer[0] == CMD_KEY_RELEASE) {
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean setSlowDown(int slowDown) {
		try {
			//Write the command:
			serialPort.writeByte(CMD_SET_SLOW_DOWN);
			
			serialPort.writeByte((byte)((slowDown >>> 8) & 0xFF));
			serialPort.writeByte((byte)(slowDown & 0xFF));
			
			byte[] answer = serialPort.readBytes(1);
			
			if(answer[0] == CMD_SET_SLOW_DOWN) {
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean step() {
		try {
			//Write the command:
			serialPort.writeByte(CMD_STEP);
			
			byte[] answer = serialPort.readBytes(1);
			
			if(answer[0] == CMD_STEP) {
				return true;
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean waitForHalt() {
		try {
			//Write the command:
			serialPort.writeByte(CMD_WAIT_HALT);
			
			byte[] answer = serialPort.readBytes(2);
			
			if(answer[1] == CMD_WAIT_HALT) {
				if(answer[0] == 1) {
					return true;
				} else {
					return false;
				}
			} else {
				return false;
			}
		} catch(SerialPortException e) {
			e.printStackTrace();
			return false;
		}
	}
	
	public boolean close() {
		try {
			serialPort.closePort();
			return true;
		} catch(Exception e) {
			return false;
		}
	}
}
