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
- **Email:** [your-email@example.com](mailto:your-email@example.com)
- **GitHub:** [https://github.com/your-username](https://github.com/your-username)

