class Car {
  PImage img;
  float x, y;
  float vel;
  float acceleration;
  float maxSpeed;
  float llim, rlim;

  Car(PImage img, float x, float y, float acceleration, float maxSpeed, float llim, float rlim) {
    this.img = img;
    this.x = x;
    this.y = y;
    this.vel = 0;
    this.acceleration = acceleration;
    this.maxSpeed = maxSpeed;
    this.llim = llim;
    this.rlim = rlim;
  }

  void update(float input) {
    float directionFactor = 1.0;
    if (input * vel < 0) {
      directionFactor = 0.3;  // 切り返しの減速
    }
    vel += input * acceleration * directionFactor;
    vel = constrain(vel, -maxSpeed, maxSpeed);
    x += vel * 1.5;
    vel *= 0.995;
    x = constrain(x, llim, rlim);
  }

  void display() {
    imageMode(CENTER);
    image(img, x, y, 250, 250);
  }
}
