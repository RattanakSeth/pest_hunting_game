/**
* Name: insectsimulationongrid21
* Clone from second model and modified insect movement by integrating with model three
* Insect fleeing and hunting
*
* Author: rattanak
* Tags: 2.1
*/


model insectsimulationongrid21

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

	float step <- 4 #s; 
	float step_count <- 0.0;
	//float hour <- 0.0;
	//int day <- 0;
	int cycle_count <- 0; // cycle count
	int cycle <- 0;
	float per_cycle_count <- 1#week;//int(24 / (step/3600) * 7);
	
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
	
	// insect intialise params outside
	float perception_radius <- 2.0;
	
	
	// UI Initialise
	
	// Experiment variable
	bool is_interacted <- true;
	bool is_spray_all_time <- true;
	bool is_batch_experiment <- false;
	string spray <- ONLY_2ND_WEEK;
	
	//bool 
//	geometry shape <- rectangle(20,30);
	init {
		create Farmer;
		
		create Pest  number: number_of_pest;
		create Parasitoid number: number_of_parasitoid;
		create Predator number: number_of_predator;
		
		// initial variable
		do initialise_variable;
		//write("cycle: " + cycle);
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
	}
	
	reflex check_date_time {
		step_count <- step_count + step;
		//write(step_count);
		cycle_count <- int(step_count/1#week);
		//write("" + step_count/1#week + " to int" + "  " + cycle_count);
	}
	
	reflex checkCycleCrop when: every(per_cycle_count#cycles){
		write("renew var");
		do renew_variable_each_cycle_count;
		//write("farmer: " + farmer.id + " : week: " + cycle_count);
	}
	
	action store_data_to_csv {

		string calc_file <-"results/calc.csv"; 
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
			float stickyToRemove <- remove_sticky_notes[i] with_precision 2;
			
			save [cycles, pest_total, pestResistant, pestNonResistant, potentialParasitoid, 
				parasitoid, potentialPestEatenByParasitoid, potentialPredator, predator, potentialPestEatenByPredator,
				totalPotentialPestEaten, totalPestEaten, predationRate, fieldCase, dynamicYield, potentialYield,
				realYield, treatment, maxDynamicYield, stickyToRemove
			] to: "results/calc.csv" format:"csv" rewrite: false;
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
		string BPH_path <-"results/BPH.csv";
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
		is_farmer_decided <- false;
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
		do calc_sticky_notes_need_to_remove;
	}
	
	
	action check {
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
		
		string crop_yeild_path <- "results/crop_yield.csv"; 
		if file_exists(crop_yeild_path){ 
			write "File exists in the computer";
			bool delete_file_ok <- delete_file(crop_yeild_path);
            write "Deleted file: " + delete_file_ok;
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
			// we remove over 1 amount which should added one
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
	
	reflex ask_farmer when: cycle_count > 0 and cycle_count < 13 and every(per_cycle_count#cycles){
		ask Farmer {
			do decision;
		}
	}
}

grid rice_grid width: rice_field_width height: rice_field_height neighbors: 8 { // good to go with 30 x 30
//	rgb color <- #blue;
//	float carrying_capacity;
//	float biomass;
	rgb color <- #green;
	float cell_value min: 0.0 max: 3.0 <- 3.0;
	bool is_free <- true;
	
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

species Farmer {
	
	init {
		//write("farmer species init");
	}
	
//	reflex test {//when: cycle_count > 0 and cycle_count < 13 and every(per_cycle_count#cycles) {
//		write("farmer test decision");
//	}

	action decision {
			write("\nWeeks: " + cycle_count + "Farmer on decision");
			// this calculation isn't related to current treatment
			ask world {do sequential_var_calc;}
			
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
			}
			
			do update_pest_on_ui;
			//write("treatment list: " + treatments);
			//do check();
			ask world {do check;}
			//ask world {do get_total_prev_treatment();}
			is_farmer_decided <- true;
	}
	
	action update_pest_on_ui {
		write("pest on ui: " + length(Pest));
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
	
//	action spray_only_first_week {
//		if (cycle_count = 0 or cycle_count = 12) {
//				add 0 to: treatments;
//		} else if (cycle_count = 1) {
//			add 1 to: treatments;
//		} else {
//			add 0 to: treatments;
//		}
//		
//	}
	
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
	
	
	
	/*action create_treatment_area(point l){
		create TreatmentArea {
			color <-  #transparent;//tet_colors[i];
			location <- l;//{15,10}
			shape <- world.select_shape(location);
			//frequency <- world.freq(level);
			is_active <- true;
		}
	}*/
	

	
	reflex stop_experiment when: cycle_count = 13 and !is_batch_experiment { 
		write("Rice harvested, stop experiment.");
		
		ask world {
			do pause;
			do store_data_to_csv;
			do storeBPH;
			do calc_end_result_and_store;
   		}
   		
	}
	
	reflex check_insect {
		write("num pest eaten by predator: " + num_pest_eaten_by_predator);
		write("potential_pest_eaten_by_predator: " + round(potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators)-1]));
		write("num pest eaten by parasitoid: " + num_pest_eaten_by_parasitoid);
		write("potential_pest_eaten_by_parastoid: " + round(potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids)-1]));
		//write("test: " + potential_pests_eaten_by_parasitoids);
	}
	
	aspect default {
		draw circle(1) color:#transparent at: {0, 0};
	}
}

species Insect skills: [moving]{
	//string type;
	//int resistance <- 0;
	//Current cell of the agent
	rice_grid cell;
	//Evacuation cell of the agent
	//rice_grid target_cell;
	//List of the cells already passed by the agents and memorised
	//list<rice_grid> memory;
	//float speed <- 1.6 #km/#day;
	
	init {
		cell <- one_of(rice_grid);
		//location <- cell.location;
	}
	
	float speed <- 1.6 #km/#day;//1.6 #km/#day;
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
	float speed <- 1.6 #km/#day;
	rgb color <- #red;
	geometry shape <- circle(1);
	
	reflex fleeing {
		if (length((Predator where (each != nil and !dead(each) and each distance_to self < perception_radius))) > 0 or length((Parasitoid where (each != nil and !dead(each) and each distance_to self < perception_radius))) > 0) {
			speed <- 2.0 #km/#day;
			is_chased <- true;
			color <- # lime;
			if (goal = nil) {
				agent a <- any(((Pest where (each != nil and !dead(each) and !Insect(each).is_chased))));
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

		if (length((Predator where (each != nil and !dead(each))) where (each distance_to self <= perception_radius)) = 0)
		{
			is_chased <- false;
			color <- #red;
			speed <- 1.6 #km/#day;
		}
	}
	
	aspect default {
		draw shape color: color;
	}
}

species Parasitoid parent: Insect {
	
	int pest_eaten <- 0;
	geometry shape <- triangle(1.1);
	rgb color <- #black;
	
//	reflex ccc {
//		write("hunting");
//	}
	
	reflex hunting when: num_pest_eaten_by_parasitoid < round(potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids)-1]) and cycle_count != 12
	{
		if (goal = nil)
		{
			let tmp <- (Pest where (!dead(each) and each.shape distance_to self.shape < perception_radius));
			if (length(tmp) > 0)
			{
				agent a <- first(tmp sort (each.shape distance_to self.shape));
				if (a = nil)
				{
					a <- any((Pest where (!dead(each))));
				}

				if (a != nil)
				{
					speed <- 2.5 #km/#day;
					goal <- a.location;
				}
			}

		} else if ((self.location distance_to goal < 0.5))
		{
			list<Pest> pestToDie <- Pest where (!dead(each) and each.location distance_to goal < 0.5);
			//write("pest selected 0.5 distance: " + length(pestToDie));
			int remainToEat <- round(potential_pests_eaten_by_parasitoids[cycle_count]) - num_pest_eaten_by_parasitoid;//length(Pest where (!dead(each))) - round(pests_total[length(pests_total)-1]);
			//write("Predator remain to eat: " + length(remainToEat));
			if (remainToEat > 0) {
				pestToDie <- remainToEat among pestToDie;
				num_pest_eaten_by_parasitoid <- num_pest_eaten_by_parasitoid + length(pestToDie);
				ask pestToDie
				{
					do die;
				}
			}

			goal <- nil;
			speed <- 1.6 #km/#day;
		}

	}
	
	aspect default {
		//draw square(1) color: #black;
		draw circle(perception_radius) color: #black wireframe: true;
		draw shape color: color rotate: 90 + heading;
	}
	
}

species Predator parent: Insect {
	//int pest_eaten <- 0;
	geometry shape <- triangle(1.1);
	rgb color <- #violet;
	
	reflex hunting when: num_pest_eaten_by_predator < round(potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators)-1]) and cycle_count != 12
	{
		//write("hunting: " + num_pest_eaten_by_predator);
		if (goal = nil)
		{
			let tmp <- (Pest where (!dead(each) and each.shape distance_to self.shape < perception_radius));
			if (length(tmp) > 0)
			{
				agent a <- first(tmp sort (each.shape distance_to self.shape));
				if (a = nil)
				{
					a <- any((Pest where (!dead(each))));
				}

				if (a != nil)
				{
					speed <- 2.5 #km/#day;
					goal <- a.location;
				}

			}

		} else if ((self.location distance_to goal < 0.5))
		{
			list<Pest> pestToDie <- Pest where (!dead(each) and each.location distance_to goal < 0.5);
			//write("pest selected 0.5 distance: " + length(pestToDie));
			int remainToEat <- round(potential_pests_eaten_by_predators[cycle_count]) - num_pest_eaten_by_predator;//length(Pest where (!dead(each))) - round(pests_total[length(pests_total)-1]);
			//write("Predator remain to eat: " + length(remainToEat));
			if (remainToEat > 0) {
				pestToDie <- remainToEat among pestToDie;
				num_pest_eaten_by_predator <- num_pest_eaten_by_predator + length(pestToDie);
				ask pestToDie
				{
					do die;
				}
			}

			goal <- nil;
			speed <- 1.6#km/#day;
		}

	}
	
	aspect default
	{
		draw circle(perception_radius) color: #violet wireframe: true;
		draw shape color: color rotate: 90 + heading;
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
		monitor "Number of pest" value: "" + length(Pest) + " " +pests_total[length(pests_total)-1];
		monitor "Week" value: cycle_count;
	}
}

experiment Experiment type: gui parent: Base{
	parameter "Interactive" category:"Pesticide" var: is_interacted <- false disables: [spray];
	parameter "Spray decision" category:"Pesticide" var: spray <- NONE among:[NONE,ALL_WEEK, ONLY_1ST_WEEK, ONLY_2ND_WEEK, ONLY_3RD_WEEK, ONLY_4TH_WEEK, ONLY_5TH_WEEK, ONLY_6TH_WEEK, ONLY_7TH_WEEK, ONLY_8TH_WEEK, ONLY_9TH_WEEK, ONLY_10TH_WEEK, ONLY_11TH_WEEK];
	output {
		display riceField {
			grid rice_grid;// border: rgba(1,1,1, 0.2);// lines: #black;
			//species Farmer;
			species Pest;
			species Parasitoid;
			species Predator;
			
			
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
				
			}
		
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
		step <- 1#week;
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
	
	output {
		layout #split editors: false;
		display riceField {
			grid rice_grid border: #lightgray;// lines: #black;
			species Farmer;
			species Pest;
			species Parasitoid;
			species Predator;
			
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
		// each simulation of the run is an agent; it is possible to access to the list of these agents by using the variable "simulations" of the experiment. 
		// Another way of accessing to the simulations consists in using the name of model + _model: here "batch_example_model"
		//in this example, we ask all the simulation agents of the run to save (at the end of the simulation) the people population in a shapefile with their is_infected and is_immune attributes 
		ask simulations
		{	
			float finalYield <- last (real_yield_in_tons);
			// initialise value and the end result that we get
			save [number_of_parasitoid, number_of_predator, finalYield] to: "results/batch/none_natural_enemies.csv" format:"csv" rewrite: false;
			write("number of parasitoid: " + number_of_parasitoid);
			write("number of predator: " + number_of_predator);
			write("real_yield_in_tons: " + last(real_yield_in_tons));
			//save [predators,parasitoids] to: "Results/natural_enemies.csv" format:"csv" rewrite:false;
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
		// each simulation of the run is an agent; it is possible to access to the list of these agents by using the variable "simulations" of the experiment. 
		// Another way of accessing to the simulations consists in using the name of model + _model: here "batch_example_model"
		//in this example, we ask all the simulation agents of the run to save (at the end of the simulation) the people population in a shapefile with their is_infected and is_immune attributes 
		ask simulations
		{	
			float finalYield <- last (real_yield_in_tons);
			// initialise value and the end result that we get
			save [number_of_parasitoid, number_of_predator, finalYield] to: "results/batch/every_week_natural_enemies.csv" format:"csv" rewrite: false;
			write("number of parasitoid: " + number_of_parasitoid);
			write("number of predator: " + number_of_predator);
			write("real_yield_in_tons: " + last(real_yield_in_tons));
			//save [predators,parasitoids] to: "Results/natural_enemies.csv" format:"csv" rewrite:false;
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
		// each simulation of the run is an agent; it is possible to access to the list of these agents by using the variable "simulations" of the experiment. 
		// Another way of accessing to the simulations consists in using the name of model + _model: here "batch_example_model"
		//in this example, we ask all the simulation agents of the run to save (at the end of the simulation) the people population in a shapefile with their is_infected and is_immune attributes 
		ask simulations
		{	
			float finalYield <- last (real_yield_in_tons);
			int sprayWeek <- get_week_num(spray);
			
			// initialise value and the end result that we get
			save [number_of_parasitoid, number_of_predator, sprayWeek, finalYield] to: "results/batch/once_per_yield_natural_enemies.csv" format:"csv" rewrite: false;
			write("number of parasitoid: " + number_of_parasitoid);
			write("number of predator: " + number_of_predator);
			write("spray week: " + spray);
			write("real_yield_in_tons: " + last(real_yield_in_tons));
			//save [predators,parasitoids] to: "Results/natural_enemies.csv" format:"csv" rewrite:false;
		}
	}
}

experiment "Batch pest arrived" type: batch keep_seed: true repeat: 1 until: (cycle_count = 13) {
	parameter "Number of parasitoid" category: "Insect" var: number_of_parasitoid min: 0 max: 40 step: 5; // 25
	parameter "Number of predator" category: "Insect" var: number_of_predator min: 0 max: 30 step: 5; // 7
	parameter "Spray" category: "Pesticide" var: spray among: [NONE, ALL_WEEK, ONLY_1ST_WEEK, ONLY_2ND_WEEK, ONLY_3RD_WEEK, ONLY_4TH_WEEK, ONLY_5TH_WEEK, ONLY_6TH_WEEK, ONLY_7TH_WEEK, ONLY_8TH_WEEK, ONLY_9TH_WEEK, ONLY_10TH_WEEK, ONLY_11TH_WEEK];
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
			save [number_of_parasitoid, number_of_predator, sprayWeek, week_pest_come, finalYield] to: "results/batch/week_pest_come_natural_enemies.csv" format:"csv" rewrite: false;
			write("number of parasitoid: " + number_of_parasitoid);
			write("number of predator: " + number_of_predator);
			write("spray week: " + spray);
			write("Week pest come: " + week_pest_come);
			write("real_yield_in_tons: " + last(real_yield_in_tons));
			//save [predators,parasitoids] to: "Results/natural_enemies.csv" format:"csv" rewrite:false;
		}
	}
}

