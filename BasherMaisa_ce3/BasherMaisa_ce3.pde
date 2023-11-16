import controlP5.*;
import beads.*;
import org.jaudiolibs.beads.*;

ControlP5 p5;
SamplePlayer music;
SamplePlayer gps1;
SamplePlayer gps2;

Gain masterGain;

Gain musicGain;

Glide masterGainGlide;
Glide musicGainGlide;

BiquadFilter duckFilter;
Glide filterGlide;
float HP_CUTOFF = 5000.0;

void setup() {
  size(320, 240);
  ac = new AudioContext();
  
  p5 = new ControlP5(this);
  
  Bead endListener = new Bead() {
    public void messageReceived(Bead message) {
      
      SamplePlayer sp = (SamplePlayer) message;
      
      filterGlide.setValue(10.0);
      duckFilter.setType(BiquadFilter.AP);
      
      musicGainGlide.setValue(1.0);
      
      sp.pause(true);
    }
  };
  
  music = getSamplePlayer("intermission.wav");
  
  gps1 = getSamplePlayer("gps-1.wav");
  gps2 = getSamplePlayer("gps-2.wav");
  
  gps1.setEndListener(endListener);
  gps2.setEndListener(endListener);
  
  music.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  
  gps1.pause(true);
  gps2.pause(true);
  
  musicGainGlide = new Glide(ac, 1.0, 500);
  musicGain = new Gain(ac, 1, musicGainGlide);
  
  masterGainGlide = new Glide(ac, 1.0, 500);
  masterGain = new Gain(ac, 1, masterGainGlide);
  
  filterGlide = new Glide(ac, 10.0, 500);
  duckFilter = new BiquadFilter(ac, BiquadFilter.HP, filterGlide, .5);
  
  duckFilter.addInput(music);
  
  musicGain.addInput(duckFilter);
  
  masterGain.addInput(musicGain);
  
  masterGain.addInput(gps1);
  masterGain.addInput(gps2);
  
  ac.out.addInput(masterGain);
  
  p5.addSlider("GainSlider")
    .setPosition(20,20)
    .setSize(20,200)
    .setValue(30.0)
    .setLabel("Master Gain");
    
  p5.addButton("PlayGPS1")
    .setPosition(width/2 -20, 110)
    .setSize(width/2-20, 20)
    .setLabel("Voice 1");
    
  p5.addButton("PlayGPS2")
    .setPosition(width/2 -20, 140)
    .setSize(width/2-20, 20)
    .setLabel("Voice 2");
    
  ac.start();
  

}

public void PlayGPS1() {
  gps2.pause(true);
  
  filterGlide.setValue(HP_CUTOFF);
  duckFilter.setType(BiquadFilter.HP);
  
  musicGainGlide.setValue(.5);
  gps1.reset();
  gps1.start();
  
}

public void PlayGPS2(){
  gps1.pause(true);
  
  filterGlide.setValue(HP_CUTOFF);
  duckFilter.setType(BiquadFilter.HP);
  
  musicGainGlide.setValue(.5);
  gps2.reset();
  gps2.start();
}

public void GainSlider(float value) {
  masterGain.setValue(value/100.0);
  
}

void draw() {
  background(0);
}
