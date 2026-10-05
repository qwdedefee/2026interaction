//week05_1_processing_do_re_mi_serial
import processing.serial.*;
Serial myPort;
void setup(){
  size(300,200);
  myPort=new Serial(this,"COM4",9600);
}
void draw(){
  
}
void keyPressed(){
  if(key=='1') myPort.write('1');
  if(key=='2') myPort.write('2');
  if(key=='3') myPort.write('3');
}
