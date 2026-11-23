
import processing.sound.*;
import processing.serial.*;
import java.util.ArrayList;

// ==========================================
// JOYSTICK RHYTHM MASTER
// ==========================================

// 畫面設定
final int SCREEN_W = 600;
final int SCREEN_H = 680;

// 遊戲狀態
final int MENU = 0;
final int PLAYING = 1;
final int RESULT = 2;

int gameState = MENU;

// ==========================================
// Arduino Serial 設定
// ==========================================

Serial port;
int serialPortIndex = 2;

// ==========================================
// 音樂設定
// ==========================================

SoundFile[] songs;

String[] songNames = {
  "Song 1 - Easy Rhythm",
  "Song 2 - Normal Rhythm",
  "Song 3 - Hard Rhythm"
};

String[] songFiles = {
  "song1.mp3",
  "song2.mp3",
  "song3.mp3"
};

// 三首歌曲統一 BPM
int[] songBPM = {
  120, 120, 120
};

// 0 = LEFT
// 1 = DOWN
// 2 = UP
// 3 = RIGHT

int[][] songPatterns = {
  {
    2,0,1,3,2,3,0,1,
    1,2,3,0,3,1,2,0
  },

  {
    0,1,2,3,0,2,1,3,
    3,2,1,0,1,3,0,2,
    2,0,3,1
  },

  {
    2,3,1,0,3,0,2,1,
    0,2,3,1,1,0,3,2,
    2,1,0,3,3,1,2,0
  }
};

int songIndex = 0;

// 歌曲起始偏移
int[] songOffsetMs = {
  0, 0, 0
};

// 遊戲時間：60 秒
int gameDurationMs = 60000;

int musicStartTime = 0;

boolean musicStarted = false;

// ==========================================
// 難度設定
// ==========================================

// 0 = Easy
// 1 = Normal
// 2 = Hard

String[] difficultyNames = {
  "EASY",
  "NORMAL",
  "HARD"
};

int difficulty = 0;

// 箭頭下落時間
int[] approachTimes = {
  1800, 1500, 1200
};

// 判定時間
int[] perfectWindows = {
  130, 100, 70
};

int[] goodWindows = {
  230, 200, 150
};

int[] badWindows = {
  330, 300, 250
};

// ==========================================
// 箭頭與遊戲畫面
// ==========================================

ArrayList<Note> notes = new ArrayList<Note>();

float laneTop = 160;
float judgmentY = 540;

float[] laneX = {
  150, 250, 350, 450
};

String[] laneNames = {
  "LEFT", "DOWN", "UP", "RIGHT"
};

color[] laneColors = {
  color(80, 150, 255),
  color(80, 220, 150),
  color(255, 190, 70),
  color(220, 100, 255)
};

// ==========================================
// 分數與 Combo
// ==========================================

int score = 0;

int combo = 0;
int maxCombo = 0;

int perfectCount = 0;
int goodCount = 0;
int badCount = 0;
int missCount = 0;

// ==========================================
// 判定文字
// ==========================================

ArrayList<JudgmentText> judgmentTexts =
  new ArrayList<JudgmentText>();

ArrayList<BonusText> bonusTexts =
  new ArrayList<BonusText>();

// ==========================================
// Processing setup
// ==========================================

void setup() {

  size(600, 680);

  surface.setTitle("JOYSTICK RHYTHM MASTER");

  textAlign(CENTER, CENTER);

  // 載入歌曲
  songs = new SoundFile[3];

  for (int i = 0; i < songs.length; i++) {
    songs[i] = new SoundFile(this, songFiles[i]);
  }

  // 連接 Arduino
  println("Available Serial Ports:");

  println(Serial.list());

  try {

    if (Serial.list().length > 0) {

      port = new Serial(
        this,
        Serial.list()[serialPortIndex],
        9600
      );

      port.clear();

      println("Arduino connected.");

    } else {

      println("No Serial Port Found.");

    }

  } catch(Exception e) {

    println("Serial connection failed.");
    println(e);

  }
}

// ==========================================
// 主畫面
// ==========================================

void draw() {

  background(20, 24, 40);

  if (gameState == MENU) {

    drawMenu();

  } else if (gameState == PLAYING) {

    drawGame();

  } else if (gameState == RESULT) {

    drawResult();

  }
}

// ==========================================
// 選單畫面
// ==========================================

void drawMenu() {

  fill(255);

  textSize(34);

  text(
    "JOYSTICK RHYTHM MASTER",
    width / 2,
    100
  );

  // 歌曲選擇
  textSize(22);

  fill(255, 210, 80);

  text("SELECT SONG", width / 2, 210);

  fill(255);

  textSize(20);

  text(
    songNames[songIndex],
    width / 2,
    255
  );

  textSize(15);

  fill(160, 180, 220);

  text(
    "LEFT / RIGHT : CHANGE SONG",
    width / 2,
    295
  );

  // 難度選擇
  fill(255, 210, 80);

  textSize(22);

  text(
    "SELECT DIFFICULTY",
    width / 2,
    370
  );

  fill(255);

  textSize(24);

  text(
    difficultyNames[difficulty],
    width / 2,
    415
  );

  textSize(15);

  fill(160, 180, 220);

  text(
    "UP / DOWN : CHANGE DIFFICULTY",
    width / 2,
    455
  );

  // 操作說明
  fill(255);

  textSize(19);

  text(
    "PRESS SELECT TO START",
    width / 2,
    550
  );

  textSize(14);

  fill(150, 170, 200);

  text(
    "USE JOYSTICK TO PLAY",
    width / 2,
    590
  );

  text(
    "GAME TIME : 60 SECONDS",
    width / 2,
    620
  );

}

// ==========================================
// 開始遊戲
// ==========================================

void startGame() {

  score = 0;

  combo = 0;
  maxCombo = 0;

  perfectCount = 0;
  goodCount = 0;
  badCount = 0;
  missCount = 0;

  judgmentTexts.clear();
  bonusTexts.clear();

  notes.clear();

  // 產生箭頭
  generateNotes();

  // 立即開始音樂，不再等待 GET READY
  musicStartTime = millis();

  musicStarted = true;

  gameState = PLAYING;

  // 立即播放歌曲
  songs[songIndex].play();

  sendArduino("LED_ON");

}

// ==========================================
// 產生箭頭
// ==========================================

void generateNotes() {

  notes.clear();

  // 三首歌 BPM 相同，均為 120
  float beatTime = 60000.0 / songBPM[songIndex];

  float stepTime = 0;

  // 箭頭間隔只由難度決定
  if (difficulty == 0) {

    // 簡單：每 2 拍一次
    stepTime = beatTime * 2;

  } else if (difficulty == 1) {

    // 中等：每 1 拍一次
    stepTime = beatTime;

  } else {

    // 困難：每半拍一次
    stepTime = beatTime * 0.5;

  }

  int patternLength =
    songPatterns[songIndex].length;

  int patternIndex = 0;

  // 只產生前 60 秒的箭頭
  for (
    float target = songOffsetMs[songIndex];
    target < gameDurationMs;
    target += stepTime
  ) {

    int lane =
      songPatterns[songIndex][patternIndex];

    notes.add(
      new Note(lane, target)
    );

    patternIndex++;

    if (patternIndex >= patternLength) {
      patternIndex = 0;
    }

  }

}

// ==========================================
// 遊戲主畫面
// ==========================================

void drawGame() {

  background(20, 24, 40);

  int songElapsed =
    millis() - musicStartTime;

  drawInformation(songElapsed);

  drawLanes();

  drawNotes(songElapsed);

  checkMiss(songElapsed);

  drawJudgmentTexts();

  drawBonusTexts();

  // 判斷是否所有箭頭都已經結算
  boolean allJudged = true;

  for (Note n : notes) {

    if (!n.judged) {

      allJudged = false;
      break;

    }

  }

  // 60 秒結束，而且所有箭頭都已判定
  if (
    songElapsed >= gameDurationMs &&
    allJudged
  ) {

    endGame();

  }

}

// ==========================================
// 顯示分數、時間與 Combo
// ==========================================

void drawInformation(int songElapsed) {

  fill(255);

  textAlign(LEFT, CENTER);

  textSize(18);

  text(
    "SCORE : " + score,
    20,
    35
  );

  text(
    "COMBO : " + combo,
    20,
    65
  );

  // Combo 每 5 次增加 10 分
  int comboBonus = 0;

  if (combo > 0) {

    comboBonus =
      ((combo - 1) / 5) * 10;

  }

  text(
    "PERFECT BONUS : +" + comboBonus,
    20,
    95
  );

  textAlign(RIGHT, CENTER);

  text(
    "TIME : " +
    nf(
      max(0, gameDurationMs - songElapsed)
      / 1000.0,
      0,
      1
    ) + "s",
    width - 20,
    35
  );

  text(
    difficultyNames[difficulty],
    width - 20,
    65
  );

  text(
    "BPM : 120",
    width - 20,
    95
  );

  textAlign(CENTER, CENTER);

}

// ==========================================
// 繪製四個軌道
// ==========================================

void drawLanes() {

  for (int i = 0; i < 4; i++) {

    stroke(70, 80, 110);

    strokeWeight(2);

    line(
      laneX[i],
      laneTop,
      laneX[i],
      judgmentY + 40
    );

    noStroke();

    fill(laneColors[i]);

    textSize(17);

    text(
      laneNames[i],
      laneX[i],
      135
    );

  }

  // 判定線
  stroke(255);

  strokeWeight(3);

  line(
    90,
    judgmentY,
    510,
    judgmentY
  );

  noStroke();

  fill(255);

  textSize(14);

  text(
    "HIT LINE",
    width / 2,
    judgmentY + 55
  );

}

// ==========================================
// 繪製箭頭
// ==========================================

void drawNotes(int elapsed) {

  for (Note n : notes) {

    if (n.judged) {
      continue;
    }

    float timeDifference =
      n.targetTime - elapsed;

    float y =
      judgmentY -
      (timeDifference /
      approachTimes[difficulty]) *
      (judgmentY - laneTop);

    if (
      y < laneTop - 30 ||
      y > judgmentY + 40
    ) {
      continue;
    }

    drawDirectionalArrow(
      laneX[n.lane],
      y,
      n.lane
    );

  }

}

// ==========================================
// 繪製方向箭頭
// ==========================================

void drawDirectionalArrow(
  float x,
  float y,
  int direction
) {

  pushMatrix();

  translate(x, y);

  float angle = 0;

  if (direction == 0) {
    angle = -HALF_PI;
  } else if (direction == 1) {
    angle = PI;
  } else if (direction == 2) {
    angle = 0;
  } else if (direction == 3) {
    angle = HALF_PI;
  }

  rotate(angle);

  stroke(laneColors[direction]);

  strokeWeight(9);

  strokeCap(ROUND);

  // 箭頭主體
  line(
    0,
    18,
    0,
    -18
  );

  // 箭頭兩側
  line(
    0,
    -18,
    -13,
    -5
  );

  line(
    0,
    -18,
    13,
    -5
  );

  popMatrix();

}

// ==========================================
// 判斷玩家輸入
// ==========================================

void checkHit(int lane) {

  if (
    gameState != PLAYING ||
    !musicStarted
  ) {
    return;
  }

  int elapsed =
    millis() - musicStartTime;

  Note closestNote = null;

  float closestDifference =
    Float.MAX_VALUE;

  // 找出同一軌道中最近的箭頭
  for (Note n : notes) {

    if (
      n.judged ||
      n.lane != lane
    ) {
      continue;
    }

    float difference =
      abs(elapsed - n.targetTime);

    if (
      difference <= badWindows[difficulty] &&
      difference < closestDifference
    ) {

      closestDifference = difference;

      closestNote = n;

    }

  }

  // 沒有可判定的箭頭
  if (closestNote == null) {
    return;
  }

  closestNote.judged = true;

  // PERFECT
  if (
    closestDifference <=
    perfectWindows[difficulty]
  ) {

    perfectCount++;

    combo++;

    if (combo > maxCombo) {
      maxCombo = combo;
    }

    // 第 1~5 次 PERFECT：100 分
    // 第 6~10 次 PERFECT：110 分
    // 第 11~15 次 PERFECT：120 分
    int currentScore =
      100 + ((combo - 1) / 5) * 10;

    score += currentScore;

    addJudgment(lane, "PERFECT");

    addBonusText(
      lane,
      "+" + currentScore
    );

    // 每 5 Combo 播放特殊音效
    if (combo % 5 == 0) {

      sendArduino("SFX_COMBO");

    } else {

      sendArduino("SFX_PERFECT");

    }

  }

  // GOOD
  else if (
    closestDifference <=
    goodWindows[difficulty]
  ) {

    goodCount++;

    combo = 0;

    score += 70;

    addJudgment(lane, "GOOD");

    sendArduino("SFX_GOOD");

  }

  // BAD
  else {

    badCount++;

    combo = 0;

    score += 30;

    addJudgment(lane, "BAD");

    sendArduino("SFX_BAD");

  }

}

// ==========================================
// MISS 判定
// ==========================================

void checkMiss(int elapsed) {

  for (Note n : notes) {

    if (n.judged) {
      continue;
    }

    if (
      elapsed >
      n.targetTime + badWindows[difficulty]
    ) {

      n.judged = true;

      missCount++;

      combo = 0;

      addJudgment(
        n.lane,
        "MISS"
      );

      sendArduino("SFX_MISS");

    }

  }

}

// ==========================================
// 判定文字
// ==========================================

void addJudgment(
  int lane,
  String label
) {

  color judgmentColor;

  if (label.equals("PERFECT")) {

    judgmentColor =
      color(255, 215, 70);

  } else if (label.equals("GOOD")) {

    judgmentColor =
      color(80, 230, 140);

  } else if (label.equals("BAD")) {

    judgmentColor =
      color(255, 150, 60);

  } else {

    judgmentColor =
      color(255, 70, 70);

  }

  judgmentTexts.add(
    new JudgmentText(
      laneX[lane],
      judgmentY - 65,
      label,
      judgmentColor
    )
  );

}

// ==========================================
// 顯示判定文字動畫
// ==========================================

void drawJudgmentTexts() {

  for (
    int i = judgmentTexts.size() - 1;
    i >= 0;
    i--
  ) {

    JudgmentText j =
      judgmentTexts.get(i);

    int elapsed =
      millis() - j.startTime;

    if (elapsed > 800) {

      judgmentTexts.remove(i);

      continue;

    }

    float alpha =
      map(elapsed, 0, 800, 255, 0);

    float y =
      j.y - elapsed * 0.035;

    fill(
      red(j.judgmentColor),
      green(j.judgmentColor),
      blue(j.judgmentColor),
      alpha
    );

    textSize(20);

    text(
      j.label,
      j.x,
      y
    );

  }

}

// ==========================================
// Combo 加分文字
// ==========================================

void addBonusText(
  int lane,
  String label
) {

  bonusTexts.add(
    new BonusText(
      laneX[lane],
      judgmentY - 95,
      label
    )
  );

}

// ==========================================
// 顯示加分動畫
// ==========================================

void drawBonusTexts() {

  for (
    int i = bonusTexts.size() - 1;
    i >= 0;
    i--
  ) {

    BonusText b =
      bonusTexts.get(i);

    int elapsed =
      millis() - b.startTime;

    if (elapsed > 800) {

      bonusTexts.remove(i);

      continue;

    }

    float alpha =
      map(elapsed, 0, 800, 255, 0);

    float y =
      b.y - elapsed * 0.04;

    fill(
      255,
      220,
      80,
      alpha
    );

    textSize(17);

    text(
      b.label,
      b.x,
      y
    );

  }

}

// ==========================================
// 遊戲結束
// ==========================================

void endGame() {

  if (gameState != PLAYING) {
    return;
  }

  if (songs[songIndex].isPlaying()) {
    songs[songIndex].stop();
  }

  sendArduino("LED_OFF");

  sendArduino("BUZZER_OFF");

  gameState = RESULT;

}

// ==========================================
// 結算畫面
// ==========================================

void drawResult() {

  background(20, 24, 40);

  fill(255, 215, 70);

  textSize(36);

  text(
    "RESULT",
    width / 2,
    90
  );

  fill(255);

  textSize(24);

  text(
    songNames[songIndex],
    width / 2,
    155
  );

  textSize(22);

  text(
    "SCORE : " + score,
    width / 2,
    225
  );

  text(
    "MAX COMBO : " + maxCombo,
    width / 2,
    275
  );

  textSize(19);

  fill(255, 215, 70);

  text(
    "PERFECT : " + perfectCount,
    width / 2,
    350
  );

  fill(80, 230, 140);

  text(
    "GOOD : " + goodCount,
    width / 2,
    390
  );

  fill(255, 150, 60);

  text(
    "BAD : " + badCount,
    width / 2,
    430
  );

  fill(255, 80, 80);

  text(
    "MISS : " + missCount,
    width / 2,
    470
  );

  fill(255);

  textSize(18);

  text(
    "PRESS SELECT TO RETURN",
    width / 2,
    570
  );

}

// ==========================================
// 回到選單
// ==========================================

void returnToMenu() {

  if (songs[songIndex].isPlaying()) {
    songs[songIndex].stop();
  }

  sendArduino("LED_OFF");

  sendArduino("BUZZER_OFF");

  musicStarted = false;

  notes.clear();

  judgmentTexts.clear();

  bonusTexts.clear();

  gameState = MENU;

}

// ==========================================
// Arduino 指令傳送
// ==========================================

void sendArduino(String command) {

  if (port != null) {

    port.write(command + "\n");

  }

}

// ==========================================
// 接收 Arduino Serial 訊息
// ==========================================

void serialEvent(Serial p) {

  String message =
    p.readStringUntil('\n');

  if (message == null) {
    return;
  }

  message = trim(message);

  if (message.equals("LEFT")) {

    handleDirection(0);

  } else if (message.equals("DOWN")) {

    handleDirection(1);

  } else if (message.equals("UP")) {

    handleDirection(2);

  } else if (message.equals("RIGHT")) {

    handleDirection(3);

  } else if (message.equals("SELECT")) {

    handleSelect();

  }

}

// ==========================================
// 處理方向輸入
// ==========================================

void handleDirection(int lane) {

  if (gameState == MENU) {

    if (lane == 0) {

      songIndex--;

      if (songIndex < 0) {
        songIndex = songNames.length - 1;
      }

    } else if (lane == 3) {

      songIndex++;

      if (songIndex >= songNames.length) {
        songIndex = 0;
      }

    } else if (lane == 2) {

      difficulty++;

      if (difficulty > 2) {
        difficulty = 0;
      }

    } else if (lane == 1) {

      difficulty--;

      if (difficulty < 0) {
        difficulty = 2;
      }

    }

  } else if (gameState == PLAYING) {

    checkHit(lane);

  }

}

// ==========================================
// SELECT 按鈕
// ==========================================

void handleSelect() {

  if (gameState == MENU) {

    startGame();

  } else if (gameState == PLAYING) {

    returnToMenu();

  } else if (gameState == RESULT) {

    returnToMenu();

  }

}

// ==========================================
// 鍵盤測試
// ==========================================

void keyPressed() {

  if (keyCode == LEFT) {

    handleDirection(0);

  } else if (keyCode == DOWN) {

    handleDirection(1);

  } else if (keyCode == UP) {

    handleDirection(2);

  } else if (keyCode == RIGHT) {

    handleDirection(3);

  } else if (
    key == ' ' ||
    keyCode == ENTER
  ) {

    handleSelect();

  }

}

// ==========================================
// Note 類別
// ==========================================

class Note {

  int lane;

  float targetTime;

  boolean judged = false;

  Note(
    int lane,
    float targetTime
  ) {

    this.lane = lane;

    this.targetTime = targetTime;

  }

}

// ==========================================
// 判定文字類別
// ==========================================

class JudgmentText {

  float x;
  float y;

  String label;

  color judgmentColor;

  int startTime;

  JudgmentText(
    float x,
    float y,
    String label,
    color judgmentColor
  ) {

    this.x = x;

    this.y = y;

    this.label = label;

    this.judgmentColor = judgmentColor;

    startTime = millis();

  }

}

// ==========================================
// 加分文字類別
// ==========================================

class BonusText {

  float x;
  float y;

  String label;

  int startTime;

  BonusText(
    float x,
    float y,
    String label
  ) {

    this.x = x;

    this.y = y;

    this.label = label;

    startTime = millis();

  }

}
