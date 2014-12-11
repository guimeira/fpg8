package com.guimeira.chip8.gui;

import java.awt.Font;
import java.awt.GridBagConstraints;
import java.awt.GridBagLayout;
import java.awt.Insets;
import java.awt.KeyEventDispatcher;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.util.Arrays;

import javax.swing.DefaultComboBoxModel;
import javax.swing.JButton;
import javax.swing.JComboBox;
import javax.swing.JLabel;
import javax.swing.JOptionPane;
import javax.swing.JPanel;
import javax.swing.JTextField;
import javax.swing.SwingUtilities;

import jssc.SerialPortException;

import com.guimeira.chip8.Chip8Disassembler;
import com.guimeira.chip8.CommunicationService;
import com.guimeira.chip8.Game;
import com.guimeira.chip8.GameState;

import eu.hansolo.custom.SteelCheckBox;

public class ControllerPanel extends JPanel implements ActionListener, GameState.ConnectionListener, GameState.GameListener, KeyEventDispatcher {
	private JComboBox<String> cmbPorts;
	private DefaultComboBoxModel<String> mdlPorts;
	private JButton btnConnect;
	private JButton btnStop;
	private GamePanel pnlNowPlaying;
	private CommunicationService commService;
	private SteelCheckBox chkDebugger;
	private JTextField txtCurrentInstruction;
	private JTextField txtDisassembled;
	private JTextField txtCurrentPC;
	private JTextField txtCurrentI;
	private JTextField[] txtRegisters;
	private JButton btnStep;
	
	public ControllerPanel() {
		GameState.getInstance().addConnectionListener(this);
		GameState.getInstance().addGameListener(this);
		
		setLayout(new GridBagLayout());
		int row = 0;
		JLabel lblConnection = new JLabel("Connection");
		lblConnection.setFont(lblConnection.getFont().deriveFont(Font.BOLD));
		add(lblConnection, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		mdlPorts = new DefaultComboBoxModel<String>();
		cmbPorts = new JComboBox<String>(mdlPorts);
		
		add(cmbPorts, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		add(new JPanel(), new GridBagConstraints(0,row,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		btnConnect = new JButton("Connect");
		btnConnect.addActionListener(this);
		add(btnConnect, new GridBagConstraints(1,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		JLabel lblNowPlaying = new JLabel("Now playing");
		lblNowPlaying.setFont(lblNowPlaying.getFont().deriveFont(Font.BOLD));
		add(lblNowPlaying, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		pnlNowPlaying = new GamePanel(null);
		add(pnlNowPlaying, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		btnStop = new JButton("Stop");
		btnStop.addActionListener(this);
		btnStop.setEnabled(false);
		add(btnStop, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		chkDebugger = new SteelCheckBox();
		chkDebugger.setText("Debugger"); //necessary to avoid exception
		chkDebugger.setOpaque(false);
		chkDebugger.setEnabled(false);
		chkDebugger.addActionListener(this);
		add(chkDebugger, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		btnStep = new JButton("Step");
		btnStep.addActionListener(this);
		btnStep.setEnabled(false);
		add(btnStep, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		JLabel lblCurrentInstruction = new JLabel("Current instruction");
		lblCurrentInstruction.setFont(lblCurrentInstruction.getFont().deriveFont(Font.PLAIN));
		add(lblCurrentInstruction, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		txtCurrentInstruction = new JTextField();
		txtCurrentInstruction.setEditable(false);
		txtCurrentInstruction.setEnabled(false);
		add(txtCurrentInstruction, new GridBagConstraints(0,row,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		txtDisassembled= new JTextField();
		txtDisassembled.setEditable(false);
		txtDisassembled.setEnabled(false);
		add(txtDisassembled, new GridBagConstraints(1,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		JLabel lblCurrentPC= new JLabel("Program counter");
		lblCurrentPC.setFont(lblCurrentPC.getFont().deriveFont(Font.PLAIN));
		add(lblCurrentPC, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		txtCurrentPC= new JTextField();
		txtCurrentPC.setEditable(false);
		txtCurrentPC.setEnabled(false);
		add(txtCurrentPC, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		JLabel lblCurrentI= new JLabel("Register I");
		lblCurrentI.setFont(lblCurrentInstruction.getFont().deriveFont(Font.PLAIN));
		add(lblCurrentI, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		txtCurrentI= new JTextField();
		txtCurrentI.setEditable(false);
		txtCurrentI.setEnabled(false);
		add(txtCurrentI, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		JLabel lblRegisters= new JLabel("Registers");
		lblRegisters.setFont(lblRegisters.getFont().deriveFont(Font.PLAIN));
		add(lblRegisters, new GridBagConstraints(0,row++,2,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		
		txtRegisters = new JTextField[16];
		for(int i = 0; i < 16; i++) {
			txtRegisters[i] = new JTextField();
			txtRegisters[i].setEditable(false);
			txtRegisters[i].setEnabled(false);
			
			JLabel lblReg = new JLabel("V"+Integer.toString(i,16).toUpperCase());
			lblReg.setFont(lblReg.getFont().deriveFont(Font.PLAIN));
			add(lblReg, new GridBagConstraints(0,row,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
			add(txtRegisters[i], new GridBagConstraints(1,row++,1,1,1,0,GridBagConstraints.CENTER,GridBagConstraints.HORIZONTAL,new Insets(5,5,5,5),0,0));
		}
		
		add(new JPanel(), new GridBagConstraints(0,row++,2,1,1,1,GridBagConstraints.CENTER,GridBagConstraints.BOTH,new Insets(0,0,0,0),0,0));
		
		updatePorts();
	}
	
	protected void updatePorts() {
		String[] ports = CommunicationService.getSerialPorts();
		mdlPorts.removeAllElements();
		Arrays.sort(ports);
		
		for(String s : ports) {
			mdlPorts.addElement(s);
		}
	}
	
	private void connectButtonPressed() {
		if(commService == null) {
			GameState.getInstance().connecting((String)mdlPorts.getSelectedItem());
			try {
				commService = new CommunicationService((String)mdlPorts.getSelectedItem());
				if(!commService.testConnection()) {
					commService = null;
				}
			} catch(SerialPortException ex) {
				commService = null;
			}
			
			if(commService == null) {
				JOptionPane.showMessageDialog(this, "Could not connect to board.", "Information", JOptionPane.INFORMATION_MESSAGE);
				GameState.getInstance().disconnected();
			} else {
				GameState.getInstance().connected((String)mdlPorts.getSelectedItem());
			}
		} else {
			if(GameState.getInstance().getLoadedGame() != null) {
				GameState.getInstance().unloadGame();
			}
			
			if(commService != null) {
				commService.close();
				commService = null;
			}
			
			GameState.getInstance().disconnected();
		}
	}
	
	private void stopButtonPressed() {
		commService.setDebug(false);
		commService.step();
		commService.stopProcessor();
		GameState.getInstance().unloadGame();
	}
	
	private void readDebugInfo() {
		int ir = commService.readIR();
		txtCurrentInstruction.setText(String.format("%04X",ir));
		txtDisassembled.setText(Chip8Disassembler.disassemble(ir));
		
		int i = commService.readI();
		txtCurrentI.setText(String.format("%04X",i));
		
		int pc = commService.readPC();
		txtCurrentPC.setText(String.format("%04X",pc));
		
		int[] regs = commService.readRegisters();
		for(int j = 0; j < 16; j++) {
			txtRegisters[j].setText(String.format("%02X",regs[j]));
		}
	}
	
	private void chkDebuggerChanged() {
		if(chkDebugger.isSelected()) {
			debuggerSetEnabled(true);
			commService.setDebug(true);
			
			if(commService.waitForHalt()) {
				readDebugInfo();
			}
		} else {
			debuggerSetEnabled(false);
			
			if(commService != null) {
				commService.setDebug(false);
				commService.step();
			}
		}
	}
	
	private void stepDebugger() {
		commService.step();
		
		if(commService.waitForHalt()) {
			readDebugInfo();
		}
	}
	
	public void actionPerformed(ActionEvent e) {
		if(e.getSource() == btnConnect) {
			connectButtonPressed();
		} else if(e.getSource() == btnStop) {
			stopButtonPressed();
		} else if(e.getSource() == chkDebugger) {
			chkDebuggerChanged();
		} else if(e.getSource() == btnStep) {
			stepDebugger();
		}
	}

	public void boardConnecting(String port) {
		btnConnect.setEnabled(false);
	}

	public void boardConnected(String port) {
		btnConnect.setText("Disconnect");
		btnConnect.setEnabled(true);
		chkDebugger.setEnabled(true);
	}

	public void boardDisconnected() {
		btnConnect.setText("Connect");
		btnConnect.setEnabled(true);
		chkDebugger.setSelected(false);
		chkDebuggerChanged();
		chkDebugger.setEnabled(false);
	}
	
	private void debuggerSetEnabled(boolean enabled) {
		txtCurrentInstruction.setEnabled(enabled);
		txtDisassembled.setEnabled(enabled);
		txtCurrentPC.setEnabled(enabled);
		txtCurrentI.setEnabled(enabled);
		
		for(int i = 0; i < 16; i++) {
			txtRegisters[i].setEnabled(enabled);
		}
		
		btnStep.setEnabled(enabled);
	}

	public void gameSelected(Game game) {
		// TODO Auto-generated method stub
		
	}

	public void loadGameStart(final Game game) {
		pnlNowPlaying.setGame(game);
		btnStop.setEnabled(true);
		
		if(game != null) {
			new Thread(new Runnable() {
				public void run() {
					commService.setSlowDown(game.getSlowDown());
					if(commService.loadGame(game.getRom())) {
						commService.startProcessor();
						SwingUtilities.invokeLater(new Runnable() {
							public void run() {
								GameState.getInstance().loadGameFinished(game);
							}
						});
					} else {
						SwingUtilities.invokeLater(new Runnable() {
							public void run() {
								GameState.getInstance().loadGame(null);
							}
						});
					}
				}
			}).start();
		}
	}

	public void gameLoaded(Game game) {
		// TODO Auto-generated method stub
		
	}
	
	public void gameUnloaded() {
		commService.setDebug(false);
		commService.step();
		commService.stopProcessor();
		pnlNowPlaying.setGame(null);
		btnStop.setEnabled(false);
	}

	public boolean dispatchKeyEvent(KeyEvent e) {
		int key = e.getKeyCode();
		Game g = GameState.getInstance().getLoadedGame();
		
		if(g != null) {
			byte mapping = g.getMapping().map(key);
			
			if(mapping != -1) {
				if(e.getID() == KeyEvent.KEY_PRESSED) {
					commService.keyPress(mapping);
					return true;
				} else if(e.getID() == KeyEvent.KEY_RELEASED) {
					commService.keyRelease(mapping);
					return true;
				}
			}
		}
		
		return false;
	}
}
