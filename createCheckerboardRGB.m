%creates coloured and black checkerboard with specified image size and checker
%size in pixels. The checkerboard image can then be shifted/displaced to
%form new unique checkerboards

checkerfold = 'C:\Users\rtebb\Documents\SummerProject\Automation\checkerboards\';

width = 480;
height = 800;
pxGrd = 2;

blank = zeros(width, height, 3);

original = blank;
motif = zeros(pxGrd * 2, pxGrd * 2, 3);

colour = 2; % 1 = red, 2 = green, 3 = blue


% create our motif to repeat which will repeat throughout the periodic lattice
for i = 1:pxGrd
    
    for j = 1:pxGrd
        
        motif(i,j, colour) = 255;
        motif(i+pxGrd,j+pxGrd, colour) = 255;
        
    end
    
end



% changes each periodic block to the motif
for i = 1: width / (2 * pxGrd)
    
    for j = 1:height / (2 * pxGrd)
        
        posw = (i-1) * pxGrd * 2 + 1;
        posh = (j-1) * pxGrd * 2 + 1;
        original(posw : posw + 2 * pxGrd - 1, posh : posh + 2 * pxGrd - 1, :) = motif;
        
    end
    
end


shiftw = 0; % shift in x direction
shifth = 0; % shift in y direction


shifted = blank;

% creates displaced checkerboard image, iterates through unshifted image
% and assigns each pixel at a set displacement to the shifted image
for i = 1:width
    
    for j = 1:height
        
        posw = i + shiftw;
        posh = j + shifth;
        
        if(i+shiftw > width)
            
            posw =  mod(i+shiftw, width); % accounts for going out of bounds of image width 
            
        end
        
        if(j + shifth > height)
            
            posh = mod(j + shifth, height) ; % accounts for going out of bounds of image height
            
        end
        
        shifted(posw, posh, :) = original(i,j,:); 
        
    end
    
end

% save and show checkerboard
% imwrite(shifted, strcat(checkerfold, "1originalg.png"));
imshow(shifted);
