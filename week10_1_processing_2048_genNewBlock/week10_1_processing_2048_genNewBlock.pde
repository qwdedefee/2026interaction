//week10_1_processing_2048_genNewBlock
void setup(){
  size(550,550);
  gen();
}
//int [][]a={{0,2,0,0},{0,0,0,0},{0,2,2,2},{4,4,4,4}};
int [][]a=new int[4][4];
void gen(){
  int zero=0;
  for(int i=0;i<4;i++){
    for(int j=0;j<4;j++){
      if(a[i][j]==0) zero++;
    }
  }
  int choose=int(random(zero));
  for(int i=0;i<4;i++){
    for(int j=0;j<4;j++){
      if(a[i][j]==0){
        if(choose==0) a[i][j]=2;
        choose--;
      }
    }
  }
}
void keyPressed(){
  gen();
}
void draw(){
  background(250,248,239);
  noStroke();
  fill(187,173,160);
  rect(40,40,450,450,9);
  for(int i=0;i<4;i++){
    for(int j=0;j<4;j++){
      int x=j*110+50,y=i*110+50;
      fill(tileColor(a[i][j]));
      rect(x,y,100,100,6);
    }
  }
}
int tileColor(int n) {
  switch(n) {
    case 0:return color(205,193,180);
    case 2:return color(238,228,218);
    case 4:return color(237,224,200);
    case 8:return color(242,177,121);
    case 16:return color(245,149,99);
    case 32:return color(246,124,95);
    case 64:return color(246,94,59);
    case 128:return color(237,207,114);
    case 256:return color(237,204,97);
    case 512:return color(237,200,80);
    case 1024:return color(237,197,63);
    default:return color(237,194,46);
  }
}
