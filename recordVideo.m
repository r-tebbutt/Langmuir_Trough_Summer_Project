% script which displays a checkerboard on the LCD, records a video with set
% parameters, and then saves the video and individual video frames


name = "1Board1AverageHighFPS4px3"; % name assigned to this data run
workingFolder = strcat('C:\Users\rtebb\Documents\SummerProject\Automation\imageNoiseTest\referenceAverageTest\', name, '\');
mkdir(workingFolder);

frameFolder = strcat(workingFolder,'videoFrames\video', name,'\'); % folder to save individual video frames into
mkdir(frameFolder);

vidFolder = strcat(workingFolder, 'videos\video', name, '\'); % folder to save video into
mkdir(vidFolder);


% set parameters
duration = 0.5;
frameRate = 160;
totalFrames = duration * frameRate;

[vid, src] = cameraSettings();
vid.FramesPerTrigger = totalFrames; % sets how many frames to capture


castImgToLCD("1original.png"); % display checkerboard
pause(3);



% records video and saves:

vid.LoggingMode = 'disk'; % sets video to save to disk

diskLogger = VideoWriter(strcat(vidFolder, name, ".avi"), 'Grayscale AVI'); % sets save location and filetype
diskLogger.FrameRate = frameRate; % sets framrate of video
vid.DiskLogger = diskLogger;


disp("Recording video");
start(vid); % records video
pause(5);



% reads video and saves indiviual frames as images:

obj = VideoReader(strcat(vidFolder,name, ".avi")); % sets video to read
vid = read(obj);
  
% read the total number of frames
frames = obj.numFrames;
  
% file format of the frames to be saved in
ST ='.png';
disp("converting video to individual frames");


% reading and writing the frames 
for x = 1 : frames
  
    % converting integer to string
    Sx = num2str(x);
  
    % concatenating 2 strings
    Strc = strcat(frameFolder ,Sx, ST);
    Vid = vid(:, :, :, x);
    
  
    % exporting the frames
    imwrite(Vid, Strc);
     
end