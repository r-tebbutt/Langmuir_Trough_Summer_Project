function [cr, cu, krad] = findReferenceCarrierPeaks(refImgName, folder)
% takes the file name of the reference image as a string, and returns the 
% corresponding carrier peaks and krad which is the reciprocal distance
% between carrier peaks
    
    tic

    Iref=imread(strcat(folder, refImgName)); % reads image as 2D array
    Iref = double(Iref); %[SW]
    
    
    % Get two independent carrier peaks from reference image
    [kr, ku] = findorthcarrierpks(Iref, 4*pi/min(size(Iref)), Inf); %[SW]
    
    
    % Extract carrier signals from reference image and store them for later use
    krad = sqrt(sum((kr-ku).^2))/2; %[SW]
    fIref = fft2(Iref); %[SW]
    cr = getcarrier(fIref, kr, krad); %[SW]
    cu = getcarrier(fIref, ku, krad); %[SW]
    
    toc
    
end