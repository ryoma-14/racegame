import processing.video.*;

class CameraManager{
  PApplet parent;
  Capture cam;
  PImage cambg, mask, bcam, result;
  float thresh = 18.0;
  float centroidX = 0;
  float pcentroidX = 0;
  int mask_pix_num = 0;
  
  // コンストラクタの設定
  CameraManager(PApplet parent){
    this.parent = parent;
    // カメラの初期化
    String[] cameras = Capture.list();
    
    if(cameras == null){
      println("Failed to retrieve the list of available cameras, will try the default...");
      cam = new Capture(parent, 640, 480);
    }else if(cameras.length == 0){
      println("There are no cameras available for capture.");
      exit();
    }else{
      println("Available cameras:");
      printArray(cameras);
      
      cam = new Capture(parent, cameras[0]);
      cam.start();
    }
  }
  
  // PImageを初期化
  void initImages(){
    cam.read();
    cambg = createImage(cam.width, cam.height, RGB);
    mask = createImage(cam.width, cam.height, RGB);
    bcam = createImage(cam.width, cam.height, RGB);
    result = createImage(cam.width, cam.height, ARGB);
    bcam.copy(cam, 0, 0, cam.width, cam.height, 0, 0, cam.width, cam.height);
  }
  
  // 動体検知＆差分検出
  void update(){
    if(cam.available()){
      cam.read();
      // クリックで背景を取得
      if(mousePressed==true){
        cambg.copy(cam, 0, 0, cam.width, cam.height, 0, 0, cam.width, cam.height);
      }
    }
    
    // 重心の初期化
    centroidX = 0;
    mask_pix_num = 0;

    // ピクセルの読み込み
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

    // ピクセルの更新
    result.updatePixels();
    mask.updatePixels();

    // 前フレームの更新
    bcam.copy(cam, 0, 0, cam.width, cam.height, 0, 0, cam.width, cam.height);
    
    if(mask_pix_num < 200){
      centroidX = pcentroidX;
    } else {
      pcentroidX = centroidX / mask_pix_num;
      centroidX = pcentroidX;
    }
  }
  
  // cam.widthの取得
  int getCamWidth(){
    return cam.width;
  }
  
  // cam.heightの取得
  int getCamHeight(){
    return cam.height;
  }
  
  // mask_pix_numの取得
  int getMaskPixNum(){
    return mask_pix_num;
  }

  // centroidXの取得
  float getCentroidX(){
    return centroidX;
  }

  // 動体検知の取得
  PImage getResult(){
    return result;
  }

  // maskの取得
  PImage getMask(){
    return mask;
  }
  
  PImage getFlippedMask(){
    PImage flipped = createImage(mask.width, mask.height, RGB);
  mask.loadPixels();
  flipped.loadPixels();

  for(int y = 0; y < mask.height; y++){
    for(int x = 0; x < mask.width; x++){
      int srcIndex = y * mask.width + x;
      int dstIndex = y * mask.width + (mask.width - 1 - x);
      flipped.pixels[dstIndex] = mask.pixels[srcIndex];
    }
  }

  flipped.updatePixels();
  return flipped;
  }
  
  // 画像の表示
  void display(float x_pos){
    imageMode(CORNER);
    image(getFlippedMask(), width - cam.width, 0);
    imageMode(CENTER);
    image(getResult(), x_pos, 850, cam.width/4, cam.height/4);
  }
  
}
