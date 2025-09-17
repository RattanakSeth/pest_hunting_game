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
	float production_ha_riz <- 3.086;
	float production_ha_vegatable <- 9.48;
	float production_ha_crevette <- 4.56;
	float production_ha_cocotier <- 6.61; // coconute
	
	float produition_total_crevette <- 0.0;
	float production_total_vegatable <- 0.0;
	//float produition_total_crevette <- 0.0;
	
	float area_crevette_ha <- 0.0;
	float area_rice_ha <- 0.0;
	float area_vegatable_ha <- 0.0;
	float area_cocotier_ha <- 0.0;
	
	float rice_price <- 0.0;
	float vegatable_price <- 0.0;
	
	init {
		create River from: river_file {
			do setColour;
		}
		create Parcel from: parcel_file with: [id::read('STT'), terrain::read('AREA'), landuse_type::read('LAND_USE'), salee::read('SALINE'), land_unit::read('DVDD')] {
			do setColor;
		}
		
		int i <-0;
		create species: Proprietaire number: length(Parcel);
		loop  i from: 0 to: length(Parcel) - 1 {
			ask Proprietaire at i {
				monParcel <- Parcel at i;
			}
		}

		do initializeParcel;
		do initializeLUT;
	}
	
	action initializeParcel {
		ask Parcel {
			loop i from: 1 to: lan_unit_b_c.rows - 1 {
				if (lan_unit_b_c at { 0, i } = "" + land_unit) { // tai vi doc tu file csv toan bo la text, string, trong khi id la int neu doi thanh so int(var)
 					let tmpLUT <- lan_unit_b_c	at { 1, i };
 					//write("tmp LUT: " + tmpLUT);
					if (!(LUT_avail contains tmpLUT)) {
						LUT_avail <- LUT_avail + tmpLUT;
					}
				}
			}
		}
	}
	
	action initializeLUT {
		loop i from: 1 to: lan_unit_b_c.rows - 1 {
			create LUT {
				land_unit_id <- "" + lan_unit_b_c at { 0, i };
				landuse_type <- "" + lan_unit_b_c at { 2, i };
				land_suitability <- "" + lan_unit_b_c at { 3, i };
				profit_rate <- lan_unit_b_c at { 4, i };
				b_c_rate <- lan_unit_b_c at { 5, i };
			}

		}

	}
	
}

species River {
	int segmen_id <-0; 
	rgb color <- rgb('yellow');
	action setColour{
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
			if landuse_type = "veg" {
				 production_ha <- production_ha_riz;
			} else {
				if landuse_type = "coco_cacao" {
					 production_ha <- production_ha_vegatable;
				} else {
					 production_ha <- production_ha_crevette;
				}

			}

			product <- production_ha * terrain / 10000;
			if landuse_type = "shrp" {
				produition_total_crevette <- produition_total_crevette + product;
			}

			if landuse_type = "rice" {
				total_rice_production <- total_rice_production + product;
			}

			if landuse_type = "veg" {
				production_total_vegatable <- production_total_vegatable + product;
			}

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

		}

}

species LUT {
	string land_unit_id <- "";
	string landuse_type <- "";
	int land_suitability <- 4;  // 4 is not suitable; 1 is the most suitable
	float profit_rate <- 0;
	float b_c_rate <- 0;
}

species Proprietaire { // owner of the land
		Parcel monParcel <- nil;
		float revenue <- 0.0;
		float argent_min_lavie <- 3000; // +rnd (20);
 		reflex changement {
			do change_landuse_type_base_on_benifit_cost;
			
			do calculate_area;
		}
		action calculate_area {
			ask monParcel{
				if self.landuse_type ="shrp"{
					area_crevette_ha <-  area_crevette_ha+  self.terrain ;	
				}
				if self.landuse_type ="rice"{
					area_rice_ha <- area_rice_ha + self.terrain ;	
				}
				if self.landuse_type ="veg"{
					area_vegatable_ha <- area_vegatable_ha + self.terrain ;	
				}
				if self.landuse_type ="coco_cacao"{
					area_cocotier_ha <- area_cocotier_ha + self.terrain ;	
				}
			
			}
		}
		action change_landuse_type_base_on_benifit_cost {

			// If there are multiple types of adaptive supplies, select one of those adaptive supplies.
			ask monParcel{
				//self.landuse_type<-"coco_cacao";
				//list aLUT <- LUT where (each.land_unit_id = ""+ self.land_unit); // land_unit la cua thua dat
				//write aLUT as list;
				int Thichghitot <- 9999;
				int tmp_b_c_rate <-0;
				int tmp_profit_rate <-0;
				
				//write("aLUT length: " + aLUT + length(aLUT));
//				ask aLUT {
//					write("land_suitability: " + land_suitability);
//				}
////				ask aLUT{
//					// tim cap thich nghi cao nhat
//					if (land_suitability <= Thichghitot )and (land_suitability<=3) and (myself.landuse_type != self.landuse_type) {
//						//if (profit_rate> tmp_profit_rate){
//							if (b_c_rate > tmp_b_c_rate ){
//							//tmp_profit_rate <- profit_rate;
//							tmp_b_c_rate<- b_c_rate;
//							Thichghitot <- land_suitability;
//							myself.landuse_type<-""+ self.landuse_type;  // trong vong lap ask, self; myself doi tuong ngoai vongf lap ask
//						}
//						 
//					}
//				}
//				loop lut over: aLUT {
//					write(lut);
//				}
				
			}	
			ask target: monParcel {
				do setColor;
			}

	
		}

	
 // calculer les revenu du proprietaire 
 action calculRevenue {
			if monParcel.landuse_type = "rice" {
				revenue <- monParcel.product * rice_price;
			} else {
				if monParcel.landuse_type = "veg" {
					revenue <- monParcel.product * vegatable_price;
				}
			}

		} //calculRevenue 

	} 

experiment RunMe type: gui {
	output {
		display RiceSystem {
			species Parcel;
			species River;
		}
		
		display graphique {
			chart name: 'Stock global' type: series background: rgb('white') {
				//data 'crevette' value: produition_total_crevette color: rgb('red');
				data 'rice' value: total_rice_production color: rgb('yellow');
				//data 'vegatable' value: produition_total_vegatable color: rgb('green');
			}

		}
	}
}