# Casus 
A training System

---
## Description

A simple training administrative system with basic CRUD support. 

All parties involved should be able to view the status of a training.

---
### Actors

- **Administrator**
  - Creates new training types 
  - creates a planning 
  - views statistics
- **Trainer**
  - Views their planned courses
  - Communicates with Students
  - Views their past training results
- **Student**
  - Views their planned courses
  - Views their past training material
  - Provides feedback on a training

---
### Concepts

- **Training**
  - The template of a training
  - Has:
    -  Name
    -  Duration in days
    -  Description
    -  Minimal interested students
    -  A list of course material, either a link or a file.

---
### Concepts

- **Course**
  - An execution of a training
  - The information of the related training can never change
  - Has:
    - A training
    - Planned dates
    - A status

---
### Concepts

- **Training Interest**
  - A student's interest in following a training
  - Has:
    - A training
    - A Student
    - Reasoning
    - A completed status

---
### Concepts

- **Course Participation**
  - A Student's participation in a course
  - Has:
    - A student
    - A course
    - Reasoning
    - Type (Required, Optional)
    - A review

---
### Concepts

- **Course Review**
  - A students feedback on a course
  - Has:
    - trainer ability score
    - trainer ability description
    - training suitability score
    - training suitability description
    - location score
    - location description
    - training quality score
    - training quality description

---
### What are you going to build?

An overview page where a paginated filtered ordered list of trainings is visible, based on the type of user you are. 

Based on the user, you view a training in several categories:

- Student: History, Upcoming, Available
- Trainer: Upcoming, History
- Administrator: All training in one view

Clicking on a training will go to a detail page with different functionality based on the type of user.
  
---
### SDK

- Github link: [https://github.com/Iconica-Development/training_flutter_architecture_expert](https://github.com/Iconica-Development/training_flutter_architecture_expert)

- Pubspec yml definition:
  ```yml
  flutter_architecture_training_sdk:
    git:
      url: https://github.com/Iconica-Development/training_flutter_architecture_expert.git
      path: _sdk/flutter_architecture_training_sdk
      ref: "2024.1"
  ```
  