//week11_3_processing_joystick_serial_available_3_myPort_read
import processing.serial.*;
Serial myPort;
void setup(){
  size(512,512);
  myPort=new Serial(this,"COM4",9600);
}
int x=0,y=0,sw=0;
void draw(){
  background(255);
  if(myPort.available()>=3){
    x=(int)myPort.read();
    y=(int)myPort.read();
    sw=(int)myPort.read();
    //myPort.read();
  }
  ellipse(x+128,y+128,8,8);
}
