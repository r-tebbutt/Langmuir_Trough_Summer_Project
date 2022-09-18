function [vid, src] = cameraSettings()

vid = videoinput('pointgrey', 1, 'F7_Raw8_1920x1200_Mode0');
src = getselectedsource(vid);

vid.ROIPosition = [885 190 632 900];
% [x_offset y_offset width height]

src.Exposure = 2;
%Max Exposure = 2.41;

src.Brightness = 12;
%Max Brightness = 12.48;

src.Shutter = 6;
%Max Shutter = 6.07;

src.Gain = 15;
%Max Gain = 30.00

end