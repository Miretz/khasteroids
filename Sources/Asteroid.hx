package;

import kha.math.Vector2;
import kha.math.Random;
import Math;
import kha.graphics2.Graphics;
import kha.System;

class Asteroid {

	public var vertices : Array<Vector2>;
	public var center: Vector2;
	public var radius: Float;
	public var velocity: Vector2;
	public var points: Int;
	public var visible: Bool;

	public function new(x: Float, y: Float, points: Int, radius: Float) {
		Random.init(Std.int(System.time * 1000));
		
		this.visible = true;
		this.center = new Vector2(x, y);
		this.radius = radius;
		this.points = points;
		this.vertices = generateVertices();

		//random velocity
		velocity = new Vector2(Random.getFloatIn(-2.0,2.0), Random.getFloatIn(-2.0,2.0));
	}

	function generateVertices(): Array<Vector2>{
		var verts = new Array();
		
		//generate random angles
		var angles = [for (i in 0...points) Random.getFloatIn(0.0, Math.PI*2)];

		//sort angles
		angles.sort(function(a, b) {
           if(a < b) return -1;
           else if(a > b) return 1;
           else return 0;
        });

		//iterate the angles and create vertices
		for (angle in angles){
			var bump = Random.getFloatIn(0.0, radius/2.0);						
			var xa = Math.cos(angle)*(radius - bump);
			var ya = Math.sin(angle)*(radius - bump);
			verts.push(new Vector2(xa, ya));			
		}

		return verts;
	}

	public function update(){
		if(this.radius < 10.0) this.visible = false;
		
		center.x += velocity.x;
		center.y += velocity.y;

		if(center.x > System.windowWidth()){
			center.x = 0;
		}
		if(center.y >  System.windowHeight()){
			center.y = 0;
		}
		if(center.x < 0){
			center.x = System.windowWidth();
		}
		if(center.y < 0){
			center.y = System.windowHeight();
		}
	}

	public function checkCollision(point: Vector2, otherRadius: Float = 0.0): Bool {
		if(!this.visible) return false;
		
		//simple circle checkCollision
		var dx = this.center.x - point.x;
		var dy = this.center.y - point.y;
		var distance = Math.sqrt(dx * dx + dy * dy);
		return (distance < this.radius + otherRadius);
	}

	public function render(g: Graphics): Void {		
		if(!this.visible) return;
		
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