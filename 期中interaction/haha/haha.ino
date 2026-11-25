
/*
  Joystick Rhythm Master
  MakerUNO + KY-023

  VRx -> A0
  VRy -> A1
  SW  -> D2

  LED -> D13
  Buzzer -> D8

  Serial: 9600

  只有每 5 次 Combo 播放特殊音效
*/

const int JOY_X = A0;
const int JOY_Y = A1;
const int JOY_SW = 2;

const int LED_PIN = 13;
const int BUZZER_PIN = 8;

// =============================
// 方向定義
// =============================

enum Direction {
  CENTER,
  UP,
  DOWN,
  LEFT,
  RIGHT
};

Direction currentDirection = CENTER;

const int LOW_THRESHOLD = 350;
const int HIGH_THRESHOLD = 700;

const int CENTER_LOW = 420;
const int CENTER_HIGH = 604;

// =============================
// SW 防彈跳
// =============================

int lastButtonState = HIGH;
int stableButtonState = HIGH;

unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 40;

// =============================
// Serial 接收
// =============================

String command = "";

// =============================
// 音效佇列
// =============================

const byte QUEUE_SIZE = 16;

bool comboQueue[QUEUE_SIZE];

byte queueHead = 0;
byte queueTail = 0;
byte queueCount = 0;

// =============================
// 音效播放狀態
// =============================

bool soundPlaying = false;

byte soundStep = 0;

unsigned long soundStepStart = 0;
unsigned long soundStepDuration = 0;

// =============================
// Setup
// =============================

void setup() {

  Serial.begin(9600);

  pinMode(JOY_SW, INPUT_PULLUP);

  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  digitalWrite(LED_PIN, LOW);
  noTone(BUZZER_PIN);

  Serial.println("READY");

}

// =============================
// Main Loop
// =============================

void loop() {

  readJoystick();

  readButton();

  receiveCommand();

  updateBuzzer();

}

// =============================
// 讀取搖桿
// =============================

void readJoystick() {

  int x = analogRead(JOY_X);
  int y = analogRead(JOY_Y);

  Direction newDirection = CENTER;

  if (y < LOW_THRESHOLD) {
    newDirection = UP;
  }
  else if (y > HIGH_THRESHOLD) {
    newDirection = DOWN;
  }
  else if (x < LOW_THRESHOLD) {
    newDirection = LEFT;
  }
  else if (x > HIGH_THRESHOLD) {
    newDirection = RIGHT;
  }

  if (currentDirection == CENTER &&
      newDirection != CENTER) {

    sendDirection(newDirection);

    currentDirection = newDirection;

  }

  if (x > CENTER_LOW &&
      x < CENTER_HIGH &&
      y > CENTER_LOW &&
      y < CENTER_HIGH) {

    currentDirection = CENTER;

  }

}

// =============================
// 傳送方向
// =============================

void sendDirection(Direction dir) {

  switch (dir) {

    case UP:
      Serial.println("UP");
      break;

    case DOWN:
      Serial.println("DOWN");
      break;

    case LEFT:
      Serial.println("LEFT");
      break;

    case RIGHT:
      Serial.println("RIGHT");
      break;

    default:
      break;

  }

}

// =============================
// 搖桿按壓 SW
// =============================

void readButton() {

  int reading = digitalRead(JOY_SW);

  if (reading != lastButtonState) {
    lastDebounceTime = millis();
  }

  if (millis() - lastDebounceTime > debounceDelay) {

    if (reading != stableButtonState) {

      stableButtonState = reading;

      if (stableButtonState == LOW) {
        Serial.println("SELECT");
      }

    }

  }

  lastButtonState = reading;

}

// =============================
// 接收 Processing 指令
// =============================

void receiveCommand() {

  while (Serial.available() > 0) {

    char c = Serial.read();

    if (c == '\n') {

      command.trim();

      handleCommand(command);

      command = "";

    }
    else if (c != '\r') {

      if (command.length() < 40) {
        command += c;
      }
      else {
        command = "";
      }

    }

  }

}

// =============================
// 處理指令
// =============================

void handleCommand(String cmd) {

  if (cmd == "LED_ON") {

    digitalWrite(LED_PIN, HIGH);

  }

  else if (cmd == "LED_OFF") {

    digitalWrite(LED_PIN, LOW);

  }

  // 只有 Combo 特殊音效
  else if (cmd == "SFX_COMBO") {

    enqueueComboSound();

  }

  // 其他音效指令一律忽略
  else if (cmd == "SFX_PERFECT" ||
           cmd == "SFX_GOOD" ||
           cmd == "SFX_BAD" ||
           cmd == "SFX_MISS") {

    // 不播放任何聲音

  }

  else if (cmd == "BUZZER_OFF") {

    clearSoundQueue();

    noTone(BUZZER_PIN);

    soundPlaying = false;

  }

}

// =============================
// 加入 Combo 音效佇列
// =============================

void enqueueComboSound() {

  if (queueCount >= QUEUE_SIZE) {
    return;
  }

  comboQueue[queueTail] = true;

  queueTail = (queueTail + 1) % QUEUE_SIZE;

  queueCount++;

}

// =============================
// 清空音效佇列
// =============================

void clearSoundQueue() {

  queueHead = 0;
  queueTail = 0;
  queueCount = 0;

}

// =============================
// 取得下一個音效
// =============================

bool dequeueComboSound() {

  if (queueCount == 0) {
    return false;
  }

  queueHead = (queueHead + 1) % QUEUE_SIZE;

  queueCount--;

  return true;

}

// =============================
// 開始播放 Combo 音效
// =============================

void startComboSound() {

  soundStep = 0;

  soundPlaying = true;

  playSoundStep();

}

// =============================
// 播放音效階段
// =============================

void playSoundStep() {

  soundStepStart = millis();

  if (soundStep == 0) {

    tone(BUZZER_PIN, 1000);
    soundStepDuration = 45;

  }

  else if (soundStep == 1) {

    noTone(BUZZER_PIN);
    soundStepDuration = 25;

  }

  else if (soundStep == 2) {

    tone(BUZZER_PIN, 1300);
    soundStepDuration = 45;

  }

}

// =============================
// 更新蜂鳴器
// =============================

void updateBuzzer() {

  if (!soundPlaying) {

    if (dequeueComboSound()) {

      startComboSound();

    }
    else {

      return;

    }

  }

  if (millis() - soundStepStart < soundStepDuration) {
    return;
  }

  soundStep++;

  if (soundStep <= 2) {

    playSoundStep();

  }

  else {

    noTone(BUZZER_PIN);

    soundPlaying = false;

  }

}
