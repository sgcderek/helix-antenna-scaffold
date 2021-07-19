
// This is a completely untested and experimental scaffold meant to work for wideband helices.
// Do not use this if you want a normally working antenna and are not prepared to conduct own testing.
// Set "Frequency" to the lower band and "Frequency2" to the higher one.
// For example if you want a scaffold that should work between 1500 and 2500 MHz you set:
// Frequency = 1500;
// Frequency2 = 2500;
// The rest of the parameters should work as usual with a few changes.
// The code to make this work is exceptionally bad, even worse than usual.
// Feel free to make and submit improvements or report test results.

// Set this to false to disable warning text (3D mesh won't render when enabled).
disclaimer = true;

Frequency = 1500;
Frequency2 = 2500;
LHCP = true;
Turns = 7;
Spacing = 0.2;
Wire_diameter = 3;
Leg_count = 3;
Wall_thickness = 4;
Enable_overhang_support = true;
Enable_cutout = true;
Enable_outer_mounts = true;
Enable_inner_mounts = false;
Mounting_diameter = 10;
Mounting_separation = 80;
Prevent_hole_clipping = true;
Base_thickness_modifier = 1.0;
Base_width_modifier = 1.0;
Leg_width_modifier = 1.0;
Outer_leg_reinforcement_modifier = 1.0;
Mount_rim_thickness_modifier = 1.0;
View_reflector = false;
Reflector_thickness = 1;
Scaffold_color = [0.2,0.7,0.7];
$fn = 30;

//-------------------------------------------------------
// Anything below this line is bad and classified as a cognitohazard by the Foundation, do not actually look at it if you just want a feed
//-------------------------------------------------------

wavelength = 29979.2458/Frequency;
wavelength2 = 29979.2458/Frequency2;
coil_diam = wavelength/PI*10;
coil_diam2 = wavelength2/PI*10;
Spacing_dist = wavelength*Spacing*10;
Spacing_dist2 = wavelength2*Spacing*10;
coil_height = Spacing_dist*Turns;
coil_height2 = Spacing_dist2*Turns;
ground_diam = wavelength*7.5;
coil_height_adj = ((coil_height2/Turns*Turns+(360+360/Leg_count)/360*Spacing_dist2)+(coil_height-coil_height2))/2;

// the variable names actually dont make sense dont think about it
base_h = Wall_thickness*Base_thickness_modifier; // base circle height
base_t = Wall_thickness*Base_width_modifier; // base circle thickness
leg_w = Wall_thickness*Leg_width_modifier; // leg width

// Reflector plate
if (View_reflector){
    color(Scaffold_color/2)
    translate([0,0,-Reflector_thickness])
    cylinder(r1=ground_diam/2, r2=ground_diam/2, h=Reflector_thickness);
}

if (disclaimer){
translate([coil_diam/1.7,0,0])
rotate([0,0,90])
color("red")
union(){
text("Not tested",halign="center",valign="bottom");
translate([0,-2,0])
text("Experimental",halign="center",valign="top");
}
}

scale([1,LHCP ? -1 : 1,1]) // invert Y axis to change polarization
union(){
    difference(){
        difference(){
            
            // base circle
            color(Scaffold_color)
            cylinder(r1=coil_diam/2+base_t/2, r2=coil_diam/2+base_t/2, base_h); // outer circle
            translate([0,0,-1])
            color(Scaffold_color)
            cylinder(r1=coil_diam/2-base_t/2, r2=coil_diam/2-base_t/2, base_h+2); // inner cutout
        }

        // Cutout section
        if (Enable_cutout){
            rotate([0,0,(Leg_count >= 2 ? -180/Leg_count : -90)])
            translate([0,0,2])
            rotate_extrude(angle=(Leg_count >= 2 ? 360/Leg_count : 180))
            translate([coil_diam/2,0,0])
            color(Scaffold_color)
            square([base_t*2,base_h+2+Wall_thickness], center=true);
        }
    }

    difference(){
        // Legs
        for (leg = [0:360/Leg_count:360]){
            // inner leg
            rotate([0,0,leg+360/Leg_count/2])
            translate([coil_diam/2-(coil_diam/4-coil_diam2/4),0,coil_height_adj/2])
            color(Scaffold_color)
            cube([(coil_diam-coil_diam2)*0.85,leg_w,coil_height_adj],center=true);

            // leg T support
            rotate([0,0,leg+180/Leg_count])
            translate([coil_diam/2+(coil_diam-coil_diam2)/8+leg_w/2,0,coil_height_adj/2])
            color(Scaffold_color)
            cube([leg_w,leg_w*Outer_leg_reinforcement_modifier*2,coil_height_adj],center=true);
                
            // tip overhang support
            if ((Enable_overhang_support)&&(Leg_count > 1)){
                difference(){
                    
                    // main body
                    rotate([0,0,leg+180/Leg_count])
                    translate([coil_diam/4,0,coil_height_adj-coil_diam/4])
                    color(Scaffold_color)
                    cube([coil_diam/2,leg_w,coil_diam/2],center=true); 
                        
                    // spherical cutout
                    translate([0,0,coil_height_adj-coil_diam/2])
                    color(Scaffold_color)
                    sphere(coil_diam/2-leg_w/2); 
                }
            }
        }

        // Leg holes
        for (leg = [0:(360/Leg_count):360]){
            for (hole = [0:1:Turns]){
                
                z_pos = coil_height/Turns*hole+(leg+360/Leg_count)/360*Spacing_dist;
                
                hole_pos = z_pos/coil_height; // hole position identifier (0 = first hole; 1 = last hole)
                spec_wavelength = wavelength - (wavelength-wavelength2)*hole_pos; // specific wavelength on hole position
                spec_spacing_dist = spec_wavelength*Spacing*10; // specific spacing on hole pos
                spec_coil_height = spec_spacing_dist*Turns; // specific coil height on hole pos
                spec_coil_diam = spec_wavelength/PI*10; // specific coil diameter on hole pos
                
                mod_z_pos = ((spec_coil_height/Turns*hole+(leg+360/Leg_count)/360*spec_spacing_dist)+(coil_height-spec_coil_height))/2;
                
                if (!((mod_z_pos > coil_height_adj-Wire_diameter)&&(Prevent_hole_clipping))){ // only make a hole when its below scaffold height or when clipping is allowed
                    
                    rotate([0,0,leg+180/Leg_count])
                    translate([spec_coil_diam/2,0,mod_z_pos])
                    rotate([0,90,90])
                    translate([0,0,-leg_w*0.55])
                    color(Scaffold_color)
                    cylinder( r1=Wire_diameter/2, r2=Wire_diameter/2, leg_w*1.1);
                    
                }
            }
        }
    }

    // Mounting holes
    if ((Enable_outer_mounts)||(Enable_inner_mounts)){

        difference(){
            union(){
                
                // right mount rim
                translate([0,Mounting_separation/2,0])
                color(Scaffold_color)
                cylinder( r1=Mounting_diameter*Mount_rim_thickness_modifier, r2=Mounting_diameter*Mount_rim_thickness_modifier, h=base_h );

                // left mount rim
                translate([0,-Mounting_separation/2,0])
                color(Scaffold_color)
                cylinder( r1=Mounting_diameter*Mount_rim_thickness_modifier, r2=Mounting_diameter*Mount_rim_thickness_modifier, h=base_h );
                    
                // main mount rim
                if (Mounting_separation > coil_diam){
                    translate([0,0,base_h/2])
                    color(Scaffold_color)
                    cube([Mounting_diameter*2*Mount_rim_thickness_modifier,Mounting_separation,base_h], center=true);
                }
                
                // extra inner side rims when mount smaller than helix
                if (Mounting_separation <= coil_diam){
                    translate([0,(coil_diam/2-(coil_diam-Mounting_separation)/4),base_h/2])
                    color(Scaffold_color)
                    cube([Mounting_diameter*2*Mount_rim_thickness_modifier,(coil_diam-Mounting_separation)/2,base_h], center=true);
                    
                    translate([0,-(coil_diam/2-(coil_diam-Mounting_separation)/4),base_h/2])
                    color(Scaffold_color)
                    cube([Mounting_diameter*2*Mount_rim_thickness_modifier,(coil_diam-Mounting_separation)/2,base_h], center=true);
                }
            }

            union(){
                
                if (Enable_outer_mounts){
                    
                    // right mount hole
                    translate([0,Mounting_separation/2,-1])
                    color(Scaffold_color)
                    cylinder( r1=Mounting_diameter/2, r2=Mounting_diameter/2, h=base_h+2 );

                    // left mount hole
                    translate([0,-Mounting_separation/2,-1])
                    color(Scaffold_color)
                    cylinder( r1=Mounting_diameter/2, r2=Mounting_diameter/2, h=base_h+2 );
                }
                    
                if (Enable_inner_mounts){
                    
                    // center mount hole
                    translate([0,0,-1])
                    color(Scaffold_color)
                    cylinder( r1=Mounting_diameter/2, r2=Mounting_diameter/2, h=base_h+2 );
                }
                    
                // center cutout
                if (((Enable_outer_mounts)&&(!Enable_inner_mounts))&&(Mounting_separation > coil_diam)){
                    translate([0,0,-1])
                    color(Scaffold_color)
                    cylinder( r1=coil_diam/2, r2=coil_diam/2, h=base_h+2 );
                }

                // outer cutout
                if ((!Enable_outer_mounts)&&(Enable_inner_mounts)){
                    difference() {
                    translate([0,0,-1])
                    color(Scaffold_color)
                    cylinder( r1=Mounting_separation, r2=Mounting_separation, h=base_h+2 ); 
                        
                    translate([0,0,-2])
                    color(Scaffold_color)
                    cylinder( r1=coil_diam/2, r2=coil_diam/2, h=base_h+4 ); 
                        
                    }
                }
            }
        }
    }
}