# Storage, Communication and Single Source of Truth

---
## Architectural overview

Flutter is the interaction point for the end user within your information system.

The amount of responsibilities the app has depends on your architectural choices and the kind of app you are building.

---
### Architectural overview: Rest

When your flutter app communicates with a RESTful backend your app will be the shell that represents the data and interaction of your backend.

The app should contain minimal domain logic and constraints, they should be centralized inside your backend. 
Validation in the app does not guarantee validated correct requests to your backend.

---
Also, do not use the app's design to dictate the interaction of the backend. Define a logical interface according to REST or your backend principle of choice, and then define the interactions as 1 or more calls for your specific needs in the app.

> A good alternative for central backends and minimal communication is to use graphQL, which flutter as full support for. 
> https://pub.dev/packages/graphql

---
### Architectural overview: Application platforms or Backends as a service

When you use backend as a service, like firebase, amazon amplify or supabase, the app is responsible for handling all domain logic.

The app still can be modified or its network communication sniffed, meaning that users with malicious intent can see and or modify your data.

Each platform should have (if not, do not use it) some sort of constraint enforcement. Firebase firestore has rules for example. 

Writing strict constraints on the flutter side is required for a good app, but can lead to a false sense of security. Always set your rules.

---
## Security Concerns

Flutter is an open source framework and your app will often depend on a lot of packages.
These packages can affect the security of your app, and it is important that you are aware of the quality of these packages.

To ensure optimal security within the framework:
- Keep current with the latest Flutter SDK releases. 
- Keep your application’s dependencies up to date.
- Keep your copy of Flutter up to date.

---
### Security: Storing data

Do not store unencrypted data locally that you do not want other people to see or modify.

SharedPreferences and file storage are not secure and mainly good for application logic and caching

Use the secureStorage package for storing important data, like access tokens.

Never add API keys into your flutter app if you do not want others to use them. Prefer to create a proxy backend in which you verify your users and so you can keep track of the usage of API keys.

---
### Security: Communicating with backends

If you communicate with a backend and have some form of authentication, do not keep sending the original authentication data but use access tokens. If you want to improve security, add an expiration to it to minimize abuse if intercepted.

Always communicate through https or wss. Often people are on public networks on their phone, you can never trust the network to be secure.

---
## Eventual Consistency

Whenever you deal with a multi-user application, you often want the changes of one user reflect the changes of another. 
Instant communication is impossible, so we need to consider changes happening at the same time. 

---
## Eventual Consistency

For a proper user interaction, you do not want to block until another action has completed. You cannot guarantee consistency, therefor you need keep a single source of truth, which you eventually update. 
On top, whenever communication is limited, for example due to poor internet connection, you want to allow the user as much interaction. You should validate this at a later stage.

---
## Eventual Consistency

Platforms like firebase have built-in eventual consistency and delta merging.

---
## Realtime communication in Flutter

For flutter, as with many other apps, you have several options for realtime communication. Depending on the architectural needs, you will often pick one of the following three:

- Websockets: Realtime two way messages
- Longpolling: Maintain an open connection
- Polling: Rapidly send requests.
- SSE: Listen to a stream of events sent by the server

When dealing with mobile apps, all 4 can be hard to manage if they are always live, as the app will kill or freeze processes 

---
## Realtime communication: Websockets

Websockets are great for interactivity, but should be opened and closed only when needed. 

Do not require you to send headers, but also makes it harder to validate authentication.

If connection breaks after the server sends a message, we can see a message being lost, causing inconsistency.

> use https://pub.dev/packages/web_socket_channel

---
## Realtime communication: Polling

Polling is really chatty and sends headers for each request. 

This can be costly when the user is on a limited internet plan.
Always consider that your user has limited internet access.

Because polling is the only way where the server does not initiates the message, we have a more robust ensurance that no messages are lost.

You can add a low frequency polling with hash validation alongside a websocket or longpolling implementation to ensure data consistency.

> Use the http packages to send requests in combination with the Timer from dart:async

---
## Realtime communication: Long Polling

Long polling keeps a connection open, after which the server responds as soon as there is a message.
This means you have a longstanding open http connection, which is harder to handle. 

Another disadvantage is that browsers can only maintain a certain low amount of connections at the same time.

If multiple messages need to be sent by the server, Long polling is also not the right option, as the connection will close on the first message, allowing for a short gap in connection everytime a message is received. 

---
## Realtime communication: Server sent events

Server sent events, or event streaming, is a protocol which uses the `text/event-stream` mimetype. This is allows the server to send partial text packets. Because the server initiates the communication, it can be used for many realtime connection use-cases. 

In flutter, there is not a widespread accepted package to solve this, but using the `http` package it is not a big hassle to implement.

After the connection is established the server initiates all messages. So it is up to the client developer to keep track of the connection. 

If events are given a timestamp and are persisted on the server side, a quick recovery can be made by listening to all events since the last known time.

---
## Single Source of Truth

Whatever your choice of storage or communication, you need to always define a consistent Single source of truth. 

Any application with central server, will have the data coming from the server as the source of truth.
