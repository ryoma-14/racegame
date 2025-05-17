void loadObstacleImages(){
  // グループ0
  obstacleImgs[0].add(loadImage("drum_red.png"));
  obstacleImgs[0].add(loadImage("drum_green.png"));
  obstacleImgs[0].add(loadImage("drum_blue.png"));
  obstacleImgs[0].add(loadImage("drum_ash.png"));
  
  // グループ1
  obstacleImgs[1].add(loadImage("guard_fence.png"));
  obstacleImgs[1].add(loadImage("traffic_cone.png"));
  
  // グループ2
  obstacleImgs[2].add(loadImage("deer.png"));
}

void addRandomObstacle(){
  int group = int(random(3));
  int type = int(random(obstacleImgs[group].size()));
  PImage img = obstacleImgs[group].get(type);
  
  Obstacle o = new Obstacle(img, random(int((width - topWidth) / 2), int((width + topWidth) / 2)), skyHeight, 50.0);
  obstacles.add(o);
}
