class Car {
  PImage img; // 車の画像
  float x_pos, y_pos; // 車の描画位置
  float vel; // 車の移動速度（水平方向）
  float acceleration; // 車の加速度
  float llim, rlim; // 移動の左端、右端
  
  float maxSpeed = 2.0; // 制限速度
  float directionFactor; // 切り返しの減衰率
  float attenuationFactor = 0.995; // 速度の減衰率
  
  int outScale = 250; // 出力画像の大きさ

  // コンストラクタの設定
  Car(PImage img, float x_pos, float y_pos, float llim, float rlim, float acceleration) {
    this.img = img;
    this.x_pos = x_pos;
    this.y_pos = y_pos;
    this.vel = 0;
    this.llim = llim;
    this.rlim = rlim;
    this.acceleration = acceleration;
  }

  // 車の加速度，速度，位置の更新
  void update(int mask_pix_num, float centroidX, CameraManager camManager) {
    // 重心の正規化
    if(mask_pix_num > 0){
      centroidX /= mask_pix_num;
      centroidX /= camManager.getCamWidth() / 2.0;
    } else centroidX = 0;
    
    // デッドゾーンの設定
    if(abs(centroidX) < 0.25){
      centroidX = 0;
    }
      
    // 切り返しの減衰
    directionFactor = 1.0;
    if (centroidX * vel < 0) {
      directionFactor = 0.5;
    }
    
    // 速度の更新
    vel += centroidX * acceleration * directionFactor;
    vel = constrain(vel, -maxSpeed, maxSpeed);
    
    // 車の位置の更新
    x_pos += vel * 1.5;
    x_pos = constrain(x_pos, llim, rlim);
    
    // 速度の減衰
    vel *= attenuationFactor;
    
  }

  // 車の画像の表示
  void display() {
    imageMode(CENTER);
    image(img, x_pos, y_pos, outScale, outScale);
  }
  
}
