# Quartz: Towards a statically typed Erlang

Erlang is probably the most widely used functional programming language in the software industry. It's been used by the creators of massive telecom infrastructure, tech giants, video game companies, and various small firms alike to achieve fast, stable network systems running on hundreds of highly distributed nodes. It's hard to argue with Erlang's success, but to many a functional programmer if feels as though it's missing something important.

I'll get right to the point. For users of other functional languages (Haskell, SML, OCaml, F#, ...you get the point), static typing has shown time and time again that it is the single biggest factor to building bug-free code. The classic saying, "if it compiles, it runs" rings true most of the time, allowing not only a cutback on testing, but also less time spent debugging initially (and also later on through earlier bug discovery). While this issue is quite a controversial one in the software industry, for me, at least, strong, static type systems give me a refreshing reassurance as I write code, and I don't think I'm alone.

Does Erlang *really* need static typing? This issue has been debated quite a lot, and many defend its current state (strong, dynamic typing) as one of the redeeming factors of the language that has helped with features like hot-swapping modules. While this notion surely has some substance, I think that this could be accomplished without much hassle (as long as the types check, modules can be swapped; building off of Erlang's infrastructure, one could do this with a statically typed language); in fact, [this feature has been added to Haskell by Facebook](https://code.facebook.com/posts/745068642270222/fighting-spam-with-haskell/), and has existed in Java for quite some time.

Here's how I see it: Erlang has not received a static typing system, because defining a good type system for Erlang has been a struggle. Yes, it has been tried: languages like [Alpaca](https://github.com/alpaca-lang/alpaca) change Erlang into an ML-like language with a run-of-the-mill Hindley-Milner type system. While this does a great job at making Erlang safer, it can only go so far at protecting the user from errors with communicating processes. This is because the `pid` type in the language has no knowledge of context, meaning that it will always be able to send/receive the exact same types as long as the processes stay communicating. As an example, consider the following example:

```
type op = Add | Sub | Mul | Div
type calculator = Start (pid calculator) | Number float | op | Equals
```

For this example, we can clearly sequence the order of these messages: Start should come first (only once), followed by Number, op, Number, Equals (the same order you'd press buttons on a calculator). Yet this option is not present in Alpaca, because there's no state/order embedded in these types, nor is the sender/receiver specified. Instead, you either must match the invalid commands at any stage or use the _ pattern (which leads to unsafe refactoring). This conundrum is what led me to approach the problem of a statically typed Erlang in a new way.

Behavioral/session types were first introduced to me about a year ago when I saw [a cool example of a hack you could do with OCaml's polymorphic variants](https://github.com/kayceesrk/code-snippets/blob/master/behavior.ml). I'm not quite sure how I found that code, but once I had discovered it I immediately began researching session types. The basic idea behind session types is simple: describing communication between processes as sessions (a sequence of back and forth interactions between these processes that can branch off into various paths). The idea had caught my eye, but I didn't have any great ideas for what to do with it at the time.

Some months later, while deciding between a choice of Erlang or Ruby for a project, the idea of the actor model sort of re-clicked in my head. I had already seen Alpaca (at the time, still called MLFE), and, while impressed with the idea, found its applications lacking in practice. I had a feeling that session typing could help, but I didn't know where to start. But once it all clicked for me, I began to think of the actor model as analogous to OOP, and thus decided to design an OOP-like language based on session typing. While it may be a stretch to call my ideas "OOP," the basic language ([Quartz](https://github.com/ohadrau/Quartz)) looks quite object-oriented, and is syntactically similar to Elixir.

In this post I'm not going to describe the specific details of Quartz' type system (look out for this in a future post), but rather talk about how it can help solve a problem that I don't believe has been adequately solved yet. Namely, Quartz uses multi-party session types (sessions in which more than two actors can take part) to express the Erlang type system as accurately as possible, and a brand new type inference algorithm extended from the classic Hindley-Milner system in order to allow for minimal type annotation in sessions. Enough of useless jargon, let's get into examples:

```
session Server()
  let db = open_database()
  branch Login(username, password) from client
    if user_exists(db, username) then
      let token = get_login_token(db, username, password)
      client!Success(token)
    else
      client!Failure
    end
    loop
  end
  branch Ping from client
    let t = get_time()
    client!Pong(t)
    loop
  end
end

session Client(s : Server) # This type annotation is not required
  let time = get_time()
  s!Ping
  branch Pong(t) from s
    let ping = diff_time(t, time)
    print("Ping is: " ++ string_of_time(ping))
  end
end

fun main()
  let server = spawn Server()
  spawn Client(server)
end
```

Looking at the above code, let's start by listing out the guarantees that the type system gives us:
- The client can receive anything the server throws at it
- The server can receive anything the client throws at it
- The client can only receive Pong after sending Ping
- The server can only send Success/Failure after receiving Login
- Since the client *doesn't* send Login, it has no need to implement those branches

More generally, we can state the following:
- To communicate, two sessions must have some overlapping interface
- The receiving session must always implement all branches that can be sent
- Sending/receiving can be nested, so everything happens in order and only the minimum amount of paths must be implemented
- Every message must take the same parameter type and result in a specific session type

So now with all this in mind, let's revisit our original question. Does Erlang *really* need static typing? Let's rephrase this to another question: where would Quartz benefit an Erlang programmer?

To answer that, let's start simple and then start to branch out. Like Alpaca, Quarts provides some regularity to fall back on throughout your code. Types are available as documentation, yet inferred to save time and keep your code no more verbose than the original Erlang. As you refactor code, they remain there to remind you of missing branches in pattern matching (when a union is extended), mismatched function argument (when function arguments are changed/added), and the same general mistakes that static typing has always been said to help. But that's not where I see Quartz going. These issues are already solved for Erlang, whether it be through Alpaca or Dialyzer. And it seems to me that these issues are not so relevant in Erlang either: when so much of the code is focused on message-passing between processes, it seems like that would be where the hardest bugs lie.

For communicating processes, Quartz offers more than the alternatives. Yes, maybe they can reason about missing branches on the receiving end of the process, but the number of false positives is amplified by those options: not only do they force you to deal with "missing branches" at every point in the function, but, due to their inability to tell who's who in the conversation, make the programmer deal with those branches on both ends. Quartz sits in a unique place of having some understanding of your code in context: the use of native session types gives Quartz the ability to deal with message-passing the way it is expressed in your code exactly. Communication does not happen through "channels" that carry a certain type of message; instead, you are allowed to think of communication as a set of 2-way conversations that any actor can conduct (A and D could talk to B and C, and yet not be forced to know of each other in order to have proper type checking). What makes this unique is that not only can conversation properly represent state, even when the cause of that state is not visible from the current session, but that these state changes can be used to sequence the conversation into a proper order.

And thus comes Quartz' secret weapon. Quartz is there to check that each session is on the same page as its counterparts. Messages won't come through out-of-order, because session types are explicit about the order of the conversation. Messages will always make sense, because session types are explicit about the context of the conversation. Whether you're working on the first instance of that session or going back to refactor the message-passing portions of your code, the type system has your back through the whole journey. Unused branches are discarded like functions that never get called, but it is brought to your attention as soon as the new message you started sending can't be received on the other end (whether it's because of a typo, unimplemented branch, or the wrong parameters being sent). Sending an extra message for a second time in a row is caught by the compiler, because it can tell the other side isn't ready for that message at the current moment. Copy-pasted code written for another branch of the conversation will be flagged as irrelevant information, so that you can go back and fix it to make sense.

So put in perspective, I think the original question can be answered. Yes, Erlang needs static typing. And if it needs static types, then it needs them everywhere. For example, hot-swaps are now guaranteed to work correctly (your refactored code still must check against the other processes it's being run with). There's also more of the feeling of "if it compiles, it's right," because the compiler can spot the harder bugs in your program. Like the alternatives, Quartz may bring false positives to the table that will be annoying to existing Erlang programmers. But with the expressive type system offered, Quartz does its best to avoid these moments and focus only on the errors that are most important. And I believe that using the type checker will reinforce your ability to reason about your concurrent code in a way that other type systems cannot.