This repository contains the OpenSCAD files capable of generating helical antenna scaffolds procedurally based on user inputs.  

![image](https://user-images.githubusercontent.com/76875958/126278826-27347789-7698-49d1-b7dd-03afd9dbf329.png)

Some of the formulas that are used to compute the helix dimensions are taken from [daycounter.com](https://www.daycounter.com/Calculators/Helical-Antenna-Design-Calculator.phtml). I do not guarantee that the resulting helix scaffold will be perfect and in tune, as there are many factors that affect the performance. It does however generate scaffolds pretty much identical to my original ones as long as proper inputs are given, and those have a pretty good track record.

<img src="https://user-images.githubusercontent.com/76875958/126063809-c2a07ed3-0a55-4eae-b551-58973dcbdb07.gif" alt="Random helix gif" width="25%" height="25%">

Also please keep in mind that this is the first project I've ever done in OpenSCAD so expect a lot of strange and non-sensical code if you're going to be investigating it. With that said though I'm happy to take suggestions for improvements, bug fixes, or additional features. Feel free to open issues or make pull requests if you manage to improve the script!

## Usage

### Downloading

To use this project you need to have OpenSCAD installed. It is a free and open source program with binaries for Windows, Mac and Linux available for download [here](https://openscad.org/downloads.html).  
Once OpenSCAD is on your system you can load the .scad file from this repository by downloading it and opening it in OpenSCAD, or copying and pasting the code from it into OpenSCAD's editor. The .json file sharing the same name contains example presets and has to be placed in the same folder as the .scad file to work (optional).

Change the parameters of the code to customize the scaffold. This is done either by using OpenSCAD's automatically generated parameter window or by manually adjusting the values in the code using the editor (may be required when the parameter window doesn't behave as expected). The editor can be opened by right-clicking the top bar. Once you have applied your changes, press F5 to refresh the model preview.

### Parameters

The parameters are the same no matter if you're using the parameter window or the code editor to adjust them. The parameter window comes with auto-preview that should preview the scaffold mesh in real time as you apply your changes, but in case that doesn't work you can just press F5 to refresh the preview and apply your parameters manually. Each parameter has a comment containing a short description, they are described in more detail below;

* **Frequency** - The main parameter affecting the dimensions of the helix. Set this to the desired operating frequency of your helix in megahertz (e.g. for HRPT reception set to "1700"). The desired frequency directly affects the scale of the scaffold, setting it too high or too low without adjusting other parameters properly will result in a stange output.  
* **LHCP** - A boolean variable telling OpenSCAD whether or not it should use left-hand circular polarization. When unchecked it will generate a RHCP scaffold. Keep in mind that when a helix is used as a dish feed, its polarization should be the opposite of the received signal as the dish reflector inverts is (e.g. HRPT is RHCP, a HRPT dish feed therefore needs to be LHCP).  
* **Turns** - How many turns do you want the helix conductor to have. Affects the height of the scaffold. Controls the gain and beamwidth of the helical antenna together with the "Spacing" parameter.
* **Spacing** - The distance between each turn of the helix conductor in wavelengths. Affects the height of the scaffold. Controls the gain and beamwidth of the helical antenna together with the "Turns" parameter.
* **Wire diameter** - Directly affects the diameter of the holes in the scaffold legs. Set this to your conductor's diameter in milimeters (I also recommend leaving some extra space for ease of construction and 3D printing tolerances, e.g. for a 2mm wire I would set this to 3 or 4mm).
* **Leg count** - How many support legs the scaffold has. The default value is 3, you can decrease this to 2 if your conductor doesn't need that much support or even to 1 when you just want a simple guide rail. Increasing above 3 is also possible but it may limit the space available for other components (such as the connector or a matching strip). I recommend leaving this as 3 unless you want to experiment or need a special-purpose scaffold (also definitely *don't* use decimals for this, unless......😳).
* **Enable overhang support** - A boolean variable that enables or disables the support arches at the top of the scaffold. These provide a significant structural support boost and are therefore recommended to be enabled when possible. The scaffold is designed to be printed without any extra support material, so the overhang on these arches may theoretically cause issues with some printers (tested on my Ender 3 without problems, just minor cosmetic flaws).
* **Enable cutout** - When enabled, one section of the base circle between the legs will be cut out. This is to make space for other parts of the feed, such as the connector or a matching strip. Disable this when not needed for extra structural strength.
* **Enable outer mounts** - A boolean variable that enables or disables the two outer mounting legs.
* **Enable inner mounts** - A boolean variable that enables or disables an extra inner mount in the center of the scaffold.
* **Mounting diameter** - Sets the diameter of the mounting holes in milimeters. Set this slightly higher than your mount bolt diameter to improve printing tolerances.
* **Mounting separation** - The distance between the two outer mount leg centers in milimeters. When setting this, make sure you have enough clearance between the outer mounting legs (most of my older scaffolds used 80mm footprint, obviously needs to be increased when working with longer wavelengths).  
* **Prevent hole clipping** - When this is enabled, a hole in the scaffold leg will not be rendered when it overlaps or gets too close (within wire diameter) to the top of the helix.
- *By default some dimensions of the helix are scaled together with the operating wavelength which may cause issues in some cases. The following modifiers can be used to manually tweak those (e.g. a modifier of "2" will double a given value, a modifier of "0.5" will half it).*
* **Base thickness modifier** - Modifies the thickness of the base footprint of the helix.
* **Leg width modifier** - Modifies the width of the helix support legs.
* **Outer leg reinforcement modifier** - Modifies the size of the helix leg reinforcements (what gives them the "T" profile). Increase this for extra structural strength, can be set to 0 when the support isn't needed (e.g. a very small/short scaffold). Another purpose of the reinforcements is to lenghten the short axis of the leg's profile and decrease the amount of bending during printing so if you encounter those issues they may be fixed by increasing this modifier's value as well.
* **Mount rim thickness modifier** - Modifies the width of the rims around the mounting holes. May be increased for example when exceptional force from the mounting bolts is expected.
* **View reflector** - When enabled it will render a circular reflector plate below the helix. This is purely for visual guidance so you can see how big the scaffold is in relation to the smallest recommended reflector for the given frequency. Make sure to disable this before exporting the stl otherwise it will get embedded in it.
* **Reflector thickness** - Sets the thickness of the reflector render in milimeters.
* **Scaffold color** - Three values between 0 and 1 set the RGB color used for the scaffold mesh. Won't affect the resulting stl.
* **$fn** - A default OpenSCAD variable that defines the number of faces used for spherical/curved geometry. You can increase this before exporting your stl to make it smoother (or decrease it if you're feeling particularly artistic).

When previewing using F5 or rendering using F6, additional information will be printed in the console output with the dimensions of the helix. This includes the max height and width so you can judge how well the model will fit the print bed.

### Exporting

Once you are satisfied with the scaffold mesh, you can export it for 3D pritning. This is done by first rendering it by pressing F6. This may take some time, but once it's done you can go the File -> Export menu and select the desired output type (e.g. STL). This will export the mesh into a 3D file that can then be put in the slicer software such as Cura for printing.

### Printing

The scaffold design is meant to save as much filament as possible to decrease the printing time and enable fast prototyping (and cheap and quick replacements in case the scaffold breaks). You should be able to print the scaffold without any support material and with a very low infill density. It is very likely that the overhang support arches (when enabled) will result in some stringing and print imperfections, but those usually only last for the first few affected layers and shouldn't affect the overall scaffold in any way besides looks.
