# %%
import pandas as pd

# Load the data from the provided file
file_path = "cirrhosis_preprocessed.csv"
data = pd.read_csv(file_path)

# %%
# Separating the features and target variable for the classification task
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import (
    AdaBoostClassifier,
    BaggingClassifier,
    RandomForestClassifier,
)
from sklearn.naive_bayes import GaussianNB
from sklearn.svm import SVC
from sklearn.tree import DecisionTreeClassifier
from sklearn.model_selection import (
    GridSearchCV,
    StratifiedKFold,
)


X_class = data.drop(["Status", "N_Days"], axis=1)
y_class = data["Status"]

# Standardizing the features
scaler = StandardScaler()
X_class_scaled = scaler.fit_transform(X_class)

# Setting up 20-fold cross-validation
cv = StratifiedKFold(n_splits=20)

# Setting up the models
models = {
    "Decision Tree": DecisionTreeClassifier(),
    "Naive Bayes": GaussianNB(),
    "SVM": SVC(),
    "Bagging": BaggingClassifier(),
    "Boosting": AdaBoostClassifier(),
    "Random Forest": RandomForestClassifier(),
}

# Hyperparameter grids
param_grids = {
    "Decision Tree": {
        "criterion": ["gini", "entropy"],
        "max_depth": [None, 3, 5, 10, 20],
        "max_features": [None, "sqrt", "log2"],
    },
    "Naive Bayes": {},
    "SVM": {
        "C": [0.01, 0.1, 1, 10, 100],
        "kernel": ["linear", "poly", "rbf", "sigmoid"],
    },
    "Bagging": {
        "n_estimators": [10, 50, 100, 200, 500],
        "max_samples": [0.1, 0.5, 1.0],
        "max_features": [0.1, 0.5, 1.0],
    },
    "Boosting": {
        "n_estimators": [10, 50, 100, 200, 500],
        "learning_rate": [0.01, 0.1, 1, 10, 100],
    },
    "Random Forest": {
        "n_estimators": [10, 50, 100, 200, 500],
        "max_depth": [None, 3, 5, 10, 20],
        "max_features": [None, "sqrt", "log2"],
    },
}


# Function to perform Grid Search with Cross-Validation
def grid_search_cv(model, param_grid, X, y, cv):
    grid_search = GridSearchCV(model, param_grid, cv=cv, scoring="accuracy")
    grid_search.fit(X, y)
    return grid_search.best_score_, grid_search.best_params_


# Performing Grid Search with Cross-Validation for each model
best_scores = {}
best_params = {}
for model_name, model in models.items():
    score, params = grid_search_cv(
        model, param_grids[model_name], X_class_scaled, y_class, cv
    )
    best_scores[model_name] = score
    best_params[model_name] = params

print(best_scores, best_params)
