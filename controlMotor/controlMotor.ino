/* */

// Include the AccelStepper library:
//[HM]
#include <AccelStepper.h>
#include <Wire.h>
#include <AS5600.h>

#ifdef ARDUINO_SAMD_VARIANT_COMPLIANCE
  #define Serial SerialUSB
  #define SYS_VOL   3.3
#else
  #define Serial Serial
  #define SYS_VOL   5
#endif

// Define stepper motor connections and motor interface type. Motor interface type must be set to 1 when using a driver:
#define dirPin 2
#define stepPin 3
#define enablePin 4
#define motorInterfaceType 1


// Create a new instance of the AccelStepper class:
AccelStepper stepper = AccelStepper(motorInterfaceType, stepPin, dirPin);
AMS_5600 ams5600;
//[HM]


float zero = 0;
float desired = 0; // Default needs to change to the perpendicular position not yet measured
int motorSpeed;
float steps;
int stepDirection;
float delta;
float maxAngle = 30;
float minAngle = -10;
float anglePres = 0.088;


float angle;
float prevAngle;

float convertRawAngleToDegrees(word newAngle)
{
  /* Raw data reports 0 - 4095 segments, which is 0.087 of a degree */
  float retVal = newAngle * 0.087;
  return retVal;
}


void setup() {
  //[HM]
  Serial.begin(9600); // Start Serial Monitor at Board Rate 9600
  
  Serial.println("Setup Initiated");
  
  stepper.setEnablePin(enablePin);
  stepper.setPinsInverted(false, false, true);

  stepper.enableOutputs();        //Enables Motor Pin Outputs
  stepper.setMaxSpeed(1000);
  stepper.setAcceleration(5000);
  stepper.disableOutputs();
 
  Wire.begin();
  

    while(1){
        if(ams5600.detectMagnet() == 1 ){
            calibrate();
            Serial.print("Current Magnitude: ");
            Serial.println(ams5600.getMagnitude());
            break;
        }
        else{
            Serial.println("Can not detect magnet");
        }
        delay(1000);
    }
  
  ams5600.setStartPosition(minAngle);
  ams5600.setEndPosition(maxAngle);  
  Serial.println("Setup Complete");
  //[HM]
} 


void calibrate() {
  // sets current position to be the zero position
  
  zero = convertRawAngleToDegrees(ams5600.getRawAngle());
  
}


void loop() {
  
  if (Serial.available() > 0){

    float desireduncheck = Serial.parseFloat(SKIP_ALL);
    
    if (desireduncheck == 90){
      // matlab sending 90 is the signal to calibrate/set the zero of the rotary encoder
      
      calibrate();
      
    }


    if (desireduncheck > 91){
      // this case runs if matlab finds the skew to be very small
      
      steps = desireduncheck - 1000; // step value is modulated for data transfer by adding 1000, this just demodulates it
      stepper.enableOutputs();
      stepper.move(int(steps));
      stepper.runToPosition();
      stepper.disableOutputs();
      
    }
    
    else if (desireduncheck < maxAngle && desireduncheck > minAngle){
      
      desired = desireduncheck;
      Serial.println("New angle: "+String( desired,DEC));
      
      angle = convertRawAngleToDegrees(ams5600.getRawAngle())-zero;
      delta = angle - desired;
      stepDirection = int(delta/abs(delta));
      
      stepper.enableOutputs();
                
      motorSpeed = 50 * delta * -1; // speed is set dependent on angle to move through
        
      stepper.setSpeed(motorSpeed);
      
      while(abs(angle - desired) > anglePres){ 
        // rotates razor until angle is within the minimum resolution of the desired angle
             
        stepper.runSpeed();
        angle = convertRawAngleToDegrees(ams5600.getRawAngle())-zero;
        
      }
          
      stepper.disableOutputs();
           
      }
    
    else{Serial.println("Out of range");} 
  
  }
}
