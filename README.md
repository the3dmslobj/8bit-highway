# 8-Bit Highway

A retro-style 2D car racing game made with Processing.

The player drives on a three-lane highway, avoids enemy cars, collects coins, and tries to get the highest score.

## Features

- Three-lane player movement
- Moving road and lane lines
- Enemy cars that move down the road
- Multiple enemy vehicle types, including compact cars, trucks, sports cars, and vans
- Four selectable player car styles
- Collectible coins that add bonus points
- Collision detection
- Score and best score
- Start screen
- Pause and resume
- Game over screen
- Restart option
- Speed increases over time

## Controls

- `left arrow` or `a`: move one lane left
- `right arrow` or `d`: move one lane right
- `1`-`4`: choose a player car style on the start or game over screen
- `c`: cycle player car styles on the start or game over screen
- `space` or `enter`: start the game
- `p`: pause or resume
- `r`: restart after game over

## Scoring

- The score increases while the game is running.
- Each coin gives 150 bonus points.
- The best score is saved while the sketch is open.

## How to Run

1. Install Processing 4.
2. Open `EightBitHighway/EightBitHighway.pde`.
3. Click the Run button.

## Main Code Ideas

- `gameState` controls whether the game is starting, playing, paused, or over.
- `PlayerCar` stores the player's lane and position.
- `EnemyCar` stores each obstacle car.
- `Coin` stores each collectible coin.
- `ArrayList` is used so the game can add and remove enemies and coins while running.
