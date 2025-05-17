class Obstacle {
  PImage img;       // 障害物の画像
  float x_pos, y_pos;  // 障害物の座標
  float speed;      // 障害物の縦方向の移動速度
  float size;       // サイズ

  // コンストラクタ
  Obstacle(PImage img, float x_pos, float y_pos, float size) {
    this.img = img;
    this.x_pos = x_pos;
    this.y_pos = y_pos;
    this.size = size;
  }

  // 障害物の位置更新
  void update() {
    x_pos += (x_pos - width / 2)*0.011;
    y_pos *= 1.005;
    size += 0.8;
  }

  // 表示
  void display() {
    image(img, x_pos, y_pos, size, size);
  }

  // 当たり判定（簡易版：距離判定）
  boolean checkCollision(Car car) {
    float d = dist(x_pos, y_pos, car.x_pos, car.y_pos);
    return (d < (size/2 + car.outScale/2) * 0.8);
  }
  
  boolean isOutOfScreen(){
    return (y_pos - size / 2 > height);
  }
}
