//week06_4_processing_rotate_serial_myPort_available_read
import processing.serial.*;
Serial myPort;
void setup(){
  size(500,500);
  myPort=new Serial(this,"COM4",9600);
}
int now=0,d=1;
void draw(){
  if(myPort.available()>0){
    if(boolean(myPort.read())) d*=-1;
  }
  background(0);
  translate(250,250);
  now+=d;
  rotate(radians(now));
  rect(-200,-200,400,400);
}
void mousePressed(){
  d*=-1;
}
