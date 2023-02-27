class VerletObject {
  PVector pos, pos_last, acceleration;
  int radius;
  color col;
  
  boolean disablePhysics = false;
  
  Grid grid;
  GridCell gridCell;
  
  VerletObject(PVector startPos, int radius, color c, Grid grid) {
    this.pos = startPos;
    this.pos_last = startPos;
    this.acceleration = new PVector(0, 0);
    this.radius = radius;
    this.col = c;
    this.grid = grid;
    
    // keeps object working even if i'm not using grid collision handler
    if(grid == null) {
      this.gridCell = null;
    } else {
      this.gridCell = grid.getCellAt(startPos);
      this.gridCell.addObject(this);
    }
  }
  
  // accelerates the object in the direction of vector
  void accelerate(PVector vector) {
    this.acceleration.add(vector);
  }
  
  // overrides current velocity
  void setVelocity(PVector v) {
    this.pos_last = this.pos.copy();
    v.mult(stepDT);
    
    this.pos_last.sub(v);
  }
  
  // adds to current velocity
  void addVelocity(PVector v) {
    v.mult(stepDT);
    
    this.pos_last.sub(v);
  }
  
  // applys gravity constant to object (should be done every tick)
  void applyGravity() {
    this.accelerate(grav_constant);
  }
  
  // handles the collision between one object and another
  void handleCollision(VerletObject obj) {
    if(obj == this) return;
    
    // vector from obj1 to obj2
    PVector difference = this.pos.copy();
    difference.sub(obj.pos);
    
    // use squared distance for checking to not have to sqrt, saves some performance
    // distance between two objects squared
    float distSquared = (difference.x * difference.x) + (difference.y * difference.y);
    // minimum distance the two objects need to be from eachother
    float min_dist = this.radius + obj.radius;
    
    // if the objects are overlapping
    if(distSquared < min_dist * min_dist) {
      // find actual distance now
      float dist = sqrt(distSquared);
     
      // normalized vector of where the obj1 is colliding with obj2
      PVector hitNormal = difference.copy();
      hitNormal.div(dist);
      
      // how much each object should be pushed away from eachother (mass depends on objects size)
      float massRatio1 = float(this.radius) / float(this.radius + obj.radius);
      float massRatio2 = float(obj.radius) / float(this.radius + obj.radius);
      
      // how far objects need to go to get out of eachother
      float delta = 0.5 * ballBounceCoefficient * (dist - min_dist);
      
      // hacky way to handle when objects have their physics disabled
      // if one object's physics is disabled, it will act like a wall, pushing the other with 100% of their force
      if(!this.disablePhysics && !obj.disablePhysics) { // both objects physics enabled
        PVector object1_bounce = hitNormal.copy();
        object1_bounce.mult(massRatio2 * delta);
        this.pos.sub(object1_bounce);
        
        PVector object2_bounce = hitNormal.copy();
        object2_bounce.mult(massRatio1 * delta);
        obj.pos.add(object2_bounce);
      } else if(this.disablePhysics && !obj.disablePhysics) { // this objects physics disabled
        PVector object2_bounce = hitNormal.copy();
        object2_bounce.mult(massRatio1 * (delta*2));
        obj.pos.add(object2_bounce);
      } else if(!this.disablePhysics && obj.disablePhysics) { // other objects physics disabled
        PVector object1_bounce = hitNormal.copy();
        object1_bounce.mult(massRatio2 * (delta*2));
        this.pos.sub(object1_bounce);
      }
    }
  }
  
  // handles colliding with world
  void collideWorld() {
    // this worked last I checked, just disabled to save performance
    // basically made the objects bounce off the walls instead of just stopping
    // with the rope net it wasn't very noticeable
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
  
  // makes sure this.gridCell is always accurate
  void updateCell() {
    if(grid == null) return;
    
    GridCell curCell = grid.getCellAt(this.pos);
    
    if(this.gridCell == curCell) return;
    
    curCell.addObject(this);
    this.gridCell = curCell;
  }
  
  // applys verlet integration physics to object, moves object towards acceleration with velocity of last position
  void updatePosition(float dt) {
    if(this.disablePhysics) return;
    
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
