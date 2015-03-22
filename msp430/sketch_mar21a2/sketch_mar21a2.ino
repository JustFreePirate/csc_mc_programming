volatile unsigned long previousMillis = 0;
volatile unsigned long previousMillisBlink = 0;
volatile int on_off = 0;
volatile int state = 0;
volatile int blink_state = 0;
const int STATE_PAUSE = 1000;
const int BLINK_PAUSE = 100;
const int RED = 2;
const int YELLOW = 3;
const int GREEN = 4;
const int BUTTON = PUSH2;

void setup()
{
  // put your setup code here, to run once:
  pinMode(RED, OUTPUT);
  pinMode(YELLOW, OUTPUT);
  pinMode(GREEN, OUTPUT);
  pinMode(BUTTON, INPUT_PULLUP);
  attachInterrupt(BUTTON, change, FALLING);
}

void loop()
{
  // put your main code here, to run repeatedly:
  unsigned long currentMillis = millis();
  if (on_off) { //если работает
    if ((currentMillis - previousMillis) > STATE_PAUSE) {
      previousMillis = currentMillis;
      state = (state + 1) % 4;
    }
    if (state == 0) { // red
      digitalWrite(RED, HIGH);
      digitalWrite(YELLOW,LOW);
      digitalWrite(GREEN,LOW);
    } else if (state == 1) { //red+yellow
      digitalWrite(RED, HIGH);
      digitalWrite(YELLOW, HIGH);
      digitalWrite(GREEN, LOW);
    } else if (state == 2) { //green
      digitalWrite(RED, LOW);
      digitalWrite(YELLOW, LOW);
      digitalWrite(GREEN, HIGH);
    } else { //blink green
      if ((currentMillis - previousMillisBlink) > BLINK_PAUSE) {
        previousMillisBlink = currentMillis;
        blink_state = !blink_state;
        digitalWrite(GREEN, blink_state);
      }
    }
  } else { //если не работает
    if ((currentMillis - previousMillis) > BLINK_PAUSE) {
      previousMillis = currentMillis;
      blink_state = !blink_state;
      digitalWrite(YELLOW, blink_state);
    }   
  }
  
}

void change() {
  on_off = !on_off; //меняем режим на работающий/сломанный
  previousMillis = millis(); //сбрасываем таймер
  previousMillisBlink = 0; //сбрасываем таймер мигания
  state = 0;
  blink_state = 0;
  digitalWrite(RED, LOW);
  digitalWrite(YELLOW, LOW);
  digitalWrite(GREEN, LOW);
}
