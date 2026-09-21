//week03_3_arduino_flow_LED
void setup(){
  for(int i=2;i<14;i++) pinMode(i,OUTPUT);
}

void loop(){
  for(int i=2;i<14;i++){
    for(int k=2;k<14;k++) digitalWrite(k,LOW);
    digitalWrite(i,HIGH);
    delay(100);
  }
}
