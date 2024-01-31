import beads.*;
import org.jaudiolibs.beads.*;
import java.util.*;
import controlP5.*;

//to use text to speech functionality, copy text_to_speech.pde from this sketch to yours
//example usage below

//IMPORTANT (notice from text_to_speech.pde):
//to use this you must import 'ttslib' into Processing, as this code uses the included FreeTTS library
//e.g. from the Menu Bar select Sketch -> Import Library... -> ttslib
long time =0;
boolean track = false;
TextToSpeechMaker ttsMaker; 
PImage bg;
boolean sensorMode = false;
float HP_CUTOFF = 5000.0;

Glide cutoffGlide;
BiquadFilter filter;
//<import statements here>

ControlP5 p5;
SamplePlayer lesson;
SamplePlayer posture;
SamplePlayer keyErr;
SamplePlayer finErr;
Gain masterGain;

Glide gainGlide;
//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON1 = "TouchData1.json";
String eventDataJSON2 = "TouchData2.json";
String eventDataJSON3 = "TouchData3.json";

NotificationServer server;
ArrayList<Notification> notifications;

Example example;

//Comparator<Notification> comparator;
//PriorityQueue<Notification> queue;
PriorityQueue<Notification> q2;

void setup() {
  size(1040,800);
  bg = loadImage("typebg.png");
  p5 = new ControlP5(this);
  
  NotificationComparator priorityComp = new NotificationComparator();
  
  q2 = new PriorityQueue<Notification>(10, priorityComp);
  
  //comparator = new NotificationComparator();
  //queue = new PriorityQueue<Notification>(10, comparator);
  
  ac = new AudioContext(); //ac is defined in helper_functions.pde
  lesson = getSamplePlayer("lesson.wav");
  lesson.pause(true);
  
  posture = getSamplePlayer("new.wav");
  posture.pause(true);
  
  keyErr = getSamplePlayer("keyerr.wav");
  keyErr.pause(true);
  
  finErr = getSamplePlayer("finerr.wav");
  finErr.pause(true);
  
  gainGlide = new Glide(ac, 1.0, 500);
  masterGain = new Gain(ac, 2, gainGlide);
  
  masterGain.addInput(posture);
  
  
 //cutoffGlide = new Glide(ac, 1500.0, 50);
 filter = new BiquadFilter(ac, BiquadFilter.AP, cutoffGlide, 0.5f);
 filter.addInput(finErr);
 
  
 server = new NotificationServer();
  
  //instantiating a custom class (seen below) and registering it as a listener to the server
  example = new Example();
  server.addListener(example);
  
  //END NotificationServer setup
  
  ac.out.addInput(masterGain);
  ac.out.addInput(lesson);
  ac.out.addInput(finErr);
  ac.out.addInput(keyErr);
  ac.out.addInput(filter);

  p5.addButton("Start")
    .setPosition(width-200,height/4)
    .setSize(width/6,30)
    .activateBy((ControlP5.RELEASE));
  
  p5.addButton("Key_Error")
    .setPosition(width-200,height/4+40)
    .setSize(width/6,30)
    .activateBy((ControlP5.RELEASE));
  
  p5.addButton("Finger_Type_error")
    .setPosition(width-200,height/4+80)
    .setSize(width/6,30)
    .activateBy((ControlP5.RELEASE));
    
  p5.addButton("Track_Posture")
    .setPosition(width-200,height/4 + 120)
    .setSize(width/6,30)
    .activateBy((ControlP5.RELEASE));
 
 p5.addButton("stressCheck")
    .setPosition(width-200,height/4 + 160)
    .setSize(width/6,30)
    .activateBy((ControlP5.RELEASE))
    .setLabel("Stress");
   
   p5.addSlider("GainGlider")
    .setPosition(width-200,height/4 + 200)
    .setSize(20,200)
    .setRange(0,100)
    .setValue(8)
    .setLabel("Control Posture");
   
   p5.addButton("Lesson_with_SensorData")
    .setPosition(40,height/4 + 120)
    .setSize(width/6,30)
    .activateBy((ControlP5.RELEASE));
  
  
    
  
  ac.start();
  
}
public void Start(int value) {
  
  println("play button pressed");
  lesson.start();
  track = true;
  
}


public void Lesson_with_SensorData(int value) {
  println("play button pressed");
  
  sensorMode = true;
  lesson.start();
  track = true;
  posture.start();
  
  posture.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
  
}



public void GainGlider(float value) {
  println("gain slider moved",value);
  if(!sensorMode)
    gainGlide.setValue(value/100.0);
}

public void Track_Posture(int value) {
  println("posture button pressed");
  posture.reset();
  posture.start();
  posture.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
}

public void Key_Error(int value) {
  keyErr.reset();
  keyErr.start();
}
public void Finger_Type_error(int value) {
  finErr.reset();
  finErr.start();
  filter.setType(BiquadFilter.HP);
}

public void stressCheck() {
  ttsMaker = new TextToSpeechMaker();
  
  String exampleSpeech = "Take a break";
  
  ttsExamplePlayback(exampleSpeech);
}


void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()
  if(track) time++;
  background(65,105,225);
  image(bg, width/4, 20 ,width/2, height/2);
  fill(25,25,112);
  circle(width-150, 100, 150);
  circle(100, 100, 150);
  fill(255, 255, 255);
  textSize(30);
  text("Manual\nControl", width-195, 90);
  text("Sensor\nmode", 55, 90);
  fill(0, 0, 0);
  text("Please click on the key in lesson audio", 40, 500);
  if(time == 5500) {
    stressCheck();
  }
}
int  index = -1;
char k;
boolean err = false;
boolean body = false;
void keyPressed() {
  //example of stopping the current event stream and loading the second one
  k = key;
  index++;
  err = false;
  body = false;
  //if (key == RETURN || key == ENTER) {
   server.stopEventStream(); //always call this before loading a new stream
   if(index%3==0)
     server.loadEventStream(eventDataJSON1);
   else if(index%2==0)
      server.loadEventStream(eventDataJSON2);
   else
      server.loadEventStream(eventDataJSON3);
       
   
    println("**** New event stream loaded: " + eventDataJSON1+ " ****");
  //}
    
}



void ttsExamplePlayback(String inputSpeech) {
  //create TTS file and play it back immediately
  //the SamplePlayer will remove itself when it is finished in this case
  
  String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
  println("File created at " + ttsFilePath);
  
  //createTTSWavFile makes a new WAV file of name ttsX.wav, where X is a unique integer
  //it returns the path relative to the sketch's data directory to the wav file
  
  //see helper_functions.pde for actual loading of the WAV file into a SamplePlayer
  
  SamplePlayer sp = getSamplePlayer(ttsFilePath, true); 
  //true means it will delete itself when it is finished playing
  //you may or may not want this behavior!
  
  ac.out.addInput(sp);
  sp.setToLoopStart();
  sp.start();
  println("TTS: " + inputSpeech);
}




class Example implements NotificationListener {
  
  public Example() {
    //setup here
  }  
  
  //this method must be implemented to receive notifications
  public void notificationReceived(Notification notification) { 
    List<Character> order = Arrays.asList(' ','u',' ','r',' ','k',' ','d',' ','e',' ',
    'i',' ','c',' ','g',' ','n',' ','j');
    println(k +" "+ index+" " + order.get(index));
    
    Map<String, String> keyFin = new HashMap<>();
    keyFin.put("j","index");
    keyFin.put("f","index");
    keyFin.put("k","middle");
    keyFin.put("u","index");
    keyFin.put("r","index");
    keyFin.put("d","middle");
    keyFin.put("e","middle");
    keyFin.put("i","middle");
    keyFin.put("c","middle");
    keyFin.put("g","index");
    keyFin.put("n","index");
    keyFin.put("j","index");
    keyFin.put("q","pinky");
    keyFin.put(" ","thumb");
    
    
    //println("<Example> " + notification.getType().toString() + " notification received at " 
    //+ Integer.toString(notification.getTimestamp()) + " ms");
    boolean unhealthy = false;
    String debugOutput = ">>> ";
  
    if(time == notification.getTimestamp()) println("OKKKK");
    switch (notification.getType()) {
      case Craniovertebral_angle:
        if(notification.getAngle() >55 || notification.getAngle() < 50) 
          unhealthy = true;
        break;
      case Sagittal_head_tilt:
       if(notification.getAngle() >90 || notification.getAngle() < 80) 
          unhealthy = true;
        break;
      case Sagittal_shoulderC7_angle:
        if(notification.getAngle() >30 || notification.getAngle() < 20) 
          unhealthy = true;
        break;
      case Coronal_head_tilt:
        if(notification.getAngle() >25 || notification.getAngle() < 19) 
          unhealthy = true;
        break;
      case Coronal_shoulder_angle:
        if(notification.getAngle() >90 || notification.getAngle() < 80) 
          unhealthy = true;
        break;
      case Thoracic_kyphosis_angle:
        if(notification.getAngle() >25 || notification.getAngle() < 19) 
          unhealthy = true;
        break;
       case hand_angle:
        if(notification.getAngle() >185 || notification.getAngle() < 150) 
          unhealthy = true;
        break;
    }
    debugOutput += notification.toString();
   
     if(unhealthy) {
        println("UUUUUUUUUUU"+ gainGlide.getValue());
        gainGlide.setValue(.7);
        println("UUUUUUUUUUU"+ gainGlide.getValue());
        body = true;
     }
     else { 
       if(!body)
           gainGlide.setValue(.08);
     }
     
     
     if(!err){
       if(k != order.get(index)){
         Key_Error(0);
       } else if(!keyFin.get(notification.getKey()).equals(notification.getFinger())){
         Finger_Type_error(0); 
       }
       err = true;
     }
     
    
   //You can experiment with the timing by altering the timestamp values (in ms) in the exampleData.json file
    //(located in the data directory)
  }
}
