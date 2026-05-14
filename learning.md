# ⚠️DISCLAIMER: All of this is AI GENERATED — DOUBLE CHECK WITH REAL SOURCES AS THEY COULD BE OUTDATED OR FALSE
 
# Learning

This is simply here to understand and learn the swift language. 
Content has nothing to do with the actual project, but can serve to be useful when needing a quick reference for swift


# Swift Access Levels

From most to least permissive:

| Level | Accessible from |
|---|---|
| `open` | Any module — can also subclass/override |
| `public` | Any module — no subclassing/overriding |
| `internal` | Anywhere in the same module *(default)* |
| `fileprivate` | Same `.swift` file only |
| `private` | Enclosing declaration only |

```swift
open class Animal { }              // subclassable from outside module
public func fetchUser() { }        // usable from outside module
func helperFunc() { }              // internal by default
fileprivate var cache: [String] = []
private var count = 0
```

**In practice:** you'll mostly use `private` for implementation details and `public` if building a package. Everything else defaults to `internal`.

# Type Narrowing
```swift
```
// ❌ won't compile — compiler can't guarantee it's still non-nil
if changedSession != nil {
    session.name = changedSession!.name
}

// ✅ if let — binds to a new non-optional constant
if let changedSession {
    session.name = changedSession.name
}

// ✅ guard let — exits early, use when nil is the failure case
guard let changedSession else { return }
session.name = changedSession.name
```
```

# Doc Comments Structure

```swift
```
```swift
/// Short one-line summary.
///
/// Longer description if needed — explain the why,
/// edge cases, or behaviour that isn't obvious.
///
/// - Parameters:
///   - paramOne: What it is and any constraints.
///   - paramTwo: What it is. Pass `nil` to skip.
/// - Returns: What comes back, or what `nil` means.
/// - Throws: When and why this throws.
/// - Note: Side effects, thread safety, or gotchas.
/// - Warning: Breaking behaviour or deprecation info.
///
/// ## Example
/// ```swift
/// let result = myFunc(paramOne: "hello", paramTwo: nil)
/// ```
func myFunc(paramOne: String, paramTwo: String?) throws -> String { }

```
```

# Swift Naming Conventions

## Casing
| Thing | Convention | Example |
|---|---|---|
| Types, protocols | `UpperCamelCase` | `SessionManager`, `Codable` |
| Functions, variables, params | `lowerCamelCase` | `fetchUser()`, `sessionId` |
| Constants | `lowerCamelCase` | `let maxRetries = 3` |
| Enums cases | `lowerCamelCase` | `.success`, `.notFound` |

## Functions
Name by what they do, not how they do it. If they return something, read like a noun phrase:

```swift
// ❌
func doSessionUpdate() { }
func getData() -> Session { }

// ✅
func updateSession() { }
func session(for id: Int64) -> Session { }
```

## Booleans
Should read as an assertion:
```swift
// ❌
var loading = true
var error = false

// ✅
var isLoading = true
var hasError = false
var canSubmit = true
```

## Argument labels
Omit when obvious, use to read like a sentence at the call site:
```swift
// ❌ redundant
session.update(session: newSession)

// ✅ reads naturally
session.update(with: newSession)
updateSession(sessionId: 1, newName: "Work")
```

# `Task {}` in Swift vs TypeScript

Both are ways to fire off async work from a sync context.

## Swift

```swift
Task {
    let data = await fetchData()
    print(data)
}
```

## TypeScript

```typescript
// async IIFE
(async () => {
    const data = await fetchData()
    console.log(data)
})()

// or void a promise
void fetchData().then(data => console.log(data))
```

## Key idea

Neither makes the surrounding function async — they just spin up an async context inline.
