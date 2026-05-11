# 8-Bit Highway video recording script

Use this as a guide while recording the screen. It is written like a normal explanation, not a formal class presentation. You do not need to read every line exactly. Speak naturally and use the "show on screen" notes to know what to demonstrate.

## Before recording

- Open the project in Processing.
- Open `EightBitHighway/EightBitHighway.pde`.
- Be ready to run the sketch.
- If you want to show the audio code, also open `AudioEngine.java`.

## Short version

### 1. Start the video

Show the Processing window with the project open.

Say:

> This is our project, 8-Bit Highway. It is a retro-style car game made in Processing. The idea is simple: the player drives on a three-lane road, avoids enemy cars, collects coins, and tries to get the highest score.

### 2. Run the game

Click Run and show the start screen.

Say:

> When the game starts, it shows the title screen. From here, the player can choose different car styles using the number keys or the C key. The game also shows the basic controls, so the player knows how to start and how to change lanes.

Press `C` or `1` to `4` a few times.

Say:

> We added four player car styles, so the game feels a bit more personal instead of always using the same car.

### 3. Show gameplay

Press Space to start. Move left and right.

Say:

> The player does not move freely like a mouse cursor. Instead, the road is split into three lanes. Pressing left or right moves the car one lane at a time. This keeps the controls simple and makes the game feel like an old arcade game.

Collect a coin if possible.

Say:

> Coins appear randomly in lanes. When the player collects one, the score gets a bonus. The normal score also increases while the game is running, so surviving longer is important too.

Avoid some cars, then crash into one.

Say:

> Enemy cars spawn at the top and move down the screen. There are different types, like compact cars, trucks, sports cars, and vans. They have different sizes and small speed differences, so the road does not feel exactly the same every time.

After crashing:

> When the player hits an enemy car, the game changes to the game over screen. It saves the best score for the current session, and the player can restart with R.

### 4. Explain the main code idea

Show the top of `EightBitHighway.pde`, especially the constants and variables.

Say:

> The project uses a few main game states: start, playing, paused, and game over. The variable `gameState` controls which mode the game is in. That way, the game only updates movement, enemies, coins, and score while it is actually playing.

Show `setup()` and `draw()`.

Say:

> Like most Processing projects, the main structure is `setup()` and `draw()`. `setup()` runs once at the beginning. It sets the window size, font, pixel-art style, audio, and resets the first round. `draw()` runs every frame. It draws the road, cars, coins, score, and screen messages.

Show `updateGame()`.

Say:

> The `updateGame()` function is where most of the active gameplay happens. It increases the score, increases speed over time, moves the road lines, updates the player, updates enemies and coins, and spawns new objects when their timers reach zero.

### 5. Explain movement

Show `laneCenter()` and the `PlayerCar` class.

Say:

> The road has three lanes. The function `laneCenter()` calculates the center of each lane. The player car stores its current lane as a number, so lane 0 is left, lane 1 is middle, and lane 2 is right.

Show `PlayerCar.update()`.

Say:

> The car moves smoothly toward the target lane instead of instantly jumping there. This line moves the car part of the distance toward the target each frame, which makes the movement look better.

### 6. Explain enemies and coins

Show `ArrayList<EnemyCar>` and `ArrayList<Coin>`.

Say:

> Enemies and coins are stored in ArrayLists. This is useful because the game needs to add new enemies and coins while it is running, and remove them after they go off screen or get collected.

Show `spawnEnemy()` and `spawnCoin()`.

Say:

> New enemies and coins spawn in random lanes. The enemy type is also random, so sometimes it is a truck, sometimes a sports car, and sometimes another type.

Show `rectsOverlap()`.

Say:

> For collisions, the game uses rectangle collision detection. It checks if the rectangle around the player overlaps the rectangle around an enemy or coin. If it overlaps an enemy, the game ends. If it overlaps a coin, the score increases.

### 7. Explain audio

Show `AudioEngine.java`.

Say:

> The sound is generated in code instead of using audio files. The audio engine creates simple square-wave sounds for the retro style. There is background music while playing, plus effects for moving, collecting coins, choosing a car, and crashing. The M key can mute or unmute the sound.

### 8. Show pause and restart

Run the game again if needed. Press `P`, then `P` again. Press `M` if you want to show mute.

Say:

> We also added pause and mute controls. Pause stops the active gameplay and music until the player resumes. Mute turns off the generated sounds.

### 9. End the video

Show the game running or the game over screen.

Say:

> Overall, this project combines drawing, keyboard input, classes, ArrayLists, collision detection, scoring, game states, and generated audio. The final result is a complete small arcade game made in Processing.

## Even shorter 1-minute script

> This is 8-Bit Highway, a retro-style car game made in Processing. The player drives on a three-lane road, avoids enemy cars, collects coins, and tries to get the highest score.
>
> On the start screen, the player can choose between four car styles. The controls are simple: left and right change lanes, space starts the game, P pauses, M mutes sound, and R restarts after game over.
>
> The main code uses game states for start, playing, paused, and game over. The game only updates the score, speed, enemies, coins, and collisions while it is in the playing state.
>
> The player car is stored in a class, and it moves smoothly toward the center of the selected lane. Enemy cars and coins are stored in ArrayLists because they are created and removed while the game is running.
>
> Collision detection uses rectangles. If the player touches a coin, the score increases by 150. If the player hits an enemy car, the game ends and the best score is updated.
>
> We also added generated retro audio in Java, so the game has background music and sound effects without needing separate sound files.
>
> So the project shows Processing drawing, keyboard input, classes, ArrayLists, collision detection, score tracking, difficulty increase, and audio.

## Natural phrases you can use

- "Here I am showing the start screen."
- "Now I am choosing a different car style."
- "The road is divided into three lanes."
- "The enemies are generated randomly, so each run is a little different."
- "The score increases over time, and coins add bonus points."
- "This part of the code controls the game state."
- "This class stores the player car information."
- "This ArrayList lets the game keep many enemies at once."
- "This function checks if two rectangles are touching."

