---
layout: post
title:  "Large Scale Eigenvalue Problems : Single Vector Iteration"
date:   2026-07-08 08:54:44 +0200
description: "A short introduction to the power method for computing the dominant eigenvalue and eigenvector, illustrated with an animation."
tag: insights
--- 

Single-vector iteration, also known as the power method, is one of the simplest ways to approximate the dominant eigenvalue and eigenvector of a matrix.

For a matrix $$A$$, the basic idea is:

- $$A \in \mathbb{R}^{n \times n}$$, with $$n$$ distinct real eigenvalues

$$|\lambda_1| > |\lambda_2| > \dots > |\lambda_n|$$

- And the corresponding eigenvectors are:  

$$e_1, e_2, \dots, e_n$$

- We can express a random starting vector $$x_0$$ as a linear combination of eigenvectors:

$$x_0 = c_1 e_1 + c_2 e_2 + \dots + c_n e_n = \sum_{i=1}^{n} c_i e_i$$

- By definition of an eigenpair: 

$$A e_i = \lambda_i e_i, \quad i=1,\dots,n$$

- Repeated multiplication by $$A$$ gives:

$$x_1 = A x_0 = A \sum_{i=1}^{n}c_ie_i =\sum_{i=1}^{n}c_i A e_i = \sum_{i=1}^{n}c_i \lambda_i e_i$$  

$$x_p = A^p x_0 = \sum_{i=1}^{n}c_i \lambda_i^p e_i$$


- After repeated multiplication, the dominant component remains:

$$x_p = \lambda_1^p \left[c_1 e_1 + \sum_{i=2}^{n} c_i \left(\frac{\lambda_i}{\lambda_1}\right)^p e_i \right] \approx \lambda_1^p c_1 e_1$$

$$x_{p+1} \approx \lambda_1^{p+1} c_1 e_1 =  \lambda_1 x_p$$

- Since $x_{p+1}$ is only approximately a scalar multiple of $x_p$, we estimate the scalar by projecting one vector onto the other:

$$\lambda_1 \approx \frac{x_p^T x_{p+1}}{x_p^T x_p}$$

$$e_1 \approx x_p$$

- To prevent underflow or overflow, we normalize the eigenvector estimate:

$$x_p = \frac{x_p}{(x_p^Tx_p)^{1/2}}$$

The explanation above was taken from [Power method of eigenvalues - Lesson 30 - Numerical Methods for Engineers](https://www.youtube.com/watch?v=_PDyi5BVY-E).

The animation below illustrates the iteration process.

<div style="margin: 1.5rem 0; text-align: center;">
	<video controls playsinline preload="metadata" style="max-width: 80%; height: auto;">
		<source src="{{ site.baseurl }}/assets/anim_powermethod_3d.mp4" type="video/mp4">
		Your browser does not support the video tag.
	</video>
</div>