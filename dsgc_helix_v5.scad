/*
* dereksgc customizable helical antenna scaffold v5
* Changes can be tracked at https://github.com/sgcderek/dsgc-helix-scaffold/blob/funny/dsgc_helix_v5.scad
* Check the repo for future updated versions
*/

/* [Basic settings] */

// Operating frequency of the helix
Frequency = 1700;

// Spacing between turns (wl)
Spacing = 0.14;

// Number of turns of the helix
Turns = 5.5;

// Polarization of the helix
Polarization = "LHCP"; //[RHCP,LHCP]

// Diameter of the holes for the helix conductor (mm)
Cutout_diameter = 4;

// How much of the first turn is parallel to the reflector
Parallel_turn = 0.25;

// Face number (OpenSCAD/Customizer parameter)
$fn = 25;

/* [Leg settings] */

// Width of the inner leg wall (mm)
Inner_leg_width = 3;

// Width of the outer leg wall (mm)
Outer_leg_width = 10;

// Distance between inner and outer leg walls (mm)
Leg_wall_distance = 12;

/* [Base settings] */

// Base width (mm)
Base_width = 10;

// Base thickness (mm)
Base_thickness = 3;

// Cut out a third of the base (space for matching, connector, etc.)
Enable_cutout = true;

/* [Strut settings] */

// Thicknes of the top part of each strut (mm)
Strut_thickness = 1;

// Angle at which struts are generated (deg)
Strut_angle = 45;

// Generate a strut at the base of the scaffold
Bottom_strut = false;

// Generate a strut in the middle of the scaffold (recommended for tall scaffolds)
Middle_strut = false;

// Generate a strut at the top of the scaffold (recommended for most scaffolds)
Top_strut = true;

/* [Mounting settings] */

// Distance between the two mounting holes (mm)
Mounting_separation = 90;

// Diameter of the mounting holes (mm)
Mounting_diameter = 10;

// Thickness of the rim around each mounting hole (mm)
Mounting_thickness = 5;

/* [Text settings] */

// Enable engraved ID and decoration text
Enable_text = true;

// Custom decoration text (set to none to disable)
Decoration_text = "DEREKSGC";

// Depth of the text engraving (mm)
Text_depth = 0.75;

// Modifies the size of the text (can be lowered if text is too long)
Text_size_multiplier = 0.8;

/* [Hidden] */

// RGB value applied to the model render (won't affect stl).
Scaffold_color = [0.5,0.5,0.5];

// Polarization modifier (RHCP = 1, LHCP = -1)
Pol_modifier = (Polarization == "RHCP") ? 1 : -1;

// This rounds down the turn number to not render too much unused scaffold area (somehow?)
Turns_rounded = floor((Turns+0.01)/(1/3))*(1/3)-(1/6);

// Speed of light (m/s)
C = 299792458;

// Wavelength of the helix frequency (mm)
Wavelength = C/Frequency/1000;

// Diameter of the helix (mm)
Diameter = Wavelength/PI;

// Distance between turns (mm)
Spacing_distance = Wavelength*Spacing;

// Circumference of the helix (mm)
Circumference = PI*Diameter;

// Helix pitch (deg)
Pitch = atan(Spacing_distance/Circumference)*Pol_modifier;

// Calculate total number of segments in helix
Total_segments = Turns * 3;

// Calculate the length of each segment (slightly longer than longest leg dimension, mm)
Segment_height = max(Inner_leg_width, Outer_leg_width)*1.1;

// Calculate offset of the bottom corner of the strut base from the desired overhang angle
Strut_offset = ((Diameter/2)/tan(Strut_angle))-Leg_wall_distance/2;

// Total scaffold height (mm)
Total_height = (Turns_rounded*Spacing_distance+Cutout_diameter*3)-Spacing_distance*Parallel_turn;

// Font used for the text on the leg
Text_font = "DejaVu Sans:style=Bold";

// Size of the text
Text_size = Outer_leg_width*0.75*Text_size_multiplier;

// Shortened polarization text
Polarization_label = (Polarization == "RHCP") ? "R" : "L";

// Frequency text
Text_frequency = str(Frequency,Polarization_label);

// ID text
Text_ID = str(round(Turns_rounded*10)/10, "T", Spacing, "S");

// Difference between legs and leg cutouts
difference(){

    // Generate legs
    for (Leg = [1:1:3]){
        
        // Rotate each leg in place (120° increments)
        rotate([0,0,Leg*120-60])
            
        // Translate each leg in place
        translate([Diameter/2,0,0])
            
        // Face leg inwards
        rotate([0,0,-90])
        
        // Leg union
        union(){
        
            // Extrude leg from base polygon
            color(Scaffold_color)
            linear_extrude(height=Total_height){
                
                // Leg base polygon
                polygon(points=[
                    [-Outer_leg_width/2,Leg_wall_distance/2],
                    [Outer_leg_width/2,Leg_wall_distance/2],
                    [Inner_leg_width/2,-Leg_wall_distance/2],
                    [-Inner_leg_width/2,-Leg_wall_distance/2]
                ]);
                
            }
            
            if (Bottom_strut){
                // Translate and rotate bottom strut
                translate([Inner_leg_width/2,-Leg_wall_distance/2,0])
                rotate([0,270,0])
                
                // Extrude bottom strut
                color(Scaffold_color)
                linear_extrude(height=Inner_leg_width){
                
                    // Bottom strut polygon
                    polygon(points=[
                        [0,0],
                        [Strut_thickness,0],
                        [Strut_thickness,-Diameter/2+Leg_wall_distance/2],
                        [0,-Diameter/2+Leg_wall_distance/2]
                    ]);
                }
            }
            
            if (Top_strut){
                // Translate and rotate top strut
                translate([Inner_leg_width/2,-Leg_wall_distance/2,Total_height-Strut_thickness])
                rotate([0,270,0])
                
                // Extrude top strut
                color(Scaffold_color)
                linear_extrude(height=Inner_leg_width){
                
                    // Top strut polygon
                    polygon(points=[
                        [0-Strut_offset,0],
                        [Strut_thickness,0],
                        [Strut_thickness,-Diameter/2+Leg_wall_distance/2],
                        [0,-Diameter/2+Leg_wall_distance/2]
                    ]);
                }
            }
            
            if (Middle_strut){
                // Translate and rotate mid strut
                color(Scaffold_color)
                translate([Inner_leg_width/2,-Leg_wall_distance/2,(Total_height-Strut_thickness)/2])
                rotate([0,270,0])
                
                // Extrude mid strut
                linear_extrude(height=Inner_leg_width){
                
                    // Top mid polygon
                    polygon(points=[
                        [0-Strut_offset,0],
                        [Strut_thickness,0],
                        [Strut_thickness,-Diameter/2+Leg_wall_distance/2],
                        [0,-Diameter/2+Leg_wall_distance/2]
                    ]);
                }
            }

        }

    }

    // Generate text
    if(Enable_text){
        for (Leg = [1:1:3]){
            rotate([0,0,Leg*120-60])
            translate([Diameter/2,0,0])
            rotate([0,0,-90])
            if (Leg == 1){
                translate([-Text_size/2,Leg_wall_distance/2-Text_depth,Base_thickness*1.5])
                rotate([0,270,270])
                color(Scaffold_color)
                linear_extrude(height=Text_depth+1){
                    text(Decoration_text,font=Text_font,size=Text_size);
                }
            } else if (Leg == 2){
                translate([-Text_size/2,Leg_wall_distance/2-Text_depth,Base_thickness*1.5])
                rotate([0,270,270])
                color(Scaffold_color)
                linear_extrude(height=Text_depth+1){
                    text(Text_frequency,font=Text_font,size=Text_size);
                }
            } else if (Leg == 3){
                translate([-Text_size/2,Leg_wall_distance/2-Text_depth,Base_thickness*1.5])
                rotate([0,270,270])
                color(Scaffold_color)
                linear_extrude(height=Text_depth+1){
                    text(Text_ID,font=Text_font,size=Text_size);
                }
            }
        }
    }

    // Generate leg cutouts
    for (Segment = [1:1:Total_segments]){
        
        Segment_offset = max(Cutout_diameter,((Segment*Spacing_distance/3)-Spacing_distance*Parallel_turn));
        
        // Rotate each segment by 120°, with a 60° offset (aligned with legs)
        rotate([0,0,Segment*360/3*Pol_modifier-60*Pol_modifier]) 
        
        // Move each segment up by Spacing_distance/3 relative to previous segment)
        translate([Diameter/2,0,Segment_offset])
        
        // Apply pitch to segment
        rotate([90+(Segment_offset == Cutout_diameter ? 0 : Pitch),0,0])
        
        // Render segment
        color(Scaffold_color)
        cylinder(r1=Cutout_diameter/2,r2=Cutout_diameter/2,h=Segment_height,center=true);
    }

}



// Generate base
difference(){
    // Body union
    union(){
        // Base
        color(Scaffold_color)
        cylinder(d=Diameter+Cutout_diameter*1.5+Base_width*2,h=Base_thickness);
        
        // Mounting spar
        translate([0,0,Base_thickness/2])
        color(Scaffold_color)
        cube([Mounting_diameter+Mounting_thickness*2,Mounting_separation,Base_thickness],center=true);
        
        // Mounting rims
        translate([0,Mounting_separation/2,Base_thickness/2])
        color(Scaffold_color)
        cylinder(d=Mounting_diameter+Mounting_thickness*2,h=Base_thickness,center=true);
        translate([0,-Mounting_separation/2,Base_thickness/2])
        color(Scaffold_color)
        cylinder(d=Mounting_diameter+Mounting_thickness*2,h=Base_thickness,center=true);
    }

    // Cutout union
    union(){
        // Segment cutout
        if (Enable_cutout){
            rotate([0,0,-60])
            color(Scaffold_color)
            rotate_extrude(angle=120)
            translate([Diameter/2+Base_width/2,0,0])
            square([Base_width*2+Cutout_diameter*1.5,Base_thickness*3],center=true);
        }

        // Center cutout
        translate([0,0,-1]) // Shift 1mm down to properly cut out
        color(Scaffold_color)
        cylinder(d=Diameter+Cutout_diameter*1.5,h=Base_thickness+2);
        
        // Mounting holes
        translate([0,Mounting_separation/2,Base_thickness/2])
        color(Scaffold_color)
        cylinder(d=Mounting_diameter,h=Base_thickness+2,center=true);
        translate([0,-Mounting_separation/2,Base_thickness/2])
        color(Scaffold_color)
        cylinder(d=Mounting_diameter,h=Base_thickness+2,center=true);
    }
}