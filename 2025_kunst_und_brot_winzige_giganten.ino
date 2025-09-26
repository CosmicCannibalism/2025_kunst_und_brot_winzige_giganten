// cosmiccannibalism 
// 25-07-18
// kunst- und brotmuseum ulm
// winzige giganten exibithion
//
// •reads mechanical start button
// •keypress "space" simulation
// •start movie on webapp

#include <Keyboard.h>

const int buttonPin = 6;                 // Pin where the button is connected
const unsigned long debounceDelay = 50;  // Debounce time in milliseconds
const unsigned long cooldownDelay = 2000; // Cooldown time after valid press (in ms)

bool lastButtonState = HIGH;             // Start with HIGH because of pull-up
bool buttonLocked = false;               // Cooldown lock flag

unsigned long lastDebounceTime = 0;      // Last time the button state changed
unsigned long lastActionTime = 0;        // Last time a key event was sent

void setup() {
  pinMode(buttonPin, INPUT_PULLUP);      // Enable internal pull-up resistor
  Keyboard.begin();                      // Start USB HID keyboard emulation
}

void loop() {
  int reading = digitalRead(buttonPin);
  unsigned long currentTime = millis();

  // Debounce check
  if (reading != lastButtonState) {
    lastDebounceTime = currentTime;
    lastButtonState = reading;
  }

  // Check for button press (LOW means pressed with pull-up)
  if (reading == LOW &&
      (currentTime - lastDebounceTime > debounceDelay) &&
      !buttonLocked &&
      (currentTime - lastActionTime > cooldownDelay)) {

    // Send "space" key event
    Keyboard.press(' ');
    delay(100);
    Keyboard.release(' ');

    // Activate cooldown
    buttonLocked = true;
    lastActionTime = currentTime;
  }

  // Reset cooldown lock when button is released
  if (reading == HIGH) {
    buttonLocked = false;
  }
}
