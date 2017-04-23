package;

import kha.Framebuffer;
import kha.System;
import kha.Scaler;
import kha.Color;
import kha.Image;
import kha.input.Keyboard;
import kha.Key;
import kha.math.Random;
import kha.Assets;
import kha.audio1.Audio;

class Project {

	private static var bgColor = Color.fromValue(0x26004d);
	
	public static inline var WIDTH = 800;
	public static inline var HEIGHT = 600;
	
	private static var numAsteroids = 8;

	private var backbuffer: Image;

	private var asteroids: Array<Asteroid>;
	private var projectiles: Array<Projectile>;
	private var player: Player;

	private var score: Int;
	private var lives: Int;

	private var escapePressed: Bool;
	private var leftPressed: Bool;
	private var rightPressed: Bool;
	private var upPressed: Bool;
	private var downPressed: Bool;
	private var firePressed: Bool;
	private var fireReleased: Bool;

	private var gameLost: Bool = false;
	
	public function new() {
		Random.init(Std.int(System.time * 1000));
		if (Keyboard.get() != null) Keyboard.get().notify(keyDown, keyUp);

		this.backbuffer = Image.createRenderTarget(WIDTH, HEIGHT);
		this.score = 0;
		this.lives = 3;
		this.player = new Player(WIDTH/2.0, HEIGHT/2.0);
		this.projectiles = new Array();
		this.asteroids = generateAsteroids();
	}

	function generateAsteroids(): Array<Asteroid>{
		var as = new Array();
		for(i in 0...numAsteroids){
			as.push(new Asteroid(
				Random.getUpTo(WIDTH), 
				Random.getUpTo(HEIGHT), 
				Random.getIn(5, 20), 
				Random.getIn(30, 50)));
		}
		return as;		
	}

	function keyUp(key: Key, char: String): Void {
		switch (key) {
			case UP:
				upPressed = false;
			case DOWN:
				downPressed = false;
			case LEFT:
				leftPressed = false;
			case RIGHT:
				rightPressed = false;
			case ESC:
				escapePressed = true;
			case CTRL:
				fireReleased = true;
			default: return;
		}
	}

	function keyDown(key: Key, char: String): Void {
		switch (key) {
			case UP:
				upPressed = true;
			case DOWN:
				downPressed = true;
			case LEFT:
				leftPressed = true;
			case RIGHT:
				rightPressed = true;
			case CTRL:
				firePressed = true;
			case ESC:
				escapePressed = true;
			default: return;
		}
	}

	function handlePlayerAsteroidCollision(asteroid: Asteroid): Void {
		if(!asteroid.checkCollision(player.center, 10.0)) return;
		Audio.play(Assets.sounds.death, false);
		lives -= 1;
		asteroid.visible = false;
		this.player = new Player(WIDTH/2.0,HEIGHT/2.0);
		if(lives < 1){
			this.gameLost = true;
		}
	}

	function handleProjectileAsteroidCollision(projectile: Projectile, asteroid: Asteroid){
		if(!asteroid.checkCollision(projectile.center)) return;

		Audio.play(Assets.sounds.impact, false);
							
		asteroid.visible = false;
		projectile.toDelete = true;

		//score
		if(asteroid.radius > 40.0) score += 20;
		if(asteroid.radius > 20.0 && asteroid.radius < 40.0) score += 50;
		if(asteroid.radius < 20.0) score += 100;

		//spawn smaller asteroids - 2 chunks
		if(asteroid.radius < 10.0) return;
		var as1 = new Asteroid(asteroid.center.x, asteroid.center.y,
			asteroid.points-1, asteroid.radius/2.0);
		var as2 = new Asteroid(asteroid.center.x, asteroid.center.y,
			asteroid.points-1, asteroid.radius/2.0);
		as2.velocity.x = -as2.velocity.x;
		as2.velocity.y = -as2.velocity.y;
		asteroids.push(as1);
		asteroids.push(as2);	
	}


	//TODO refactor this method
	public function update(): Void {
		
		//esc to quit
		if(escapePressed){
			System.requestShutdown();
			return;
		}

		//game is lost, stop updating
		if(gameLost) return;

		//filter invisible asteroids
		asteroids = asteroids.filter(function (e) return e.visible);
		if(asteroids.length < 1){
			asteroids = generateAsteroids();
		}

		//update asteroids
		for(asteroid in asteroids){
			asteroid.update();

			for(projectile in projectiles){
				handleProjectileAsteroidCollision(projectile, asteroid);
			}
			handlePlayerAsteroidCollision(asteroid);
		}
		
		//update player
		player.update();

		//update and delete projectiles out of screen
		projectiles = projectiles.filter(function (e) return !e.toDelete);
		for(p in projectiles){
			p.update();
		}
		
		//handle controls
		if(leftPressed){
			player.rotate(-5.0);
		}
		if(rightPressed){
			player.rotate(5.0);
		}
		if(upPressed){
			player.accelerate(0.1);
		}
		if(downPressed){
			player.accelerate(-0.1);
		}
		if(firePressed && fireReleased){
			Audio.play(Assets.sounds.laser, false);
			projectiles.push(new Projectile(player));
			firePressed = false;
			fireReleased = false;
		}

	}

	public function render(framebuffer: Framebuffer): Void {

		var g = backbuffer.g2;
    
		// clear our backbuffer using graphics2
		g.begin(bgColor);
		g.color = Color.White;
		for(asteroid in asteroids){
			asteroid.render(g);
		}
		for(projectile in projectiles){
			projectile.render(g);
		}
		player.render(g);

		g.font = Assets.fonts.LiberationSans_Regular;
    	g.fontSize = 25;
		g.drawString("score: " + score, 10, 10);
		g.drawString("lives: " + lives, 10, 40);

		if(gameLost){
			g.drawString("GAME OVER!", WIDTH/2 - 75, HEIGHT/2 - 50);
		}

		g.end();

    	// draw our backbuffer onto the active framebuffer
    	framebuffer.g2.begin();
    	Scaler.scale(backbuffer, framebuffer, System.screenRotation);
    	framebuffer.g2.end();
	}
	
}
