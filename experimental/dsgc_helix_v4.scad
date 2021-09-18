/*
* dereksgc customizable helical antenna scaffold v4
* Changes can be tracked at https://github.com/sgcderek/dsgc-helix-scaffold (dsgc_helix_v4.scad)
*/

/* [Basic settings] */

// Center operating frequency of the helix (MHz)
Frequency = 1700;

// Whether the helix should be right or left hand circularly polarized (keep in mind a dish reflector inverts polarization)
Polarization = "LHCP"; //[RHCP,LHCP]

// How many turns the helix will have
Turns = 5.5;

// Spacing between the turns of the helix in wavelengths
Spacing = 0.14;

// Diameter of the support leg cutouts for the helical conductor. This should be higher than the diameter of the actual conductor in order to facilitate shrink or sag during printing
Cutout_Diameter = 4;

// Diameter of the mounting footprint circle (mm)
Mounting_Footprint_Separation = 90;

// Diameter of the mounting leg holes (mm)
Mounting_Hole_Diameter = 10;

// When enabled, information about the scaffold parameters will be embedded into the support leg model
Embed_Info_Text = true;

// Text that will be put on spare legs when info text embedding is enabled
Extra_Text = "DEREKSGC";

/* [Advanced settings] */

// Separation between the lower edge of the first conductor turn and the reflector plate (mm)
Vertical_Offset = 2;

// How many support scaffold legs to render (3 recommended)
Support_Leg_Count = 3; //[2,3,4,5]

// Base modifier of the overall scaffold wall thickness (defines the narrowest point of the scaffold in mm)
Base_Wall_Width = 2;

// When enabled, one section of the base scaffold circle will be cut out to facilitate a connector or a matching strip. The cutout size depends on the support/mounting leg count
Enable_Cutout = true;

Mounting_Leg_Count = 2; //[0,1,2,3,4,5]

/* [Hidden] */

// (this is currently a bit broken) What percentage of the first turn will be modelled parallel to the reflector plate to help impedance matching
Matching_Turn_Section = 25; //[0:75]

// Speed of light (m/s)
C = 299792458;

// Geometry face count
$fn = 30;

///////////////////////////////

polmod = (Polarization == "RHCP") ? 1 : -1;
mturnmod0 = Matching_Turn_Section/100;

// Segments per turn
spt = $preview ? 20 : 40;
// How many individual segments are used to model
// each turn of the helix.
// By default it's 20 for preview and 40 for render.

// Helix wavelength (mm)
wlength = C/Frequency/1000;

// Helix radius (mm)
hrad = wlength/PI/2;

// Total number of segments in helix
tseg = spt*Turns;

// Segment revolve angle (°)
segrev = 360/spt*polmod;

// Leg revolve angle (°)
legrev = 360/Support_Leg_Count;

// Cutout revolve angle (°)
cutrev = min(legrev, 360/Mounting_Leg_Count)*0.9;
// The cutout is put between whatever set of
// legs is the closest. This usually means the
// main scaffold legs as there will likely be
// more of them.

// Mounting leg revolve angle (°)
mlegrev = 360/Mounting_Leg_Count;

// Turn circumference (mm)
tcirc = 2*PI*hrad;
// This is actually just the helix circumference
// assuming a flattened circle. In hindsight I 
// shouldn't have called it this.

// Base helix height (mm)
height = Turns*Spacing*wlength;
// Distance between the very start and very
// end of the helix, ignoring any other factors
// that may influence this.

// Leg height (mm)
lheight = height + Vertical_Offset + Cutout_Diameter*2 - (mturnmod0*wlength*Spacing);

// Total helix length (mm)
hlength = Turns*sqrt(height/Turns*height/Turns + tcirc*tcirc);
// thanks https://sciencing.com/calculate-helical-length-7808380.html

// Segment lenght (mm)
seglen = hlength/tseg*1.1;

// Segment pitch (°)
segpitch = atan(height/hlength)*(1+Spacing*0.28);
// not sure what's wrong with the formula here
// atan(height/hlength) doesn't come up with a large enough pitch
// hence *(1+Spacing*0.28) is used to correct it
// still imperfect but only when Spacing is close or over 1wl
// which wouldn't be used in practice anyway
// will try to fix properly but not critical

// Modified matching turn length to match segments (wl)
mturnmod = round(mturnmod0/(1/spt))/spt ;

// Matching height offset (mm)
moffset = mturnmod*Spacing*wlength;

// Difference between scaffold and helix
difference(){
    
    // Scaffold body union
    color("MediumAquamarine")
    union(){
        
        // Support legs for loop
        for (leg = [1:1:Support_Leg_Count]){
            rotate([0,0,leg*legrev+legrev/2])
            translate([hrad-Base_Wall_Width*3,0,0])
            union(){
                
                // Difference between legs and engraved text (when enabled)
                difference(){
                    linear_extrude(height=lheight)
                    polygon(points=[
                        [0,Base_Wall_Width],
                        [Base_Wall_Width*6,Base_Wall_Width*3],
                        [Base_Wall_Width*6,-Base_Wall_Width*3],
                        [0,-Base_Wall_Width]
                    ]);
                    
                    // Info text
                    if (Embed_Info_Text){
                        txtsize = Base_Wall_Width*4;
                        txtfont = "DejaVu Sans:style=Bold";
                        if (leg == 1){
                            translate([Base_Wall_Width*6-1.4,txtsize/2,Base_Wall_Width*3])
                            rotate([90,-90,90])
                            linear_extrude(height=1.5)
                            text(text=(str(Frequency,"M")), size=txtsize, font=txtfont);
                        } else if (leg == 2){
                            translate([Base_Wall_Width*6-1.4,txtsize/2,Base_Wall_Width*3])
                            rotate([90,-90,90])
                            linear_extrude(height=1.5)
                            text(text=(str(Turns,"T",Spacing,"S")), size=txtsize, font=txtfont);
                        } else if (leg >= 3){
                            translate([Base_Wall_Width*6-1.4,txtsize/2,Base_Wall_Width*3])
                            rotate([90,-90,90])
                            linear_extrude(height=1.5)
                            text(text=Extra_Text, size=txtsize, font=txtfont);
                        }
                    }
                }
                
                // Overhang support
                translate([0,-Base_Wall_Width,lheight])
                rotate([0,90,90])
                linear_extrude(height=Base_Wall_Width*2)
                polygon(points=[
                    [0,0],
                    [hrad,0],
                    [0,hrad-Base_Wall_Width*2]
                ]);
            }
        }
        
        // Mounting base union
        union(){
            
            // Difference between outer base circle and inner circular cutout
            difference(){
                
                // Union of outer base circle and mounting legs
                union(){
                    
                    // Difference between outer base circle and section cutout (when enabled)
                    difference(){
                        cylinder(r1 = hrad+Base_Wall_Width*6, r2=hrad+Base_Wall_Width*6, h=Base_Wall_Width*2, $fn=Support_Leg_Count*3); // <- face number decreased to make it look cooler no other functional purpose
                        if (Enable_Cutout){
                            //base circle section cutout
                            rotate([0,0,-cutrev/2])
                            rotate_extrude(angle=cutrev)
                            translate([hrad+Base_Wall_Width*3,0,0])
                            circle(r=Base_Wall_Width*4);
                        }
                    }
                    
                    // Mounting legs for loop
                    for (mleg = [1:1:Mounting_Leg_Count]){
                        rotate([0,0,mleg*mlegrev+mlegrev/2])
                        translate([Mounting_Footprint_Separation/2,0,0])
                        linear_extrude(height=Base_Wall_Width*2)
                        polygon(points=[
                            [Mounting_Hole_Diameter,Mounting_Hole_Diameter],
                            [Mounting_Hole_Diameter,-Mounting_Hole_Diameter],
                            [-Mounting_Footprint_Separation/2,-Mounting_Hole_Diameter*2],
                            [-Mounting_Footprint_Separation/2,Mounting_Hole_Diameter*2]
                        ]);
                    }
                }
                // Inner base circular cutout
                translate([0,0,-Base_Wall_Width])
                cylinder(r1 =hrad+Base_Wall_Width, r2=hrad+Base_Wall_Width, h=Base_Wall_Width*4);
            }
        }
    }
    
    // Helix body and mounting holes union
    union(){
        
        // Helix segment for loop
        for (seg = [0:1:tseg]){
            
            // Segment position within helix (0 = first, 1 = last)
            segpos = seg/tseg;
            
            // Current turn section
            curturn = seg/spt;
            
            // Height offset of the segment
            zpos = height*segpos-moffset;
            
            // Segment length modified by matching offset
            seglenmod = (zpos < 0) ? tcirc/spt*1.1 : seglen;
            
            // Height offset of the segment modified by matching offset
            zposmod = ((zpos < 0) ? 0 : zpos)+Cutout_Diameter/2+Vertical_Offset;
            
            // Segment pitch modified by matching offset
            segpitchmod = (zpos < 0) ? 0 : segpitch;
            
            // Polarization 180° offset (LHCP)
            poloffset = (polmod == -1) ? 180 : 0;
            
            // Create segment
            rotate([0,0,seg*segrev+poloffset])
            translate([hrad*polmod,0,zposmod])
            rotate([-90+segpitchmod,0,segrev/2])
            color("peru")
            #cylinder(r1=Cutout_Diameter/2,r2=Cutout_Diameter/2,h=seglenmod); // remove the "#" prefix to disable rendering of the helix and only show cutouts instead
        }
        // Mounting holes
        for (mleg = [1:1:Mounting_Leg_Count]){
            rotate([0,0,mleg*mlegrev+mlegrev/2])
            translate([Mounting_Footprint_Separation/2,0,-Base_Wall_Width])
            cylinder(r1=Mounting_Hole_Diameter/2, r2=Mounting_Hole_Diameter/2, h=Base_Wall_Width*4);
        }
    }
}