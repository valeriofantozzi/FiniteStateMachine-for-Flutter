// STATE MACHINE MODEL
// Transition Flowchart:
// [Check Transition]
//   |
//   |--(Valid Transition)---
//   |                        	|
//   |                   [ transitionExitAction ]
//   |                         	|
//   |                         	v
//   |                   [ stateExitAction ]
//   |                         	|
//   |                         	v
//   |                   [ transitionAction ]
//   |                         	|
//   |                         	v
//   |                   [ State --> Next State ]
//   |                         	|
//   |                         	v
//   |                   [ transitionEntryAction ]
//   |                         	|
//   |                         	v
//   |                   [ stateEntryAction ]
//   |                         	|
//   |                         	v
//   |                   [Notify State Change ]
//   |                         	|
//   |                         	v
//   |-----------------(Invalid Transition)--> [Handle Invalid Event]
//   |
//   v
// [End]

import 'dart:async';

/// Definizione delle azioni per gli stati ed eventi
typedef StateAction<C> = Future<C?> Function(C context);
typedef EventAction<C> = Future<C?> Function(C context);
typedef StateActionAsync<C> = Future<C?> Function(C context);
typedef EventActionAsync<C> = Future<C?> Function(C context);

/// Classe base per gli stati
abstract class MachineState {}

/// Classe base per gli eventi
abstract class MachineEvent {}

/// Classe per le transizioni
class Transition<C, S extends MachineState, E extends MachineEvent> {
  final S nextState;
  final EventActionAsync<C>? transitionAction;
  final StateActionAsync<C>? transitionEntryAction;
  final StateActionAsync<C>? transitionExitAction;

  Transition({
    required this.nextState,
    this.transitionAction,
    this.transitionEntryAction,
    this.transitionExitAction,
  });
}

/// Classe per gli stati con azioni di entrata e uscita
abstract class StateWithEntryExit<C> extends MachineState {
  final StateAction<C>? stateEntryAction;
  final StateAction<C>? stateExitAction;

  StateWithEntryExit({this.stateEntryAction, this.stateExitAction});
}

/// Classe per la macchina a stati finiti
// abstract class StateMachine<C, S extends MachineState, E extends MachineEvent> {
//   StateMachine(this.context, this.state, this.transitions);

//   final Map<Type, Map<Type, Transition<C, S, E>>> transitions;
//   S state;
//   C context;
//   final StreamController<S> _stateController = StreamController<S>.broadcast();

//   Stream<S> get stateStream => _stateController.stream;

//   Future<void> close() async {
//     await _stateController.close();
//   }

//   void addEvent(E event) async {
//     final transitionsForState = transitions[state.runtimeType];
//     if (transitionsForState != null) {
//       final transition = transitionsForState[event.runtimeType];
//       if (transition != null) {
//         // Esegui l'azione di uscita associata alla transizione
//         if (transition.transitionExitAction != null) {
//           context = await transition.transitionExitAction!(context) ?? context;
//         }
//         // Esegui l'azione di uscita dello stato corrente
//         if (state is StateWithEntryExit<C>) {
//           final exitAction = (state as StateWithEntryExit<C>).stateExitAction;
//           if (exitAction != null) {
//             context = await exitAction(context) ?? context;
//           }
//         }
//         // Esegui l'azione associata all'evento (azione della transizione)
//         if (transition.transitionAction != null) {
//           context = await transition.transitionAction!(context) ?? context;
//         }
//         // Aggiorna lo stato
//         state = transition.nextState;
//         // Esegui l'azione di entrata associata alla transizione
//         if (transition.transitionEntryAction != null) {
//           context = await transition.transitionEntryAction!(context) ?? context;
//         }
//         // Esegui l'azione di entrata del nuovo stato
//         if (state is StateWithEntryExit<C>) {
//           final entryAction = (state as StateWithEntryExit<C>).stateEntryAction;
//           if (entryAction != null) {
//             context = await entryAction(context) ?? context;
//           }
//         }
//         _stateController.add(state);
//         return;
//       }
//     }
//     // Gestione dell'evento non permesso nello stato corrente
//     handleInvalidEvent(event);
//   }

//   void handleInvalidEvent(E event) {
//     print(
//         'Evento ${event.runtimeType} non permesso nello stato ${state.runtimeType}');
//   }
// }

abstract class StateMachine<C, S extends MachineState, E extends MachineEvent> {
  StateMachine(this.context, this.state, this.transitions);

  final Map<Type, Map<Type, Transition<C, S, E>>> transitions;
  S state;
  C context;

  // Add an event queue
  final List<E> _eventQueue = [];
  bool _isProcessingEvent = false;

  final StreamController<S> _stateController = StreamController<S>.broadcast();
  Stream<S> get stateStream => _stateController.stream;

  Future<void> close() async {
    await _stateController.close();
  }

  void addEvent(E event) {
    _eventQueue.add(event);
    if (!_isProcessingEvent) {
      _processNextEvent();
    }
  }

  Future<void> _processNextEvent() async {
    if (_eventQueue.isEmpty) return;
    _isProcessingEvent = true;
    final event = _eventQueue.removeAt(0);
    await _handleEvent(event);
    _isProcessingEvent = false;
    if (_eventQueue.isNotEmpty) {
      _processNextEvent();
    }
  }

  Future<void> _handleEvent(E event) async {
    final transitionsForState = transitions[state.runtimeType];
    if (transitionsForState != null) {
      final transition = transitionsForState[event.runtimeType];
      if (transition != null) {
        // Execute transition exit action
        if (transition.transitionExitAction != null) {
          context = await transition.transitionExitAction!(context) ?? context;
        }

        // Execute state exit action
        if (state is StateWithEntryExit<C>) {
          final exitAction = (state as StateWithEntryExit<C>).stateExitAction;
          if (exitAction != null) {
            context = await exitAction(context) ?? context;
          }
        }

        // Execute transition action
        if (transition.transitionAction != null) {
          context = await transition.transitionAction!(context) ?? context;
        }

        // Update the state
        state = transition.nextState;

        // Execute transition entry action
        if (transition.transitionEntryAction != null) {
          context = await transition.transitionEntryAction!(context) ?? context;
        }

        // Execute state entry action
        if (state is StateWithEntryExit<C>) {
          final entryAction = (state as StateWithEntryExit<C>).stateEntryAction;
          if (entryAction != null) {
            context = await entryAction(context) ?? context;
          }
        }

        _stateController.add(state);
        return;
      }
    }
    // Handle invalid event
    handleInvalidEvent(event);
  }

  void handleInvalidEvent(E event) {
    print(
        'Evento ${event.runtimeType} non permesso nello stato ${state.runtimeType}');
  }
}
