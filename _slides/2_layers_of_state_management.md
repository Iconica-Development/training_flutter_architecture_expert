# Layers of state management 
UI state vs App state vs System state

---
## Different Layers of state management

> In the broadest possible sense, the state of an app is everything that exists in memory when the app is running. This includes the app’s assets, all the variables that the Flutter framework keeps about the UI, animation state, textures, fonts, and so on. While this broadest possible definition of state is valid, it’s not very useful for architecting an app.

---
## Different Layers of state management

- **UI state**
  
  Also known as ephemeral or local state. Contains state regarding a single UI component. The goal is to facilitate UI Functionality like the current page, or the state of a button.

- **App state**
  
  The global state of the app. Anything that lives in memory. 

- **System state**

  State that exists outside of the app. Often a database implementation living on a server in the cloud, but any persisted state falls under this.


---
### UI State

Ephemeral state (sometimes called UI state or local state) is the state you can neatly contain in a single widget.

This is, intentionally, a vague definition, so here are a few examples.

- current page in a PageView
- current progress of a complex animation
- current selected tab in a BottomNavigationBar

Other parts of the widget tree seldom need to access this kind of state. There is no need to serialize it, and it doesn’t change in complex ways.


---
### App State

State that is not ephemeral, that you want to share across many parts of your app, and that you want to keep between user sessions, is what we call application state (sometimes also called shared state).

Examples of application state:

- User preferences
- Login info
- Notifications in a social networking app
- The shopping cart in an e-commerce app
- Read/unread state of articles in a news app

For managing app state, you’ll want to research your options. Your choice depends on the complexity and nature of your app, your team’s previous experience, and many other aspects.

---
### System State

State that exists outside of the scope of the app. Anything that is persisted is considered system state. The only way to access system state is through some form of I/O process.

A couple examples:
- The total count of reactions on a post
- A history of changes made to users
- All users currently connected

---
## What type of state is it?

> “The rule of thumb is: Do whatever is less awkward.”
> 
> _Dan Abramov, Author of Redux_

- A single widget: UI State
- Any other case: App State

**Is a screen not a single widget?**

Yes, and no.

---
### Quiz

I will follow with 15 questions that describe a use case on what state is being saved. Answer these questions to the best of your ability.

---
### Quiz - Question 1

> I want to know the current page for a page indicator.

---
### Quiz - Question 2

> I would like to store the current authentication session.

---
### Quiz - Question 3

> I want to keep track of whether the user has seen the intro screen across multiple sessions.

---
### Quiz - Question 4

> I want to display whether a button press is still in progress.

---
### Quiz - Question 5

> I want to display a loading indicator until my data is loaded.

---
### Quiz - Question 6

> I want to know what step I am in for the current registration.

---
### Quiz - Question 7

> I want to know the status of a planned training.

---
### Quiz - Question 8

> I want to know what page of the data I am at.

---
### Quiz - Question 9

> I want to store user settings

---
### Quiz - Question 10

> I want to change a user setting

---
### Quiz - Question 11

> I want to check the current camera permissions

---
### Quiz - Question 12

> I want to animate a transition between two widgets

### Quiz - Question 13

> I want to validate whether the syntax of an email is correct

### Quiz - Question 14

> I want to validate whether the password does not contain parts of the email

### Quiz - Question 15

> I want to validate whether the email already exists for another user