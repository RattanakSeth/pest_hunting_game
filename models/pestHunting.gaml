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
	int number_of_pest <- 0;
	int number_of_parasitoids <- 25;
	int number_of_predator <- 7;
	
	init {
		create Pest  number: number_of_pest {
			
		}
		
		create Parasitoid number: number_of_parasitoids {
			
		}
		
		create Predator number: number_of_predator {
			
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
	aspect default {
		draw square(1) color: #red;
	}
}

species Parasitoid parent: Insect {
	aspect default {
		draw square(1) color: #black;
	}
	
	reflex move {
		plot_grid <- one_of(plot_grid.neighbors);
		location <- plot_grid.location;
	}
	
	reflex eat {
		
	}
}

species Predator parent: Insect {
	aspect default {
		draw square(1) color: #violet;
	}
}

experiment Experiment type: gui{
	output {
		display riceFeild type: java2D{
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
		}
	}
}

