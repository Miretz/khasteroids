package;

import kha.math.Vector2;
import kha.graphics2.Graphics;
import kha.System;

class Projectile {

	public var center: Vector2;
	public var velocity: Vector2;

	public var toDelete: Bool;
	
	public function new(player: Player) {

		var v = new Vector2(0.0, -4.0);
		var cosAngle = Math.cos(player.currentAngleRad);
    	var sinAngle = Math.sin(player.currentAngleRad);
		var newX = (v.x * cosAngle - v.y * sinAngle);
		var newY = (v.x * sinAngle + v.y * cosAngle);

		this.center = new Vector2(player.center.x + player.vertices[0].x, 
			player.center.y + player.vertices[0].y);
		this.velocity = new Vector2(newX, newY);
		this.toDelete = false;
	}


	public function update(){
		center.x += velocity.x;
		center.y += velocity.y;

		if(center.x > System.windowWidth()){
			this.toDelete = true;
		}
		if(center.y > System.windowHeight()){
			this.toDelete = true;
		}
		if(center.x < 0){
			this.toDelete = true;
		}
		if(center.y < 0){
			this.toDelete = true;
		}
	}

	public function render(g: Graphics): Void {		
		if(toDelete) return;
		g.fillRect(center.x, center.y, 4.0, 4.0);
	}
}