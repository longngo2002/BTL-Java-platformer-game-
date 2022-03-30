//Global variables
final static float MOVE_SPEED = 4;
final static float SPRITE_SCALE = 50.0/128;
final static float SPRITE_SIZE= 50;
final static float GRAVITY = 0.6;
final static float JUMP_SPEED = 14;
final static float RIGHT_MARGIN = 400;
final static float LEFT_MARGIN = 300;
final static float VERTICAL_MARGIN = 40;
final static int NEUTRAL_FACING = 0;
final static int LEFT_FACING = 1;
final static int RIGHT_FACING = 2;
final static float WIDTH = SPRITE_SIZE *16;
final static float HEIGHT = SPRITE_SIZE *12;
final static float GROUND_LEVEL = HEIGHT - SPRITE_SIZE;

Player player;
PImage grass, crate, red_brick, stone, gold, spider, title, rules;
ArrayList<Sprite> platforms;
ArrayList<Sprite> coins;
Enemy enemy;
float view_x;
float view_y;
boolean isGameOver;
int numCoins;
int stage;

void setup(){
  stage = 0;
  size(800, 600);
  imageMode(CENTER);
  PImage p = loadImage("player.png");
  player = new Player(p, 0.8);
  player.change_y = GROUND_LEVEL;
  player.center_x = 100;
  view_x = 0;
  view_y = 0;
  
  platforms = new ArrayList<Sprite>();
  coins = new ArrayList<Sprite>();
  numCoins = 0;
  isGameOver = false;
  
  gold = loadImage("gold_1.png");
  spider = loadImage("spider_walk_right1.png");
  red_brick = loadImage("red_brick.png");
  stone = loadImage("stone.png");
  crate = loadImage("crate.png");
  grass = loadImage("grass.png");
  createPlatforms("map.csv");
  title = loadImage("titlescreen.png");
  rules = loadImage("rule.png");
}

void draw(){
  if(stage==0){
    background(title);
    if(key == 'c'){
      background(rules);
     }
    if(key == ' '){
        stage=1;
    }  
  }
    if(stage==1){
      background(228,242,247);
      scroll();  
      displayAll();
  
       if(!isGameOver){
        updateAll();
        collectCoins();
        checkDeath();
      }
  }
}

void displayAll(){
  for(Sprite s: platforms)
    s.display();
  for(Sprite c: coins){
    c.display();
  }
  player.display();
  enemy.display();
  
  fill(255,0,0);
  textSize(32);
  text("Coin: " + numCoins, view_x + 50, view_y + 50);
  text("Lives: " + player.lives, view_x + 50, view_y + 100);
  
  if(isGameOver){
    fill(46,139,87);
    textSize(70);
    textAlign(CENTER);
    text("GAME OVER!", view_x + width/2, view_y + height/2);
    if(player.lives == 0){
      text("You lose!", view_x + width/2, view_y + height/2 + 50);
    }
    else
      text("You win!", view_x + width/2 , view_y + height/2 + 70);
    text("Press SPACE to restart!", view_x + width/2, view_y + height/2 + 170);
  }
}

void updateAll(){
  player.updateAnimation();
  resolvePlatformCollisions(player, platforms);
  
  enemy.update();
  enemy.updateAnimation();
  
  for(Sprite c: coins){
    ((AnimatedSprite)c).updateAnimation();
  }
  collectCoins();
  checkDeath();
}

void checkDeath(){
  boolean collideEnemy = checkCollision(player, enemy);
  boolean fallOffCliff = player.getBottom() > (GROUND_LEVEL);
  if(collideEnemy || fallOffCliff){
    player.lives--;
    if(player.lives == 0){
      isGameOver = true;
    }
    else{
      player.center_x = 100;
      player.setBottom(GROUND_LEVEL);
    }
  }
}

void collectCoins(){
  ArrayList<Sprite> coin_list = checkCollisionList(player, coins);
  if(coin_list.size() > 0){
    for(Sprite coin: coin_list){
      numCoins++;
      coins.remove(coin);
    }
  }
  if(coins.size() == 0){
    isGameOver = true;
  }
}

void scroll(){
  float right_boundary = view_x + width - RIGHT_MARGIN;
  if(player.getRight() > right_boundary){
    view_x += player.getRight() - right_boundary;
  }
  float left_boundary = view_x + LEFT_MARGIN;
  if(player.getLeft() < left_boundary){
    view_x -= left_boundary - player.getLeft();
  }
  float bottom_boundary = view_y + height - VERTICAL_MARGIN;
  if(player.getBottom() > bottom_boundary){
    view_y += player.getBottom() - bottom_boundary;
  }
  float top_boundary = view_y + VERTICAL_MARGIN;
  if(player.getTop() < top_boundary){
    view_y -= top_boundary -  player.getTop();
  }
  translate(-view_x, -view_y);
}
void keyPressed(){
  if(keyCode == RIGHT){
    player.change_x = MOVE_SPEED;
  }
  else if(keyCode == LEFT){
    player.change_x = -MOVE_SPEED;
  }
  else if(keyCode == UP && isOnPlatforms(player, platforms)){
    player.change_y = -JUMP_SPEED;
  }
  else if(isGameOver && key == ' ')
   setup();
}
void keyReleased(){
  if(keyCode == RIGHT){
    player.change_x = 0;
  }
  else if(keyCode == LEFT){
    player.change_x = 0;
  }
}
boolean checkCollision(Sprite s1, Sprite s2){
  boolean noXOverlap = s1.getRight() <= s2.getLeft() || s1.getLeft() >= s2.getRight();
  boolean noYOverlap = s1.getBottom() <= s2.getTop() || s1.getTop() >= s2.getBottom();
  if(noXOverlap || noYOverlap){
    return false;
  }
  else{
    return true;
  }
}
public ArrayList<Sprite> checkCollisionList(Sprite s, ArrayList<Sprite> list){
  ArrayList<Sprite> collision_list = new ArrayList<Sprite>();
  for(Sprite p: list){
    if(checkCollision(s, p))
      collision_list.add(p);
  }
  return collision_list;
}
public void resolvePlatformCollisions(Sprite s, ArrayList<Sprite> walls){
  //them trong luc
  s.change_y += GRAVITY;
  
  //di chuyen theo chieu y roi giai quyet collision
  s.center_y += s.change_y;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_y > 0){
      s.setBottom(collided.getTop());
    }
    else if(s.change_y < 0){
      s.setTop(collided.getBottom());
    }
  s.change_y = 0;
  }
  
  //di chuyen theo chieu x roi giai quyet collision
  s.center_x += s.change_x;
  col_list = checkCollisionList(s, walls);
  if(col_list.size() > 0){
    Sprite collided = col_list.get(0);
    if(s.change_x > 0){
      s.setRight(collided.getLeft());
    }
    else if(s.change_x < 0){
      s.setLeft(collided.getRight());
    }
  }
}
public boolean isOnPlatforms(Sprite s, ArrayList<Sprite> walls){
  s.center_y += 5;
  ArrayList<Sprite> col_list = checkCollisionList(s, walls);
  s.center_y -=5;
  if(col_list.size() > 0){
    return true;
  }
  else{
    return false;
  }
}

void createPlatforms(String filename){
  String[] lines = loadStrings(filename);
  for(int row = 0; row < lines.length; row++){
    String[] values = split(lines[row], ",");
    for(int col = 0; col < values.length; col++){
      if(values[col].equals("1")){
        Sprite s = new Sprite(red_brick, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("2")){
        Sprite s = new Sprite(grass, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("3")){
        Sprite s = new Sprite(stone, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("4")){
        Sprite s = new Sprite(crate, SPRITE_SCALE);
        s.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        s.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        platforms.add(s);
      }
      else if(values[col].equals("5")){
        Coin c = new Coin(gold, SPRITE_SCALE);
        c.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        c.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
        coins.add(c);
      }
      else if(values[col].equals("6")){
        float bLeft = col * SPRITE_SIZE;
        float bRight = bLeft + 4 * SPRITE_SIZE;
        enemy = new Enemy(spider, 50.0/72.0, bLeft, bRight);
        enemy.center_x = SPRITE_SIZE/2 + col * SPRITE_SIZE;
        enemy.center_y = SPRITE_SIZE/2 + row * SPRITE_SIZE;
      }
      
    }
  }
}
