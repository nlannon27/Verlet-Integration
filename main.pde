int substeps = 8;
int framerate = 60;
PVector grav_constant = new PVector(0, 1000);
float ballBounceCoefficient = 0.75;
int spawnRate = 20; // every 1000 ms
int ballRadius = 10;
int cellSize = 40; // must be greater than the diameter of the largest circle

int numSpawned = 0;
float frameDT = 1.0 / framerate;
float stepDT = frameDT / substeps;
ArrayList<VerletObject> activeObjects = new ArrayList<VerletObject>();
Grid grid;

VerletObject createObject(PVector pos, int radius, color col) {
  VerletObject newObj = new VerletObject(pos, radius, col, grid);
  
  activeObjects.add(newObj);
  
  return newObj;
}

void setup() {
  size(2000, 1000);
  frameRate(framerate);
  
  strokeWeight(2);
  stroke(0);
  
  grid = new Grid(cellSize);
}

void applyGravity() {
  for(VerletObject obj : activeObjects) {
    obj.applyGravity();
  }
}

void handleCollisions() {
  /*for(VerletObject obj1 : activeObjects) {
    for(VerletObject obj2 : activeObjects) {
      obj1.handleCollision(obj2);
    }
  }*/
  
  grid.checkCollisions();
}

void handleWorldCollisions() {
  for(VerletObject obj : activeObjects) {
    obj.collideWorld();
  }
}

void update() {  
  if(millis() > numSpawned * spawnRate) {
    float colorMultiplier = (sin(millis() * 0.001) + 1) / 2;
    
    VerletObject obj1 = createObject(new PVector(1920/2, 1080/3), ballRadius, color(colorMultiplier * 255));
    obj1.setVelocity(new PVector(sin(millis() * 0.001) * 1000, cos(millis() * 0.001) * 1000));
    
    numSpawned++;
  }
  
  for(int i=0; i<substeps; i++) {
    applyGravity();
    handleCollisions();
    handleWorldCollisions();
    
    for(VerletObject obj : activeObjects) {
      obj.updatePosition(stepDT);
    }
  }
}

void draw() {
  background(127);
  
  update();
  
  for(VerletObject obj : activeObjects) {
    
    obj.drawObject();
  }
  
  /*strokeWeight(5);
  stroke(255);
  grid.drawGrid();*/
}
