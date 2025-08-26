/**
* Name: shapefilesoctrang
* Based on the internal empty template. 
* Author: rattanak
* Tags: 
*/


model shapefilesoctrang

global {
	file parcel_file <- file('../includes/soctrang/Myan_parcels_region.shp');
	file river_file <- file('../includes/soctrang/myan_river_region.shp');
	file environment_file <- file('../includes/soctrang/environment_polyline_region.shp');
	matrix lan_unit_b_c <- matrix(file("../includes/soctrang/lan_unit_b_c.csv"));
	
	geometry shape <- envelope(environment_file);
	
	float total_rice_production <- 0.0;
	
	init {
		create River from: river_file;
		create Parcel from: parcel_file with: [id::read('STT'), terrain::read('AREA'), landuse_type::read('LAND_USE'), salee::read('SALINE'), land_unit::read('DVDD')] {
			do setColor;
		}
	}
}

species River {
	int segmen_id <-0; 
	rgb color <- rgb('yellow');
	action serRiver_color{
		let rivers type: list of: River <- list(River); 			
		color <- rgb('blue');
	}
}

species Parcel {
		rgb color <- rgb('yellow');
		int id <- 0;
		float terrain <- 0.0;
		string salee <- "0"; //parcel_type landuse_type ;
 		string landuse_type <- "";
		int land_unit <- 0;
		list LUT_avail <- [];
		float production_ha <- 0.0;
		float product <- 0.0;
		
		reflex production {
			/*if landuse_type = "veg" {
				 production_ha <- production_ha_riz;
			} else {
				if landuse_type = "coco_cacao" {
					 production_ha <- production_ha_vegatable;
				} else {
					 production_ha <- production_ha_crevette;
				}

			}*/

			product <- production_ha * terrain / 10000;
			//if landuse_type = "shrp" {
			//	produition_total_crevette <- produition_total_crevette + produit;
			//}

			if landuse_type = "rice" {
				total_rice_production <- total_rice_production + product;
			}

			//if landuse_type = "veg" {
			//	produition_total_vegatable <- produition_total_vegatable + produit;
			//}

		}

	action setColor {
			let parcels type: list of: Parcel <- list(Parcel);
			if (landuse_type = 'rice') {
				set color <- rgb('yellow');
			}

			if (landuse_type = 'veg') {
				set color <- rgb('green');
			}

			if (landuse_type = 'shrp') {
				set color <- rgb('blue');
			}

			if (landuse_type = 'ONT') {
				set color <- rgb([235,126,20]); // mau nau
			}
			if (landuse_type = 'coco_cacao') {
				set color <- rgb([16,171,5]); // mau xanh la dam
			}
			if (landuse_type = 'shrp_rice') {
				set color <- rgb([14,131,198]); // xanh cyan
			}
			//2rice_1veg
			if (landuse_type = '2rice_1veg') {
				set color <- rgb([237,244,56]);
			}

		} //action setColor

	}

experiment RunMe {
	output {
		display RiceSystem {
			species Parcel;
			species River;
		}
	}
}