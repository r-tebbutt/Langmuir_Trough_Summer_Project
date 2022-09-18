% script which runs for an hour, taking images at certain time intervals
% and finding the capillary length as time progresses, with razor held at
% one angle

folder = 'C:\Users\rtebb\Documents\SummerProject\Automation\overTimeData\';
checkerfold = 'C:\Users\rtebb\Documents\SummerProject\Automation\checkerboards\';
mkdir(folder);


angle = 5;  % angle of razor tilt
numImages = 20;
pxConversion = 28.4695;  % this is 1000 * amount of checkerboard pixels per image pixel

calibrate();

delete(strcat(folder, 'refimage.png'));

castImgToLCD("1original.png");
pause(3);

capture('refimage.png', folder);
disp("Capturing reference image");
pause(5);


lcOverTime = [];
lcDeviations = [];
timerVal = [];
totalTime = 0;
counter = 1;


sendSerial(angle, arduino);  % sends the angle through the serial port to Arduino
pause(20);  % pauses to allow time for angle to change and water to settle


while(totalTime < 3600)
    
timeStart = tic;

for i = 1:numImages
%take pictures and saves them to folder

    capture(strcat("image", int2str(i), ".png"), folder);  % captures and saves image
    disp("Capturing");
    
end


[cr,cu,krad] = findReferenceCarrierPeaks("refimage.png", folder);


names = dir(strcat(folder, 'image*'));
names = {names.name}; % Get data images
names = string(names);
 

[lc, lcArray] = findCapillaryLength(names, folder, cr, cu, krad, pxConversion);
stdev = std(lcArray);


lcOverTime(counter) = lc;
lcDeviations(counter) = stdev;
timeStop = toc(timeStart);
timerVal(counter) = timeStop;
totalTime = totalTime + timeStop;

counter = counter + 1;

end



temp = timerVal;
for i = 2:length(timerVal)
    % calculates array of time at which each set of photos was taken
    timerVal(i) = timerVal(i) + timerVal(i-1);
end


errorbar(timerVal, lcOverTime, lcDeviations, lcDeviations, 'o');
xlabel("time / s");
ylabel("capillary length / mm");

savefig(strcat(folder, "overTimePlotAngle5Run1"));
