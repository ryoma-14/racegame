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
