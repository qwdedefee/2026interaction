//week06_4_arduino_rotate_Serial_begin_write
int mode=0;
void setup() {
  Serial.begin(9600);
  pinMode(2,INPUT_PULLUP);
  for(int i=3;i<14;i++) pinMode(i,OUTPUT);
  tone(8,523,100); delay(100);
  tone(8,784,100); delay(100);
}
int p=1,now=3;
void loop() {
  if(p&&digitalRead(2)==LOW){
    if(mode){
      mode--;
      tone(8,523,100); delay(100);
      tone(8,784,100); delay(100);
    }
    else{
      mode++;
      tone(8,784,100); delay(100);
      tone(8,523,100); delay(100);
    }
    p--;
    Serial.write('1');
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
