include <gears.scad>


echo("----- Outputs -------");
difference () {
    union () {
        motor();
        onboardStarter();
    }
    translate([-50,0,-50])
        cube([100,100,100]);
}
module motor() {
    whisker = 0.4;// 0;
    
    translate([0,0,-whisker]) {
        cylinder(h=50,d = 10-whisker);
        translate([0,0,-9]) {
            cylinder(h=9,d = 45);
            translate([0,0,-3]) {
                cylinder(h=9,d = 45);
                cylinder(h=9,d = 30);
                translate([0,0,-3]) {
                    cylinder(h=3,d = 30);
                    translate([0,0,-10]) {
                        cylinder(h=10,d = 44);
                    }
                }
            }
        }
    }
}

module onboardStarter() {
    bearing_width = 14;
    gear_width = 20;
    outer_bearing = 47;
    outer_bearing_flange = 6;
    flange_inner = outer_bearing-outer_bearing_flange;
    flange_width = (gear_width-bearing_width)/2+1;
    inner_bearing = 20;
    inner_bearing_flange = 6;
    motor_shaft = 10;
    
    
    inner_bearing_key_depth = 1.5;
    inner_key_length = 10;
    inner_key_width = 6;
    inner_key_depth = 4;

    main_gear_teeth = 48;
    
    #color ("blue") {
        difference() {
            spur_gear(2, main_gear_teeth, 20, flange_inner, optimized = false);
            translate([outer_bearing/2-1.5,-2,0]) {
                cube([4,4,20]);
            }
            translate([0,0,flange_width]) {
                cylinder(d=outer_bearing, h=gear_width);
            }
            cylinder(d=outer_bearing, h=2);
        }
    }
    //keyway
    *color ("green") {
        translate([47/2-1.5,-2,0]) {
            cube([4,4,20]);
        }
    }
    
    //bearing
    color ("red") {
        translate ([0,0,flange_width]) {
            bearing(bearing_width);
        }
    }
    
    *color ("green") {
        translate([motor_shaft+inner_bearing_key_depth-inner_key_depth,0,flange_width]) {
            rotate([90,0,90]) {
                milledKey_singleside(inner_key_width,inner_key_depth,gear_width - flange_width);
            }
        }
    }

    color ("yellow") {
        difference() {
            union() {
                cylinder(d=inner_bearing, h=gear_width);
                cylinder(d=inner_bearing+inner_bearing_flange, h=flange_width);
                cylinder(d=outer_bearing-outer_bearing_flange-4, h=flange_width-.5);
            }
            //motor shaft
            cylinder(d=motor_shaft, h=100);
            //inner key
            translate([motor_shaft+inner_bearing_key_depth-inner_key_depth,0,flange_width]) {
                rotate([90,0,90]) {
                    milledKey_singleside(inner_key_width,inner_key_depth,gear_width - flange_width);
                }
            }
            echo("Inner Stock ( diameter",outer_bearing-outer_bearing_flange-4, ", width: ", gear_width,")");
        }
    }
}

module milledKey_singleside(width, depth, length) {
    translate([0,width/2,0]) {
        linear_extrude(height = depth) {
            circle(d=width);
            translate([-width/2,0]) {
                square([width, length - width/2]);
            }
        }
    }
}

module bearing(bearing_width) {
    outer_bearing_surface = 6.5;
    inner_bearing_surface = 6.5;
    inner_bearing = 20;
    outer_bearing = 47;
    inner_key = 1.5;
    inner_key_width = 6;
    outer_key = 1;
    outer_key_width = 4;
    
    //outer ring
    linear_extrude(height = bearing_width) {
        difference () {
            circle(d=outer_bearing);
            circle(d=outer_bearing - outer_bearing_surface);
            translate([outer_bearing/2-outer_key-.15,-outer_key_width/2,0]) {
                square([outer_key+1,outer_key_width]);
            }
        }
    }

    //inner ring
    linear_extrude(height = bearing_width) {
        difference () {
            circle(d=inner_bearing + inner_bearing_surface);
            circle(d=inner_bearing);
            translate([inner_bearing/2-1.4,-inner_key_width/2,0]) {
                square([inner_key+1,inner_key_width]);
            }
        }
    }

    //inner ring
    translate ([0,0,2]) {
        linear_extrude(height = bearing_width-4) {
            difference () {
                circle(d=outer_bearing - outer_bearing_surface);
                circle(d=inner_bearing + inner_bearing_surface);
            }
        }
    }
}

