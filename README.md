# university_library

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


What is the difference between the Model, View, and ViewModel in this application?

What should happen if a student attempts to borrow a book that already has an active loan?

Why is it better to calculate the fine in one place rather than repeating the formula in multiple widgets?

What is the difference between a book being Overdue and being Missing?

If the university changes its weekly fine from Rp5,000 to Rp7,000, how should the app be updated?

Answer 

1. Viewmodel is like logic behind how things should end that also work the data from model  ( what type being used or what data are required ) so the View can show the UI


2. If there any book that has been borrow and has active loan , they can't because they already being borrow except if the book has 2 in the library
but in the code there are no same book more than 1  too

3. having a place that already success is best choice to have consistenty rather than try to risk that maybe some widgets that maybe not compatible or even fails (DRY) , also it is more easy to update and testing too

4. Overdue is they already over than they promise so they still have to pay bill for but being missing they already far ahead than they promise and rules carried
so not only the have to replace the book but also pay the bill that they haven't pay

5. I think the should look to the viewmodel because that is where the logic work
and then search where they charged fine weekly fine ( 5000 ) with the code in ( Single source of Truth or in center variabel) and if the code is being hardcoded we have to change the variable one by one that makes the codes more risky to fails"# Lab06--University-Library-System-MVVM-in-Flutter-208602251006" 
