// クラスの宣言
CameraManager camManager;
Car mycar;

// 画像データの宣言
PImage[] car = new PImage[3];

// ゲームシステムの変数
PImage heartImg;
PImage starImg;
int maxLife = 5;
int collisionCount = 0;
int frameCounter = 0;
boolean isGameOver = false;
boolean isPaused = false;
int level = 0;

// 車の移動用変数
float xpos; // 水平位置
float xvel = 0; // 速度
float acceleration = 0.3; // 加速度の係数

// 差分検知のしきい値
float thresh = 18.0; 

// 空の高さ
float skyHeight; 

// 道路の幅設定
float topWidth;
float bottomWidth;
float roadTopY =skyHeight;
float roadBottomY;
int llim;
int rlim;

// 背景の初期化
PImage bg = createImage(1920, 1080, RGB);
PImage bga = createImage(1920,1080, RGB);

// 障害物画像の初期化
ArrayList<PImage>[] obstacleImgs;
ArrayList<Obstacle> obstacles;

int nextObstacleFrame = 240;
int obstacleCount = 0;

void setup(){
  
  // ウィンドウ設定＆描画設定
  size(1920, 1080);
  noSmooth();
  frameRate(60);
  background(255);
  colorMode(RGB);

  // 変数の設定
  // 背景
  skyHeight = int(height * 0.4);
  topWidth = width * 0.1;
  bottomWidth = width * 0.6;
  roadTopY =skyHeight;
  roadBottomY = height;
  bg = createBackgroundGradient(skyHeight);
  xpos = width / 2;
  
  llim = int((width - bottomWidth) / 2) + 100;
  rlim = int((width + bottomWidth) / 2) - 100;

  // 画像の読み込み
  car[0] = loadImage("car_red.png");
  car[1] = loadImage("car_blue.png");
  car[2] = loadImage("car_green.png");
  
  heartImg = loadImage("heart.png");
  starImg = loadImage("star.png");
  
  int car_type = int(random(3));
  mycar = new Car(car[car_type], xpos, 950, llim, rlim, 0.3);
  
  // cameraManagerのインスタンス作成
  camManager = new CameraManager(this);
  // PImageの初期化
  camManager.initImages();  
  
  obstacleImgs = new ArrayList[3];
  for(int i = 0; i < 3; i++){
    obstacleImgs[i] = new ArrayList<PImage>();
  }
  
  // 障害物画像読み込み
  loadObstacleImages();
  
  // 障害物リストの初期化
  obstacles = new ArrayList<Obstacle>();

}

void draw(){
  // ゲームオーバー処理
  if(isGameOver){
    background(0);
    fill(255, 0, 0);
    textSize(100);
    textAlign(CENTER, CENTER);
    text("Game Over", width/2, height/2);
    
     // 難易度を描画
    int startX = width/2 - ((level+1)*50 + level*20)/2;
    int startY = height/2+60;
    int starSize = 50;
    int margin = 20;
    for(int i = 0; i < level + 1; i++){
      image(starImg, startX + i * (starSize + margin), startY + 60, starSize, starSize);
    }
    return;
  }
  
  if (isPaused) {
    // ポーズ中は画面をそのまま維持（ゲームの更新は止める）
    fill(0, 150);
    rect(0, 0, width, height);
    fill(255);
    textSize(64);
    textAlign(CENTER, CENTER);
    text("PAUSED", width/2, height/2);
    
    return;  // ここでdrawの処理を止める
  }
  
  // 背景の初期化
  imageMode(CORNER);
  background(255);
  image(bg, 0, 0);
  
  frameCounter++;
  
  // 残りライフを計算
  int remainingLife = maxLife - collisionCount;
  
  // ハート画像の表示位置と大きさ設定
  int heartSize = 50;
  int margin = 10;
  int startX = 20;
  int startY = 20;
  
  // 残りライフ分のハートを描画
  for(int i = 0; i < remainingLife; i++){
    image(heartImg, startX + i * (heartSize + margin), startY, heartSize, heartSize);
  }
  
  // 難易度を描画
  for(int i = 0; i < level + 1; i++){
    image(starImg, startX + i * (heartSize + margin), startY + 60, heartSize, heartSize);
  }
  
  // 道路の描画
  // 道路の形（台形）
  noStroke();
  fill(50);  // 濃いグレー

  beginShape();
  vertex((width - topWidth) / 2, roadTopY);
  vertex((width + topWidth) / 2, roadTopY);
  vertex((width + bottomWidth) / 2, roadBottomY);
  vertex((width - bottomWidth) / 2, roadBottomY);
  endShape(CLOSE);

  // センターレーンの破線アニメーション
  stroke(255);
  strokeWeight(3);

  int numLines = 20;
  float line_speed = 3; // 破線の流れる速さ
  float laneWidth = bottomWidth / 3;
  
  float offset = (frameCount * line_speed) % (height / numLines);
  
  for (int i = 0; i < numLines; i++) {
    float interY1 = lerp(roadTopY, roadBottomY, (float)i / numLines) + offset;
    
    if(interY1 >= roadBottomY) continue;
    
    float t = (interY1 - roadTopY) / (roadBottomY - roadTopY);
    
    float dashLength = lerp(1, 15, t);
    float interY2 = interY1 + dashLength;
  
    float x1 = lerp((width - topWidth) / 2, (width - bottomWidth) / 2, t);
    float x2 = lerp((width + topWidth) / 2, (width + bottomWidth) / 2, t);
  
    float centerX = (x1 + x2) / 2;
    float currentLaneWidth = lerp(laneWidth * 0.1, laneWidth, t);
  
    // 左側の線
    line(centerX - currentLaneWidth / 2, interY1, centerX - currentLaneWidth / 2, interY2);
    // 右側の線
    line(centerX + currentLaneWidth / 2, interY1, centerX + currentLaneWidth / 2, interY2);
  }
  
  // カメラの処理
  if(frameCounter % 2 == 0){
    camManager.update();
  }
  
  camManager.displayMask();
  
  imageMode(CENTER);
  
  // 障害物の描画・更新
  for(int i = obstacles.size() - 1; i >= 0; i--){
    Obstacle o = obstacles.get(i);
    o.update();
    o.display();
    
    boolean shouldRemove = false;
    
    // 車との衝突判定
    if(o.checkCollision(mycar)){
      collisionCount++;
      shouldRemove = true;
      
      if(collisionCount >= maxLife){
        isGameOver = true;
      }
    }else if(o.isOutOfScreen()){
      shouldRemove = true;
    }
    
    if(shouldRemove){
      obstacles.remove(i);
    }
  }
  
  // 障害物の追加
  if (frameCounter % nextObstacleFrame == 0){
    addRandomObstacle();
    obstacleCount++;
    if(obstacleCount % 5 == 0){
      level++;
    }
    nextObstacleFrame = int(random(300-(level*20), 300-(level*10)));
  }
  
  // 車(xpos)の移動
  mycar.update(camManager.getCentroidX(), camManager);
  
  //// カメラの描画
  //camManager.displayResult(mycar.x_pos);
  
  // 車の描画
  mycar.display();
}

// その他の関数
void mousePressed() {
  if (mouseButton == RIGHT) {  // 右クリックなら
    isPaused = !isPaused;      // ポーズ状態をトグル（ON/OFF切替）
  }
}

PImage createBackgroundGradient(float skyHeight){
  PImage bg = createImage(1920, 1080, RGB);
  bg.loadPixels(); // pixels配列を操作する準備

  // 空の色（青空）
  color topSky = color(0, 150, 255);
  color bottomSky = color(200, 230, 255);
  
  // 地面の色
  color topCity = color(180);
  color bottomCity = color(100);

  for (int y = 0; y < bg.height; y++) {
    color c;
    if (y < skyHeight) {
      float inter = map(y, 0, skyHeight, 0, 1);
      c = lerpColor(topSky, bottomSky, inter);
    } else {
      float inter = map(y, skyHeight, bg.height, 0, 1);
      c = lerpColor(topCity, bottomCity, inter);
    }

    // 1行分まとめて色を代入
    int rowStart = y * bg.width;
    for (int x = 0; x < bg.width; x++) {
      bg.pixels[rowStart + x] = c;
    }
  }

  bg.updatePixels(); // pixels配列の更新を反映
  return bg;
}

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
