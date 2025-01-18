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

/// Definition of actions for states and events
typedef StateAction<C> = Future<C?> Function(C context);
typedef EventAction<C> = Future<C?> Function(C context);
typedef StateActionAsync<C> = Future<C?> Function(C context);
typedef EventActionAsync<C> = Future<C?> Function(C context);

/// Base class for states
abstract class MachineState {}

/// Base class for events
abstract class MachineEvent {}

/// Class for transitions
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

/// Class for states with entry and exit actions
abstract class StateWithEntryExit<C> extends MachineState {
  final StateAction<C>? stateEntryAction;
  final StateAction<C>? stateExitAction;

  StateWithEntryExit({this.stateEntryAction, this.stateExitAction});
}

/// Class for state machine model
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
