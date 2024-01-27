#include <EEPROM.h>
#include <Keypad.h>
#include <LiquidCrystal.h>

const byte rowsCount = 4;
const byte columsCount = 4;

const int buzzerPin = 12;
const int botonPin = 13;
const int ldrPin = A3;
const int pirPin = A2;

char keys[rowsCount][columsCount] = {
    { '1', '2', '3', 'A' },
    { '4', '5', '6', 'B' },
    { '7', '8', '9', 'C' },
    { '#', '0', '*', 'D' }
};

byte rowPins[rowsCount] = { A0, A1, 11, 10 };
byte columnPins[columsCount] = { 9, 8, 7, 6 };

LiquidCrystal lcd(5, 4, 3, 2, A4, A5);
Keypad keypad = Keypad(makeKeymap(keys), rowPins, columnPins, rowsCount, columsCount);

char password[4] = { '1', '2', '3', '4' };
char key;
byte sendCode, readCode;
bool bloqueado = true;
int luz, estadoBoton = 0, estadoPir = 0, estadoPirInicial = 0, j;
char tmp[3];
unsigned long tiempoInicial, timeout;

String opcion1 = "1) Cambiar PIN";
String opcion2 = "2) Temperatura";
String opcion3 = "3) Estado aire";
String opcion4 = "4) Bloquear";

void setup()
{
    int num1, num2, num3, num4;

    Serial.begin(9600);
    lcd.begin(16, 2);

    num1 = EEPROM.read(0);
    num2 = EEPROM.read(1);
    num3 = EEPROM.read(2);
    num4 = EEPROM.read(3);

    if (num1 == 0 && num2 == 0 && num3 == 0 && num4 == 0) {
        EEPROM.write(0, (int)password[0]);
        EEPROM.write(1, (int)password[1]);
        EEPROM.write(2, (int)password[2]);
        EEPROM.write(3, (int)password[3]);
    }

    pinMode(0, OUTPUT);
    pinMode(1, INPUT);
    pinMode(buzzerPin, OUTPUT);
    pinMode(botonPin, INPUT);
    pinMode(ldrPin, INPUT);
    pinMode(pirPin, INPUT);
}

void loop()
{
    comprobarPIN();

    while (!bloqueado)
        menu();

    delay(100);
}

void cambiarPIN()
{
    int i = 0;

    lcd.clear();
    lcd.print("Nuevo PIN:");
    lcd.setCursor(0, 1);
    lcd.print("> ");

    while (i < 4) {
        key = keypad.getKey();
        keyTone(key);
        if (key == '*' || key == '#') {
            if (i > 0) {
                lcd.setCursor(1 + i, 1);
                lcd.print(" ");
                lcd.setCursor(1 + i, 1);
                i--;
            }
        } else if (key) {
            password[i] = key;
            lcd.print(key);
            i++;
        }
        delay(100);
    }

    lcd.clear();
    lcd.print("PIN cambiado");

    EEPROM.write(0, (int)password[0]);
    EEPROM.write(1, (int)password[1]);
    EEPROM.write(2, (int)password[2]);
    EEPROM.write(3, (int)password[3]);
}

void comprobarPIN()
{
    int i = 0, correcto = 0;
    char keyAnterior[4];

    lcd.clear();
    lcd.print("Introducir PIN:");
    lcd.setCursor(0, 1);
    lcd.print("> ");

    while (i < 4) {
        key = keypad.getKey();
        keyTone(key);
        if (key == '*' || key == '#') {
            if (i > 0) {
                lcd.setCursor(1 + i, 1);
                lcd.print(" ");
                lcd.setCursor(1 + i, 1);
                i--;
                if (password[i] == keyAnterior[i])
                    correcto--;
            }
        } else if (key == password[i]) {
            keyAnterior[i] = key;
            correcto++;
            i++;
            lcd.print(key);
        } else if (key) {
            keyAnterior[i] = key;
            i++;
            lcd.print(key);
        }
        delay(100);
    }

    lcd.clear();
    if (correcto == 4) {
        sendCode = 1;
        Serial.print(sendCode);
        bloqueado = false;
    } else {
        sendCode = 2;
        Serial.print(sendCode);
        bloqueado = true;
    }

    delay(100);
}

void menu()
{
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(opcion1);
    lcd.setCursor(0, 1);
    lcd.print(opcion2);
    delay(1000);
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(opcion2);
    lcd.setCursor(0, 1);
    lcd.print(opcion3);
    delay(1000);
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(opcion3);
    lcd.setCursor(0, 1);
    lcd.print(opcion4);
    delay(1000);

    lcd.clear();
    lcd.print("Opcion: ");
    lcd.setCursor(0, 1);
    lcd.print("> ");

    tiempoInicial = millis();
    while (1) {
        key = keypad.getKey();
        keyTone(key);
        if (key == '1' || key == '2' || key == '3' || key == '4') {
            lcd.print(key);
            break;
        } else if (key) {
            lcd.clear();
            lcd.print(key);
            lcd.setCursor(0, 1);
            lcd.print("Opcion invalida");
            break;
        }

        estadoPir = digitalRead(pirPin);
        if (estadoPir == HIGH) {
            if (estadoPirInicial == LOW) {
                tiempoInicial = millis();
                estadoPirInicial = HIGH;
            }
        } else {
            if (estadoPirInicial == HIGH) {
                estadoPirInicial = LOW;
            }
        }

        estadoBoton = digitalRead(botonPin);
        timeout = millis() - tiempoInicial;
        if (estadoBoton == HIGH || timeout > 15000) {
            sendCode = 3;
            Serial.print(sendCode);
            bloqueado = true;
            break;
        }

        delay(100);
    }

    switch (key) {
    case '1':
        lcd.clear();
        lcd.print("Cambiar PIN...");
        delay(100);
        cambiarPIN();
        break;
    case '2':
        sendCode = 4;
        Serial.print(sendCode);
        lcd.clear();
        lcd.print("Temperatura:");
        lcd.setCursor(0, 1);
        delay(100);
        j = 0;
        while (Serial.available() && j < 3) {
            tmp[j++] = Serial.read();
        }
        lcd.print(tmp[0]);
        lcd.print(tmp[1]);
        lcd.print(tmp[2]);
        lcd.print("C");
        delay(1000);
        break;
    case '3':
        sendCode = 5;
        Serial.print(sendCode);
        lcd.clear();
        lcd.print("Estado del aire:");
        lcd.setCursor(0, 1);
        delay(100);
        while (Serial.available()) {
            readCode = Serial.read();
        }
        if (readCode == '1') {
            lcd.print("Aire limpio");
        } else if (readCode == '2') {
            lcd.print("Polucion baja");
        } else if (readCode == '3') {
            lcd.print("Polucion media");
        } else if (readCode == '4') {
            lcd.print("Polucion alta");
        }
        delay(1000);
        break;
    case '4':
        sendCode = 3;
        Serial.print(sendCode);
        bloqueado = true;
        break;
    }

    delay(100);
}

void keyTone(char k)
{
    luz = analogRead(ldrPin);
    if (k && luz > 80) {
        switch (k) {
        case '1':
            tone(buzzerPin, 953, 100);
            break;
        case '2':
            tone(buzzerPin, 1017, 100);
            break;
        case '3':
            tone(buzzerPin, 1072, 100);
            break;
        case '4':
            tone(buzzerPin, 990, 100);
            break;
        case '5':
            tone(buzzerPin, 1053, 100);
            break;
        case '6':
            tone(buzzerPin, 1109, 100);
            break;
        case '7':
            tone(buzzerPin, 1031, 100);
            break;
        case '8':
            tone(buzzerPin, 1094, 100);
            break;
        case '9':
            tone(buzzerPin, 1150, 100);
            break;
        case '*':
            tone(buzzerPin, 1075, 100);
            break;
        case '0':
            tone(buzzerPin, 1139, 100);
            break;
        case '#':
            tone(buzzerPin, 1194, 100);
            break;
        case 'A':
            tone(buzzerPin, 1165, 100);
            break;
        case 'B':
            tone(buzzerPin, 1202, 100);
            break;
        case 'C':
            tone(buzzerPin, 1243, 100);
            break;
        case 'D':
            tone(buzzerPin, 1287, 100);
            break;
        }
    }
}
