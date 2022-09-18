% script to display a preview of the images that will be taken, with
% parameters set in 'cameraSettings.m'

[vid, src] = cameraSettings();

castImgToLCD('1original.png');

preview(vid);

start(vid);

