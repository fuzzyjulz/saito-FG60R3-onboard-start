include <gears.scad>

m3 = 3;
upside_down = [180,0,0];

motor_shaft = 10;

bearing_width = 14;
outer_bearing = 47;
outer_bearing_flange = 6;
inner_bearing = 20;
inner_bearing_flange = 6;
inner_bearing_key_depth = 1.5;
inner_key_length = 10;
inner_key_width = 6;
inner_key_depth = 4;

gear_width = 20;
main_gear_teeth = 48;
flange_inner = outer_bearing-outer_bearing_flange;
flange_width = (gear_width-bearing_width)/2+1; //flange for the main gear

bearing_holder_d = outer_bearing + 16;
bearing_holder_depth = 2;

bushing_holder_depth = 2;


echo("----- Outputs -------");
difference () {
    union () {
        motor();
        onboardStarter();
    }
    *translate([-50,0,-50])
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
    explode_dim = 25;
    
    translate([0,0,explode_dim * 2])
    color ("blue") {
        main_gear();
    }
    
    //keyway
    translate([0,0,explode_dim * 4])
    color ("green") {
        baring_key();
    }
    
    //bearing
    translate([0,0,explode_dim * 3])
    color ("red") {
        translate ([0,0,flange_width]) {
            bearing([6.5, 6.5], [20, 47], [1.5, 1], bearing_width);
        }
    }
    
    translate([0,0,explode_dim * 4])
    color ("green") {
        bushing_key();
    }

    translate([0,0,explode_dim * 1])
    color ("yellow") {
        bushing();
    }

    translate([0,0,explode_dim * 5])
    color ("green") {
        bearing_holder();
    }
    translate([0,0,explode_dim * 5])
    color ("green") {
        bushing_holder();
    }

}

module main_gear() {
        difference() {
        spur_gear(2, main_gear_teeth, 20, flange_inner, optimized = false);
        baring_key();
        translate([0,0,flange_width]) {
            cylinder(d=outer_bearing, h=gear_width);
        }
        cylinder(d=outer_bearing, h=2);
        translate([0,0,flange_width]) {
            cylinder(d=outer_bearing, h=gear_width);
        }
        bearing_holder();
        //Bolt holes
        bearing_holder_bolts();
    }
}

module bushing_holder() {
    bushing_holder_d = inner_bearing+inner_bearing_flange + 9;
    echo("Bushing holder diamerter: ",bushing_holder_d);

    difference() {
        translate([0,0,gear_width]) {
            rotate(upside_down) {
                linear_extrude(bearing_holder_depth) {
                    difference() {
                        circle(d=bushing_holder_d);
                        circle(d=inner_bearing);
                    }
                }
            }
            linear_extrude(bushing_holder_depth) {
                difference() {
                    circle(d=bushing_holder_d);
                    circle(d=motor_shaft);
                }
            }
        }
        bushing_key();
    }
}

module bearing_holder() {
    difference() {
        translate([0,0,gear_width]) {
            rotate(upside_down) {
                linear_extrude(bearing_holder_depth) {
                    difference() {
                        circle(d=bearing_holder_d);
                        circle(d=outer_bearing-outer_bearing_flange);
                    }
                }
            }
        }
        bearing_holder_bolts();
    }
}

module bearing_holder_bolts() {
    for (r = [45:90:360]) {
        rotate([0,0,r]) {
            translate([0,outer_bearing/2+ (bearing_holder_d-outer_bearing)/4,gear_width]) {
                rotate(upside_down) {
                    cylinder(d=m3, h=10);
                }
                rotate(upside_down) {
                    cylinder(d=6, h=1);
                }
            }
        }
    }
}

module baring_key() {
    translate([47/2-1.5,-2,0]) {
        cube([4,4,gear_width-bearing_holder_depth]);
    }
}

module bushing_key() {
    translate([motor_shaft+inner_bearing_key_depth-inner_key_depth,0,flange_width]) {
        rotate([90,0,90]) {
            milledKey_singleside(inner_key_width,inner_key_depth,gear_width - flange_width);
        }
    }
}

module bushing() {
    difference() {
        union() {
            cylinder(d=inner_bearing, h=gear_width);
            cylinder(d=inner_bearing+inner_bearing_flange, h=flange_width);
            cylinder(d=outer_bearing-outer_bearing_flange-4, h=flange_width-.5);
        }
        //motor shaft
        cylinder(d=motor_shaft, h=100);
        //inner key
        echo("Inner Stock ( diameter",outer_bearing-outer_bearing_flange-4, ", width: ", gear_width,")");
    bushing_key();
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

module bearing(bearing_surface, diameter, key_depth, bearing_width) {
    inner_bearing_surface = bearing_surface[0];
    outer_bearing_surface = bearing_surface[1];
    inner_bearing = diameter[0];
    outer_bearing = diameter[1];
    inner_key = key_depth[0];
    outer_key = key_depth[1];
    inner_key_width = 6;
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

