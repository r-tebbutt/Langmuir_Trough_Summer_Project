Document for the use of the Langmuir Trough device, a project in soft matter physis supervised by Pietro Cicuta.

About::

The Langmuir Trough is a 3D printed device which is comprised of a trough, a stepper motor, a tilting arm and a razor blade.
Other components necessary for use are an arduino, a camera, a small digital screen, a rotary encoder and a computer. Ideally, a method to isolate the system from vibrations is used.
The use of the device is to measure the surface tension of a fluid, and this is done by filling the trough up to the razor blade with the fluid,
then capturing images of a checkerboard displayed underneath the fluid from above. An imaging process called Fast Checkerboard Demodulation is used cleverly to 
find the surface tension of the fluid based on how the curvature of the fluid surface distorts the light from the checkerboard and makes it appear distorted to the camera when 
compared to a uniform, flat reference checkerboard image. The idea behind the device is that is cheap, simple and can be printed by anyone anywhere and easily set up. The most expensive part is the camera lens, whereas 
other surface tension measuring instruments cost lots more money.

The project was initially undertaken by Harry McMullan as a physics Part III project at Cambridge university. It has since been carried on by Robson Tebbutt, a Part II student, as a summer project. Code written by Harry is commented with '%[HM]'.
Pietro Cicuta is the project supervisor.

The project's codebase is written in MATLAB, following from the MATLAB library used to perform the Fast Checkerboard Demodulation processes written by S. Wildeman: https://github.com/swildeman/fcd

Harry's github, containing the 3D models and his report, can be found here: https://github.com/iisrowingmad/PartIII-project/tree/main

Surface Evolver was used to simulate fluid surfaces and information on the program can be found here: http://facstaff.susqu.edu/brakke/evolver/html/evolver.htm#doc-top

OpenScad was used to design and render the models to 3D print.



First Time Setup::

- Print all the pieces and assemble, seal the transparent window with, for example, an O-ring and PTFE tape so that it is level and water-tight. Connect the motor and rotary encoder to an arduino, and thread the lead screw through the 
tilting arm. Mount the trough on an optical breadboard with enough space underneath for the lcd screen. Place the optical breadboard on a level surface and isolate from vibrations, I used a Table Stable TS-150.
- For accurate use it is important to ensure the lcd screen and trough are perfectly flat. The lcd screen can be set up very close to the glass window.
- Set up the camera and lens so that it is as far away as possible while still resolving checkers of the desired size, I used 2px size checkers. Make sure the lens surface is parallel to the horizontal of the focus and fix the lens in position.
- Connect the motor to the power supply and the camera, arduino and lcd screen, which should all be compatible with the computer, to the computer. 
- Set up MATLAB so it can communicate with the camera and arduino. I used the image processing toolbox and a pointgrey camera, which allowed easy communication. MATLAB is good at talking to arduinos, you can just open a port
and communicate with the serial. The lcd screen I used can just connect through HDMI to my laptop. Upload the arduino code to the arduino.
- There is code written to test the motor and camera with MATLAB.
- Set up your desired folder structure. The scripts generally work with the assumption that there is an overall workspace containing all the scripts and folders for images and plots, aswell as a folder for your checkerboard images.
- Use 'createCheckerboard.m' to make a checkerboard and save it to your checkerboard folder
- Ensure the 'fcd' files, written by S Wildeman, are on your MATLAB Path
- Configure the specific camera hardware you are using in 'cameraSettings.m', the image processing toolbox application will help you do this. You may have to install drivers for your particular camera.
- Use 'vidPreview.m' or open the image processing toolbox application and ensure the edge of the razor blade is parallel to the edge of the images taken (you may have to adjust the position of the trough for this)
- Use 'castImgToLCD' to ensure the checkerboard is being displayed on your screen correctly. It should be set up so that each element of the 2D image data array corresponds to one pixel on the device screen.
- To calibrate your setup, you need to find the conversion factor from image pixels to pixels on the checkerboard, i.e. How many pixels in the captured image correspond to one pixel on the checkerboard screen; adjust the 
'pxConversion' variable accordingly.



Collecting Image Data::

- To prepare the trough, use distilled water (I used Millipore water) to rinse the trough and remove contaminants. Put the razor roughly flat and fill the trough with the fluid of interest up to the razor edge. It is safest to sligtly
underfill than overfill the trough.
- Run the script 'setZeroSkew.m' to ensure the razor edge is very level with the fluid surface - in this state you will take reference images.
- Use 'vidPreview.m' and adjust 'cameraSettings.m' so that the image's region of interest has its edge just aligned with the razor edge but not including the razor, and only includes the checkerboard. 
- Adjust the parameters in 'cameraSettings.m' to your liking. Using a high gain makes the checkerboard more visible for set up, but a low gain gives less noise in the images.
- The razor is now set at 0 and the camera configured. Now you can run a script to collect whatever data you like. The examples are 'collectSurfaceTensionData.m' which takes reference images and then gradually increments the angle
of the razor blade, capturing images at each angle. Also included is 'recordVideo.m' which takes a video of the board and converts the video to individual frames for processing.
- Many images should be taken as the processing is very sensitive to external vibration, and noise from things like the screen, reflections, the camera etc all affect the calculated capillary length.
- It is best to ensure your experiments do not run for too long, as water evaporates and at higher angles this makes a big difference to the calculated capillary length over the span of an hour. Also contaminants collect and affect
surface tension, and dust introduces error into images. I used a cover over the camera and device to reduce vibrations from wind and noise from external light sources. Also, if your data doesn't require a moving razor blade, 
consider switching the motor off while data is collected as this reduces vibrations in the fluid.
- Between experiments, a vacuum pump was used to suck out the fluid, and the skew was set to 0 before the next reference images were collected. New reference images should be taken for each run of data.


Basic Working Theory::

- Literature can be found on interfacial tensiometry and the imaging technique that describe similar experiments: Molaei, Crocker 2019; S. Wildeman 2018. Reading Harry's report is very helpful.
- When the razor touches the fluid, the fluid pins to the razor blade edge and this edge of the fluid is lifted with the blade. This creates a decaying surface profile of the fluid. The decay length is the capillary length of the fluid
which is directly related to its surface tension.
- The fluid refracts the light from the checkerboard which passes through it. As the depth of the fluid now varies, following the decaying height profile, this affects the refraction of the light passing through it - the checkerboard
appears distorted when looking at it through the fluid when the razor is at a non-zero tilt.
- This refraction introduces an apparent displacement to the checkerboard field. We can find this displacement vector field through the imaging process. A 2D periodic crystal lattice can be expressed in harmonic series form, with
2 wavenumbers, k1 and k2. A displacement vector field modifies the phase of each harmonic in the series. If the distortion signal is not too large and the wavelengths comprising it are not too small, then the effect of the displacement
field will be localised around the carrier peaks at wavenumbers k1 and k2 in Fourier Space. Therefore, simple Fourier domain filtering can be used to extract signals at a single wavevector from the reference and distorted images
and these signals can be used together to extract the displacement field. Once we have the apparent displacement field, geometrically it is found that its integral is proportional to the height profile of the surface of the fluid. So
then, we use the Laplace-Young equation to find a 1D first-order solution, that we then fit to the height profile and extract a decay length.

- Skew: if the image of the checkerboard is not completely uniform, the carrier peaks formed from the Fourier transform of the checkerboard have a skew to their shape. Conversely, if the checkerboard is perfectly uniform, the carrier
peaks are symmetrical about their centre. The skew can then be used to gauge how flat the current checkerboard is, and so is a great metric for zeroing our razor blade before we take a reference image. If all that matters is that
the edge of the razor blade is level with the surface of the fluid, then we can use the skew to gauge this, rather than trusting that the razor is perfectly flat and the volume of the fluid is perfectly accurate.
- In the codebase we fit the curves to a modified form of Johnson's SU distribution. It is not a perfect fit but the skew coefficient works analogously to how we want it to, and its use seems consistent.
- For negative tilt anglesm the skew seems to be a bit unpredictable, but so far this hasn't been a concern because we haven't been using negative tilt angles. Sometimes the 'setZeroSkew.m' fails because it may overshoot to a 
negative angle and find another 0 skew value or positive value and then continue to decrease etc, when the reference image is obviously not undistorted. This can usually be fixed by starting the razor at a positive angle and allowing
it to iteratively decrease to 0.
- It is found that the skew varies as an inverse hyperbolic sinh of the angle, consistently, for positive angles. Harry found that the capillary length is a quadratic function of the angle of the razor blade, and so it is consistent that
it is found that the capillary length is a sinh^2 function of the skew.

- The best way to get a precise capillary length is to take images at multiple angles, and then fit a curve to the data found and extrapolate to read off the capillary length at a skew of 0. This is because small angle approximations
used in the geometric theory break down as the angle becomes larger. Ideally we would find the capillary length from images taken at 0 degrees then, but this doesn't work as there is no curvature to find the capillary length from, and
in the case that the reference image is the same as the 'distorted' image, the program tends to output about 4.5 as the capillary length. Therefore, we plot data taken at higher angles and extrapolate back to 0 skew.
- This is method that the scripts 'collectSurfaceTensionData.m' and 'plotSurfaceTensionData.m' follow. It is found that starting at a minimum angle of less than 0.4 degrees causes issues and some wild behaviour at smaller angles.
- Smaller angles also seem to be more affected by external vibrations, showing higher deviations between images. This probably makes sense as then the oscillation amplitude of the surface is bigger relative to the height difference
across the profile so there is larger proportional error.


S. Wildman's codebase:

- 'findorthcarrierpeaks.m' : takes 2D array image data and a minimum and maximum search range, and detects peaks in the Fourier space of the image data. kr and ku are 2-vectors which correspond to the location of the peaks in kspace. 
If this is flagging up an error 'Could not detect carrier signal' it usually means there is a problem with the image e.g. obstructed, issue with displaying checkerboard etc. krad is found from kr and ku.
- 'getCarrier.m' : this is ran after 'findorthcarrierpeaks.m' to create the carrier peak objects cr and cu. It takes the carrier peak vector, krad and the fft of the reference image as input and assigns properties to a carrier object,
which are the peak vector, krad (the filter radius in k-space), the mask (2D array of 1s in krad around the carrier peak, and 0s elsewhere - a filter through which only values at k-space within krad of the peak is passed), and 
the the conjugate of the carrier signal, used for demodulation.
- once you have the carrier peaks, 'fcp_dispfield.m' takes the distorted image data and carrier peaks and finds the displacement vector field components u and v.
