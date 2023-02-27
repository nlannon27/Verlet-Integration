// config values
int substeps = 8; // number of substeps, 8 is usually good enough
int framerate = 60; // how fast you want the simulation to run
PVector grav_constant = new PVector(0, 1000); // how strong gravity is
float ballBounceCoefficient = 0.75; // how much force is kept when the balls bounce off eachother
int spawnRate = 200; // how often to spawn a ball
int ballRadius = 25; // radius of spawned balls
int chainBallRadius = 10; // radius of chain (rope) objects
int cellSize = 50; // must be greater than the diameter of the largest circle

int numSpawned = 0;
float frameDT = 1.0 / framerate;
float stepDT = frameDT / substeps;
ArrayList<VerletObject> activeObjects = new ArrayList<VerletObject>();
ArrayList<VerletChain> activeChains = new ArrayList<VerletChain>();
Grid grid = null;

// creates a new VerletChain and appends it to the active chains array
VerletChain createChain(VerletObject obj1, VerletObject obj2, float chainLength) {
  VerletChain chain = new VerletChain(obj1, obj2, chainLength);
  
  activeChains.add(chain);
  
  return chain;
}

// creates a new VerletObject and appends it to the active objects array
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
  
  // initialize the grid
  grid = new Grid(cellSize);
  
  // floating vertical rope
  /*float chainSize = 25.0;
  for(int i=1; i<6; i++) {
    int curX = i*(width/6);
    
    VerletObject last = null;
    for(int j=0; j<chainSize; j++) {
      VerletObject curObj = createObject(new PVector(curX, (height/8) + (j*chainBallRadius*2)), chainBallRadius, color((j/chainSize) * 255));
      
      if(last != null) {
        createChain(last, curObj, chainBallRadius*2);
      } else {
        curObj.disablePhysics = true;
      }
      
      last = curObj;
    }
  }*/
  
  // net horizontal rope
  VerletObject last = null;
  for(int i=0; i<width/(chainBallRadius*2); i++) {
    VerletObject curObj = createObject(new PVector(chainBallRadius+(i*chainBallRadius*2), 4*(height/6)), chainBallRadius, color(255));
    
    if(last != null) {
      createChain(last, curObj, chainBallRadius*2);
    } else {
      curObj.disablePhysics = true;
    }
    
    last = curObj;
  }
  
  if(last != null) last.disablePhysics = true;
  
  // floating cloth
  int clothSize = 15;
  int chainLength = int(chainBallRadius*3);
  VerletObject[] lastChain = new VerletObject[clothSize];
  for(int i=0; i<clothSize; i++) {
    for(int j=0; j<clothSize; j++) {
      VerletObject curObj = createObject(new PVector(100 + (i*chainLength), 100 + (j*chainLength)), chainBallRadius, color(255, 100, 100));
      
      if(j==0 && lastChain[j] == null) { // top left object
        curObj.disablePhysics = true;
        lastChain[j] = curObj;
        continue;
      }
      
      if(lastChain[j] == null) { // first row, not top left
        createChain(lastChain[j-1], curObj, chainLength);
        lastChain[j] = curObj;
        continue;
      }
      
      if(j==0) { // top column, not first row
        createChain(lastChain[j], curObj, chainLength);
        lastChain[j] = curObj;
        continue;
      }
      
      // not first row
      createChain(lastChain[j-1], curObj, chainLength);
      createChain(lastChain[j], curObj, chainLength);
      lastChain[j] = curObj;
    }
  }
  
  lastChain[0].disablePhysics = true;
}

// moves all of the objects to their correct positions in the chains
void applyChains() {
  for(VerletChain chain : activeChains) {
    chain.update();
  }
}

// applies gravity acceleration to all of the verlet objects
void applyGravity() {
  for(VerletObject obj : activeObjects) {
    obj.applyGravity();
  }
}

// handles collisions between verlet objects
void handleCollisions() {
  // slow approach, kept code for bug testing
  for(VerletObject obj1 : activeObjects) {
    for(VerletObject obj2 : activeObjects) {
      obj1.handleCollision(obj2);
    }
  }
  
  // faster approach, group objects into cells to reduce collision checks
  //grid.checkCollisions();
}

// makes sure the objects don't escape the world
void handleWorldCollisions() {
  for(VerletObject obj : activeObjects) {
    obj.collideWorld();
  }
}

// updates the verlet objects
void update() {  
  if(millis() > numSpawned * spawnRate) { // spawn new objects every so often
    float colorMultiplier = (sin(millis() * 0.001) + 1) / 2;
    
    VerletObject obj1 = createObject(new PVector(width * (random(0.5) + 0.5), height * random(0.5)), ballRadius, color(colorMultiplier * 255));
    obj1.setVelocity(new PVector(random(3000) - 3000, random(100) - 50));
    
    numSpawned++;
  }
  
  for(int i=0; i<substeps; i++) { // actual object update code
    applyChains();
    applyGravity();
    handleCollisions();
    handleWorldCollisions();
    
    // apply the movements to the verlet objects
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
