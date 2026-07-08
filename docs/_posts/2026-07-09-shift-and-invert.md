---
layout: post
title:  "Large Scale Eigenvalue Problems : Shift-and-invert"
date:   2026-07-09 08:54:44 +0200
description: "A short introduction to the shift-and-invert technique, which turns the eigenvalue closest to a chosen target into the dominant one so the power method can find it."
tag: insights
--- 

The power method only finds the *dominant* eigenvalue, the one largest in magnitude. But often we care about an eigenvalue somewhere in the middle of the spectrum, close to a value $$\sigma$$ we have in mind. Shift-and-invert is a simple trick that reshuffles the eigenvalues so that the one nearest to $$\sigma$$ becomes the dominant one, and the power method can then pick it out.

The key is that shifting and inverting the matrix keeps the eigenvectors untouched while transforming the eigenvalues in a very useful way.

- Start from the eigenvalue equation:

$$A v = \lambda v$$

- Subtract $$\sigma v$$ from both sides (this is the *shift* by $$\sigma$$):

$$(A - \sigma I) v = (\lambda - \sigma)v$$

- If $$(A - \sigma I)$$ is nonsingular, we can invert it. The same $$v$$ is then an eigenvector of $$(A - \sigma I)^{-1}$$:

$$(A - \sigma I)^{-1} v = \frac{1}{\lambda - \sigma}v = \mu v$$

- Three things are worth noticing:
    - **Same eigenvectors.** $$A$$ and $$(A-\sigma I)^{-1}$$ share the *exact same eigenvectors* $$v$$.
	- **Transformed eigenvalues.** Each eigenvalue $$\lambda_i$$ of $$A$$ maps to $$\mu_i = \dfrac{1}{\lambda_i - \sigma}$$.
	- **The mapping explodes near $$\sigma$$.** The eigenvalue $$\lambda_i$$ *closest to the shift* $$\sigma$$ has the smallest $$\lvert \lambda_i - \sigma \rvert$$, and therefore the **largest** $$\lvert \mu_i \rvert$$.


- Putting these together: the eigenvalue of $$A$$ nearest to $$\sigma$$ becomes the **dominant** eigenvalue of $$(A - \sigma I)^{-1}$$. So we simply apply the plain power method to $$(A-\sigma I)^{-1}$$, and it converges to the eigenvector $$v$$ we were after.

- Finally, we recover the actual eigenvalue of $$A$$ by inverting the map:

$$\lambda = \sigma + \frac{1}{\mu}$$
