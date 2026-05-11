# 8-bit highway video explanation

This document explains the project in a simple order for a school video presentation.

## 1. project introduction

8-bit highway is a retro-style 2d car racing game made with processing.

The goal of the game is to avoid enemy cars, collect coins, and get the highest score possible. the game uses a simple three-lane road system, so the player only moves left or right between lanes.

The start screen also lets the player choose between four car styles before starting.

The game also generates simple retro sounds in code. there is a subtle background melody while playing, plus sound effects for moving lanes, collecting coins, choosing a car, and crashing.

## 2. how the game works

The game has four main states:

- start screen
- playing
- paused
- game over

The variable `gameState` stores the current state.

```java
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_PAUSED = 2;
final int STATE_GAME_OVER = 3;
```

This makes the code easier to understand because the game can decide what to do based on the current state.

For example, the game only updates movement, enemies, coins, and score when the state is `STATE_PLAYING`.

```java
if (gameState == STATE_PLAYING) {
  updateGame();
}
```

Sound can be muted or unmuted with the `m` key.

## 3. setup and draw

Processing starts with two important functions:

- `setup()`
- `draw()`

`setup()` runs once when the game starts. in this project it sets the window size, turns off smoothing for a pixel-art look, sets the font, starts the generated audio engine, and prepares the first round.

```java
void setup() {
  size(400, 600);
  noSmooth();
  textFont(createFont("Monospaced", 18));
  audio = new AudioEngine();
  audio.startMusic();
  resetRound();
}
```

`draw()` runs again and again every frame. it draws the road, objects, player car, score, and screen messages.

```java
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
```

## 4. road and movement

The road is drawn with rectangles. the road has three lanes.

```java
final int ROAD_X = 70;
final int ROAD_W = 260;
final int LANE_COUNT = 3;
```

The lane position is calculated using the `laneCenter()` function.

```java
float laneCenter(int lane) {
  return ROAD_X + ROAD_W / LANE_COUNT * lane + ROAD_W / LANE_COUNT / 2.0;
}
```

The player does not move freely across the road. instead, the player has a lane number.

- lane `0` is the left lane
- lane `1` is the middle lane
- lane `2` is the right lane

When the player presses left, the lane number decreases. when the player presses right, the lane number increases.

```java
void moveLeft() {
  lane = max(0, lane - 1);
}

void moveRight() {
  lane = min(LANE_COUNT - 1, lane + 1);
}
```

`max()` and `min()` stop the player from moving outside the road.

## 5. player car

The player car is stored in the `PlayerCar` class.

Important variables:

- `x` and `y` store the car position
- `w` and `h` store the car size
- `lane` stores the current lane
- `style` stores which player car design is selected
- `targetX` stores where the car should move

```java
class PlayerCar {
  float x;
  float y;
  float w = 30;
  float h = 50;
  int lane = 1;
  int style = selectedPlayerStyle;
  float targetX;
}
```

The player car smoothly moves toward the selected lane.

```java
targetX = laneCenter(lane) - w / 2;
x += (targetX - x) * 0.35;
```

This makes the movement look smoother than instantly jumping to the lane.

## 6. enemy cars

Enemy cars are stored in an `ArrayList`.

```java
ArrayList<EnemyCar> enemies = new ArrayList<EnemyCar>();
```

An `ArrayList` is useful because the game can add new enemy cars and remove old ones while the game is running.

Enemy cars spawn at the top of the screen and move downward.

```java
void update() {
  y += max(2.6, speed + enemySpeedBoost(type));
}
```

The game has different enemy vehicle types. compact cars, trucks, sports cars, and vans have different sizes and small speed differences. this makes the road feel less repetitive and changes how much space each enemy takes up.

When an enemy car moves past the bottom of the screen, it is removed.

```java
if (enemy.y > height + 70) {
  enemies.remove(i);
}
```

## 7. coins

Coins work in a similar way to enemy cars.

They are stored in another `ArrayList`.

```java
ArrayList<Coin> coins = new ArrayList<Coin>();
```

Coins spawn in random lanes and move downward.

```java
void spawnCoin() {
  int lane = int(random(LANE_COUNT));
  coins.add(new Coin(laneCenter(lane) - 10, -30));
}
```

If the player touches a coin, the score increases by 150 points.

```java
score += 150;
coins.remove(i);
```

## 8. score and difficulty

The score increases every frame while the game is playing.

```java
score++;
```

The speed also increases as the score gets higher.

```java
speed = 5 + score / 900.0;
```

This means the game slowly becomes harder over time.

## 9. collision detection

The game uses rectangle collision detection.

This function checks if two rectangles are touching.

```java
boolean rectsOverlap(float ax, float ay, float aw, float ah, float bx, float by, float bw, float bh) {
  return ax < bx + bw && ax + aw > bx && ay < by + bh && ay + ah > by;
}
```

The same function is used for enemy cars and coins.

If the player hits an enemy car, the game changes to game over.

```java
gameState = STATE_GAME_OVER;
bestScore = max(bestScore, score);
```

If the player touches a coin, the player gets bonus points instead.

## 10. keyboard controls

Keyboard input is handled by the `keyPressed()` function.

Controls:

- `space` or `enter` starts the game
- `left arrow` or `a` moves left
- `right arrow` or `d` moves right
- `p` pauses and resumes
- `r` restarts after game over

The pause feature works by changing the game state.

```java
if (key == 'p' || key == 'P') {
  gameState = STATE_PAUSED;
  return;
}
```

When the game is paused, pressing `p` again changes the state back to playing.

```java
gameState = STATE_PLAYING;
```

## 11. drawing the cars

The game does not use image files for the cars. instead, the cars are drawn using rectangles.

This keeps the project simple and easy to explain.

```java
void drawPixelCar(float x, float y, color bodyColor, boolean playerCar) {
  fill(bodyColor);
  rect(x, y + 6, 30, 38);
  rect(x + 5, y, 20, 50);
}
```

Using `noSmooth()` and rectangle shapes helps create the 8-bit style.

## 12. suggested video order

Use this order when explaining the project in a video:

1. show the game running
2. explain the goal of the game
3. show the controls
4. explain `setup()` and `draw()`
5. explain `gameState`
6. explain lane movement
7. explain enemy cars
8. explain coins and score
9. explain collision detection
10. explain pause, restart, and game over

## 13. short speaking script

Here is a simple script you can use or modify:

Hello, this is my processing project called 8-bit highway. it is a 2d retro car racing game. the player controls a car on a three-lane road. the goal is to avoid enemy cars, collect coins, and get the highest score.

The game uses different states, such as start, playing, paused, and game over. this is controlled by the `gameState` variable. when the game is playing, the program updates the player, enemies, coins, score, and road movement. when the game is paused, the game still draws the screen but does not update the gameplay.

The player movement is lane-based. the player has a lane number, and pressing left or right changes the lane. the car then moves smoothly toward the center of that lane.

Enemy cars and coins are stored in arraylists. this allows the game to create new objects while the game is running and remove them when they go off screen or are collected. the enemy cars have multiple types, including compact cars, trucks, sports cars, and vans.

Collision detection uses rectangles. if the player rectangle overlaps with an enemy car rectangle, the game is over. if the player overlaps with a coin rectangle, the score increases by 150 points.

The score increases over time, and the speed also increases as the score gets higher. this makes the game more difficult the longer the player survives.

The graphics are drawn with simple rectangles instead of image files. this makes the project easier to understand and gives it a simple 8-bit style.

The audio is also generated in code instead of using sound files. the background music is kept quiet so it does not distract from the sound effects.

## 14. possible future improvements

If more time is available, the game could be improved with:

- saved high score
- custom pixel-art sprites
- power-ups
