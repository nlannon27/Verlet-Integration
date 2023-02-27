class VerletChain { // chain of objects (like a rope)
  VerletObject obj1;
  VerletObject obj2;
  float chainLength;
  
  VerletChain(VerletObject obj1, VerletObject obj2, float chainLength) {
    this.obj1 = obj1;
    this.obj2 = obj2;
    this.chainLength = chainLength;
  }
  
  void update() {
    // vector going from first object to second
    PVector dir = obj1.pos.copy();
    dir.sub(obj2.pos);
    
    // distance between center of two objects)
    float dist = dir.mag();
    
    // normalized direction from obj1 to obj2
    PVector normalizedDir = dir.copy();
    normalizedDir.div(dist);
    
    // how much further the objects are from eachother than they should be
    float delta = this.chainLength - dist;
    
    // hacky code to handle if an objects physics is disabled
    // moves the objects to where they should be based on the chain
    if(!obj1.disablePhysics && !obj2.disablePhysics) {
      normalizedDir.mult(0.5 * delta);
    
      obj1.pos.add(normalizedDir);
      obj2.pos.sub(normalizedDir);
    } else if(obj1.disablePhysics && !obj2.disablePhysics) {
      normalizedDir.mult(delta);
    
      obj2.pos.sub(normalizedDir);
    } else if(!obj1.disablePhysics && obj2.disablePhysics) {
      normalizedDir.mult(delta);
    
      obj1.pos.add(normalizedDir);
    }
  }
}
