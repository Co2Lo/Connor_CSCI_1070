# Dataset:
The "Job Change of Data Scientists" dataset is a CSV file from Kaggle.com with 14 features describing over 19,000 rows of data, each row representing a data scientist who was either looking or not looking for a job change at the time of the survey. Today, I'll be training binary classification models to determine if a data scientist was pursuing a job change, based on those aforementioned features, which are described in greater detail below, per the Kaggle description:

"enrollee_id : Unique ID for candidate.

city: City code.

city_ development _index : Developement index of the city (scaled).

gender: Gender of candidate

relevent_experience: Relevant experience of candidate

enrolled_university: Type of University course enrolled if any

education_level: Education level of candidate

major_discipline :Education major discipline of candidate

experience: Candidate total experience in years

company_size: No of employees in current employer's company

company_type : Type of current employer

last_new_job: Difference in years between previous job and current job

training_hours: training hours completed

target: 0.0 – Not looking for job change, 1.0 – Looking for a job change"

# Hypothesis:
1. Null: For the dataset, there will be no difference in the population characteristics between the data scientists who look for a job change and those who do not look for a job change.
2. Alternative: For the dataset, there will be a difference in the population characteristics between the data scientists who look for a job change and those who do not look for a job change.

### Implication of hypothesis for binary classification models:
As a "Command + F" search of "0.0" (see above, "Not looking for job change"), and "1.0" (Looking for a job change) on the raw CSV file will reveal, the ratio of the latter to the former is 4777 : 14381... approximately 33.4% of the data scientists represented in the dataset are not looking for a job change, while approximately 66.6% are. As such, a rudimentary "coin flip" model based solely on these percentages would be accurate, over many trials, about 50% of the time, and an even simpler model predicting a data scientist is looking for a job, every single time, would be accurate 66.6% of the time. At the very least, we need to do better than each of these approaches, and prove the accuracy of each model through their respective ROC AUC scores, given it is one of the most consistent and accurate performance metrics.

Then, if my models can predict if data scientists were or were not looking for a job change with more than 66.6% accuracy, the null will be rejected, since a pattern exists among the population of data scientists not looking for a job change from those who are, by which the models can guess with greater accuracy than a naive guesser. Moreover, the more accurate my models are, the "further" they'll reject the null: this will be explained in greater detail, later.

For this implication to be true, however, we must clean the data to ensure our models are truly evaluating PATTERNS, as opposed to NOISE, in the data. Let's preprocess.


# Preprocessing:

### Reading Data:
First, let's create a read_file function which reads our CSV file through a given file path.

### Handling Nulls:
Next, let's create a count_null_values to do exactly that, for each column of our DataFrame.

Now that we can see each column whose nulls we'll have to handle, let's initialize a count_unique_values function to determine the number of occurrences of each, unique value in a specified column, and a fill_null_values_with_ratio function, which, self-explicably, will calculate a "proportions" variable for the specified column by taking the value count of each, specific variable in that column, normalizing the count to create a ratio between unique values, then filling nulls values, at random, with counts, based on the proportion of the non-null value counts calculated earlier.

Let's apply both functions, in that order, to each column with null values, to ensure the proportion of values maintains, for each column, and to get an idea of the unique variables at play in each, which will be useful, later.

Finally, let's print null count of the cleaned dataframe: hooray, there are none left!

### Encoding:
First, let's create a label_encode function using sickitlearn's LabelEncoder: this will be useful to encode columns without natural order. Next, let's create an ordinal_map_encode function for those columns which DO bear natural order. Now, let's go through each column to determine how it should be encoded:
- "enrolee_id" (or the unique "tag" of each data row) will not be encoded, given it is, at best, a confounding, feature for my models, and at worst a perfect predictor of the outcome.
- "city" will be label encoded, as it is categorical—neccesitating conversion to integer values—but not ordinal.
- "city_development_index" is already integered AND normalized between 0 and 1, hooray!
- "gender" will be label encoded, as it is categorical—neccesitating conversion to integer values—but not ordinal.
- "relevant_experience" will be ordinally encoded, with "No relevent experience" mapped to 0 and "Has relevent experience" mapped to 1, given the latter has a higher status than the former.
- "enrolled_university" will be label encoded, because even if an order pops out between "no enrollment", "part time course", and "full time course" at face value, all these options are equally valid living situations; there is no universal status of one over any other.
- "education_level", on the other hand, will be ordinally mapped, given a "PhD" represents more time and bears more weight than graduation from "primary school", and the preceding grade levels.
- "major_discipline" will be label encoded, as it is categorical—neccesitating conversion to integer values—but not ordinal.
- "experience" (measured in years worked at the job) will be ordinally mapped, given the natural order of time places the more experienced above the less experienced, on a scale.
- "company_size" will be ordinally mapped for a very similar reason, because the natural order of population places a given, larger group above a smaller group, on a scale.
- "company_type" will be label encoded, as it is categorical—neccesitating conversion to integer values—but not ordinal.
- "last_new_job" (measured in years since leaving most previous job and entering the current role) will be ordinally mapped, under the same logic as "experience".

Now, let's ensure all our data is encoded properly: indeed, it is.

### Standardization:
Given we're predicting a binary outcome, the below ordinal columns will now need to be normalized, given they bear data whose larger ranges (as can be seen in the table at the end of "encoding") have an excellent chance at negatively impacting model performance:
1. 'relevent_experience'
2. 'education_level'
3. 'experience'
4. 'company_size'
5. 'last_new_job'
6. 'training_hours'

As such, let's create a standardize_columns function using sickitlearn's StandardScaler, to do so. Let's then apply this function to all the above columns, and display the dataframe again in a table, to ensure it applied properly.

### Typographical Corrections:
Finally, let's fix the columns' grammatical errors, and make their titles both simpler and more representative of their data. To do so, let's create a rename_column function which, very simply, takes as input a column, its old name, and your new name, and updates the column title accordingly. Finally, let's create a df_to_csv (dataframe to csv) function which saves our cleaned dataframe back to a file accessible to our visualization notebook.


# Visualization and Analysis:
Let's create exactly that read_file function used earlier, to load in the cleaned, CSV file.

### Visualization #1 — Heatmap:
First, let's visualize the data through a heatmap, to determine the features we should include in the model. We'll fashion a create_heatmap function using seaborn.

As the heatmap illustrates, the top features most correlated with our target are, in order, "City Development Index", "Years of Experience", "In School", and "Has Relevant Experience". The fifth most correlated feature is "Years Since Last Job", though this bears a striking multicollinearity with "Years of Experience", rather intuitively: people who've had invested a long time at their current company, since their last job, necessarily increased their net experience in doing so. As such, we'll exclude the "Years Since Last Job" feature and its measly 8.2% correlation in our models.

The preceding features of "City" and "ID" don't warrant inclusion, either, bearing the highest correlations among the remaining features, though multicollinear (City, with City Index) and confounding (ID) as they are. Given these two are incredibly flawed in their respective ways and yet predict the target best among the remaining columns, I believe cutting off our model's input at "Has Relevant Experience" would be most appropriate, to prevent overfitting.

### Visualization #2 — Box and Whisker Plots:
Next, let's create Box and Whisker Plots for those top four features, to determine generally if their data have any nasty skews or imbalances, which we'll confirm through histograms to come. We'll fashion a create_boxplots function which takes as input our dataframe and aforementioned four columns, and loops boxplot creation for each column using matplot's "box" function.

The two features which jump out as potentially disproportionate are "Has Relevant Experience" and "In School", whose medians (green line) are plastered against the right side of their plots. Moreover, the quartile cutoffs of "Has Relevant Experience" fill the entire graph, indicating a bimodal distribution with a much greater number of positive than negative points, tracking with the column's two variables we encoded in preprocessing. The box plot of "In School" illustrates similar properties, however its first quartile cutoff rests exactly in the middle of the graph, tracking with a similar narrative of disproportionate positive-to-negative data, whose plot is modified by the existence of a "middle" or "neutral" data type, also tracking with the three variables we encoded for the column, in preprocessing.

The features of "Years of Experience" and "City Development Index" don't bear such patterns—and are thus healthy—for different reasons. For the former, the box plot displays a strikiingly Gaussian form—a normal distribution—indicating that no one data value overpowers another: no stratification will be necessary! The box plot of "City Development Index" presents a less idyllic picture, but a perfectly adeuqate one yet. Although the skew is certainly negative, much like our troublemakers, the considerable offset of this plot's quartile range from its positive outlier cutoff, and expansive outlier cutoff range describe a feature whose stratification would harm our model more than its raw input, especially for our highest-correlation metric. Again, we're looking for extreme imbalances because being too liberal with stratification could easily wound our models' accuracy.

### Visualization #3 — Bar Graphs:
Then, let's validate or reject the imbalances of "Has Relevant Experience" and "In School" through histogram visualization of the features' value counts. We'll begin with a create_histogram function which takes as input our dataframe and specified columns, then uses matplot's histogram graph type and auto-buckets (or "bins") close data together.

The "Has Relevant Experience" histogram reveals there are 2/5 the count of low-relevant-experience data scientists to those with high relevant experience, indicating the stratification of this column is in all likelihood unecessary and would harm our models more than benefit them. The histogram of "In School", however, reveals a more dramatic imbalance, validating our findings in the box plot visualization. Still, it's unclear whether the column's imbalance will appreciably impact model performance, and as such our first Logistic Regression model will simply sample our chosen four features without stratification of "In School".

### Model #1A — Logistic Regression ("In School" Unstratified):
As described above, our first function "logistic_regression_model" will train sickitlearn's LogisticRegression model, and evaluate its accuracy through an ROC AUC score. 

As the score illustrates, our model accuracy rests around 71%.

### Model #1B — Logistic Regression ("In School" Stratified):
Our second function, however, will stratify "In School", to see how the tune-up impacts performance. To hold the models apples-to-apples, however, "improved_logistic_regression_model" will remain exactly the same, otherwise (including the same random state!)

Our Logistic Regression model's performance slightly improved; it seems that its predictive abilities benefited slightly from balancing the data representation—inputs—of the "In School" feature, as well as increasing the test_size to 0.23, which is where the benefit of tuning up this metric capped out.

Still, an ROC AUC score of 71.3% is much lower accuracy than I'd prefer to substantiate a conclusion, so let's employ a Gradient Boosting Classifier to reach higher echelons of accuracy. This model will, as learned in class, take as input the data of our specified features in the dataframe, train a model to predict our target, and contribute its predictive power to our final model, at which point it will "hand off" the data to the next model, which will do exactly the same, with, ideally, better predictive capacities towards a specific side of the data than its predecessor, and the process will unfold, exactly as before. Our final model should be more accurate, by these aggregate, predictive abilities, than the simpler Logistic Regression model.

### Model #2 — Gradient Boosting Classifier:
As can be seen above, this model took as input the exact same features as our Logistic Regression model, but bears a nearly 6% higher ROC AUC score than the unstratified—first—model, and a 5.6% bump on the stratfied—second. To tune the GBC model's accuracy and provide a common base on which to evaluate it against the logistic regression model most fairly, I so too tuned up its test size to 0.23.

# Conclusion:
Because all three datasets predicted whether or not a data scientist was looking to change their job with accuracies—ROC AUC scores—of greater than the established benchmark of 66.6%, (in fact, they ranged between 71 - 76.9%), we reject the null that for the dataset, there exists no difference in the population characteristics between the data scientists who look for a job change and those who do not look for a job change.

This is rather intuitive, if we only return to the heatmap, our first visualization of the data. Given our top four features bore negative correlations with the target, respectively, of between 0.17 and 0.34, it was telling early-on there was some pattern threading through the dataset which could be harnessed to predict whether data scientists would pursue career changes. 

The most striking—and greatest—of these correlations is the city development index, featuring that aforementioned -0.34 correlation, which would've been far from my first guess for the preliminary predictor. On further thought, however, the metric is largely intuitive. As data scientists have flocked to emerging hubs such as San Fransisco, Seattle, New York, and Raleigh to pursue the cities' burgeoning job market for software, they tend to add value and enrich the resources of these places, improving their index score. The higher these cities' index score, the lower the probability their data scientist residents will wish to flee the mushrooming innovation around them. Such innovation could very well come from the curricula of universities and education in the area; so to speak, every course, such as this one, is the root of dozens of interactions, projects, and careers in data science.