//week09_1_arduino_ai_makerUNO_PCM_D8
#include "PCM.h"
#include "sounddata.h"
void setup() {
  startPlayback(sounddata_data, sounddata_length);
}

void loop() {
  // One-shot sample plays for 1 second. Press RESET to play again.
}
