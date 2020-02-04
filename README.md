# deStripe

![alt text](https://raw.githubusercontent.com/SebastienTs/deStripe/master/FilterExample.PNG)

This ImageJ macro implements an image filter meant to mitigate close to parallel attenuation stripes, such as the ones typically observed in (fixed) light sheet microscopy. The filter is designed to cope with some stripe angular spread (e.g. due to light sheet refraction at the sample surface), and it can process a 3D stack in one go (but the processing is performed slice by slice).

For stripe width similar to the sample image, setting "SubRad" and "OpenRad" to 40 and disabling sharpening (SharpenRad = 0) is a good starting point. Scale these values proportionally to the typical width of the stripes. Some guidelines to further adjust the parameters:

1) Thin stripes apparent in filtered image                  --> decrease OpenRad
2) Large, uniform, stripes apparent in filtered image       --> increase SubRad 
3) Filtered image looks "blocky" and too smooth             --> increase OpenRad
4) Filtered image looks dirty and distorted                 --> decrease SubRad

SharpenRad / SharpenFeedback are the parameters of a post-processing high-pass filter meant to boost the high frequency part of the spectrum that might have been too attenuated by the main filter. Increase SharpenFeedback to sharpen more (practical range: 0 to 0.5), adjust SharpenRad to obtain the best results.
