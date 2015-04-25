class Player
{
  //parameters start x, start y, width, height, movement speed on press, color, dash/block/cli.
  //float health1;
  int damage;
  float x;
  float y;
  float charWidth;
  float charHeight;
  float moveSpeed;
  color playerHue;
  
  boolean dashBreak;
  float dashLimit = 40;

  //Constructor, determines health, starting x & y, width & height, color. All other booleans start as false.
  Player(float _health, float _x, float _y, float _charWidth, float _charHeight, float _moveSpeed, color _playerHue)
  {
    health1 = _health;
    x = _x;
    y = _y;
    charWidth = _charWidth;
    charHeight = _charHeight;
    moveSpeed = _moveSpeed;
    playerHue = _playerHue;
  }

  void display()
  {
    //Draws player. Writes P1 over character.
    noStroke();
    fill(255);
    textSize(16);
    text("P1", x, y - charHeight/2 - 8);
    fill(playerHue);
    rect(x, y, charWidth, charHeight);
    
    //Draws Dash Bar, if not climbing
    if(!climbing1)
    {
      rectMode(CORNER);
      fill(barHue);
      rect(x - charWidth/2, y + charHeight *.66, charWidth, 10);
      fill(dashHue);
      rect(x - charWidth/2, y + charHeight *.66, dashLimit, 10);  
      rectMode(CENTER);
    }
  }

  //Involves actions for movement.
  void move()
  {
    //Changes movement speed. If dashing, runs function. If blocking, cuts it in half. If throwing, player is stopped until throw is completed (success or whiff).
    dash();    
    if (blocking1) moveSpeed = character[s1][3] / 2;
    if (frameCount < p1ThrowTime + 30) moveSpeed = 0;
    if (frameCount >= p1ThrowTime + 30) throwLock1 = false;

    //If player presses keys, moves character.
    if (keyUp1) y -= moveSpeed;
    if (keyDown1) y += moveSpeed;
    if (keyLeft1) x -= moveSpeed;
    if (keyRight1) x += moveSpeed;

    //Constrains player to walls of stage
    x = constrain(x, sideStageW + charWidth/2, width - sideStageW - charWidth/2);
    y = constrain(y, topStageH/2 + charHeight/2 + topStageY, height - topStageH - charHeight/2);

    //Auto player facing. Automatically faces opponent
    if (player1.x < player2.x)
    {
      fill(255);
      rect(x + charWidth *.25, y, charWidth *.25, charHeight/2);
      faceRight1 = true;
    }

    else if (player1.x >= player2.x)
    {
      fill(255);
      rect(x - charWidth *.25, y, charWidth *.25, charHeight/2);
      faceRight1 = false;
    }

   //Determines which player is higher.
   if(y < player2.y) above1 = true;
   else if(y >= player2.y) above1 = false;


    //Changes color if climbing. If climbing, damage taken is reduced.
    if (x == sideStageW + charWidth/2 || x == width - sideStageW - charWidth/2 || y == topStageH/2 + charHeight/2 + topStageY || y == height - topStageH - charHeight/2) 
    {
      climbing1 = true;
      fill(character[s1][4]/3, character[s1][5]/3, character[s1][6]/3);
      rect(x, y, charWidth/2, charHeight/2);
    }

    else climbing1 = false;
  }



  //formula for damage taking. If blocking is true, any attacks that connect deal no damage. If not blocking, damage received is normal.
  void block()
  {
    if(blocking1) playerHue = color(character[s1][4]/2, character[s1][5]/2, character[s1][6]/2); //Character becomes darker when blocking.
    else playerHue = color(character[s1][4], character[s1][5], character[s1][6]); //Default color

    //Prevents player from blocking while dashing
    if(dashing1) blocking1 = false;
    
    //Runs if player gets hit by enemy hitbox. Damage is reduced if player is climbing.
    if (p1GettingHit && !p1TakenHit && !blocking1)
    {
      if(climbing1) health1 -= p1Damage * .8;
      else health1 -= p1Damage;
      x += p1Knockback;
      y += p1KnockbackY;
      p1GettingHit = false;
      p1TakenHit = true;
      blocking1 = false;
      
      p1HitTime = frameCount;
    }

    //Runs if player gets thrown
    else if(p1GettingThrown && !p1TakenHit)
    {
      health1 -= p1Damage;
      x += p1Knockback;
      y += p1KnockbackY;
      p1GettingThrown = false;
      p1TakenHit = true;
      
      p1HitTime = frameCount;
    }

    //Runs if player blocks enemy hitbox. Reduces damage to 1/10, rounded down.
    else if (p1GettingHit && blocking1)
    {
      health1 -= floor(p1Damage/10);
      x += p1Knockback/2; //Deals horizontal knockback.
      p1GettingHit = false;
      p1HitTime = frameCount;
      playerHue = color(210);//Brightens color if attack is blocked.
    }
    
    //Character becomes Light Grey if a move is blocked.
    if(frameCount < p1HitTime + p1HitStun && blocking1)
    {
      blocking1 = true;
      //p1TakenHit = true; //if off, allows for multiple hits of block.
      p1HitStun *= .99;
      playerHue = color(200);
    }
        
    //Character becomes semi transparent if hit.     
    else if (frameCount < p1HitTime + p1HitStun && !blocking1) playerHue = color(character[s1][4]/2, character[s1][5]/2, character[s1][6]/2, 190);

    if (frameCount > p1HitTime + p1HitStun + 5) p1TakenHit = false;
  }


  //Returns dash value, which is limited based on long player holds the dash button.
  float dash()
  {
    //println("Dash Break: " + dashBreak);
    
    //If dash limit is reached, bar must drain before player can dash again. Movement speed defaults
    if (dashBreak)
    {
      dashing1 = false;
      dashLimit--;

      moveSpeed = character[s1][3];
      
      if (dashLimit <= 0)
      {
        dashLimit = 0;
        dashBreak = false;
      }
    }

    //If player presses dash button, and dash has not reached its limit, dashes.
    else if (!dashBreak && dashing1)
    {
      dashLimit+=5;
      if (dashLimit > charWidth)
      {
        dashLimit = charWidth;
        dashing1 = false;
        dashBreak = true;
      }

      moveSpeed = character[s1][3] * 2;
      
      moveSpeed+=.5; 
      if (moveSpeed > character[s1][3] * 3.2) moveSpeed = character[s1][3] * 3.2;
    }

    //If dash is released before bar empties, player can dash again after releasing.
    else if (!dashing1 && !dashBreak)
    {
      dashLimit--;

      if (dashLimit < 0)
      {
        dashLimit = 0;
        dashBreak = false;
      }

      moveSpeed--;
      if (moveSpeed < character[s1][3]) moveSpeed = character[s1][3];
    }

    return moveSpeed;
  } 

  //Generates Strikes and Throws. Projectiles are being cut from this build.
  void attack()
  {
    stroke(120);
    fill(120, 80);

    //Throws have 0 frame startup, high damage, etc. Occurs when two buttons pressed together. Cannot be blocked.
    if(throwing1 && !p1Attacking && !p1GettingHit && !blocking1 && !throwLock1)
    {
    println("throwing");
      
      if(keyUp1) //Up throw
      {
        rect(x + ADimensions[s1][10][0], y - ADimensions[s1][10][1], ADimensions[s1][10][2], ADimensions[s1][10][3]);   
        if(!p2TakenHit && hit2(x + ADimensions[s1][10][0], y - ADimensions[s1][10][1], ADimensions[s1][10][2], ADimensions[s1][10][3]))
        {
          p2Damage = ADimensions[s1][10][10]; //Sets opponent's throw damage
          p2Knockback = ADimensions[s1][10][7]; //Sets opponent's horizontal knockback
          p2KnockbackY = - ADimensions[s1][10][8]; //Sets opponent's vertical knockback
          p2HitStun = ADimensions[s1][10][11]; //Sets opponent's hitstun
          p2GettingThrown = true;
        }
      }

      
      else if(keyDown1) //Down throw. See up throw for specifics
      {
        rect(x + ADimensions[s1][10][0], y + ADimensions[s1][10][1], ADimensions[s1][10][2], ADimensions[s1][10][3]);           
        if(!p2TakenHit && hit2(x + ADimensions[s1][10][0], y + ADimensions[s1][10][1], ADimensions[s1][10][2], ADimensions[s1][10][3]))
        {
          p2Damage = ADimensions[s1][10][10];
          p2Knockback = ADimensions[s1][10][7];
          p2KnockbackY = ADimensions[s1][10][8];
          p2HitStun = ADimensions[s1][10][11]; //Sets opponent's hitstun
          p2GettingThrown = true;
        }
      }
      
      else if(faceRight1) //Right throw. See up throw for specifics
      {
        rect(x + ADimensions[s1][9][0], y + ADimensions[s1][9][1], ADimensions[s1][9][2], ADimensions[s1][9][3]);        
        if(!p2TakenHit && hit2(x + ADimensions[s1][9][0], y + ADimensions[s1][9][1], ADimensions[s1][9][2], ADimensions[s1][9][3]))
        {
          p2Damage = ADimensions[s1][9][10];
          p2Knockback = ADimensions[s1][9][7];
          p2KnockbackY = ADimensions[s1][9][8];
          p2HitStun = ADimensions[s1][9][11]; //Sets opponent's hitstun
          p2GettingThrown = true;
        }
      } 
      
      else if(!faceRight1) //Left throw. See up throw for specifics
      {
        rect(x - ADimensions[s1][9][0], y + ADimensions[s1][9][1], ADimensions[s1][9][2], ADimensions[s1][9][3]);
        if(!p2TakenHit && hit2(x - ADimensions[s1][9][0], y + ADimensions[s1][9][1], ADimensions[s1][9][2], ADimensions[s1][9][3]))
        {
          p2Damage = ADimensions[s1][9][10];
          p2Knockback = - ADimensions[s1][9][7];
          p2KnockbackY = ADimensions[s1][9][8];
          p2HitStun = ADimensions[s1][9][11]; //Sets opponent's hitstun
          p2GettingThrown = true;
        }
      }
      

      if(frameCount - p1ThrowTime > 1)
      {
        throwing1 = false;
        throwLock1 = true;
      }
    }


    //Generates color of hitboxes based on selected Character's colors.
    stroke(character[s1][4], character[s1][5], character[s1][6]);
    fill(character[s1][4], character[s1][5], character[s1][6], 128);



    //Generates attack of key pressed, corresponding to dimensions of ADimensions[selected character][input key][size, position, damage, etc]
    
    //[0] x position, [1] y position,[2] length, [3] width, [4] startup, [5] duration, [6] cooldown, [7] x knockback, [8] y knockback,  [10] damage
    
    for (int i = 0; i < player1AttackKey.length; i++)
    {
      //Executes only if player is not in the middle of being hit.
      if (!p1GettingHit && !throwing1 && player1Action[i])
      {

        p1Attacking = true;
        //Executes once startup phase has passed, and is less than the end of active time.
        if((frameCount > p1Starttime + ADimensions[s1][i][4]) && (frameCount <= p1Starttime + ADimensions[s1][i][4] + ADimensions[s1][i][5]) && !p1GettingHit)
        {
          //println("active");
          if (faceRight1) //Executes if facing right
          {
            if(keyUp1) i += player1AttackKey.length; //Switches between High/Low versions of each move during active frames of chosen move.
            if(keyDown1) i += player1AttackKey.length * 2; //i value corresponds to later values in Attack Array without overrunning the for loop.
            
            rect(x + ADimensions[s1][i][0], y + ADimensions[s1][i][1], ADimensions[s1][i][2], ADimensions[s1][i][3]); //Draws attack hitbox


                                    //[0] x position, [1] y position,[2] length, [3] width, [4] startup, [5] duration, 
                                    //[6] cooldown, [7] x knockback, [8], y knockback, [9] pushback, [10] damage, [11] hitstun
      

            //Executes if hitbox overlaps with enemy
            if (!p2GettingHit && !p2TakenHit && hit2(x + ADimensions[s1][i][0], y + ADimensions[s1][i][1], ADimensions[s1][i][2], ADimensions[s1][i][3]))
            {
              p2GettingHit = true; //Self explanatory
              x -= ADimensions[s1][i][9]; //Sets player pushback
              p2Knockback = ADimensions[s1][i][7]; //Sets opponent's horizontal knockback
              p2KnockbackY = ADimensions[s1][i][8]; //Sets opponent's vertical knockback
              p2Damage = ADimensions[s1][i][10]; //Sets opponent's damage
              p2HitStun = ADimensions[s1][i][11]; //Sets opponent's hitstun
            }
          }

          //Same as above, but if player is facing left
          if (!faceRight1)
          {
            if(keyUp1) i += player1AttackKey.length;// upAttack1 = true;
            if(keyDown1) i += player1AttackKey.length * 2;
            
            rect(x - ADimensions[s1][i][0], y + ADimensions[s1][i][1], ADimensions[s1][i][2], ADimensions[s1][i][3]); 

            if (!p2GettingHit && !p2TakenHit && hit2(x - ADimensions[s1][i][0], y + ADimensions[s1][i][1], ADimensions[s1][i][2], ADimensions[s1][i][3]))
            {
              
              p2GettingHit = true; //Derp
              x += ADimensions[s1][i][9]; //Sets player pushback
              p2Knockback = - ADimensions[s1][i][7]; //Sets opponent's horizontal knockback
              p2KnockbackY = ADimensions[s1][i][8]; //Sets opponent's vertical knockback
              p2Damage = ADimensions[s1][i][10]; //Sets opponent's damage
              p2HitStun = ADimensions[s1][i][11]; //Sets opponent's hitstun
            }
          }
        }
        
        //Cooldown frames. Player cannot act again until cooldown has ended.
        if ((frameCount > p1Starttime + ADimensions[s1][i][4] + ADimensions[s1][i][5]) && (frameCount <= p1Starttime + ADimensions[s1][i][4] + ADimensions[s1][i][5] + ADimensions[s1][i][6]))
        {
          //println("cooldown");
          p2GettingHit = false; //if (p2GettingHit) 
        }   

        
        //If cooldown has ended, the player is done with attacking. Player is ready to act again
        else if (frameCount > p1Starttime + ADimensions[s1][i][4] + ADimensions[s1][i][5] + ADimensions[s1][i][6])
        {
          //println("ready");
          if( i > (player1AttackKey.length * 2) -1 ) i -= player1AttackKey.length * 2; //Prevents out-of-bounds exceptions
          else if( i > player1AttackKey.length - 1 ) i -= player1AttackKey.length; //^
          
          player1Action[i] = false;       
          p2TakenHit = false; //if (p2TakenHit) 
          p1Attacking = false;
        }
      }
    }
    
    //Lightens if in the middle of recovery or startup
    if(p1Attacking || frameCount < p1ThrowTime + 30)
    { 
      playerHue = color(character[s1][4]/2 +100 , character[s1][5]/2 + 100 , character[s1][6]/2 + 100);
    }
  }

  //If players are colliding, allows players to push one another.
  void push()
  {
    if(hit2(x, y, charWidth,charHeight))
    {
      if(keyUp2 && above1)
      {
        y -= player2.moveSpeed;
        y = constrain(y, topStageH/2 + charHeight/2 + topStageY, player2.y - player2.charHeight/2 - charHeight/2 - 1);        
      }
      else if(keyDown2 && !above1)
      {
        y += player2.moveSpeed;
        y = constrain(y, player2.y + player2.charHeight/2 + charHeight/2 + 1, height - topStageH - charHeight/2);
      }
      else if(keyLeft2 && faceRight1)
      {
        x -= player2.moveSpeed;
        x = constrain(x, sideStageW + charWidth/2, player2.x - player2.charWidth/2 - charWidth/2 -1); 
      }
      else if(keyRight2 && !faceRight1)
      {
        x += player2.moveSpeed;
        x = constrain(x, player2.x + player2.charWidth/2 + charWidth/2 + 1, width - sideStageW - charWidth/2);
      }
    }    
    x = constrain(x, sideStageW + charWidth/2, width - sideStageW - charWidth/2);
    y = constrain(y, topStageH/2 + charHeight/2 + topStageY, height - topStageH - charHeight/2);
  }
  
  
  void alive()
  {
    if (health1 <= 0) 
    {
      health1 = 0;
      player1Dead = true;
      playerHue = (100); 
    }
    else player1Dead = false;  
  }
  
  void reset()
  {
    x = wSet * .25;
    y = hSet /2;
    dashLimit = 0;
    health1 = character[s1][0];
  }
}
