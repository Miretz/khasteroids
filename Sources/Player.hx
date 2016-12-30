package;

import kha.math.Vector2;
import kha.graphics2.Graphics;
import Math;

class Player {

	public var vertices : Array<Vector2>;
	public var center: Vector2;
	public var velocity: Vector2;
	public var currentAngleRad: Float;

	public function new(x: Float, y: Float) {
		this.center = new Vector2(x, y);
		this.currentAngleRad = 0.0;
	
		this.vertices = new Array();
		this.vertices.push(new Vector2(0.0, -20.0));
		this.vertices.push(new Vector2(12.0, 10.0));
		this.vertices.push(new Vector2(0.0, 4.0));
		this.vertices.push(new Vector2(-12.0, 10.0));

		this.velocity = new Vector2(0.0,0.0);		
	}

	public function rotate(delta: Float): Void{
		var angleRad = (delta/180.0)*Math.PI;
		var cosAngle = Math.cos(angleRad);
    	var sinAngle = Math.sin(angleRad);

		currentAngleRad += angleRad;

		for(v in vertices){
			var newX = (v.x * cosAngle - v.y * sinAngle);
			var newY = (v.x * sinAngle + v.y * cosAngle);
			v.x = newX;
			v.y = newY;
		}
	}

	public function accelerate(delta: Float): Void {
		var v = new Vector2(0.0, -delta);
		var cosAngle = Math.cos(currentAngleRad);
    	var sinAngle = Math.sin(currentAngleRad);
		var newX = (v.x * cosAngle - v.y * sinAngle);
		var newY = (v.x * sinAngle + v.y * cosAngle);
		velocity.x += newX;
		velocity.y += newY;
	}

	public function update(){
		center.x += velocity.x;
		center.y += velocity.y;

		if(center.x > 800){
			center.x = 0;
		}
		if(center.y > 600){
			center.y = 0;
		}
		if(center.x < 0){
			center.x = 800;
		}
		if(center.y < 0){
			center.y = 600;
		}
	}

	public function render(g: Graphics): Void {		
		var i = 0;
		while(i < vertices.length - 1){
			var first = vertices[i++];
			var second = vertices[i];
			g.drawLine(center.x + first.x, center.y + first.y, 
				center.x + second.x, center.y + second.y);		
		}
		g.drawLine(center.x + vertices[0].x, center.y + vertices[0].y, 
			center.x + vertices[i].x, center.y + vertices[i].y);
	}
}