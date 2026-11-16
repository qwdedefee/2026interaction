//week11_2_arduino_joystick_serial_println
void setup() {
  Serial.begin(9600);
  pinMode(2,INPUT_PULLUP);
}
void loop() {
  int x=analogRead(A0),y=analogRead(A1),sw=0;
  if(digitalRead(2)==LOW) sw=1;
  else sw=0;
  char line[200];
  sprintf(line,"x:%d y:%d sw%d\n",x,y,sw);
  Serial.print(line);
}
