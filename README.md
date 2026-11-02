# Pest Hunting Game
### Topic: Modelling insect interactions in rice crops on the GAMA platform as a basis for educational VR games
Authors: Rattanak Seth, Lucile Delatouche, Mathilde Sester, Alexis Drogoul, Sovuthy Cheab <br>
<br/>
<b>Cite us (IEEE format)</b>: R. Seth, L. Delatouche, M. Sester, A. Drogoul, and S. Cheab, “Modelling insect interactions in rice crops on the GAMA platform as a basis for educational VR games,” in ASEAN Conference on Emerging Technology 2025, Cambodia Academy of Digital Technology (CADT): Rattanak Seth, Nov. 2015, pp. 103–113. Available: https://www.idri.edu.kh/wp-content/uploads/2025/12/ACET-2025_Proceedings.pdf

---
## First model - PestHunting.gaml
Building model based on game which was implemented on the Microsoft Excel by expert in the field (Delatouche, Ngang and Sester, 2025). It was coded in Gama platform and stick to the excel formula. Before building it, it should draw class diagram, variable relation, and understand the formula in MS Excel.

## Second model - pestHunting_second_model.gaml & insect_simulation_on_grid_2.1.gaml
Adding from only formula in MS Excel, it was implemented as an agent-based modelling by adding insect movement, and eating. In the first version of second model, it consists of three categories such as pesticide, rice paddy and insect and describe in the following:

- interactive: if it is true, it will pop up a dialog to ask participant to apply treatment or not. Inversely, participant should choose the spray decision.
- is grid clicked: this is only if participant would like to remove lost of rice sticky note by using mouse click on grid. It will remove one layer of sticky note until sticky notes equals zero and then it continues to the next week. If you're lazy to click on grid to remove just change it to false.
- number of parasitoid: it is the population of parasitoid in rice paddy
- number of predator: it is the population of predator in rice paddy with default value 7
- week of pest come: it is the week that pest arrived to the rice field. Value can be change ranging from week 0 until last week of rice cycle. The population of pest come will default 200 pests that 1% of them are pest resistant.

Model 2.1 is an improvement model 2 which replaced the movement of insect and eating of them by hunting and fleeing. Natural enemies will hunt the pests in case they see them in the perception radius 1.0. Likewise, pests will flee if they see the natural enemies within the perception radius.

For batch simulation, it consists of batch none, batch every week, batch once per cycle, and batch pest arrived. The 'Batch None' scenario uses two variables: natural enemies and no treatment, to assess crop yield. Batch every week is a corelation between spray every week and natural enemies. Batch once per cycle is a corelation between natural enemy and spray once per rice yield. Lastly, batch pest arrived is a corelation between week the pest come, number of natural enemy and spray decision.

### Third model: pestHunting_third_model.gaml
We expand grid by a grid represents as one hectar of rice field that belong to one farmer, and each grid will randomly select of treatment decision. This will give four scenarios that allow four participants to interaction in the VR Game.

