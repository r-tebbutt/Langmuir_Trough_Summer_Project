% script to use the images collected from 'collectSurfaceTensionData.m' to
% plot the skew and capillary length at each angle with errors, then
% extrapolate to find the capillary length corresponding to a skew of 0,
% from which our best estimate of surface tension is found


dataName = 'run4\'; % name to identify the particular set of data collected in a particular run
workingFolder = strcat('C:\Users\rtebb\Documents\SummerProject\Automation\capVSSkewData\', dataName); % folder to save all data and plots within
checkerFolder = 'C:\Users\rtebb\Documents\SummerProject\Automation\checkerboards\'; % folder containing the images of the checkerboards
refFolder = strcat(workingFolder, "ref\"); % folder to save reference images into
imgFolder = strcat(workingFolder, "images\"); % folder to save distorted images into


% define variables particular to current set up:
pxConversion = 28.4695; % this is 1000 * amount of checkerboard pixels per image pixel
numImages = 20;
filetype = ".png";

% find the average of the reference images:

refArray = dir(strcat(refFolder, "ref*")); 
refArray = {refArray.name}; % creates array of all ref image names in refFolder

disp("Averaging reference images...");


for j = 1 : length(refArray)
    
    refName = strcat(refFolder, string(refArray(j)));
    refImgData = double(imread(refName));  % reads the image data from the ref image
    
    if (j==1)
        refMatrix = refImgData;
    else
        refMatrix = cat(3, refMatrix, refImgData); % joins 2D image arrays into a 3D array
    end
    
end

refAvg = mean(refMatrix, 3); % finds the average ref image data

imwrite(uint8(refAvg), strcat(refFolder, "refAvg", filetype)); % saves averaged reference image

[cr, cu, krad] = findReferenceCarrierPeaks(strcat("refAvg", filetype), refFolder); % finds carrier peaks from reference image



% finds the capillary lengths and skew of each image:

angleArray = dir(imgFolder);
angleArray = {angleArray.name};
angleArray= angleArray(3:end); % removes unwanted elements at beginning


lcArrayByAngle = [];
skewArrayByAngle = [];
lcDeviations = [];
skewDeviations = [];
angleError = ones(1, length(angleArray)) * 0.088; % based on resolution of rotary encoder


for i = 1 : length(angleArray)
    
    angleFolder = strcat(imgFolder, angleArray(i), '\');
    
    imgArray = dir(strcat(angleFolder));
    imgArray = {imgArray.name}; % extract filenames of all images at particular angle
    imgArray = imgArray(3:end);
    
    [lc, lcArray] = findCapillaryLength(imgArray, angleFolder, cr, cu, krad, pxConversion);  % find capillary lengths from images
    [skew, skewArray] = findSkew(imgArray, angleFolder); % find skews from images
    
    lcArrayByAngle(i) = lc;
    skewArrayByAngle(i) = skew;
    lcDeviations(i) = std(lcArray); % find estimate of error in capillary length
    skewDeviations(i) = std(skewArray); % find estimate of error in skew
    
end


angleArray = str2double(strrep(angleArray, '_', '.')); % converts angle folder names back to numerical angles


% plot results and find best estimate of surface tension:

plotFolder = strcat(workingFolder, "plots\");
mkdir(plotFolder);


figure, plot1 = errorbar(angleArray, skewArrayByAngle, skewDeviations, skewDeviations, angleError, angleError, '.'); % plot skew against angle
xlabel("Angle / degrees");
ylabel("Skew");
title("Skew against angle of razor tilt from images taken at a range of angles");
saveas(plot1, strcat(plotFolder, "SkewVSAngle.fig"));
saveas(plot1, strcat(plotFolder, "SkewVSAngle.png"));


curvefit = fittype('a * asinh(x) + b', 'independent', 'x', 'dependent', 'y'); % define fit type 
[f1, gof1] = fit(angleArray.', skewArrayByAngle.', curvefit);
plotf1 = figure;
plot(f1, angleArray.', skewArrayByAngle); % plot data with fit
xlabel("Angle / degrees");
ylabel("Skew");
title("Skew against angle of razor tilt with associated fitting curve");
saveas(plotf1, strcat(plotFolder, "SkewVSAnglefit.fig"));
saveas(plotf1, strcat(plotFolder, "SkewVSAnglefit.png"));


figure, plot2 = errorbar(skewArrayByAngle, lcArrayByAngle, lcDeviations, lcDeviations, skewDeviations, skewDeviations, '.'); % plot capillary length against skew
xlabel("Skew");
ylabel("Capillary Length / mm");
title("Capillary length against skew from images taken at a range of angles");
saveas(plot2, strcat(plotFolder, "CapVSSkew.fig"));
saveas(plot2, strcat(plotFolder, "CapVSSkew.png"));


curvefit = fittype('a * sinh(x)^(2) + b', 'independent', 'x', 'dependent', 'y'); % define fit type 
[f2, gof2] = fit(skewArrayByAngle.', lcArrayByAngle.', curvefit);
plotf2 = figure;
plot(f2, skewArrayByAngle.', lcArrayByAngle.'); % plot data with fit
xlabel("Skew");
ylabel("Capillary length / mm");
title("Capillary length against skew and associated fitting curve");
legend("CapVSSkew Data", "Sinh^2 fit", 'Location', 'east')
saveas(plotf2, strcat(plotFolder, "CapVSSkewfit.fig"));
saveas(plotf2, strcat(plotFolder, "CapVSSkewfit.png"));


disp(strcat("Skew VS Angle modelled by ", num2str(f1.a), " * arsinh(x) + ", num2str(f1.b)));
disp(strcat("Capillary Length vs Skew modelled by ", num2str(f2.a), " * sinh(x)^2 + ", num2str(f2.b)));



finallc = f2.b; % final capillary length value is the y intercept of the capillary length vs skew fit

surfaceTension= finallc^2 * 1e-6 * (997.5-1.2) * 9.806;  % surface tension found from capillary length, (density diff and gravity)
disp('The surface tension of the fluid is ' + string(surfaceTension) + ' N/m');


 
