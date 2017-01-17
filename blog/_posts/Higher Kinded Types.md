# Higher Kinded Types

I remember when I was first learning Haskell, one of the terms being thrown around all the time was higher-kinded types. Coming from OCaml, it was commonly referenced as one of the major differences between the two languages. But as much as I tried to understand, I couldn't grasp what I now see as a simple concept. Every StackOverflow answer, blog post, or article I read about HKTs failed to explain the idea in a way that makes sense to me. It wasn't until I read [a blog post on the repercussions of having HKTs available in C#](http://www.sparxeng.com/blog/software/an-example-of-what-higher-kinded-types-could-make-possible-in-c) that I really started to understand the idea. Here's my attempt at explaining the idea in a way that wouldn't confuse me more.

Anyone learning Haskell, Scala, ML, or another typed functional language can probably assign a type to a short term without much thought. In our hypothetical syntax, it would be trivial to say `1 : Int` and `add 1 : Int -> Int`. If we go a little further and start giving types their own types, we enter the realm of Kinds.

For example, it's pretty obvious that the type of `Int` is going to be `Type`. Somewhat confusingly at first, `Int -> Int` is not `Type -> Type`, but rather `Type` (since the type is not a function in and of itself, but rather a single term). It may make sense to assign a type to `(->)` at this point, which we could make `Type -> Type -> Type`. Notice how the standard types we talk about (`Int`, `Float -> Int`, `(Int, String)`) all fall under the simple `Type`. This is probably weird at first... if we put all types into the same category, what's the use of categorizing them? Even seeing a kind given for `(->)` doesn't help us out much, as it's just some magical operator that's guaranteed to make sense.

## Enter higher-kinded types.

The reason we have for categorizing existing types is in fact due to HKTs. While `List Int : Type` isn't a very useful statement, `List : Type -> Type` is a bit more interesting. Of course, it's not useful to think of `List` here in terms of its values... we aren't planning on writing a function of `(Type -> Type) -> Int` or anything of the sort. Where it gets interesting is when you write generic code. Let's start with a simple example:

```
f : forall (c : Type -> Type), (a : Type), (b : Type).
    c a -> c b
```

Let's not get caught up over the details of defining such a function, but as an exercise it's useful to analyze this type. First of all, you'll notice the rather drawn out `forall` clause. In particular, it's worth noticing the fact that we give the type variables their own types. This is important, because it allows us to make `c` a higher-kinded type here (alternatively, something with more complexity than `Type` alone). Also, try to think of some examples for `c` here: some good ones include `List` and `Option` (or `Maybe`); an invalid example might be `Map` (which is `Type -> Type -> Type`, since we would normally write `Map Int String`).

Now that we've got this basic example in mind, let's think of somewhere we can actually use this concept. We all know parametric polymorphism allows us to write things like functions that can operate on any kind of list (`List a -> (a -> b) -> List b` being the type of `map`). But it's quite hard to relate higher-kinded types as we've seen them so far to any sort of real-world code. In fact, HKTs alone are of little use. It's not until we enter a language with some kind of ad-hoc polymorphism that we can even really use them. To be language-agnostic, I'll define my own system for ad-hoc polymorphism below:

`a -> b | a, b < Number` means "a function from `a` to `b`, where `a` and `b` inherit from the interface `Number`." Less general types would include `Int -> Int` and `Float -> Int` in this case.

For our own use, we will create an interface called `MapFn`. This interface can be inherited by any type with a corresponding `map` function. Let's write a few of these:

```
inherit MapFn for List
  with map f [] = []
       map f (x::xs) = f::(map f xs)

inherit MapFn for Option
  with map f None     = None
       map f (Some x) = Some (f x)
```

With both `List` and `Option` available, it's useful to see some places where it might be helpful to have both within reach without forcing us to rewrite a function each time. For example, `mapTwice` might perform `map` with 2 different functions in a row. Rather than writing a whole interface and its implementations for `MapTwiceFn`, let's try to write this using HKTs.

First of all, we know our function `mapTwice` is going to have a few type variables: `x`, the original type contained by the List/Option; `y`, the result of the first `map` and input to the second `map`; `z`, the result of the second `map`; and `c`, the container to be mapped over (which must either be List or Option). It's also quite easy to write the function itself:

```
let mapTwice f g xs =
  let ys = map f xs
  map g ys
```

Next, we can start to assign types to the individual variables. Let's refine this function:

```
let mapTwice (f : x -> y) (g : y -> z) (xs : c x) =
  let ys : c y = map f xs
  map g ys : c z
```

Finally, let's put together everything we know and give the whole function its type:

```
mapTwice : (x -> y) -> (y -> z) -> c x -> c z
```

And how do we know what `c` is?

```
mapTwice : forall (x : Type), (y : Type), (z : Type), (c : Type -> Type).
           (x -> y) -> (y -> z) -> c x -> c z
           | c < MapFn
```
