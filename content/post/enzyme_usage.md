+++
title = "how to use enzyme to compute derivatives"
date = 2025-12-02T10:35:05.787893-05:00
draft = false

[extra]
authors = []
summary = "explain AD library enzyme"
tags = ["research"]

+++

The objective functions in enzyme can be classified into *Return-By-Value* and *Return-by-Reference*. 
In each case, enzyme can use two modes to get the derivatives, i.e., `__enzyme_fwddiff` (forward) and `__enzyme_autodiff` (reverse).
[Enzyme's documentation](https://enzyme.mit.edu/getting_started/Examples/) provides some examples, but lacks explanation. 
I will just add some of my understandings on these examples and also provide some lessons learnt while using Eigen library for matrix computation.

### Return value of forward and reverse mode

For this function, $f(x, y) := xy + \frac{1}{y}$,
the “derivative” (i.e., the Jacobian) of this function is a row vector with two entries:

$$
\begin{bmatrix}
\frac{\partial f}{\partial x} & \frac{\partial f}{\partial y}
\end{bmatrix}
$$


- `__enzyme_fwddiff`

    *forward mode*: compute  
   $$
   d\mathbf{f} := \mathbf{J} \cdot d\mathbf{x},
   $$
   where $d\mathbf{x} = [dx\;\; dy]^\top$
   In this case, the dimension of result of the forward mode is a scalar, i.e., the same as the dimension of the output.

- `__enzyme_autodiff`

    *reverse mode* differentiation*: compute  
   $$
   \mu := \mathbf{J}^\top \lambda
   $$
   here $\lambda$
   is a scalar, for example, if we want the derivative, then $\lambda = 1$
   In this case, the dimention of the result of the reverse mode is a vector, i.e., the same as the dimension of the input.

   In the later sections applying these modes, we will focuse on how to pass $d\mathbf{x}$ and $\lambda$, as well as which variable stores the output.

### Translation unit in the example code snippet

```
#include <iostream>
#include <enzyme/enzyme> 

int enzyme_dup;
int enzyme_dupnoneed;
int enzyme_out;
int enzyme_const;

template < typename return_type, typename ... T >
return_type __enzyme_fwddiff(void*, T ... );

template < typename return_type, typename ... T >
return_type __enzyme_autodiff(void*, T ... );
```

### Return-By-Value + Forward mode






