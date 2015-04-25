/*
CONTROLS

P1: WASD -Move
    JKL - Attack
    ; - Throw
    N - Block
    Space - Dash
    
P2: Arrow Keys - Move
    456 - Attack
    + - Throw
    1 - Block
    0 - Dash


FEATURES
  -Can cancel any move into its up/down equivalent after inputting move.
  -Dash Bar not visible when climbing
  -Damage taken reduced when climbing
  
  
  [Temporarily] REMOVED FEATURES and TBI FEATURES
  -Projectiles
  -Clashes
  -Controller Support
  -Obstacles
  -Sliding
  -Climbing = invinciblity
  -3 Players?
  
 I DUNNO BRAH THAT LOOKS LIKE A BULLET WOUND TO ME -Deal with NumPad counting as ARROW KEYS when SHIFT is HELD
 */


void setup()
{
  size(wSet, hSet); //window size, should be bigger than set, use preset
  frameRate(60); //60 FPS OR BUST. IF SOMEBODY ASKS FOR A WINDOW OF EXECUTION BUFF I'M GOING TO DOUBLE IT AND PUT THE FRAMERATE AT 120
  rectMode(CENTER); //rectangle origin coordinates are center of rect
  
  //creates Sound Files
  minim = new Minim(this);
  
  //Character Select Music
  mp3[0] = minim.loadFile("It was Called Victim.mp3", 2048);//, 2048);

  //Stage Music; Randomly selects from the ones listed every time a new game starts.
  mp3[1] = minim.loadFile("A Fixed Idea.mp3", 2048);  
  mp3[2] = minim.loadFile("Home Sweet Grave.mp3", 2048);
  mp3[3] = minim.loadFile("Liquor Bar & Drunkard.mp3", 2048);
  mp3[4] = minim.loadFile("Meet Again.mp3", 2048);
  mp3[5] = minim.loadFile("No Mercy.mp3", 2048); 
  mp3[6] = minim.loadFile("The March of The Wicked King.mp3", 2048);

  //FONT
  gameFont = loadFont("Gulim-20.vlw");
  textAlign(CENTER);
  
  //Purely for testing purposes. Ignored if character select is passed.
  
  //draws Player 1 at left center of screen, with width 50, height 70, movement speed 10, red, 
  player1 = new Player(character[s1][0], width * .25, height/2, character[s1][1], character[s1][2], character[s1][3],  color(character[s1][4], character[s1][5], character[s1][6]));//, false, false, false);

  //draws Player 2 at right center of screen, with width 50, height 70, movement speed 10, blue, 
  player2 = new Player2(character[s2][0], width * .75, height/2, character[s2][1], character[s2][2], character[s2][3],  color(character[s2][4], character[s2][5], character[s2][6]));
  //player2 = new Player2(health2, width * .75, height/2, 50, 70, 10, color(fillD, fillE, fillF, alpha2), false, false, false);
  
}



void draw()
{
  //GREEN ON BLACK IS A SCIENTIFICALLY EASIEST TO SEE BECAUSE OF SOMETHING TO DO WITH LIGHT FREQUENCIES OR SOME JAZZ
  background(0);

  println(p2TakenHit);
  
  //if the game hasn't started, runs the menu, and plays the select music. Closes game music when it runs.
  if(!gameStarted)
  {
    charSelect();
  }
  
  //Runs if the game has ended: as in one player has gotten two rounds. Resets pretty much everything. If the game hasn't started, runs the menu, and plays the select music. Closes game music when it runs.
  else if(gameEnded)
  {
    fill(255);
    text("Retry? Hit Enter for Yes, Backspace for Character Select", wSet/2, hSet/2);
    bgm = false;
    
    //RESET EVERYTHING
    p1Round = p2Round = 0;
    round = 0;
    player1.reset();
    player2.reset();
    p1Win = p2Win = false;
    
    //Resets stage if players hit retry
    if(retry)
    {
      gameEnded = false;
      gameStarted = true;
      reset = true;      
      bgm = false;
      mp3[mPlayer].pause(); 
      roundStart = true;
      player2Dead = player1Dead = false;      
      retry = false; 
      time = 1;      
    }
    
    //Returns to menu otherwise
    else if(menu)
    {
      mp3[mPlayer].pause(); 
      gameEnded = gameStarted = bgm = menu = false;
      player2Dead = player1Dead = false;
      time = 1;
    }

  }

  //WE IN THERE. Executes if the game is running.
  else if(gameStarted)
  {
    drawStage();
    HUD();
    
    //Runs new round if any player is dead or time is over
    if(time <= 0 || player1Dead || player2Dead) reset = true;
    if(reset) newRound();
    
    //Runs music on new game
    if(!bgm)
    {
      mPlayer = int(random(1, 7));
      mp3[mPlayer].rewind();
      mp3[mPlayer].loop();
      bgm = true;
    }
    
    //Gets players displayed, attacking, moving, etc.
    player1.display();  
    player1.alive();
    
    if(!player1Dead && roundStart)
    {
      player1.move();
      player1.block();
      player1.attack();
      player1.push();
    }

    player2.display();  
    player2.alive();  
    
    if(!player2Dead && roundStart)
    {
      player2.move();
      player2.block();
      player2.attack();
      player2.push();
    }
  }
}

//Heads up display. Runs only if game is in session.
void HUD()
{
  //Writes FrameRate;
  fill(255);
  textFont(gameFont, 25);
  text(int(frameRate), wSet - 30, 25);

  //Timer counts down if the game has started.
  if(roundStart) time = s - millis()/1000;

  //Writes timer. if <0, runs time up code.
  fill(0, 255, 255);
  if (time <= 10) fill(255, 0, 0);
  else if (time <= 25) fill(255, 255, 0);
  if (time > 0)
    text(time, width/2, 25);
  else if (time <= 0) time = 0;


  //Draw Health Bar and Round Counters
  rectMode(CORNER);
  stroke(0);
  fill(barHue);
  rect(wSet/12, 2, wSet/3, 30);
  rect(width- wSet/12 - wSet/3, 2, wSet/3, 30);
  
  //Draws red health fill for players.
  //Scales health to equate to range 100 - 0 (using map function). Since characters have differing health, equations would otherwise not work properly.
  noStroke();
  fill(255, 0, 0);
  health1display = ceil(map(health1, 0, character[s1][0], 0, 100));
  health2display = ceil(map(health2, 0, character[s2][0], 0, 100));
  rect(wSet/12, 2, health1display * wSet/300, 30);
  rect(width- wSet/12 - health2display * wSet/300, 2, health2display * wSet/300, 30);
     
  rectMode(CENTER);
  
  
  //Draws Round Counters. Fills in with player colors if a round is won.

  if(p1Round > 0) fill(character[s1][4], character[s1][5], character[s1][6]);
  else fill(255);
  rect(wSet/14,  9, 14, 14);
  if(p1Round > 1) fill(character[s1][4], character[s1][5], character[s1][6]);
  else fill(255);
  rect(wSet/14, 25, 14, 14);

  //Same as above for Player 2.

  if(p2Round > 0) fill(character[s2][4], character[s2][5], character[s2][6]);
  else fill(255);    
  rect(width - wSet/14,  9, 14, 14);
  if(p2Round > 1) fill(character[s2][4], character[s2][5], character[s2][6]);
  else fill(255);  
  rect(width - wSet/14, 25, 14, 14);

}


//Resets positions and round count. If player has won two games, game is over.
void newRound()
{
  fill(255);
  
  //Determines round time
  if (roundStart) t = frameCount;
  roundStart = false;
  
  
  //If round time is over a certain amount, checks to see if anybody is dead. Otherwise, displays the time up message.
  if(frameCount < t + textTime[0])
  {  
    if(player1Dead && player2Dead) text("Double Knockout", wSet/2, hSet/2);
    
    else if (player2Dead) p1Win = true;
    else if (player1Dead) p2Win = true;

    else if (time <= 0)
    {
      text("Time Up", wSet/2, hSet/2 - 20);
      if(health1display > health2display) p1Win = true;
      else if(health1display < health2display) p2Win = true;
      else text("Draw", wSet/2, hSet/2 + 20);    
    }
    
    //Runs first round message
    else if (round == 0 || round == 1) text("Let's Punk", wSet/2, hSet/2);
    
    //If conditions are fulfilled, displays Win text
    if(p1Win) text("Player 1 Wins", wSet/2, hSet/2 + 20);
    if(p2Win) text("Player 2 Wins", wSet/2, hSet/2 + 20);
  }

  else if(frameCount < + t + textTime[0] + textTime[1])
  {
    //1 frame calculation of round counts. Ups round counts if one player wins.
    if(frameCount < t + textTime[0] + 1)    
    {
      if(player1Dead && player2Dead);
      else if(p2Win) p2Round++;
      else if(p1Win) p1Round++;
      
      p1Win = p2Win = false;
      
      round++;
    }
      
    //Displays Win game message if either player has more than one round 
    if(p1Round >= 2)
    {
      text("Game: Player 1", wSet/2, hSet/2);
    }
    else if(p2Round >= 2)
    {
      text("Game: Player 2", wSet/2, hSet/2);
    }

    //Otherwise, resets the character positions and health.
    else
    {
      player1.reset();
      player2.reset();
      text("Round " + round, wSet/2, hSet/2);
    }
  }
  
  //Executes next round, otherwise ends game if player has won.
  else if(frameCount < t + textTime[0] + textTime[1] + textTime[2] && !gameEnded)
  {
    if(p1Round >= 2 || p2Round >= 2)
    {
      gameEnded = true;
    }

    text("GO", wSet/2, hSet/2);
  }
  
  //Resets the timer if the game hasn't ended.
  else if (!gameEnded)
  {
    //Time Reset
    s = millis()/1000 + roundTime;// 99;
    
    roundStart = true;
    reset = false;
  }
}


//Draws stage boundaries in neon green
void drawStage()
{
  //neon green? It's easier to see.
  fill(30, 220, 30);
  noStroke();

  //top boundary
  rect(width/2, topStageY, width, topStageH);

  //bottom boundary
  rect(width/2, height - 5, width, topStageH);

  //left boundary
  rect(5, height/2, sideStageW, height);

  //right boundary
  rect(width -5, height/2, sideStageW, height); 
}

//BUTTONS
void keyPressed()
{
  //Shared with Char_Select Page
  if(!gameStarted) selection1();
  
  //Player 1 Movement, block, and dash keys. Needed doubles for every key due to SHIFT, which was supposed to be disabled. :V
  if (key == up1 || key == up2) keyUp1 = true;
  if (key == down1  || key == down2) keyDown1 = true;
  if (key == left1 || key == left2) keyLeft1 = true;
  if (key == right1 || key == right2) keyRight1 = true;
  
  if (key == block1) blocking1 = true; // || key == block2
  if (key == dash1) dashing1 = true;

  //Player 2 Movement, block, and dash keys
  if (key == CODED)
  {
    if (keyCode == UP) keyUp2 = true; 
    if (keyCode == DOWN) keyDown2 = true; 
    if (keyCode == LEFT) keyLeft2 = true; 
    if (keyCode == RIGHT) keyRight2 = true;
  }
  if (key == block3) blocking2 = true;
  if (key == dash2) dashing2 = true;
  
  
//Attempt to Disable Shift Key. Doesn't work. :(
  if (key == SHIFT) key = 0;
  if (key == CODED) if (keyCode == SHIFT) key = 0;  //if(key == block1) blocking1 = true;



  //Activates throw on press for player 1
  if(key == throw1 || key == throw2)
  {
    if(!p1Attacking && !throwing1) 
    {
      throwing1 = true;
      p1ThrowTime = frameCount; 
    }
  }
  //Activates throw on press for player 2
  if(key == throw3)
  {
    if(!p2Attacking && !throwing2) 
    {
      throwing2 = true;
      p2ThrowTime = frameCount; 
    }
  }
  
    
  //Player 1 Attack keys. Only initiates the attack if currently no attacks are initiating.
  for (int i = 0; i < player1AttackKey.length; i++)
  {
    if (key == player1AttackKey[i] && player1Action[0] == player1Action[1] == player1Action[2] == false && !throwing1)// && !p1Attacking)
    { 
      player1Action[i] = true;
      p1Starttime = frameCount;
    }
  }
  
  //Player 2 Attack keys. Only initiates the attack if currently no attacks are initiating.
  for (int i = 0; i < player2AttackKey.length; i++)
  {
    if (key == player2AttackKey[i] && player2Action[0] == player2Action[1] == player2Action[2] == false && !throwing2)
    { 
      player2Action[i] = true;
      p2Starttime = frameCount;
    }
  }
  
  //Saves screencap.
  if (paused && key == 0)
  {
    saveFrame("shots/shot-#######.jpg");
    println("Frame Saved");
  }
  
  if(gameEnded)
  {
    //Restarts match with same characters
    if(key == ENTER || key == RETURN) retry = true;
    //Goes back to character select screen
    if(key == BACKSPACE || key == DELETE) menu = true;
  }
  
  //Pauses game.
  if (key == '`' && gameStarted)
  {    
    if (!paused)
    {
      paused = !paused;
      textSize(30);
      fill(200, 255, 200);
      text("PAUSED", wSet/2, hSet/2 - 70);
      noLoop();
    }
    
    else
    {
      paused = !paused;
      loop();
    }
  }
}


void keyReleased()
{
  //Stops moving characters if released. Player 1 keys
  if (key == up1 || key == up2) keyUp1 = false;
  if (key == down1 || key == down2) keyDown1 = false; //
  if (key == left1 || key == left2) keyLeft1 = false; //
  if (key == right1 || key == right2) keyRight1 = false;

  if (key == block1 || key == block2) blocking1 = false;
  if (key == dash1) dashing1 = false;

  //Player 2 keys.
  if (key == CODED)
  {
    if (keyCode == UP) keyUp2 = false; 
    if (keyCode == DOWN) keyDown2 = false; 
    if (keyCode == LEFT) keyLeft2 = false;
    if (keyCode == RIGHT) keyRight2 = false;
  }

  if (key == block3) blocking2 = false;
  if (key == dash2) dashing2 = false;
}



//Determines if moves are making contact with player1 and player2, respectively.
boolean hit1(float x_1, float y_1, float width_1, float height_1)
{
  return !(x_1 - width_1/2 > player1.x + player1.charWidth/2 || x_1+width_1/2 < player1.x - player1.charWidth/2 || y_1 - height_1/2 > player1.y + player1.charHeight/2 || y_1+height_1/2 < player1.y - player1.charHeight/2);
}


boolean hit2(float x_1, float y_1, float width_1, float height_1)
{
  return !(x_1 - width_1/2 > player2.x + player2.charWidth/2 || x_1+width_1/2 < player2.x - player2.charWidth/2 || y_1 - height_1/2 > player2.y + player2.charHeight/2 || y_1+height_1/2 < player2.y - player2.charHeight/2);
}
