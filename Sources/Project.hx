package;

import kha.Framebuffer;
import kha.Scheduler;
import kha.System;
import kha.Scaler;
import kha.Color;
import kha.Image;
import kha.input.Keyboard;
import kha.Key;
import kha.math.Random;
import kha.Assets;

class Project {

	private static var bgColor = Color.fromValue(0x26004d);
	public static inline var screenWidth = 800;
	public static inline var screenHeight = 600;
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
	
	public function new() {
		Random.init(Std.int(System.time * 1000));
		if (Keyboard.get() != null) Keyboard.get().notify(keyDown, keyUp);

		this.backbuffer = Image.createRenderTarget(screenWidth, screenHeight);
		this.score = 0;
		this.lives = 3;
		this.player = new Player(screenWidth/2.0, screenHeight/2.0);
		this.projectiles = new Array();
		this.asteroids = generateAsteroids();
		
		Assets.loadEverything(function () {
			System.notifyOnRender(render);
			Scheduler.addTimeTask(update, 0, 1 / 60);
		});
	}

	function generateAsteroids(): Array<Asteroid>{
		var as = new Array();
		for(i in 0...numAsteroids){
			as.push(new Asteroid(
				Random.getUpTo(screenWidth), 
				Random.getUpTo(screenHeight), 
				Random.getIn(5, 20), 
				Random.getIn(30, 80)));
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

	function update(): Void {
		//update asteroid
		for(asteroid in asteroids){
			asteroid.update();

			//check collision of asteroid with projectile
			for(projectile in projectiles){
				if(asteroid.checkCollision(projectile.center)){
					
					asteroid.visible = false;
					projectile.toDelete = true;

					//score
					if(asteroid.radius > 40.0) score += 20;
					if(asteroid.radius > 20.0 && asteroid.radius < 40.0) score += 50;
					if(asteroid.radius < 20.0) score += 100;
					

					//spawn smaller asteroids - chunks
					if(asteroid.radius < 10.0) continue;
					var as1 = new Asteroid(asteroid.center.x, asteroid.center.y,
						asteroid.points-1, asteroid.radius/2.0);
					var as2 = new Asteroid(asteroid.center.x, asteroid.center.y,
						asteroid.points-1, asteroid.radius/2.0);
					as2.velocity.x = -as2.velocity.x;
					as2.velocity.y = -as2.velocity.y;
					asteroids.push(as1);
					asteroids.push(as2);
				}
			}

			//check collision of asteroid and player (checking each vertex of player)
			if(asteroid.checkCollision(player.center, 20.0)){
				lives -= 1;
				this.player = new Player(screenWidth/2.0,screenHeight/2.0);
				this.asteroids = generateAsteroids();
			}
			
		}
		
		//update player
		player.update();

		//update and delete projectiles out of screen
		var projTemp = [];
		for(p in projectiles){
			if(!p.toDelete){
				p.update();
				projTemp.push(p);
			}
		}
		projectiles = projTemp;

		//handle controlls
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
			projectiles.push(new Projectile(player));
			firePressed = false;
			fireReleased = false;
		}

		//esc to quit
		if(escapePressed){
			System.requestShutdown();
		}

	}

	function render(framebuffer: Framebuffer): Void {

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

		g.end();

    	// draw our backbuffer onto the active framebuffer
    	framebuffer.g2.begin();
    	Scaler.scale(backbuffer, framebuffer, System.screenRotation);
    	framebuffer.g2.end();
	}
	
}
