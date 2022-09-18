% script which captures references images, and then increments the tilt of
% the razor blade to capture images at a range of angles

% USAGE: check camera preview first and adjust camera settings accordingly.
% run setZeroSkew beforehand to ensure references are of a flat
% checkerboard. Run 'plotSurfaceTensionData.m' after to analyse data.

% define folders to save particular data into
dataName = 'run9tiff\'; % name to identify the particular set of data collected in a particular run
workingFolder = strcat('C:\Users\rtebb\Documents\SummerProject\Automation\capVSSkewData\', dataName); % folder to save all data and plots within
checkerFolder = 'C:\Users\rtebb\Documents\SummerProject\Automation\checkerboards\'; % folder containing the images of the checkerboards
refFolder = strcat(workingFolder, "ref\"); % folder to save reference images into
imgFolder = strcat(workingFolder, "images\"); % folder to save distorted images into

mkdir(refFolder);
mkdir(imgFolder);


% define variables particular to data you want to collect
minAngle = 0.4; % starting angle for razor blade
maxAngle = 5; % maximum angle the razor will tilt to
deltaAngle = 0.2; % increment in razor tilt angle between image capturing
numImages = 20; % number of images to take at each angle, to average over
checkerboardToUse = "1original.png"; % filename of checkerboard to use in this run
filetype = ".tiff";



% capture reference images:

castImgToLCD(checkerboardToUse); % displays checkerboard on LCD screen
pause(3);
disp(strcat("Capturing ", int2str(numImages), " reference images"));

for i = 1 : numImages
    
    refName = strcat("refimage", int2str(i), filetype);
    delete(strcat(refFolder, refName)); % deletes existing image of same name
    
    capture(refName, refFolder); % takes the image and saves it
    
end



calibrate(); % initialises connection with arduino and sets its zero
angle = minAngle; % angle variable keeps track of the current razor angle; initially it is minAngle


% capture images at range of angles:

while (angle < maxAngle)
    
    sendSerial(angle, arduino); % tilts razor to current angle
    pause(10); % allow razor to move and vibrations to settle
    disp(strcat("Current angle is ", num2str(angle)));
    
    angleName = strrep(num2str(angle), '.', '_'); % replaces decimal point in angle with underscore for saving, e.g. '4.2' becomes '4_2'
    angleFolder = strcat(imgFolder, angleName, '\'); % folder to save images from each angle in
    mkdir(angleFolder);
    
    disp(strcat("Capturing ", int2str(numImages), " images at angle ", num2str(angle)));
    
    
    for i = 1 : numImages
        
        imgName = strcat("image", int2str(i), filetype);
        capture(imgName, angleFolder);
        
    end
    
    angle = angle + deltaAngle; % increments angle
    
end

fclose(arduino);
    
