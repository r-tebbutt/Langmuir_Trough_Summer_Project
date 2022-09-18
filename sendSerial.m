function [] = sendSerial(message, arduino)
% sends a message through the serial port to the arduino as a float

fprintf(arduino,'%f', message);


end