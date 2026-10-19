//week07_4_processing_serial_audio_do_re_mi
import processing.serial.*;
Serial myPort;
import processing.sound.*;
SoundFile Do,re,mi;
void setup(){
  size(300,200);
  myPort=new Serial(this,"COM4",9600);
  Do=new SoundFile(this,"do.wav");
  re=new SoundFile(this,"re.wav");
  mi=new SoundFile(this,"mi.wav");
}
void draw(){
  rect(0,0,100,200);
  rect(100,0,100,200);
  rect(200,0,100,200);
}
void mousePressed(){
  if(mouseX<100){
    Do.play();
    myPort.write("1");
  }
  else if(mouseX<200){
    re.play();
    myPort.write("2");
  }
  else{
    mi.play();
    myPort.write("3");
  }
}
void mouseReleased(){
  myPort.write("0");
}
