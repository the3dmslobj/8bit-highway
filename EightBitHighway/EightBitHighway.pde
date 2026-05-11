final int SCREEN_W = 400;
final int SCREEN_H = 600;
final int ROAD_X = 70;
final int ROAD_W = 260;
final int LANE_COUNT = 3;

PlayerCar player;
ArrayList<EnemyCar> enemies = new ArrayList<EnemyCar>();

float roadOffset = 0;
float speed = 5;
int score = 0;
int bestScore = 0;
int spawnTimer = 0;
boolean gameOver = false;

void setup() {
  size(400, 600);
  noSmooth();
  textFont(createFont("Monospaced", 18));
  resetGame();
}

void draw() {
  background(21, 120, 54);
  drawRoad();
  drawRoadside();

  if (!gameOver) {
    updateGame();
  }

  for (EnemyCar enemy : enemies) {
    enemy.draw();
  }
  player.draw();
  drawHud();
}

void updateGame() {
  score++;
  speed = 5 + score / 900.0;
  roadOffset = (roadOffset + speed) % 80;

  player.update();
  updateEnemies();

  spawnTimer--;
  if (spawnTimer <= 0) {
    spawnEnemy();
    spawnTimer = max(26, int(70 - speed * 5));
  }
}

void updateEnemies() {
  for (int i = enemies.size() - 1; i >= 0; i--) {
    EnemyCar enemy = enemies.get(i);
    enemy.update();

    if (enemy.y > height + 70) {
      enemies.remove(i);
    } else if (rectsOverlap(player.x, player.y, player.w, player.h, enemy.x, enemy.y, enemy.w, enemy.h)) {
      gameOver = true;
      bestScore = max(bestScore, score);
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

  if (gameOver) {
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

float laneCenter(int lane) {
  return ROAD_X + ROAD_W / LANE_COUNT * lane + ROAD_W / LANE_COUNT / 2.0;
}

boolean rectsOverlap(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh) {
  return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by;
}

void keyPressed() {
  if ((key == 'r' || key == 'R') && gameOver) {
    resetGame();
  } else if (!gameOver) {
    if (keyCode == LEFT || key == 'a' || key == 'A') {
      player.moveLeft();
    }
    if (keyCode == RIGHT || key == 'd' || key == 'D') {
      player.moveRight();
    }
  }
}

void resetGame() {
  player = new PlayerCar(1, height - 92);
  enemies.clear();
  roadOffset = 0;
  speed = 5;
  score = 0;
  spawnTimer = 40;
  gameOver = false;
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
