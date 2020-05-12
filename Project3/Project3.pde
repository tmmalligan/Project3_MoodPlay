/*
  Project 3: MoodPlay
  By Taylor Malligan
  Expects a string of comma-delimted Serial data from Arduino:
  ** field is 0 or 1 as a string (switch)
  ** second fied is 0-4095 (potentiometer)
  ** third field is 0-4095 (LDR) 
  
  
    Will change the background to red when the button gets pressed
    
 */
 

// Importing the serial library to communicate with the Arduino 
import processing.serial.*;    
import processing.sound.*;
import ddf.minim.*;

// Initializing a vairable named 'myPort' for serial communication
Serial myPort;      
float value = 0;
Minim minim;
AudioPlayer player;
SoundFile stronger;
SoundFile thankyou;
SoundFile piano;
SoundFile playinggames;

// Data coming in from the data fields
String [] data;
int switchValue = 0;
int potValue = 0;
int ldrValue = 0;

// Change to appropriate index in the serial list — YOURS MIGHT BE DIFFERENT
int serialIndex = 4;


//-- image covers
PImage strongCover;
PImage tunCover;
PImage pianoCover;
PImage pgCover;

int minLDRValue = 400;
int maxLDRValue = 1700;
int minAlphaValue = 0;
int maxAlphaValue = 255;

// state machine
int state;
int stateStatic = 1;
int stateRap = 2;
int statePop = 3;
int stateChill = 4;
int stateRandom = 5;

//timer
Timer startTimer;
//boolean for timer
boolean end = false;

void setup ( ) {
  size (1000,  1000);    
  
  // List all the available serial ports
  printArray(Serial.list());
  
  // Set the com port and the baud rate according to the Arduino IDE
  //-- use your port name
    myPort=new Serial(this, Serial.list()[serialIndex], 115200); 
  
  minim = new Minim(this);
  myPort = new Serial(this,"COM3", 9600);
  
  // load images
  strongCover = loadImage("strongeralbum.jpeg");
  tunCover = loadImage("thankualbum.png");
  pianoCover = loadImage("pianoalbum.jpg");
  pgCover= loadImage("pgalbum.jpg"); 
  
  startTimer = new Timer(5000);

  
} 


// We call this to get the data 
void checkSerial() {
  while (myPort.available() > 0) {
    String inBuffer = myPort.readString();  
    
    print(inBuffer);
    
    // This removes the end-of-line from the string 
    inBuffer = (trim(inBuffer));
    
    // This function will make an array of TWO items, 1st item = switch value, 2nd item = potValue
    data = split(inBuffer, ',');
   
   // we have THREE items — ERROR-CHECK HERE
   if( data.length >= 3 ) {
      switchValue = int(data[0]);           // first index = switch value 
      potValue = int(data[1]);               // second index = pot value
      ldrValue = int(data[2]);               // third index = LDR value
   }
  }
} 


void draw ( ) {  
  // every loop, look for serial information
  checkSerial();
  
  //state machine 
  if(state == stateStatic ){
    staticPage();
  }
  
  else if(state == stateRap){
    drawRap();
    
  } 
  else if(state == statePop){
    drawRap();
 
}
  else if(state == stateChill){
    drawChill();
    
}
 else if(state == stateRandom){
    drawRandom();
    startTimer.start();
  }
 else{
   staticPage();
  }
} 

// if input value is 1 (from ESP32, indicating a button has been pressed), change the background
void drawBackground() {
   if( switchValue == 1 )
    background( 0,255,0 );
  else
    background(0); 
}
//---------------- states ---------------

void staticPage(){ //Welcome Page
  
  textSize(90);
  fill(255);
  text("Welcome Friends!",100, 250);
  textSize(35);
  text("Key: Press Button One Time - Rap Music", 100, 550);
  text("Press Button Two Times - Pop Music",110, 550);
  text("Press Button Three Times - Chill Music",120, 550); 
}

//--- load music-----
void loadStronger(){ //
  stronger = new SoundFile(this,"Stronger.wav");
}

void loadThank(){
  thankyou = new SoundFile(this,"TUN.wav");
}

void loadPiano(){
  piano = new SoundFile(this,"Piano.wav");
  
}

void loadPlayingGames(){
  piano = new SoundFile(this,"PlayingGames.wav");
  
}
//states
void drawRap(){ //RAP state
  background(251, 5, 58);
  textAlign(CENTER);
  textSize(78);
  text("Stronger",500, 460);
  textAlign(CENTER);
  textSize(58);
  text("Kanye West",500, 500);
  imageMode(CENTER);
  image(strongCover, width/2, height/2);
 
  player = minim.loadFile("Stronger.wav", 2048); //load the file using minim
  player.play();
 // player.rewind();
}

void drawPop(){ //POP state
  background(240, 5, 251);
  textAlign(CENTER);
  textSize(78);
  text("Thank U, Next",500, 460);
  textAlign(CENTER);
  textSize(58);
  text("Ariana Grande",500, 500);
  imageMode(CENTER);
  image(tunCover, width/2, height/2);
  
  player = minim.loadFile("TUN.wav",2048);//2048 samples buffer long
  player.play();
  //player.rewind();
}

void drawChill(){ //CHILL state
  background(27, 168, 121);
  textAlign(CENTER);
  textSize(78);
  text("Bria's Interlude (Drake)",500, 460);
  textAlign(CENTER);
  textSize(58);
  text("The Theorist",500, 500);
  imageMode(CENTER);
  image(pianoCover, width/2, height/2);
  
  player = minim.loadFile("piano.wav",2048);
  player.play();
 // player.rewind();
}

///-------for sensor music player --- 
int lf = 10;    // Linefeed in ASCII
String myString = null;
Serial Port;  // The serial port
int sensorValue = 0;

void drawRandom(){ //RANDOM state
  background(27, 168, 121);
  textAlign(CENTER);
  textSize(78);
  text("Playing Games",500, 460);
  textAlign(CENTER);
  textSize(58);
  text("Summer Walker",500, 500);
  imageMode(CENTER);
  image(pgCover, width/2, height/2);
  player = minim.loadFile("PlayingGames.mp3"); //load song
  
 
  while (Port.available() > 0) {
    // store the data in myString 
    myString = Port.readStringUntil(lf); //read string from port
    // check if we really have something
    if (myString != null) {
      myString = myString.trim(); // let's remove whitespace characters
         if(potValue >= 0 && potValue < 2000){
           player.play();
         }
     
  //  else if(potValue >= 1000 && potValue < 2000){
  //  }
    
  //  else if(potValue >= 2000 && potValue < 5000){
  //    
  //  }
  //} 
//        if(myString.equals("T")){
//          if(player.isPlaying() == false){
//            player.play();
//          }
//        }
 }   
 }
}

void stop(){
  // always close Minim audio classes when you are done with them
  player.close();
  // always stop Minim before exiting
  minim.stop();
  
  super.stop();
}


void keyPressed(){
  if(key == '1'){
    state = stateStatic;
  }
  

  else if(key == '2'){
    state = stateRap;
  }
  
  else if(key == '3') {
    state = statePop;
  }
  
  else if(key == '4'){
    state = stateChill;
  }
  
   else if(key == '5'){
    state = stateRandom;
  }
  
}
