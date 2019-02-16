# Currencies

There are two examples of my code. One was made as easy as possible. And another one with all fancy architecture and testing. This is the second one, another you can get by [the link](https://github.com/Atimca/PhotoGallerys)

**Task:**

The app must download and update rates every 1 second [using API](https://revolut.duckdns.org/latest?base=EUR). List all currencies you get from the endpoint (one per row). Each row has an input where you can enter any amount of money. When you tap on currency row it should slide to top and its input becomes first responder. When you’re changing the amount the app must simultaneously update the corresponding value for other currencies. Use swift programming language and any libraries you want. UI does not have to be exactly the same, it’s up to you. Unit tests must be included. Don’t use Rx. [Video demo](https://youtu.be/omcS-6LeKoo)

**Tech stack:**

- `DataDriven` pattern for working with views  
- `SwiftGen` for recources  
- Plain `URLSession` for networking  
- `DI` pattern for dependencies  
- `DispatchSourceTimer` for Sceduling  
- `Redux (ReSwift) + SOA` acrhitecture pattern as base  

**Disclamer:**

I completely understand that Redux is some kind of overengineering for this task. However, I wanted this test to be a demonstration of abilities and not just the simplest solution for the app that only contains one screen. I've never used Redux before, but I've been working with RxFeedbackLoop. And I have decided to try it for this test. I could say that unidirectional flow helped me with this test because the app has a lot of different events, which are mutating the state.