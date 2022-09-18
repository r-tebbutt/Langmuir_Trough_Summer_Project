function [lc_avg, lcArray] = findCapillaryLength(imgArray, folder, cr, cu, krad, pxConversion)
% Takes an array of string filenames of the images to analyse, and a string of the folder they are stored in
% Carrier objects and krad are found from running 'findReferenceCarrierPeaks'
% on a reference image.
% Returns the calculated capillary lengths and average capillary length
    
    num = length(imgArray);
    lcArray = zeros(1, num);  % array to store measured capillary lengths
    pxGrd = 2; % amount of LCD pixels per checker on checkerboard, in each dimension
    
    pxmm = pxConversion/ (pxGrd * krad)  % actual checkerBoard pixel to mm conversion
    
    
    initialCoeffs = [0.0001,0,0.37,0,0,0]; % initial start point for fitting
    
    
    for i = 1:num
    
        imgName = imgArray(i);

        tic

        % first-order solution
        surfexp = fittype('cos(p4)*cos(p3)*(A*exp(((p1*x)+(p2*y))))+sin(p3)*y+sin(p4)*x+C', ...
                            'independent',{'x','y'}, ...
                            'dependent','h');

        
        % reads the image data
        Idef=imread(strcat(folder,imgName));


        % convert images to double to prevent rounding errors    
        Idef = double(Idef); %[SW]


        % get displacement field and height profile
        fIdef = fft2(Idef); %[SW]
        [u,v] = fcd_dispfield(fIdef,cr,cu,true); %[SW]  % The phase wrap is important
        
        u = u/pxmm;
        v = v/pxmm;    
        
        % integrates the gradient to find the height (inverse gradient)
        h = invgrad2(-u,-v)/(pxmm*5.45); % the '5.45' is some value related to the optical thickness of the device, found by Harry.
        % h = intgrad2(-u,-v,1/pxmm,1/pxmm)/5.45; %SLOWER


        % Rearange the data for the reqirements of fit()
        ys = linspace(1,length(h(:,1)),length(h(:,1)))/pxmm;
        xs = linspace(1,length(h(1,:)),length(h(1,:)))/pxmm;    
        xss = reshape(repmat(xs,length(ys),1),1,[]).';
        yss = repmat(ys(:),length(xs),1);

        % Use one edge to reduce the z offset
        h = h - mean(h(1:end,1));
        hss = reshape(h,1,[]).';


        % Perform the surface fitting     
        [surffit,gof] = fit([xss,yss],hss,surfexp','Lower',[0,-25,0.2,-0.1,-2,-1.5],'StartPoint', initialCoeffs,'Upper',[2,10,0.8,0.1,3.0,1])
        initialCoeffs = coeffvalues(surffit); % updates the starting point for the next run - this speeds up the fitting process
        fittedCoeffs = initialCoeffs; %
        conLim = confint(surffit);

        
        % extracts the coefficients from the fitted curve
        A = fittedCoeffs(1);
        l1 = fittedCoeffs(3);
        l2 = fittedCoeffs(4);
        lc = 1/(l1^2+l2^2)^(1/2)
        errorlc =lc* (abs(conLim(1,3)-l1))/l1;

        toc
        
        lcArray(i) = lc;

    end

    lc_avg = mean(lcArray, 'all');

end