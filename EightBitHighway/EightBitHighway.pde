final int SCREEN_W = 400;
final int SCREEN_H = 600;
final int ROAD_X = 70;
final int ROAD_W = 260;
final int LANE_COUNT = 3;
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_PAUSED = 2;
final int STATE_GAME_OVER = 3;

PlayerCar player;
ArrayList<EnemyCar> enemies = new ArrayList<EnemyCar>();
ArrayList<Coin> coins = new ArrayList<Coin>();

float roadOffset = 0;
float speed = 5;
int score = 0;
int bestScore = 0;
int spawnTimer = 0;
int coinTimer = 0;
int gameState = STATE_START;

void setup() {
  size(400, 600);
  noSmooth();
  textFont(createFont("Monospaced", 18));
  resetRound();
}

void draw() {
  background(21, 120, 54);
  drawRoad();
  drawRoadside();

  if (gameState == STATE_PLAYING) {
    updateGame();
  }

  for (EnemyCar enemy : enemies) {
    enemy.draw();
  }
  for (Coin coin : coins) {
    coin.draw();
  }
  player.draw();
  drawHud();
  drawScreenMessage();
}

void updateGame() {
  score++;
  speed = 5 + score / 900.0;
  roadOffset = (roadOffset + speed) % 80;

  player.update();
  updateEnemies();
  updateCoins();

  spawnTimer--;
  if (spawnTimer <= 0) {
    spawnEnemy();
    spawnTimer = max(26, int(70 - speed * 5));
  }

  coinTimer--;
  if (coinTimer <= 0) {
    spawnCoin();
    coinTimer = int(random(80, 140));
  }
}

void updateEnemies() {
  for (int i = enemies.size() - 1; i >= 0; i--) {
    EnemyCar enemy = enemies.get(i);
    enemy.update();

    if (enemy.y > height + 70) {
      enemies.remove(i);
    } else if (rectsOverlap(player.x, player.y, player.w, player.h, enemy.x, enemy.y, enemy.w, enemy.h)) {
      gameState = STATE_GAME_OVER;
      bestScore = max(bestScore, score);
    }
  }
}

void updateCoins() {
  for (int i = coins.size() - 1; i >= 0; i--) {
    Coin coin = coins.get(i);
    coin.update();

    if (coin.y > height + 30) {
      coins.remove(i);
    } else if (rectsOverlap(player.x, player.y, player.w, player.h, coin.x, coin.y, coin.size, coin.size)) {
      score += 150;
      coins.remove(i);
    }
  }
}

void spawnEnemy() {
  int lane = int(random(LANE_COUNT));
  color[] colors = {
    color(38, 99, 220),
    color(236, 188, 28),
    color(179, 61, 211),
    color(36, 194, 153)
  };

  enemies.add(new EnemyCar(laneCenter(lane) - 15, -60, colors[int(random(colors.length))]));
}

void spawnCoin() {
  int lane = int(random(LANE_COUNT));
  coins.add(new Coin(laneCenter(lane) - 10, -30));
}

void drawRoad() {
  fill(42);
  rect(ROAD_X, 0, ROAD_W, height);

  fill(230);
  rect(ROAD_X - 8, 0, 8, height);
  rect(ROAD_X + ROAD_W, 0, 8, height);

  for (int lane = 1; lane < LANE_COUNT; lane++) {
    float x = ROAD_X + lane * ROAD_W / float(LANE_COUNT);
    for (int y = -80; y < height + 80; y += 80) {
      fill(245);
      rect(x - 3, y + roadOffset, 6, 42);
    }
  }
}

void drawRoadside() {
  for (int y = 20; y < height; y += 80) {
    drawTree(32, y + roadOffset % 80);
    drawTree(width - 48, y + 38 + roadOffset % 80);
  }
}

void drawTree(float x, float y) {
  fill(96, 58, 27);
  rect(x + 8, y + 20, 8, 18);
  fill(28, 82, 33);
  rect(x, y + 8, 24, 16);
  rect(x + 4, y, 16, 12);
}

void drawHud() {
  fill(0, 150);
  rect(0, 0, width, 42);

  fill(255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("SCORE " + score, 12, 11);

  textAlign(RIGHT, TOP);
  text("BEST " + bestScore, width - 12, 11);

  if (gameState == STATE_GAME_OVER) {
    fill(0, 190);
    rect(56, 216, 288, 132);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(30);
    text("GAME OVER", width / 2, 260);
    textSize(16);
    text("PRESS R TO RESTART", width / 2, 305);
  }
}

void drawScreenMessage() {
  if (gameState == STATE_START) {
    fill(0, 190);
    rect(42, 190, 316, 170);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(30);
    text("8-BIT HIGHWAY", width / 2, 234);
    textSize(16);
    text("LEFT / RIGHT TO CHANGE LANES", width / 2, 282);
    text("PRESS SPACE TO START", width / 2, 316);
  } else if (gameState == STATE_PAUSED) {
    fill(0, 180);
    rect(86, 238, 228, 96);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(30);
    text("PAUSED", width / 2, 274);
    textSize(16);
    text("PRESS P TO RESUME", width / 2, 308);
  }
}

float laneCenter(int lane) {
  return ROAD_X + ROAD_W / LANE_COUNT * lane + ROAD_W / LANE_COUNT / 2.0;
}

boolean rectsOverlap(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh) {
  return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by;
}

void keyPressed() {
  if (gameState == STATE_START && (key == ' ' || key == ENTER || key == RETURN)) {
    resetGame();
  } else if (gameState == STATE_GAME_OVER && (key == 'r' || key == 'R')) {
    resetGame();
  } else if (gameState == STATE_PLAYING) {
    if (key == 'p' || key == 'P') {
      gameState = STATE_PAUSED;
      return;
    }
    if (keyCode == LEFT || key == 'a' || key == 'A') {
      player.moveLeft();
    }
    if (keyCode == RIGHT || key == 'd' || key == 'D') {
      player.moveRight();
    }
  } else if (gameState == STATE_PAUSED && (key == 'p' || key == 'P')) {
    gameState = STATE_PLAYING;
  }
}

void resetGame() {
  resetRound();
  gameState = STATE_PLAYING;
}

void resetRound() {
  player = new PlayerCar(1, height - 92);
  enemies.clear();
  coins.clear();
  roadOffset = 0;
  speed = 5;
  score = 0;
  spawnTimer = 40;
  coinTimer = 90;
}

class PlayerCar {
  float x;
  float y;
  float w = 30;
  float h = 50;
  int lane = 1;
  float targetX;

  PlayerCar(int startLane, float startY) {
    lane = startLane;
    targetX = laneCenter(lane) - w / 2;
    x = targetX;
    y = startY;
  }

  void update() {
    targetX = laneCenter(lane) - w / 2;
    x += (targetX - x) * 0.35;
  }

  void moveLeft() {
    lane = max(0, lane - 1);
  }

  void moveRight() {
    lane = min(LANE_COUNT - 1, lane + 1);
  }

  void draw() {
    drawPixelCar(x, y, color(224, 38, 38), true);
  }
}

class EnemyCar {
  float x;
  float y;
  float w = 30;
  float h = 50;
  color bodyColor;

  EnemyCar(float startX, float startY, color c) {
    x = startX;
    y = startY;
    bodyColor = c;
  }

  void update() {
    y += speed;
  }

  void draw() {
    drawPixelCar(x, y, bodyColor, false);
  }
}

class Coin {
  float x;
  float y;
  float size = 20;

  Coin(float startX, float startY) {
    x = startX;
    y = startY;
  }

  void update() {
    y += speed;
  }

  void draw() {
    fill(120, 81, 18);
    rect(x + 3, y + 3, 14, 14);
    fill(255, 208, 44);
    rect(x + 2, y, 16, 20);
    fill(255, 244, 126);
    rect(x + 7, y + 4, 6, 12);
  }
}

void drawPixelCar(float x, float y, color bodyColor, boolean playerCar) {
  fill(13);
  rect(x - 5, y + 8, 5, 12);
  rect(x + 30, y + 8, 5, 12);
  rect(x - 5, y + 32, 5, 12);
  rect(x + 30, y + 32, 5, 12);

  fill(bodyColor);
  rect(x, y + 6, 30, 38);
  rect(x + 5, y, 20, 50);

  fill(230);
  if (playerCar) {
    rect(x + 7, y + 8, 16, 9);
    rect(x + 7, y + 31, 16, 8);
  } else {
    rect(x + 7, y + 11, 16, 8);
    rect(x + 7, y + 34, 16, 9);
  }

  fill(255, 239, 94);
  rect(x + 4, y + 1, 6, 4);
  rect(x + 20, y + 1, 6, 4);
}
