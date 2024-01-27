# %%
import pandas as pd

# Load the data from the provided file
file_path = "cirrhosis_preprocessed.csv"
data = pd.read_csv(file_path)

# Drop N_Days column
data = data.drop("N_Days", axis=1)

# %%
import numpy as np

# Define the bins for each feature
bins = {
    "Bilirubin": [0, 1, 2.5, np.inf],
    "Cholesterol": [0, 200, 240, np.inf],
    "Albumin": [0, 3.4, 5.4, np.inf],
    "Copper": [0, 10, 30, np.inf],
    "Alk_Phos": [0, 440, 1470, np.inf],
    "SGOT": [0, 80, 450, np.inf],
    "Tryglicerides": [0, 150, 199, np.inf],
    "Platelets": [0, 150, 450, np.inf],
    "Prothrombin": [0, 10, 13, np.inf],
}

# Discretize each feature
for feature, bin in bins.items():
    data[feature] = pd.cut(
        data[feature], bins=bin, labels=[0, 1, 2], include_lowest=True
    )

# %%
from mlxtend.frequent_patterns import apriori, association_rules

# Convert the DataFrame to one-hot encoded DataFrame
data_encoded = pd.get_dummies(data, columns=data.columns)

# Apply the Apriori algorithm
frequent_itemsets = apriori(data_encoded, min_support=0.2, use_colnames=True)

# Generate the association rules
rules = association_rules(frequent_itemsets, metric="confidence", min_threshold=0.7)

# Sort rules by confidence in descending order and then by lift in descending order
rules = rules.sort_values(["confidence", "lift"], ascending=[False, False])

# Filter to keep only the first rule for each combination of consequents
rules = rules.drop_duplicates(subset=["consequents"])

# save rules to csv
rules.to_csv("results/rules.csv")

# %%
# Apply the Apriori algorithm
frequent_itemsets = apriori(data_encoded, min_support=0.2, use_colnames=True)

# Generate the association rules
rules = association_rules(frequent_itemsets, metric="confidence", min_threshold=0.7)

# Filter the rules to keep only those where the consequent contains "Status"
rules = rules[rules["consequents"].astype(str).str.contains("Status")]

# Sort rules by confidence in descending order and then by lift in descending order
rules = rules.sort_values(["confidence", "lift"], ascending=[False, False])

# Filter to keep only the first rule for each combination of antecedents
rules = rules.drop_duplicates(subset=["antecedents"])

# Save rules to CSV
rules.to_csv("results/rules_car.csv")
