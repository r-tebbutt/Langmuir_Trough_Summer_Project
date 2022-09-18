% iteratively adjusts the razor to within a tolerance of a specified tilt angle based on the 
% skew measured from images of a checkerboard

folder = 'C:\Users\rtebb\Documents\SummerProject\Automation\images\';

angle = 0;
angleRes = 0.088;  % resolution of rotary encoder/angle measurer
numImages = 10;  % number of images to be taken
tolerance = 0.005;  % tolerance around target skew allowed
targetSkew = 0;  % skew value we are aiming for
imageArray = strings(1, numImages);  % array of image names


castImgToLCD('1original.png'); % display checkerboard on LCD


calibrate(); % initialise arduino connection


targetAngle = findAngleFromSkew(targetSkew);
skew = findAverageSkew(numImages, folder) % finds initial skew
skewError = skew - targetSkew; 
disp("initial skew is: " + skew);


while(abs(skewError) > tolerance)
% repeats process until skew is within tolerance of target angle

    if(abs(skewError) < 0.1)
        % when the error gets small, we switch to moving the razor by steps
        % of the motor as this allows us to move it in smaller increments
        
        steps = (300 * skewError + 1 * sign(skewError)) + 1000; 
        disp("steps: " + (steps-1000));
        % sets the steps to move through to be linear function of the skew error 
        %(like a proportional control system), while ensuring it moves atleast 1
        % step. Modulates the serial signal by adding 1000 for arduino
        

        sendSerial(steps, arduino);
        

    else
        
        deltaAngle = abs(findAngleFromSkew(skew) - targetAngle); % finds angle difference between current and target angle
        angle = angle + deltaAngle * sign(skewError); % angle variable keeps track of current angle
        sendSerial(angle, arduino);


    end
    
    
    pause(10);
    
    
    skew = findAverageSkew(numImages, folder)

    skewError = skew - targetSkew;
    disp("Skew error is: " + skewError);
    

    if(abs(skewError) < tolerance)
        % double checks that the skew is less than the tolerance before
        % ending the program
        disp("verifying");
        skew = findAverageSkew(numImages, folder)
        skewError = skew - targetSkew;

    end
    
    pause(5); % pauses are needed else the motor stops moving (something to do with serial buffer?)
     
end

sendSerial(90, arduino); % this tells the arduino to set its current position to its zero
fclose(arduino);
close all;


function [skew_avg] = findAverageSkew(numImages, folder)
% takes a given number of photos and finds average skew
% this function just made code above a lot neater

    imageArray = strings(1, numImages);
    disp("Capturing " + string(numImages) + " images...");
    
    for i = 1:numImages
    % capture photos to find skew from
        
        imageName = strcat('skewimage', int2str(i), ".tiff");
        capture(imageName, folder);
        imageArray(i) = imageName;

    end

    
    [skew, skewArray] = findSkew(imageArray, folder);
    
    skew_avg = skew;

end


function [angle] = findAngleFromSkew(skew)
% estimates angle of razor from the current skew, this formula was found
% from plotting multiple angles against skew and fitting a curve
% It is not at all perfect, which is why we have to find the zero iteratively


    angle = sinh((skew - 0.02163)/(-0.3681))
    
end
    

   
    