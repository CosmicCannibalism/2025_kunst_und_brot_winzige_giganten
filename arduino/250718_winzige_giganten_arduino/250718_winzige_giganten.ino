// cosmiccannibalism 
// 25-07-18
// kunst- und brotmuseum ulm
// winzige giganten exibithion
//
// •reads mechanical start button
// •keypress "space" simulation
// •start movie on webapp
#include <Keyboard.h>

const int buttonPin = 7;                 // Pin where the button is connected
const unsigned long debounceDelay = 50;  // Debounce time in milliseconds
const unsigned long cooldownDelay = 2000; // Cooldown time after valid press (in ms)

bool lastButtonState = LOW;              // Previous stable state of the button
bool buttonLocked = false;               // Cooldown lock flag

unsigned long lastDebounceTime = 0;      // Last time the button state changed
unsigned long lastActionTime = 0;        // Last time a key event was sent

void setup() {
  pinMode(buttonPin, INPUT);             // Use external pull-down resistor
  Keyboard.begin();                      // Start USB HID keyboard emulation
}

void loop() {
  int reading = digitalRead(buttonPin);
  unsigned long currentTime = millis();

  // Debounce check: if the reading changed, reset debounce timer
  if (reading != lastButtonState) {
    lastDebounceTime = currentTime;
    lastButtonState = reading;
  }

  // If the button is pressed AND debounce delay passed AND not locked
  if (reading == HIGH &&
      (currentTime - lastDebounceTime > debounceDelay) &&
      !buttonLocked &&
      (currentTime - lastActionTime > cooldownDelay)) {

    // Send "space" key event
    Keyboard.press(' ');
    delay(100); // simulate a short keypress
    Keyboard.release(' ');

    // Activate cooldown
    buttonLocked = true;
    lastActionTime = currentTime;
  }

  // Reset cooldown lock when button is released
  if (reading == LOW) {
    buttonLocked = false;
  }
}
