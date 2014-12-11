package com.guimeira.chip8.gui;

import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseListener;

import javax.swing.BorderFactory;
import javax.swing.JLabel;
import javax.swing.JPanel;
import javax.swing.SwingConstants;

import com.guimeira.chip8.Game;
import com.guimeira.chip8.GameState;

public class GamePanel extends JPanel implements MouseListener {
	private Game game;
	private JLabel lblLogo;
	private JLabel lblName;
	private JLabel lblAuthor;
	
	public GamePanel(Game game) {
		this.game = game;
		setLayout(new GridBagLayout());
		int row = 0;
		
		lblLogo = new JLabel();
		add(lblLogo, new GridBagConstraints(0,0,1,2,0,1,GridBagConstraints.CENTER, GridBagConstraints.NONE, new Insets(5,5,5,5),0,0));
		
		lblName = new JLabel();
		lblName.setFont(lblName.getFont().deriveFont(lblName.getFont().getStyle() | Font.BOLD));
		lblName.setVerticalAlignment(SwingConstants.BOTTOM);
		add(lblName, new GridBagConstraints(1,row++,1,1,1,1,GridBagConstraints.LINE_START, GridBagConstraints.BOTH, new Insets(5,5,2,5),0,0));
		
		lblAuthor = new JLabel();
		lblAuthor.setFont(lblName.getFont().deriveFont(Font.PLAIN));
		lblAuthor.setVerticalAlignment(SwingConstants.TOP);
		add(lblAuthor, new GridBagConstraints(1,row++,1,1,1,1,GridBagConstraints.LINE_START, GridBagConstraints.BOTH, new Insets(2,5,5,5),0,0));
		
		addMouseListener(this);
		
		setGame(game);
	}
	
	public void setGame(Game game) {
		this.game = game;
		
		if(game != null) {
			lblLogo.setIcon(game.getLogo());
			lblName.setText(game.getName());
			lblAuthor.setText(game.getAuthor());
		} else {
			lblLogo.setIcon(null);
			lblName.setText("-no game loaded-");
			lblAuthor.setText("");
		}
	}

	public void mouseClicked(MouseEvent e) {
		GameState.getInstance().selectGame(game);
	}

	public void mousePressed(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	public void mouseReleased(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	public void mouseEntered(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}

	public void mouseExited(MouseEvent e) {
		// TODO Auto-generated method stub
		
	}
}
