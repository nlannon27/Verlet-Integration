class Grid {
  GridCell[] grid;
  int gridWidth, gridHeight;
  int cellSize;
  
  Grid(int cellSize) { // cellSize must be bigger than the biggest VerletObject
    gridWidth = int(width / cellSize);
    gridHeight = int(height / cellSize);
    
    this.cellSize = cellSize;
    
    // create grid array
    grid = new GridCell[gridWidth * gridHeight];
    
    // initialize values in grid array
    for(int x=0; x<gridWidth; x++) {
      for(int y=0; y<gridHeight; y++) {
        grid[gridKey(x,y)] = new GridCell(this, x, y);
      }
    }
  }
  
  // handles object collisions between every cell in array
  void checkCollisions() {
    for(int i=0; i<gridWidth*gridHeight; i++) {
      GridCell cell = this.grid[i];
      
      cell.cullExcessObjects(); // removes objects from cell that have moved to a different cell
      cell.checkNeighbors(); // checks collisions with neighboring cells (and own cell)
    }
  }
  
  // 0,0 : 0 | 1,0 : 1 | 2,0 : 2
  // 0,1 : 3 | 1,1 : 4 | 2,1 : 5
  // 0,2 : 6 | 1,2 : 7 | 2,2 : 8
  int gridKey(int x, int y) { // turn x,y coordinates into index for grid array
    return (y * gridWidth) + x;
  }
  
  GridCell getCell(int x, int y) { // get cell at x,y coordinates (not screen x,y : grid x,y)
    return this.grid[gridKey(x, y)];
  }
  
  GridCell getCellAt(PVector pos) { // get cell at screenn x,y coordinates
    return getCell(int(pos.x / cellSize), int(pos.y / cellSize));
  }
  
  void drawGrid() { // draws the grid (used for debugging)
    for(int i=1; i<gridWidth; i++) {
      line(i*cellSize, 0, i*cellSize, height);
    }
    
    for(int i=1; i<gridHeight; i++) {
      line(0, i*cellSize, width, i*cellSize);
    }
  }
}
