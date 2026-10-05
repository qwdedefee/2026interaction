//week05_1_do_re_mi_Serial
void setup(){
  Serial.begin(9600);
}
void loop(){
  if(Serial.available()){
    char c=Serial.read();
    if(c=='1') tone(8,523,1000);
    if(c=='2') tone(8,587,1000);
    if(c=='3') tone(8,659,1000);
  }
}
