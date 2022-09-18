function [] = capture(filename, folder)
% takes an image with parameters set by 'cameraSettings.m', saves it to
% folder as filename

[vid, src] = cameraSettings();

vid.FramesPerTrigger = 1;  % sets camera to take a single photo


start(vid);

imwrite(getdata(vid), strcat(folder, filename)); % saves image

stop(vid);

end