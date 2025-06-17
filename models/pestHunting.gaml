/**
* Name: pestHunting
* Based on the internal empty template. 
* Author: Rattanak
* Tags: farmer
*/


model pestHunting

global {// TODO: change this in cell tmr
	rgb HEALTHY_COLOR const: true <- rgb(0, 176, 80);
	rgb SLIGHTLY_DIMAGE_COLOR const: true <- rgb(221, 235, 247);
	rgb HEAVY_DIMAGE_COLOR const: true <- rgb(242, 220, 219);
	//	float max_carrying_capacity <- 10.0;
	int number_of_pest <- 0; // first step should be 0
	int number_of_parasitoids <- 25;
	int number_of_predator <- 7;
	float step <- 6 #h;
	float hour <- 0.0;
	int day <- 0;
	int cycle_count <- 0; // cycle count
	int cycle <- 0;
	
	// variable renew to zero for every each cycle_count count
	int num_pest_eaten_by_predator <- 0;
	int num_pest_eaten_by_parasitoid <- 0;
	
	// info init
	// parasitoid
	float normal_survival_pesticide_parasitoid <- 0.3;
	float normal_consumption_rate_parasitoid <- 1.1;
	float normal_reproduction_rate_parasitoid <- 1.25;
	float resistance_survival_pesticide_parasitoid <- 0.4;
	// pest
	float normal_survival_pesticide_pest <- 0.3;
	float normal_production_rate_pest <- 1.34;
	float normal_production_rate_pesticide_pest <- 1.6;
	float resistance_survival_pesticide_pest <- 1.0;
	float resistance_reproduction_rate_pesticide_pest <- 1.8;
	float resistance_reproduction_pest <- 1.34;
	// predator
	float normal_survival_pesticides_predator <- 0.5;
	float normal_reproduction_rate_predator <- 1.1;
	float normal_consumption_rate_predator <- 2.5;
	float resistance_survival_pesticide_predator <- 0.5;
	
	bool is_farmer_decided <- false;
	list<int> treatments <- [];
	
	// need to find of each cycle_count
	float pest_non_resistant <- 0.0;
	float predation_rate <- 0.0;
	float pest_resistant <- 0.0;
	list<float> pest_resistants <- [];
	list<float> predation_rates <- [];
	list<float> pest_non_resistants <- [];
	//list<int> pest_population <- []; // pest_total
	list<int> potential_pests_eaten_by_parasitoids <- []; // maximum amount of pest eaten by parasitoids
	list<int> potential_pests_eaten_by_predators <- []; // maximum of predators to eat pest
	list<int> total_pest_eaten <- []; // program start need this
	list<int> pests_total <- [0]; // program start need this
	list<int> predators <- [7];
	list<int> parasitoids <- [25];
	list<int> total_potential_pests_eaten <- [];
	list<int> field_cases <- [300];
	list<float> dynamic_yields <- [];
	list<float> potential_yields <- [];
	list<float> real_yield_in_tons <- [];
	list<float> max_dynamic_yields <- [];
	list<int> remove_sticky_notes <- [];
	
	init {
		create Pest  number: number_of_pest {
			
		}
		
		create Parasitoid number: number_of_parasitoids {
			
		}
		
		create Predator number: number_of_predator {
			
		}
		
		// initial variable
		do initialise_variable;
		write("cycle: " + cycle);
	}
	
	action initialise_variable {
		// only cycle_count one
		write("start initialise vairable now: ");
		ask rice_grid {
			do change_color;
		}
		//		add parasitoids[0] * normal_consumption_rate_parasitoid to: potential_pests_eaten_by_parasitoids;
		//		add predators[0] * normal_consumption_rate_predator to: potential_pests_eaten_by_predators;
	}
	
	reflex check_date_time {
		hour <- hour + (step / 3600); // second to hour
//		write(hour);
		if (hour mod 24 = 0) {
			day +<- int(hour / 24);
			write("day: " + day);
			if (day mod 7 = 0) { // weekly
				cycle_count <- cycle_count + 1;
//				cycle <- cycle + 1;
				is_farmer_decided <- false;
				//do update_pests_were_eaten_by;
				do renew_variable_each_cycle_count;
				write("\ncycle_count or week: " + cycle_count + '\n');
//				write("cirlce: " + cycle_count);
			}
		}
	}
	
	reflex stop_experiment when: cycle_count = 13 {
		write("Rice harvested, stop experiment.");
   		do pause;
	}
	
	action calc_dynamic_yield {
		add (cycle_count * 100/11) to: dynamic_yields;
	}
	
	action calc_field_case {
		if (cycle_count < 1) {return;}
		int prev_field_case <- field_cases[length(field_cases) - 1];
		add (prev_field_case - (pests_total[length(pests_total)-1]/15)) > 0 ? round(prev_field_case - (pests_total[length(pests_total)-1]/15)) : 0 to: field_cases;
	}
	
	int get_total_prev_treatment {
		int total_prev_treatment <- 0;
		loop i from: 0 to: length(treatments) - 2 {
			total_prev_treatment <- total_prev_treatment + treatments[i];
		}
			
		return total_prev_treatment;
	}
	
	action update_predators {
		if (cycle_count > 0) {
			number_of_predator <- round((treatments[length(treatments) - 2] = 1 ? normal_survival_pesticides_predator : 1) * predators[length(predators) - 1] * normal_reproduction_rate_predator);
			add number_of_predator to: predators;
			//create Predator number: number_of_predator;
			int update_predator_amount <- predators[length(predators) - 1] - predators[length(predators) - 2];
			if (update_predator_amount > 0) {
				create Predator number: update_predator_amount;
			} else if (update_predator_amount < 0) {
				list<Predator> selectedPredator <- abs(update_predator_amount) among Predator;
				loop p over: selectedPredator {
					ask p {
						do die;
					}
				}
			}
		}
	}
	
	action update_predation_rate {
		float tmp_predation_rate <- pests_total[length(pests_total)-1] = 0 ? 0 : (total_pest_eaten[length(total_pest_eaten)-1]/ pests_total[length(pests_total)-1]);
		add tmp_predation_rate to: predation_rates;
		write("tmp predation rate: " + tmp_predation_rate);
		//addpredation_rates
	}
	
	action update_pest_non_resistant_and_relevant_fields {
		/**
		 * This function uses to update each cycle_count (7 days or a week)
		 */
		if (cycle_count < 2) {
//			predation_rate <- (number_of_pest = 0) ? 0 : ((total_pest_eaten[length(total_pest_eaten)-1] / number_of_pest));
//			add predation_rate to: predation_rates;
			add 0.0 to: pest_non_resistants;
		}
		else if (cycle_count = 2) {
			pest_non_resistant <- 198.0;
			add pest_non_resistant to: pest_non_resistants;
//			predation_rate <- number_of_pest = 0 ? 0 : (total_pest_eaten / number_of_pest);
//			add predation_rate to: predation_rates;
		}
		else if (cycle_count > 2) {
			float pev_predation_rate <- predation_rates[length(predation_rates) - 2];
//			write("predation_rate: " + predation_rate);
//			write("predation_rates: " + predation_rates);
			int prev_treatment <- treatments[length(treatments) - 2];
			int sum_first_prev_treatment <- treatments[0] + treatments[length(treatments) - 2];
//			loop i from: 0 to: length(treatments) - 2 {
//				sum_of_prev_treatment <- sum_of_prev_treatment + treatments[i];
//			}
			pest_non_resistant <- pest_non_resistant * (1 - pev_predation_rate) * (sum_first_prev_treatment = 0 ? normal_production_rate_pest : normal_production_rate_pesticide_pest) * (prev_treatment = 1 ? normal_survival_pesticide_pest : 1) + 9.8;
			add pest_non_resistant to: pest_non_resistants;
		}
	}
	
	action update_pest_resistant {
		if (cycle_count < 2) {
			pest_resistant <- 0.0;
			add pest_resistant to: pest_resistants;
		}
		if (cycle_count = 2) {
			pest_resistant <- 2.0;
			add pest_resistant to: pest_resistants;
		} else if (cycle_count > 2) {
			pest_resistant <- pest_resistant * (1 - predation_rates[length(predation_rates)-2]) * (get_total_prev_treatment() > 1 ? resistance_reproduction_rate_pesticide_pest : resistance_reproduction_pest) + 0.2;
			// add pest resistant to list
			add pest_resistant to: pest_resistants; 
		}
	}
	
	action update_pest_total {
		number_of_pest <- int(pest_resistants[length(pest_resistants) - 1] + pest_non_resistants[length(pest_non_resistants) - 1]);
		//add number_of_pest to: pest_population; // store in list
		add number_of_pest to: pests_total;
		//create Pest number: number_of_pest;
		int pest_amount <- pests_total[length(pests_total) - 1] - pests_total[length(pests_total) - 2];
		if (pest_amount > 0) {
			create Pest number: pest_amount;
		} else if (pest_amount < 0) {
			list<Pest> selectedPest <- abs(pest_amount) among Pest;
			loop p over: selectedPest {
				ask p {
					do die;
				}
			}
		}
	}
	
	action update_pests_were_eaten_by {
		// update pest was eaten by to list
		add num_pest_eaten_by_parasitoid to: potential_pests_eaten_by_parasitoids;
		add num_pest_eaten_by_predator to: potential_pests_eaten_by_predators;
		write("pests_eaten_by_parasitoids: " + potential_pests_eaten_by_parasitoids);
		write("pests_eaten_by_predators: " + potential_pests_eaten_by_predators);
	}
	
	action renew_variable_each_cycle_count {
		// this function use for renewing variable to zero every each cycle_count count
		num_pest_eaten_by_parasitoid <- 0;
		num_pest_eaten_by_predator <- 0;
	}
	
	action update_potential_pests_eaten_by_predators {
		add round(normal_consumption_rate_predator * predators[length(predators) - 1]) to: potential_pests_eaten_by_predators;
	}
	
	action update_potential_pests_eaten_by_parasitoids {
		// maximum eat of parasitoid for each cycle_count count
		add round(normal_consumption_rate_parasitoid * parasitoids[length(parasitoids) - 1]) to: potential_pests_eaten_by_parasitoids;
	}
	
	action update_total_potential_pest_eaten {
		// each cycle_count update
		add potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators) - 1] + potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids) - 1] to: total_potential_pests_eaten;
	}
	
	action update_total_pest_eaten {
		int tmp_total_potential_pest_eaten <- potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids) - 1] + potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators) -1];
		add (tmp_total_potential_pest_eaten < pests_total[length(pests_total) - 1]) ? tmp_total_potential_pest_eaten : pests_total[length(pests_total) - 1] to: total_pest_eaten;
	}
	
	action update_parasitoids {
		// first init or cycle_count zero will be 25
		// we treated or sprayed
		if (cycle_count < 1) {return;}
		write("normal_reproduction_rate parasitoid: " + normal_reproduction_rate_parasitoid);
		write("total pest eaten: " + total_pest_eaten[length(total_pest_eaten) - 2]);
		write("total potential pest eaten: " + total_potential_pests_eaten[length(total_potential_pests_eaten) - 2]);

		int tmp_parasitoid <- round((treatments[length(treatments) - 2] = 1 ? normal_survival_pesticide_parasitoid : 1) * parasitoids[length(parasitoids) - 1] * ((total_potential_pests_eaten[length(total_potential_pests_eaten)-1] = total_pest_eaten[length(total_pest_eaten) - 1]) ? normal_reproduction_rate_parasitoid : (((normal_reproduction_rate_parasitoid - 1) * total_pest_eaten[length(total_pest_eaten) - 2] / total_potential_pests_eaten[length(total_potential_pests_eaten) - 2]) + 1)));
		add tmp_parasitoid to: parasitoids;
		int parasitoid_amount <- parasitoids[length(parasitoids) - 1] - parasitoids[length(parasitoids) - 2];
		if (parasitoid_amount > 0) {
			create Parasitoid number: parasitoid_amount;
		} else if (parasitoid_amount < 0) {
			list<Parasitoid> selectedParasitoid <- abs(parasitoid_amount) among Parasitoid;
			loop p over: selectedParasitoid {
				ask p {
					do die;
				}
			}
		}
//		create Parasitoid number: tmp_parasitoid;
		
		write("number of parasitoid: " + tmp_parasitoid);
		write("number of test length: " + length(Parasitoid));
		write("number of parasitoids: " + parasitoids);
		//add tmp_parasitoid to: parasitoids;
	}
	
	action calc_potential_yield {
		add field_cases[length(field_cases) - 1] / 300 to: potential_yields;
	}
	
	action calc_real_yield_in_tons {
		add field_cases[length(field_cases)-1] * dynamic_yields[length(dynamic_yields) - 1] * 5 / (100 * 300) to: real_yield_in_tons;
	}
	
	action calc_max_dynamic_yield {
		add 5 * dynamic_yields[length(dynamic_yields) - 1] / 100 to: max_dynamic_yields;
	}
	
	action calc_sticky_notes_need_to_remove {
		if (cycle_count < 1) {return;}
		int tmp_remove_rice_yield <- field_cases[length(field_cases) - 1] -  field_cases[length(field_cases) - 2];
		add tmp_remove_rice_yield to: remove_sticky_notes;
		list<rice_grid> rice_pest <- rice_grid where(length(Pest) > 0 and each.cell_value > 0);//select rice_grid where(each.)
		write("tmp remove sticky note: " + tmp_remove_rice_yield);
		write("rice pest: " + rice_pest);
		if (abs(tmp_remove_rice_yield) != 0) {
			if (length(rice_pest) > 0) {
				float tmp_remove <- float(abs(tmp_remove_rice_yield));
				loop rp over: rice_pest {
					if (tmp_remove = 0.0) {break;}
					float cellValue <- rp.cell_value;
					tmp_remove <- tmp_remove - cellValue;
					
					if (tmp_remove < 0) {
						ask rp {
							cell_value <- abs(tmp_remove);
							do change_color;
						}
						tmp_remove <- 0.0;
					} else {
						ask rp {
							cell_value <- 0.0;
							do change_color;
						}
					}
//					write("rp: " + cellValue);
				}
			}
		}
		
		
		// ask rice grid to remove sticky notes
		
//		ask rice_grid {
//			
//		}
	}
	
	reflex farmer_decision_to_treatment when: !is_farmer_decided {
		write("cycle_count: " + cycle_count);
		/*if (number_of_pest > 30) {
			write("Farmer decided to spray on crop (mark as 1).");
			add 1 to: treatments;
			write("treatments: " + treatments);
		} else {
			write("Farmer decided not to spray");
			add 0 to: treatments;
			write("treatments: " + treatments);
		}*/
		// test with apply all treatment
		if (cycle_count = 0 or cycle_count = 13) {
			add 0 to: treatments;
		} else {
			add 1 to: treatments;
		}
		// independant var
		do calc_dynamic_yield;
		// structure or dependent variables
		do update_predators;
		do update_potential_pests_eaten_by_predators;
		do update_potential_pests_eaten_by_parasitoids;
		do update_total_potential_pest_eaten;
		do update_total_pest_eaten;
		do update_parasitoids;
		do update_pest_non_resistant_and_relevant_fields;
		do update_pest_resistant;
		do update_pest_total;
		do update_predation_rate;
		do calc_field_case;
		do calc_potential_yield;
		do calc_real_yield_in_tons;
		do calc_max_dynamic_yield;
		do calc_sticky_notes_need_to_remove;
		is_farmer_decided <- true;
		//write("treatment list: " + treatments);
	}
	
	reflex check {
			/*write("potential pest eaten by parasitoids: " + potential_pests_eaten_by_parasitoids);
			write("predator each cycle_count: " + predators);
			write("potential pest eaten by predators: " + potential_pests_eaten_by_predators);
			write("totoal pest eaten: " + total_pest_eaten);
			write("parasitoids: " + parasitoids);
			write("predation rates: " + predation_rates);
			write("field cases: " + field_cases);
			write("potential yield: " + potential_yields);
			write("real yield in tons: " + real_yield_in_tons);
			write("max dynamic_yield: " + max_dynamic_yields);
			write("number of predators: " + length(Predator));
			write("number of parasitoid: " + length(Parasitoid));
			write("number of pest: " + length(Pest));*/
	}
	
}

grid rice_grid width: 10 height: 10 neighbors: 8  { // good to go with 30 x 30
//	rgb color <- #blue;
//	float carrying_capacity;
//	float biomass;
//	int color_value <- 3;
	rgb color <- #green;
	float cell_value min: 0.0 max: 3.0 <- 3.0;
	
	init {
//		carrying_capacity <- max_carrying_capacity;
//		biomass <- rnd(0, carrying_capacity);
	}
	
//	aspect rice_crop {
//	//		draw self color:rgb(0, biomass*20, 0);
////		draw self color: rgb(0, 255 * biomass / max_carrying_capacity, 0) lines: #black;
//		draw self color: color;
//	}
	
//	action update_color {
//		if (color_value = 2) {
//			color <- HEALTHY_COLOR;
//		} else if (color_value = 1) {
//			color <- SLIGHTLY_DIMAGE_COLOR;
//		} else if (color_value = 0) {
//			color <- HEAVY_DIMAGE_COLOR;
//		}
//	}
	
	action change_color {
		if (cell_value = 3) {
			// Dark Green Background
			color <- rgb(0, 112, 48);
		} else if (cell_value = 2) {
			// Light Blue Background
			color <- rgb(221, 235, 247);
		} else if (cell_value <= 1.1 and cell_value <= 2.9) {
			// Medium Blue Background
			color <- rgb(189, 215, 238);
		} else if (cell_value < 1) {
			// Gray Background
			color <- rgb(217, 217, 217);
		} else if (cell_value <= 0.1 and cell_value <= 1.9) {
			// Light Magenta Background
			color <- rgb(242, 220, 219);
		} else if (cell_value > 2.1) {
			// Light Green Background
			color <- rgb(198, 239, 206);
		} else if (cell_value = 1) {
			// Pink Background
			color <- rgb(255, 199, 206);
		}
	}
}

species Insect {
	string type;
	int resistance <- 0;
	rice_grid plot_grid;
	
	init {
		plot_grid <- one_of(rice_grid);
		location <- plot_grid.location;
	}
	
	aspect default {
		draw circle(1) color: #red;
	}
}

species Pest parent:Insect {
	float reproduction_rate <- 1.33;

	reflex move {
		plot_grid <- one_of(plot_grid.neighbors);
		location <- plot_grid.location;
	}
	
	aspect default {
		draw square(1) color: #red;
	}
}

species Parasitoid parent: Insect {
	int pest_eaten <- 0;
	aspect default {
		draw square(1) color: #black;
	}
	
	reflex move {
		plot_grid <- one_of(plot_grid.neighbors);
		location <- plot_grid.location;
	}
	
	reflex eat when: num_pest_eaten_by_parasitoid < potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids)-1] {
		list<Insect> insectList <- agents_overlapping(self) of_species Pest;
		loop p over: insectList {
			pest_eaten <- pest_eaten + 1;
			num_pest_eaten_by_parasitoid <- num_pest_eaten_by_parasitoid + 1;
			ask p {
				number_of_pest <- number_of_pest - 1;
				do die;
			}
			
		}
	}
}

species Predator parent: Insect {
	int pest_eaten <- 0;
	reflex move {
		plot_grid <- one_of(plot_grid.neighbors);
		location <- plot_grid.location;
	}
	
	reflex eat when: num_pest_eaten_by_predator < potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators)-1] {
		list<Insect> insectList <- agents_overlapping(self) of_species Pest;
		loop p over: insectList {
			pest_eaten <- pest_eaten + 1;
			num_pest_eaten_by_predator <- num_pest_eaten_by_predator + 1;
			ask p {
				number_of_pest <- number_of_pest - 1;
				do die;
			}
			
		}
	}
	
	aspect default {
		draw square(1) color: #violet;
	}
}

species Farmer {
	reflex apply_treatment_to_rice_crop {
		write("farmer applay treatment work!");
	}
}

experiment Experiment type: gui{
	output {
		display riceFeild type: java2D{
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			//species Farmer;
		}
		
		// every 28 cycles equal to one cycle count ( a week)
		display plots type: 2d refresh:every(28#cycles){
				chart "Population Dynamics" type: series {
				    data "Pest" value: length(Pest);//[cycle_count, length(Pest)] color: #red;
				    data "Parasitoid" value: length(Parasitoid);//[cycle_count, length(Parasitoid)] color: #blue;
				    data "Predator" value: length(Predator);//[cycle_count, length(Predator)] color: #yellow;
				}
		}
		
//		display crop_yield type: 2d refresh:every(28#cycles){
//				chart "Population Dynamics" type: series {
//				    data "Real Yield (tons)" value: real_yields;//[cycle_count, length(Pest)] color: #red;
//				    data "Parasitoid" value: length(Parasitoid);//[cycle_count, length(Parasitoid)] color: #blue;
//				    data "Predator" value: length(Predator);//[cycle_count, length(Predator)] color: #yellow;
//				}
//
//		}
		
	}
	
}

