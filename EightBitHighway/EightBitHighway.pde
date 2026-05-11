final int SCREEN_W = 400;
final int SCREEN_H = 600;
final int ROAD_X = 70;
final int ROAD_W = 260;
final int LANE_COUNT = 3;
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_PAUSED = 2;
final int STATE_GAME_OVER = 3;
final int PLAYER_STYLE_RED = 0;
final int PLAYER_STYLE_BLUE = 1;
final int PLAYER_STYLE_GREEN = 2;
final int PLAYER_STYLE_YELLOW = 3;
final int PLAYER_STYLE_COUNT = 4;
final int ENEMY_COMPACT = 0;
final int ENEMY_TRUCK = 1;
final int ENEMY_SPORTS = 2;
final int ENEMY_VAN = 3;

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
int selectedPlayerStyle = PLAYER_STYLE_RED;

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
  int type = randomEnemyType();
  EnemyCar enemy = new EnemyCar(lane, -enemyHeight(type) - 10, type, enemyColor(type));
  enemies.add(enemy);
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
    text("CAR: " + playerStyleName(selectedPlayerStyle), width / 2, 296);
    text("R TO RESTART  C TO CHANGE", width / 2, 322);
  }
}

void drawScreenMessage() {
  if (gameState == STATE_START) {
    fill(0, 190);
    rect(36, 166, 328, 238);

    fill(255);
    textAlign(CENTER, CENTER);
    textSize(30);
    text("8-BIT HIGHWAY", width / 2, 208);
    textSize(16);
    text("LEFT / RIGHT TO CHANGE LANES", width / 2, 252);
    text("CAR: " + playerStyleName(selectedPlayerStyle), width / 2, 292);
    text("PRESS 1-4 OR C TO CHANGE", width / 2, 320);
    text("PRESS SPACE TO START", width / 2, 360);
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
  if (gameState == STATE_START) {
    if (key == ' ' || key == ENTER || key == RETURN) {
      resetGame();
    } else {
      handleStyleSelection();
    }
  } else if (gameState == STATE_GAME_OVER) {
    if (key == 'r' || key == 'R') {
      resetGame();
    } else {
      handleStyleSelection();
    }
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

void handleStyleSelection() {
  if (key == 'c' || key == 'C') {
    selectedPlayerStyle = (selectedPlayerStyle + 1) % PLAYER_STYLE_COUNT;
    player.style = selectedPlayerStyle;
  } else if (key >= '1' && key <= '4') {
    selectedPlayerStyle = key - '1';
    player.style = selectedPlayerStyle;
  }
}

String playerStyleName(int style) {
  if (style == PLAYER_STYLE_BLUE) {
    return "BLUE RACER";
  } else if (style == PLAYER_STYLE_GREEN) {
    return "GREEN ROADSTER";
  } else if (style == PLAYER_STYLE_YELLOW) {
    return "YELLOW MUSCLE";
  }
  return "RED CLASSIC";
}

color playerStyleColor(int style) {
  if (style == PLAYER_STYLE_BLUE) {
    return color(42, 124, 236);
  } else if (style == PLAYER_STYLE_GREEN) {
    return color(40, 190, 118);
  } else if (style == PLAYER_STYLE_YELLOW) {
    return color(241, 190, 36);
  }
  return color(224, 38, 38);
}

int randomEnemyType() {
  float roll = random(1);
  if (roll < 0.32) {
    return ENEMY_COMPACT;
  } else if (roll < 0.56) {
    return ENEMY_TRUCK;
  } else if (roll < 0.80) {
    return ENEMY_SPORTS;
  }
  return ENEMY_VAN;
}

float enemyWidth(int type) {
  if (type == ENEMY_TRUCK) {
    return 38;
  } else if (type == ENEMY_SPORTS) {
    return 28;
  } else if (type == ENEMY_VAN) {
    return 34;
  }
  return 30;
}

float enemyHeight(int type) {
  if (type == ENEMY_TRUCK) {
    return 62;
  } else if (type == ENEMY_SPORTS) {
    return 46;
  } else if (type == ENEMY_VAN) {
    return 56;
  }
  return 50;
}

float enemySpeedBoost(int type) {
  if (type == ENEMY_TRUCK) {
    return -0.7;
  } else if (type == ENEMY_SPORTS) {
    return 1.1;
  } else if (type == ENEMY_VAN) {
    return -0.2;
  }
  return 0;
}

color enemyColor(int type) {
  if (type == ENEMY_TRUCK) {
    return color(122, 132, 145);
  } else if (type == ENEMY_SPORTS) {
    color[] sportsColors = {
      color(179, 61, 211),
      color(236, 188, 28),
      color(37, 185, 220)
    };
    return sportsColors[int(random(sportsColors.length))];
  } else if (type == ENEMY_VAN) {
    color[] vanColors = {
      color(36, 194, 153),
      color(226, 103, 55),
      color(78, 103, 196)
    };
    return vanColors[int(random(vanColors.length))];
  }

  color[] compactColors = {
    color(38, 99, 220),
    color(236, 188, 28),
    color(179, 61, 211),
    color(36, 194, 153)
  };
  return compactColors[int(random(compactColors.length))];
}

class PlayerCar {
  float x;
  float y;
  float w = 30;
  float h = 50;
  int lane = 1;
  int style = selectedPlayerStyle;
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
    drawPlayerCar(x, y, style);
  }
}

class EnemyCar {
  float x;
  float y;
  float w;
  float h;
  int type;
  color bodyColor;

  EnemyCar(int lane, float startY, int enemyType, color c) {
    type = enemyType;
    w = enemyWidth(type);
    h = enemyHeight(type);
    x = laneCenter(lane) - w / 2;
    y = startY;
    bodyColor = c;
  }

  void update() {
    y += max(2.6, speed + enemySpeedBoost(type));
  }

  void draw() {
    drawEnemyCar(x, y, type, bodyColor);
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

void drawPlayerCar(float x, float y, int style) {
  color bodyColor = playerStyleColor(style);

  if (style == PLAYER_STYLE_BLUE) {
    drawPixelCar(x, y, bodyColor, true);
    fill(255, 255, 255);
    rect(x + 13, y + 1, 4, 48);
  } else if (style == PLAYER_STYLE_GREEN) {
    drawPixelCar(x, y, bodyColor, true);
    fill(255, 239, 94);
    rect(x + 4, y + 22, 22, 5);
    fill(20);
    rect(x + 8, y + 7, 14, 9);
  } else if (style == PLAYER_STYLE_YELLOW) {
    drawPixelCar(x, y, bodyColor, true);
    fill(20);
    rect(x + 3, y + 16, 24, 4);
    rect(x + 3, y + 30, 24, 4);
    fill(255, 96, 66);
    rect(x + 11, y - 4, 8, 5);
  } else {
    drawPixelCar(x, y, bodyColor, true);
  }
}

void drawEnemyCar(float x, float y, int type, color bodyColor) {
  if (type == ENEMY_TRUCK) {
    drawTruck(x, y, bodyColor);
  } else if (type == ENEMY_SPORTS) {
    drawSportsCar(x, y, bodyColor);
  } else if (type == ENEMY_VAN) {
    drawVan(x, y, bodyColor);
  } else {
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

void drawTruck(float x, float y, color bodyColor) {
  fill(13);
  rect(x - 5, y + 10, 5, 14);
  rect(x + 38, y + 10, 5, 14);
  rect(x - 5, y + 42, 5, 14);
  rect(x + 38, y + 42, 5, 14);

  fill(bodyColor);
  rect(x, y + 8, 38, 50);
  fill(104, 83, 68);
  rect(x + 4, y + 28, 30, 28);
  fill(224);
  rect(x + 8, y + 12, 22, 10);
  fill(255, 239, 94);
  rect(x + 5, y + 2, 7, 5);
  rect(x + 26, y + 2, 7, 5);
}

void drawSportsCar(float x, float y, color bodyColor) {
  fill(13);
  rect(x - 4, y + 9, 4, 10);
  rect(x + 28, y + 9, 4, 10);
  rect(x - 4, y + 30, 4, 10);
  rect(x + 28, y + 30, 4, 10);

  fill(bodyColor);
  rect(x + 2, y + 7, 24, 34);
  rect(x + 7, y, 14, 46);
  fill(230);
  rect(x + 7, y + 9, 14, 7);
  rect(x + 7, y + 31, 14, 7);
  fill(255, 239, 94);
  rect(x + 3, y + 1, 5, 4);
  rect(x + 20, y + 1, 5, 4);
  fill(20);
  rect(x + 5, y + 42, 18, 4);
}

void drawVan(float x, float y, color bodyColor) {
  fill(13);
  rect(x - 5, y + 9, 5, 12);
  rect(x + 34, y + 9, 5, 12);
  rect(x - 5, y + 38, 5, 12);
  rect(x + 34, y + 38, 5, 12);

  fill(bodyColor);
  rect(x, y + 4, 34, 48);
  rect(x + 4, y, 26, 56);
  fill(232);
  rect(x + 7, y + 8, 20, 8);
  rect(x + 7, y + 21, 20, 7);
  rect(x + 7, y + 35, 20, 7);
  fill(255, 239, 94);
  rect(x + 5, y + 1, 6, 4);
  rect(x + 23, y + 1, 6, 4);
}
