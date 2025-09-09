from sktime.transformations.panel.rocket import Rocket
from sktime.datasets import load_unit_test
X_train, y_train = load_unit_test(split="train") 
X_test, y_test = load_unit_test(split="test") 
trf = Rocket(num_kernels=512) 
trf.fit(X_train) 
X_train = trf.transform(X_train) 
X_test = trf.transform(X_test) 

from sktime.classification.interval_based import TimeSeriesForestClassifier
from sktime.datasets import load_arrow_head
from sklearn.model_selection import train_test_split
from sklearn.metrics import accuracy_score
import matplotlib.pyplot as plt

X, y = load_arrow_head()
X_train, X_test, y_train, y_test = train_test_split(X, y)
classifier = TimeSeriesForestClassifier()
classifier.fit(X_train, y_train)
y_pred = classifier.predict(X_test)
accuracy_score(y_test, y_pred)

fig, ax = plt.subplots(layout='constrained')
plt.plot(y_test, color='blue', label='True Labels')
plt.plot(y_pred, color='red', label='Guess Labels')
#ax.scatter(y_pred, color='red', marker='x', label='Predicted')
ax.set_title('True vs Predicted Labels')
ax.grid(True)
        
from sklearn.model_selection import train_test_split
from sktime.clustering.k_means import TimeSeriesKMeans
from sktime.clustering.utils.plotting._plot_partitions import plot_cluster_algorithm
from sktime.datasets import load_arrow_head

X, y = load_arrow_head()
X_train, X_test, y_train, y_test = train_test_split(X, y)

k_means = TimeSeriesKMeans(n_clusters=5, init_algorithm="forgy", metric="dtw")
k_means.fit(X_train)
plot_cluster_algorithm(k_means, X_test, k_means.n_clusters)