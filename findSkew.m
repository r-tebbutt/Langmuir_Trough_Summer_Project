function [skew, skewArray] = findSkew(imgArray, folder)
% takes array of image file names as strings for input, and a string of the folder the images are stored in, and returns the average
% skew of the images and the array of skews
    
    num = length(imgArray);
    
    skewArray = zeros(1, length(num));

        for i = 1:num

            surfjons = fittype('A*exp(-0.5*(w1+asinh((x-t1)/s1)).^2).*exp(-(y-t2).^2/(2*s2^2))./(2*3.1415*s2*s1)+z1','independent',{'x','y'},'dependent','h');
            % surface we are fitting the peaks to, w1 = 0 for perfectly filled trough and the curve is symmetric

           
            Iref = double(imread(strcat(folder, imgArray(i)))); % read image data
            
            
            % converts rgb img data to greyscale for analysis
            if size(Iref,3) == 3
                
                Iref = rgb2gray(Iref);
                
            end


            % get two independent carrier peaks from reference image
            [kr, ku] = findorthcarrierpks(Iref, 4*pi/min(size(Iref)), Inf); %[SW]

            
            % extract carrier signals from reference image and store them for later use
            krad = sqrt(sum((kr-ku).^2))/2;%[SW]
            fIref = fft2(Iref);%[SW]
            cr = getcarrier(fIref, kr, krad);%[SW]
            cu = getcarrier(fIref, ku, krad);%[SW]
            [rows,cols] = size(Iref);%[SW]
            kxvec = fftshift(kvec(cols));%[SW]
            kyvec = fftshift(kvec(rows));%[SW]
            wr = hann(rows,'periodic');%[SW]
            wc = hann(cols,'periodic');%[SW]
            win2d = wr(:)*wc(:)';%[SW]

            fftIm = fftshift(abs(fft2((Iref-mean(Iref(:))).*win2d)));%[SW]
            
            % Harry wrote this. I don't really know exactly what it's
            % doing.
            c = cu;
            diffIdxX = 30;
            [val,idxX]=min(abs(kxvec-c.k(1)));
            kxvecShort = kxvec(idxX-fix(diffIdxX):idxX+diffIdxX);
            diffIdxY = 6;
            [val,idxY]=min(abs(kyvec-c.k(2)));
            kyvecShort = kyvec(idxY-diffIdxY:idxY+fix(diffIdxY/1));

            fftIm1 = fftIm(idxY-diffIdxY:idxY+fix(diffIdxY/1),idxX-fix(diffIdxX):idxX+diffIdxX);
            
            % fits curve to johnson surface
            xss = reshape(repmat(kxvecShort,length(kyvecShort),1),1,[]).';
            yss = repmat(kyvecShort(:),length(kxvecShort),1);
            hss = reshape(fftIm1,1,[]).';
            [surffit,gof] = fit([xss,yss],hss,surfjons,'Lower',[0, 0, 0, c.k(1)-0.5, c.k(2)-0.5, -20, -1e5], ...
                                                        'StartPoint',[0, 0.01, 0.01, c.k(1), c.k(2), 0, 0], ...
                                                       'Upper',[1e5, 0.05, 0.05, c.k(1)+0.5, c.k(2)+0.5, 20, 1e5])
            coef = coeffvalues(surffit);
            conLim = confint(surffit);

            mm = linspace(min(kxvecShort), max(kxvecShort), length(kxvecShort));
            qq = linspace(min(kyvecShort), max(kyvecShort), length(kyvecShort));


            A = coef(1);
            s1 = coef(2);
            s2 = coef(3);
            t1 = coef(4);
            t2 = coef(5);
            w1 = coef(6);
            z1 = coef(7);

            skewArray(i) = w1;  % w1 is the skew factor
    
        end

    skew = mean(skewArray, 'all');

end


