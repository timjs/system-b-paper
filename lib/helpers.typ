
//// Functions ////

#let identity(it) = it
#let always(it) = (other) => it
#let compose(..fs) = (x) => fs.pos().rev().fold(x, (x, f) => f(x))
#let flip(f) = (x, y) => f(y, y)
#let tap(a, f) = {f(a); a}
#let twice(f) = (x) => f(f(x))

#let spread(xs, n, f) = xs.pos().chunks(n).map(f).flatten()
// #let spread(xs, n, f) = chunks(xs.pos(), n).map(f).flatten()


//// Units ////

#let pc = 1/6 * 1in


//// Ratios ////

#let ratio(x) = x * 100%
#let ratio-of(x) = ratio(1/x)


//// Sizes ////

#let sqrt-sqrt-2 = twice(calc.sqrt)(2)
// Note: we can only raise integers and floats to a power, not lengths like `sqrt-sqrt-2 * 1em`
#let sq(n) = calc.pow(sqrt-sqrt-2, n) * 1em

// #let tiny     = sq(-2) // pandoc: Negative exponent
// #let small    = sq(-1) // pandoc: Negative exponent
#let normal   = sq( 0)
#let medium   = sq(+1)
#let big      = sq(+2)
#let huge     = sq(+3)
#let enormous = sq(+5)


//// Spaces ////

#let w = v.with(weak: true)
#let skip = compose(w, sq)
#let strut = box(height: 1em, width: 0pt, baseline: 0.3em)


//// Pages ////

#let even-page() = calc.rem(counter(page).get().at(0), 2) == 0
#let odd-page() = not even-page()


//// Alternatives ////

#let chunks(a, n) = {
  let r = ()
  for i in range(int(a.len()/n)) {
    r.push(a.slice(i*n, count: n))
  }
  r
 }
