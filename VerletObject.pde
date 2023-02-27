class VerletObject {
  PVector pos, pos_last, acceleration;
  int radius;
  color col;
  
  Grid grid;
  GridCell gridCell;
  
  VerletObject(PVector startPos, int radius, color c, Grid grid) {
    this.pos = startPos;
    this.pos_last = startPos;
    this.acceleration = new PVector(0, 0);
    this.radius = radius;
    this.col = c;
    
    this.grid = grid;
    this.gridCell = grid.getCellAt(startPos);
  }
  
  void accelerate(PVector vector) {
    this.acceleration.add(vector);
  }
  
  void setVelocity(PVector v) {
    this.pos_last = this.pos.copy();
    v.mult(stepDT);
    
    this.pos_last.sub(v);
  }
  
  void addVelocity(PVector v) {
    v.mult(stepDT);
    
    this.pos_last.sub(v);
  }
  
  void applyGravity() {
    this.accelerate(grav_constant);
  }
  
  void handleCollision(VerletObject obj) {
    if(obj == this) return;
    
    PVector difference = this.pos.copy();
    difference.sub(obj.pos);
    
    float distSquared = (difference.x * difference.x) + (difference.y * difference.y);
    float min_dist = this.radius + obj.radius;
    
    if(distSquared < min_dist * min_dist) { // objects overlap
      float dist = sqrt(distSquared);
     
      PVector hitNormal = difference.copy();
      hitNormal.div(dist);
      
      float massRatio1 = float(this.radius) / float(this.radius + obj.radius);
      float massRatio2 = float(obj.radius) / float(this.radius + obj.radius);
      
      float delta = 0.5 * ballBounceCoefficient * (dist - min_dist);
      
      PVector object1_bounce = hitNormal.copy();
      object1_bounce.mult(massRatio2 * delta);
      this.pos.sub(object1_bounce);
      
      PVector object2_bounce = hitNormal.copy();
      object2_bounce.mult(massRatio1 * delta);
      obj.pos.add(object2_bounce);
    }
  }
  
  void collideWorld() {
    /*if(this.pos.y > height - radius || this.pos.y < 0 + radius) {
      PVector velocity = getVelocity();
      
      if(abs(velocity.y) < 1) { // if the velocity is low (already bounced around enough)
        this.pos.y = constrain(this.pos.y, 0 + radius, height - radius); // stop bouncing, stay on ground
        
        if(abs(velocity.x) > 0) { // if ball is moving horizontally while on ground, apply some friction
          this.accelerate(new PVector((velocity.x * -1) * dt, this.acceleration.y));
        }
      } else {
        this.accelerate(new PVector(this.acceleration.x, (velocity.y * -1) * dt * 50)); // bounce off the wall
      }
    }
    
    if(this.pos.x > width - radius || this.pos.x < 0 + radius) {
      PVector velocity = getVelocity();
      
      if(abs(velocity.x) < 1) { // if velocity is low
        this.pos.x = constrain(this.pos.x, 0 + radius, width - radius); // stop bouncing
      } else {
        this.accelerate(new PVector((velocity.x * -1) * dt * 40, acceleration.y)); // bounce off wall
      }
    }*/
    
    this.pos.y = constrain(this.pos.y, 0 + radius, height - radius);
    this.pos.x = constrain(this.pos.x, 0 + radius, width - radius);
  }
  
  void updateCell() {
    GridCell curCell = grid.getCellAt(this.pos);
    
    if(this.gridCell == curCell) return;
    
    curCell.addObject(this);
    this.gridCell = curCell;
  }
  
  void updatePosition(float dt) {
    PVector velocity = this.pos.copy();
    velocity.sub(this.pos_last);
    
    this.pos_last = this.pos.copy();
    
    this.pos.add(velocity);
    acceleration.mult(dt * dt);
    this.pos.add(acceleration);
    
    updateCell();
    
    this.acceleration.x = 0;
    this.acceleration.y = 0;
  }
  
  void drawObject() {
    fill(this.col);
    circle(this.pos.x, this.pos.y, this.radius * 2);
  }
}
