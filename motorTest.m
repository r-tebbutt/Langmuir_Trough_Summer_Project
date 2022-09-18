% script to test motor and razor tilting

delete(instrfind({'Port'},{'COM3'}));
calibrate();


while (1)

    angle_in = input('Enter angle,  enter 90 to exit: '); 
    
    if (angle_in == 90)
        
        break;
        
    else
        
        fprintf(arduino,'%f', angle_in); 

    end
    
end

fprintf(arduino, '%i', 0);
fclose(arduino);