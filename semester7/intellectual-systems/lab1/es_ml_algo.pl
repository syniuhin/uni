% Basic facts.
goal(predicting_values) :- query('Is your goal predicting values').
goal(predicting_categories) :- query('Is your goal predicting categories').
goal(discovering_structure) :- query('Is your goal discovering the structure').
goal(finding_unusual_data_points) :- query('Is your goal finding unusual data points / detecting anomalies').

data(rank_ordered_categories) :- query('Is your data in rank ordered categories').

result(event_counts) :- query('Are you expecting event counts as a result').
result(distribution) :- query('Are you expecting distribution as a result').

training_speed(fast) :- query('Do you want your model to train fast').
training_speed(slow) :- query('Are you ok with your model training slow').

memory_footprint(large) :- query('Are you ok with large memory footprint').
memory_footprint(small) :- query('Do you prioritize small memory footprint').

accuracy(high) :- query('Do you want to rely on high accuracy').

model(linear) :- query('Your model better be linear').

features_amount(more_than_hundred) :- query('Are you expecting to have >100 features').

feature(aggressive_boundary) :- query('Do you want to have aggressive boundary').

how_many_categories(two) :- query('Do you predict between only 2 categories').
how_many_categories(three_or_more) :- query('Do you predict between >=3 categories').

data_set(small) :- query('Is your dataset relatively small').

% Regression
algo(ordinal_regression) :-
  goal(predicting_values),
  data(rank_ordered_categories).

algo(poission_regression) :-
  goal(predicting_values),
  result(event_counts).

algo(fast_forest_quantile_regression) :-
  goal(predicting_values),
  result(distribution).

algo(linear_regression) :-
  goal(predicting_values),
  training_speed(fast),
  model(linear).

algo(bayesian_linear_regression) :-
  goal(predicting_values),
  data_set(small),
  model(linear).

algo(neural_network_regression) :-
  goal(predicting_values),
  training_speed(slow),
  accuracy(high).

algo(decision_forest_regression) :-
  goal(predicting_values),
  training_speed(fast),
  model(linear).

algo(boosted_decision_forest_regression) :-
  goal(predicting_values),
  training_speed(fast),
  model(linear),
  memory_footprint(large).

% Clustering
algo(k_means) :-
  goal(discovering_structure).

% Anomaly detection.
algo(one_class_svm) :-
  goal(finding_unusual_data_points),
  features_amount(more_than_hundred),
  feature(aggressive_boundary).

algo(pca_based_anomaly_detection) :-
  goal(finding_unusual_data_points),
  training_speed(fast).

% Two-class classification
algo(two_class_SVM) :-
  goal(predicting_categories),
  how_many_categories(two),
  features_amount(more_than_hundred),
  model(linear).

algo(two_class_averaged_perceptron) :-
  goal(predicting_categories),
  how_many_categories(two),
  training_speed(fast),
  model(linear).

algo(two_class_logistic_regression) :-
  goal(predicting_categories),
  how_many_categories(two),
  training_speed(fast),
  model(linear).

algo(two_class_bayes_point_machine) :-
  goal(predicting_categories),
  how_many_categories(two),
  training_speed(fast),
  model(linear).

algo(two_class_decision_forest) :-
  goal(predicting_categories),
  how_many_categories(two),
  training_speed(fast),
  accuracy(high).

algo(two_class_boosted_decision_tree) :-
  goal(predicting_categories),
  how_many_categories(two),
  training_speed(fast),
  accuracy(high),
  memory_footprint(large).

algo(two_class_decision_jungle) :-
  goal(predicting_categories),
  how_many_categories(two),
  memory_footprint(small),
  accuracy(high).

algo(two_class_locally_deep_svm) :-
  goal(predicting_categories),
  how_many_categories(two),
  features_amount(more_than_hundred).

algo(two_class_neural_network) :-
  goal(predicting_categories),
  how_many_categories(two),
  training_speed(slow),
  accuracy(high).

% Multi-class classification
algo(multiclass_logistic_regression) :-
  goal(predicting_categories),
  how_many_categories(three_or_more),
  training_speed(fast),
  model(linear).

algo(multiclass_neural_network) :-
  goal(predicting_categories),
  how_many_categories(three_or_more),
  training_speed(slow),
  accuracy(high).

algo(multiclass_decision_forest) :-
  goal(predicting_categories),
  how_many_categories(three_or_more),
  training_speed(fast),
  accuracy(high).

algo(multiclass_decision_jungle) :-
  goal(predicting_categories),
  how_many_categories(three_or_more),
  memory_footprint(small),
  accuracy(high).

% User
:- dynamic asked/2.

find_me_algo :-
    retractall(asked(_,_)),
    algo(Desire),
    !,
    nl,
    write('Go with '), write(Desire), write(.), nl.
find_me_algo :-
    nl,
    write('Could\'t find a right one for you :( [sad]'), nl.


query(Prompt) :-
    (
        asked(Prompt, Reply) -> true;
        nl, write(Prompt), write('? [y/n] '), flush,
        read_line_to_codes(user_input, [Initial|_]),
        (
            (([Initial] =:= "y"; [Initial] =:= "Y") -> Reply = "y"); Reply = "n"
        ),
        assert(asked(Prompt, Reply))
    ),
    /* write(Reply), */
    Reply =:= "y".
