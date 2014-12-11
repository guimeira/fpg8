package com.guimeira.chip8;

import java.util.List;
import java.util.Map;

public class GameDescription {
	private String name;
	private String author;
	private String description;
	private List<String> instructions;
	private int slowdown;
	private Map<String,String> mapping;
	
	public String getName() {
		return name;
	}
	
	public void setName(String name) {
		this.name = name;
	}
	
	public String getAuthor() {
		return author;
	}
	
	public void setAuthor(String author) {
		this.author = author;
	}
	
	public String getDescription() {
		return description;
	}
	
	public void setDescription(String description) {
		this.description = description;
	}
	
	public List<String> getInstructions() {
		return instructions;
	}
	
	public void setInstructions(List<String> instructions) {
		this.instructions = instructions;
	}
	
	public int getSlowdown() {
		return slowdown;
	}
	
	public void setSlowdown(int slowdown) {
		this.slowdown = slowdown;
	}
	
	public Map<String, String> getMapping() {
		return mapping;
	}
	
	public void setMapping(Map<String, String> mapping) {
		this.mapping = mapping;
	}
	
	
}
