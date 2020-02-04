///////////////////////////////////////////////////////////////////////////////////////////////
//// Name: 	deStripe2
//// Author:	Sébastien Tosi (IRB / Barcelona)
//// Version:	1.0
////
//// Usage:	Designed to attenuate the stripes in SPIM images.
//// Input:	Any image, stack or hypertstack (should not exceed about 1/4 of available memory). 
//// Note:	The whole dynamic range (min to max) is compressed to 8-bit so that entire
////		z stacks should be processed at once to ensure 8-bit intensity levels consistency
////		across the z slices.
//// Params:	SubRad and OpenRad should be adjusted to the structures in the image
////		
////		Guidelines for adjustement:
////		- many thin stripes in the filtered image: decrease OpenRad
////		- large uniform stripes in filtered image: increase SubRad		
////		- filtered image looks "blocky" and too uniform: increase OpenRad
////		- filtered image looks dirty and distorted: decrease SubRad
////		If both parameters are very misadjusted it might be difficult to find the
////		right combination: 40 and 40 is a good starting point for 2048 x 2048 images
////		and stripe width similar to the example image.
////		
////		Sharpen is a post-processing sharpening filter:
////		- set SharpenRad to 0 to disable
////		- increase feedback to sharpen more (0 to 0.5)
///////////////////////////////////////////////////////////////////////////////////////////////

// Macro parameters 
Dialog.create("deStripe");
Dialog.addNumber("SubRad", 40);
Dialog.addNumber("OpenRad", 40);
Dialog.addNumber("SharpenRad", 10);
Dialog.addNumber("SharpenFeedback", 0.4);
Dialog.show();

// Variables initialization from dialog box
SubRad = Dialog.getNumber();
OpenRad = Dialog.getNumber();
SharpenRad = Dialog.getNumber();
SharpenFeedback = Dialog.getNumber();

setSlice(round(nSlices/2));
setTool("line");
waitForUser("Draw a line along the typical stripes orientation\n(from left to right)");
run("Measure");
run("Select None");
Orientation = getResult("Angle");
if(nSlices>1)
{
	run("Stack to Hyperstack...", "order=xyczt(default) channels=1 slices="+d2s(nSlices,0)+" frames=1 display=Grayscale");
	Stack.getStatistics(voxelCount, mean, min, max);
}
else getMinAndMax(min,max);
print(min,max);
setMinAndMax(min,max);
run("8-bit");
run("Rotate... ", "angle="+d2s(Orientation,2)+" grid=1 interpolation=Bilinear stack");
rename("Original");
run("Duplicate...", "title=Copy1 duplicate");
run("Subtract Background...", "rolling="+d2s(SubRad,0)+" disable stack");
run("Gray Morphology", "radius="+d2s(OpenRad,0)+" type=[hor line] operator=[fast open] stack");
run("Gaussian Blur 3D...", "x=0.1 y=2 z=0");
imageCalculator("Subtract stack", "Original","Copy1");
selectImage("Original");
run("Duplicate...", "title=Copy2 duplicate");
run("Subtract Background...", "rolling="+d2s(SubRad,0)+" disable light stack");
run("Invert", "stack");
run("Gray Morphology", "radius="+d2s(OpenRad,0)+" type=[hor line] operator=[fast open] stack");
run("Gaussian Blur 3D...", "x=0.1 y=2 z=0");
imageCalculator("Add stack", "Original","Copy2");
selectImage("Copy1");
close();
selectImage("Copy2");
close();
selectImage("Original");
if(SharpenRad>0)run("Unsharp Mask...", "radius="+d2s(SharpenRad,0)+" mask="+d2s(SharpenFeedback,2)+" stack");
selectImage("Original");
run("Rotate... ", "angle="+d2s(-Orientation,2)+" grid=1 interpolation=Bilinear stack");
rename("Filtered");
run("Enhance Contrast", "saturated=0.35");
selectWindow("Results");
run("Close");