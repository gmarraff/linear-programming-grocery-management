# Linear Programming Shopping Helper
This repo contain an experiment with linear programming in Ruby. It is essentialy a way to minimize the cost of the grocery supply and use a powerful tool like Linear Programming in a User Friendly application contest.<br>
The goal of this project was to implement a LP model in a programming language and provide an UI to interact with it.
Poorly i didn't have the time to complete it due to other commitments and at this time (24/06/2018) i've only implemented a working model in AMPL and in Ruby using ruby-cbc, but in the future nothing prevents me to cotinue with this project and implement a working UI in Ruby On Rails. <br>
I choose to write this readme from my point of view like a story to improve my english (i'm italian) and my storytelling skills. <br>
I hope you'll enjoy it!
## Background
In the last quarter of 2017 i was following a course of Operative Research (an introduction to Linear Programming and its basic alghoritms) at the University Of Padua and i was really fascinated by the existence of a standardized way to write optimization problems and by the presence of a bunch of alghoritms that do the dirty work for you, so i thought: why not learn it with a real life problem? <br>
## The Idea
I often deal with the problem of the empty fridge, i need to optimize my monthly expense to balance life and survival, i'm looking for an optimization problem... The solution was under my eyes: let's optimize my shopping list! <br>
Ok, now my goal is fixed but i need some bound: it's easy to optimize the gorcery's list if i only buy the cheapest pasta and the end of dreams looking tomato's sauce, i need to live not to survive! <br>
## Linear Programming Model
The first thing to do is to differentiate: i can't eat the same thing everyday and i need a different set of food for lunch and dinner (breakfast wasn't included in the model because coffe is enough for me). Let's see, i found the firsts sets: meals and recipes, what i need to make a recipe? Ingredients! But i don't know a place that sell the exact amount of ingredient that i need to cook a generic plate, the mall only sells package of food... That's it, the last set: packages. <br>
Now that i have in mind the domain of my problem i need the variables, what output have the computer to elaborate? If i want to optimize, i need the perfect combination of packages to buy to eat for a fixed amount of time. <br>
To summarize:
* Recipes (combination of different ingredients)
* Meals (categorization of recipes for lunch and dinner)
* Packages (fixed quantity of a certain ingredient)
* Ingredients (the smallest unit of this problem)

Where to put the bounds?<br>
I need a minimum amount of lunchs and dinners (i usually go to the mall once a week so let's do 7/7), i need a variation of recipes, i may want to eat a maximum or a minimum of a certain recipe, i may have some ingredients in my food storage that i don't need to buy. So i found the params for my problem: <br>
* Meals variation
* Recipe's limits
* Ingredients in the storage

There's another thing that i need to complete my data set: prices. A quick search on my mall's website revealed me the common price so i decided to use those.<br>
The last thing i need is to reorganize my thoughts in a formal way to make my problem machine readable. <br>
You can find the result under the AMPL folder (is written with the AMPL syntax, as a student i got the license for a limited amount of time).
## User-Friendly Application
Wow! The model work and i'm reciving usable solution, let's try this for a real shopping session! The first attempt was succesful, you can find the analysis under the analysis folder of the repo (poorly it's written in italian). <br>
Yeah... The model work but everytime i need to go to the mall i have to compile tables of data and every time i do that i make mistakes, this thing isn't really usable (i don't know if you are familiar with .dat files of AMPL, but they're just block of plain text organized in tabular way and because is a LINEAR problem, you need to fill every empty data with 0s). <br>
I need a good interface that i can use everywhere i go, why not write down a  good ol' web application?
I worked on some Ruby on Rails project's and i know the development speed it has once you understand it, so it's the ideal choice to let me focus on the linear programming part.

## Tool Selection
Now that i have the working model on my pc and a technology stack selected i need a powerful tool that solve the first and fit the second. I'm a student and, hopefully, the license for AMPL will not last forever. So i need something that works in Ruby and doesn't cost much, even better if it's free. <br>
For this kind of requirments, the solution often comes with the name of "Open Source"; yes i know that free software is not free beer but is also true that a lot of the open source software you can find on the internet comes with no price (or a voluntary donation). <br>
I'm not familiar with the Linear Programming world so i need some research to find the best tool the fit with this project. A fast research on google reveals this study: <br>
http://prod.sandia.gov/techlib/access-control.cgi/2013/138847.pdf<br>
Of course i jumped immediatly on the Conclusion section but times later i thought: it may be an interesting read! And it was, i read it in it's entirety and i strongly raccomend you to do the same!<br>
So the article suggest that the best open software for linear programming available at the time was CLP, also known as Coin-OR Linear Programming. There's a Ruby version of it? <br>
https://github.com/gverger/ruby-cbc <br>
Gotcha! A good Ruby wrapper for the CBC project that contains the CLP simplex solver, time to get my hand on this!
## Workflow
### Data
### Model
### Solution

## Whats'next?
