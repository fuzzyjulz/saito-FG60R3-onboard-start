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
main_gear_teeth = 48-4;
main_gear_mod = 2;
flange_inner = outer_bearing-outer_bearing_flange;
flange_width = (gear_width-bearing_width)/2+1; //flange for the main gear

bearing_holder_d = outer_bearing + 16;
bearing_holder_depth = 2;

bushing_holder_depth = 2;

main_reducer_gear_teeth = 12;
pinion_reducer_gear_teeth = 72-12-4;
pinion_gear_mod = 1;
pinion_gear_teeth = 12-2;


echo("----- Outputs -------");
main_to_reducer = main_gear_teeth/main_reducer_gear_teeth;
reducer_to_pinion = pinion_reducer_gear_teeth/pinion_gear_teeth;

echo("main ",main_gear_teeth, "t, main reducer ",main_reducer_gear_teeth,"t, pinion reducer",pinion_reducer_gear_teeth,"t, pinion",pinion_gear_teeth,"t");
echo("gearing",main_to_reducer,"*",reducer_to_pinion," = ",main_to_reducer * reducer_to_pinion, "orig ~17");
echo("Motor KV",1200/17 * main_to_reducer * reducer_to_pinion);

difference () {
    union () {
        %motor();
        main_gear_assembly();
        reduction_gear_assembly();
        starter_motor_assembly();
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

module starter_motor_assembly() {
    main_gear_diameter = (main_gear_teeth+2)*main_gear_mod;
    main_reduction_gear_diameter = (main_reducer_gear_teeth+2)*main_gear_mod;

    pinion_reducer_gear_diameter = (pinion_reducer_gear_teeth+2)*pinion_gear_mod;
    pinion_gear_diameter = (pinion_gear_teeth+2)*pinion_gear_mod;
    
        translate([main_gear_diameter/2 + main_reduction_gear_diameter/2 - main_gear_mod*2,0,-11]) {
            rotate([0,0,-100]) {
                translate([pinion_reducer_gear_diameter/2 + pinion_gear_diameter/2 - pinion_gear_mod*2,0,-14]) {
                    rotate([0,0,23]) {
                        color("teal")
                            motor_and_pinion();
                    }
            }
        }
    }
}

module motor_and_pinion() {
    starter_diameter = 35;
    starter_length = 35;
    
    spur_gear(pinion_gear_mod, pinion_gear_teeth, 18, 5, optimized = false);
    cylinder(d=5, h=15);
    
    translate([0,0,-starter_length]) {
        cylinder(d=starter_diameter, h=starter_length);
    }
}
reduction_gear_top = 13;

module reduction_gear_assembly() {
    main_gear_diameter = (main_gear_teeth+2)*main_gear_mod;
    main_reduction_gear_diameter = (main_reducer_gear_teeth+2)*main_gear_mod;
    
    translate([main_gear_diameter/2 + main_reduction_gear_diameter/2 - main_gear_mod*2,0,reduction_gear_top-30])
    rotate([0,0,15]) {
        reduction_gear();
    }
}

module reduction_gear() {
    translate([0,0,10])
        spur_gear(main_gear_mod, main_reducer_gear_teeth, 20, 10, optimized = false);
    spur_gear(pinion_gear_mod, pinion_reducer_gear_teeth, 10, 10, optimized = false);

}





module main_gear_assembly() {
    explode_dim = 0;//25;
    
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
            bearing([4*2, 4*2], [20, 47], [2, 1], bearing_width);
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
        spur_gear(main_gear_mod, main_gear_teeth, 20, flange_inner, optimized = false);
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
    echo("Baring Key Length:",gear_width-bearing_holder_depth)
    
    translate([47/2-1.5,-2,0]) {
        cube([3,3,gear_width-bearing_holder_depth]);
    }
}

module bushing_key() {
    echo("Bushing Key:",inner_key_width, " x ", inner_key_depth, " x ", gear_width - flange_width)
    
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
    outer_key_width = 3;

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

