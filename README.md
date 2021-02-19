# CIS 566 Homework 1: Noisy Terrain

## Saranya Sampath Submission 

Here is the link for the project online: https://saranyacodes.github.io/CIS599_HW01/

For this assignment, I decided to make three different types of terrain. 
1) DreadMountains 
2) CottonCandyHills
3) FlatWasteLand

I used a lot of resources to complete this assignment, such as IQ's websites for random function 
and noise, 560 material on the shaderfun material, and other websites. I cite these websites within
comments in the code throughout the shaders. 

Additionally, I have added a GUI to modify some elements. One can modify the type of terrain they are 
witnessing through a drop down menu. Additionally, they can edit the height of the terrain, 
the opacity, whether it is in grayscale or not, and two colors that we can interpolate the terrain colors between. 

Techniques used to generate planet features: 
I used dat.GUI for the GUI elements, passing them through to the vertex and fragment shader through uniform variables. 

In the vertex shader I generate the height based on the type of terrain is chosen as well as the x, z value, and where the user's position is in space. For the DreadMountains, I map the user input height in between a range and then I use a sine term combined with Fractal Brownian Motion noise. Within the actual FBM noise function, I use another noise function which is called value noise. 

For the CottonCandyHills terrain, I use a sineterm, a mapped height term based on user input, as well as Fractal Brownian Motion with another value noise function. In this one, I also use a voronoi noise function. 

For the FlatWasteLand, I use the sineterm, a mapped height term based on user input, as well as Fractal Brownian Motion with another value onise function. In this one, I use a smoothstep function in order to create the flat hills at the top and create a new height value from that. 

In the fragment shader is where I set the colors. I pass through the FBM term since each terrain uses FBM, which is mapped from 0 to 1. Using this height mapping, I am able to use a mapping function to allow a gradient between two user input functions. If the user chooses not to input colors, then the colors will be greyscale, with the lower portions being darker and the higher portions being lighter. I basically map the user's colors to black and white and then translate them into the output color. 
