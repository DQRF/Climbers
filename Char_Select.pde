//MUSIC
import ddf.minim.*;
Minim minim;
AudioPlayer[] mp3 = new AudioPlayer[7];

//Determines whether characters are picked.
static int selection;
boolean picked1, picked2; //Determines if players have picked their characters
boolean p1Ready, p2Ready; //Determines if players are ready to proceed

//color values for portraits
int dAlpha = 200;
int sAlpha = 255;

color dFill = color(0, 255, 0);
color sFill1 = color(120, 0, 0);
color sFill2 = color(0, 0, 120);


//Player Portrait dimensions

//if true, portrait is highlighted by player's color.
boolean[] selected = {true, false, false, false, false, true};
                           //0   1   2    3    4   5   6  7
                           //x   y wdth hght   r   g   b  a
float[][] dDisplay = {{-220,   20,  80, 100, 255,  50,  50, dAlpha, -210, 20, 20, 56}, 
                      {   0,   10,  64, 120, 255, 150,  50, dAlpha, -16, -10, 16, 72},
                      { 180,    0,  48,  80, 255, 255,  50, dAlpha, 170, 10, 12, 40},
                      {-190,  230, 100,  80,  50, 255,  50, dAlpha, -190, 215, 25, 48},
                      {   0,  170,  80,  80,  50,  50, 255, dAlpha, 15, 180, 20, 48},
                      { 200,  200, 140, 140, 150,  50, 255, dAlpha, 200, 200, 36, 88}};

//Closes music when program ends.
void stop()
{
  for(int i = 0; i < mp3.length; i++)
  {
    mp3[i].close();
  }
  
  minim.stop();
  super.stop();
}

//Draws character select screen
void charSelect()
{
  noStroke();
  
  //bgm = false;
  if(bgm == false)
  {
    mp3[0].rewind();
    mp3[0].loop();
    bgm = true;
  }
  
  pushMatrix();
  
  translate(width/2, height/2 - 100);
  
  for(int i = 0; i < 6; i++)
  {
    //Changes color if selected. red if p1, blue if p2. Brightens if picked. purple if both players select. yellow if both players pick.
    if(selected[i])
    {
      if (i == s1 && i == s2)
      {
        if(picked1 && picked2) fill(255, 255, 0);
        else if(picked1) fill(255, 0, 120);
        else if(picked2) fill(120, 0, 255);
        else fill(120, 0, 120);
      } 
      else if (s1 == i)
      {
        fill(sFill1);
        if(picked1) fill(255, 0, 0);
      }
      else if (s2 == i)
      {
        fill(sFill2);
        if(picked2) fill(0, 0, 255);
      }
    }
    else fill(dFill);
    
    //Green Border + Black Rectangle
    if(i < 3)
    {
      rect(-200 + 200 * i, 0, 150, 150);
      fill(0);
      rect(-200 + 200 * i, 0, 140, 140);  
    }
    else
    {
      rect(-200 + 200 * (i-3), 200, 150, 150);
      fill(0);
      rect(-200 + 200 * (i-3), 200, 140, 140);
    } 
    
    //Displays character portraits. Displays in toned down color by default.
    //if selected by either player, displays portraits in full color.
    if(selected[i]) dDisplay[i][7] = 255;
    else dDisplay[i][7] = 200;
    
    //Displays body
    fill(dDisplay[i][4], dDisplay[i][5], dDisplay[i][6], dDisplay[i][7]);
    rect(dDisplay[i][0], dDisplay[i][1], dDisplay[i][2], dDisplay[i][3]);
    
    //Displays "face"
    fill(255);
    rect(dDisplay[i][8], dDisplay[i][9] ,dDisplay[i][10], dDisplay[i][11]);    
  }

  //Asks if players are ready after picking characters.
  if(picked1 && picked2)
  {
    fill(255);
    textFont(gameFont, 25);
    text("Ready? Hit SHIFT and ENTER", 0, 400);
    
    if(p1Ready) fill(255, 0, 0);
    else fill(255);
    rect(-250, 400, 10, 10);
    
    if(p2Ready) fill(0, 0, 255);
    else fill(255);    
    rect(250, 400, 10, 10);
  }
    
    
  //Starts Game when both players are ready. Runs all necessary blocks.
  if(p1Ready && p2Ready)
  {
    gameStarted = true;
    roundStart = true;
    picked1 = picked2 = p1Ready = p2Ready = false;
    mp3[0].pause();
    bgm = false;
    
    reset = true;
    s = millis()/1000 + roundTime;

    //draws Player 1 at left center of screen, with width 50, height 70, movement speed 10, red, 
    player1 = new Player(character[s1][0], width * .25, height/2, character[s1][1], character[s1][2], character[s1][3],  color(character[s1][4], character[s1][5], character[s1][6]));

    //draws Player 2 at right center of screen, with width 50, height 70, movement speed 10, blue, 
    player2 = new Player2(character[s2][0], width * .75, height/2, character[s2][1], character[s2][2], character[s2][3],  color(character[s2][4], character[s2][5], character[s2][6]));
  
    p1Win = p2Win = false;  
  }
     
      
  popMatrix();
}

//Character select buttons. Same as player movement keys.
void selection1()
{
  if(!picked1)
  {
    if(key == right1 || key == right2)
    {
      s1 ++;
      if(s1 > 5) s1 = 0;
    }
    if(key == left1 || key == left2)
    {
      s1 --;
      if(s1 < 0) s1 = 5;  
    }
    if(key == up1 || key == up2)
    {
      s1 -=3;
      if(s1 < 0) s1 +=6;
    }
    if(key == down1 || key == down2)
    {
      s1 +=3;
      if(s1 > 5) s1 -=6;
    }
  }

  selected[s1] = true;
  
  
 if(!picked2)
  {
    if(key == CODED)
      {
      if(keyCode == RIGHT)
      {
        s2 ++;
        if(s2 > 5) s2 = 0;
      }
      if(keyCode == LEFT)
      {
        s2 --;
        if(s2 < 0) s2 = 5;  
      }
      if(keyCode == UP)
      {
        s2 -=3;
        if(s2 < 0) s2 +=6;
      }
      if(keyCode == DOWN)
      {
        s2 +=3;
        if(s2 > 5) s2 -=6;
      }
    }
  }
  
  selected[s2] = true;
  
  
  //Changes the selection values, which determine which character to draw.
  for(int i = 0; i < selected.length; i++)
  {
    if(i != s1 && i != s2) selected[i] = false;
  }    

    for(int i = 0; i < player1Action.length; i++)
    {  
      if(key == player1AttackKey[i]) picked1 = !picked1;
      if(key == player2AttackKey[i]) picked2 = !picked2;  
    } 
    
  //Hit shift and enter when ready.
  if(picked1 && picked2)
  {
      if(key == CODED)
      {
        if(keyCode == SHIFT) p1Ready = true;
      }
      if(key == ENTER) p2Ready = true;   
  }  
}
