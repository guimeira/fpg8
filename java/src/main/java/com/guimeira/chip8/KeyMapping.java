package com.guimeira.chip8;

import java.awt.event.KeyEvent;
import java.util.Map;

public class KeyMapping {
	private int[] mapping;
	
	public KeyMapping(Map<String,String> map) {
		mapping = new int[16];
		
		for(int i = 0; i < 15; i++) {
			String key = Integer.toString(i, 16).toUpperCase();
			String value = map.get(key);
			
			if(value == null) {
				mapping[i] = 0;
				continue;
			}
			
			if(value.equals("arrow-up")) {
				mapping[i] = KeyEvent.VK_UP;
			} else if(value.equals("arrow-down")) {
				mapping[i] = KeyEvent.VK_DOWN;
			} else if(value.equals("arrow-left")) {
				mapping[i] = KeyEvent.VK_LEFT;
			} else if(value.equals("arrow-right")) {
				mapping[i] = KeyEvent.VK_RIGHT;
			} else if(value.equals("space")) {
				mapping[i] = KeyEvent.VK_SPACE;
			} else if(value.equals("ctrl")) {
				mapping[i] = KeyEvent.VK_CONTROL;
			} else if(value.equals("alt")) {
				mapping[i] = KeyEvent.VK_ALT;
			} else if(value.equals("shift")) {
				mapping[i] = KeyEvent.VK_SHIFT;
			} else if(value.equals("enter")) {
				mapping[i] = KeyEvent.VK_ENTER;
			} else if(value.matches("[a-zA-Z]")) {
				mapping[i] = value.toUpperCase().charAt(0);
			} else {
				mapping[i] = 0;
				continue;
			}
		}
	}
	
	public byte map(int keyCode) {
		for(byte i = 0; i < 16; i++) {
			if(mapping[i] == keyCode) {
				return i;
			}
		}
		
		return -1;
	}
}
