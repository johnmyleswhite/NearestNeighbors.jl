# TODO: Try to make as many types as possible immutable
# TODO: Generalize to arbitrary metric space

abstract AbstractBall

type EmptyBall <: AbstractBall
end

type Ball{T <: Real} <: AbstractBall
	center::Vector{T}
	r::Float64
end

function Base.contains(b1::Ball, b2::Ball)
	d = euclidean(b1.center, b2.center)
	return d + b2.r <= b1.r
end

function intersects(b1::Ball, b2::Ball)
	d = euclidean(b1.center, b2.center)
	return d <= b1.r + b2.r
end
