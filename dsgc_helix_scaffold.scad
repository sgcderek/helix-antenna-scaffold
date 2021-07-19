//-------------------------------------------------------
// Main settings:
//-------------------------------------------------------

// Operating frequency of the helix in MHz.
Frequency = 1700;

// Switch to LHCP polarization, leave unchecked for RHCP.
LHCP = true;

// Number of turns of the helix conductor.
Turns = 4.5;

// Turn spacing in wavelenghts or fractions of wavelength. E.g. spacing of 0.5 equals to 1/2 wavelength. 
Spacing = 0.14;

// Diameter of the helix conductor (wire) in milimeters.
Wire_diameter = 3;

// Number of support legs to generate. Set to 1 to generate only a single guide slot.
Leg_count = 3;

// Base thickness value of all scaffold walls in milimeters.
Wall_thickness = 4;

// Generate extra overhang support at the tip of the helix
Enable_overhang_support = true;

// Cut out one section between the legs
Enable_cutout = true;

// Enable outer mounting holes
Enable_outer_mounts = true;

// Enable inner mounting hole
Enable_inner_mounts = false;

// Diameter of the mounting holes (mm)
Mounting_diameter = 10;

// Distance between the centers of the outer mounting holes (mm)
Mounting_separation = 80;

// When set to true, holes that would overlap with the top of the scaffold aren't rendered
Prevent_hole_clipping = true;

//-------------------------------------------------------
// Advanced settings:
// Changing can result in very bad (or good) things happening
//-------------------------------------------------------

// Affects the thickness of the base and mounting supports.
Base_thickness_modifier = 1.0;

// Affects the width of the base (and legs).
Base_width_modifier = 1.0;

// Affects the thickness of the legs independently of the base.
Leg_width_modifier = 1.0;

// Affects the length of the outer "T" shape leg reinforcements.
Outer_leg_reinforcement_modifier = 1.0;

// Affects the width of the rim around the mounting holes/screws.
Mount_rim_thickness_modifier = 1.0;

// Render the reflector plate.
View_reflector = false;

// Thickness of the reflector in milimeters.
Reflector_thickness = 1;

// RGB value applied to the model render (won't affect stl).
Scaffold_color = [0.7,0.7,0.7];

// Geometry face count.
$fn = 30;

//-------------------------------------------------------
// Anything below this line is bad and classified as a cognitohazard by the Foundation, do not actually look at it if you just want a feed
//-------------------------------------------------------

wavelength = 29979.2458/Frequency;
coil_diam = wavelength/PI*10;
Spacing_dist = wavelength*Spacing*10;
coil_height = Spacing_dist*Turns;
ground_diam = wavelength*7.5;

// the variable names actually dont make sense dont think about it
base_h = Wall_thickness*Base_thickness_modifier; // base circle height
base_t = Wall_thickness*Base_width_modifier; // base circle thickness
leg_w = Wall_thickness*Leg_width_modifier; // leg width

echo("╔═══════");
echo("║Frequency:",Frequency,"MHz");
polarization = LHCP ? "LHC" : "RHC";
echo("║Polarization:",polarization);
echo("╠═══════");
if ((Enable_overhang_support)&&(Leg_count == 1)){
echo("║Only 1 leg selected, overhang disabled ");
}
if ((Enable_cutout)&&(Leg_count == 1)){
echo("║Only 1 leg selected, cutout angle set to 180 ");
}
echo("╚═══════");

// Reflector plate
if (View_reflector){
    color(Scaffold_color/2)
    translate([0,0,-Reflector_thickness])
    cylinder(r1=ground_diam/2, r2=ground_diam/2, h=Reflector_thickness);
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
            translate([coil_diam/2,0,coil_height/2])
            color(Scaffold_color)
            cube([base_t*1.5,leg_w,coil_height],center=true);

            // leg T support
            rotate([0,0,leg+180/Leg_count])
            translate([coil_diam/2+base_t*0.75+leg_w/2,0,coil_height/2])
            color(Scaffold_color)
            cube([leg_w,leg_w*Outer_leg_reinforcement_modifier*2,coil_height],center=true);
                
            // tip overhang support
            if ((Enable_overhang_support)&&(Leg_count > 1)){
                difference(){
                    
                    // main body
                    rotate([0,0,leg+180/Leg_count])
                    translate([coil_diam/4,0,coil_height-coil_diam/4])
                    color(Scaffold_color)
                    cube([coil_diam/2,leg_w,coil_diam/2],center=true); 
                        
                    // spherical cutout
                    translate([0,0,coil_height-coil_diam/2])
                    color(Scaffold_color)
                    sphere(coil_diam/2-leg_w/2); 
                }
            }
        }

        // Leg holes
        for (leg = [0:(360/Leg_count):360]){
            for (hole = [0:1:Turns]){
                z_pos = coil_height/Turns*hole+(leg+360/Leg_count)/360*Spacing_dist;
                if (!((z_pos > coil_height-Wire_diameter)&&(Prevent_hole_clipping))){ // only make a hole when its below scaffold height or when clipping is allowed
                    rotate([0,0,leg+180/Leg_count])
                    translate([coil_diam/2,0,z_pos])
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
                translate([0,0,base_h/2])
                color(Scaffold_color)
                cube([Mounting_diameter*2*Mount_rim_thickness_modifier,Mounting_separation,base_h], center=true);
            }

            union(){
                
                // right mount hole
                translate([0,Mounting_separation/2,-1])
                color(Scaffold_color)
                cylinder( r1=Mounting_diameter/2, r2=Mounting_diameter/2, h=base_h+2 );

                // left mount hole
                translate([0,-Mounting_separation/2,-1])
                color(Scaffold_color)
                cylinder( r1=Mounting_diameter/2, r2=Mounting_diameter/2, h=base_h+2 );
                    
                // center mount hole
                translate([0,0,-1])
                color(Scaffold_color)
                cylinder( r1=Mounting_diameter/2, r2=Mounting_diameter/2, h=base_h+2 );
                    
                // center cutout
                if ((Enable_outer_mounts)&&(!Enable_inner_mounts)){
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