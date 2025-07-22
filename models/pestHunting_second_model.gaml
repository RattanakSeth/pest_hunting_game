/**
* Name: pestHuntingsecondmodel
* Spray on an select grid and insect movement 
* Author: rattanak
* Tags: second model, model improvement
* Base on research and game formula on the excel file
* Using grid represent as a rice fields
* Spray will be in between (select 10 grid for first initial)
*/


model pestHuntingsecondmodel

global {
	//rgb HEALTHY_COLOR const: true <- rgb(0, 176, 80);
	//rgb SLIGHTLY_DIMAGE_COLOR const: true <- rgb(221, 235, 247);
	//rgb HEAVY_DIMAGE_COLOR const: true <- rgb(242, 220, 219);
	rgb PARASITOID_COLOR const: true <- #black;
	rgb PREDATOR_COLOR const: true <- #violet;
	rgb PEST_COLOR const: true <- #red;
	//	float max_carrying_capacity <- 10.0;
	int number_of_pest <- 0; // first step should be 0
	int number_of_parasitoids <- 25;
	int number_of_predator <- 7;
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
	list<float> predators <- [7.00];
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
	
	// Rice field
	int rice_field_width <- 10;
	int rice_field_height <- 10;
	
	// In between treatment store
	list treatment_areas <- [];
	
	// UI Initialise
//	geometry shape <- rectangle(20,30);
	init {
		create Pest  number: number_of_pest {
//			current_cell <- one_of(rice_grid);
//			location <- current_cell.location;
//			current_cell.is_free <- false;

		}
		
		create Parasitoid number: number_of_parasitoids {
//			current_cell <- one_of(rice_grid);
//			location <- current_cell.location;
//			current_cell.is_free <- false;
		}
		
		create Predator number: number_of_predator {
//			current_cell <- one_of(rice_grid);
//			location <- current_cell.location;
//			current_cell.is_free <- false;
		}
		
		create Farmer;
		
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
		// no treatment
		add [] to: treatment_areas;
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
			add 25 to: potential_parasitoids;
		} else {
			add (parasitoids[length(parasitoids) - 2] * normal_reproduction_rate_parasitoid) to: potential_parasitoids;
		}
		//write("potential parasitoid: " + potential_parasitoids);
	}
	
	action calc_potential_predator {
		if (cycle_count = 0) {
			add 7 to: potential_predators;
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
//			predation_rate <- (number_of_pest = 0) ? 0 : ((total_pest_eaten[length(total_pest_eaten)-1] / number_of_pest));
//			add predation_rate to: predation_rates;
			add 0.0 to: pest_non_resistants;
		}
		else if (cycle_count = 2) {
			//pest_non_resistant <- 198.0;
			add 198.0 to: pest_non_resistants;
//			predation_rate <- number_of_pest = 0 ? 0 : (total_pest_eaten / number_of_pest);
//			add predation_rate to: predation_rates;
		}
		else if (cycle_count > 2) {
			//write("\npest non__resist in week: " + cycle_count);
			float prev_predation_rate <- predation_rates[length(predation_rates) - 1]; // it will calc after this
			//write("prev predation_rate: " + prev_predation_rate + " length: " + length(predation_rates));
			//write("predation_rates: " + predation_rates);

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
			add 25 to: parasitoids;
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
		
		
//		create Parasitoid number: tmp_parasitoid;
		
//		write("number of parasitoid: " + tmp_parasitoid);
//		write("number of test length: " + length(Parasitoid));
		//write("number of parasitoids: " + parasitoids);
		//add tmp_parasitoid to: parasitoids;
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
			add 300 to: remove_sticky_notes;
			return;
		}

		float tmp_remove_rice_yield <- field_cases[length(field_cases) - 1] -  field_cases[length(field_cases) - 2];
		add tmp_remove_rice_yield to: remove_sticky_notes;
		list<rice_grid> rice_pest <- shuffle(rice_grid) where(each.cell_value > 0); // abs(round(tmp_remove_rice_yield)) among 
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
	}
	
	action calc_end_result_and_store {
		float stickyNoteRemaining <- sum(remove_sticky_notes);
		write("sticky note remaining: " + round(stickyNoteRemaining));
		
		float finalYield <- 5 * stickyNoteRemaining / 300;
		write("Final yeild (t/ha): " + finalYield);
		
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
	
	geometry select_shape(point l) {
		write(l);
		// TODO: edit this as a dynamic grid
		return rectangle({l.x - 5, l.y - 5}, {l.x + 5, l.y + 5});
		//return l;
	}
	
}

grid rice_grid width: rice_field_width height: rice_field_height neighbors: 8 { // good to go with 30 x 30
//	rgb color <- #blue;
//	float carrying_capacity;
//	float biomass;
//	int color_value <- 3;
	rgb color <- #green;
	float cell_value min: 0.0 max: 3.0 <- 3.0;
	bool is_free <- true;
	list<int> treatments <- [0,0,0,0,0,0,0,0,0,0,0,0,0];
	//list<Insect> insects_inside <- (Predator + Pest + Predator) inside(self);
	
	
	init {
	//write "my column index is:" + grid_x;
		//write("treatment: " + length(self.treatments));
		
		//write("insect inside: " + insects_inside);
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
		} else {
			//write("nil");
			// check other location
			current_cell <- one_of(current_cell.neighbors);
			location <- current_cell.location;
		}
	}
	
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
	
	aspect default {
		draw square(1) color: #violet;
	}
}


species TreatmentArea {
	// This a shape of drawing while farmer decide to spray
	int i;
	bool is_active;
	float frequency;
	rgb color;
	
	//point center_rotate;
	
	
	aspect default {
		draw shape color:color border:#red at: location size: 5;
		//draw circle(0.3) at:center_rotate color:#red;
		//draw shape color:color border: #red;
	}
	
}

species Farmer {

	reflex farmer_decision when: !is_farmer_decided and cycle_count > 0 and cycle_count < 13 {
			write("\nWeeks: " + cycle_count);
			// this calculation isn't related to current treatment
			ask world {do sequential_var_calc;}
			// apply treatment
			if (cycle_count = 0 or cycle_count = 12) {
				add 0 to: treatments;
			} else {
				add 1 to: treatments;
				list<rice_grid> rnd_grids <- get_fields_for_treatment();
				add rnd_grids to: treatment_areas;
				//list<pair<string, int>> insect_list <- []; // list of insect here
				//write("random cell: " + length(rnd_grids));
				loop rc over: rnd_grids {
					//write("random grid: " + rnd_grids[i]);
					//rice_grid rg <- rice_grid grid_at rnd_grids[i];
					do create_treatment_area(rc.location);
					list<Insect> insect_on_grid <- rc.get_insects_inside();
					insect_on_grid <- insect_on_grid where (each!=nil); // remove nil
					insect_on_grid >>- 0; // remove nill from list
					//insect_on_grid <- remove nill from: insect_on_grid;
					write("insect inside grid: " + insect_on_grid);
					ask rc {
						put 1 in: self.treatments at: cycle_count;
					}
					// TODO: each grid store data and compute only treatment area
				}
				
			}
			
			/*if (cycle_count = 0 or cycle_count = 12) {
				add 0 to: treatments;
			} else {
				bool confirm <- user_confirm("Spray","Please confirm, Would you spray or not?");
				write("user confirm: " + confirm);
				add confirm ? 1 : 0 to: treatments;
			}*/
			
			//do action: sequential_var_calc;
			//write("treatment list: " + treatments);
			//do check();
			ask world {do check;}
			//ask world {do get_total_prev_treatment();}
			is_farmer_decided <- true;
		}
	
	// ui action
	
	
	
	action create_treatment_area(point l){
//		int j <- rnd(6);
//		stats[next_te] <- stats[next_te] + 1;
		create TreatmentArea {
			color <-  #transparent;//tet_colors[i];
			location <- l;//{15,10}
			shape <- world.select_shape(location);
			//frequency <- world.freq(level);
			is_active <- true;
//			ask tetrimino - self {
//				do die;
//			}
		}
		

	}
	
	list<rice_grid> get_fields_for_treatment{
		/* 
		 * This choosing rice fields base on the behavior of the farmer 
		 * They will have different choices
		 * Place to spray will be chosen where the insect in stay on
		 * 10 grids have been selected
		 */
		int target_grid <- 10;
		rice_grid rnd_one_field <- one_of(rice_grid where (!each.is_free));
		list<rice_grid> rice_cell <- rnd_one_field.neighbors;
		add rnd_one_field to: rice_cell;
		//rice_cell <- rice_cell sort_by each;
		
		write("rice cell: " + length(rice_cell));
		int remainingCell <- target_grid - length(rice_cell);
		if (remainingCell != 0) {
			// need to select more
			loop while: (length(rice_cell) < target_grid) {
				write("loop take other grid");
				list<rice_grid> neighbor_of_neighbor <- one_of(rnd_one_field.neighbors).neighbors;
				rice_cell <- rice_cell union neighbor_of_neighbor;
				if (length(rice_cell) > 10) {
					//write("limit cell");
					rice_cell <- (rice_cell sort_by each);
					rice_cell <- rice_cell[0::10];
					write("rice cell size: " + length(rice_cell));
//					rice_cell <- rice_cell sublist 0 number: 10;
				}
			}
			write("rice cell: " + rice_cell);
		}
		
		return rice_cell;
		/* 
		list<point> rnd_grids <- [];
		rice_grid rnd_cell <- one_of(rice_grid);
		add {rnd_cell.grid_x, rnd_cell.grid_y} to: rnd_grids;
		write("random x: " + rnd_cell.grid_x);
		int next_cell <- 8;
		int start <- 0;
		int start_x <- rnd_cell.grid_x;
		int start_y <- rnd_cell.grid_y;
		loop i from: 0 to: next_cell {
			start_x <- start_x + 1;
			if (start_x > 9) {
				start_x <- 0;
				start_y <- start_y + 1;
				if (start_y > 9) {
					start_y <- 0;
				}
			}
			add {start_x, start_y} to: rnd_grids;
		}
		
		return rnd_grids;
		*/
	}
	
	reflex stop_experiment when: cycle_count = 12 { 
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

experiment Experiment type: gui{
	parameter "Width of rice field" var: rice_field_width <- 10;
	parameter "Height of rice field" var: rice_field_height <- 10;
	
	output {
		display riceField type: java2D{
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			species TreatmentArea;
			species Farmer;
			
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
		
		// change this to on init cause it needs to start the programme
		/*display plot_crop_yield_each_cycle type: 2d refresh:every(per_cycle_count#cycles){ // skip(1#cycles)
				chart "Crop Yield" type: series {
				    data "Real Yield (tons)" value: real_yield_in_tons[cycle_count] color: #lightblue;//[cycle_count, length(Pest)] color: #red;
				    data "Max yield (tons)" value: max_dynamic_yields[cycle_count] color: #blue;//[cycle_count, length(Parasitoid)] color: #blue;
				}
		}*/
		
		
	}
	
}

