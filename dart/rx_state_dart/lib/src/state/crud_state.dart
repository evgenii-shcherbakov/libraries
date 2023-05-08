import '../common/subject.dart';
import '../types/observable.dart';

/// Main class for build state using Subjects
abstract class CrudState<Entity, Id> {
  /// Subject for store list of entities
  final Subject<List<Entity>> _entities$ = Subject([]);

  /// Subject for store current entity
  final Subject<Entity?> _current$ = Subject(null);

  /// Subject for store current entity id
  final Subject<Id?> _currentId$ = Subject(null);

  /// Way to get entity id
  final Id Function(Entity) _getIdStrategy;

  CrudState(this._getIdStrategy);

  /// Public version of entities Subject
  Observable<List<Entity>> get entities$ {
    return _entities$;
  }

  /// Public version of current Subject
  Observable<Entity?> get current$ {
    return _current$;
  }

  /// Public version of current id Subject
  Observable<Id?> get currentId$ {
    return _currentId$;
  }

  List<Entity> getEntities() => _entities$.get();
  Entity? getCurrentOrNull() => _current$.get();
  Entity getCurrent() => _current$.get() ?? (throw Exception('Current is null'));
  Id? getCurrentIdOrNull() => _currentId$.get();
  Id getCurrentId() => _currentId$.get() ?? (throw Exception('Current id is null'));

  /// Method for compare ids of two entities
  bool _compareIds(Entity firstEntity, Entity secondEntity) {
    return _getIdStrategy(firstEntity) == _getIdStrategy(secondEntity);
  }

  /// Method for update list of entities
  void setEntities(List<Entity> value) {
    _entities$.set(value);
  }

  /// Method for add single entity
  void addEntity(Entity entity) {
    _entities$.set([...getEntities(), entity]);
  }

  /// Method for update single entity
  void updateEntity(Entity entity) {
    _entities$.set(getEntities().map((e) => _compareIds(e, entity) ? entity : e).toList());
  }

  /// Method for remove entity by id
  void removeEntityById(Id id) {
    _entities$.set(getEntities().where((entity) => _getIdStrategy(entity) != id).toList());
  }

  /// Method for update current Subject value
  void setCurrent(Entity? value) {
    _current$.set(value);
  }

  /// Method for update current id Subject value
  void setCurrentId(Id? value) {
    _currentId$.set(value);
  }
}
