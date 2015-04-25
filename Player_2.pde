class Player2
{
  //parameters start x, start y, width, height, movement speed on press, color, dash/block/cli.
  //float health2;
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
  Player2(float _health, float _x, float _y, float _charWidth, float _charHeight, float _moveSpeed, color _playerHue)
  {
    health2 = _health;
    x = _x;
    y = _y;
    charWidth = _charWidth;
    charHeight = _charHeight;
    moveSpeed = _moveSpeed;
    playerHue = _playerHue;
  }
  
  void display()
  {
    //Draws player. Draws P2 over character
    noStroke();
    fill(255);
    textSize(16);
    text("P2", x, y - charHeight/2 - 8);    
    fill(playerHue);
    rect(x, y, charWidth, charHeight);

    //Draws Dash Bar, if not climbing
    if(!climbing2)
    {
      rectMode(CORNER);
      fill(barHue);
      rect(x - charWidth/2, y + charHeight *.66, charWidth, 10);
      fill(dashHue);
      rect(x - charWidth/2, y + charHeight *.66, dashLimit, 10);  
      rectMode(CENTER);
    }
  }
  
  //Involves actions for movement
  void move()
  {
    //Changes movement speed. If dashing, runs function. If blocking, cuts it in half. If throwing, player is stopped until throw is completed (success or whiff).
    dash();    
    if (blocking2) moveSpeed = character[s2][3] / 2;
    if (frameCount < p2ThrowTime + 30) moveSpeed = 0;
    if (frameCount >= p2ThrowTime + 30) throwLock2 = false;

    //If player presses keys, moves character.    
    if(keyUp2) y -= moveSpeed;
    if(keyDown2) y += moveSpeed;
    if(keyLeft2) x -= moveSpeed;
    if(keyRight2) x += moveSpeed;
    
    //Constrain to within walls of stage
    x = constrain(x, sideStageW + charWidth/2, width - sideStageW - charWidth/2);
    y = constrain(y, topStageH/2 + charHeight/2 + topStageY, height - topStageH - charHeight/2);
    
    //Auto player facing. Automatically faces opponent
    if(player2.x < player1.x)
    {
      fill(255);
      rect(x + charWidth *.25, y, charWidth *.25, charHeight/2);
      faceRight2 = true;
    }
    else if(player2.x > player1.x)
    {
      fill(255);
      rect(x - charWidth *.25, y, charWidth *.25, charHeight/2);
      faceRight2 = false;
    }
   //Determines which player is higher.
   if(y <= player1.y) above2 = true;
   else if(y > player1.y) above2 = false;
   
    //Determines if player is climbing. If true, damage taken is reduced.
    if(x == sideStageW + charWidth/2 || x == width - sideStageW - charWidth/2 || y == topStageH/2 + charHeight/2 + topStageY || y == height - topStageH - charHeight/2) 
    {
      climbing2 = true;
      fill(character[s2][4]/3, character[s2][5]/3, character[s2][6]/3);
      rect(x, y, charWidth/2, charHeight/2);
    }
    else
      climbing2 = false;
      
  }
   
  
  //formula for damage taking. If blocking is true, any attacks that connect deal no damage. If not blocking, damage received is normal.
  void block()
  {
    if(blocking2) playerHue = color(character[s2][4]/2, character[s2][5]/2, character[s2][6]/2); //Character becomes darker when blocking.
    else playerHue = color(character[s2][4], character[s2][5], character[s2][6]); //Default color

    //Prevents player from blocking while dashing
    if(dashing2) blocking2 = false;
    
    //Generates Damage and Knockback if hit algorithm is true.
    if(p2GettingHit && !p2TakenHit && !blocking2)
    {
      if(climbing2) health2 -= p2Damage * .8;
      else health2 -= p2Damage;
      x += p2Knockback;
      y += p2KnockbackY;
      p2GettingHit = false;
      p2TakenHit = true;
      blocking2 = false;
      
      p2HitTime = frameCount;
    }

    //Runs if player gets thrown
    else if(p2GettingThrown && !p2TakenHit)
    {
      health2 -= p2Damage;
      x += p2Knockback;
      y += p2KnockbackY;
      p2GettingThrown = false;
      p2TakenHit = true;
      
      p2HitTime = frameCount;
    }
    
    //Runs if player blocks enemy hitbox. Reduces damage to 1/10, rounded down.
    else if (p2GettingHit && blocking2)
    {
      health2 -= floor(p2Damage/10);
      x += p2Knockback/2; //Deals horizontal knockback.
      p2GettingHit = false;
      p2HitTime = frameCount;
      playerHue = color(210);//Brightens color if attack is blocked.
    }    

    //Character becomes Light Grey if a move is blocked.
    if(frameCount < p2HitTime + p2HitStun && blocking2)
    {
      blocking2 = true;
      //p2TakenHit = true; //if off, allows for multiple hits of block.
      p2HitStun *= .99;
      playerHue = color(200);
    }
 
    //Character becomes semi transparent if hit.     
    else if (frameCount < p2HitTime + p2HitStun && !blocking2) playerHue = color(character[s2][4]/2, character[s2][5]/2, character[s2][6]/2, 190);
        
    if (frameCount > p2HitTime + p2HitStun + 5 ) p2TakenHit = false;
  }
  
  
  //Returns dash value, which is limited based on long player holds the dash button.
  float dash()
  {
    //println("Dash Break: " + dashBreak);
    
    //If dash limit is reached, bar must drain before player can dash again. Movement speed defaults
    if (dashBreak)
    {
      dashing2 = false;
      dashLimit--;

      moveSpeed = character[s2][3];
      
      if (dashLimit <= 0)
      {
        dashLimit = 0;
        dashBreak = false;
      }
    }

    //If player presses dash button, and dash has not reached its limit, dashes.
    else if (!dashBreak && dashing2)
    {
      dashLimit+=5;
      if (dashLimit > charWidth)
      {
        dashLimit = charWidth;
        dashing2 = false;
        dashBreak = true;
      }

      moveSpeed = character[s2][3] * 2;
      
      moveSpeed+=.5; 
      if (moveSpeed > character[s2][3] * 3.2) moveSpeed = character[s2][3] * 3.2;
    }

    //If dash is released before bar empties, player can dash again after releasing.
    else if (!dashing2 && !dashBreak)
    {
      dashLimit--;

      if (dashLimit < 0)
      {
        dashLimit = 0;
        dashBreak = false;
      }

      moveSpeed--;
      if (moveSpeed < character[s2][3]) moveSpeed = character[s2][3];
    }

    return moveSpeed;
  }
 
  
  void attack()
  {
    stroke(120);
    fill(120, 80);

    //Throws have 0 frame startup, high damage, etc. Occurs when two buttons pressed together. Cannot be blocked.
    if(throwing2 && !p2Attacking && !p2GettingHit && !blocking2 && !throwLock2)
    {
    println("throwing");
      
      if(keyUp2) //Up throw
      {
        rect(x + ADimensions[s2][10][0], y - ADimensions[s2][10][1], ADimensions[s2][10][2], ADimensions[s2][10][3]);   
        if(!p1TakenHit && hit1(x + ADimensions[s2][10][0], y - ADimensions[s2][10][1], ADimensions[s2][10][2], ADimensions[s2][10][3]))
        {
          p1Damage = ADimensions[s2][10][10]; //Sets opponent's throw damage
          p1Knockback = ADimensions[s2][10][7]; //Sets opponent's horizontal knockback
          p1KnockbackY = - ADimensions[s2][10][8]; //Sets opponent's vertical knockback
          p1HitStun = ADimensions[s2][10][11]; //Sets opponent's hitstun
          p1GettingThrown = true;
        }
      }

      
      else if(keyDown2) //Down throw. See up throw for specifics
      {
        rect(x + ADimensions[s2][10][0], y + ADimensions[s2][10][1], ADimensions[s2][10][2], ADimensions[s2][10][3]);           
        if(!p1TakenHit && hit1(x + ADimensions[s2][10][0], y + ADimensions[s2][10][1], ADimensions[s2][10][2], ADimensions[s2][10][3]))
        {
          p1Damage = ADimensions[s2][10][10];
          p1Knockback = ADimensions[s2][10][7];
          p1KnockbackY = ADimensions[s2][10][8];
          p1HitStun = ADimensions[s2][10][11]; //Sets opponent's hitstun
          p1GettingThrown = true;
        }
      }
      
      else if(faceRight2) //Right throw. See up throw for specifics
      {
        rect(x + ADimensions[s2][9][0], y + ADimensions[s2][9][1], ADimensions[s2][9][2], ADimensions[s2][9][3]);        
        if(!p1TakenHit && hit1(x + ADimensions[s2][9][0], y + ADimensions[s2][9][1], ADimensions[s2][9][2], ADimensions[s2][9][3]))
        {
          p1Damage = ADimensions[s2][9][10];
          p1Knockback = ADimensions[s2][9][7];
          p1KnockbackY = ADimensions[s2][9][8];
          p1HitStun = ADimensions[s2][9][11]; //Sets opponent's hitstun
          p1GettingThrown = true;
        }
      } 
      
      else if(!faceRight2) //Left throw. See up throw for specifics
      {
        rect(x - ADimensions[s2][9][0], y + ADimensions[s2][9][1], ADimensions[s2][9][2], ADimensions[s2][9][3]);
        if(!p1TakenHit && hit1(x - ADimensions[s2][9][0], y + ADimensions[s2][9][1], ADimensions[s2][9][2], ADimensions[s2][9][3]))
        {
          p1Damage = ADimensions[s2][9][10];
          p1Knockback = - ADimensions[s2][9][7];
          p1KnockbackY = ADimensions[s2][9][8];
          p1HitStun = ADimensions[s2][9][11]; //Sets opponent's hitstun
          p1GettingThrown = true;
        }
      }
      

      if(frameCount - p2ThrowTime > 1)
      {
        throwing2 = false;
        throwLock2 = true;
      }
    }  
    
    //Generates color of hitboxes based on selected Character's colors.
    stroke(character[s2][4], character[s2][5], character[s2][6]);
    fill(character[s2][4], character[s2][5], character[s2][6], 128);
    //Generates attack of key pressed, corresponding to dimensions of ADimensions[selected character][input key][size, position, damage, etc]
    
    //[0] x position, [1] y position,[2] length, [3] width, [4] startup, [5] duration, [6] cooldown, [7] x knockback, [8] y knockback,  [10] damage
    
    for (int i = 0; i < player2AttackKey.length; i++)
    {
      //Executes only if player is not in the middle of being hit.
      if (!p2GettingHit && player2Action[i])
      {
        //Executes once startup phase has passed
        if((frameCount - p2Starttime > ADimensions[s2][i][4]) && !p2GettingHit)
        {
          if (faceRight2) //Executes if facing right
          {
            if(keyUp2) i += player2AttackKey.length; //Switches between High/Low versions of each move during active frames of chosen move.
            if(keyDown2) i += player2AttackKey.length * 2; //i value corresponds to later values in Attack Array without overrunning the for loop.
            
            rect(x + ADimensions[s2][i][0], y + ADimensions[s2][i][1], ADimensions[s2][i][2], ADimensions[s2][i][3]); //Draws attack hitbox

            //Executes if hitbox overlaps with enemy
            if (!p2GettingHit && !p2TakenHit && hit1(x + ADimensions[s2][i][0], y + ADimensions[s2][i][1], ADimensions[s2][i][2], ADimensions[s2][i][3]))
            {
              p1GettingHit = true; //Self explanatory
              x -= ADimensions[s2][i][9]; //Sets player pushback
              p1Knockback = ADimensions[s2][i][7]; //Sets opponent's horizontal knockback
              p1KnockbackY = ADimensions[s2][i][8]; //Sets opponent's vertical knockback
              p1Damage = ADimensions[s2][i][10]; //Sets opponent's damage
              p1HitTime = ADimensions[s2][i][11]; //Sets opponent's hitstun
            }
          }

          //Same as above, but if player is facing left
          if (!faceRight2)
          {
            if(keyUp2) i += player2AttackKey.length;// upAttack1 = true;
            if(keyDown2) i += player2AttackKey.length * 2;
            
            rect(x - ADimensions[s2][i][0], y + ADimensions[s2][i][1], ADimensions[s2][i][2], ADimensions[s2][i][3]); 

            if (!p2GettingHit && !p2TakenHit && hit1(x - ADimensions[s2][i][0], y + ADimensions[s2][i][1], ADimensions[s2][i][2], ADimensions[s2][i][3]))
            {
              
              p1GettingHit = true; //Derp
              x += ADimensions[s2][i][9]; //Sets player pushback
              p1Knockback = - ADimensions[s2][i][7]; //Sets opponent's horizontal knockback
              p1KnockbackY = ADimensions[s2][i][8]; //Sets opponent's vertical knockback
              p1Damage = ADimensions[s2][i][10]; //Sets opponent's damage
              p1HitTime = ADimensions[s2][i][11]; //Sets opponent's hitstun
            }
          }
        }
      }
      
      
      //Cooldown frames. Player cannot act again until cooldown has ended.
      if (frameCount - p2Starttime - ADimensions[s2][i][4] > ADimensions[s2][i][5])
      {
        p1GettingHit = false; //if (p2GettingHit) 
      }


      //If cooldown has ended, the player is done with attacking. Player is ready to act again
      if (frameCount - p2Starttime - ADimensions[s2][i][4] - ADimensions[s2][i][5]> ADimensions[s2][i][6])
      {
        if( i > (player2AttackKey.length * 2) -1 ) i -= player2AttackKey.length * 2; //Prevents out-of-bounds exceptions
        else if( i > player2AttackKey.length - 1 ) i -= player2AttackKey.length; //^
        
        player2Action[i] = false;       
        p1TakenHit = false; //if (p2TakenHit) 
        p2Attacking = false;
      }
    }
  }
  
  void push()
  {
    if(hit1(x, y, charWidth, charHeight))
    {
      if(keyUp1 && above2)
      {
        y -= player1.moveSpeed;
        y = constrain(y, topStageH/2 + charHeight/2 + topStageY, player1.y - player1.charHeight/2 - charHeight/2 -1);        
      }
      if(keyDown1 && !above2)
      {
        y += player1.moveSpeed;
        y = constrain(y, player1.y + player1.charHeight/2 + charHeight/2 + 1, height - topStageH - charHeight/2);
      }
      if(keyLeft1 && faceRight2)
      {
        x -= player1.moveSpeed;
        x = constrain(x, sideStageW + charWidth/2, player1.x - player1.charWidth/2 - charWidth/2 -1); 
      }
      if(keyRight1 && !faceRight2)
      {
        x += player1.moveSpeed;
        x = constrain(x, player1.x + player1.charWidth/2 + charWidth/2+1, width - sideStageW - charWidth/2);
      }
    } 

    x = constrain(x, sideStageW + charWidth/2, width - sideStageW - charWidth/2);
    y = constrain(y, topStageH/2 + charHeight/2 + topStageY, height - topStageH - charHeight/2);
  }
  
  void alive()
  {
    if(health2 <= 0)
    {
      health2 = 0;
      player2Dead = true;
      playerHue = (100);
    }
    else player2Dead = false;  
  }
  
  void reset()
  {
    x = wSet * .75;
    y = hSet /2;
    dashLimit = 0;
    health2 = character[s2][0];
  }

}
 
