# FiniteStateMachine FSM Model in Dart

This repository contains a **Finite State Machine (FSM)** model implemented in Dart. The FSM is designed to handle complex state transitions in a structured and scalable manner, making it ideal for applications such as workflows, game development, or any scenario requiring dynamic state management.

---

## **Features**

- **Modular Design:** Separate classes for states, events, and transitions for maximum flexibility.
- **Asynchronous Actions:** Supports async/await for non-blocking operations during state transitions.
- **Entry and Exit Actions:** Execute specific actions when entering or exiting a state.
- **Event Queue:** Ensures proper handling of multiple events by processing them sequentially.
- **Invalid Event Handling:** Detects and logs events that are not valid for the current state.
- **State Stream:** Provides a stream for observing state changes in real time.

---

## **Components**

### 1. **MachineState**

The base class for defining states in the FSM.

### 2. **MachineEvent**

The base class for defining events that trigger state transitions.

### 3. **Transition**

Represents a transition between states, including optional entry, exit, and transition actions.

### 4. **StateWithEntryExit**

An extended state class that allows defining custom entry and exit actions for a state.

### 5. **StateMachine**

The main class that:

- Manages the current state.
- Defines the mapping between states, events, and transitions.
- Handles the execution of actions during state transitions.
- Provides a queue for events to ensure ordered processing.

### 6. **Sequence of Events During a Transition**

When you call stateMachine.addEvent(...), the following actions occur in order:

1. Locate the corresponding transition
   The FSM determines if there is a valid transition based on the current state and the incoming event.
2. Execute transitionExitAction (if defined)
   This step occurs while still in the old state, allowing for cleanup tasks related to that specific transition.
3. Execute stateExitAction (if defined)
   This step handles the general exit logic for leaving the old state, regardless of which event triggered it.
4. Execute transitionAction (if defined)
   This is often used for logic that should happen between exiting the old state and entering the new one— e.g., sending a network request, updating data, etc.
5. Update the currentState
   The FSM sets currentState to the new nextState.
6. Execute transitionEntryAction (if defined)
   A transition-specific action that applies immediately after the state change.
7. Execute stateEntryAction (if defined)
   This is the general entry logic for the new state, setting up anything needed or performing additional initialization.
8. Notify State Change
   The machine may notify observers or trigger a callback to indicate that the state has changed (e.g., a UI update).

No valid transition?
If no transition is defined for (current state + event), the event is ignored (or handled as invalid, depending on your logic).

---

## **How to Use**

### **1. Define Your States**

Create classes extending `MachineState` to define each state in your FSM:

```dart
class IdleState extends MachineState {}
class RunningState extends MachineState {}
```

### **2. Define Your Events**

Create classes extending `MachineEvent` to define the events:

```dart
class StartEvent extends MachineEvent {}
class StopEvent extends MachineEvent {}
```

### **3. Create Transitions**

Define transitions between states using the `Transition` class:

```dart
final startTransition = Transition(
  nextState: RunningState(),
  transitionAction: (context) async {
    print("Starting...");
    return context;
  },
);
```

### **4. Initialize the State Machine**

Set up the FSM by defining its initial state, context, and transition map:

```dart
final Map<Type, Map<Type, Transition>> transitions = {
  IdleState: {
    StartEvent: startTransition,
  },
  RunningState: {
    StopEvent: Transition(
      nextState: IdleState(),
      transitionAction: (context) async {
        print("Stopping...");
        return context;
      },
    ),
  },
};

final stateMachine = StateMachine(
  context: {},
  state: IdleState(),
  transitions: transitions,
);
```

### **5. Add Events**

Trigger events to drive state transitions:

```dart
stateMachine.addEvent(StartEvent());
stateMachine.addEvent(StopEvent());
```

Sequence of Events During a Transition

When you call stateMachine.addEvent(...), the following actions occur in order:

1. Locate the corresponding transition:
   The FSM determines if there is a valid transition based on the current state and the incoming event.
2. Execute transitionAction:
   If a valid transition is found, the optional asynchronous transitionAction(context) runs before changing the state. This is typically used to perform any logic required (e.g., updating data, logging, etc.).
3. Update the currentState:
   The FSM then sets currentState to the nextState defined in the transition, indicating the state change.
4. Execute transitionEntryAction:
   After the state is updated, the FSM invokes the optional transitionEntryAction(context), which can initialize or configure anything needed in the new state.
5. No valid transition?
   If there is no defined transition for (current state + event), the event is ignored (or handled as an invalid scenario, depending on your implementation).


[ Incoming Event ]
|
+– Check if (currentState + event) has a valid transition?
|
+–(Valid)—————————————————––+
|                                                                |
v                                                                |
(1) transitionExitAction()  [OLD STATE CONTEXT]                          |
|                                                                |
v                                                                |
(2) stateExitAction()       [OLD STATE EXIT LOGIC]                       |
|                                                                |
v                                                                |
(3) transitionAction()      [BRIDGE BETWEEN OLD & NEW STATE]             |
|                                                                |
v                                                                |
(4) currentState = nextState (ACTUAL STATE SWITCH)                       |
|                                                                |
v                                                                |
(5) transitionEntryAction() [NEW STATE CONTEXT]                          |
|                                                                |
v                                                                |
(6) stateEntryAction()      [NEW STATE ENTRY LOGIC]                      |
|                                                                |
v                                                                |
(7) Notify State Change      [e.g., UI update or callback]               |
|                                                                |
+—————————————————————+
|
+–(Invalid)–> [Handle or ignore invalid event]

---

## **Installation**

1. Clone the repository:

   ```bash
   git clone https://github.com/<your-username>/fsm_model.git
   cd fsm_model
   ```

2. Include the `fsm_model.dart` file in your Dart project.

3. Ensure your project is set up for asynchronous programming with Dart.

---

## **Examples**

Check out the `examples/` directory for complete usage examples and real-world scenarios.

---

## **Contributing**

Contributions are welcome! Feel free to submit issues or pull requests to enhance the FSM or add new features.

---

## **License**

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## **Contact**

For any questions or suggestions, feel free to reach out:

- **Email:** [iamvaleriofantozzi@gmail.com](mailto:iamvaleriofantozzi@gmail.com)
- **GitHub:** [https://github.com/valeriofantozzi](https://github.com/valeriofantozzi)
