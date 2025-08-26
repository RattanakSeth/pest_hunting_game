/**
* Name: pestHuntingthirdmodel
* Based on the internal empty template. 
* Author: rattanak
* A grid is field of farmer with a hectar
* A big to small grid with default 100 farmer
* Tags: A grid a farmer
*/


model pestHuntingthirdmodel

global {
	rgb PARASITOID_COLOR const: true <- #black;
	rgb PREDATOR_COLOR const: true <- #violet;
	rgb PEST_COLOR const: true <- #red;
	string NONE const: true <- 'none';//["none","all","second week"]
	string ALL_WEEK const: true <- 'All weeks';
	string ONLY_1ST_WEEK const: true <- 'Only 1st week';
	string ONLY_2ND_WEEK const: true <- 'Only 2nd week';
	string ONLY_3RD_WEEK const: true <- 'Only 3rd week';
	string ONLY_4TH_WEEK const: true <- 'Only 4th week';
	string ONLY_5TH_WEEK const: true <- 'Only 5th week';
	string ONLY_6TH_WEEK const: true <- 'Only 6th week';
	string ONLY_7TH_WEEK const: true <- 'Only 7th week';
	string ONLY_8TH_WEEK const: true <- 'Only 8th week';
	string ONLY_9TH_WEEK const: true <- 'Only 9th week';
	string ONLY_10TH_WEEK const: true <- 'Only 10th week';
	string ONLY_11TH_WEEK const: true <- 'Only 11th week';
	
	
	//	float max_carrying_capacity <- 10.0;
	int number_of_pest <- 0; // first step should be 0

	float step <-  12#hour;//1#week;
	geometry shape <- square(1000);
	float hour <- 0;
	int day <- 0;
	int cycle_count <- 0; // cycle count
	int cycle <- 0;
	int per_cycle_count <- int(24 / (step/3600) * 7); // 1 week
	
	// initialise variable
	// parasitoid
	float normal_survival_pesticide_parasitoid const: true <- 0.3;
	float normal_consumption_rate_parasitoid const: true<- 1.1;
	float normal_reproduction_rate_parasitoid const: true <- 1.25;
	float resistance_survival_pesticide_parasitoid const: true <- 0.4;
	// pest
	float normal_survival_pesticide_pest const: true <- 0.3;
	float normal_production_rate_pest const: true <- 1.343570058;
	float normal_production_rate_pesticide_pest const: true <- 1.6;
	float resistance_survival_pesticide_pest const: true <- 1.0;
	float resistance_reproduction_rate_pesticide_pest const: true <- 1.8;
	float resistance_reproduction_pest const: true <- 1.34;
	// predator
	float normal_survival_pesticides_predator const: true <- 0.5;
	float normal_reproduction_rate_predator const: true <- 1.1;
	float normal_consumption_rate_predator const: true <- 2.5;
	float resistance_survival_pesticide_predator const: true <- 0.5;
	
	bool is_farmer_decided <- false;
	int all_farmer_decided <- 0;
	
	// Input params
	int rice_field_width <- 10 min: 10;
	int rice_field_height <- 10 min: 10;
	int number_of_parasitoid <- 25 min: 25;
	int number_of_predator <- 7 min: 7;
	
	// In between treatment store
	list treatment_areas <- [];
	
	// UI Initialise
	
	// Experiment variable
	bool is_interacted <- true;
	bool is_spray_all_time <- true;
	bool is_batch_experiment <- false;
	string spray;
	int num_paddy_field <- 0;
	
	// new variable
	float perceipt_radius <- 20.0;
	
	init {
		// initial variable
		//write("cycle: " + cycle);
		create RicePaddy number: 1 {
			paddyField <- one_of(PaddyField where (each.is_free));
			if (paddyField = nil) {
				paddyField <- one_of(PaddyField);
			}
			location <- paddyField.location;
			paddyField.is_free <- false;
			paddyField.ricePaddy <- self;
			id <- paddyField.index;
			write("init: " + id);
			
			create Pest  number: number_of_pest returns: listPest {
				cell <- myself.paddyField;
				location <- any_location_in(cell.shape);//paddyField.location;
				paddyFieldId <- myself.id;
			}
			create Parasitoid number: number_of_parasitoid returns: listParasitoid {
				cell <- myself.paddyField;
				location <- any_location_in(cell.shape);//paddyField.location;
				paddyFieldId <- myself.id;
			}
			create Predator number: number_of_predator returns: listPredator {
				cell <- myself.paddyField;
				location <- any_location_in(cell.shape);
				paddyFieldId <- myself.id;
			}
			//cell1 cell;
			create Farmer{
				id <- myself.index;
				cell <- myself.paddyField;
				location <- cell.location;
				myself.farmer <- self;
				paddy <- myself;
			}
			
			lstPest <- list<agent>(listPest);
			lstParasitoid <- list<agent>(listParasitoid);
			lstPredator <- list<agent>(listPredator);
			//write("list parasitoid: " + lst + length(lst));
			
//			list para <- Parasitoid where (each.paddyField.index = self.paddyField.index);
//			write(para);
		}
		create RiceMonitor;
	}
	
	reflex check_date_time {
		hour <- hour + (step / 3600); // second to hour
		write("hours: " + hour);
		if (hour mod 24 = 0) {
			day <- int(hour/24);//day + 1;//int(hour / 24);
			write("day: " + day);
			if (day mod 8 = 0) { // weekly
				cycle_count <- cycle_count + 1;
				write("cycle count increase: " + cycle_count);
				//is_farmer_decided <- false;
				//do update_pests_were_eaten_by;
				do renewVariable;
			}
		}
		//cycle_count <- cycle_count + 1;
		//is_farmer_decided <- false;
		//do renewVariable;
	}
	
	action renewVariable {
		all_farmer_decided <- 0;
	}
	
	
}

grid PaddyField width: 2 height: 2 {
		rgb color <- #green;
//		float cell_value min: 0.0 max: 3.0 <- 3.0;
		bool is_free <- true;
		Farmer farmer;
		RicePaddy ricePaddy;
//		RicePaddy ricePaddy update: RicePaddy {
//			id <- 1;
//		}
//		geometry shape <- square(10);
		init {
			//write()
//			write("write paddy: " + shape.width);
//			write(shape);
			
			//create RicePaddy number: 1 with: (location: {self.grid_x,self.grid_y}, id: index);
			/*create RicePaddy {
				write("index: " + index);
				id <- myself.index;
				paddyField <- myself;
				location <- paddyField.location;
//				location <- {myself.grid_x,myself.grid_y};
			}*/
		}
		
		
//		list get_insects_inside {
//			return agents_inside(self);//(Predator + Pest + Predator) inside self;
//			//return (Predator + Pest + Predator) inside(self);
//		}
		
//		action change_color {
//			if (cell_value = 3.0) {
//				// Dark Green Background
//				color <- rgb(0, 112, 48);
//			} else if (cell_value = 2.0) {
//				// Light Green Background
//				color <- rgb(198, 239, 206);
//			} else if (cell_value = 1.0) {
//				// Bright Yellow Background
//				color <- rgb(255, 255, 0);
//			} else if (cell_value = 0.0) {
//				// Brown Background #583927, LEGO Brick
//				color <- rgb(88, 57, 39);
//			}
//		}
}

	

species RicePaddy {
	int id;
	PaddyField paddyField;
	Farmer farmer;
	list<Parasitoid> lstParasitoid;
	list<Predator> lstPredator;
	list<Pest> lstPest;
	
	string filePath <- "../results/paddyField/id_";
	//geometry shape <- square(10);
	// need to find of each cycle_count
	//float pest_non_resistant <- 0.0;
	float predation_rate <- 0.0;
	//float pest_resistant <- 0.0;
	list<float> pest_resistants <- [];
	list<float> predation_rates <- [];
	list<float> pest_non_resistants <- [];
	//list<int> pest_population <- []; // pest_total
	list<float> potential_pests_eaten_by_parasitoids <- []; // maximum amount of pest eaten by parasitoids
	list<float> potential_pests_eaten_by_predators <- []; // maximum of predators to eat pest
	list<float> total_pest_eaten <- []; // program start need this
	list<float> pests_total <- []; // program start need this
	list<float> predators <- [];
	list<float> parasitoids <- [];
	list<float> total_potential_pests_eaten <- [];
	list<float> field_cases <- [];
	list<float> dynamic_yields <- [];
	list<float> potential_yields <- [];
	list<float> real_yield_in_tons <- [];
	list<float> max_dynamic_yields <- [];
	list<float> remove_sticky_notes <- [];
	list<float> potential_parasitoids <- [];
	list<float> potential_predators <- [];
	
	list<int> treatments <- [];
	
	// variable renew to zero for every each cycle_count count
	int num_pest_eaten_by_predator <- 0;
	int num_pest_eaten_by_parasitoid <- 0;
	
//	grid cell1 width: 10 height: 10;
	//grid rice_grid border: #yellow;
	
	init {
		//write("RicePaddy: " + id + filePath);
		//test
//		PaddyField tmpCell <- one_of(PaddyField where(each.is_free = true));
//		if (tmpCell != nil) {
//			paddyField <- tmpCell;
//		} else {
//			paddyField <- one_of(paddyField);
//		}
//		location <- paddyField.location;
//		paddyField.is_free <- false;
		
		//paddyField <- one_of(PaddyField);
		//write("paddy: " + paddyField);
		
		do initialise_variable;
		
//		grid rice_cell;
		
//		write("inner cell: " + self.InnerCell);
		//grid rc border: #lightgray;
		//rc test;
		//write(cell1);
	}
	
	reflex checkCycleCrop when: every(per_cycle_count#cycles){
		do renew_variable_each_cycle_count;
		write("farmer: " + farmer.id + " : week" + cycle_count);
		write("Pest total: " + pests_total);
//		write("paddyField: " + paddyField.index);
//		write("ricepaddy: " + id);
//		write("lstParasitoid: " + self.lstParasitoid);
	}
	
	action initialise_variable {
		// only cycle_count one
		write("start initialise vairable now");
		write("weeks: " + cycle_count);
//		ask rice_grid {
//			do change_color;
//		}
		add 0 to: treatments;
		do define_field_case;
		do sequential_var_calc;
		do check;
		// no treatment
		//add [] to: treatment_areas;
	}
	
	action store_data_to_csv {
		write("file path: " + filePath + id);
		string calc_file <- filePath + id + "/calc.csv"; 
		if file_exists(calc_file){ 
			write "File exists in the computer";
			bool delete_file_ok <- delete_file(calc_file);
            write "Deleted file: " + delete_file_ok;
		}

		// stick to the excel
		loop i from: 0 to: 12 {
			int cycles <- i;
			int pest_total <- round(pests_total[i]);
			float pestResistant <- pest_resistants[i] with_precision 1;
			int pestNonResistant <- round(pest_non_resistants[i]);
			int potentialParasitoid <- round(potential_parasitoids[i]);
			int parasitoid <- round(parasitoids[i]);
			int potentialPestEatenByParasitoid <- round(potential_pests_eaten_by_parasitoids[i]);
			int potentialPredator <- round(potential_predators[i]);
			int predator <- round(predators[i]);
			int potentialPestEatenByPredator <- round(potential_pests_eaten_by_predators[i]);
			int totalPotentialPestEaten <- round(total_potential_pests_eaten[i]);
			int totalPestEaten <- round(total_pest_eaten[i]);
			float predationRate <- predation_rates[i] with_precision 2;
			int fieldCase <- round(field_cases[i]);
			float dynamicYield <- dynamic_yields[i] with_precision 2;
			float potentialYield <- potential_yields[i] with_precision 2;
			float realYield <- real_yield_in_tons[i] with_precision 2;
			int treatment <- treatments[i];
			float maxDynamicYield <- max_dynamic_yields[i] with_precision 7;
			
			// test
			//float stickyToRemove <- remove_sticky_notes[i] with_precision 2;
			
			save [cycles, pest_total, pestResistant, pestNonResistant, potentialParasitoid, 
				parasitoid, potentialPestEatenByParasitoid, potentialPredator, predator, potentialPestEatenByPredator,
				totalPotentialPestEaten, totalPestEaten, predationRate, fieldCase, dynamicYield, potentialYield,
				realYield, treatment, maxDynamicYield //stickyToRemove
			] to: calc_file format:"csv" rewrite: false;
		}
	}
	
	action storeBPH {
		string BPH_path <- filePath + id + "/BPH.csv";
		if file_exists(BPH_path){ 
			write "File exists in the computer";
			bool delete_file_ok <- delete_file(BPH_path);
            write "Deleted file: " + delete_file_ok;
		}
		
		loop i from: 0 to: 12 {
			int week <- i;
			float stickyNoteNeedToRemove <- remove_sticky_notes[i] with_precision 2;
			save [week, stickyNoteNeedToRemove] to: BPH_path format: "csv" rewrite: false;
		}
	}
	
	action calc_potential_parasitoid {
		if (cycle_count = 0) {
			add number_of_parasitoid to: potential_parasitoids;
		} else {
			add (parasitoids[length(parasitoids) - 2] * normal_reproduction_rate_parasitoid) to: potential_parasitoids;
		}
		//write("potential parasitoid: " + potential_parasitoids);
	}
	
	action calc_potential_predator {
		if (cycle_count = 0) {
			add number_of_predator to: potential_predators;
		} else {
			add (predators[length(predators) - 2] * normal_reproduction_rate_predator) to: potential_predators;
		}
	}
	
	action define_field_case {
		// use the dynamic field case base on rice grid
		add rice_field_width * rice_field_height * 3 to: field_cases;
		write("field cases: " + field_cases);
	}
	
	action calc_dynamic_yield {
		if (cycle_count = 12) {
			add dynamic_yields[length(dynamic_yields) - 1] to: dynamic_yields; // copy previous to last cycle
		} else {
			add (cycle_count * 100/11) to: dynamic_yields;
		}
	}
	
	action calc_field_case {
		if (cycle_count < 1) {return;}
		float prev_field_case <- field_cases[length(field_cases) - 1];
		// need 15 pests to eat one sticky note or yield
		add (prev_field_case - (pests_total[length(pests_total)-1]/15)) > 0 ? (prev_field_case - (pests_total[length(pests_total)-1]/15)) : 0 to: field_cases;
	}
	
	int get_total_prev_treatment {
		int total_prev_treatment <- 0;
		loop i from: 0 to: length(treatments) - 1 {
			total_prev_treatment <- total_prev_treatment + treatments[i];
		}
			
		return total_prev_treatment;
	}
	
	int get_prev_treatment {
		// because treatment was applied after the calculation
		return treatments[cycle_count];
	}
	
	action update_predators {
		if (cycle_count = 0 ) {
			add number_of_predator to: predators;
		}
		if (cycle_count > 0) {
			//write("cycle: " + cycle_count + "predator: " + (treatments[length(treatments) - 2] = 1 ? normal_survival_pesticides_predator : 1) * predators[length(predators) - 1] * normal_reproduction_rate_predator);
			float num_predator <- ((treatments[length(treatments) - 1] = 1 ? normal_survival_pesticides_predator : 1) * predators[length(predators) - 1] * normal_reproduction_rate_predator);
			add num_predator to: predators;
			//create Predator number: number_of_predator;
			int update_predator_amount <- round(predators[length(predators) - 1]) - round(predators[length(predators) - 2]);
			if (update_predator_amount > 0) {
				create Predator number: update_predator_amount {
					cell <- myself.paddyField;
					location <- any_location_in(cell.shape).location;//paddyField.location;
					//paddyFieldId <- paddyField.index;
				}
			} else if (update_predator_amount < 0) {
//				list<Predator> test <- Predator ;//where(each.paddyField.index = id);
//				
//				write("select predator: " +  one_of(Predator where (each.paddyField.index = self.id)).paddyField.index + " -> " + self.id);
//				write("length of pred: " + length(Predator));
				list<Predator> selectedPredator <- abs(update_predator_amount) among (Predator where(each.cell.index = self.id));
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
		//write("tmp predation rate: " + tmp_predation_rate);
		//addpredation_rates
	}
	
	action update_pest_non_resistant {
		/**
		 * This function uses to update each cycle_count (7 days or a week)
		 */
		if (cycle_count < 2) {
			add 0.0 to: pest_non_resistants;
		}
		else if (cycle_count = 2) {
			add 198.0 to: pest_non_resistants;
		}
		else if (cycle_count > 2) {
			//write("\npest non__resist in week: " + cycle_count);
			float prev_predation_rate <- predation_rates[length(predation_rates) - 1]; // it will calc after this
			int prev_treatment <- treatments[length(treatments) - 1];
			//write("prev_treatment: " + prev_treatment);
			//write("treatments: " + treatments);
			int sum_first_prev_treatment <- treatments[0] + treatments[length(treatments) - 1];
			//write("sum_first_prev_treatment: " + sum_first_prev_treatment);
			float prev_pest_non_resistant <- pest_non_resistants[length(pest_non_resistants) - 1];
			//write("prev_pest_non_resistant: " + prev_pest_non_resistant);
			float pest_non_resistant <- prev_pest_non_resistant * (1 - prev_predation_rate) * (sum_first_prev_treatment = 0 ? normal_production_rate_pest : normal_production_rate_pesticide_pest) * (prev_treatment = 1 ? normal_survival_pesticide_pest : 1) + 9.8;
			add pest_non_resistant to: pest_non_resistants;
			//write("pest_non_resistant: " + pest_non_resistant);
		}
	}
	
	action update_pest_resistant {
		if (cycle_count < 2) {
			float pest_resistant <- 0.0;
			add pest_resistant to: pest_resistants;
		}
		if (cycle_count = 2) {
			float pest_resistant <- 2.0;
			add pest_resistant to: pest_resistants;
		} else if (cycle_count > 2) {
			float prev_pest_resistant <- pest_resistants[length(pest_resistants) - 1];
			float prev_predation_rate <- predation_rates[length(predation_rates) - 1];
			float pest_resistant <- prev_pest_resistant * (1 - prev_predation_rate) * (get_total_prev_treatment() > 1 ? resistance_reproduction_rate_pesticide_pest : resistance_reproduction_pest) + 0.2;
			// add pest resistant to list
			add pest_resistant to: pest_resistants; 
		}
	}
	
	action update_pest_total {
		float num_pest <- (pest_resistants[length(pest_resistants) - 1] + pest_non_resistants[length(pest_non_resistants) - 1]);
		//add number_of_pest to: pest_population; // store in list
		add num_pest to: pests_total;
		//create Pest number: number_of_pest;
		write("cycle count: " + cycle_count + " -> " + pests_total);
		int pest_amount <- round(pests_total[cycle_count]);
		if (cycle_count > 0) {
			pest_amount <- round(pests_total[length(pests_total) - 1]) - round(pests_total[length(pests_total) - 2]);
		}
		
		if (pest_amount > 0) {
			create Pest number: pest_amount {
				cell <- myself.paddyField;
				location <- any_location_in(cell.shape).location;//paddyField.location;
				//paddyFieldId <- paddyField.index;
			}
		} else if (pest_amount < 0) {
			//list<Pest> pest <- Pest where(each.paddyField.id = id);
			list<Pest> selectedPest <- abs(pest_amount) among (Pest where(each.cell.index = self.paddyField.index));
			loop p over: selectedPest {
				ask p {
					do die;
				}
			}
		}
	}
	
	action renew_variable_each_cycle_count {
		num_pest_eaten_by_parasitoid <- 0;
		num_pest_eaten_by_predator <- 0;
	}
	
	action update_potential_pests_eaten_by_predators {
		add (normal_consumption_rate_predator * predators[length(predators) - 1]) to: potential_pests_eaten_by_predators;
	}
	
	action update_potential_pests_eaten_by_parasitoids {
		// maximum eat of parasitoid for each cycle_count count
		add (normal_consumption_rate_parasitoid * parasitoids[length(parasitoids) - 1]) to: potential_pests_eaten_by_parasitoids;
	}
	
	action update_total_potential_pest_eaten {
		// each cycle_count update
		add (potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators) - 1] + potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids) - 1]) to: total_potential_pests_eaten;
	}
	
	action update_total_pest_eaten {
		float tmp_total_potential_pest_eaten <- (potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids) - 1] + potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators) -1]);
		add (tmp_total_potential_pest_eaten < pests_total[length(pests_total) - 1]) ? tmp_total_potential_pest_eaten : pests_total[length(pests_total) - 1] to: total_pest_eaten;
	}
	
	action update_parasitoids {
		if (cycle_count = 0) {
			add number_of_parasitoid to: parasitoids;
		} else {
			float prev_total_potential_pests_eaten <- total_potential_pests_eaten[length(total_potential_pests_eaten)-1];
			float prev_total_pest_eaten <- total_pest_eaten[length(total_pest_eaten) - 1];
			float tmp_parasitoid <- (treatments[length(treatments) - 1] = 1 ? normal_survival_pesticide_parasitoid : 1) * parasitoids[length(parasitoids) - 1] * ((prev_total_potential_pests_eaten = prev_total_pest_eaten) ? normal_reproduction_rate_parasitoid : (((normal_reproduction_rate_parasitoid - 1) * prev_total_pest_eaten / prev_total_potential_pests_eaten) + 1));
			add tmp_parasitoid to: parasitoids;
			int parasitoid_amount <- round(parasitoids[length(parasitoids) - 1]) - round(parasitoids[length(parasitoids) - 2]);
			if (parasitoid_amount > 0) {
				create Parasitoid number: parasitoid_amount {
					cell <- myself.paddyField;
					location <- any_location_in(cell.shape);
				}
			} else if (parasitoid_amount < 0) {
				list<Parasitoid> selectedParasitoid <- abs(parasitoid_amount) among Parasitoid where(each.cell.index = self.paddyField.index);
				loop p over: selectedParasitoid {
					ask p {
						do die;
					}
				}
			}
		}
		
	}
	
	action calc_potential_yield {
		add (field_cases[length(field_cases) - 1] / field_cases[0]) to: potential_yields;
	}
	
	action calc_real_yield_in_tons {
		int begin_field_case <- rice_field_width * rice_field_height * 3;
		add (field_cases[length(field_cases)-1] * dynamic_yields[length(dynamic_yields) - 1] * 5 / (100 * begin_field_case)) to: real_yield_in_tons;
	}
	
	action calc_max_dynamic_yield {
		// 5 tons maximum and 100 is percentage
		add (5 * dynamic_yields[length(dynamic_yields) - 1] / 100) to: max_dynamic_yields;
	}
	
	/*action calc_sticky_notes_need_to_remove {
		if (cycle_count < 1) {
			add field_cases[0] to: remove_sticky_notes;
			return;
		}

		float tmp_remove_rice_yield <- field_cases[length(field_cases) - 1] -  field_cases[length(field_cases) - 2];
		add tmp_remove_rice_yield to: remove_sticky_notes;
		list rice_pest <- shuffle(self.cell) where(each.cell_value > 0); // abs(round(tmp_remove_rice_yield)) among 
		write("num remove sticky note: " + abs(round(tmp_remove_rice_yield)));
		write("rice pest: " + length(rice_pest));
		
		if (abs(round(tmp_remove_rice_yield)) != 0) {
			if (length(rice_pest) > 0) {
				int tmp_remove <- abs(round(tmp_remove_rice_yield));
				write("Start remove grid layer");
				int removedSticky <- 0;
				loop rp over: rice_pest {
					if (tmp_remove = 0) {break;}
					int cellValue <- int(rp.cell_value);
					tmp_remove <- tmp_remove - cellValue;
					write("remaining tmp remove: " + tmp_remove);
					if (tmp_remove < 0) {
						// testing var
						removedSticky <- removedSticky + (cellValue + tmp_remove);
						write("less than zero: " + tmp_remove);
						write("cellvalue - tmp_remove: " + (cellValue + tmp_remove));
						ask rp {
							cell_value <- float(abs(tmp_remove));
							do change_color;
						}
						tmp_remove <- 0;
					} else {
						// testing var
						 removedSticky <- removedSticky + cellValue;
						 write("amount to remove: " + cellValue);
						ask rp {
							cell_value <- 0.0;
							do change_color;
						}
					}
				}
				write("removed sticky: " + removedSticky);
			}
		}
	}*/
	
	action sequential_var_calc{
		// independant var
		do calc_dynamic_yield;
		
		// structure or dependent variables
		// start with predator
		do update_predators;
		do calc_potential_predator;
		do update_potential_pests_eaten_by_predators;
		
		// start with parasitoid
		do update_parasitoids;
		do update_potential_pests_eaten_by_parasitoids;
		do update_total_potential_pest_eaten;
		do calc_potential_parasitoid;
		
		// pest
		do update_pest_non_resistant;
		do update_pest_resistant;
		do update_pest_total;
		do update_total_pest_eaten;
		
		//
		do update_predation_rate;
		
		// result calculation
		do calc_field_case;
		do calc_potential_yield;
		do calc_real_yield_in_tons;
		do calc_max_dynamic_yield;
		//do calc_sticky_notes_need_to_remove;
	}
	
	
	action check{
		/*write("treatments: " + treatments);
		// predator
		write("predator each cycle_count: " + predators);
		write("potential predator: " + potential_predators);
		// parasitoid
		write("parasitoids: " + parasitoids);
		write("potential parasitoid: " + potential_parasitoids);
		
		// pest
		write("pest non resistant: " + pest_non_resistants);
		write("pest resistant: " + pest_resistants);
		
		write("potential pest eaten by parasitoids: " + potential_pests_eaten_by_parasitoids);
		write("potential pest eaten by predators: " + potential_pests_eaten_by_predators);
		write("total potential pest eaten: " + total_potential_pests_eaten);
		write("totoal pest eaten: " + total_pest_eaten);
		*/
//		write("predation rates: " + predation_rates);
//		write("field cases: " + field_cases);
//		write("potential yield: " + potential_yields);
//		write("real yield in tons: " + real_yield_in_tons);
//		write("max dynamic_yield: " + max_dynamic_yields);
		
//		write("potential pest eaten by parasitoids: " + potential_pests_eaten_by_parasitoids[cycle_count]);
//		write("potential pest eaten by predators: " + potential_pests_eaten_by_predators[cycle_count]);
//		write("num_pest_eaten_by_predator: " + num_pest_eaten_by_predator);
//		write("num_pest_eaten_by_parasitoid: " + num_pest_eaten_by_parasitoid);
		
	}
	
	action calc_end_result_and_store {
		float stickyNoteRemaining <- sum(remove_sticky_notes);
		write("sticky note remaining: " + round(stickyNoteRemaining));
		
		float finalYield <- 5 * stickyNoteRemaining / field_cases[0];
		write("Final yield (t/ha): " + finalYield with_precision 2);
		
		// verify sticky note remove for ui only
		do check_last_sticky_note;
		
		// check ui sticky note or grid
//		list<rice_grid> rice_cell <-  rice_grid where(each.cell_value > 0);
//		float cellRemaining <- 0.0;
//		loop rc over: rice_cell {
//			cellRemaining <- cellRemaining + rc.cell_value;
//		}
//		write("remaining cell value: " + cellRemaining);
		
		string crop_yeild_path <- "../results/crop_yield.csv"; 
		if file_exists(crop_yeild_path){ 
			write "File exists in the computer";
			bool delete_file_ok <- delete_file(crop_yeild_path);
            write "Deleted file: " + delete_file_ok;
		}
		
		save [stickyNoteRemaining, finalYield] to: crop_yeild_path format: "csv" rewrite: false;
	}
	
	action check_last_sticky_note {
		float sticky_with_precision <- 0.0;
		int sticky_note_round <- 0;
		loop sticky over: remove_sticky_notes {
			sticky_with_precision <- sticky_with_precision + sticky;
			sticky_note_round <- sticky_note_round + round(sticky);
			//write("sticky: " + sticky);
		}
		//write("sticky with precison and round: " + round(sticky_with_precision));
		//write("sticky note round: " + sticky_note_round);
		
		if (sticky_note_round < round(sticky_with_precision)) {
			// we remove over 1 amount which should added one
			int add_amount <- round(sticky_with_precision) - sticky_note_round;
			write("amount need to add: " + add_amount);
//			if (add_amount <= 3) {
//				list<rice_grid> rice_cell <- rice_grid where(each.cell_value < 3);
//				// amount has only 1 in this case
//				ask rice_cell[0] {
//					cell_value <- float(rice_cell[0].cell_value + add_amount);
//					do change_color;
//				}
//			}
		}
	}
	
	
	reflex record_data when: cycle_count = 12{
		write("store data: " + id);
		do store_data_to_csv;
		//do storeBPH;
		//do calc_end_result_and_store;	
	}
	
	aspect default {
		draw square(1) color: #transparent;
	}
}

//species RiceCrop {
//	// use it in the gird represent as rice on grid
//	int value ;//min: 0 max: 3;// <- 3; // three crop per sigle grid
//	//list<int> treatments <- [0,0,0,0,0,0,0,0,0,0,0,0,0];
//}

species Insect skills: [moving] {
	//Current cell of the agent
	PaddyField cell;
	int paddyFieldId; // no need this anymore
		//rice_grid current_cell;
	//Evacuation cell of the agent
	//rice_grid target_cell;
	//List of the cells already passed by the agents and memorised
	//list<rice_grid> memory;
	float speed <- 1.0;//1.6 #km/#day;
	geometry shape <- square(2);
	point goal;
	bool is_chased <- false;
	
	reflex move { // change to move
		if (goal != nil) {
			do wander speed: speed;
			do goto target: goal speed: speed;
		} else {
			do wander speed: speed;
		}
	}
	
	aspect default {
		draw circle(1) color: #red;
	}
}

species Pest parent:Insect {
	float speed <- 0.2;
	rgb color <- #red;
	geometry shape <- circle(3);
	
	reflex fleeing {
		if (length((cell.ricePaddy.lstPredator where (each != nil and !dead(each) and each distance_to self < perceipt_radius))) > 0) {
			speed <- 1.0;
			is_chased <- true;
			color <- # lime;
			if (goal = nil) {
				agent a <- any(((cell.ricePaddy.lstPest where (each != nil and !dead(each) and !Insect(each).is_chased))));
				if (a != nil and !dead(a)) {
					if(flip(0.5)) {
						goal <- a.location;
					} else {
						goal <- any_location_in(cell.shape);
					}
				} else {
					goal <- any_location_in(cell.shape);
				}
			}
		}
		
		if (goal != nil and self.location distance_to goal < 0.5)
		{
			goal <- nil;
		}

		if (length((cell.ricePaddy.lstPredator where (each != nil and !dead(each))) where (each distance_to self <= perceipt_radius)) = 0)
		{
			is_chased <- false;
			color <- # red;
			speed <- 0.2;
		}
	}
	
	aspect default {
		draw shape color: color;
	}
}

species Parasitoid parent: Insect {
	int pest_eaten <- 0;
	geometry shape <- triangle(4);
	rgb color <- #black;
	
	/*reflex move {
		rice_grid tmp_cell <- shuffle(current_cell.neighbors) first_with (!(empty(Pest inside (each))));
		list pest_on_grid <- agents_overlapping(current_cell); //current_cell overlap Pest;
		if (length(pest_on_grid) = 1) {
			// current cell will be a previous cell
			// in case this grid consists of only one insect then moving will be free cell
			current_cell.is_free <- true;
		}
		if (tmp_cell != nil) {
			//write("not nil, so have pest neighbour. " +  tmp_cell);
			current_cell <- tmp_cell;
			location <- current_cell.location;
			current_cell.is_free <- false;
		} else {
			//write("nil");
			// check other location
			// current_cell now
			current_cell <- one_of(current_cell.neighbors);
			location <- current_cell.location;
			current_cell.is_free <- false;
		}
	}*/
	
	/*reflex eat when: num_pest_eaten_by_parasitoid < potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids)-1] {
		list<Insect> insectList <- agents_overlapping(self) of_species Pest;
		loop p over: insectList {
			if (num_pest_eaten_by_parasitoid = potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids)-1]) {break;}
			pest_eaten <- pest_eaten + 1;
			num_pest_eaten_by_parasitoid <- num_pest_eaten_by_parasitoid + 1;
			ask p {
				number_of_pest <- number_of_pest - 1;
				current_cell.is_free <- true;
				do die;
			}
			
		}
	}*/
	
	aspect default {
		//draw square(1) color: #black;
		draw circle(perceipt_radius) color: #pink wireframe: true;
		draw shape color: color rotate: 90 + heading;
	}
	
}

species Predator parent: Insect {
	//int pest_eaten <- 0;
	geometry shape <- triangle(4);
	rgb color <- #violet;

	/*reflex move {
		rice_grid tmp_cell <- shuffle(current_cell.neighbors) first_with (!(empty(Pest inside (each))));
		//write("current cell: ", tmp_cell);
		if (tmp_cell != nil) {
			//write("not nil, so have pest neighbour. " +  tmp_cell);
			current_cell <- tmp_cell;
			location <- current_cell.location;
			current_cell.is_free <- false;
		} else {
			//write("nil");
			// check other location
			current_cell <- one_of(current_cell.neighbors);
			location <- current_cell.location;
			current_cell.is_free <- false;
		}
	}*/
	
	/*reflex eat when: num_pest_eaten_by_predator < potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators)-1] {
		list<Insect> insectList <- agents_overlapping(self) of_species Pest;
		loop p over: insectList {
			if (num_pest_eaten_by_predator = potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators)-1]) {break;}
			pest_eaten <- pest_eaten + 1;
			num_pest_eaten_by_predator <- num_pest_eaten_by_predator + 1;
			ask p {
				number_of_pest <- number_of_pest - 1;
				current_cell.is_free <- true;
				do die;
			}
		}
	}*/
	
	reflex hunting
	{
		write("list pest: " + cell.ricePaddy.lstPest);
		if (goal = nil)
		{
			let tmp <- (cell.ricePaddy.lstPest where (!dead(each) and each.shape distance_to self.shape < perceipt_radius));
			if (length(tmp) > 0)
			{
				agent a <- first(tmp sort (each.shape distance_to self.shape));
				if (a = nil)
				{
					a <- any((cell.ricePaddy.lstPest where (!dead(each))));
				}

				if (a != nil)
				{
					speed <- 2.0;
					goal <- a.location;
				}

			}

		} else if ((self.location distance_to goal < 0.5))
		{
			ask cell.ricePaddy.lstPest where (!dead(each) and each.location distance_to goal < 0.5)
			{
				do die;
			}

			goal <- nil;
			speed <- 1.0;
		}

	}
	
//	aspect default {
//		draw square(1) color: #violet;
//	}
	aspect default
	{
		draw circle(perceipt_radius) color: # pink wireframe: true;
		draw shape color: color rotate: 90 + heading;
	}
}

species Farmer {
	int id;
	PaddyField cell;
	RicePaddy paddy;
	string decision <- NONE;
	// Farmer in the rice paddy
	
	init {
		write("farmer species init");
	}

	reflex farmer_decision when: (cycle_count > 0 and cycle_count < 13) and every(per_cycle_count#cycles){
			write("\nWeeks: " + cycle_count);
			ask paddy {do sequential_var_calc;}
			switch(decision) {
				match NONE{
					do no_spray;
					break;
				}
				match ALL_WEEK {
					do spray_all_the_time;
					break;
				}
				default {
					do no_spray;
					break;
				} 
			}
			
			ask paddy {do check;}
			//ask world {do get_total_prev_treatment();}
			is_farmer_decided <- true;
			//all_farmer_decided <- all_farmer_decided + 1;
	}
	
//	reflex test  when:every(per_cycle_count#cycles)  {
//		write("test decision");
//	}
	
	action spray_all_the_time {
		if (cycle_count = 0 or cycle_count = 12) {
			add 0 to: paddy.treatments;
		} else {
			add 1 to: paddy.treatments;
		}
		
	}
	
	action no_spray {
		add 0 to: paddy.treatments;
	}
		
}

species RiceMonitor {
	reflex check {
		//write("all farmer decided: " + all_farmer_decided);
	}
	
	reflex stop_experiment when: cycle_count = 12 { 
		write("Rice harvested, stop experiment.");
		ask world {
			do pause;
		}
   		
	}
}

experiment Ex {
	output {
		display Rice type: 3d {
			grid PaddyField border: #lightgray;
			species RicePaddy;
			species Farmer;
			species Pest;
			species Predator;
			species Parasitoid;
//			species multiGrid;
//			species rice_grid;
		}
	}
}


