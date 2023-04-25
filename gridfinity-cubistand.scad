include <gridfinity-rebuilt-utility.scad>
// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// Which part would you like to see?
part = "fullset"; // [base:Base only,top:Top only,rod:Connecting rod,cap: Connecting rod cap, fullset:Full set of parts]
// Gridfinity of bases along x-axis
gridx = 2;  
// Gridfinity of bases along y-axis   
gridy = 2;  
 
// base unit
length = 42;

/* [Compartments] */


// Number of holes width
holes_count_w = 4;

// Number of holes depth
holes_count_d = 4;

// Wall thickness. 
wall_thickness = 2; 

// Holder base and top height
holder_h = 7; 

//Rod height (excludes the part that goes into the base and top)
rod_h = 60; 

// Rounding. This is the rounding at the corners of the base and top.
rounding2 = 6; 

// Bottom Thickness. 
bottom_h = 3; //[1,2,3,4,5]

// Rod play. This shrinks the ends of the rod by a smidge so they can be inserted into the printed base and top.
rod_play = 0.05; // [0,0.05, 0.1, 0.2]

// Cap height. Zero means no cap.
cap_h = 6; 


/*[Hidden]*/
// number of X Divisions
divx = 1;
// number of y Divisions
divy = 1;
// ===== IMPLEMENTATION ===== //

// bin height. See bin height information and "gridz_define" below.  
gridz = 0;  

// determine what the variable "gridz" applies to based on your use case
gridz_define = 0; // [0:gridz is the height of bins in units of 7mm increments - Zack's method,1:gridz is the internal height in millimeters, 2:gridz is the overall external height of the bin in millimeters]
// overrides internal block height of bin (for solid containers). Leave zero for default height. Units: mm
height_internal = 0; 
// snap gridz height to nearest 7mm increment
enable_zsnap = false;

// the type of tabs
style_tab = 5; //[0:Full,1:Auto,2:Left,3:Center,4:Right,5:None]
// how should the top lip act
style_lip = 0; //[0: Regular lip, 1:remove lip subtractively, 2: remove lip and retain height]
// scoop weight percentage. 0 disables scoop, 1 is regular scoop. Any real number will scale the scoop. 
scoop = 0; //[0:0.1:1]

style_hole = 3; // [0:no holes, 1:magnet holes only, 2: magnet and screw holes - no printable slit, 3: magnet and screw holes - printable slit]
// number of divisions per 1 unit of base along the X axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_x = 0;
// number of divisions per 1 unit of base along the Y axis. (default 1, only use integers. 0 means automatically guess the right division)
div_base_y = 0; 



// Paintbrush hole width.
hole_w = (((gridx * 42) - (wall_thickness * holes_count_w + wall_thickness)) / holes_count_w); 

// Paintbrush hole length.
hole_d = ((gridy * 42) - (wall_thickness * holes_count_d + wall_thickness)) / holes_count_d; 


full_width = holes_count_w * (hole_w + wall_thickness) + wall_thickness;
full_depth = holes_count_d * (hole_d + wall_thickness) + wall_thickness;
$fn = 64;

module gridfinitybase(){
color("tomato") {
gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, length) {

    if (divx > 0 && divy > 0)
    cutEqual(n_divx = divx, n_divy = divy, style_tab = style_tab, scoop_weight = scoop);
}
gridfinityBase(gridx, gridy, length, div_base_x, div_base_y, style_hole);

}
}





// Brush holder
//
// ===================================================
// This is a remix of the Cubistand Pen Brush Holder Stand
// by sdmc
//
// ===================================================





inner_rounding = rounding2 - wall_thickness;
if ( inner_rounding < 0 ) {
    inner_rounding = 0;
}

print_part();

module print_part() {
    if (part=="base") {
        part_base();
    }
    else if (part == "top") {
        part_main();
    }
    else if (part == "cap") {
        part_cap();
    }
    else if (part == "rod") {
        part_rod();
    }
    else if (part=="fullset") {
        part_fullset();
    }
}

module part_fullset() {
    part_base();
    part_main();   
    part_rod();
    part_cap();
}

module part_cap() {
    if ( cap_h > 0 ) {
         translate([0,0,rod_h+30]) {
            difference() {
                onecorner_rounded_rectangle(hole_w+2*wall_thickness, hole_d+2*wall_thickness, cap_h, rounding2);
                translate([wall_thickness,wall_thickness,-1]) 
                onecorner_rounded_rectangle(hole_w, hole_d, cap_h - wall_thickness+2, inner_rounding);
            }
        }
    }
}

module part_rod() {
    union() {
        translate([0,0,holder_h]) 
            onecorner_rounded_rectangle(hole_w+2*wall_thickness, hole_d+2*wall_thickness, rod_h, rounding2);
        
        o = sign(cap_h) * (cap_h - wall_thickness);
        
        translate([wall_thickness+rod_play,wall_thickness+rod_play,rod_play]) 
            onecorner_rounded_rectangle(hole_w-rod_play*2, 
                    hole_d-rod_play*2, 
                    rod_h+(2*holder_h)-rod_play*2 + o, 
                    inner_rounding);
    }
}

module part_base() {
    union() {
        holed_rectangle();
        translate([0,0,-bottom_h]) {
            rounded_rectangle2(bottom_h);
        }
        translate([gridx*42 / 2,gridy*42 / 2,-9])
        gridfinitybase();
    }
}

module part_main() {
    translate([0,0,rod_h+holder_h]) {
        holed_rectangle();
    }
}

module holed_rectangle() {
    difference() {
        rounded_rectangle2(holder_h);
        for( x=[0:holes_count_w-1]) {
             for( y =[0:holes_count_d-1] ) {
                translate(
                    [wall_thickness+ (hole_w + wall_thickness) * x ,
                     wall_thickness+ (hole_d + wall_thickness) * y,
                     -1]) {
                         if ( (x == 0 && y == 0)) {
                             onecorner_rounded_rectangle( hole_w, hole_d, holder_h+2, inner_rounding);
                         } 
                         else if ( x==0 && y == (holes_count_d -1)) {
                             rotated_rounded_hole(180, true);
                         }                         
                         else if ( x== (holes_count_w -1) && y == (holes_count_d -1)) {
                             rotated_rounded_hole(180, false);
                         }                         
                         else if ( x==(holes_count_w -1) && y == 0) {
                             rotated_rounded_hole(0, true);
                         }                         
                         else                          
                         {
                             onecorner_rounded_rectangle( hole_w, hole_d, holder_h+2,0);
                         }
                }
             }
        }
    }
}

module rotated_rounded_hole(deg, which_corner) {
     translate([hole_w/2, hole_d/2,0]) {
         rotate([0,0,deg]) {
             translate([-hole_w/2, -hole_d/2,0]) {
                 if ( !which_corner) 
                     onecorner_rounded_rectangle( hole_w, hole_d, holder_h+2, inner_rounding, 0);                 
                 else 
                     onecorner_rounded_rectangle( hole_w, hole_d, holder_h+2, 0, inner_rounding);
             }
         }                             
    }
}

module onecorner_rounded_rectangle(w, d, h, r, r1) {    
    difference() {
        cube([w, d, h], false);
        if ( r > 0 ) {
            round_corner(r,h);
        }
        if ( r1 > 0 ) {
            other_round_corner(r1, w, h);
        }
    }
}

module round_corner(r, h) {
    p=1;      
    difference () {
        translate([-p,-p,-p]) { 
            cube( [r+p,r+p,h+p*2] , false);
        }
        translate([r, r, 0]) {
            cylinder(h,r,r);
        }
    }
}

module other_round_corner(r,w,h) {
    p=1;      
    difference () {
        translate([w-r,-p,-p]) { 
            cube( [r+p,r+p,h+p*2] , false);
        }
        translate([w-r, r, 0]) {
            cylinder(h,r,r);
        }
    }
}

module rounded_rectangle2(h) {
    union() {
        translate([0,rounding2,0]) {
            cube([full_width,full_depth - (rounding2 * 2),h], false);
        }
        translate([rounding2,0,0]) {
            cube([full_width - (rounding2 * 2), full_depth ,h], false);
        }
        translate([rounding2,rounding2,0]) {
            cylinder(h, rounding2, rounding2);
        }
        translate([full_width - rounding2,rounding2,0]) {
            cylinder(h, rounding2, rounding2);
        }
        translate([full_width - rounding2,full_depth - rounding2,0]) {
            cylinder(h, rounding2, rounding2);
        }
        translate([rounding2,full_depth - rounding2,0]) {
            cylinder(h, rounding2, rounding2);
        }
    }
}



