# %%
import pandas as pd

# Load the data from the provided file
file_path = "cirrhosis_preprocessed.csv"
data = pd.read_csv(file_path)

# %%
from sklearn.calibration import cross_val_predict
from sklearn.model_selection import StratifiedKFold
from sklearn.model_selection import cross_val_score
from sklearn.metrics import confusion_matrix
from sklearn.preprocessing import StandardScaler
from sklearn.svm import SVC

X_class = data.drop(["Status", "N_Days"], axis=1)
y_class = data["Status"]

numeric_features = [
    "Bilirubin",
    "Cholesterol",
    "Albumin",
    "Copper",
    "Alk_Phos",
    "SGOT",
    "Tryglicerides",
    "Platelets",
    "Prothrombin",
]

# Standardize numeric features
scaler = StandardScaler()
X_class[numeric_features] = scaler.fit_transform(X_class[numeric_features])

# Set up 20-fold cross-validation, shuffled and with stratification, constant rng seed
cv = StratifiedKFold(n_splits=20, shuffle=True, random_state=42)

# Set matrix of class weights to use
class_weight = {0: 1, 1: 1.5}

svm = SVC(class_weight=class_weight)

# Run the cross-validation and report the mean and standard deviation of the accuracy
scores = cross_val_score(svm, X_class, y_class, cv=cv, scoring="accuracy")
print("Accuracy: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean and standard deviation of the AUC
scores = cross_val_score(svm, X_class, y_class, cv=cv, scoring="roc_auc")
print("AUC: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean and standard deviation of the F1 score
scores = cross_val_score(svm, X_class, y_class, cv=cv, scoring="f1")
print("F1: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean and standard deviation of the precision
scores = cross_val_score(svm, X_class, y_class, cv=cv, scoring="precision")
print("Precision: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean and standard deviation of the recall
scores = cross_val_score(svm, X_class, y_class, cv=cv, scoring="recall")
print("Recall: {:.3f} +/- {:.3f}".format(scores.mean(), scores.std()))

# Run the cross-validation and report the mean confusion matrix
y_pred = cross_val_predict(svm, X_class, y_class, cv=cv)
print("Confusion matrix:")
print(confusion_matrix(y_class, y_pred))
