
/*
  Joystick Rhythm Master
  MakerUNO + KY-023

  VRx -> A0
  VRy -> A1
  SW  -> D2

  LED -> D13
  Buzzer -> D8
*/

const int JOY_X = A0;
const int JOY_Y = A1;
const int JOY_SW = 2;

const int LED_PIN = 13;
const int BUZZER_PIN = 8;

// 方向定義
enum Direction {
  CENTER,
  UP,
  DOWN,
  LEFT,
  RIGHT
};

Direction currentDirection = CENTER;

// 搖桿判斷門檻
const int LOW_THRESHOLD = 350;
const int HIGH_THRESHOLD = 700;

// 回到中心的判斷範圍
const int CENTER_LOW = 420;
const int CENTER_HIGH = 604;

// SW 防彈跳
int lastButtonState = HIGH;
unsigned long lastDebounceTime = 0;
const unsigned long debounceDelay = 40;

String command = "";

void setup() {

  Serial.begin(9600);

  pinMode(JOY_SW, INPUT_PULLUP);

  pinMode(LED_PIN, OUTPUT);
  pinMode(BUZZER_PIN, OUTPUT);

  digitalWrite(LED_PIN, LOW);

  Serial.println("READY");

}

void loop() {

  readJoystick();

  readButton();

  receiveCommand();

}

// =============================
// 讀取搖桿
// =============================

void readJoystick() {

  int x = analogRead(JOY_X);
  int y = analogRead(JOY_Y);

  Direction newDirection = CENTER;

  // 判斷方向
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

  // 只有原本在中心時才觸發
  if (currentDirection == CENTER &&
      newDirection != CENTER) {

    sendDirection(newDirection);

    currentDirection = newDirection;

  }

  // 必須回到中心才允許下一次觸發
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

  if ((millis() - lastDebounceTime) > debounceDelay) {

    static int stableState = HIGH;

    if (reading != stableState) {

      stableState = reading;

      if (stableState == LOW) {

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

      if (command == "LED_ON") {

        digitalWrite(LED_PIN, HIGH);

      }

      else if (command == "LED_OFF") {

        digitalWrite(LED_PIN, LOW);

      }

      else if (command == "BEEP") {

        tone(BUZZER_PIN, 880, 100);

      }

      else if (command == "BUZZER_OFF") {

        noTone(BUZZER_PIN);

      }

      command = "";

    }

    else {

      command += c;

    }

  }

}
