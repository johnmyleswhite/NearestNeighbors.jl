immutable NaiveNeighborTree{T <: Real} <: NearestNeighborTree
	X::Matrix{T}
	metric::Metric
end

function NaiveNeighborTree{T <: Real}(X::Matrix{T})
	return NaiveNeighborTree(X, Euclidean())
end

function nearest{T <: Real}(t::NaiveNeighborTree,
                            v::Vector{T},
	                        k::Integer = 1,
	                        exclude::Integer = -1)
	n = size(t.X, 2)

	if k >= n
		error("k cannot be larger than the size of the full data set")
	end

	pq = PriorityQueue(Int, Float64, Base.Order.Reverse)
	items = 0

	for i in 1:n
		if i == exclude
			continue
		end
		d = evaluate(t.metric, v, t.X[:, i])
		if items < k
			items += 1
			enqueue!(pq, i, d)
		else
			i_max, d_max = peek(pq)
			if d < d_max
				dequeue!(pq)
				enqueue!(pq, i, d)
			end
		end
	end

	return collect(keys(pq)), collect(values(pq))
end


function inball{T <: Real}(t::NaiveNeighborTree,
	                       v::Vector{T},
	                       r::Real,
	                       exclude::Integer = -1)
	is, ds = Int[], Float64[]

	n = size(t.X, 2)

	for i in 1:n
		if i == exclude
			continue
		end
		d = evaluate(t.metric, v, t.X[:, i])
		if d < r
			push!(is, i)
			push!(ds, d)
		end
	end

	return is, ds
end
