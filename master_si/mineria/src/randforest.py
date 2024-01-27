# %%
import pandas as pd

# Load the data from the provided file
file_path = "cirrhosis_preprocessed.csv"
data = pd.read_csv(file_path)

# %%
from sklearn.calibration import cross_val_predict
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import StratifiedKFold, cross_val_score

X_class = data.drop(["Status", "N_Days"], axis=1)
y_class = data["Status"]

# Setting up 20-fold cross-validation
cv = StratifiedKFold(n_splits=20)

# Set up class weights
class_weight = [{0: 1, 1: 1}, {0: 1, 1: 2}, {0: 1, 1: 3}, {0: 1, 1: 4}]

rf = RandomForestClassifier(random_state=42)

# Set up the parameter grid to be searched over
param_grid = {"max_depth": [3, 5, 10, 20, 30], "class_weight": class_weight}

# Run the cross-validation and report the mean and standard deviation of the accuracy
scores = cross_val_score(rf, X_class, y_class, cv=cv, scoring="accuracy")
print("Accuracy: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean and standard deviation of the AUC
scores = cross_val_score(rf, X_class, y_class, cv=cv, scoring="roc_auc")
print("AUC: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean and standard deviation of the F1 score
scores = cross_val_score(rf, X_class, y_class, cv=cv, scoring="f1")
print("F1: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean and standard deviation of the precision
scores = cross_val_score(rf, X_class, y_class, cv=cv, scoring="precision")
print("Precision: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean and standard deviation of the recall
scores = cross_val_score(rf, X_class, y_class, cv=cv, scoring="recall")
print("Recall: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean confusion matrix
y_pred = cross_val_predict(rf, X_class, y_class, cv=cv)
print("Confusion matrix:")
print(confusion_matrix(y_class, y_pred))

# Fit the model to the entire dataset
rf.fit(X_class, y_class)
importances = rf.feature_importances_

# Print the feature importances, sorted from most to least important
print("Feature importances:")
print(
    sorted(
        zip(
            importances,
            X_class.columns,
        ),
        reverse=True,
    )
)

# Show a graph of a random decision tree from the forest
from sklearn.tree import export_graphviz
import pydotplus

tree = rf.estimators_[0]
dot_data = export_graphviz(
    tree,
    out_file=None,
    feature_names=X_class.columns,
    class_names=["Alive", "Dead"],
    rounded=True,
    filled=True,
)
graph = pydotplus.graph_from_dot_data(dot_data)
graph.write_svg("results/tree.svg")
