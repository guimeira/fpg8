package com.guimeira.chip8;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.util.List;
import java.util.Scanner;

import javax.swing.SwingUtilities;
import javax.swing.UIManager;
import javax.swing.UnsupportedLookAndFeelException;

import com.guimeira.chip8.gui.MainWindow;

/**
 * Hello world!
 *
 */
public class App 
{
    public static void main( String[] args ) throws Exception
    {
        /*CommunicationService cs = new CommunicationService("/dev/ttyUSB0");
        
        boolean testConn = cs.testConnection();
        if(testConn) {
        	System.out.println("Connection is ok");
        } else {
        	System.out.println("Connection is not ok");
        	System.exit(1);
        }
        
        BufferedInputStream is = new BufferedInputStream(new FileInputStream(new File("/home/guimeira/Downloads/Chip-8 Games/Blinky [Hans Christian Egeberg, 1991].ch8")));
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
        
        System.out.println("Configuring slowdown...");
        if(cs.setSlowDown(0xFFFF)) {
       //if(cs.setSlowDown(0)) {
        	System.out.println("Slowdown configured successfully!");
        } else {
        	System.out.println("Failed to configure slowdown.");
        	System.exit(1);
        }
        
        System.out.println("Enabling debug...");
        if(cs.setDebug(true)) {
        	System.out.println("Debug enabled successfully!");
        } else {
        	System.out.println("Failed to enable debug.");
        	System.exit(1);
        }
        
        System.out.println("Loading game...");
        cs.loadGame(game);
        System.out.println("Game loaded! Starting processor...");
        cs.startProcessor();
        System.out.println("Processor started!");
        
        Scanner in = new Scanner(System.in);
        
        while(true) {
        	System.out.println("Waiting for processor to halt...");
        	if(!cs.waitForHalt()) {
        		System.out.println("Processor refuses to halt.");
        		System.exit(1);
        	}
        	
        	int[] registers = cs.readRegisters();
        	for(int i = 0; i < 16; i++) {
        		System.out.printf("Reg[%x] = %02x\n",i,registers[i]);
        	}
        	
        	System.out.printf("PC = %04x\n",cs.readPC());
        	System.out.printf("IR = %04x\n",cs.readIR());
        	System.out.printf("I = %04x\n",cs.readI());
        	
        	String line = in.nextLine();
        	if(line.equals("x")) {
        		break;
        	}
        	
        	cs.step();
        }
        cs.close();
        in.close();*/
    	
    	final List<Game> games = Game.loadGames(new File("games/"));
    	
    	SwingUtilities.invokeLater(new Runnable() {
			
			public void run() {
				//Enable WebLookAndFeel:
				//WebLookAndFeel.install();
				//WebLookAndFeel.setDecorateAllWindows(true);
				try {
					UIManager.setLookAndFeel("com.jtattoo.plaf.hifi.HiFiLookAndFeel");
				} catch (Exception e) {
					e.printStackTrace();
				}
				new MainWindow(games);
			}
		});
    }
}
