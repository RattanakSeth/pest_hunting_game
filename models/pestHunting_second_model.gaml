/**
* Name: pestHuntingsecondmodel
* Make it an agent-based mdoel
* Spray will be a whole field
* a whole grid consists of one hectar of rice which belong to a farmer
* Author: rattanak
* Tags: second model, model improvement v2.0
* Base on research and game formula on the excel file
* Using grid represent as a rice fields
* Separate experiment for consideration senario
*/


model pestHuntingsecondmodel

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
	string TWICE_TREATMENT const: true <- 'Twice treatment';
	
	
	//	float max_carrying_capacity <- 10.0;
	int number_of_pest <- 0; // first step should be 0

	float step <- 1 #week;
	//float hour <- 0.0;
	//int day <- 0;
	int cycle_count <- 0; // cycle count
	int cycle <- 0;
	int per_cycle_count <- int(24 / (step/3600) * 7);
	
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
	float normal_production_rate_pest <- 1.343570058;
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
	
	// Input params
	int rice_field_width <- 10 min: 10;
	int rice_field_height <- 10 min: 10;
	int number_of_parasitoid <- 25 min: 0;
	int number_of_predator <- 7 min: 0;
	int week_pest_come <- 2 min: 0 max: 12;
	
	// In between treatment store
	//list treatment_areas <- [];
	
	// UI Initialise
	bool is_grid_clicked <- false;
	int sticky_to_removed <- 0;
	bool game_is_running <- false; // not use
	//field cell <- field(300,300);
	
	// Experiment variable
	bool is_interacted <- true;
	bool is_spray_all_time <- true;
	bool is_batch_experiment <- false;
	string spray <- ONLY_2ND_WEEK;
	
	// Batch expirement
	list<int> week_to_spray <- [1,2,3,4,5,6,7,8,9,10,11];
	int f_spray <- 2;
	int s_spray <- 4;
	list<int> weeks <- range(1, 12);
	map<point, string> alternatives;
	list<string> alternative_tstr <- ['F1-S2','F1-S3','F1-S4','F1-S5','F1-S6','F1-S7','F1-S8','F1-S9','F1-S10','F1-S11','F1-S12','F2-S3','F2-S4','F2-S5','F2-S6','F2-S7','F2-S8','F2-S9','F2-S10','F2-S11','F2-S12','F3-S4','F3-S5','F3-S6','F3-S7','F3-S8','F3-S9','F3-S10','F3-S11','F3-S12','F4-S5','F4-S6','F4-S7','F4-S8','F4-S9','F4-S10','F4-S11','F4-S12','F5-S6','F5-S7','F5-S8','F5-S9','F5-S10','F5-S11','F5-S12','F6-S7','F6-S8','F6-S9','F6-S10','F6-S11','F6-S12','F7-S8','F7-S9','F7-S10','F7-S11','F7-S12','F8-S9','F8-S10','F8-S11','F8-S12','F9-S10','F9-S11','F9-S12','F10-S11','F10-S12','F11-S12'];
	string opt_alternative;
	//map<list<int, int>, string> alternative;
	//map<int, string> test <- [1::'one', 2::'two'];
	
	
	//bool 
//	geometry shape <- rectangle(20,30);
	init {
		create Pest  number: number_of_pest;
		
		create Parasitoid number: number_of_parasitoid {
		}
		
		create Predator number: number_of_predator {
		}
		
		create Farmer;
		//create HUD;
		// initial variable
		do initialise_variable;
		//write("cycle: " + cycle);
		
		// initial treatment
		//do alternative_twice_treatment;
	}
	
	action alternative_twice_treatment {
		loop first over: weeks {
			loop second over: weeks {
				if (first < second) {
					add ({first, second}::'F' + first + '-S' + second) to: alternatives;
					add 'F' + first + '-S' + second to: alternative_tstr;
				}
			}
		}
		write("alternative: " + alternative_tstr);
	}
	
	action initialise_variable {
		// only cycle_count one
		write("start initialise vairable now");
		write("weeks: " + cycle_count);
		ask rice_grid {
			do change_color;
		}
		add 0 to: treatments;
		do define_field_case;
		do sequential_var_calc;
		do check;
		// no treatment
		//add [] to: treatment_areas;
		
		// UI
		if (!is_batch_experiment) {
			do display_how_to_play; 
		}
		
	}
	
	action display_how_to_play {
		write("*** How to play *****");
		write("if interacton is true, you will require to choose to spray or not.");
		write("if is_grid_clicked is true, you will require to remove gird layer. Otherwise, it will remove automatically.");
		
		if (is_grid_clicked) {
			write("click on the grid to remove layer of rice.");
		}
	}
	
	reflex check_date_time {
		// we did with step (hour, day and week)
		/*
		hour <- hour + (step / 3600); // second to hour
		if (hour mod 24 = 0) {
			day +<- int(hour / 24);
			if (day mod 7 = 0) { // weekly
				cycle_count <- cycle_count + 1;
				is_farmer_decided <- false;
				//do update_pests_were_eaten_by;
				do renew_variable_each_cycle_count;
			}
		}
		*/
		// each step is a week
	
		cycle_count <- cycle_count + 1;
		is_farmer_decided <- false;
		//do update_pests_were_eaten_by;
		do renew_variable_each_cycle_count;
		//write("Weeks: " + cycle_count);
	}
	
	action store_data_to_csv {

		string calc_file <-"../results/calc.csv"; 
		if file_exists(calc_file){ 
			write "File calc.csv exists in the computer";
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
			//write("predator: " + predators[i]);
			
			float stickyToRemove <- remove_sticky_notes[i] with_precision 2;
			
			save [cycles, pest_total, pestResistant, pestNonResistant, potentialParasitoid, 
				parasitoid, potentialPestEatenByParasitoid, potentialPredator, predator, potentialPestEatenByPredator,
				totalPotentialPestEaten, totalPestEaten, predationRate, fieldCase, dynamicYield, potentialYield,
				realYield, treatment, maxDynamicYield, stickyToRemove
			] to: "../results/calc.csv" format:"csv" rewrite: false;
		}
		
		// use all to float
		// change all to float
		/*loop i from: 0 to: 12 {
			int cycles <- i;
			float pest_total <- pests_total[i] with_precision 2;
			float pestResistant <- pest_resistants[i] with_precision 1;
			float pestNonResistant <- pest_non_resistants[i];
			float potentialParasitoid <- potential_parasitoids[i] with_precision 2;
			float parasitoid <- parasitoids[i] with_precision 2;
			float potentialPestEatenByParasitoid <- potential_pests_eaten_by_parasitoids[i] with_precision 2;
			float potentialPredator <- potential_predators[i] with_precision 2;
			float predator <- predators[i] with_precision 2;
			float potentialPestEatenByPredator <- potential_pests_eaten_by_predators[i];
			float totalPotentialPestEaten <- total_potential_pests_eaten[i] with_precision 2;
			float totalPestEaten <- total_pest_eaten[i] with_precision 2;
			float predationRate <- predation_rates[i] with_precision 2;
			float fieldCase <- field_cases[i] with_precision 2;
			float dynamicYield <- dynamic_yields[i] with_precision 2;
			float potentialYield <- potential_yields[i] with_precision 2;
			float realYield <- real_yield_in_tons[i] with_precision 2;
			int treatment <- treatments[i];
			float maxDynamicYield <- max_dynamic_yields[i] with_precision 2;
			
			// test
			float stickyToRemove <- remove_sticky_notes[i] with_precision 2;
			
			save [cycles, pest_total, pestResistant, pestNonResistant, potentialParasitoid, 
				parasitoid, potentialPestEatenByParasitoid, potentialPredator, predator, potentialPestEatenByPredator,
				totalPotentialPestEaten, totalPestEaten, predationRate, fieldCase, dynamicYield, potentialYield,
				realYield, treatment, maxDynamicYield, stickyToRemove
			] to: "../results/calc.csv" format:"csv" rewrite: false;
		}*/

	}
	
	action storeBPH {
		string BPH_path <-"../results/BPH.csv";
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
	
	action update_pest_non_resistant {
		/**
		 * This function uses to update each cycle_count (7 days or a week)
		 */
		if (cycle_count < week_pest_come) {
			add 0.0 to: pest_non_resistants;
		}
		else if (cycle_count = week_pest_come) {
			add 198.0 to: pest_non_resistants;
		}
		else if (cycle_count > week_pest_come) {
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
		if (cycle_count < week_pest_come) {
			float pest_resistant <- 0.0;
			add pest_resistant to: pest_resistants;
		}
		if (cycle_count = week_pest_come) {
			float pest_resistant <- 2.0;
			add pest_resistant to: pest_resistants;
		} else if (cycle_count > week_pest_come) {
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
		int pest_amount <- round(pests_total[cycle_count]);
		if (cycle_count > 0) {
			pest_amount <- round(pests_total[length(pests_total) - 1]) - round(pests_total[length(pests_total) - 2]);
		}
		
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
	
	action update_predation_rate {
		float tmp_predation_rate <- pests_total[length(pests_total)-1] = 0 ? 0 : (total_pest_eaten[length(total_pest_eaten)-1]/ pests_total[length(pests_total)-1]);
		add tmp_predation_rate to: predation_rates;
		//write("tmp predation rate: " + tmp_predation_rate);
		//addpredation_rates
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
				create Parasitoid number: parasitoid_amount;
			} else if (parasitoid_amount < 0) {
				list<Parasitoid> selectedParasitoid <- abs(parasitoid_amount) among Parasitoid;
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
	
	action calc_sticky_notes_need_to_remove {
		if (cycle_count < 1) {
			add field_cases[0] to: remove_sticky_notes;
			return;
		}

		float tmp_remove_rice_yield <- field_cases[length(field_cases) - 1] -  field_cases[length(field_cases) - 2];
		add tmp_remove_rice_yield to: remove_sticky_notes;
		list<rice_grid> rice_pest <- shuffle(rice_grid) where(each.cell_value > 0); // abs(round(tmp_remove_rice_yield)) among 
		//write("num remove sticky note: " + abs(round(tmp_remove_rice_yield)));
		//write("rice pest: " + length(rice_pest));
		
		if (abs(round(tmp_remove_rice_yield)) != 0) {
			if (length(rice_pest) > 0) {
				int tmp_remove <- abs(round(tmp_remove_rice_yield));
				//write("Start remove grid layer");
				int removedSticky <- 0;
				loop rp over: rice_pest {
					if (tmp_remove = 0) {break;}
					int cellValue <- int(rp.cell_value);
					tmp_remove <- tmp_remove - cellValue;
					//write("remaining tmp remove: " + tmp_remove);
					if (tmp_remove < 0) {
						// testing var
						removedSticky <- removedSticky + (cellValue + tmp_remove);
						//write("less than zero: " + tmp_remove);
						//write("cellvalue - tmp_remove: " + (cellValue + tmp_remove));
						ask rp {
							cell_value <- float(abs(tmp_remove));
							do change_color;
						}
						tmp_remove <- 0;
					} else {
						// testing var
						 removedSticky <- removedSticky + cellValue;
						 //write("amount to remove: " + cellValue);
						ask rp {
							cell_value <- 0.0;
							do change_color;
						}
					}
				}
				//write("removed sticky: " + removedSticky);
			}
		}
	}
	
	action add_remove_sticky_note {
		if (cycle_count < 1) {
			add field_cases[0] to: remove_sticky_notes;
			return;
		}

		float tmp_remove_rice_yield <- field_cases[length(field_cases) - 1] -  field_cases[length(field_cases) - 2];
		add tmp_remove_rice_yield to: remove_sticky_notes;
		sticky_to_removed <- abs(round(tmp_remove_rice_yield));
	}
	
	action mouse_click_on_grid { 
		rice_grid selected_grid <- first(rice_grid where(each.cell_value > 0) overlapping (square(1) at_location #user_location));
		write("grid: " + selected_grid);
		
		if (sticky_to_removed > 0 and selected_grid != nil) {
			int cellValue <- int(selected_grid.cell_value);
			sticky_to_removed <- sticky_to_removed - 1;
			cellValue <- cellValue - 1;
			ask selected_grid {
				cell_value <- float(cellValue);
				do change_color;
			}
		}
		
		// if removed all required sticky notes
		if (cycle_count > 0 and cycle_count < 12 and sticky_to_removed <= 0) {
			do resume;
		}
	}
	
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
		if (is_grid_clicked) {
			do add_remove_sticky_note;
		} else {
			do calc_sticky_notes_need_to_remove;
		}
		
	}
	
	
	action check {
		/*
		write("treatments: " + treatments);
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
		
		write("predation rates: " + predation_rates);
		write("field cases: " + field_cases);
		write("potential yield: " + potential_yields);
		write("real yield in tons: " + real_yield_in_tons);
		write("max dynamic_yield: " + max_dynamic_yields);
		*/
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
		list<rice_grid> rice_cell <-  rice_grid where(each.cell_value > 0);
		float cellRemaining <- 0.0;
		loop rc over: rice_cell {
			cellRemaining <- cellRemaining + rc.cell_value;
		}
		write("remaining cell value: " + cellRemaining);
		
		string crop_yeild_path <- "../results/crop_yield.csv"; 
		if file_exists(crop_yeild_path){ 
			write "File exists in the computer";
			bool delete_file_ok <- delete_file(crop_yeild_path);
            write "Deleted file (crop_yield): " + delete_file_ok;
		}
		
		save [stickyNoteRemaining, cellRemaining, finalYield] to: crop_yeild_path format: "csv" rewrite: false;
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
			// we remove over 1 amount so, we should added. This over of removing due to precision and round
			int add_amount <- round(sticky_with_precision) - sticky_note_round;
			write("amount need to add: " + add_amount);
			if (add_amount <= 3) {
				list<rice_grid> rice_cell <- rice_grid where(each.cell_value < 3);
				// amount has only 1 in this case
				ask rice_cell[0] {
					cell_value <- float(rice_cell[0].cell_value + add_amount);
					do change_color;
				}
			}
		}
	}
	
	// interactio part
	action decide_to_spray {
		write("decide to spray");
		do sequential_var_calc;
		add 1 to: treatments;
		ask world {do check;}
		is_farmer_decided <- true;
//		event "y" {ask simulation { do decide_to_spray;}}
	}
	
	action decide_not_to_spray {
		do sequential_var_calc;
		add 0 to: treatments;
		ask world {do check;}
		is_farmer_decided <- true;
	}
//	action farmer_decision when: !is_farmer_decided and cycle_count > 0 and cycle_count < 13 {
//			write("\nWeeks: " + cycle_count);
//			// this calculation isn't related to current treatment
//			ask world {do sequential_var_calc;}
//			
//			// apply treatment
//			if (cycle_count = 0 or cycle_count = 12) {
//				add 0 to: treatments;
//			} else {
//				add 1 to: treatments;
//				
//			}
//			ask world {do check;}
//			//ask world {do get_total_prev_treatment();}
//			is_farmer_decided <- true;
//	}

	int get_week_num(string sprayWeek) {
		if (sprayWeek = ONLY_1ST_WEEK) {
				return 1;
		} else if (sprayWeek = ONLY_2ND_WEEK) {
			return 2; 
		} else if (sprayWeek = ONLY_3RD_WEEK){
			return 3;
		} else if (sprayWeek = ONLY_4TH_WEEK) {
			return 4;
		} else if (sprayWeek = ONLY_5TH_WEEK) {
			return 5;
		} else if (sprayWeek = ONLY_6TH_WEEK) {
			return 6;
		} else if (sprayWeek = ONLY_7TH_WEEK) {
			return 7;
		} else if (sprayWeek = ONLY_8TH_WEEK) {
			return 8;
		} else if (sprayWeek = ONLY_9TH_WEEK) {
			return 9;
		} else if (sprayWeek = ONLY_10TH_WEEK) {
			return 10;
		} else if (sprayWeek = ONLY_11TH_WEEK) {
			return 11;
		} else if (sprayWeek = NONE) {
			return 0; // No spray
		} else if (sprayWeek = ALL_WEEK) {
			return 12;
		}
	}
	
}

grid rice_grid width: rice_field_width height: rice_field_height neighbors: 8 { // good to go with 30 x 30
	rgb color <- #green;
	float cell_value min: 0.0 max: 3.0 <- 3.0;
	bool is_free <- true;
	list<int> treatments <- [0,0,0,0,0,0,0,0,0,0,0,0,0];
	//RiceCrop rice_crop;
	//list<Insect> insects_inside <- (Predator + Pest + Predator) inside(self);
	
	
	init {

	}
	
	
	list get_insects_inside {
		return agents_inside(self);//(Predator + Pest + Predator) inside self;
		//return (Predator + Pest + Predator) inside(self);
	}
	
	action change_color {
		if (cell_value = 3.0) {
			// Dark Green Background
			color <- rgb(0, 112, 48);
		} else if (cell_value = 2.0) {
			// Light Green Background
			color <- rgb(198, 239, 206);
		} else if (cell_value = 1.0) {
			// Bright Yellow Background
			color <- rgb(255, 255, 0);
		} else if (cell_value = 0.0) {
			// Brown Background #583927, LEGO Brick
			color <- rgb(88, 57, 39);
		}
	}
	
}

species Insect {
	string type;
	int resistance <- 0;
	//Current cell of the agent
	rice_grid current_cell;
	//Evacuation cell of the agent
	//rice_grid target_cell;
	//List of the cells already passed by the agents and memorised
	//list<rice_grid> memory;
	float speed <- 1.6 #km/#day;
	
	init {
		// move to one of a grid location
		rice_grid tmpCell <- one_of(rice_grid where(each.is_free = true));
		if (tmpCell != nil) {
			current_cell <- tmpCell;
		} else {
			current_cell <- one_of(rice_grid);
		}
		location <- current_cell.location;
		current_cell.is_free <- false;
	}
	
	/*reflex move {
		current_cell <- one_of(current_cell.neighbors);
		location <- current_cell.location;
	}*/
	
	aspect default {
		draw circle(1) color: #red;
	}
}

species Pest parent:Insect {
	//float reproduction_rate <- 1.33;

	reflex move {
		current_cell <- one_of(current_cell.neighbors);
		location <- current_cell.location;
	}
	
	aspect default {
		draw square(1) color: #red;
	}
}

species Parasitoid parent: Insect {
	int pest_eaten <- 0;
	
	reflex move {
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
	}
	
	reflex eat when: num_pest_eaten_by_parasitoid < potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids)-1] {
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
	}
	
	aspect default {
		draw square(1) color: #black;
	}
	
}

species Predator parent: Insect {
	int pest_eaten <- 0;

	reflex move {
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
	}
	
	reflex eat when: num_pest_eaten_by_predator < potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators)-1] {
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
	}
	
	aspect default {
		draw square(1) color: #violet;
	}
}

species Farmer {
	
	init {
		//write("farmer species init");
	}

	reflex farmer_decision when: !is_farmer_decided and cycle_count > 0 and cycle_count < 13 {
			//write("\nWeeks: " + cycle_count + "reflex work");
			// this calculation isn't related to current treatment
			ask world {do sequential_var_calc;}
			// apply treatment
			
			if (is_interacted) {
				do interact_from_participant;
			} else if (spray = ALL_WEEK) {
				do spray_all_the_time;
			} else if (spray = ONLY_1ST_WEEK) {
				do spray_only_week(1);
			} else if (spray = ONLY_2ND_WEEK) {
				do spray_only_week(2);
			} else if (spray = ONLY_3RD_WEEK){
				do spray_only_week(3);
			} else if (spray = ONLY_4TH_WEEK) {
				do spray_only_week(4);
			} else if (spray = ONLY_5TH_WEEK) {
				do spray_only_week(5);
			} else if (spray = ONLY_6TH_WEEK) {
				do spray_only_week(6);
			} else if (spray = ONLY_7TH_WEEK) {
				do spray_only_week(7);
			} else if (spray = ONLY_8TH_WEEK) {
				do spray_only_week(8);
			} else if (spray = ONLY_9TH_WEEK) {
				do spray_only_week(9);
			} else if (spray = ONLY_10TH_WEEK) {
				do spray_only_week(10);
			} else if (spray = ONLY_11TH_WEEK) {
				do spray_only_week(11);
			} else if (spray = NONE) {
				do do_not_spray;
			} else if (spray = TWICE_TREATMENT) {
				point val <- alternatives index_of opt_alternative;
				f_spray <- int(val.x);
				s_spray <- int(val.y);
				//write("value: " + val.x);
				do apply_treatment_twice([f_spray, s_spray]);
			}
			 
			//do action: sequential_var_calc;
			//write("treatment list: " + treatments);
			//do check();
			do update_pest_on_ui;
			ask world {do check;}
			//ask world {do get_total_prev_treatment();}
			is_farmer_decided <- true;
			
			if (sticky_to_removed > 0 and is_grid_clicked) {
				write("do pause: " + sticky_to_removed);
				ask world {
					do pause;
				}
			}
	}
	
	action apply_treatment_twice(list<int> _sprays) {
		bool is_matched <- false;
		loop week over: _sprays {
			if (week = cycle_count) {
				add 1 to: treatments;
				is_matched <- true;
			}
		}
		
		if (!is_matched) {
			add 0 to: treatments;
		}
	}
	
	action update_pest_on_ui {
		//write("pest on ui: " + length(Pest));
		//write("pest var: " + pests_total);
		if (length(Pest) < pests_total[cycle_count]) {
			// udpdate ui pest due to eating of natural enemies
			create Pest number: pests_total[cycle_count] - length(Pest);
		}
	}
	
	action do_not_spray {
		if (cycle_count = 0 or cycle_count = 12) {
			add 0 to: treatments;
		} else {
			add 0 to: treatments;
		}
	}
	
	
	action spray_all_the_time {
		if (cycle_count = 0 or cycle_count = 12) {
			add 0 to: treatments;
		} else {
			add 1 to: treatments;
		}
		
	}
	
	action spray_only_week(int week_num) {
		if (cycle_count = 0 or cycle_count = 12) {
			add 0 to: treatments;
		} else if (cycle_count = week_num) {
			add 1 to: treatments;
		} else {
			add 0 to: treatments;
		}
		
	}
	
	action interact_from_participant {
		if (cycle_count = 0 or cycle_count = 12) {
			add 0 to: treatments;
		} else {
			bool confirm <- user_confirm("Spray","Please confirm, Would you spray or not?");
			write("user confirm: " + confirm);
			add confirm ? 1 : 0 to: treatments;
		}
	}
	
	reflex pollution_of_pesticide {

	}
	
	
	reflex stop_experiment when: cycle_count = 12 and !is_batch_experiment { 
		write("Rice harvested, stop experiment.");
		ask world {
			do store_data_to_csv;
			do storeBPH;
			do calc_end_result_and_store;
			do pause;
   		}
   		
	}
	
	aspect default {
		draw circle(1) color:#transparent at: {0, 0};
	}
}

experiment Base virtual: true {
	parameter "Width of rice field" category: "Rice Paddy" var: rice_field_width <- 10;
	parameter "Height of rice field" category: "Rice Paddy" var: rice_field_height <- 10;
	parameter "Number of parasitoid" category: "Insect" var: number_of_parasitoid;
	parameter "Number of predator" category: "Insect" var: number_of_predator;
	parameter "Week of pest come" category: "Insect" var: week_pest_come;
	
	output {
		monitor "Number of parasitoid" value: length(Parasitoid);
		monitor "Number of predator" value: length(Predator);
		monitor "Number of pest" value: length(Pest);
		monitor "Week" value: cycle_count;
		//monitor "Sticky to removed" value: sticky_to_removed;
	}
}

experiment Experiment type: gui parent: Base{
	parameter "Interactive" category:"Pesticide" var: is_interacted <- true disables: [spray];
	parameter "Spray decision" category:"Pesticide" var: spray <- NONE among:[NONE,ALL_WEEK, ONLY_1ST_WEEK, ONLY_2ND_WEEK, ONLY_3RD_WEEK, ONLY_4TH_WEEK, ONLY_5TH_WEEK, ONLY_6TH_WEEK, ONLY_7TH_WEEK, ONLY_8TH_WEEK, ONLY_9TH_WEEK, ONLY_10TH_WEEK, ONLY_11TH_WEEK, TWICE_TREATMENT];
	parameter "is grid clicked" category: "Rice Paddy" var: is_grid_clicked <- false;
	parameter "Twice treatment" category: "Pesticide" var: opt_alternative <- 'F1-S2' among: alternative_tstr ;//enables: [spray];
	
	init {
		ask world {
			do alternative_twice_treatment;
		}
	}
	
	output {
		display riceField {
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			species Farmer;
			
			event #mouse_down {ask simulation {do mouse_click_on_grid;}}
			
			overlay position: { 5, 5 } size: { 180 #px, 140 #px } background: # black transparency: 0.5 border: #black rounded: true
	        {
            	//for each possible type, we draw a square with the corresponding color and we write the name of the type
                float y <- 30#px;

                draw square(10#px) at: { 20#px, y } color:PREDATOR_COLOR  border: #white;
                draw "Predator " + '(' + length(Predator) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw square(10#px) at: { 20#px, y } color:PARASITOID_COLOR  border: #white;
                draw "Parasitoid (" + length(Parasitoid) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw square(10#px) at: { 20#px, y } color:PEST_COLOR  border: #white;
                draw "Pest (" + length(Pest) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
//                draw square(10#px) at: { 20#px, y } color:IMMUNE_COLOR  border: #white;
                draw "Weeks: " + cycle_count at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                // current decision still make decision
                //draw "Treatment: " + (treatments[cycle_count] = 1 ? "Yes" : "No")  at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                //y <- y + 25#px;
                if(is_grid_clicked) {
                	draw "sticky removed: " + sticky_to_removed  at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                	y <- y + 25#px;
                }
			}
			
			//display the pollution grid in 3D using triangulation.
			
			//mesh rice_grid scale: 9 triangulation: true transparency: 0.4 smooth: 3 above: 0.8 color: pal;
		
		}
		
		// every 28 cycles equal to one cycle count ( a week)
		display plots type: 2d refresh:every(per_cycle_count#cycles){
				chart "Population Dynamics" size: {1,0.5} position: {0,0} type: series {
				    data "Total Pest" value: length(Pest) color: PEST_COLOR;
				    data "Pest resistance" value: pest_resistants[cycle_count] color: #yellow;
				    data "Parasitoid" value: length(Parasitoid) color: PARASITOID_COLOR;
				    data "Predator" value: length(Predator) color: PREDATOR_COLOR;
				    data "Treatment" value: (treatments[cycle_count] = 1 ? treatments[cycle_count] * 50 : nil) color: #blue style: dot; // display dot as a treatment in value 50
				}
				
				chart "Crop Yield" size: {1,0.5} position: {0,0.5} type: series {
				    data "Real Yield (tons)" value: real_yield_in_tons[cycle_count] color: #lightblue;//[cycle_count, length(Pest)] color: #red;
				    data "Max yield (tons)" value: max_dynamic_yields[cycle_count] color: #blue;//[cycle_count, length(Parasitoid)] color: #blue;
				}
		}
		
	}
	
}

experiment "No Treatment" type: gui parent: Base {
//	parameter "Width of rice field" var: rice_field_width <- 10;
//	parameter "Height of rice field" var: rice_field_height <- 10;
//	parameter "Number of parasitoid" var: number_of_parasitoid;
//	parameter "Number of predator" var: number_of_predator;
//	parameter "Interactive" category:"Pesticide" var: is_interacted <- false read_only: true;
//	parameter "Spary decision" category:"Pesticide" var: spray <- NONE read_only: true;
	
	init {
		write("\n===== Don't Spray all the week =====");
		write("Using traditional method by depending on predator and parasitoid group\n");
		is_interacted <- false;
		spray <- NONE;
		write("is interacted: " + is_interacted);
		write("spray: " + spray);
	}
	
	output {
		layout #split editors: false;
		display riceField2 {
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			species Farmer;
			
//			species ExperimentFarmerNoTreatment;
			
			/*overlay position: { 5, 5 } size: { 180 #px, 140 #px } background: # black transparency: 0.5 border: #black rounded: true
            {
                float y <- 30#px;

                draw square(10#px) at: { 20#px, y } color:PREDATOR_COLOR  border: #white;
                draw "Predator " + '(' + length(Predator) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw square(10#px) at: { 20#px, y } color:PARASITOID_COLOR  border: #white;
                draw "Parasitoid (" + length(Parasitoid) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw square(10#px) at: { 20#px, y } color:PEST_COLOR  border: #white;
                draw "Pest (" + length(Pest) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw "Weeks: " + cycle_count at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
			}*/
		
		}
		
		//inspect "All Parasitoid" type: table value: Parasitoid attributes: ['name', 'speed'];
		//inspect "All Predator" type: table value: Predator attributes: ['name', 'speed'];
		monitor "Number of parasitoid" value: length(Parasitoid);
		monitor "Number of predator" value: length(Predator);
		monitor "Number of pest" value: length(Pest);
		monitor "Week" value: cycle_count;
		
		display plots type: 2d refresh:every(per_cycle_count#cycles){
				chart "Population Dynamics" size: {1,0.5} position: {0,0} type: series {
				    data "Pest" value: length(Pest) color: PEST_COLOR;
				    data "Parasitoid" value: length(Parasitoid) color: PARASITOID_COLOR;
				    data "Predator" value: length(Predator) color: PREDATOR_COLOR;
				    data "Treatment" value: (treatments[cycle_count] = 1 ? treatments[cycle_count] * 50 : nil) color: #blue style: dot; // display dot as a treatment in value 50
				}
				
				chart "Crop Yield" size: {1,0.5} position: {0,0.5} type: series {
				    data "Real Yield (tons)" value: real_yield_in_tons[cycle_count] color: #lightblue;//[cycle_count, length(Pest)] color: #red;
				    data "Max yield (tons)" value: max_dynamic_yields[cycle_count] color: #blue;//[cycle_count, length(Parasitoid)] color: #blue;
				}
		}
		
	}
}


experiment "Treatment All" parent: Base{
	parameter "Interactive" category:"Pesticide" var: is_interacted <- false read_only: true;
	parameter "Spary decision" category:"Pesticide" var: spray <- ALL_WEEK read_only: true;
	
	init {
		is_interacted <- false;
	}
	
	output {
		layout #split editors: false;
		display riceField {
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			species Farmer;
//			species ExperimentFarmerNoTreatment;
			
			/*overlay position: { 5, 5 } size: { 180 #px, 140 #px } background: # black transparency: 0.5 border: #black rounded: true
            {
                float y <- 30#px;

                draw square(10#px) at: { 20#px, y } color:PREDATOR_COLOR  border: #white;
                draw "Predator " + '(' + length(Predator) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw square(10#px) at: { 20#px, y } color:PARASITOID_COLOR  border: #white;
                draw "Parasitoid (" + length(Parasitoid) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw square(10#px) at: { 20#px, y } color:PEST_COLOR  border: #white;
                draw "Pest (" + length(Pest) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw "Weeks: " + cycle_count at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
			}*/
		
		}
		
		// every 28 cycles equal to one cycle count ( a week)
		display plots type: 2d refresh:every(per_cycle_count#cycles){
				chart "Population Dynamics" size: {1,0.5} position: {0,0} type: series {
				    data "Pest" value: length(Pest) color: PEST_COLOR;
				    data "Parasitoid" value: length(Parasitoid) color: PARASITOID_COLOR;
				    data "Predator" value: length(Predator) color: PREDATOR_COLOR;
				    data "Treatment" value: (treatments[cycle_count] = 1 ? treatments[cycle_count] * 50 : nil) color: #blue style: dot; // display dot as a treatment in value 50
				}
				
				chart "Crop Yield" size: {1,0.5} position: {0,0.5} type: series {
				    data "Real Yield (tons)" value: real_yield_in_tons[cycle_count] color: #lightblue;//[cycle_count, length(Pest)] color: #red;
				    data "Max yield (tons)" value: max_dynamic_yields[cycle_count] color: #blue;//[cycle_count, length(Parasitoid)] color: #blue;
				}
		}
		
	}
}

experiment "Only 1st Week" parent: Base {
//	parameter "Interactive" category:"Pesticide" var: is_interacted <- false read_only: true;
//	parameter "Spary decision" category:"Pesticide" var: spray <- ALL_WEEK read_only: true;
	init {
		is_interacted <- false;
		spray <- ONLY_1ST_WEEK;
	}
	
	output {
		layout #split editors: false;
		display riceField2 {
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			species Farmer;
//			species ExperimentFarmerNoTreatment;
		}
		
		display plots type: 2d refresh:every(per_cycle_count#cycles){
				chart "Population Dynamics" size: {1,0.5} position: {0,0} type: series {
				    data "Pest" value: length(Pest) color: PEST_COLOR;
				    data "Parasitoid" value: length(Parasitoid) color: PARASITOID_COLOR;
				    data "Predator" value: length(Predator) color: PREDATOR_COLOR;
				    data "Treatment" value: (treatments[cycle_count] = 1 ? treatments[cycle_count] * 50 : nil) color: #blue style: dot; // display dot as a treatment in value 50
				}
				
				chart "Crop Yield" size: {1,0.5} position: {0,0.5} type: series {
				    data "Real Yield (tons)" value: real_yield_in_tons[cycle_count] color: #lightblue;//[cycle_count, length(Pest)] color: #red;
				    data "Max yield (tons)" value: max_dynamic_yields[cycle_count] color: #blue;//[cycle_count, length(Parasitoid)] color: #blue;
				}
		}
		
	}
}

experiment "Run 4 Simulations" parent: Base {
	init {
		// FOR SELF
		is_interacted <- false;
		spray <- ONLY_2ND_WEEK;
		
		create pestHuntingsecondmodel_model {
			is_interacted <- false;
			spray <- ONLY_1ST_WEEK;
			is_batch_experiment <- true; // only decide a batch experiment
		}
		
		create pestHuntingsecondmodel_model {
			is_interacted <- false;
			spray <- ONLY_3RD_WEEK;
			is_batch_experiment <- true; // only decide a batch experiment
		}
		
		create pestHuntingsecondmodel_model {
			is_interacted <- false;
			spray <- NONE; // no treatment was applied
			is_batch_experiment <- true; // only decide a batch experiment
		}
	}
	
	output {
		display riceField {
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			species Farmer;
			
			overlay position: { 5, 5 } size: { 180 #px, 150 #px } background: # black transparency: 0.5 border: #black rounded: true
            {
                float y <- 30#px;

                draw square(10#px) at: { 20#px, y } color:PREDATOR_COLOR  border: #white;
                draw "Predator " + '(' + length(Predator) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw square(10#px) at: { 20#px, y } color:PARASITOID_COLOR  border: #white;
                draw "Parasitoid (" + length(Parasitoid) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw square(10#px) at: { 20#px, y } color:PEST_COLOR  border: #white;
                draw "Pest (" + length(Pest) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw "Weeks: " + cycle_count at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
                
                draw "Spray: " + spray at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
                y <- y + 25#px;
			}
			
			// farmer owned their own field
			// Now experiment base on all field as a hactar grid. each farmer has a hactar
			// species ExperimentFarmerNoTreatment;
		}
		
		display plot type: 2d {
			chart "Crop Yield" size: {1,1} position: {0,0} type: series {
			    data "Real Yield (tons)" value: real_yield_in_tons[cycle_count] color: #lightblue;//[cycle_count, length(Pest)] color: #red;
			    data "Max yield (tons)" value: max_dynamic_yields[cycle_count] color: #blue;//[cycle_count, length(Parasitoid)] color: #blue;
			}
		}
	}
}

experiment "Batch None" type: batch keep_seed: true repeat: 1 until: (cycle_count = 13){
	parameter "Number of parasitoid" category: "Insect" var: number_of_parasitoid min: 0 max: 40 step: 1; // 25
	parameter "Number of predator" category: "Insect" var: number_of_predator min: 0 max: 30 step: 1; // 7
	
	init {
		is_interacted <- false;
		is_batch_experiment <- true;
		spray <- NONE;
		write("is_interacted: " + is_interacted);
	}
	
	reflex end_of_runs
	{ 
		ask simulations
		{	
			float finalYield <- last (real_yield_in_tons);
			// initialise value and the end result that we get
			save [number_of_parasitoid, number_of_predator, finalYield] to: "../results/batch/none_natural_enemies.csv" format:"csv" rewrite: false;
		}
	}
}

experiment "Batch every week" type: batch keep_seed: true repeat: 1 until: (cycle_count = 13){
	// Exploration method
	parameter "Number of parasitoid" category: "Insect" var: number_of_parasitoid min: 0 max: 40 step: 1; // 25
	parameter "Number of predator" category: "Insect" var: number_of_predator min: 0 max: 30 step: 1; // 7
	
	init {
		is_interacted <- false;
		is_batch_experiment <- true;
		spray <- ALL_WEEK;
		write("is_interacted: " + is_interacted);
	}
	
	reflex end_of_runs
	{ 
		ask simulations
		{	
			float finalYield <- last (real_yield_in_tons);
			// initialise value and the end result that we get
			save [number_of_parasitoid, number_of_predator, finalYield] to: "../results/batch/every_week_natural_enemies.csv" format:"csv" rewrite: false;
		}
	}
}

experiment "Batch once per cycle" type: batch keep_seed: true repeat: 1 until: (cycle_count = 13){
	parameter "Number of parasitoid" category: "Insect" var: number_of_parasitoid min: 0 max: 40 step: 1; // 25
	parameter "Number of predator" category: "Insect" var: number_of_predator min: 0 max: 30 step: 1; // 7
	parameter "Spray" category: "Pesticide" var: spray among: [ONLY_1ST_WEEK, ONLY_2ND_WEEK, ONLY_3RD_WEEK, ONLY_4TH_WEEK, ONLY_5TH_WEEK, ONLY_6TH_WEEK, ONLY_7TH_WEEK, ONLY_8TH_WEEK, ONLY_9TH_WEEK, ONLY_10TH_WEEK, ONLY_11TH_WEEK];
	
//	string ONLY_6TH_WEEK const: true <- 'Only 6th week';
//	string ONLY_7TH_WEEK const: true <- 'Only 7th week';
//	string ONLY_8TH_WEEK const: true <- 'Only 8th week';
//	string ONLY_9TH_WEEK const: true <- 'Only 9th week';
//	string ONLY_10TH_WEEK const: true <- 'Only 10th week';
//	string ONLY_11TH_WEEK const: true <- 'Only 11th week';
	
	init {
		is_interacted <- false;
		is_batch_experiment <- true;
		//spray <- ALL_WEEK;
		write("is_interacted: " + is_interacted);
	}
	
	reflex end_of_runs
	{
		ask simulations
		{	
			float finalYield <- last (real_yield_in_tons);
			int sprayWeek <- get_week_num(spray);
			
			// initialise value and the end result that we get
			save [number_of_parasitoid, number_of_predator, sprayWeek, finalYield] to: "../results/batch/once_per_yield_natural_enemies.csv" format:"csv" rewrite: false;
		}
	}
}

experiment "Batch pest arrived" type: batch keep_seed: true repeat: 1 until: (cycle_count = 13) {
	parameter "Number of parasitoid" category: "Insect" var: number_of_parasitoid min: 0 max: 40 step: 5; // 25
	parameter "Number of predator" category: "Insect" var: number_of_predator min: 0 max: 30 step: 5; // 7
	parameter "Spray" category: "Pesticide" var: spray among: [NONE, ALL_WEEK, ONLY_1ST_WEEK, ONLY_2ND_WEEK, ONLY_3RD_WEEK, ONLY_4TH_WEEK, ONLY_5TH_WEEK, ONLY_6TH_WEEK, ONLY_7TH_WEEK, ONLY_8TH_WEEK, ONLY_9TH_WEEK, ONLY_10TH_WEEK, ONLY_11TH_WEEK, TWICE_TREATMENT];
	parameter "Week of pest come" category: "Insect" var: week_pest_come min: 1 max: 12 step: 1;
	
	init {
		is_interacted <- false;
		is_batch_experiment <- true;
	}
	
	reflex end_of_runs
	{ 
		ask simulations
		{	
			float finalYield <- last (real_yield_in_tons);
			int sprayWeek <- get_week_num(spray);
			
			// initialise value and the end result that we get
			save [number_of_parasitoid, number_of_predator, sprayWeek, week_pest_come, finalYield] to: "../results/batch/week_pest_come_natural_enemies.csv" format:"csv" rewrite: false;
		}
	}
}

experiment "Batch Twice Treatment" type: batch keep_seed: true repeat: 1 until: (cycle_count = 13) {
	parameter "First Spray" var: f_spray among: [1,2] min: 1 max: 2 step: 1;
	parameter "Second Spray" var: s_spray among: [3,4,5,6,7,8,9,10,11] min: 3 max: 11 step: 1;
	
	init {
		is_interacted <- false;
		is_batch_experiment <- true;
		spray <- TWICE_TREATMENT;
	}
	
	reflex end_of_runs {
		ask simulations {
			float finalYield <- last(real_yield_in_tons) with_precision 2;
			int firstDecision <- f_spray;
			int secondDecision <- s_spray;
			
			save [firstDecision, secondDecision, finalYield] to: "../results/batch/twice_treatment.csv" format:"csv" rewrite: false;
		}
	}
}