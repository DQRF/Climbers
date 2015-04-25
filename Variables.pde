Player player1;
Player2 player2;

 
int mPlayer; //Determines which song to play out the array (random every battle).
boolean bgm; //Whether or not music is playing
boolean reset; //Resets screen after round
boolean retry; //Restarts battle after completion.
boolean menu; //Goes back to menu if true, opposite of Retry.

int t; //Resets time every time a new round occurs
int s = 99;//99;

int time; //Game time. 
int wSet = 1400; //Width
int hSet = 800; //Height

int s1 = 3, s2 = 5; //Players' character selection.

//Font
PFont gameFont;
boolean throwLock1, throwLock2;

                      
boolean gameStarted;        //If true, players are running
boolean gameEnded;                 //If true, runs retry screen
int p1Round, p2Round;  //How many rounds either player has won
boolean p1Win, p2Win;              //Determines HUD/rules based on how many wins each player has.


int round = 0;                            //Down in the fifth
int roundTime = 99;                        //How do boxers stand getting punched for 99 seconds?
float health1display, health2display;     //Scales to health to properly display health bars.
boolean paused;                           //Paused, obviously
            
//Win display, "Round" display, "GO" display
int[] textTime = {240, 180, 60};
//DING
boolean roundStart = true;


boolean p1Attacking;       //activates once an attack is initiated. Prevents players from doing multiple attacks at once.
boolean p1GettingHit;      //Activates once the player takes an attack
boolean p1TakenHit;        //Prevents player from being hit multiple times by same attack
boolean p1GettingThrown;   //CHURN DAT BUTTAH
float p1Knockback;         //How far getting hit launches a player, horizontally.
float p1KnockbackY;        //How far getting hit launches a player, vertically.
float p1Damage;            //How much damage a player takes from a particular attack.

boolean p2Attacking;       //activates once an attack is initiated. Prevents players from doing multiple attacks at once.
boolean p2GettingHit;      //Same as above
boolean p2GettingThrown;   //Again
boolean p2TakenHit;        //Ouch
float p2Knockback;         //Derp
float p2KnockbackY;        //Herp
float p2Damage;            //Bleh

//I THINK HE'S DEAD VEGETA. Determines whether or not a player is alive
boolean player1Dead = false;
boolean player2Dead = false;

//Color of the dash bar. Do you fly or dash?
color dashHue = color(0, 250, 50);
color barHue = color(50);

//Dimensions of the stage barriers
float topStageY = 40;
float topStageH = 10;
float sideStageW = 10;

//Dimensions for characters //[0] health [1] width, [2] height [3] moveSpeed [4] fillR [5] fillG [6] fillB [7] alpha
final float[][] character = {{100, 50,  70, 10, 255,  50,  50},  //Red
                             { 90, 40,  90, 12, 255, 150,  50},  //Orange
                             { 60, 30,  50, 16, 255, 255,  50},  //Yellow
                             {100, 60,  60,  9,  50, 255,  50},  //Green
                             {100, 50,  60, 11,  50,  50, 255},  //Blue
                             {160, 90, 110,  5, 255,  50, 255}}; //Purple

//Health is based on player's selected character.                             
float health1 = character[s1][0];
float health2 = character[s2][0];

//Define Buttons Player1
char[] player1AttackKey = {'j', 'k', 'l'};
//Determines whether button is currently being pressed for player.
boolean[] player1Action = new boolean[player1AttackKey.length];

//Hitstun Timer
float p1HitTime;
float p1HitStun;
//Startup Timer
int p1Starttime;
//Throw startup timers
int p1ThrowTime;

//Define Buttons Player2                           
char[] player2AttackKey = {'4', '5', '6'};
boolean[] player2Action = new boolean[player2AttackKey.length];

float p2HitTime;
float p2HitStun;
int p2Starttime;
int p2ThrowTime;


//Character Movesets
//[0] x position, [1] y position,[2] length, [3] width, [4] startup, [5] duration, 
//[6] cooldown, [7] x knockback, [8], y knockback, [9] pushback, [10] damage, [11] hitstun
                                    
                                  //Red {100, 50,  70, 10, 255,  50,  50}
                                  // 0    1   2   3   4   5   6    7    8   9   10  11
                                  // x    y   w   h  stt drt cld xkbk ykbk psh dmg, stn
final float[][][] ADimensions =  {{{25,   0, 30,  20,  4, 10,  5,  60,    0, 20,  3,  15}, //[0] Neutral Attack 1
                                   {24,   0, 35,  24, 10,  2, 20, 100,    0, 30,  6,  22}, //[1] Neutral Attack 2
                                   {30,   0, 65,  70, 15, 15, 25, 120,    0, 40, 10,  48}, //[2] Neutral Attack 3
                                   {40, -40, 20,  30,  5,  2, 16,  25,  -30, 27,  4,  25}, //[3] Up Attack 1
                                   { 0, -50, 60,  20,  9,  7, 16,  10,  -50, 40,  8,  25}, //[4] Up Attack 2
                                   {30,  50, 50,  90, 10, 10, 25, 120, -160, 68, 10,  37}, //[5] Up Attack 3
                                   {30,  20, 35,  40,  7,  3, 10,   0,   30, 40,  7,  19}, //[6] Down Attack 1
                                   {10,  60, 20,  40, 10, 30, 15,   0,   70, 10, 10,  45}, //[7] Down Attack 2                               
                                   {30, -50, 50,  90, 11, 10, 25, 120,  100, 30, 15,  49}, //[8] Down Attack 3
                                   // x    y   w   h  stt drt cld xkbk ykbk psh dmg, stn                                 
                                   {45,   0, 50, 105,  0,  1, 50, 250,    0,  0, 20,  60}, //[9] Regular Throw
                                   { 0,  60, 60,  75,  0,  1, 50,  30,  280,  0, 20,  60}},//[10] Vertical Throw
                                   
                                   
                                  //Orange { 90, 40,  90, 12, 255, 150,  50}
                                  //  x    y    w    h  stt drt cld xkbk ykbk psh dmg  stn                                   
                                  {{ 45,   0,  60,  70,  5,  8, 15,  60,    0, 20,  2, 10},  //[0] Neutral Attack 1
                                   { 55,   0, 100,  84, 10, 10, 20, 100,    0, 30,  6, 15},  //[1] Neutral Attack 2
                                   {120,   0, 205,  40, 15, 15, 25, 120,    0, 40,  8, 20},  //[2] Neutral Attack 3
                                   { 40, -40,   8,  50,  9,  3, 26,  25,  -30, 27,  4, 25},  //[3] Up Attack 1
                                   {  0, -50,  10, 100,  9,  8, 26,  10,  -50, 40,  8, 30},  //[4] Up Attack 2
                                   { 30, -50,  20, 120, 10, 10, 25, 120, -160, 68, 10, 30},  //[5] Up Attack 3
                                   { 30,  20,  35,  40,  7,  6, 20,   0,   30, 40,  7, 10},  //[6] Down Attack 1
                                   { 10,  20,  60,  40,  5, 14, 36,   0,   70, 10,  8, 55},  //[7] Down Attack 2                               
                                   {150, 100, 300, 120, 16, 30, 38, 120,  100, 30, 10, 50}, //[8] Down Attack 3
                                    //Throws
                                    // x    y   w   h  stt drt cld xkbk ykbk psh dmg, stn                                 
                                   {55,   0,  30, 105,  0,  3, 30, 250,    0,  0, 15, 60}, //[9] Regular Throw
                                   { 0,  70,  60,  67,  0,  3, 30,  30,  280,  0, 16, 60}}, //[10] Vertical Throw



                                  //Yellow { 70, 30,  50, 16, 255, 255,  50}
                                  // x    y   w   h  stt drt cld xkbk ykbk psh dmg  stn                                   
                                  {{15,   0, 30, 20,  2,  5,  5,  30,    0, 20,  3,  3},  //[0] Neutral Attack 1
                                   {24,   0, 35, 24,  5,  3, 10,  50,    0, 30,  5, 10},  //[1] Neutral Attack 2
                                   {20,   0, 65, 70,  8,  1, 13,  60,    0, 40,  7, 13},  //[2] Neutral Attack 3
                                   {30, -40, 20, 30,  3,  1,  8,  13,  -15, 27,  4,  9},  //[3] Up Attack 1
                                   { 0, -50, 60, 20,  5,  9,  8,  10,  -25, 40,  8, 17},  //[4] Up Attack 2
                                   {30,  50, 50, 90,  9,  2, 14,  60,  -80, 68, 10, 18},  //[5] Up Attack 3
                                   {30,  20, 35, 40,  4,  2,  5,   0,   15, 40,  3,  8},  //[6] Down Attack 1
                                   {10,  60, 20, 40,  5, 15, 13,   0,   35, 10,  5, 20},  //[7] Down Attack 2                               
                                   {30, -50, 50, 90,  6,  2, 13,  60,   50, 30, 15, 20}, //[8] Down Attack 3
                                    //Throws
                                  // x    y   w   h  stt drt cld xkbk ykbk psh dmg, stn                                 
                                   {25,   0, 25, 105, 0,  3, 30, 250,    0,  0, 10, 60}, //[9] Regular Throw
                                   { 0,  30, 60, 75,  0,  3, 30,  30,  280,  0, 10, 60}},

                                  //Green {100, 60,  60,  9,  50, 255,  50}
                                  // x    y    w   h  stt drt  cld xkbk ykbk psh dmg   stn                                  
                                  {{ 0,   0,  70, 70,  4,  20, 10,  70,    0, 20,  3,  29},  //[0] Neutral Attack 1
                                   {24,   0,  35, 24, 10,  60, 30, 100,    0, 30,  6,  90},  //[1] Neutral Attack 2
                                   { 0,   0,  90, 90, 15,  45, 35, 120,    0, 40, 16,  48},  //[2] Neutral Attack 3
                                   {30, -30,  50, 60,  5,  10, 26,  25,  -30, 27,  4,  25},  //[3] Up Attack 1
                                   { 0,  50,  60, 60,  9,  30, 36,  20,  -50, 40,  8,  65},  //[4] Up Attack 2
                                   { 0, -50, 100, 50, 10,  20, 45, 120, -160, 68, 10,  60},  //[5] Up Attack 3
                                   {30,  20,  35, 40,  7,  20, 15,   0,   30, 40,  7,  34},  //[6] Down Attack 1
                                   {10, -60,  20, 40, 10,  40, 35,  10,   70, 10, 10,  75},  //[7] Down Attack 2                               
                                   {20,  20,  50, 70, 11, 100, 40, 120,  100, 30, 15, 145}, //[8] Down Attack 3
                                    //Throws
                                    // x    y   w   h  stt drt cld xkbk ykbk psh dmg, stn                                 
                                   {65,   0, 50, 105, 0,  3, 30, 250,    0,  0, 20, 60}, //[9] Regular Throw
                                   { 0,  60, 60, 75,  0,  3, 30,  30,  280,  0, 20, 60}},
                                     
                                     
                                  //Blue {100, 50,  60, 11,  50,  50, 255}
                                  // x    y   w   h  stt drt cld xkbk ykbk psh dmg  stn
                                  {{35, -10, 35, 30,  3, 10,  5,  60,    0, 20,  3, 15},  //[0] Neutral Attack 1
                                   {34,  10, 40, 24,  8,  5, 10, 100,    0, 30,  7, 15},  //[1] Neutral Attack 2
                                   {40,   0, 65, 70, 11, 15, 25, 120,    0, 40, 10, 40},  //[2] Neutral Attack 3
                                   {50, -40, 20, 30,  4,  8,  9,  25,  -30, 27,  4, 17},  //[3] Up Attack 1
                                   { 0, -50, 60, 20,  7,  8, 15,  10,  -50, 40,  8, 23},  //[4] Up Attack 2
                                   {40,  50, 50, 90,  8, 10, 25, 120, -160, 68, 10, 35},  //[5] Up Attack 3
                                   {40,  20, 35, 40,  6, 10, 10,   0,   30, 40,  7, 20},  //[6] Down Attack 1
                                   {20,  60, 20, 40, 10, 30, 16,   0,   70, 10, 10, 46},  //[7] Down Attack 2                               
                                   {30, -40, 50, 70, 11, 10, 25, 120,  100, 30, 15, 35}, //[8] Down Attack 3
                                    //Throws
                                    // x    y   w   h  stt drt cld xkbk ykbk psh dmg, stn                                 
                                   {45,   0, 50, 105, 0,  3, 30, 250,    0,  0, 20, 60}, //[9] Regular Throw
                                   { 0,  60, 60, 75,  0,  3, 30,  30,  280,  0, 20, 60}},                                     

                                  //Purple {160, 90, 110,  5, 255,  50, 255}
                                  //  x     y    w   h  stt drt cld xkbk ykbk  psh dmg  stn
                                  {{ 85,    0,  60,  40,  6, 10, 10,  60,    0, 20,  3,  25},  //[0] Neutral Attack 1
                                   { 84,    0,  35,  44, 10, 11, 20, 100,    0, 30,  6,  33},  //[1] Neutral Attack 2
                                   {100,    0,  65,  70, 15, 15, 25, 120,    0, 40, 10,  40},  //[2] Neutral Attack 3
                                   {119, -100,  20,  30,  6,  5, 16,  25,  -30, 27,  4,  21},  //[3] Up Attack 1
                                   {  0, -100, 100,  20,  9, 10, 16,  10,  -50, 40,  8,  28},  //[4] Up Attack 2
                                   {100,  130,  50,  90, 10,  9, 25, 120, -160, 68, 10,  39},  //[5] Up Attack 3
                                   {120,   80,  35,  40,  7, 13, 10,   0,   30, 40,  7,  25},  //[6] Down Attack 1
                                   { 80,  110,  20,  40, 10, 30, 25,   0,   70, 10, 10,  60},  //[7] Down Attack 2                               
                                   {  0,  100, 200,  90, 15, 60, 30, 900,   20, 30, 30, 110}, //[8] Down Attack 3
                                    //Throws
                                    // x    y   w   h  stt drt cld xkbk ykbk psh dmg, stn                                 
                                   {100,   0, 120, 185,  0,  3, 30, 500,   0,  0, 20, 100}, //[9] Regular Throw
                                   {  0,  90, 120, 135,  0,  3, 30,  30, 500,  0, 20, 100}}}; 


//If players enter these buttons, THINGS HAPPEN. They should be pretty self-explanatory, though up1 and up2 are for player 1 due to shift. same for other directions, throw, and block
char up1 = 'w'; char up2 = 'W';
char down1 = 's'; char down2 = 'S';
char right1 = 'd'; char right2 = 'D';
char left1 = 'a'; char left2 = 'A';

char throw1 = ';';char throw2 = ':';
char dash1 = ' ';
char block1 = 'n'; char block2 = 'N';

char throw3 = '+';
char dash2 = '0';
char block3 = '1'; //ENTER


boolean neutral;

//Player1 Booleans

//Determines whether Moving/ which directions player is facing, whether blocking, dashing, or climbing.
boolean keyUp1, keyDown1, keyRight1, keyLeft1, keyUp2, keyRight2, keyLeft2, keyDown2;
boolean faceRight1 = true;
boolean above1 = false;
boolean blocking1, dashing1,climbing1;
boolean throwing1 = false, throwing2 = false;

//Player2 Booleans
//Player2 movement buttons are ARROW KEYS
boolean faceRight2 = false;
boolean above2 = false;

boolean blocking2, dashing2, climbing2;


