# registrar
Registrar is a software for registration of 3D images in time and space.

[<img src="http://kahaki.ir/reg_before_after.PNG" alt="Registrar" align="middle">](http://www.neurogeometry.com)

The ability to map neural circuits on the scale of an entire brain is critical for advancing our understanding of brain functions. Circuit mapping can be based on whole-brain imaging of sparsely labeled populations of neurons with 3D confocal or two-photon microscopy. Registrar is a software for stitching and registration designed for different proposes including 1. Stitching of 3D image stacks of entire brain, 2. registration of time-lapse images, and 3. registration of images within stacks. 
1.	Stitching of 3D image stacks of entire brain: whole brain imaging experiment, if applied to the mouse brain, would result in tens of thousands of image stacks, totaling several terabytes of data. Because, imaging is generally done with small overlaps between neighboring stacks, the information contained in the stack overlap regions can be used for stitching. The Registrar software can provide the ability of stitching 3D stacks in both sequential and parallel and output the registered stack positions along with the transformation for each stack for further analysis. 

2.	Registration of time-lapse images: the second goal of this application is to register 3D stack images captured in different times. These images are usually having high overlap because they are taken from a same part of the brain in different time. The current Registrar software can also register this type of images with a high accuracy. 

3.	Registration of images within stacks: the Registrar software can register stack slices within a single stack which is an important task in Neuroscience and many other fields. Large scale image stacks captured in live animal can be transformed within the slices of the stacks. This is a common issue specially in EM data. Using this ability of the software, you can register the slices based on different transformation provided in the GUI.


# Examples

[<img src="https://web.northeastern.edu/kahaki/Registrar.PNG" alt="Registrar" align="middle">](http://www.neurogeometry.com)

# License

Copyright 2018 Northeastern University.

