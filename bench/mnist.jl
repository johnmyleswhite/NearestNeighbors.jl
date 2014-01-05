using NearestNeighbors
using MNIST

X_train, y_train = traindata()
X_test, y_test = testdata()

@elapsed t1 = NaiveNeighborTree(X_train)
@elapsed t2 = BallTree(X_train) # VERY SLOW!!

v = X_train[:, 1]

@elapsed k_nearest(v, t1, 30)
@elapsed k_nearest(v, t2, 30)

errors = 0
n = length(y_test)

for i in 1:25
	is, ds = k_nearest(X_test[:, i], t2, 3)
	if mode(y_train[is]) != y_test[i]
		errors += 1
	end
end

errors / 25
