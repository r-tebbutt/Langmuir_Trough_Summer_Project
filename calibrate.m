% script which deletes an existing connection to arduino, then opens a new
% one as specified, then zeros the current position of the razor blade

delete(instrfind({'Port'},{'COM3'}));

arduino=serial('COM3','BaudRate',9600); % create serial communication object on port COM3 

fopen(arduino); % initiate arduino communication

pause(3)

fprintf(arduino,'%f', 90);  % 90 is the signal to tell the arduino that we want to zero/calibrate the setup

