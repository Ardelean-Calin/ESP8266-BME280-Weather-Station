$fn = 100;
module plateNoCorners(l, w, r){
    difference(){
        square([l, w]);
        translate([0, 0])
        square([r, r]);
        translate([0, w-r])
        square([r, r]);
        translate([l-r, w-r])
        square([r, r]);
        translate([l-r, 0])
        square([r, r]);
    }
    
}
// The rounded corner with the screw
// hole in it
module cornerScrew(corner_radius, screw_radius, delta_r){
    r1 = corner_radius;
    r2 = screw_radius;
    // distance between outer radius
    // and center point
    c = r1 - delta_r - r2;
    a = c*sqrt(2)/2;
    
    intersection(){
        difference(){
            circle(r1);
            translate([a, a])
            circle(r2);
        }
        square([r1, r1]);
    }    
}

module corners(l, w, r, s_r, delta_r, cap_radius, cap_thickness){
    // Y
    // ^
    // |_ > X
    
    // Top left
    translate([r, w-r])
    rotate([0, 0, 90])
    cornerScrew(r, s_r, delta_r);
    
    // Top right
    translate([l-r, w-r])
    rotate([0, 0, 0])
    cornerScrew(r, s_r, delta_r);
    
    // Bottom left
    translate([r, r])
    rotate([0, 0, 180])
    cornerScrew(r, s_r, delta_r);
    
    // Bottom right
    translate([l-r, r])
    rotate([0, 0, 270])
    cornerScrew(r, s_r, delta_r);
}

// Top Plate with screw holes at
// given distance from edge
module topPlate(l, w, t, r, s_r, delta_r){
    
    linear_extrude(t)
    plateNoCorners(l, w, r);
    
    color("Red", 0.7) // temporary
    linear_extrude(t)  
    corners(l, w, r, s_r, delta_r);
}

// Wall with given length, height and
// thickness. Has a certain number
// of holes with given radius at
// given height
module wall(w, h, t, no_holes, h_radius, h_height=40){
    
    linear_extrude(t)
    // Make holes in the walls if defined
    if (no_holes){
        total_h_diameter = no_holes*h_radius*2;
        step = w/(no_holes+1);
        difference(){
            square([w, h]);
            for (x=[step:step:w-step+1]){
                translate([x, h_height])
                circle(h_radius);
            }
        }
    } else { // just an empty wall
        square([w, h]);
    }
}

module bottomPlate(l, w, h, t, r, s_r, delta_r){
    
    // Plate
    linear_extrude(t)
    plateNoCorners(l, w, r);
    // Corners
    translate([0,0,t])
    linear_extrude(h-t)  
    corners(l, w, r, s_r, delta_r);
    // Corners without holes
    linear_extrude(t)  
    corners(l, w, r, 0, 0);
}

module sideWalls(l, w, h, t, r, no_holes, h_height, h_radius){
    // Walls
    // 2x on length
    wall_width1 = l-2*r;
    // 2x on width
    wall_width2 = w-2*r;
    
    // 2x on length
    translate([r, t, 0])
    rotate([90, 0, 0])
    wall(w=wall_width1, h=h, t=t, no_holes=no_holes, h_height=h_height, h_radius=h_radius);
    
    translate([r, w, 0])
    rotate([90, 0, 0])
    wall(w=wall_width1, h=h, t=t, no_holes=no_holes, h_height=h_height, h_radius=h_radius);
    
    // 2x on width
    translate([t, w-r, 0])
    rotate([90, 0, 270])
    wall(w=wall_width2, h=h, t=t, no_holes=no_holes, h_height=h_height, h_radius=h_radius);
    
    translate([l, w-r, 0])
    rotate([90, 0, 270])
    wall(w=wall_width2, h=h, t=t, no_holes=no_holes, h_height=h_height, h_radius=h_radius);
}

module boxBottom(length=80, width=80, height=50, thickness=1.2, corner_radius=8, screw_radius=1.5, screw_delta_r=1.6, no_holes_wall, holes_height=40, holes_radius=1.5){
    
    color("YellowGreen", 1)
    bottomPlate(l=length, w=width, h=height, t=thickness, r=corner_radius, s_r=screw_radius, delta_r=screw_delta_r);
    
    color("SaddleBrown", 1)
    sideWalls(l=length, w=width, h=height, t=thickness, r=corner_radius, no_holes=no_holes_wall, h_height=holes_height, h_radius=holes_radius); 
}

module boxTop(length=80, width=80, thickness=1.2, corner_radius=8, screw_radius=1.5, screw_delta_r=1.6, cap_radius=2.5, cap_thickness=0.6){
    
    // Plate
    linear_extrude(thickness)
    plateNoCorners(length, width, corner_radius);
    
    // Corners
    color("YellowGreen", 1)
    difference(){
        translate([0,0,0])
        linear_extrude(thickness)  
        corners(length, width, corner_radius, screw_radius, screw_delta_r);
        
        translate([0, 0, thickness-cap_thickness])
        linear_extrude(thickness) 
        difference(){
            corners(length, width, corner_radius, screw_radius, screw_delta_r);
            corners(length, width, corner_radius, cap_radius, screw_delta_r-cap_radius+screw_radius);
        }
    }
}


boxBottom(length=75, width=60, height=30, holes_radius=3, no_holes_wall=3, holes_height=20);
translate([80,0,0])
color("YellowGreen", 1)
boxTop(length=75, width=60, thickness=2.5, cap_thickness=1.6, screw_delta_r=1.6);