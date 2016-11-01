#Genmaicha
Genmaicha is a language for graphic design.
You can use it to lay out documents and create reactive interfaces for the web.
It is a single language that compiles down to HTML CSS and JAVASCRIPT.

Examples
--------
#### Variables & Mappings

```
a: 5
b: "hello"
c: false

d: (a+5*20) //105
e: b + " " + "world" //hello world
f: false and false //true
```

You can only define a variable once. This is because you are defining a variable *over time*. When one variable changes it's value all the depenant variables update.
```
doubleX: mouseX * 2 //whenever the user moves the mouse, doubleX will update automatically
```

#### Functions
Functions take an argument list and define an abstracted mapping that can be used multiple times
```
multiplyAndAdd: (a,b,c) -> a*b+c
multiplyAndAdd(1, 2, 3) //five
multiplyAndAdd(3, 2, 1) //seven
```
Multiline functions are defined by using indentation. The last line is the implied return.
```
multiplyAndAdd: (a,b,c) ->
	d:a*b
	d+c

multiplyAndAdd(1, 2, 3) //five
```

#### When statements
*when* is Genmaicha's version of *if*. You can assign variables based on conditionals.
```
name: when id==5: "foo" else: "bar"
```

#### Arrays
An array is defined with square brackets. They can contain any kind of variable.
```
list: [1,"john",false]
matrix: [[1,2],[3,4]]
```
Arrays can be *unfolded*. Which means that the array gets sequentialized over time, and can be treated just as any other variable.
```
list: [1,2,3]
newlist: unfold list as element: element * 5   //[5,10,15]
```

Design philosophy
-----------------

#### Abstraction over time
Programming interactive graphics is hard because keeping track of state and propagating change is hard. Genmaicha completely abstracts away all the noodley event handeling for you, and all you are left with is neat declarative wabi-sabi.

TODO
-----------------
* recursive state
* dealing with parenthesized expresssions (that don't conflict with lists)
