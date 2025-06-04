/**
* Name: pestHunting
* Based on the internal empty template. 
* Author: rattanak
* Tags: farmer
*/


model pestHunting

global {
	rgb HEALTHY_COLOR const: true <- #green;
	rgb SLIGHTLY_DIMAGE_COLOR const: true <- #whitesmoke;
	rgb HEAVY_DIMAGE_COLOR const: true <- #pink;
//	float max_carrying_capacity <- 10.0;
	int number_of_pest <- 0; // first step should be 0
	int number_of_parasitoids <- 25;
	int number_of_predator <- 7;
	float step <- 6 #h;
	float hour <- 0.0;
	int day <- 0;
	int circle <- 0;
	int num_pest_eaten_by_predator <- 0;
	int num_pest_eaten_by_parasitoid <- 0;
	
	// info init
	float normal_survival_pesticide_pest <- 0.3;
	float normal_survival_pesticide_parasitoid <- 0.3;
	float normal_survival_pesticide_predator <- 0.5;
	float normal_production_rate_pest <- 1.34;
	float normal_production_rate_pesticide_pest <- 1.6;
	
	float resistance_survival_pesticide_pest <- 1.0;
	float resistance_survival_pesticide_parasitoid <- 0.4;
	float resistance_survival_pesticide_predator <- 0.5;
	float resistance_reproduction_rate_pesticide_pest <- 1.8;
	float resistance_reproduction_pest <- 1.34;
	
	bool is_farmer_decided <- false;
	list<int> treatments <- [];
	
	// need to find
	float pest_non_resistant <- 0.0;
	float predation_rate <- 0.0;
	float pest_resistant <- 0.0;
	list<float> pest_resistants <- [];
	list<float> predation_rates <- [];
	list<float> pest_non_resistants <- [];
	
	init {
		create Pest  number: number_of_pest {
			
		}
		
		create Parasitoid number: number_of_parasitoids {
			
		}
		
		create Predator number: number_of_predator {
			
		}
	}
	
	reflex check_date_time {
		hour <- hour + (step / 3600); // second to hour
//		write(hour);
		if (hour mod 24 = 0) {
			day +<- int(hour / 24);
			write("day: " + day);
			if (day mod 7 = 0) { // weekly
				circle <- circle + 1;
				is_farmer_decided <- false;
//				write("cirlce: " + circle);
			}
		}
	}
	
	reflex stop_experiment when: circle = 13 {
		write("Rice harvested, stop experiment.");
   		do pause;
	}
	
	int get_total_prev_treatment {
		int totoal_prev_treatment <- 0;
		loop i from: 0 to: length(treatments) - 2 {
			totoal_prev_treatment <- totoal_prev_treatment + treatments[i];
		}
			
		return totoal_prev_treatment;
	}
	
	action update_pest_non_resistant_and_relevant_fields {
		int total_pest_eaten <- num_pest_eaten_by_predator + num_pest_eaten_by_parasitoid;
		if (circle < 2) {
			predation_rate <- number_of_pest = 0 ? 0 : (total_pest_eaten / number_of_pest);
			add predation_rate to: predation_rates;
			add 0.0 to: pest_non_resistants;
		}
		else if (circle = 2) {
			pest_non_resistant <- 198.0;
			add pest_non_resistant to: pest_non_resistants;
			predation_rate <- number_of_pest = 0 ? 0 : (total_pest_eaten / number_of_pest);
			add predation_rate to: predation_rates;
		}
		else if (circle > 2) {
			// update predation_rate and add to a list
			predation_rate <- number_of_pest = 0 ? 0 : (total_pest_eaten / number_of_pest);
			add predation_rate to: predation_rates;
			int prev_treatment <- treatments[length(treatments) - 2];
			int sum_of_prev_treatment <- 0;
			loop i from: 0 to: length(treatments) - 2 {
				sum_of_prev_treatment <- sum_of_prev_treatment + treatments[i];
			}
			pest_non_resistant <- pest_non_resistant * (1 - predation_rate) * (sum_of_prev_treatment = 0 ? normal_production_rate_pest : normal_production_rate_pesticide_pest) * (prev_treatment = 1 ? normal_survival_pesticide_pest : 1) + 9.8;
			add pest_non_resistant to: pest_non_resistants;
		}
	}
	
	action update_pest_resistant {
		if (circle < 2) {
			pest_resistant <- 0.0;
			add pest_resistant to: pest_resistants;
		}
		if (circle = 2) {
			pest_resistant <- 2.0;
			add pest_resistant to: pest_resistants;
		} else if (circle > 2) {
			// TODO: pest resistant list
			pest_resistant <- pest_resistant * (1 - predation_rates[length(predation_rates)-2]) * (get_total_prev_treatment() > 1 ? resistance_reproduction_rate_pesticide_pest : resistance_reproduction_pest) + 0.2;
			// add pest resistant to list
			add pest_resistant to: pest_resistants; 
		}
	}
	
	action update_pest_population {
		number_of_pest <- int(pest_resistants[length(pest_resistants) - 1] + pest_non_resistants[length(pest_non_resistants) - 1]);
	}
	
	reflex check {
//		Parasitoid select (each.pest_eaten !=0);
		//write("eatten: " + num_pest_eaten_by_predator + " eaten by parasitoid: " + num_pest_eaten_by_parasitoid);
		write("pest_non_resistant: " + pest_non_resistants);
		write("pest_resistants: " + pest_resistants);
		write("total_of_pest: " + number_of_pest);
	}
	
	reflex farmer_decision_to_treament when: !is_farmer_decided {
		if (number_of_pest > 30) {
			write("Farmer decided to spray the insecticide on crop (mark as 1).");
			add 1 to: treatments;
			//Todo: check farmer decision
			do update_pest_non_resistant_and_relevant_fields;
			do update_pest_resistant;
			do update_pest_population;
			// push to list to check latter
		} else {
			write("Farmer decided not to spray");
			add 0 to: treatments;
			do update_pest_non_resistant_and_relevant_fields;
			do update_pest_resistant;
			do update_pest_population;
		}
		is_farmer_decided <- true;
		//write("treatment list: " + treatments);
	}
	
}

grid rice_grid width: 30 height: 30 neighbors: 8  {
//	rgb color <- #blue;
//	float carrying_capacity;
//	float biomass;
	int color_value <- 0;
	rgb color <- #green;
	
	init {
//		carrying_capacity <- max_carrying_capacity;
//		biomass <- rnd(0, carrying_capacity);
	}
	
//	aspect rice_crop {
//	//		draw self color:rgb(0, biomass*20, 0);
////		draw self color: rgb(0, 255 * biomass / max_carrying_capacity, 0) lines: #black;
//		draw self color: color;
//	}
	
	aspect update_color {
		if (color_value = 0) {
			color <- HEALTHY_COLOR;
		} else if (color_value = 1) {
			color <- SLIGHTLY_DIMAGE_COLOR;
		} else if (color_value = 2) {
			color <- HEAVY_DIMAGE_COLOR;
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
	
	reflex eat {
		list<Insect> insectList <- agents_overlapping(self) of_species Pest;
		loop p over: insectList {
			pest_eaten <- pest_eaten + 1;
			num_pest_eaten_by_parasitoid <- num_pest_eaten_by_parasitoid + 1;
			ask p {
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
	
	reflex eat {
		list<Insect> insectList <- agents_overlapping(self) of_species Pest;
		loop p over: insectList {
			pest_eaten <- pest_eaten + 1;
			num_pest_eaten_by_predator <- num_pest_eaten_by_predator + 1;
			ask p {
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
		write("circle: " + circle);
	}
}

experiment Experiment type: gui{
	output {
		display riceFeild type: java2D{
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			species Farmer;
		}
	}
}

