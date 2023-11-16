import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

//declare global variables at the top of your sketch
//AudioContext ac; is declared in helper_functions

SamplePlayer buttonSound;
Gain masterGain;
Glide gainGlide; // to change the glide value, smoothlu chage gain value up/ dowm
BiquadFilter lpFilter;
ControlP5 p5;



//end global variables

//runs once when the Play button above is pressed
void setup() {
  size(320, 240); //size(width, height) must be the first line in setup()
  ac = new AudioContext(); //AudioContext ac; is declared in helper_functions 
  p5 = new ControlP5(this);
  
  buttonSound = getSamplePlayer("new.wav");
  buttonSound.pause(true);
  
  //Create glide to smoothly change masterGain
  gainGlide = new Glide(ac, 1.0, 500);
  //lpFilter = new BiquadFilter(ac, 1);
  lpFilter = new BiquadFilter(ac, BiquadFilter.Type.LP , 1.0, 1.0);
  masterGain = new Gain(ac, 2, gainGlide);
  //masterGain.setValue(.5)// instant change
  //gainGlide.setValue(.5); // slowing change the volume
  
  lpFilter.addInput(buttonSound);
  masterGain.addInput(lpFilter);
  
 
  
  
  //ac.out.addInput(buttonSound);
  ac.out.addInput(masterGain);
  
  //create GUI control
  p5.addButton("Play")
    .setPosition(width/2+30,110)
    .setSize(60,20)
    .setLabel("Play Music")
    .activateBy((ControlP5.RELEASE));
    
   p5.addSlider("GainGlider")
    .setPosition(20,20)
    .setSize(20,200)
    .setRange(0,100)
    .setValue(50)
    .setLabel("Gain");
    
   p5.addButton("filter")
     .setPosition(width/2+30,140)
     .setSize(80,20)
     .setLabel("increase Freq")
     .activateBy((ControlP5.RELEASE));
    
    
  ac.start();
}

public void Play(int value) {
  println("play button pressed");
  buttonSound.start();
  buttonSound.setToLoopStart();
  
}
public void GainGlider(float value) {
  println("gain slider moved",value);
  gainGlide.setValue(value/100.0);
}

public void filter(float val) {
  lpFilter.setFrequency(lpFilter.getFrequency() + val*10);
  println(lpFilter.getFrequency());
  
}

void draw() {
  background(0);  //fills the canvas with black (0) each frame
  
}
