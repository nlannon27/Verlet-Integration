class GridCell {
  ArrayList<VerletObject> objects;
  Grid parentGrid;
  int gridX, gridY;
  
  GridCell(Grid grid, int gridX, int gridY) {
    this.objects = new ArrayList<VerletObject>();
    this.parentGrid = grid;
    this.gridX = gridX;
    this.gridY = gridY;
  }
  
  void checkCollisions(GridCell otherCell) {
    for(VerletObject obj : this.objects) {
      for(VerletObject otherObj : otherCell.objects) {
        obj.handleCollision(otherObj);
      }
    }
  }
  
  void checkNeighbors() {
    for(int x=-1; x<=1; x++) {
      for(int y=-1; y<=1; y++) {
        int dx = gridX + x;
        int dy = gridY + y;
        
        if(dx < 0 || dx > grid.gridWidth-1 || dy < 0 || dy > grid.gridHeight-1) continue;
        
        GridCell neighbor = parentGrid.getCell(dx, dy);
        
        checkCollisions(neighbor);
      }
    }
  }
  
  void cullExcessObjects() { // Removes objects that have left the grid
    for(int i=0; i<this.objects.size(); i++) {
      VerletObject obj = this.objects.get(i);
      
      if(this.parentGrid.getCellAt(obj.pos) != this) {
        this.objects.remove(i);
      }
    }
  }

  int addObject(VerletObject obj) {
    objects.add(obj);
    
    return objects.size() - 1;
  }
}
