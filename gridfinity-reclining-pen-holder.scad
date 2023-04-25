include <gridfinity-rebuilt-utility.scad>
// ===== PARAMETERS ===== //

/* [Setup Parameters] */
$fa = 8;
$fs = 0.25;

/* [General Settings] */
// Which part would you like to see?
part = "pens"; // [base:Base only,pens]
// Gridfinity of bases along x-axis
gridx = 2;  
// Gridfinity of bases along y-axis   
gridy = 2;  

// base unit
length = 42;

/* [Compartments] */

pen_list=[3,2,10,12];
angle = 45;
pen_spacing=10;

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



module gridfinitybase(){
color("tomato") {
gridfinityInit(gridx, gridy, height(gridz, gridz_define, style_lip, enable_zsnap), height_internal, length) {

    if (divx > 0 && divy > 0)
    cutEqual(n_divx = divx, n_divy = divy, style_tab = style_tab, scoop_weight = scoop);
}
gridfinityBase(gridx, gridy, length, div_base_x, div_base_y, style_hole);

}
}



print_part();

module print_part() {
    if (part=="base") {
        part_base();
    }
    else if (part == "pens") {
        part_pens();
    }
}


module pen(d = 10, gridy = gridy, angle = 45) {
	h = gridy * length * cos(angle);
	cylinder(d=d, h=h);
}

module pens(pen_list, pen_spacing, gridy, angle, index) {
	echo(pen_list = pen_list, index=index);
	if (index < len(pen_list)) {
		dx = pen_list[index] + pen_spacing;
		d = pen_list[index];
		echo(d=d, dx=dx);
		translate([d/2, 0, 0]) pen(d, gridy, angle);
		translate([dx, 0, ,0]) pens(pen_list, pen_spacing, gridy, angle, index + 1);
	}
}
	
module part_base() {
   
        gridfinitybase();
    
}

module part_pens() {
	pens(pen_list, pen_spacing, gridy, angle, index = 0);
}




