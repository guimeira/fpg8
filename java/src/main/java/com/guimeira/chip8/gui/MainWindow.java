package com.guimeira.chip8.gui;

import java.awt.BorderLayout;
import java.awt.KeyboardFocusManager;
import java.util.List;

import javax.imageio.ImageIO;
import javax.swing.BorderFactory;
import javax.swing.ImageIcon;
import javax.swing.JFrame;
import javax.swing.JLabel;
import javax.swing.JScrollPane;
import javax.swing.border.BevelBorder;

import com.guimeira.chip8.Game;
import com.guimeira.chip8.GameState;

public class MainWindow extends JFrame implements GameState.ConnectionListener, GameState.GameListener {
	private List<Game> games;
	private GameDetailsPanel gameDetails;
	private ControllerPanel controllerPanel;
	private JLabel lblStatus;
	
	public MainWindow(List<Game> games) {
		GameState.getInstance().addConnectionListener(this);
		GameState.getInstance().addGameListener(this);
		
		setLayout(new BorderLayout());
		
		try {
			setIconImage(ImageIO.read(getClass().getResourceAsStream("/com/guimeira/chip8/resources/icon.png")));
		} catch(Exception e) {
			e.printStackTrace();
		}
		
		GameList gameList = new GameList(games);
		JScrollPane scrollList = new JScrollPane(gameList);
		gameList.setBorder(BorderFactory.createEmptyBorder(0,0,0,scrollList.getVerticalScrollBar().getWidth()));
		scrollList.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
		scrollList.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		add(scrollList, BorderLayout.WEST);
		
		gameDetails = new GameDetailsPanel();
		JScrollPane scrollDetails = new JScrollPane(gameDetails);
		gameDetails.setBorder(BorderFactory.createEmptyBorder(0,0,0,scrollDetails.getVerticalScrollBar().getWidth()));
		scrollDetails.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
		scrollDetails.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		add(scrollDetails, BorderLayout.CENTER);
		
		lblStatus = new JLabel("Disconnected");
		lblStatus.setBorder(new BevelBorder(BevelBorder.LOWERED));
		add(lblStatus, BorderLayout.SOUTH);
		
		controllerPanel = new ControllerPanel();
		JScrollPane scrollController = new JScrollPane(controllerPanel);
		controllerPanel.setBorder(BorderFactory.createEmptyBorder(0,0,0,scrollController.getVerticalScrollBar().getWidth()));
		scrollController.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_NEVER);
		scrollController.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		add(scrollController, BorderLayout.EAST);
		
		KeyboardFocusManager.getCurrentKeyboardFocusManager().addKeyEventDispatcher(controllerPanel);
		
		GameState.getInstance().selectGame(games.get(0));
		
		pack();
		setExtendedState(MAXIMIZED_BOTH);
		setTitle("FPG-8");
		setDefaultCloseOperation(EXIT_ON_CLOSE);
		setVisible(true);
	} 
	
	public void boardConnecting(String port) {
		lblStatus.setText("Connecting to "+port+"...");
	}

	public void boardConnected(String port) {
		lblStatus.setText("Connected to "+port);
	}

	public void boardDisconnected() {
		lblStatus.setText("Disconnected");
	}

	public void gameSelected(Game game) {
		
	}

	public void loadGameStart(Game game) {
		lblStatus.setText("Loading "+game.getName()+"...");
	}

	public void gameLoaded(Game game) {
		lblStatus.setText("Game "+game.getName()+" loaded!");
	}
	
	public void gameUnloaded() {
		lblStatus.setText("Game unloaded");
	}
}
