# %%
import pandas as pd
from sklearn.impute import SimpleImputer
from sklearn.preprocessing import LabelEncoder

# Load the data from the provided file
file_path = "cirrhosis.csv"
data = pd.read_csv(file_path)

# Remove the 'ID' and 'N_Days' columns which are not part of the relevant features
data = data.drop(columns=["ID"])

# Remove rows where 'Drug' is NA
data_cleaned = data.dropna(subset=["Drug"])

# Separate the data into numeric and categorical features
numeric_features = data_cleaned.select_dtypes(include=["int64", "float64"]).columns
categorical_features = data_cleaned.select_dtypes(include=["object"]).columns

# Move Stage to categorical features and convert to int
numeric_features = numeric_features.drop("Stage")
categorical_features = categorical_features.append(pd.Index(["Stage"]))
data_cleaned.loc[:, "Stage"] = data_cleaned["Stage"].astype("str").str.replace(".0", "")
data_cleaned.loc[:, "Stage"] = data_cleaned["Stage"].astype("int64")

# Impute missing values for numeric features using the median
imputer = SimpleImputer(strategy="median")
data_cleaned.loc[:, numeric_features] = imputer.fit_transform(
    data_cleaned[numeric_features]
)

# Label encoding for categorical features
for col in categorical_features:
    le = LabelEncoder()
    data_cleaned.loc[:, col] = le.fit_transform(data_cleaned[col])
    data_cleaned.loc[:, col] = data_cleaned[col]

# %%
# Discretize the 'Age' column into quartiles
age_bins = pd.cut(data_cleaned["Age"], bins=4)

data_cleaned.loc[:, "Age"] = pd.cut(data_cleaned["Age"], bins=4, labels=False)
numeric_features = numeric_features.drop("Age")
categorical_features = categorical_features.append(pd.Index(["Age"]))

# %%
from sklearn.feature_selection import SelectKBest, chi2

# Define the feature matrix X and the target y
X = data_cleaned.drop("Status", axis=1)
y = data_cleaned["Status"].astype("int64")

# Create a SelectKBest object to select features with the 10 best chi-squared scores
selector = SelectKBest(chi2, k=17)

# Use the selector to retrieve the 10 best features
X_best = selector.fit_transform(X, y)

# Print the sorted feature scores
feature_scores = [
    (feature, score) for feature, score in zip(X.columns, selector.scores_)
]
sorted_feature_scores = sorted(feature_scores, key=lambda x: x[1])
for feature, score in sorted_feature_scores:
    print(f"Feature: {feature}, Score: {score}")

# Get back the features we've kept, zero out all other features
selected_features = pd.DataFrame(
    selector.inverse_transform(X_best), index=X.index, columns=X.columns
)

# Dropped columns have values of all 0s, so var is 0, drop them
selected_columns = selected_features.columns[selected_features.var() != 0]

# Add the target column to the list of selected columns
selected_columns = ["Status"] + list(selected_columns)

# Keep only the selected features and the target column
data_cleaned = data_cleaned[selected_columns]

# %%
# Remove entries with Status=1
data_cleaned = data_cleaned[data_cleaned["Status"] != 1]

# Sample 43 new entries with Status=2
resampled_data = data_cleaned[data_cleaned["Status"] == 2].sample(
    n=43, replace=True, random_state=42
)

# Append the resampled data to the original DataFrame
data_cleaned = pd.concat([data_cleaned, resampled_data])

# Change Status to binary
data_cleaned.loc[:, "Status"] = data_cleaned["Status"].replace(2, 1)

# Save the cleaned data to a new file
data_cleaned.to_csv("cirrhosis_preprocessed.csv", index=False)
