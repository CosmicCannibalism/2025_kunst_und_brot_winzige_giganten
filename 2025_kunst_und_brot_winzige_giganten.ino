// cosmiccannibalism 
// 25-07-18
// kunst- und brotmuseum ulm
// winzige giganten exibithion
//
// •reads mechanical start button
// •sets variable isPlaying via serial or button
// •relay opens when isPlaying == true

const int buttonPin = 6;                 // Pin where the button is connected
const unsigned long debounceDelay = 50;  // Debounce time in milliseconds
const unsigned long cooldownDelay = 200; // Cooldown time after valid press (in ms)

bool lastButtonState = 1;             // Start with HIGH because of pull-up
bool buttonLocked = false;               // Cooldown lock flag
bool isPlaying = false;                  // Variable to control playback state

unsigned long lastDebounceTime = 0;      // Last time the button state changed
unsigned long lastActionTime = 0;        // Last time an action was triggered

const int relayPin = 7;                   // Pin where the relay is connected

void setup() {
  pinMode(buttonPin, INPUT_PULLUP);       // Enable internal pull-up resistor
  pinMode(relayPin, OUTPUT);
  Serial.begin(9600);                     // Start serial communication
  Serial.println("Type 'false' or '0' to stop playback.");
}

void loop() {
  int reading = digitalRead(buttonPin);
  unsigned long currentTime = millis();

  // --- Read Serial Input to set isPlaying to false ---
  if (Serial.available() > 0) {
    String command = Serial.readStringUntil('\n');
    command.trim(); // remove spaces/newline

    if (command.equalsIgnoreCase("false") || command.equals("0")) {
      isPlaying = false;
      Serial.println("isPlaying set to false");
    }
    if (command.equalsIgnoreCase("true") || command.equals("1")) {
      isPlaying = true;
      Serial.println("isPlaying set to true");
    }
  }

  // --- Debounce check for the button ---
  if (reading != lastButtonState) {  
    lastDebounceTime = currentTime;
    lastButtonState = reading;
  }

  // --- Button press sets isPlaying to true ---
  if (reading == LOW &&
      (currentTime - lastDebounceTime > debounceDelay) &&
      !buttonLocked &&
      (currentTime - lastActionTime > cooldownDelay)) {

    isPlaying = true;
    Serial.println("isPlaying set to true by button");

    buttonLocked = true;
    lastActionTime = currentTime;
  }

  // Reset cooldown lock when button is released
  if (reading == HIGH) {
    buttonLocked = false;
  }

  // --- Control relay based on isPlaying state ---
  if (isPlaying) {
    digitalWrite(relayPin, HIGH);  // Relay ON
  } else {
    digitalWrite(relayPin, LOW);   // Relay OFF
  }
}
