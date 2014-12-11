package com.guimeira.chip8.gui;

import java.awt.GridLayout;
import java.util.List;

import javax.swing.JPanel;

import com.guimeira.chip8.Game;

public class GameList extends JPanel {
	
	public GameList(List<Game> games) {
		setOpaque(false);
		setLayout(new GridLayout(0, 1));
		buildGameList(games);
	}
	
	private void buildGameList(List<Game> games) {
		for(Game g : games) {
	        add(new GamePanel(g));
		}
	}
}
