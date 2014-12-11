package com.guimeira.chip8.gui;

import java.awt.BorderLayout;
import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import javax.swing.BoxLayout;
import javax.swing.JButton;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.JTextArea;
import javax.swing.SwingConstants;

import com.guimeira.chip8.Game;
import com.guimeira.chip8.GameState;

public class GameDetailsPanel extends JPanel implements ActionListener, GameState.GameListener, GameState.ConnectionListener {
	private JLabel lblScreenshot;
	private JLabel lblGameName;
	private JLabel lblGameAuthor;
	private JTextArea lblGameDescription;
	private JPanel pnlInstructions;
	private JButton btnPlay;
	
	public GameDetailsPanel() {
		GameState.getInstance().addGameListener(this);
		GameState.getInstance().addConnectionListener(this);
		
		setLayout(new GridBagLayout());
		int row = 0;
		
		lblScreenshot = new JLabel();
		lblScreenshot.setHorizontalAlignment(SwingConstants.CENTER);
		add(lblScreenshot, new GridBagConstraints(0,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5, 5, 5, 5),0,0));
		
		lblGameName = new JLabel();
		lblGameName.setFont(lblGameName.getFont().deriveFont(Font.BOLD, 30));
		lblGameName.setHorizontalAlignment(SwingConstants.CENTER);
		lblGameName.setVerticalAlignment(SwingConstants.CENTER);
		add(lblGameName, new GridBagConstraints(0,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5, 5, 5, 5),0,0));
		
		lblGameAuthor = new JLabel();
		lblGameAuthor.setFont(lblGameAuthor.getFont().deriveFont(Font.ITALIC));
		lblGameAuthor.setHorizontalAlignment(SwingConstants.CENTER);
		lblGameAuthor.setVerticalAlignment(SwingConstants.CENTER);
		add(lblGameAuthor, new GridBagConstraints(0,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5, 5, 5, 5),0,0));
		
		lblGameDescription = new JTextArea();
		lblGameDescription.setWrapStyleWord(true);
		lblGameDescription.setLineWrap(true);
		lblGameDescription.setEditable(false);
		lblGameDescription.setFocusable(false);
		lblGameDescription.setOpaque(false);
		lblGameDescription.setFont(lblGameDescription.getFont().deriveFont(Font.PLAIN));
		add(lblGameDescription, new GridBagConstraints(0,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5, 5, 5, 5),0,0));
		
		JLabel lblInstructions = new JLabel("Instructions");
		lblInstructions.setFont(lblInstructions.getFont().deriveFont(Font.BOLD));
		add(lblInstructions, new GridBagConstraints(0,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5, 5, 5, 5),0,0));
		
		pnlInstructions = new JPanel();
		pnlInstructions.setLayout(new GridBagLayout());
		add(pnlInstructions, new GridBagConstraints(0,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5, 5, 5, 5),0,0));
		
		btnPlay = new JButton("Play!");
		btnPlay.addActionListener(this);
		add(btnPlay, new GridBagConstraints(0,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5, 5, 5, 5),0,0));
		
		add(new JPanel(), new GridBagConstraints(0,row++,1,1,1,1,GridBagConstraints.CENTER,GridBagConstraints.BOTH,new Insets(0, 0, 0, 0),0,0));
	}

	public void loadGameStart(Game game) {
		btnPlay.setEnabled(false);
	}

	public void gameLoaded(Game game) {
		
	}
	
	public void gameUnloaded() {
		btnPlay.setEnabled(true);
	}

	public void gameSelected(Game game) {
		lblScreenshot.setIcon(game.getScreenshot());
		lblGameName.setText(game.getName());
		lblGameAuthor.setText(game.getAuthor());
		lblGameDescription.setText(game.getDescription());
		
		pnlInstructions.removeAll();
		int row = 0;
		for(String s : game.getInstructions()) {
			JLabel lblInst = new JLabel(s);
			lblInst.setFont(lblInst.getFont().deriveFont(Font.PLAIN));
			pnlInstructions.add(lblInst,new GridBagConstraints(0,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.BOTH,new Insets(5, 5, 5, 20),0,0));
		}
		
		btnPlay.setEnabled(GameState.getInstance().isConnected());
		
		revalidate();
		repaint();
	}

	public void boardConnecting(String port) {
		
	}

	public void boardConnected(String port) {
		btnPlay.setEnabled(true);
	}

	public void boardDisconnected() {
		btnPlay.setEnabled(false);
	}

	public void actionPerformed(ActionEvent e) {
		GameState.getInstance().loadGame(GameState.getInstance().getSelectedGame());
	}
}
