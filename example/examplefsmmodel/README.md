# Example Flutter FSM

A minimal Flutter example demonstrating how to implement a **Finite State Machine (FSM)** in Dart.  
This project contains **only** the essentials to keep it simple and easy to understand.

---

## Project Structure

my_fsm_example/
├── lib/
│ ├── example_fsm.dart // FSM implementation (states, events, transitions)
│ └── main.dart // Minimal Flutter app demonstrating the FSM
└── pubspec.yaml // Minimal pubspec to run the project

---

## How to Run

1. **Clone or download** this repository.
2. Navigate to the project directory in a terminal:

   ```bash
   cd my_fsm_example
   ```

3. Fetch dependencies:

   ```bash
    flutter pub get
   ```

4. Run the app on your device or emulator:

   ```bash
   flutter run
   ```

5. You should see a simple UI with three buttons: Start Wizard, Next Step, and Reset Wizard.
   • Press each button in sequence to see the FSM in action.

## How It Works

    • States:
    • IdleState
    • StepOneState
    • StepTwoState
    • CompletedState
    • Events:
    • StartWizardEvent
    • NextStepEvent
    • ResetWizardEvent
    • Transitions:
    • IdleState → StepOneState on StartWizardEvent
    • StepOneState → StepTwoState on NextStepEvent
    • StepTwoState → CompletedState on NextStepEvent
    • Any state → IdleState on ResetWizardEvent (when defined in that state)

In main.dart, a small UI sends these events to the WizardStateMachine, which updates the current state and triggers the appropriate logic.

## Notes

• Flutter may generate platform-specific folders like android/, ios/, web/, etc. If you prefer a minimal example, you can ignore or remove these from your version control.
• You can safely remove .idea/ or other IDE configuration files from the repository, as they are not required to run the app.

## License

Feel free to use this example as you wish. It is intended purely as a starting point for learning and experimenting with finite state machines in Flutter/Dart. If you plan to use it in a production environment, please ensure you adapt or extend it to meet the needs of your application.
