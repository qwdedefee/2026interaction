//week11_1_arduino_joystick_analongRead_A0_A1
void setup() {

}
void loop() {
  int x=analogRead(A0),y=analogRead(A1);
  tone(8,x);
}
