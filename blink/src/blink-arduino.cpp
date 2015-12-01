#include "Arduino.h"
#include "util/delay.h"
 
int led=13;
 
int main (void)
{
  init();
 
  // initialize the digital pin as an output.
  pinMode(led, OUTPUT);  
  Serial.begin(9600);
  Serial.println("hello world");

  int i = 0;
  while(1) {
    Serial.println(i++);
    digitalWrite(led, HIGH);   // turn the LED on (HIGH is the voltage level)
    delay(1000);               // wait for a second
    //_delay_ms(100);               // wait for a second
    digitalWrite(led, LOW);    // turn the LED off by making the voltage LOW
    delay(1000);               // wait for a second
    //_delay_ms(100);               // wait for a second
  }
 
 return 0;
}
