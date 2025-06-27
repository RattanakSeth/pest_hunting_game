/**
* Name: pestHunting
* Base on research and game formula on the excel file
* Using grid and movement on grid
* First Toy Model
* Author: Rattanak
* Tags: farmer
*/


model pestHunting

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
	float step <- 3 #h; // TODO: reduce this speed
	float hour <- 0.0;
	int day <- 0;
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
	list<int> remove_sticky_notes <- [];
	list<float> potential_parasitoids <- [];
	list<float> potential_predators <- [];
	
	// Rice field
	int rice_field_width <- 10;
	int rice_field_height <- 10;
	
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
		
		// initial variable
		do initialise_variable;
		//write("cycle: " + cycle);
	}
	
	action initialise_variable {
		// only cycle_count one
		write("start initialise vairable now");
		
		ask rice_grid {
			do change_color;
		}
		add 0 to: treatments;
		do define_field_case;
		do sequential_var_calc;
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
		// TODO: popup result on cycle 13 
		write("Rice harvested, stop experiment.");
		do store_data_to_csv;
   		do pause;
//   		bool confirm <- user_confirm("Confirm","
//				Game Simulation has finished. \n
//				" + "Max yeild: " + max_dynamic_yields[length(max_dynamic_yields) - 1]
//			+ '\n' + 'Real yiel in tons: '+ real_yield_in_tons[length(real_yield_in_tons) - 1]);
		// TODO: STORE DATA AS CSV FILE
	}
	
	action store_data_to_csv {
//		ask bug {
//			// save the values of the variables name, speed and size to the csv file; the rewrite facet is set to false to continue to write in the same file
//			save [name,speed, size] to: "../results/bug.csv" format:"csv" rewrite: false;
//			// save all the attributes values of the bug agents in a file. The file is overwritten at every save
//			save bug to: "../results/bug_agents.csv" format:"csv" rewrite: true;
//		}
//		write("store pest: " + pests_total);
//		string test <- concatenate(pests_total, ',');
//		write("test: " + test);

		string calc_file <-"../results/calc.csv"; 
		if file_exists(calc_file){ 
			write "File exists in the computer";
			bool delete_file_ok <- delete_file(calc_file);
            write "Deleted file: " + delete_file_ok;
		}
		string data_string <- ""; 

		/*loop i from: 0 to: 12 {
			int cycles <- i;
			//int pest_total <- round(pests_total[i]);
			float pest_total <- pests_total[i];
			float pestResistant <- pest_resistants[i];
			float pestNonResistant <- pest_non_resistants[i];
			//int potentialParasitoid <- round(potential_parasitoids[i]);
			float potentialParasitoid <- potential_parasitoids[i];
			//int parasitoid <- round(parasitoids[i]);
			float parasitoid <- parasitoids[i];
			//int potentialPestEatenByParasitoid <- round(potential_pests_eaten_by_parasitoids[i]);
			float potentialPestEatenByParasitoid <- potential_pests_eaten_by_parasitoids[i];
			//int potentialPredator <- round(potential_predators[i]);
			float potentialPredator <- potential_predators[i];
			int predator <- round(predators[i]);
			int potentialPestEatenByPredator <- round(potential_pests_eaten_by_predators[i]);
			int totalPotentialPestEaten <- round(total_potential_pests_eaten[i]);
			int totalPestEaten <- total_pest_eaten[i];
			float predationRate <- predation_rates[i];
			int fieldCase <- field_cases[i];
			float dynamicYield <- dynamic_yields[i];
			float potentialYield <- potential_yields[i];
			float realYield <- real_yield_in_tons[i];
			int treatment <- treatments[i];
			float maxDynamicYield <- max_dynamic_yields[i];
			
			save [cycles, pest_total, pestResistant, pestNonResistant, potentialParasitoid, 
				parasitoid, potentialPestEatenByParasitoid, potentialPredator, predator, potentialPestEatenByPredator,
				totalPotentialPestEaten, totalPestEaten, predationRate, fieldCase, dynamicYield, potentialYield,
				realYield, treatment, maxDynamicYield
			] to: "../results/calc.csv" format:"csv" rewrite: false;
		}*/
		
		// use all to float
		// TODO: change all to float
		loop i from: 0 to: 12 {
			int cycles <- i;
			//int pest_total <- round(pests_total[i]);
			float pest_total <- pests_total[i] with_precision 2;
			float pestResistant <- pest_resistants[i] with_precision 1;
			float pestNonResistant <- pest_non_resistants[i] with_precision 2;
			//int potentialParasitoid <- round(potential_parasitoids[i]);
			float potentialParasitoid <- potential_parasitoids[i] with_precision 2;
			//int parasitoid <- round(parasitoids[i]);
			float parasitoid <- parasitoids[i] with_precision 2;
			//int potentialPestEatenByParasitoid <- round(potential_pests_eaten_by_parasitoids[i]);
			float potentialPestEatenByParasitoid <- potential_pests_eaten_by_parasitoids[i] with_precision 2;
			//int potentialPredator <- round(potential_predators[i]);
			float potentialPredator <- potential_predators[i] with_precision 2;
			float predator <- predators[i] with_precision 2;
			float potentialPestEatenByPredator <- potential_pests_eaten_by_predators[i] with_precision 2;
			float totalPotentialPestEaten <- total_potential_pests_eaten[i] with_precision 2;
			float totalPestEaten <- total_pest_eaten[i] with_precision 2;
			float predationRate <- predation_rates[i] with_precision 2;
			float fieldCase <- field_cases[i] with_precision 2;
			float dynamicYield <- dynamic_yields[i];
			float potentialYield <- potential_yields[i] with_precision 2;
			float realYield <- real_yield_in_tons[i];
			int treatment <- treatments[i];
			float maxDynamicYield <- max_dynamic_yields[i];
			
			save [cycles, pest_total, pestResistant, pestNonResistant, potentialParasitoid, 
				parasitoid, potentialPestEatenByParasitoid, potentialPredator, predator, potentialPestEatenByPredator,
				totalPotentialPestEaten, totalPestEaten, predationRate, fieldCase, dynamicYield, potentialYield,
				realYield, treatment, maxDynamicYield
			] to: "../results/calc.csv" format:"csv" rewrite: false;
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
			add (cycle_count * 100/11) with_precision 2 to: dynamic_yields;
		}
	}
	
	action calc_field_case {
		if (cycle_count < 1) {return;}
		float prev_field_case <- field_cases[length(field_cases) - 1];
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
			//write("cycle: " + cycle_count + "predator: " + (treatments[length(treatments) - 2] = 1 ? normal_survival_pesticides_predator : 1) * predators[length(predators) - 1] * normal_reproduction_rate_predator);
			float num_predator <- ((treatments[length(treatments) - 2] = 1 ? normal_survival_pesticides_predator : 1) * predators[length(predators) - 1] * normal_reproduction_rate_predator);
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
			
//			write("predators: " + predators);
//			write("length of it; " + length(Predator));
		}
	}
	
	action update_predation_rate {
		float tmp_predation_rate <- pests_total[length(pests_total)-1] = 0 ? 0 : (total_pest_eaten[length(total_pest_eaten)-1]/ pests_total[length(pests_total)-1]);
		add tmp_predation_rate to: predation_rates;
		//write("tmp predation rate: " + tmp_predation_rate);
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
			//pest_non_resistant <- 198.0;
			add 198.0 to: pest_non_resistants;
//			predation_rate <- number_of_pest = 0 ? 0 : (total_pest_eaten / number_of_pest);
//			add predation_rate to: predation_rates;
		}
		else if (cycle_count > 2) {
			float pev_predation_rate <- predation_rates[length(predation_rates) - 1]; // it will calc after this
//			write("predation_rate: " + predation_rate);
//			write("predation_rates: " + predation_rates);
			int prev_treatment <- treatments[length(treatments) - 2];
			int sum_first_prev_treatment <- treatments[0] + treatments[length(treatments) - 2];
//			loop i from: 0 to: length(treatments) - 2 {
//				sum_of_prev_treatment <- sum_of_prev_treatment + treatments[i];
//			}
			float prev_pest_non_resistant <- pest_non_resistants[length(pest_non_resistants) - 1];
			float pest_non_resistant <- prev_pest_non_resistant * (1 - pev_predation_rate) * (sum_first_prev_treatment = 0 ? normal_production_rate_pest : normal_production_rate_pesticide_pest) * (prev_treatment = 1 ? normal_survival_pesticide_pest : 1) + 9.8;
			add pest_non_resistant to: pest_non_resistants;
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
	
//	action update_pests_were_eaten_by {
//		// update pest was eaten by to list
//		add num_pest_eaten_by_parasitoid to: potential_pests_eaten_by_parasitoids;
//		add num_pest_eaten_by_predator to: potential_pests_eaten_by_predators;
////		write("pests_eaten_by_parasitoids: " + potential_pests_eaten_by_parasitoids);
////		write("pests_eaten_by_predators: " + potential_pests_eaten_by_predators);
//	}
	
	action renew_variable_each_cycle_count {
		// this function use for renewing variable to zero every each cycle_count count
//		write("num_pest_eaten_by_parasitoid: " + num_pest_eaten_by_parasitoid);
//		write("max : " + potential_pests_eaten_by_parasitoids[length(potential_pests_eaten_by_parasitoids)-1]);
//		write("num_pest_eaten_by_predator: " + num_pest_eaten_by_predator);
//		write("max: " + potential_pests_eaten_by_predators[length(potential_pests_eaten_by_predators)-1]);
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
		// first init or cycle_count zero will be 25
		// we treated or sprayed
		//write("cycle " + cycle_count + "not return");
		if (cycle_count = 0) {
			add 25 to: parasitoids;
		} else {
			float prev_total_potential_pests_eaten <- total_potential_pests_eaten[length(total_potential_pests_eaten)-1];
			float prev_total_pest_eaten <- total_pest_eaten[length(total_pest_eaten) - 1];
			float tmp_parasitoid <- (treatments[length(treatments) - 2] = 1 ? normal_survival_pesticide_parasitoid : 1) * parasitoids[length(parasitoids) - 1] * ((prev_total_potential_pests_eaten = prev_total_pest_eaten) ? normal_reproduction_rate_parasitoid : (((normal_reproduction_rate_parasitoid - 1) * prev_total_pest_eaten / prev_total_potential_pests_eaten) + 1));
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
		add (field_cases[length(field_cases)-1] * dynamic_yields[length(dynamic_yields) - 1] * 5 / (100 * begin_field_case)) with_precision 2 to: real_yield_in_tons;
	}
	
	action calc_max_dynamic_yield {
		add (5 * dynamic_yields[length(dynamic_yields) - 1] / 100) with_precision 2 to: max_dynamic_yields;
	}
	
	action calc_sticky_notes_need_to_remove {
		if (cycle_count < 1) {return;}
		int tmp_remove_rice_yield <- field_cases[length(field_cases) - 1] -  field_cases[length(field_cases) - 2];
		add tmp_remove_rice_yield to: remove_sticky_notes;
		list<rice_grid> rice_pest <- rice_grid where(length(Pest) > 0 and each.cell_value > 0);//select rice_grid where(each.)
		//write("tmp remove sticky note: " + tmp_remove_rice_yield);
		//write("rice pest: " + rice_pest);
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
				}
			}
		}
	}
	
	action sequential_var_calc{
		// independant var
		do calc_dynamic_yield;
		
		// structure or dependent variables
		do update_predators;
		do calc_potential_predator;
		do update_potential_pests_eaten_by_predators;
		
		// start with parasitoid
		do update_parasitoids;
		do update_potential_pests_eaten_by_parasitoids;
		do update_total_potential_pest_eaten;
		
		// pest
		do update_pest_non_resistant_and_relevant_fields;
		do update_pest_resistant;
		do update_pest_total;
		do update_total_pest_eaten;
		do calc_potential_parasitoid;
		// resistant
		
		// result calculation
		do update_predation_rate;
		do calc_field_case;
		do calc_potential_yield;
		do calc_real_yield_in_tons;
		do calc_max_dynamic_yield;
		do calc_sticky_notes_need_to_remove;
	}
	
	reflex farmer_decision_to_treatment when: !is_farmer_decided and cycle_count > 0 and cycle_count < 13 {
		//write("cycle_count: " + cycle_count);
		if (cycle_count = 0) {
			add 0 to: treatments;
		} else {
			add 1 to: treatments;
		}
		
		// dynamic code
		/*if (cycle_count = 12) {
			// Harvest
			add 0 to: treatments;
		} else {
			bool confirm <- user_confirm("Confirm","Please confirm, Would you spray or not?");
			write("user confirm: " + confirm);
			add confirm ? 1 : 0 to: treatments;
		}*/
		/*
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
		* */
		do sequential_var_calc;
		is_farmer_decided <- true;
		//write("treatment list: " + treatments);
		do check;
	}
	
	action check {
		// predator
		write("predator each cycle_count: " + predators);
		write("potential predator: " + potential_predators);
		// parasitoid
		write("parasitoids: " + parasitoids);
		write("potential parasitoid: " + potential_parasitoids);
		
		write("potential pest eaten by parasitoids: " + potential_pests_eaten_by_parasitoids);
		write("potential pest eaten by predators: " + potential_pests_eaten_by_predators);
		write("total potential pest eaten: " + total_potential_pests_eaten);
		write("totoal pest eaten: " + total_pest_eaten);
		
		write("predation rates: " + predation_rates);
		write("field cases: " + field_cases);
		write("potential yield: " + potential_yields);
		write("real yield in tons: " + real_yield_in_tons);
		write("max dynamic_yield: " + max_dynamic_yields);
		//write("number of parasitoid: " + length(Parasitoid));
		//write("number of pest: " + length(Pest));
	}
	
}

grid rice_grid width: rice_field_width height: rice_field_height neighbors: 8  { // good to go with 30 x 30
//	rgb color <- #blue;
//	float carrying_capacity;
//	float biomass;
//	int color_value <- 3;
	rgb color <- #green;
	float cell_value min: 0.0 max: 3.0 <- 3.0;
	bool is_free <- true;
	
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
	//Current cell of the agent
	rice_grid current_cell;
	//Evacuation cell of the agent
	//rice_grid target_cell;
	//List of the cells already passed by the agents and memorised
	//list<rice_grid> memory;
	float speed <- 20 #km/#h;
	
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

//	reflex move {
//		current_cell <- one_of(current_cell.neighbors);
//		location <- current_cell.location;
//	}
	
	aspect default {
		draw square(1) color: #red;
	}
}

species Parasitoid parent: Insect {
	int pest_eaten <- 0;
	
	/*reflex move {
		rice_grid tmp_cell <- shuffle(current_cell.neighbors) first_with (!(empty(Pest inside (each))));
		list pest_on_grid <- agents_overlapping(current_cell); //current_cell overlap Pest;
		if (length(pest_on_grid) = 1) {
			// current cell will be a previous cell
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
	
//	reflex move {
//		current_cell <- one_of(current_cell.neighbors);
//		location <- current_cell.location;
//	}

	/*reflex move {
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
	}*/
	
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
	reflex apply_treatment_to_rice_crop {
		write("farmer applay treatment work!");
	}
}

experiment Experiment type: gui{
	parameter "Width of rice field" var: rice_field_width <- 10;
	parameter "Height of rice field" var: rice_field_height <- 10;
	
	output {
		display riceFeild type: java2D{
			grid rice_grid border: #lightgray;// lines: #black;
			species Pest;
			species Parasitoid;
			species Predator;
			//species Farmer;
			
				overlay position: { 5, 5 } size: { 180 #px, 160 #px } background: # black transparency: 0.5 border: #black rounded: true
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
	                draw "PEST (" + length(Pest) + ')' at: { 40#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
	                y <- y + 25#px;
	                
	//                draw square(10#px) at: { 20#px, y } color:IMMUNE_COLOR  border: #white;
	                draw "Cycle: " + cycle_count at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
	                y <- y + 25#px;
	                
	                draw "Treatment: " + treatments[cycle_count] at: { 20#px, y + 4#px } color: #white font: font("Helvetica", 16, #bold);
	                y <- y + 25#px;
				
			}
		
		}
		
		// every 28 cycles equal to one cycle count ( a week)
		display plots type: 2d refresh:every(per_cycle_count#cycles){
				chart "Population Dynamics" type: series {
				    data "Pest" value: length(Pest) color: PEST_COLOR;
				    data "Parasitoid" value: length(Parasitoid) color: PARASITOID_COLOR;
				    data "Predator" value: length(Predator) color: PREDATOR_COLOR;
				    data "Treatment" value: treatments[cycle_count] * 50 color: #blue style: dot; // display dot as a treatment in value 50
				}
		}
		
		// change this to on init cause it needs to start the programme
		display plot_crop_yield_each_cycle type: 2d refresh:every(per_cycle_count#cycles){ // skip(1#cycles)
				chart "Crop Yield" type: series {
				    data "Real Yield (tons)" value: real_yield_in_tons[cycle_count] color: #lightblue;//[cycle_count, length(Pest)] color: #red;
				    data "Max yield (tons)" value: max_dynamic_yields[cycle_count] color: #blue;//[cycle_count, length(Parasitoid)] color: #blue;
				    //data "Predator" value: length(Predator) color: PREDATOR_COLOR;//[cycle_count, length(Predator)] color: #yellow;
				}
		}
		
		
	}
	
}

