class Grid {
  GridCell[] grid;
  int gridWidth, gridHeight;
  int cellSize;
  
  Grid(int cellSize) { // cellSize must be bigger than the biggest VerletObject
    gridWidth = int(width / cellSize);
    gridHeight = int(height / cellSize);
    
    this.cellSize = cellSize;
    
    grid = new GridCell[gridWidth * gridHeight];
    
    for(int x=0; x<gridWidth; x++) {
      for(int y=0; y<gridHeight; y++) {
        grid[gridKey(x,y)] = new GridCell(this, x, y);
      }
    }
  }
  
  void checkCollisions() {
    for(int i=0; i<gridWidth*gridHeight; i++) {
      GridCell cell = this.grid[i];
      
      cell.cullExcessObjects();
      cell.checkNeighbors();
    }
  }
  
  // 0,0 : 0 | 1,0 : 1 | 2,0 : 2
  // 0,1 : 3 | 1,1 : 4 | 2,1 : 5
  // 0,2 : 6 | 1,2 : 7 | 2,2 : 8
  int gridKey(int x, int y) {
    return (y * gridWidth) + x;
  }
  
  GridCell getCell(int x, int y) {
    return this.grid[gridKey(x, y)];
  }
  
  GridCell getCellAt(PVector pos) {
    return getCell(int(pos.x / cellSize), int(pos.y / cellSize));
  }
  
  void drawGrid() {
    for(int i=1; i<gridWidth; i++) {
      line(i*cellSize, 0, i*cellSize, height);
    }
    
    for(int i=1; i<gridHeight; i++) {
      line(0, i*cellSize, width, i*cellSize);
    }
  }
}
