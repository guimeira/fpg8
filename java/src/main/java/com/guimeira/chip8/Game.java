package com.guimeira.chip8;

import java.awt.Image;
import java.awt.image.BufferedImage;
import java.io.BufferedInputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.List;
import java.util.zip.ZipEntry;
import java.util.zip.ZipFile;

import javax.imageio.ImageIO;
import javax.swing.ImageIcon;

import com.fasterxml.jackson.databind.ObjectMapper;

public class Game implements Comparable<Game> {
	private String name;
	private String author;
	private String description;
	private List<String> instructions;
	private int slowDown;
	private KeyMapping mapping;
	private byte[] rom;
	private ImageIcon screenshot;
	private ImageIcon logo;
	private static ObjectMapper mapper = new ObjectMapper();
	
	public Game(String name, String author, String description, List<String> instructions, int slowDown, KeyMapping mapping, byte[] rom, BufferedImage screenshot, BufferedImage logo) {
		this.name = name;
		this.author = author;
		this.description = description;
		this.instructions = instructions;
		this.slowDown = slowDown;
		this.mapping = mapping;
		this.rom = rom;
		this.screenshot = new ImageIcon(screenshot);
		this.logo = new ImageIcon(logo.getScaledInstance(70, 70, Image.SCALE_SMOOTH));
	}
	
	public static List<Game> loadGames(File directory) {
		List<Game> games = new ArrayList<Game>();
		
		if(!directory.exists() || !directory.isDirectory()) {
			return games;
		}
		
		for(File f : directory.listFiles()) {
			if(f.getName().endsWith(".zip")) {
				try {
					Game g = loadGame(f);
					if(g != null) {
						games.add(g);
					}
				} catch(IOException e) {
					e.printStackTrace();
				}
			}
		}
		
		Collections.sort(games);
		return games;
	}
	
	private static Game loadGame(File game) throws IOException {
		ZipFile zipFile = new ZipFile(game);
		Enumeration<? extends ZipEntry> entries = zipFile.entries();
		String name = null, author = null, description = null;
		List<String> instructions = null;
		int slowDown = 0;
		byte[] rom = null;
		BufferedImage screenshot = null,logo = null;
		KeyMapping mapping = null;
		
		while(entries.hasMoreElements()) {
			ZipEntry entry = entries.nextElement();
			if(!entry.isDirectory()) {
				if(entry.getName().equals("rom.ch8")) {
					rom = loadRom(zipFile.getInputStream(entry));
				} else if(entry.getName().equals("screenshot.png")) {
					screenshot = ImageIO.read(zipFile.getInputStream(entry));
				} else if(entry.getName().equals("logo.png")) {
					logo = ImageIO.read(zipFile.getInputStream(entry));
				} else if(entry.getName().equals("description.json")) {
					GameDescription gameDescription = mapper.readValue(zipFile.getInputStream(entry), GameDescription.class);
					name = gameDescription.getName();
					author = gameDescription.getAuthor();
					description = gameDescription.getDescription();
					instructions = gameDescription.getInstructions();
					slowDown = gameDescription.getSlowdown();
					mapping = new KeyMapping(gameDescription.getMapping());
				}
			}
		}
		
		zipFile.close();
		
		if(name != null && author != null && description != null && instructions != null && mapping != null && rom != null && screenshot != null && logo != null) {
			Game g = new Game(name, author, description, instructions, slowDown, mapping, rom, screenshot, logo);
			return g;
		}
		
		return null;
	}
	
	private static byte[] loadRom(InputStream input) throws IOException {
		BufferedInputStream is = new BufferedInputStream(input);
        int bufferSize = 4096;
        byte[] buffer = new byte[bufferSize];
        int pos = 0;
        int read = 0;
        while((read = is.read(buffer,pos,bufferSize-pos)) != -1) {
        	pos += read;
        }
        is.close();
        byte[] game = new byte[pos];
        System.arraycopy(buffer, 0, game, 0, pos);
        return game;
	}

	public int compareTo(Game o) {
		return name.compareTo(o.getName());
	}

	//Getters:
	public String getName() {
		return name;
	}

	public String getAuthor() {
		return author;
	}

	public String getDescription() {
		return description;
	}

	public List<String> getInstructions() {
		return instructions;
	}

	public int getSlowDown() {
		return slowDown;
	}

	public KeyMapping getMapping() {
		return mapping;
	}

	public byte[] getRom() {
		return rom;
	}

	public ImageIcon getScreenshot() {
		return screenshot;
	}

	public ImageIcon getLogo() {
		return logo;
	}

	public static ObjectMapper getMapper() {
		return mapper;
	}
}
