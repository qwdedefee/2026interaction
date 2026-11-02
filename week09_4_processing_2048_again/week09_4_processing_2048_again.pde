//week09_4_processing_2048_again
void setup(){
  size(550,550);
}
void draw(){
  background(250,248,239);
  noStroke();
  fill(187,173,160);
  rect(40,40,450,450,9);
  for(int i=0;i<4;i++){
    for(int j=0;j<4;j++){
      int x=j*110+50,y=i*110+50;
      fill(238,228,218);
      rect(x,y,100,100,6);
    }
  }
}
