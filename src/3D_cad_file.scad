// Simplified - correct physics, clean visualization
drum_radius = 40;
drum_height = 16;
lever_length = 250;
rope_diam = 1;
phi = 30;

// Fixed rope exit point (left side of drum)
exit_x = -drum_radius;

// Rope unwound length
rope_unwound = 50 + drum_radius * ((phi) * 3.14159 / 180);

// Main support
support_length = 280;
support_w = 40;
support_d = 9;
offset_z = 20;
color("Blue") {
translate([0, -(support_length/2-20), -offset_z])
cube([support_w, support_length, support_d], center = true);

translate([-support_w/2,-support_length+20,-offset_z-3*support_d/2])
cube([support_length,support_w,support_d]);
}

// cadran pour afficher les graduations d'angles

// Paramètres
r_int = 200;
r_ext = 250;
epaisseur = 3;
angle = 90;   // quart de cadran
$fn = 200;

translate([0, 0, -offset_z-support_d/2])
rotate([0, 0, -90])
linear_extrude(height = epaisseur)
    intersection() {
        // Anneau (cadran)
        difference() {
            circle(r = r_ext);
            circle(r = r_int);
        }

        // Secteur angulaire 90°
        polygon(points=[
            [0,0],
            [2*r_ext*cos(angle),  2*r_ext*sin(angle)],
            [2*r_ext*cos(0),      2*r_ext*sin(0)]
            
        ]);
    }


module ticks_cadran(r_int, r_ext, angle=90, pas=5, pas_long=15, ep=3, h=1.2) {
    // h = hauteur (épaisseur) des ticks en extrusion Z
    // ep = hauteur du cadran (pour synchroniser si besoin)
    linear_extrude(height = h)
    for (a = [0:pas:angle]) {
        is_long = (a % pas_long == 0);
        len = is_long ? 20 : 10;
        // On place un petit rectangle radial au bon angle
        rotate(a)
            translate([r_int, 0, 0])
                square([len, h], center = false); // longueur radiale × épaisseur 2D
    }
}

// Exemple d’appel, avec même placement/rotation que le cadran
translate([0, 0, -offset_z - support_d/2 + epaisseur])
rotate([0, 0, -90])
color("black")
ticks_cadran(r_int, r_ext, angle=90, pas=5, pas_long=15, ep=epaisseur, h=0.5);



// Pivot shaft (through drum center)
color("Black")
cylinder(h = 50, r = 2, center = true);

// Drum and lever (rotate together)
module drum_lever () {
    rotate([0, 0, -(90-phi)]) {
        // Drum
        color("Silver")
        cylinder(h = drum_height, r = drum_radius, center = true);
        
        // Lever
        color("Sienna")
        translate([lever_length/2, 0, (drum_height+9)/2])
        cube([lever_length, 16, 9], center = true);
        
        // Counterweight
        translate([150, 0, 10])
        color("Gold")
        cube([30, 30, 30], center = true);
    }
}
drum_lever();

// Rope (vertical from fixed exit point)
color("Red") {
translate([exit_x-rope_diam, 0, 0])
rotate([90, 0, 0])
cylinder(h = rope_unwound, r = rope_diam);

rotate([0, 0, 180-(90-phi)])
translate([rope_diam, 0, 0])
rotate_extrude(angle = (90-phi), convexity = 10)
translate([drum_radius, 0, 0])
circle(r = rope_diam);
}

// Plate
color("Green") {
plate_h = 55;
translate([exit_x-rope_diam, -(plate_h/2)-rope_unwound, 0])
rotate([90, 0, 0])
cube([30, 30, plate_h], center = true);
}

module annotate_phi(phi_deg, radius=60, thickness=1.8, z=drum_height + 20, txt_size=10) {
    // Arc (de 0 à phi_deg) dans le plan XY
    color("Black")
    rotate([0, 0, -90])  // arc de référence à partir de l'axe X positif
    translate([0, 0, z])
    rotate_extrude(angle=phi_deg, convexity=10)
        translate([radius, 0, 0])
            circle(r=thickness/2);

    // Flèche à l'extrémité de l'arc
    // On place un petit triangle au bout de l'arc
    color("Black")
    translate([0, 0, z])
    rotate([0, 0, -90+phi_deg])
    translate([radius+2, 0, 0])  // bout de l'arc
    rotate([0, 0, 90])
        linear_extrude(height=thickness)
            polygon(points=[[0,0],[6,2.5],[0,5]]);  // petite flèche

    // Texte "φ = ...°" (utilise text() -> 2D -> linear_extrude pour 3D)
    // On le place un peu à l'extérieur du rayon pour ne pas chevaucher l'arc
    color("Black")
    translate([0, 0, z + thickness])
    rotate([0, 0, 0])  // orienté à mi-angle
    translate([radius + 20, -txt_size/3, 0])  // décalage radial + léger centrage
        linear_extrude(height=1)
            text(str("φ = ", round(phi_deg), "°"), size=txt_size, halign="center", valign="center");
}

// Affiche l'annotation pour phi
annotate_phi(phi, radius = drum_radius + 20, thickness = 2, z = drum_height + 10, txt_size = 12);
