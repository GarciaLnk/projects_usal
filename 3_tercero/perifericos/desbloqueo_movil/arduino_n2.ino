#include <Adafruit_NeoPixel.h>
#include <Servo.h>

byte sendCode, readCode;

const int echoPin = 4;
const int triggerPin = 5;
const int LEDPin = 3;
const int servoPin = 2;
const int vibrarPin = 9;
const int tempPin = A1;
const int gasPin = A0;

int pos = 0;
bool camaraAbierta = false;
bool bloqueado = true;
char tmp[3];
int lectTemp, lectGas;
float temperaturaC;

Servo motorCamara;
Adafruit_NeoPixel strip = Adafruit_NeoPixel(4, LEDPin, NEO_GRB + NEO_KHZ800);

void setup()
{
  Serial.begin(9600);
  strip.begin();
  motorCamara.attach(servoPin);
  
  pinMode(0, OUTPUT);
  pinMode(1, INPUT);
  pinMode(triggerPin, OUTPUT);
  pinMode(echoPin, INPUT);
  pinMode(vibrarPin, OUTPUT);
}

void loop()
{
  if(Serial.available() > 0) {
    readCode = Serial.read();
    
    if(readCode == '1'){
      bloqueado = false;
      
      for(int i=0; i<4; i++){
        strip.setPixelColor(i, strip.Color(0, 255, 0));
        strip.show();
      }
      
      digitalWrite(vibrarPin, HIGH);
      delay(1000);
      digitalWrite(vibrarPin, LOW);
      
      for(int i=0; i<4; i++){
        strip.setPixelColor(i, strip.Color(0, 0, 0));
        strip.show();
      }      
    } else if(readCode == '2'){
      bloqueado = true;
      
      for(int i=0; i<4; i++){
        strip.setPixelColor(i, strip.Color(255, 0, 0));
        strip.show();
      }
      
      delay(1000);
      
      for(int i=0; i<4; i++){
        strip.setPixelColor(i, strip.Color(0, 0, 0));
        strip.show();
      }      
    } else if(readCode == '3'){
      bloqueado = true;
      
      for(int i=0; i<4; i++){
        strip.setPixelColor(i, strip.Color(0, 0, 255));
        strip.show();
      }
      
      delay(1000);
      
      for(int i=0; i<4; i++){
        strip.setPixelColor(i, strip.Color(0, 0, 0));
        strip.show();
      }      
    } else if(readCode == '4'){
      lectTemp = analogRead(tempPin);
      temperaturaC = ((lectTemp*5.0)/1024-0.5)*100;
      itoa((int) temperaturaC, tmp, 10);
      for(int i=0; i<3; i++)
        if(tmp[i]==NULL)
          tmp[i]=' ';
      Serial.write(tmp, 3);
    } else if(readCode == '5'){
      lectGas = analogRead(gasPin);
      lectGas = map(lectGas, 300, 750, 0, 100);
      if(lectGas < 30) {
        sendCode = 1;
      } else if(lectGas > 30 && lectGas < 50) {
        sendCode = 2;
      } else if(lectGas > 50 && lectGas < 80) {
        sendCode = 3;
      } else if(lectGas > 80) {
        sendCode = 4;
      }
      Serial.print(sendCode);
    }
  }
  
  int cm = ping(triggerPin, echoPin);
  if(!camaraAbierta && cm<50 && bloqueado) {
    for (pos = 0; pos <=90; pos++) {
      motorCamara.write(pos);
      delay(10);
    }
    camaraAbierta = true;
  } else if(camaraAbierta && (cm>50 || !bloqueado)) {
    for (pos = 90; pos >=0; pos--) {
      motorCamara.write(pos);
      delay(10);
    }
    camaraAbierta = false;
  }
  
  delay(100);
}

int ping(int triggerPin, int echoPin){
  long duration, distanceCm;
  digitalWrite(triggerPin, LOW);
  delayMicroseconds(4);
  digitalWrite(triggerPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(triggerPin,LOW);

  duration = pulseIn(echoPin,HIGH);

  distanceCm = duration*10/292/2;
  return distanceCm;
}
