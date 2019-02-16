# RevolutTest

**Tech stack:**  

- `DataDriven` pattern for working with views  
- `SwiftGen` for recources  
- Plain `URLSession` for networking  
- `DI` pattern for dependencies  
- `DispatchSourceTimer` for Sceduling  
- `Redux (ReSwift) + SOA` acrhitecture pattern as base  

**Disclamer:**

I completely understand that Redux is some kind of overengineering for this task. However, I wanted this test to be a demonstration of abilities and not just the simplest solution for the app that only contains one screen. I've never used Redux before, but I've been working with RxFeedbackLoop. And I have decided to try it for this test. I could say that unidirectional flow helped me with this test because the app has a lot of different events, which are mutating the state.