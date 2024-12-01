import java.awt.Robot;
import java.awt.AWTException;
import java.awt.MouseInfo;
import java.awt.Point;
import com.jogamp.newt.opengl.GLWindow;
import java.util.ArrayList;
import java.util.List;
import java.util.Collections;


// input
boolean wPressed = false;
boolean aPressed = false;
boolean sPressed = false;
boolean dPressed = false;
boolean shiftPressed = false;
boolean spacePressed = false;
boolean ctrlPressed = false;
boolean clicked = false;
boolean rightClicked = false;
boolean middleClicked = false;
int lastPressTime = 0;
int doublePressThreshold = 200;

// blocks
List<Block> blocks;
List<Block> newBlocks;

int n = 20;
float blockSize = 50;


Player plr;
UI ui;
Skin steve;

void setup() {
  ((PGraphicsOpenGL)g).textureSampling(3);
  size(1000, 600, P3D);
  noSmooth();
  noCursor();
  rectMode(CENTER);
  imageMode(CENTER);
  strokeWeight(5);
  //fullScreen(P3D);
  
  blocksSetup();
  plr = new Player();
  ui = new UI();
  plr.setupCamera();
}

int lastTime = 0;
int delta = 0;
void draw() {
  delta = millis() - lastTime;
  lastTime = millis();
  
  updateBlocks();
  plr.drawCamera();
  selectBlock();
  
  background(102, 200, 232);
  renderBoxes(false);
  if(steve != null) {
    steve.draw();
    steve.position.x++;
  }
  plr.renderHand();
  ui.draw();
  
  //input
  rightClicked = false;
  middleClicked = false;
  clicked = false;
}



void mousePressed() {
  if (mouseButton == LEFT) {
    clicked = true;
  } else if (mouseButton == RIGHT) {
    rightClicked = true;
  } else if (mouseButton == CENTER) {
    middleClicked = true;
  } else {
    return;
  }
}


void renderBoxes(boolean pick) {
  if(pick){
     noLights();
     noStroke();
  } else {
    ambientLight(128, 128, 128);
    directionalLight(200,200,200,0.9,0.7,0.6);
  }
  //first render non transparent
  for(Block block : blocks) {
    if(!block.transparent) block.draw(pick);
  }
  for(Block block : blocks) {
    if(block.transparent) block.draw(pick);
  }
}

int colorToInt(color c) {
  int r = c >> 16 & 0xFF;
  int g = c >> 8 & 0xFF;
  int b = c & 0xFF;
  String hex = String.format("%02X", r) + String.format("%02X", g) + String.format("%02X", b);
  return Integer.parseInt(hex, 16);
}

color intToColor(int n) {
  String hex = String.format("%06X", n);
  int r = Integer.parseInt(hex.substring(0,2), 16);
  int g = Integer.parseInt(hex.substring(2,4), 16);
  int b = Integer.parseInt(hex.substring(4,6), 16);
  return color(r,g,b);
}

int[] getWindowPosition() {
  GLWindow glWindow = (GLWindow) surface.getNative();
  int windowX = (int) glWindow.getX(); // Get X position
  int windowY = (int) glWindow.getY(); // Get Y position
  return new int[]{windowX, windowY};
}

boolean isInside(PVector a, PVector aSize, PVector b, PVector bSize) {
  boolean isOnTop   = a.y-aSize.y/2 >= b.y+bSize.y/2;
  boolean isBelow   = a.y+aSize.y/2 <= b.y-bSize.y/2;
  boolean isToRight = a.x-aSize.x/2 >= b.x+bSize.x/2;
  boolean isToLeft  = a.x+aSize.x/2 <= b.x-bSize.x/2;
  boolean isInFront = a.z-aSize.z/2 >= b.z+bSize.z/2;
  boolean isBehind  = a.z+aSize.z/2 <= b.z-bSize.z/2;
  return !isOnTop && !isBelow && !isToRight && !isToLeft && !isInFront && !isBehind;
}

void keyPressed() {
  if(keyCode == 87) {
    wPressed = true;
  }
  if(keyCode == 65) {
    aPressed = true;
  }
  if(keyCode == 83) {
    sPressed = true;
  }
  if(keyCode == 68) {
    dPressed = true;
  }
  if(keyCode == 16) {
    shiftPressed = true;
  }
  if(keyCode == 32) {
    int currentTime = millis();
    if (currentTime - lastPressTime < doublePressThreshold) {
      plr.toggleFly();
    }
    lastPressTime = currentTime;
    spacePressed = true;
  }
  if(keyCode == 17) {
    ctrlPressed = true;
  }
  if(keyCode > 48 && keyCode < 58) {
    plr.inv = keyCode - 49;
  }

}

void keyReleased() {
  if(keyCode == 87) {
    wPressed = false;
  }
  if(keyCode == 65) {
    aPressed = false;
  }
  if(keyCode == 83) {
    sPressed = false;
  }
  if(keyCode == 68) {
    dPressed = false;
  }
  if(keyCode == 16) {
    shiftPressed = false;
  }
  if(keyCode == 32) {
    spacePressed = false;
  }
  if(keyCode == 17) {
      steve = new Skin(plr.position.x,plr.position.y,plr.position.z,2.5);
    ctrlPressed = false;
  }
}

void mouseWheel(MouseEvent event) {
  int e = event.getCount();
  plr.inv = (plr.inv+e)%9;
  if(plr.inv < 0) plr.inv = 8; 
}
