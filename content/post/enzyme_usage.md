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

### Forward mode

```
double df_dx = __enzyme_fwddiff<double>((void*)f, enzyme_dup, x, dx); 
```

Here, `double` is the `return_type`. The shadow argument `dx` stores the directional derivative.

e.g., if `x` is a vector of inputs, then

$$
df\_dx = \frac{df}{dx_{0}} \cdot dx[0] + \frac{df}{dx_{1}} \cdot dx[1] + ...
$$


#### Return-By-Value

```
double f(double x) { return x * x; }
```

In this case, we usually use `enzyme_dup` to annotate the input and the shadow argument (the directioal vectors).
The return value is the jacobian-vector product (JVP).

e.g.,
```
double x = 5.0;
double dx = 1.0;
double df_dx = __enzyme_fwddiff<double>((void*)f, enzyme_dup, x, dx); 
printf("f(x) = %f, f'(x) = %f", f(x), df_dx);
```

#### Return-By-Reference

```
void f(double x, double y, double & output) { output = x * y + 1.0 / y; }
```

Still we store the direction vector in the shadow argument, and we use another variable for storing the function output, whose shadow argument stores the JVP.

e.g., 

```
double z = 0;
double dz = 0;
#if 1
__enzyme_fwddiff<void>((void*)f, enzyme_dup, x, dx, 
                                 enzyme_dup, y, dy, 
                                 enzyme_dup, &z, &dz);
```

`z` stores the function primal value and `dz` stores the JVP. We need to pass the reference because we are going to change the value.


### Reverse mode

Reverse mode computes the vector-Jacobian product (VJP). 

#### Return-By-Value

```
struct double2(double x, y;);

auto [mu_x, mu_y] = __enzyme_autodiff<double>((void*)f, enzyme_out, x, enzyme_out, y);
```

Here, if we use `enzyme_out` annotation, the default $\lambda = 1$. 
In this case, the output is the gradients themselves.

#### Return-By-Reference

It looks like that when using reverse mode, we are mostly using `enzyme_out` annotation.

```
double lambda = 2.0;

double2 mu = __enzyme_autodiff<double2>((void*)f, enzyme_out, x, 
                                                  enzyme_out, y, 
                                                  enzyme_dup, &z, &lambda); 
```

The shadow argument w.r.t the output `z` is the `lambda`. The way to annotate the output is passing the pointer.
The function output is the VJP. Again, `double2` is the return type. 


## Using matrix

Only use matrix with fixed size, instead of `MatrixXd`. 




