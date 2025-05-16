import processing.video.*;

// カメラの宣言
Capture cam;

// データの宣言
PImage rcar, bcar, gcar;
PImage cambg, mask, bcam, result;

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

PImage bg = createImage(1920, 1080, RGB);
PImage bga = createImage(1920,1080, RGB);

void setup(){
  // 画像の読み込み
  rcar = loadImage("red_car.png");
  bcar = loadImage("blue_car.png");
  gcar = loadImage("green_car.png");
  
  
  // ウィンドウ設定＆描画設定
  size(1920, 1080);
  noSmooth();
  frameRate(60);
  background(255);
  colorMode(RGB);
  
  // カメラ設定
  String[] cameras = Capture.list();
  
  if(cameras == null){
    println("Failed to retrieve the list of available cameras, will try the default...");
    cam = new Capture(this, 640, 480);
  }else if(cameras.length == 0){
    println("There are no cameras available for capture.");
    exit();
  }else{
    println("Available cameras:");
    printArray(cameras);
    
    cam = new Capture(this, cameras[0]);
    cam.start();
    cambg = createImage(cam.width, cam.height, RGB);
    mask = createImage(cam.width, cam.height, RGB);
    bcam = createImage(cam.width, cam.height, RGB);
    result = createImage(cam.width, cam.height, ARGB);
    cam.read();
    bcam.copy(cam,0,0,width,height,0,0,width,height);
  }
  
  // 背景の設定
  skyHeight = int(height * 0.4);
  topWidth = width * 0.1;
  bottomWidth = width * 0.6;
  roadTopY =skyHeight;
  roadBottomY = height;
  bg = createBackgroundGradient(skyHeight);
  
  xpos = width / 2;
}

void draw(){
  // 背景の初期化
  imageMode(CORNER);
  background(255);
  image(bg, 0, 0);
  
  
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
  float line_speed = 4; // 破線の流れる速さ
  float laneWidth = bottomWidth / 3;
  
  for (int i = 0; i < numLines; i++) {
    float offset = (frameCount * line_speed) % (height / numLines);
    
    float interY1 = map(i, 0, numLines, roadTopY, roadBottomY) + offset;
    
    float dashLength = map(interY1, roadTopY, roadBottomY, 1, 15);
    float interY2 = interY1 + dashLength;

    float x1 = map(interY1, roadTopY, roadBottomY, (width - topWidth) / 2, (width - bottomWidth) / 2);
    float x2 = map(interY1, roadTopY, roadBottomY, (width + topWidth) / 2, (width + bottomWidth) / 2);

    float centerX = (x1 + x2) / 2;
    float currentLaneWidth = map(interY1, roadTopY, roadBottomY, laneWidth * 0.1, laneWidth);

    if(interY1 < roadBottomY){
      // 左側の線
      line(centerX - currentLaneWidth / 2, interY1, centerX - currentLaneWidth / 2, interY2);
      // 右側の線
      line(centerX + currentLaneWidth / 2, interY1, centerX + currentLaneWidth / 2, interY2);
    }
  }
  
  
  // カメラの処理
  if(cam.available()){
    cam.read();
    if(mousePressed==true){
      cambg.copy(cam, 0, 0, cam.width, cam.height, 0, 0, cam.width, cam.height);
    }
  }
  
  float centroidX = 0;
  int mask_pix_num = 0;
  
  result.loadPixels();
  mask.loadPixels();
  
  for(int w = 0; w < cam.width; w++){
    for(int h = 0; h < cam.height; h++){
      int pix = h * cam.width + w;
      color c = cam.pixels[pix];
      
      // 動体検知
      color c1 = cambg.pixels[pix];
      float diff1 = (abs(red(c1) - red(c)) + 
                    abs(green(c1) - green(c)) +
                    abs(blue(c1) - blue(c))) / 3.0;
      
      if(diff1 > thresh){
        result.pixels[pix] = color(red(c), green(c), blue(c), 255);
      }else{
        result.pixels[pix] = color(0, 0, 0, 0);
      }
      
      // 差分検出
      color c2 = bcam.pixels[pix];
      float diff2 = (abs(red(c2) - red(c)) + 
                    abs(green(c2) - green(c)) +
                    abs(blue(c2) - blue(c))) / 3.0;
                    
      if(diff2 > thresh){
        mask.pixels[pix] = color(255);
        centroidX += w - cam.width / 2;
        mask_pix_num++;
      }else{
        mask.pixels[pix] = color(0);
      }  
    }
  }
  result.updatePixels();
  mask.updatePixels();
  
  // 更新
  bcam.copy(cam, 0, 0, cam.width, cam.height, 0, 0, cam.width, cam.height);
  
  // 車(xpos)の移動
  // 重心位置の正規化＆デッドゾーン
  if(mask_pix_num > 0){
    centroidX /= mask_pix_num;
    centroidX /= (cam.width / 2.0);
    if(abs(centroidX) < 0.2){
      centroidX = 0;
    }
    float directionFactor = 1.0;
    if(centroidX * xvel < 0){
      directionFactor = 0.3;
    }
    
    xvel += centroidX * acceleration * directionFactor;
  }

  xpos += xvel*1.5;
  xvel *= 0.995;
  // 値の制限
  int llim = int((width-bottomWidth)/2);
  int rlim = int((width+bottomWidth)/2);
  xpos = constrain(xpos, llim, rlim);
  xvel = constrain(xvel, -2, 2);
  
  //print("xpos:",xpos);
  print("centroid", centroidX);
    
  image(mask, 0, 0);
  imageMode(CENTER);
  image(result, xpos, 850, cam.width/4, cam.height/4);
  image(rcar, xpos, 950, 250, 250);
  cam.read();
}
