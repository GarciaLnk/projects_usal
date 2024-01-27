# %%
import pandas as pd

# Load the data from the provided file
file_path = "cirrhosis_preprocessed.csv"
data = pd.read_csv(file_path)

# Drop N_Days column
data = data.drop("N_Days", axis=1)

# %%
from sklearn.cluster import KMeans
import matplotlib.pyplot as plt

# Define the feature matrix X
X = data.drop("Status", axis=1)

# List to hold the SSE for each k
sse = []

# We will check every k from 1 to 10
for k in range(1, 11):
    kmeans = KMeans(n_clusters=k, n_init=10, random_state=42)
    kmeans.fit(X)
    sse.append(kmeans.inertia_)

# Plot the results
plt.plot(range(1, 11), sse)
plt.title("Método del codo")
plt.xlabel("Clusters")
plt.ylabel("Suma distancia centroide al cuadrado")
plt.xticks(range(1, 11))
plt.grid()

# Save the figure in svg
plt.savefig("results/elbow_method.svg")

plt.show()

# %%
from sklearn.cluster import KMeans

# Define the feature matrix X
X = data.drop("Status", axis=1)

# Create a KMeans object with 2 clusters
kmeans = KMeans(n_clusters=2, n_init=10, random_state=42)

# Fit the model to the data
kmeans.fit(X)

# Get the cluster assignments for each data point
labels = kmeans.labels_

# Add the cluster labels to the original DataFrame
data["Cluster"] = labels

# %%
# Sort the DataFrame by 'Cluster' and reset the index
data_sorted = data.sort_values(by="Cluster").reset_index()

# Create a scatter plot with the entry number on the X axis and 'Status' on the Y axis
plt.scatter(
    data_sorted.index,
    data_sorted["Status"],
    c=data_sorted["Cluster"],
    cmap="viridis",
)

plt.title("Clusters")
plt.xlabel("Registro")
plt.ylabel("Status")
plt.colorbar(label="Cluster")

# Save svg
plt.savefig("results/kmeans2_status.svg")

plt.show()

# %%
# Create a scatter plot with the entry number on the X axis and 'Alk_Phos' on the Y axis
plt.scatter(
    data_sorted.index,
    data_sorted["Alk_Phos"],
    c=data_sorted["Cluster"],
    cmap="viridis",
)

plt.title("Clusters")
plt.xlabel("Entry Number")
plt.ylabel("Alk_Phos")
plt.colorbar(label="Cluster")
plt.savefig("results/kmeans2_alp.svg")


plt.show()

# %%
from sklearn.preprocessing import StandardScaler

# drop cluster
data = data.drop("Cluster", axis=1)

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

# Apply feature scaling to the numeric features
scaler = StandardScaler()
data.loc[:, numeric_features] = scaler.fit_transform(data[numeric_features])

# %%
# List to hold the SSE for each k
sse = []

# We will check every k from 1 to 10
for k in range(1, 11):
    kmeans = KMeans(n_clusters=k, n_init=10, random_state=42)
    kmeans.fit(data)
    sse.append(kmeans.inertia_)

# Plot the results
plt.plot(range(1, 11), sse)
plt.title("Método del codo")
plt.xlabel("Clusters")
plt.ylabel("Suma distancia centroide al cuadrado")
plt.xticks(range(1, 11))
plt.grid()

# Save the figure in svg
plt.savefig("results/elbow_method_norm.svg")

plt.show()

# %%
# Create a KMeans object with 2 clusters
kmeans = KMeans(n_clusters=5, n_init=10, random_state=42)

# Fit the model to the data
kmeans.fit(data)

# Get the cluster assignments for each data point
labels = kmeans.labels_

# Add the cluster labels to the original DataFrame
data["Cluster"] = labels

# %%
# Sort the DataFrame by 'Cluster' and reset the index
data_sorted = data.sort_values(by="Cluster").reset_index()

# Create a scatter plot with the entry number on the X axis and 'Status' on the Y axis
plt.scatter(
    data_sorted.index,
    data_sorted["Status"],
    c=data_sorted["Cluster"],
    # cmap with high contrast colors
    cmap="Spectral",
)

plt.title("Clusters")
plt.xlabel("Registro")
plt.ylabel("Status")
plt.colorbar(label="Cluster")
plt.savefig("results/kmeans5_status.svg")
plt.show()
