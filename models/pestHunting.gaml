/**
* Name: pestHunting
* Based on the internal empty template. 
* Author: rattanak
* Tags: farmer
*/


model pestHunting

global {
	rgb HEALTHY_COLOR <- #green;
	rgb SLIGHTLY_DIMAGE_COLOR <- #whitesmoke;
	rgb HEAVY_DIMAGE_COLOR <- #pink;
//	float max_carrying_capacity <- 10.0;
	int number_of_pest <- 100; // first step should be 0
	int number_of_parasitoids <- 25;
	int number_of_predator <- 7;
	float step <- 6 #h;
	float hour <- 0.0;
	int day <- 0;
	int circle <- 0;
	int num_pest_eaten_by_predator <- 0;
	int num_pest_eaten_by_parasitoid <- 0;
	int pest_non_resistant <- 0;
	float predation_rate <- 0.0;
	
	// info init
	float normal_survival_pesticide_pest <- 0.3;
	float normal_survival_pesticide_parasitoid <- 0.3;
	float normal_survival_pesticide_predator <- 0.5;
	
	float resistance_survival_pesticide_pest <- 1.0;
	float resistance_survival_pesticide_parasitoid <- 0.4;
	float resistance_survival_pesticide_predator <- 0.5;
	bool is_farmer_decided <- false;
	
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
			if (day mod 8 = 0) {
				circle <- circle + 1;
//				write("cirlce: " + circle);
			}
		}
	}
	
	reflex update_pest_non_resistant {
		if (circle > 1) {
			int total_pest_eaten <- num_pest_eaten_by_predator + num_pest_eaten_by_parasitoid;
			predation_rate <- number_of_pest = 0 ? 0 : (total_pest_eaten / number_of_pest);
			//pest_non_resistant <- 0;
		}
	}
	
	reflex check {
//		Parasitoid select (each.pest_eaten !=0);
		write("eatten: " + num_pest_eaten_by_predator + " eaten by parasitoid: " + num_pest_eaten_by_parasitoid);
	}
	
	reflex farmer_decision_to_treament when: !is_farmer_decided {
		if (number_of_pest > 30) {
			//Todo: check farmer decision
		}
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

