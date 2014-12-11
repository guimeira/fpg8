package com.guimeira.chip8;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;

public class Chip8Disassembler {
	public static String disassemble(int instruction) {
		int opcode = instruction >> 12;
		int reg1 = (instruction >> 8) & 0xF;
		int reg2 = (instruction >> 4) & 0xF;
		int byteParam = instruction & 0xFF;
		int nibbleParam = instruction & 0xF;
		int bigParam = instruction & 0xFFF;
		
		switch(opcode) {
			case 0x0:
				switch(bigParam) {
					case 0x0E0:
						return "CLS";
					
					case 0x0EE:
						return "RET";
						
					case 0x0FB:
						return "(S) SCR";
						
					case 0x0FC:
						return "(S) SCL";
						
					case 0x0FD:
						return "(S) EXIT";
						
					case 0x0FE:
						return "(S) LOW";
						
					case 0x0FF:
						return "(S) HIGH";
						
					default:
						if(reg2 == 0xC) {
							return String.format("(S) SCD %01X",nibbleParam);
						}
				}
				break;
				
			case 0x1:
				return String.format("JP %03X",bigParam);
				
			case 0x2:
				return String.format("CALL %03X",bigParam);
				
			case 0x3:
				return String.format("SE V%01X,%02X",reg1,byteParam);
				
			case 0x4:
				return String.format("SNE V%01X,%02X",reg1,byteParam);
				
			case 0x5:
				switch(nibbleParam) {
					case 0x0:
						return String.format("SE V%01X,V%01X",reg1,reg2);
				}
				break;
				
			case 0x6:
				return String.format("LD V%01X,%02X",reg1,byteParam);
				
			case 0x7:
				return String.format("ADD V%01X,%02X",reg1,byteParam);
				
			case 0x8:
				switch(nibbleParam) {
					case 0x0:
						return String.format("LD V%01X,V%01X",reg1,reg2);
						
					case 0x1:
						return String.format("OR V%01X,V%01X",reg1,reg2);
						
					case 0x2:
						return String.format("AND V%01X,V%01X",reg1,reg2);
						
					case 0x3:
						return String.format("XOR V%01X,V%01X",reg1,reg2);
						
					case 0x4:
						return String.format("ADD V%01X,V%01X",reg1,reg2);
						
					case 0x5:
						return String.format("SUB V%01X,V%01X",reg1,reg2);
						
					case 0x6:
						return String.format("SHR V%01X",reg1);
						
					case 0x7:
						return String.format("SUBN V%01X,V%01X",reg1,reg2);
						
					case 0xE:
						return String.format("SHL V%01X",reg1);
				}
				break;
				
			case 0x9:
				switch(nibbleParam) {
					case 0x0:
						return String.format("SNE V%01X,V%01X",reg1,reg2);
				}
				break;
				
			case 0xA:
				return String.format("LD I,%03X",bigParam);
				
			case 0xB:
				return String.format("JP V0,%03X",bigParam);
				
			case 0xC:
				return String.format("RND V%01X,%02X",reg1,byteParam);
				
			case 0xD:
				switch(nibbleParam) {
					case 0x0:
						return String.format("(S) DRW V%01X,V%01X,0",reg1,reg2);
						
					default:
						return String.format("DRW V%01X,V%01X,%01X",reg1,reg2,nibbleParam);
				}
				
			case 0xE:
				switch(byteParam) {
					case 0x9E:
						return String.format("SKP V%01X",reg1);
						
					case 0xA1:
						return String.format("SKNP V%01X",reg1);
				}
				break;
				
			case 0xF:
				switch(byteParam) {
					case 0x07:
						return String.format("LD V%01X,DT",reg1);
						
					case 0x0A:
						return String.format("LD V%01X,K",reg1);
						
					case 0x15:
						return String.format("LD DT,V%01X",reg1);
						
					case 0x18:
						return String.format("LD ST,V%01X",reg1);
						
					case 0x1E:
						return String.format("ADD I,V%01X",reg1);
						
					case 0x29:
						return String.format("LD F,V%01X",reg1);
						
					case 0x33:
						return String.format("LD B,V%01X",reg1);
						
					case 0x55:
						return String.format("LD [I],V%01X",reg1);
						
					case 0x65:
						return String.format("LD V%01X,[I]",reg1);
						
					case 0x30:
						return String.format("(S) LD HF,V%01X",reg1);
						
					case 0x75:
						return String.format("(S) LD R,V%01X",reg1);
						
					case 0x85:
						return String.format("(S) LD V%01X,R",reg1);
				}
				break;
		}
		
		return "???";
	}
	
	public static void main(String[] args) throws Exception {
		byte[] data = new byte[2];
		int address = 0x200;
		while(System.in.read(data) != -1) {
			int instruction = (data[0]&0xFF) << 8 | (data[1]&0xFF);
			System.out.printf("[%04X] %04X: %s\n",address,instruction,disassemble(instruction));
			address += 2;
		}
	}
}
