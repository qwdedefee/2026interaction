//week06_2_arduino_button_change_mode_LED_flow
int mode=0;
void setup() {
  pinMode(2,INPUT_PULLUP);
  for(int i=3;i<14;i++) pinMode(i,OUTPUT);
  tone(8,523,100); delay(100);
  tone(8,784,100); delay(100);
}
int p=1,now=3;
void loop() {
  if(p&&digitalRead(2)==LOW){
    if(mode) mode--;
    else mode++;
    p--;
  }
  else if(p==0&&digitalRead(2)==HIGH){
    p++;
  }
  if(mode){
    now--;
    if(now<3) now=13;
    digitalWrite(now,HIGH);
    delay(100);
    digitalWrite(now,LOW);
  }
  else{
    now++;
    if(now>13) now=3;
    digitalWrite(now,HIGH);
    delay(100);
    digitalWrite(now,LOW); 
  }
}
