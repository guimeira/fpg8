package com.guimeira.chip8;

import java.util.ArrayList;
import java.util.List;

public class GameState {
	private static GameState instance;
	private boolean connected;
	private Game selectedGame;
	private Game loadedGame;
	private List<ConnectionListener> connectionListeners;
	private List<GameListener> gameListeners;
	
	private GameState() {
		connectionListeners = new ArrayList<GameState.ConnectionListener>();
		gameListeners = new ArrayList<GameState.GameListener>();
	}
	
	public static GameState getInstance() {
		if(instance == null) {
			instance = new GameState();
		}
		
		return instance;
	}
	
	public void connecting(String port) {
		for(ConnectionListener l : connectionListeners) {
			l.boardConnecting(port);
		}
	}
	
	public void connected(String port) {
		connected = true;
		for(ConnectionListener l : connectionListeners) {
			l.boardConnected(port);
		}
	}
	
	public void disconnected() {
		connected = false;
		for(ConnectionListener l : connectionListeners) {
			l.boardDisconnected();
		}
	}
	
	public void selectGame(Game game) {
		selectedGame = game;
		for(GameListener l : gameListeners) {
			l.gameSelected(game);
		}
	}
	
	public void loadGame(Game game) {
		for(GameListener l : gameListeners) {
			l.loadGameStart(game);
		}
	}
	
	public void loadGameFinished(Game game) {
		loadedGame = game;
		for(GameListener l : gameListeners) {
			l.gameLoaded(game);
		}
	}
	
	public void unloadGame() {
		loadedGame = null;
		for(GameListener l : gameListeners) {
			l.gameUnloaded();
		}
	}
	
	public boolean isConnected() {
		return connected;
	}
	
	public Game getLoadedGame() {
		return loadedGame;
	}
	
	public Game getSelectedGame() {
		return selectedGame;
	}
	
	public void addConnectionListener(ConnectionListener listener) {
		connectionListeners.add(listener);
	}
	
	public void addGameListener(GameListener listener) {
		gameListeners.add(listener);
	}
	
	public static interface ConnectionListener {
		void boardConnecting(String port);
		void boardConnected(String port);
		void boardDisconnected();
	}
	
	public static interface GameListener {
		void gameSelected(Game game);
		void loadGameStart(Game game);
		void gameLoaded(Game game);
		void gameUnloaded();
	}
}
