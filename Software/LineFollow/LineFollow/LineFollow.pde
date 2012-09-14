/*
  Blink
  Turns on an LED on for one second, then off for one second, repeatedly.
 
  This example code is in the public domain.
 */
 
#include <Servo.h>

#define STEER 4
#define LED 13

#define THRESH 60
#define Delta_S 40
#define SCENTER 1500
#define SMIN 1050
#define SMAX 1950

Servo steer;
int s;

void setup() {                
  // initialize the digital pin as an output.
  // Pin 13 has an LED connected on most Arduino boards:
  pinMode(LED, OUTPUT);   

  Serial.begin(9600);
  Serial.println("Hello");

  motorInit();
  
  steer.attach(STEER);
  s = SCENTER;
  motorSpeed(35);
  
}

void loop() {
  int lsense, rsense;

  rsense = analogRead(0);
  lsense = analogRead(2);

  if ( lsense > THRESH && rsense > THRESH ) {
  } else if ( lsense > THRESH) {
    digitalWrite(LED, HIGH);   // set the LED on
    if ( s > SMIN) s -= Delta_S;
  } else if ( rsense > THRESH) {
    digitalWrite(LED, HIGH);   // set the LED on
    if (s < SMAX) s += Delta_S;
  } else {
    digitalWrite(LED, LOW);    // set the LED off
    if ( s < SCENTER) s += Delta_S;
    if ( s > SCENTER) s -= Delta_S;
  }
  
  steer.write(s);
  delay(20);

  Serial.print(lsense);
  Serial.print(" ");
  Serial.print(rsense);
  Serial.println();
  
}
