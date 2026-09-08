// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PeopleTable extends People with TableInfo<$PeopleTable, Person> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PeopleTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Me'),
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Me'),
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _linkedUserIdMeta = const VerificationMeta(
    'linkedUserId',
  );
  @override
  late final GeneratedColumn<String> linkedUserId = GeneratedColumn<String>(
    'linked_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    displayName,
    firstName,
    lastName,
    linkedUserId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'people';
  @override
  VerificationContext validateIntegrity(
    Insertable<Person> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('linked_user_id')) {
      context.handle(
        _linkedUserIdMeta,
        linkedUserId.isAcceptableOrUnknown(
          data['linked_user_id']!,
          _linkedUserIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Person map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Person(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      linkedUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}linked_user_id'],
      ),
    );
  }

  @override
  $PeopleTable createAlias(String alias) {
    return $PeopleTable(attachedDatabase, alias);
  }
}

class Person extends DataClass implements Insertable<Person> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String displayName;
  final String firstName;
  final String lastName;
  final String? linkedUserId;
  const Person({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.displayName,
    required this.firstName,
    required this.lastName,
    this.linkedUserId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    map['display_name'] = Variable<String>(displayName);
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || linkedUserId != null) {
      map['linked_user_id'] = Variable<String>(linkedUserId);
    }
    return map;
  }

  PeopleCompanion toCompanion(bool nullToAbsent) {
    return PeopleCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      displayName: Value(displayName),
      firstName: Value(firstName),
      lastName: Value(lastName),
      linkedUserId: linkedUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedUserId),
    );
  }

  factory Person.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Person(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      displayName: serializer.fromJson<String>(json['displayName']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      linkedUserId: serializer.fromJson<String?>(json['linkedUserId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'displayName': serializer.toJson<String>(displayName),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'linkedUserId': serializer.toJson<String?>(linkedUserId),
    };
  }

  Person copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    String? displayName,
    String? firstName,
    String? lastName,
    Value<String?> linkedUserId = const Value.absent(),
  }) => Person(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    displayName: displayName ?? this.displayName,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    linkedUserId: linkedUserId.present ? linkedUserId.value : this.linkedUserId,
  );
  Person copyWithCompanion(PeopleCompanion data) {
    return Person(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      linkedUserId: data.linkedUserId.present
          ? data.linkedUserId.value
          : this.linkedUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Person(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('displayName: $displayName, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('linkedUserId: $linkedUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    displayName,
    firstName,
    lastName,
    linkedUserId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Person &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.displayName == this.displayName &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.linkedUserId == this.linkedUserId);
}

class PeopleCompanion extends UpdateCompanion<Person> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String> displayName;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> linkedUserId;
  final Value<int> rowid;
  const PeopleCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.displayName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.linkedUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PeopleCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.displayName = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.linkedUserId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Person> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? displayName,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? linkedUserId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (displayName != null) 'display_name': displayName,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (linkedUserId != null) 'linked_user_id': linkedUserId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PeopleCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String>? displayName,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String?>? linkedUserId,
    Value<int>? rowid,
  }) {
    return PeopleCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      displayName: displayName ?? this.displayName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      linkedUserId: linkedUserId ?? this.linkedUserId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (linkedUserId.present) {
      map['linked_user_id'] = Variable<String>(linkedUserId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PeopleCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('displayName: $displayName, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('linkedUserId: $linkedUserId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalTeamsTable extends PersonalTeams
    with TableInfo<$PersonalTeamsTable, PersonalTeam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalTeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    personId,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalTeam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    } else if (isInserting) {
      context.missing(_personIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalTeam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalTeam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $PersonalTeamsTable createAlias(String alias) {
    return $PersonalTeamsTable(attachedDatabase, alias);
  }
}

class PersonalTeam extends DataClass implements Insertable<PersonalTeam> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String personId;
  final String name;
  const PersonalTeam({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.personId,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    map['person_id'] = Variable<String>(personId);
    map['name'] = Variable<String>(name);
    return map;
  }

  PersonalTeamsCompanion toCompanion(bool nullToAbsent) {
    return PersonalTeamsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      personId: Value(personId),
      name: Value(name),
    );
  }

  factory PersonalTeam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalTeam(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      personId: serializer.fromJson<String>(json['personId']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'personId': serializer.toJson<String>(personId),
      'name': serializer.toJson<String>(name),
    };
  }

  PersonalTeam copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    String? personId,
    String? name,
  }) => PersonalTeam(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    personId: personId ?? this.personId,
    name: name ?? this.name,
  );
  PersonalTeam copyWithCompanion(PersonalTeamsCompanion data) {
    return PersonalTeam(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      personId: data.personId.present ? data.personId.value : this.personId,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalTeam(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('personId: $personId, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    personId,
    name,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalTeam &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.personId == this.personId &&
          other.name == this.name);
}

class PersonalTeamsCompanion extends UpdateCompanion<PersonalTeam> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String> personId;
  final Value<String> name;
  final Value<int> rowid;
  const PersonalTeamsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.personId = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalTeamsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String personId,
    required String name,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       personId = Value(personId),
       name = Value(name);
  static Insertable<PersonalTeam> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? personId,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (personId != null) 'person_id': personId,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalTeamsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String>? personId,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return PersonalTeamsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      personId: personId ?? this.personId,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalTeamsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('personId: $personId, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamsTable extends Teams with TableInfo<$TeamsTable, Team> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('mens'),
  );
  static const VerificationMeta _settingsMeta = const VerificationMeta(
    'settings',
  );
  @override
  late final GeneratedColumn<String> settings = GeneratedColumn<String>(
    'settings',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(defaultTeamSettings),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    name,
    type,
    settings,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Team> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    if (data.containsKey('settings')) {
      context.handle(
        _settingsMeta,
        settings.isAcceptableOrUnknown(data['settings']!, _settingsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Team map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Team(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      settings: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings'],
      )!,
    );
  }

  @override
  $TeamsTable createAlias(String alias) {
    return $TeamsTable(attachedDatabase, alias);
  }
}

class Team extends DataClass implements Insertable<Team> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String name;
  final String type;
  final String settings;
  const Team({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.name,
    required this.type,
    required this.settings,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['settings'] = Variable<String>(settings);
    return map;
  }

  TeamsCompanion toCompanion(bool nullToAbsent) {
    return TeamsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      name: Value(name),
      type: Value(type),
      settings: Value(settings),
    );
  }

  factory Team.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Team(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      settings: serializer.fromJson<String>(json['settings']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'settings': serializer.toJson<String>(settings),
    };
  }

  Team copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    String? name,
    String? type,
    String? settings,
  }) => Team(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    name: name ?? this.name,
    type: type ?? this.type,
    settings: settings ?? this.settings,
  );
  Team copyWithCompanion(TeamsCompanion data) {
    return Team(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      settings: data.settings.present ? data.settings.value : this.settings,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Team(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('settings: $settings')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    name,
    type,
    settings,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Team &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.name == this.name &&
          other.type == this.type &&
          other.settings == this.settings);
}

class TeamsCompanion extends UpdateCompanion<Team> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String> name;
  final Value<String> type;
  final Value<String> settings;
  final Value<int> rowid;
  const TeamsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.settings = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String name,
    this.type = const Value.absent(),
    this.settings = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<Team> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? settings,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (settings != null) 'settings': settings,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String>? name,
    Value<String>? type,
    Value<String>? settings,
    Value<int>? rowid,
  }) {
    return TeamsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      name: name ?? this.name,
      type: type ?? this.type,
      settings: settings ?? this.settings,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (settings.present) {
      map['settings'] = Variable<String>(settings.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('settings: $settings, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeamMembersTable extends TeamMembers
    with TableInfo<$TeamMembersTable, TeamMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeamMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    userId,
    role,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'team_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeamMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeamMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeamMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
    );
  }

  @override
  $TeamMembersTable createAlias(String alias) {
    return $TeamMembersTable(attachedDatabase, alias);
  }
}

class TeamMember extends DataClass implements Insertable<TeamMember> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String teamId;
  final String userId;
  final String role;
  const TeamMember({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.teamId,
    required this.userId,
    required this.role,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    map['team_id'] = Variable<String>(teamId);
    map['user_id'] = Variable<String>(userId);
    map['role'] = Variable<String>(role);
    return map;
  }

  TeamMembersCompanion toCompanion(bool nullToAbsent) {
    return TeamMembersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      teamId: Value(teamId),
      userId: Value(userId),
      role: Value(role),
    );
  }

  factory TeamMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeamMember(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      teamId: serializer.fromJson<String>(json['teamId']),
      userId: serializer.fromJson<String>(json['userId']),
      role: serializer.fromJson<String>(json['role']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'teamId': serializer.toJson<String>(teamId),
      'userId': serializer.toJson<String>(userId),
      'role': serializer.toJson<String>(role),
    };
  }

  TeamMember copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    String? teamId,
    String? userId,
    String? role,
  }) => TeamMember(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    teamId: teamId ?? this.teamId,
    userId: userId ?? this.userId,
    role: role ?? this.role,
  );
  TeamMember copyWithCompanion(TeamMembersCompanion data) {
    return TeamMember(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      userId: data.userId.present ? data.userId.value : this.userId,
      role: data.role.present ? data.role.value : this.role,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeamMember(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('userId: $userId, ')
          ..write('role: $role')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    userId,
    role,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeamMember &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.teamId == this.teamId &&
          other.userId == this.userId &&
          other.role == this.role);
}

class TeamMembersCompanion extends UpdateCompanion<TeamMember> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String> teamId;
  final Value<String> userId;
  final Value<String> role;
  final Value<int> rowid;
  const TeamMembersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.userId = const Value.absent(),
    this.role = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeamMembersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String teamId,
    required String userId,
    required String role,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       userId = Value(userId),
       role = Value(role);
  static Insertable<TeamMember> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? teamId,
    Expression<String>? userId,
    Expression<String>? role,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (teamId != null) 'team_id': teamId,
      if (userId != null) 'user_id': userId,
      if (role != null) 'role': role,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeamMembersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String>? teamId,
    Value<String>? userId,
    Value<String>? role,
    Value<int>? rowid,
  }) {
    return TeamMembersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      teamId: teamId ?? this.teamId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeamMembersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('userId: $userId, ')
          ..write('role: $role, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InviteCodesTable extends InviteCodes
    with TableInfo<$InviteCodesTable, InviteCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InviteCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    code,
    role,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invite_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<InviteCode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InviteCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InviteCode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      ),
    );
  }

  @override
  $InviteCodesTable createAlias(String alias) {
    return $InviteCodesTable(attachedDatabase, alias);
  }
}

class InviteCode extends DataClass implements Insertable<InviteCode> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String teamId;
  final String code;
  final String role;
  final DateTime? expiresAt;
  const InviteCode({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.teamId,
    required this.code,
    required this.role,
    this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    map['team_id'] = Variable<String>(teamId);
    map['code'] = Variable<String>(code);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<DateTime>(expiresAt);
    }
    return map;
  }

  InviteCodesCompanion toCompanion(bool nullToAbsent) {
    return InviteCodesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      teamId: Value(teamId),
      code: Value(code),
      role: Value(role),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory InviteCode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InviteCode(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      teamId: serializer.fromJson<String>(json['teamId']),
      code: serializer.fromJson<String>(json['code']),
      role: serializer.fromJson<String>(json['role']),
      expiresAt: serializer.fromJson<DateTime?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'teamId': serializer.toJson<String>(teamId),
      'code': serializer.toJson<String>(code),
      'role': serializer.toJson<String>(role),
      'expiresAt': serializer.toJson<DateTime?>(expiresAt),
    };
  }

  InviteCode copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    String? teamId,
    String? code,
    String? role,
    Value<DateTime?> expiresAt = const Value.absent(),
  }) => InviteCode(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    teamId: teamId ?? this.teamId,
    code: code ?? this.code,
    role: role ?? this.role,
    expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
  );
  InviteCode copyWithCompanion(InviteCodesCompanion data) {
    return InviteCode(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      code: data.code.present ? data.code.value : this.code,
      role: data.role.present ? data.role.value : this.role,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InviteCode(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('code: $code, ')
          ..write('role: $role, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    code,
    role,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InviteCode &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.teamId == this.teamId &&
          other.code == this.code &&
          other.role == this.role &&
          other.expiresAt == this.expiresAt);
}

class InviteCodesCompanion extends UpdateCompanion<InviteCode> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String> teamId;
  final Value<String> code;
  final Value<String> role;
  final Value<DateTime?> expiresAt;
  final Value<int> rowid;
  const InviteCodesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.code = const Value.absent(),
    this.role = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InviteCodesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String teamId,
    required String code,
    required String role,
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       code = Value(code),
       role = Value(role);
  static Insertable<InviteCode> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? teamId,
    Expression<String>? code,
    Expression<String>? role,
    Expression<DateTime>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (teamId != null) 'team_id': teamId,
      if (code != null) 'code': code,
      if (role != null) 'role': role,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InviteCodesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String>? teamId,
    Value<String>? code,
    Value<String>? role,
    Value<DateTime?>? expiresAt,
    Value<int>? rowid,
  }) {
    return InviteCodesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      teamId: teamId ?? this.teamId,
      code: code ?? this.code,
      role: role ?? this.role,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InviteCodesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('code: $code, ')
          ..write('role: $role, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlayersTable extends Players with TableInfo<$PlayersTable, Player> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlayersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _jerseyNumberMeta = const VerificationMeta(
    'jerseyNumber',
  );
  @override
  late final GeneratedColumn<String> jerseyNumber = GeneratedColumn<String>(
    'jersey_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batsMeta = const VerificationMeta('bats');
  @override
  late final GeneratedColumn<String> bats = GeneratedColumn<String>(
    'bats',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('right'),
  );
  static const VerificationMeta _throws_Meta = const VerificationMeta(
    'throws_',
  );
  @override
  late final GeneratedColumn<String> throws_ = GeneratedColumn<String>(
    'throws',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('right'),
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('undisclosed'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    personId,
    firstName,
    lastName,
    jerseyNumber,
    bats,
    throws_,
    gender,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'players';
  @override
  VerificationContext validateIntegrity(
    Insertable<Player> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('jersey_number')) {
      context.handle(
        _jerseyNumberMeta,
        jerseyNumber.isAcceptableOrUnknown(
          data['jersey_number']!,
          _jerseyNumberMeta,
        ),
      );
    }
    if (data.containsKey('bats')) {
      context.handle(
        _batsMeta,
        bats.isAcceptableOrUnknown(data['bats']!, _batsMeta),
      );
    }
    if (data.containsKey('throws')) {
      context.handle(
        _throws_Meta,
        throws_.isAcceptableOrUnknown(data['throws']!, _throws_Meta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Player map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Player(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      )!,
      jerseyNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}jersey_number'],
      ),
      bats: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bats'],
      )!,
      throws_: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}throws'],
      )!,
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $PlayersTable createAlias(String alias) {
    return $PlayersTable(attachedDatabase, alias);
  }
}

class Player extends DataClass implements Insertable<Player> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String? teamId;
  final String? personId;
  final String firstName;
  final String lastName;
  final String? jerseyNumber;
  final String bats;
  final String throws_;
  final String gender;
  final String status;
  const Player({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    this.teamId,
    this.personId,
    required this.firstName,
    required this.lastName,
    this.jerseyNumber,
    required this.bats,
    required this.throws_,
    required this.gender,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    map['first_name'] = Variable<String>(firstName);
    map['last_name'] = Variable<String>(lastName);
    if (!nullToAbsent || jerseyNumber != null) {
      map['jersey_number'] = Variable<String>(jerseyNumber);
    }
    map['bats'] = Variable<String>(bats);
    map['throws'] = Variable<String>(throws_);
    map['gender'] = Variable<String>(gender);
    map['status'] = Variable<String>(status);
    return map;
  }

  PlayersCompanion toCompanion(bool nullToAbsent) {
    return PlayersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      firstName: Value(firstName),
      lastName: Value(lastName),
      jerseyNumber: jerseyNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(jerseyNumber),
      bats: Value(bats),
      throws_: Value(throws_),
      gender: Value(gender),
      status: Value(status),
    );
  }

  factory Player.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Player(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      personId: serializer.fromJson<String?>(json['personId']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String>(json['lastName']),
      jerseyNumber: serializer.fromJson<String?>(json['jerseyNumber']),
      bats: serializer.fromJson<String>(json['bats']),
      throws_: serializer.fromJson<String>(json['throws_']),
      gender: serializer.fromJson<String>(json['gender']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'teamId': serializer.toJson<String?>(teamId),
      'personId': serializer.toJson<String?>(personId),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String>(lastName),
      'jerseyNumber': serializer.toJson<String?>(jerseyNumber),
      'bats': serializer.toJson<String>(bats),
      'throws_': serializer.toJson<String>(throws_),
      'gender': serializer.toJson<String>(gender),
      'status': serializer.toJson<String>(status),
    };
  }

  Player copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    Value<String?> teamId = const Value.absent(),
    Value<String?> personId = const Value.absent(),
    String? firstName,
    String? lastName,
    Value<String?> jerseyNumber = const Value.absent(),
    String? bats,
    String? throws_,
    String? gender,
    String? status,
  }) => Player(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    teamId: teamId.present ? teamId.value : this.teamId,
    personId: personId.present ? personId.value : this.personId,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    jerseyNumber: jerseyNumber.present ? jerseyNumber.value : this.jerseyNumber,
    bats: bats ?? this.bats,
    throws_: throws_ ?? this.throws_,
    gender: gender ?? this.gender,
    status: status ?? this.status,
  );
  Player copyWithCompanion(PlayersCompanion data) {
    return Player(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      personId: data.personId.present ? data.personId.value : this.personId,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      jerseyNumber: data.jerseyNumber.present
          ? data.jerseyNumber.value
          : this.jerseyNumber,
      bats: data.bats.present ? data.bats.value : this.bats,
      throws_: data.throws_.present ? data.throws_.value : this.throws_,
      gender: data.gender.present ? data.gender.value : this.gender,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Player(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('personId: $personId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('bats: $bats, ')
          ..write('throws_: $throws_, ')
          ..write('gender: $gender, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    personId,
    firstName,
    lastName,
    jerseyNumber,
    bats,
    throws_,
    gender,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Player &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.teamId == this.teamId &&
          other.personId == this.personId &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.jerseyNumber == this.jerseyNumber &&
          other.bats == this.bats &&
          other.throws_ == this.throws_ &&
          other.gender == this.gender &&
          other.status == this.status);
}

class PlayersCompanion extends UpdateCompanion<Player> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String?> teamId;
  final Value<String?> personId;
  final Value<String> firstName;
  final Value<String> lastName;
  final Value<String?> jerseyNumber;
  final Value<String> bats;
  final Value<String> throws_;
  final Value<String> gender;
  final Value<String> status;
  final Value<int> rowid;
  const PlayersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.personId = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.jerseyNumber = const Value.absent(),
    this.bats = const Value.absent(),
    this.throws_ = const Value.absent(),
    this.gender = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlayersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.personId = const Value.absent(),
    required String firstName,
    this.lastName = const Value.absent(),
    this.jerseyNumber = const Value.absent(),
    this.bats = const Value.absent(),
    this.throws_ = const Value.absent(),
    this.gender = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       firstName = Value(firstName);
  static Insertable<Player> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? teamId,
    Expression<String>? personId,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? jerseyNumber,
    Expression<String>? bats,
    Expression<String>? throws_,
    Expression<String>? gender,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (teamId != null) 'team_id': teamId,
      if (personId != null) 'person_id': personId,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (jerseyNumber != null) 'jersey_number': jerseyNumber,
      if (bats != null) 'bats': bats,
      if (throws_ != null) 'throws': throws_,
      if (gender != null) 'gender': gender,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlayersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String?>? teamId,
    Value<String?>? personId,
    Value<String>? firstName,
    Value<String>? lastName,
    Value<String?>? jerseyNumber,
    Value<String>? bats,
    Value<String>? throws_,
    Value<String>? gender,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return PlayersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      teamId: teamId ?? this.teamId,
      personId: personId ?? this.personId,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      jerseyNumber: jerseyNumber ?? this.jerseyNumber,
      bats: bats ?? this.bats,
      throws_: throws_ ?? this.throws_,
      gender: gender ?? this.gender,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (jerseyNumber.present) {
      map['jersey_number'] = Variable<String>(jerseyNumber.value);
    }
    if (bats.present) {
      map['bats'] = Variable<String>(bats.value);
    }
    if (throws_.present) {
      map['throws'] = Variable<String>(throws_.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlayersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('personId: $personId, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('jerseyNumber: $jerseyNumber, ')
          ..write('bats: $bats, ')
          ..write('throws_: $throws_, ')
          ..write('gender: $gender, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OpponentsTable extends Opponents
    with TableInfo<$OpponentsTable, Opponent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpponentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    name,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'opponents';
  @override
  VerificationContext validateIntegrity(
    Insertable<Opponent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Opponent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Opponent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $OpponentsTable createAlias(String alias) {
    return $OpponentsTable(attachedDatabase, alias);
  }
}

class Opponent extends DataClass implements Insertable<Opponent> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String teamId;
  final String name;
  final String? notes;
  const Opponent({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.teamId,
    required this.name,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    map['team_id'] = Variable<String>(teamId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  OpponentsCompanion toCompanion(bool nullToAbsent) {
    return OpponentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      teamId: Value(teamId),
      name: Value(name),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Opponent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Opponent(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      teamId: serializer.fromJson<String>(json['teamId']),
      name: serializer.fromJson<String>(json['name']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'teamId': serializer.toJson<String>(teamId),
      'name': serializer.toJson<String>(name),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Opponent copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    String? teamId,
    String? name,
    Value<String?> notes = const Value.absent(),
  }) => Opponent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    teamId: teamId ?? this.teamId,
    name: name ?? this.name,
    notes: notes.present ? notes.value : this.notes,
  );
  Opponent copyWithCompanion(OpponentsCompanion data) {
    return Opponent(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      name: data.name.present ? data.name.value : this.name,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Opponent(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('name: $name, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    name,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Opponent &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.teamId == this.teamId &&
          other.name == this.name &&
          other.notes == this.notes);
}

class OpponentsCompanion extends UpdateCompanion<Opponent> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String> teamId;
  final Value<String> name;
  final Value<String?> notes;
  final Value<int> rowid;
  const OpponentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.name = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OpponentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String teamId,
    required String name,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       name = Value(name);
  static Insertable<Opponent> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? teamId,
    Expression<String>? name,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (teamId != null) 'team_id': teamId,
      if (name != null) 'name': name,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OpponentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String>? teamId,
    Value<String>? name,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return OpponentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpponentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('name: $name, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CompetitionsTable extends Competitions
    with TableInfo<$CompetitionsTable, Competition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CompetitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _leagueNameMeta = const VerificationMeta(
    'leagueName',
  );
  @override
  late final GeneratedColumn<String> leagueName = GeneratedColumn<String>(
    'league_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<DateTime> startsOn = GeneratedColumn<DateTime>(
    'starts_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<DateTime> endsOn = GeneratedColumn<DateTime>(
    'ends_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    type,
    name,
    leagueName,
    location,
    startsOn,
    endsOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'competitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Competition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('league_name')) {
      context.handle(
        _leagueNameMeta,
        leagueName.isAcceptableOrUnknown(data['league_name']!, _leagueNameMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Competition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Competition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      leagueName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}league_name'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_on'],
      ),
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_on'],
      ),
    );
  }

  @override
  $CompetitionsTable createAlias(String alias) {
    return $CompetitionsTable(attachedDatabase, alias);
  }
}

class Competition extends DataClass implements Insertable<Competition> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String teamId;
  final String type;
  final String name;
  final String? leagueName;
  final String? location;
  final DateTime? startsOn;
  final DateTime? endsOn;
  const Competition({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.teamId,
    required this.type,
    required this.name,
    this.leagueName,
    this.location,
    this.startsOn,
    this.endsOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    map['team_id'] = Variable<String>(teamId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || leagueName != null) {
      map['league_name'] = Variable<String>(leagueName);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || startsOn != null) {
      map['starts_on'] = Variable<DateTime>(startsOn);
    }
    if (!nullToAbsent || endsOn != null) {
      map['ends_on'] = Variable<DateTime>(endsOn);
    }
    return map;
  }

  CompetitionsCompanion toCompanion(bool nullToAbsent) {
    return CompetitionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      teamId: Value(teamId),
      type: Value(type),
      name: Value(name),
      leagueName: leagueName == null && nullToAbsent
          ? const Value.absent()
          : Value(leagueName),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      startsOn: startsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(startsOn),
      endsOn: endsOn == null && nullToAbsent
          ? const Value.absent()
          : Value(endsOn),
    );
  }

  factory Competition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Competition(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      teamId: serializer.fromJson<String>(json['teamId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      leagueName: serializer.fromJson<String?>(json['leagueName']),
      location: serializer.fromJson<String?>(json['location']),
      startsOn: serializer.fromJson<DateTime?>(json['startsOn']),
      endsOn: serializer.fromJson<DateTime?>(json['endsOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'teamId': serializer.toJson<String>(teamId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'leagueName': serializer.toJson<String?>(leagueName),
      'location': serializer.toJson<String?>(location),
      'startsOn': serializer.toJson<DateTime?>(startsOn),
      'endsOn': serializer.toJson<DateTime?>(endsOn),
    };
  }

  Competition copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    String? teamId,
    String? type,
    String? name,
    Value<String?> leagueName = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<DateTime?> startsOn = const Value.absent(),
    Value<DateTime?> endsOn = const Value.absent(),
  }) => Competition(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    teamId: teamId ?? this.teamId,
    type: type ?? this.type,
    name: name ?? this.name,
    leagueName: leagueName.present ? leagueName.value : this.leagueName,
    location: location.present ? location.value : this.location,
    startsOn: startsOn.present ? startsOn.value : this.startsOn,
    endsOn: endsOn.present ? endsOn.value : this.endsOn,
  );
  Competition copyWithCompanion(CompetitionsCompanion data) {
    return Competition(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      leagueName: data.leagueName.present
          ? data.leagueName.value
          : this.leagueName,
      location: data.location.present ? data.location.value : this.location,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Competition(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('leagueName: $leagueName, ')
          ..write('location: $location, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    type,
    name,
    leagueName,
    location,
    startsOn,
    endsOn,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Competition &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.teamId == this.teamId &&
          other.type == this.type &&
          other.name == this.name &&
          other.leagueName == this.leagueName &&
          other.location == this.location &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn);
}

class CompetitionsCompanion extends UpdateCompanion<Competition> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String> teamId;
  final Value<String> type;
  final Value<String> name;
  final Value<String?> leagueName;
  final Value<String?> location;
  final Value<DateTime?> startsOn;
  final Value<DateTime?> endsOn;
  final Value<int> rowid;
  const CompetitionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.leagueName = const Value.absent(),
    this.location = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CompetitionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String teamId,
    required String type,
    required String name,
    this.leagueName = const Value.absent(),
    this.location = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       type = Value(type),
       name = Value(name);
  static Insertable<Competition> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? teamId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? leagueName,
    Expression<String>? location,
    Expression<DateTime>? startsOn,
    Expression<DateTime>? endsOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (teamId != null) 'team_id': teamId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (leagueName != null) 'league_name': leagueName,
      if (location != null) 'location': location,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CompetitionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String>? teamId,
    Value<String>? type,
    Value<String>? name,
    Value<String?>? leagueName,
    Value<String?>? location,
    Value<DateTime?>? startsOn,
    Value<DateTime?>? endsOn,
    Value<int>? rowid,
  }) {
    return CompetitionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      teamId: teamId ?? this.teamId,
      type: type ?? this.type,
      name: name ?? this.name,
      leagueName: leagueName ?? this.leagueName,
      location: location ?? this.location,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (leagueName.present) {
      map['league_name'] = Variable<String>(leagueName.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<DateTime>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<DateTime>(endsOn.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CompetitionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('leagueName: $leagueName, ')
          ..write('location: $location, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _scoringDraftMeta = const VerificationMeta(
    'scoringDraft',
  );
  @override
  late final GeneratedColumn<String> scoringDraft = GeneratedColumn<String>(
    'scoring_draft',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _settingsSnapshotMeta = const VerificationMeta(
    'settingsSnapshot',
  );
  @override
  late final GeneratedColumn<String> settingsSnapshot = GeneratedColumn<String>(
    'settings_snapshot',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('team'),
  );
  static const VerificationMeta _opponentIdMeta = const VerificationMeta(
    'opponentId',
  );
  @override
  late final GeneratedColumn<String> opponentId = GeneratedColumn<String>(
    'opponent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _opponentNameMeta = const VerificationMeta(
    'opponentName',
  );
  @override
  late final GeneratedColumn<String> opponentName = GeneratedColumn<String>(
    'opponent_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playedForNameMeta = const VerificationMeta(
    'playedForName',
  );
  @override
  late final GeneratedColumn<String> playedForName = GeneratedColumn<String>(
    'played_for_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playedForTeamIdMeta = const VerificationMeta(
    'playedForTeamId',
  );
  @override
  late final GeneratedColumn<String> playedForTeamId = GeneratedColumn<String>(
    'played_for_team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _parkMeta = const VerificationMeta('park');
  @override
  late final GeneratedColumn<String> park = GeneratedColumn<String>(
    'park',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startsAtMeta = const VerificationMeta(
    'startsAt',
  );
  @override
  late final GeneratedColumn<DateTime> startsAt = GeneratedColumn<DateTime>(
    'starts_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _homeAwayMeta = const VerificationMeta(
    'homeAway',
  );
  @override
  late final GeneratedColumn<String> homeAway = GeneratedColumn<String>(
    'home_away',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('home'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('scheduled'),
  );
  static const VerificationMeta _ourRunsMeta = const VerificationMeta(
    'ourRuns',
  );
  @override
  late final GeneratedColumn<int> ourRuns = GeneratedColumn<int>(
    'our_runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _theirRunsMeta = const VerificationMeta(
    'theirRuns',
  );
  @override
  late final GeneratedColumn<int> theirRuns = GeneratedColumn<int>(
    'their_runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _currentInningMeta = const VerificationMeta(
    'currentInning',
  );
  @override
  late final GeneratedColumn<int> currentInning = GeneratedColumn<int>(
    'current_inning',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _currentHalfMeta = const VerificationMeta(
    'currentHalf',
  );
  @override
  late final GeneratedColumn<String> currentHalf = GeneratedColumn<String>(
    'current_half',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('bottom'),
  );
  static const VerificationMeta _outsMeta = const VerificationMeta('outs');
  @override
  late final GeneratedColumn<int> outs = GeneratedColumn<int>(
    'outs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scorerUserIdMeta = const VerificationMeta(
    'scorerUserId',
  );
  @override
  late final GeneratedColumn<String> scorerUserId = GeneratedColumn<String>(
    'scorer_user_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _firstBaseIdMeta = const VerificationMeta(
    'firstBaseId',
  );
  @override
  late final GeneratedColumn<String> firstBaseId = GeneratedColumn<String>(
    'first_base_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _secondBaseIdMeta = const VerificationMeta(
    'secondBaseId',
  );
  @override
  late final GeneratedColumn<String> secondBaseId = GeneratedColumn<String>(
    'second_base_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thirdBaseIdMeta = const VerificationMeta(
    'thirdBaseId',
  );
  @override
  late final GeneratedColumn<String> thirdBaseId = GeneratedColumn<String>(
    'third_base_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentBatterIndexMeta =
      const VerificationMeta('currentBatterIndex');
  @override
  late final GeneratedColumn<int> currentBatterIndex = GeneratedColumn<int>(
    'current_batter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _theirHalfRunsMeta = const VerificationMeta(
    'theirHalfRuns',
  );
  @override
  late final GeneratedColumn<int> theirHalfRuns = GeneratedColumn<int>(
    'their_half_runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ourHalfRunsMeta = const VerificationMeta(
    'ourHalfRuns',
  );
  @override
  late final GeneratedColumn<int> ourHalfRuns = GeneratedColumn<int>(
    'our_half_runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('game'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    scoringDraft,
    settingsSnapshot,
    teamId,
    kind,
    opponentId,
    opponentName,
    playedForName,
    playedForTeamId,
    park,
    startsAt,
    homeAway,
    status,
    ourRuns,
    theirRuns,
    currentInning,
    currentHalf,
    outs,
    scorerUserId,
    notes,
    firstBaseId,
    secondBaseId,
    thirdBaseId,
    currentBatterIndex,
    theirHalfRuns,
    ourHalfRuns,
    scope,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('scoring_draft')) {
      context.handle(
        _scoringDraftMeta,
        scoringDraft.isAcceptableOrUnknown(
          data['scoring_draft']!,
          _scoringDraftMeta,
        ),
      );
    }
    if (data.containsKey('settings_snapshot')) {
      context.handle(
        _settingsSnapshotMeta,
        settingsSnapshot.isAcceptableOrUnknown(
          data['settings_snapshot']!,
          _settingsSnapshotMeta,
        ),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('opponent_id')) {
      context.handle(
        _opponentIdMeta,
        opponentId.isAcceptableOrUnknown(data['opponent_id']!, _opponentIdMeta),
      );
    }
    if (data.containsKey('opponent_name')) {
      context.handle(
        _opponentNameMeta,
        opponentName.isAcceptableOrUnknown(
          data['opponent_name']!,
          _opponentNameMeta,
        ),
      );
    }
    if (data.containsKey('played_for_name')) {
      context.handle(
        _playedForNameMeta,
        playedForName.isAcceptableOrUnknown(
          data['played_for_name']!,
          _playedForNameMeta,
        ),
      );
    }
    if (data.containsKey('played_for_team_id')) {
      context.handle(
        _playedForTeamIdMeta,
        playedForTeamId.isAcceptableOrUnknown(
          data['played_for_team_id']!,
          _playedForTeamIdMeta,
        ),
      );
    }
    if (data.containsKey('park')) {
      context.handle(
        _parkMeta,
        park.isAcceptableOrUnknown(data['park']!, _parkMeta),
      );
    }
    if (data.containsKey('starts_at')) {
      context.handle(
        _startsAtMeta,
        startsAt.isAcceptableOrUnknown(data['starts_at']!, _startsAtMeta),
      );
    }
    if (data.containsKey('home_away')) {
      context.handle(
        _homeAwayMeta,
        homeAway.isAcceptableOrUnknown(data['home_away']!, _homeAwayMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('our_runs')) {
      context.handle(
        _ourRunsMeta,
        ourRuns.isAcceptableOrUnknown(data['our_runs']!, _ourRunsMeta),
      );
    }
    if (data.containsKey('their_runs')) {
      context.handle(
        _theirRunsMeta,
        theirRuns.isAcceptableOrUnknown(data['their_runs']!, _theirRunsMeta),
      );
    }
    if (data.containsKey('current_inning')) {
      context.handle(
        _currentInningMeta,
        currentInning.isAcceptableOrUnknown(
          data['current_inning']!,
          _currentInningMeta,
        ),
      );
    }
    if (data.containsKey('current_half')) {
      context.handle(
        _currentHalfMeta,
        currentHalf.isAcceptableOrUnknown(
          data['current_half']!,
          _currentHalfMeta,
        ),
      );
    }
    if (data.containsKey('outs')) {
      context.handle(
        _outsMeta,
        outs.isAcceptableOrUnknown(data['outs']!, _outsMeta),
      );
    }
    if (data.containsKey('scorer_user_id')) {
      context.handle(
        _scorerUserIdMeta,
        scorerUserId.isAcceptableOrUnknown(
          data['scorer_user_id']!,
          _scorerUserIdMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('first_base_id')) {
      context.handle(
        _firstBaseIdMeta,
        firstBaseId.isAcceptableOrUnknown(
          data['first_base_id']!,
          _firstBaseIdMeta,
        ),
      );
    }
    if (data.containsKey('second_base_id')) {
      context.handle(
        _secondBaseIdMeta,
        secondBaseId.isAcceptableOrUnknown(
          data['second_base_id']!,
          _secondBaseIdMeta,
        ),
      );
    }
    if (data.containsKey('third_base_id')) {
      context.handle(
        _thirdBaseIdMeta,
        thirdBaseId.isAcceptableOrUnknown(
          data['third_base_id']!,
          _thirdBaseIdMeta,
        ),
      );
    }
    if (data.containsKey('current_batter_index')) {
      context.handle(
        _currentBatterIndexMeta,
        currentBatterIndex.isAcceptableOrUnknown(
          data['current_batter_index']!,
          _currentBatterIndexMeta,
        ),
      );
    }
    if (data.containsKey('their_half_runs')) {
      context.handle(
        _theirHalfRunsMeta,
        theirHalfRuns.isAcceptableOrUnknown(
          data['their_half_runs']!,
          _theirHalfRunsMeta,
        ),
      );
    }
    if (data.containsKey('our_half_runs')) {
      context.handle(
        _ourHalfRunsMeta,
        ourHalfRuns.isAcceptableOrUnknown(
          data['our_half_runs']!,
          _ourHalfRunsMeta,
        ),
      );
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      scoringDraft: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scoring_draft'],
      ),
      settingsSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}settings_snapshot'],
      ),
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      opponentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_id'],
      ),
      opponentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_name'],
      ),
      playedForName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}played_for_name'],
      ),
      playedForTeamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}played_for_team_id'],
      ),
      park: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}park'],
      ),
      startsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_at'],
      ),
      homeAway: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}home_away'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      ourRuns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}our_runs'],
      )!,
      theirRuns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}their_runs'],
      )!,
      currentInning: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_inning'],
      )!,
      currentHalf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_half'],
      )!,
      outs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outs'],
      )!,
      scorerUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scorer_user_id'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      firstBaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_base_id'],
      ),
      secondBaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}second_base_id'],
      ),
      thirdBaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}third_base_id'],
      ),
      currentBatterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_batter_index'],
      )!,
      theirHalfRuns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}their_half_runs'],
      )!,
      ourHalfRuns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}our_half_runs'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String? scoringDraft;

  /// Frozen at creation so future team settings cannot rewrite this game.
  final String? settingsSnapshot;
  final String? teamId;
  final String kind;
  final String? opponentId;
  final String? opponentName;
  final String? playedForName;

  /// Set when the name came from a saved personal team, so games stay grouped
  /// even if that team is later renamed. Null when the name was typed.
  final String? playedForTeamId;
  final String? park;
  final DateTime? startsAt;
  final String homeAway;
  final String status;
  final int ourRuns;
  final int theirRuns;
  final int currentInning;
  final String currentHalf;
  final int outs;
  final String? scorerUserId;
  final String? notes;
  final String? firstBaseId;
  final String? secondBaseId;
  final String? thirdBaseId;
  final int currentBatterIndex;

  /// Runs tallied in the opponent half that is under way. Committed to a
  /// `game_events` row when the half ends.
  final int theirHalfRuns;

  /// Personal games: total team runs in our half, independent of player RBI.
  final int ourHalfRuns;

  /// `bat` (just your at-bats) or `game` (at-bats plus team scores). Team
  /// games are always `game`.
  final String scope;
  const Game({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    this.scoringDraft,
    this.settingsSnapshot,
    this.teamId,
    required this.kind,
    this.opponentId,
    this.opponentName,
    this.playedForName,
    this.playedForTeamId,
    this.park,
    this.startsAt,
    required this.homeAway,
    required this.status,
    required this.ourRuns,
    required this.theirRuns,
    required this.currentInning,
    required this.currentHalf,
    required this.outs,
    this.scorerUserId,
    this.notes,
    this.firstBaseId,
    this.secondBaseId,
    this.thirdBaseId,
    required this.currentBatterIndex,
    required this.theirHalfRuns,
    required this.ourHalfRuns,
    required this.scope,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    if (!nullToAbsent || scoringDraft != null) {
      map['scoring_draft'] = Variable<String>(scoringDraft);
    }
    if (!nullToAbsent || settingsSnapshot != null) {
      map['settings_snapshot'] = Variable<String>(settingsSnapshot);
    }
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || opponentId != null) {
      map['opponent_id'] = Variable<String>(opponentId);
    }
    if (!nullToAbsent || opponentName != null) {
      map['opponent_name'] = Variable<String>(opponentName);
    }
    if (!nullToAbsent || playedForName != null) {
      map['played_for_name'] = Variable<String>(playedForName);
    }
    if (!nullToAbsent || playedForTeamId != null) {
      map['played_for_team_id'] = Variable<String>(playedForTeamId);
    }
    if (!nullToAbsent || park != null) {
      map['park'] = Variable<String>(park);
    }
    if (!nullToAbsent || startsAt != null) {
      map['starts_at'] = Variable<DateTime>(startsAt);
    }
    map['home_away'] = Variable<String>(homeAway);
    map['status'] = Variable<String>(status);
    map['our_runs'] = Variable<int>(ourRuns);
    map['their_runs'] = Variable<int>(theirRuns);
    map['current_inning'] = Variable<int>(currentInning);
    map['current_half'] = Variable<String>(currentHalf);
    map['outs'] = Variable<int>(outs);
    if (!nullToAbsent || scorerUserId != null) {
      map['scorer_user_id'] = Variable<String>(scorerUserId);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || firstBaseId != null) {
      map['first_base_id'] = Variable<String>(firstBaseId);
    }
    if (!nullToAbsent || secondBaseId != null) {
      map['second_base_id'] = Variable<String>(secondBaseId);
    }
    if (!nullToAbsent || thirdBaseId != null) {
      map['third_base_id'] = Variable<String>(thirdBaseId);
    }
    map['current_batter_index'] = Variable<int>(currentBatterIndex);
    map['their_half_runs'] = Variable<int>(theirHalfRuns);
    map['our_half_runs'] = Variable<int>(ourHalfRuns);
    map['scope'] = Variable<String>(scope);
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      scoringDraft: scoringDraft == null && nullToAbsent
          ? const Value.absent()
          : Value(scoringDraft),
      settingsSnapshot: settingsSnapshot == null && nullToAbsent
          ? const Value.absent()
          : Value(settingsSnapshot),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      kind: Value(kind),
      opponentId: opponentId == null && nullToAbsent
          ? const Value.absent()
          : Value(opponentId),
      opponentName: opponentName == null && nullToAbsent
          ? const Value.absent()
          : Value(opponentName),
      playedForName: playedForName == null && nullToAbsent
          ? const Value.absent()
          : Value(playedForName),
      playedForTeamId: playedForTeamId == null && nullToAbsent
          ? const Value.absent()
          : Value(playedForTeamId),
      park: park == null && nullToAbsent ? const Value.absent() : Value(park),
      startsAt: startsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startsAt),
      homeAway: Value(homeAway),
      status: Value(status),
      ourRuns: Value(ourRuns),
      theirRuns: Value(theirRuns),
      currentInning: Value(currentInning),
      currentHalf: Value(currentHalf),
      outs: Value(outs),
      scorerUserId: scorerUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(scorerUserId),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      firstBaseId: firstBaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(firstBaseId),
      secondBaseId: secondBaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(secondBaseId),
      thirdBaseId: thirdBaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(thirdBaseId),
      currentBatterIndex: Value(currentBatterIndex),
      theirHalfRuns: Value(theirHalfRuns),
      ourHalfRuns: Value(ourHalfRuns),
      scope: Value(scope),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      scoringDraft: serializer.fromJson<String?>(json['scoringDraft']),
      settingsSnapshot: serializer.fromJson<String?>(json['settingsSnapshot']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      kind: serializer.fromJson<String>(json['kind']),
      opponentId: serializer.fromJson<String?>(json['opponentId']),
      opponentName: serializer.fromJson<String?>(json['opponentName']),
      playedForName: serializer.fromJson<String?>(json['playedForName']),
      playedForTeamId: serializer.fromJson<String?>(json['playedForTeamId']),
      park: serializer.fromJson<String?>(json['park']),
      startsAt: serializer.fromJson<DateTime?>(json['startsAt']),
      homeAway: serializer.fromJson<String>(json['homeAway']),
      status: serializer.fromJson<String>(json['status']),
      ourRuns: serializer.fromJson<int>(json['ourRuns']),
      theirRuns: serializer.fromJson<int>(json['theirRuns']),
      currentInning: serializer.fromJson<int>(json['currentInning']),
      currentHalf: serializer.fromJson<String>(json['currentHalf']),
      outs: serializer.fromJson<int>(json['outs']),
      scorerUserId: serializer.fromJson<String?>(json['scorerUserId']),
      notes: serializer.fromJson<String?>(json['notes']),
      firstBaseId: serializer.fromJson<String?>(json['firstBaseId']),
      secondBaseId: serializer.fromJson<String?>(json['secondBaseId']),
      thirdBaseId: serializer.fromJson<String?>(json['thirdBaseId']),
      currentBatterIndex: serializer.fromJson<int>(json['currentBatterIndex']),
      theirHalfRuns: serializer.fromJson<int>(json['theirHalfRuns']),
      ourHalfRuns: serializer.fromJson<int>(json['ourHalfRuns']),
      scope: serializer.fromJson<String>(json['scope']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'scoringDraft': serializer.toJson<String?>(scoringDraft),
      'settingsSnapshot': serializer.toJson<String?>(settingsSnapshot),
      'teamId': serializer.toJson<String?>(teamId),
      'kind': serializer.toJson<String>(kind),
      'opponentId': serializer.toJson<String?>(opponentId),
      'opponentName': serializer.toJson<String?>(opponentName),
      'playedForName': serializer.toJson<String?>(playedForName),
      'playedForTeamId': serializer.toJson<String?>(playedForTeamId),
      'park': serializer.toJson<String?>(park),
      'startsAt': serializer.toJson<DateTime?>(startsAt),
      'homeAway': serializer.toJson<String>(homeAway),
      'status': serializer.toJson<String>(status),
      'ourRuns': serializer.toJson<int>(ourRuns),
      'theirRuns': serializer.toJson<int>(theirRuns),
      'currentInning': serializer.toJson<int>(currentInning),
      'currentHalf': serializer.toJson<String>(currentHalf),
      'outs': serializer.toJson<int>(outs),
      'scorerUserId': serializer.toJson<String?>(scorerUserId),
      'notes': serializer.toJson<String?>(notes),
      'firstBaseId': serializer.toJson<String?>(firstBaseId),
      'secondBaseId': serializer.toJson<String?>(secondBaseId),
      'thirdBaseId': serializer.toJson<String?>(thirdBaseId),
      'currentBatterIndex': serializer.toJson<int>(currentBatterIndex),
      'theirHalfRuns': serializer.toJson<int>(theirHalfRuns),
      'ourHalfRuns': serializer.toJson<int>(ourHalfRuns),
      'scope': serializer.toJson<String>(scope),
    };
  }

  Game copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    Value<String?> scoringDraft = const Value.absent(),
    Value<String?> settingsSnapshot = const Value.absent(),
    Value<String?> teamId = const Value.absent(),
    String? kind,
    Value<String?> opponentId = const Value.absent(),
    Value<String?> opponentName = const Value.absent(),
    Value<String?> playedForName = const Value.absent(),
    Value<String?> playedForTeamId = const Value.absent(),
    Value<String?> park = const Value.absent(),
    Value<DateTime?> startsAt = const Value.absent(),
    String? homeAway,
    String? status,
    int? ourRuns,
    int? theirRuns,
    int? currentInning,
    String? currentHalf,
    int? outs,
    Value<String?> scorerUserId = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> firstBaseId = const Value.absent(),
    Value<String?> secondBaseId = const Value.absent(),
    Value<String?> thirdBaseId = const Value.absent(),
    int? currentBatterIndex,
    int? theirHalfRuns,
    int? ourHalfRuns,
    String? scope,
  }) => Game(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    scoringDraft: scoringDraft.present ? scoringDraft.value : this.scoringDraft,
    settingsSnapshot: settingsSnapshot.present
        ? settingsSnapshot.value
        : this.settingsSnapshot,
    teamId: teamId.present ? teamId.value : this.teamId,
    kind: kind ?? this.kind,
    opponentId: opponentId.present ? opponentId.value : this.opponentId,
    opponentName: opponentName.present ? opponentName.value : this.opponentName,
    playedForName: playedForName.present
        ? playedForName.value
        : this.playedForName,
    playedForTeamId: playedForTeamId.present
        ? playedForTeamId.value
        : this.playedForTeamId,
    park: park.present ? park.value : this.park,
    startsAt: startsAt.present ? startsAt.value : this.startsAt,
    homeAway: homeAway ?? this.homeAway,
    status: status ?? this.status,
    ourRuns: ourRuns ?? this.ourRuns,
    theirRuns: theirRuns ?? this.theirRuns,
    currentInning: currentInning ?? this.currentInning,
    currentHalf: currentHalf ?? this.currentHalf,
    outs: outs ?? this.outs,
    scorerUserId: scorerUserId.present ? scorerUserId.value : this.scorerUserId,
    notes: notes.present ? notes.value : this.notes,
    firstBaseId: firstBaseId.present ? firstBaseId.value : this.firstBaseId,
    secondBaseId: secondBaseId.present ? secondBaseId.value : this.secondBaseId,
    thirdBaseId: thirdBaseId.present ? thirdBaseId.value : this.thirdBaseId,
    currentBatterIndex: currentBatterIndex ?? this.currentBatterIndex,
    theirHalfRuns: theirHalfRuns ?? this.theirHalfRuns,
    ourHalfRuns: ourHalfRuns ?? this.ourHalfRuns,
    scope: scope ?? this.scope,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      scoringDraft: data.scoringDraft.present
          ? data.scoringDraft.value
          : this.scoringDraft,
      settingsSnapshot: data.settingsSnapshot.present
          ? data.settingsSnapshot.value
          : this.settingsSnapshot,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      kind: data.kind.present ? data.kind.value : this.kind,
      opponentId: data.opponentId.present
          ? data.opponentId.value
          : this.opponentId,
      opponentName: data.opponentName.present
          ? data.opponentName.value
          : this.opponentName,
      playedForName: data.playedForName.present
          ? data.playedForName.value
          : this.playedForName,
      playedForTeamId: data.playedForTeamId.present
          ? data.playedForTeamId.value
          : this.playedForTeamId,
      park: data.park.present ? data.park.value : this.park,
      startsAt: data.startsAt.present ? data.startsAt.value : this.startsAt,
      homeAway: data.homeAway.present ? data.homeAway.value : this.homeAway,
      status: data.status.present ? data.status.value : this.status,
      ourRuns: data.ourRuns.present ? data.ourRuns.value : this.ourRuns,
      theirRuns: data.theirRuns.present ? data.theirRuns.value : this.theirRuns,
      currentInning: data.currentInning.present
          ? data.currentInning.value
          : this.currentInning,
      currentHalf: data.currentHalf.present
          ? data.currentHalf.value
          : this.currentHalf,
      outs: data.outs.present ? data.outs.value : this.outs,
      scorerUserId: data.scorerUserId.present
          ? data.scorerUserId.value
          : this.scorerUserId,
      notes: data.notes.present ? data.notes.value : this.notes,
      firstBaseId: data.firstBaseId.present
          ? data.firstBaseId.value
          : this.firstBaseId,
      secondBaseId: data.secondBaseId.present
          ? data.secondBaseId.value
          : this.secondBaseId,
      thirdBaseId: data.thirdBaseId.present
          ? data.thirdBaseId.value
          : this.thirdBaseId,
      currentBatterIndex: data.currentBatterIndex.present
          ? data.currentBatterIndex.value
          : this.currentBatterIndex,
      theirHalfRuns: data.theirHalfRuns.present
          ? data.theirHalfRuns.value
          : this.theirHalfRuns,
      ourHalfRuns: data.ourHalfRuns.present
          ? data.ourHalfRuns.value
          : this.ourHalfRuns,
      scope: data.scope.present ? data.scope.value : this.scope,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('scoringDraft: $scoringDraft, ')
          ..write('settingsSnapshot: $settingsSnapshot, ')
          ..write('teamId: $teamId, ')
          ..write('kind: $kind, ')
          ..write('opponentId: $opponentId, ')
          ..write('opponentName: $opponentName, ')
          ..write('playedForName: $playedForName, ')
          ..write('playedForTeamId: $playedForTeamId, ')
          ..write('park: $park, ')
          ..write('startsAt: $startsAt, ')
          ..write('homeAway: $homeAway, ')
          ..write('status: $status, ')
          ..write('ourRuns: $ourRuns, ')
          ..write('theirRuns: $theirRuns, ')
          ..write('currentInning: $currentInning, ')
          ..write('currentHalf: $currentHalf, ')
          ..write('outs: $outs, ')
          ..write('scorerUserId: $scorerUserId, ')
          ..write('notes: $notes, ')
          ..write('firstBaseId: $firstBaseId, ')
          ..write('secondBaseId: $secondBaseId, ')
          ..write('thirdBaseId: $thirdBaseId, ')
          ..write('currentBatterIndex: $currentBatterIndex, ')
          ..write('theirHalfRuns: $theirHalfRuns, ')
          ..write('ourHalfRuns: $ourHalfRuns, ')
          ..write('scope: $scope')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    scoringDraft,
    settingsSnapshot,
    teamId,
    kind,
    opponentId,
    opponentName,
    playedForName,
    playedForTeamId,
    park,
    startsAt,
    homeAway,
    status,
    ourRuns,
    theirRuns,
    currentInning,
    currentHalf,
    outs,
    scorerUserId,
    notes,
    firstBaseId,
    secondBaseId,
    thirdBaseId,
    currentBatterIndex,
    theirHalfRuns,
    ourHalfRuns,
    scope,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.scoringDraft == this.scoringDraft &&
          other.settingsSnapshot == this.settingsSnapshot &&
          other.teamId == this.teamId &&
          other.kind == this.kind &&
          other.opponentId == this.opponentId &&
          other.opponentName == this.opponentName &&
          other.playedForName == this.playedForName &&
          other.playedForTeamId == this.playedForTeamId &&
          other.park == this.park &&
          other.startsAt == this.startsAt &&
          other.homeAway == this.homeAway &&
          other.status == this.status &&
          other.ourRuns == this.ourRuns &&
          other.theirRuns == this.theirRuns &&
          other.currentInning == this.currentInning &&
          other.currentHalf == this.currentHalf &&
          other.outs == this.outs &&
          other.scorerUserId == this.scorerUserId &&
          other.notes == this.notes &&
          other.firstBaseId == this.firstBaseId &&
          other.secondBaseId == this.secondBaseId &&
          other.thirdBaseId == this.thirdBaseId &&
          other.currentBatterIndex == this.currentBatterIndex &&
          other.theirHalfRuns == this.theirHalfRuns &&
          other.ourHalfRuns == this.ourHalfRuns &&
          other.scope == this.scope);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String?> scoringDraft;
  final Value<String?> settingsSnapshot;
  final Value<String?> teamId;
  final Value<String> kind;
  final Value<String?> opponentId;
  final Value<String?> opponentName;
  final Value<String?> playedForName;
  final Value<String?> playedForTeamId;
  final Value<String?> park;
  final Value<DateTime?> startsAt;
  final Value<String> homeAway;
  final Value<String> status;
  final Value<int> ourRuns;
  final Value<int> theirRuns;
  final Value<int> currentInning;
  final Value<String> currentHalf;
  final Value<int> outs;
  final Value<String?> scorerUserId;
  final Value<String?> notes;
  final Value<String?> firstBaseId;
  final Value<String?> secondBaseId;
  final Value<String?> thirdBaseId;
  final Value<int> currentBatterIndex;
  final Value<int> theirHalfRuns;
  final Value<int> ourHalfRuns;
  final Value<String> scope;
  final Value<int> rowid;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.scoringDraft = const Value.absent(),
    this.settingsSnapshot = const Value.absent(),
    this.teamId = const Value.absent(),
    this.kind = const Value.absent(),
    this.opponentId = const Value.absent(),
    this.opponentName = const Value.absent(),
    this.playedForName = const Value.absent(),
    this.playedForTeamId = const Value.absent(),
    this.park = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.homeAway = const Value.absent(),
    this.status = const Value.absent(),
    this.ourRuns = const Value.absent(),
    this.theirRuns = const Value.absent(),
    this.currentInning = const Value.absent(),
    this.currentHalf = const Value.absent(),
    this.outs = const Value.absent(),
    this.scorerUserId = const Value.absent(),
    this.notes = const Value.absent(),
    this.firstBaseId = const Value.absent(),
    this.secondBaseId = const Value.absent(),
    this.thirdBaseId = const Value.absent(),
    this.currentBatterIndex = const Value.absent(),
    this.theirHalfRuns = const Value.absent(),
    this.ourHalfRuns = const Value.absent(),
    this.scope = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.scoringDraft = const Value.absent(),
    this.settingsSnapshot = const Value.absent(),
    this.teamId = const Value.absent(),
    this.kind = const Value.absent(),
    this.opponentId = const Value.absent(),
    this.opponentName = const Value.absent(),
    this.playedForName = const Value.absent(),
    this.playedForTeamId = const Value.absent(),
    this.park = const Value.absent(),
    this.startsAt = const Value.absent(),
    this.homeAway = const Value.absent(),
    this.status = const Value.absent(),
    this.ourRuns = const Value.absent(),
    this.theirRuns = const Value.absent(),
    this.currentInning = const Value.absent(),
    this.currentHalf = const Value.absent(),
    this.outs = const Value.absent(),
    this.scorerUserId = const Value.absent(),
    this.notes = const Value.absent(),
    this.firstBaseId = const Value.absent(),
    this.secondBaseId = const Value.absent(),
    this.thirdBaseId = const Value.absent(),
    this.currentBatterIndex = const Value.absent(),
    this.theirHalfRuns = const Value.absent(),
    this.ourHalfRuns = const Value.absent(),
    this.scope = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Game> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? scoringDraft,
    Expression<String>? settingsSnapshot,
    Expression<String>? teamId,
    Expression<String>? kind,
    Expression<String>? opponentId,
    Expression<String>? opponentName,
    Expression<String>? playedForName,
    Expression<String>? playedForTeamId,
    Expression<String>? park,
    Expression<DateTime>? startsAt,
    Expression<String>? homeAway,
    Expression<String>? status,
    Expression<int>? ourRuns,
    Expression<int>? theirRuns,
    Expression<int>? currentInning,
    Expression<String>? currentHalf,
    Expression<int>? outs,
    Expression<String>? scorerUserId,
    Expression<String>? notes,
    Expression<String>? firstBaseId,
    Expression<String>? secondBaseId,
    Expression<String>? thirdBaseId,
    Expression<int>? currentBatterIndex,
    Expression<int>? theirHalfRuns,
    Expression<int>? ourHalfRuns,
    Expression<String>? scope,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (scoringDraft != null) 'scoring_draft': scoringDraft,
      if (settingsSnapshot != null) 'settings_snapshot': settingsSnapshot,
      if (teamId != null) 'team_id': teamId,
      if (kind != null) 'kind': kind,
      if (opponentId != null) 'opponent_id': opponentId,
      if (opponentName != null) 'opponent_name': opponentName,
      if (playedForName != null) 'played_for_name': playedForName,
      if (playedForTeamId != null) 'played_for_team_id': playedForTeamId,
      if (park != null) 'park': park,
      if (startsAt != null) 'starts_at': startsAt,
      if (homeAway != null) 'home_away': homeAway,
      if (status != null) 'status': status,
      if (ourRuns != null) 'our_runs': ourRuns,
      if (theirRuns != null) 'their_runs': theirRuns,
      if (currentInning != null) 'current_inning': currentInning,
      if (currentHalf != null) 'current_half': currentHalf,
      if (outs != null) 'outs': outs,
      if (scorerUserId != null) 'scorer_user_id': scorerUserId,
      if (notes != null) 'notes': notes,
      if (firstBaseId != null) 'first_base_id': firstBaseId,
      if (secondBaseId != null) 'second_base_id': secondBaseId,
      if (thirdBaseId != null) 'third_base_id': thirdBaseId,
      if (currentBatterIndex != null)
        'current_batter_index': currentBatterIndex,
      if (theirHalfRuns != null) 'their_half_runs': theirHalfRuns,
      if (ourHalfRuns != null) 'our_half_runs': ourHalfRuns,
      if (scope != null) 'scope': scope,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String?>? scoringDraft,
    Value<String?>? settingsSnapshot,
    Value<String?>? teamId,
    Value<String>? kind,
    Value<String?>? opponentId,
    Value<String?>? opponentName,
    Value<String?>? playedForName,
    Value<String?>? playedForTeamId,
    Value<String?>? park,
    Value<DateTime?>? startsAt,
    Value<String>? homeAway,
    Value<String>? status,
    Value<int>? ourRuns,
    Value<int>? theirRuns,
    Value<int>? currentInning,
    Value<String>? currentHalf,
    Value<int>? outs,
    Value<String?>? scorerUserId,
    Value<String?>? notes,
    Value<String?>? firstBaseId,
    Value<String?>? secondBaseId,
    Value<String?>? thirdBaseId,
    Value<int>? currentBatterIndex,
    Value<int>? theirHalfRuns,
    Value<int>? ourHalfRuns,
    Value<String>? scope,
    Value<int>? rowid,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      scoringDraft: scoringDraft ?? this.scoringDraft,
      settingsSnapshot: settingsSnapshot ?? this.settingsSnapshot,
      teamId: teamId ?? this.teamId,
      kind: kind ?? this.kind,
      opponentId: opponentId ?? this.opponentId,
      opponentName: opponentName ?? this.opponentName,
      playedForName: playedForName ?? this.playedForName,
      playedForTeamId: playedForTeamId ?? this.playedForTeamId,
      park: park ?? this.park,
      startsAt: startsAt ?? this.startsAt,
      homeAway: homeAway ?? this.homeAway,
      status: status ?? this.status,
      ourRuns: ourRuns ?? this.ourRuns,
      theirRuns: theirRuns ?? this.theirRuns,
      currentInning: currentInning ?? this.currentInning,
      currentHalf: currentHalf ?? this.currentHalf,
      outs: outs ?? this.outs,
      scorerUserId: scorerUserId ?? this.scorerUserId,
      notes: notes ?? this.notes,
      firstBaseId: firstBaseId ?? this.firstBaseId,
      secondBaseId: secondBaseId ?? this.secondBaseId,
      thirdBaseId: thirdBaseId ?? this.thirdBaseId,
      currentBatterIndex: currentBatterIndex ?? this.currentBatterIndex,
      theirHalfRuns: theirHalfRuns ?? this.theirHalfRuns,
      ourHalfRuns: ourHalfRuns ?? this.ourHalfRuns,
      scope: scope ?? this.scope,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (scoringDraft.present) {
      map['scoring_draft'] = Variable<String>(scoringDraft.value);
    }
    if (settingsSnapshot.present) {
      map['settings_snapshot'] = Variable<String>(settingsSnapshot.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (opponentId.present) {
      map['opponent_id'] = Variable<String>(opponentId.value);
    }
    if (opponentName.present) {
      map['opponent_name'] = Variable<String>(opponentName.value);
    }
    if (playedForName.present) {
      map['played_for_name'] = Variable<String>(playedForName.value);
    }
    if (playedForTeamId.present) {
      map['played_for_team_id'] = Variable<String>(playedForTeamId.value);
    }
    if (park.present) {
      map['park'] = Variable<String>(park.value);
    }
    if (startsAt.present) {
      map['starts_at'] = Variable<DateTime>(startsAt.value);
    }
    if (homeAway.present) {
      map['home_away'] = Variable<String>(homeAway.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (ourRuns.present) {
      map['our_runs'] = Variable<int>(ourRuns.value);
    }
    if (theirRuns.present) {
      map['their_runs'] = Variable<int>(theirRuns.value);
    }
    if (currentInning.present) {
      map['current_inning'] = Variable<int>(currentInning.value);
    }
    if (currentHalf.present) {
      map['current_half'] = Variable<String>(currentHalf.value);
    }
    if (outs.present) {
      map['outs'] = Variable<int>(outs.value);
    }
    if (scorerUserId.present) {
      map['scorer_user_id'] = Variable<String>(scorerUserId.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (firstBaseId.present) {
      map['first_base_id'] = Variable<String>(firstBaseId.value);
    }
    if (secondBaseId.present) {
      map['second_base_id'] = Variable<String>(secondBaseId.value);
    }
    if (thirdBaseId.present) {
      map['third_base_id'] = Variable<String>(thirdBaseId.value);
    }
    if (currentBatterIndex.present) {
      map['current_batter_index'] = Variable<int>(currentBatterIndex.value);
    }
    if (theirHalfRuns.present) {
      map['their_half_runs'] = Variable<int>(theirHalfRuns.value);
    }
    if (ourHalfRuns.present) {
      map['our_half_runs'] = Variable<int>(ourHalfRuns.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('scoringDraft: $scoringDraft, ')
          ..write('settingsSnapshot: $settingsSnapshot, ')
          ..write('teamId: $teamId, ')
          ..write('kind: $kind, ')
          ..write('opponentId: $opponentId, ')
          ..write('opponentName: $opponentName, ')
          ..write('playedForName: $playedForName, ')
          ..write('playedForTeamId: $playedForTeamId, ')
          ..write('park: $park, ')
          ..write('startsAt: $startsAt, ')
          ..write('homeAway: $homeAway, ')
          ..write('status: $status, ')
          ..write('ourRuns: $ourRuns, ')
          ..write('theirRuns: $theirRuns, ')
          ..write('currentInning: $currentInning, ')
          ..write('currentHalf: $currentHalf, ')
          ..write('outs: $outs, ')
          ..write('scorerUserId: $scorerUserId, ')
          ..write('notes: $notes, ')
          ..write('firstBaseId: $firstBaseId, ')
          ..write('secondBaseId: $secondBaseId, ')
          ..write('thirdBaseId: $thirdBaseId, ')
          ..write('currentBatterIndex: $currentBatterIndex, ')
          ..write('theirHalfRuns: $theirHalfRuns, ')
          ..write('ourHalfRuns: $ourHalfRuns, ')
          ..write('scope: $scope, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameCompetitionsTable extends GameCompetitions
    with TableInfo<$GameCompetitionsTable, GameCompetition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameCompetitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _competitionIdMeta = const VerificationMeta(
    'competitionId',
  );
  @override
  late final GeneratedColumn<String> competitionId = GeneratedColumn<String>(
    'competition_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    gameId,
    competitionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_competitions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameCompetition> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teamIdMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('competition_id')) {
      context.handle(
        _competitionIdMeta,
        competitionId.isAcceptableOrUnknown(
          data['competition_id']!,
          _competitionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_competitionIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameCompetition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameCompetition(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      competitionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}competition_id'],
      )!,
    );
  }

  @override
  $GameCompetitionsTable createAlias(String alias) {
    return $GameCompetitionsTable(attachedDatabase, alias);
  }
}

class GameCompetition extends DataClass implements Insertable<GameCompetition> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String teamId;
  final String gameId;
  final String competitionId;
  const GameCompetition({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    required this.teamId,
    required this.gameId,
    required this.competitionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    map['team_id'] = Variable<String>(teamId);
    map['game_id'] = Variable<String>(gameId);
    map['competition_id'] = Variable<String>(competitionId);
    return map;
  }

  GameCompetitionsCompanion toCompanion(bool nullToAbsent) {
    return GameCompetitionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      teamId: Value(teamId),
      gameId: Value(gameId),
      competitionId: Value(competitionId),
    );
  }

  factory GameCompetition.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameCompetition(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      teamId: serializer.fromJson<String>(json['teamId']),
      gameId: serializer.fromJson<String>(json['gameId']),
      competitionId: serializer.fromJson<String>(json['competitionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'teamId': serializer.toJson<String>(teamId),
      'gameId': serializer.toJson<String>(gameId),
      'competitionId': serializer.toJson<String>(competitionId),
    };
  }

  GameCompetition copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    String? teamId,
    String? gameId,
    String? competitionId,
  }) => GameCompetition(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    teamId: teamId ?? this.teamId,
    gameId: gameId ?? this.gameId,
    competitionId: competitionId ?? this.competitionId,
  );
  GameCompetition copyWithCompanion(GameCompetitionsCompanion data) {
    return GameCompetition(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      competitionId: data.competitionId.present
          ? data.competitionId.value
          : this.competitionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameCompetition(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('competitionId: $competitionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    gameId,
    competitionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameCompetition &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.teamId == this.teamId &&
          other.gameId == this.gameId &&
          other.competitionId == this.competitionId);
}

class GameCompetitionsCompanion extends UpdateCompanion<GameCompetition> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String> teamId;
  final Value<String> gameId;
  final Value<String> competitionId;
  final Value<int> rowid;
  const GameCompetitionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.competitionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameCompetitionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    required String teamId,
    required String gameId,
    required String competitionId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       teamId = Value(teamId),
       gameId = Value(gameId),
       competitionId = Value(competitionId);
  static Insertable<GameCompetition> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? teamId,
    Expression<String>? gameId,
    Expression<String>? competitionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (teamId != null) 'team_id': teamId,
      if (gameId != null) 'game_id': gameId,
      if (competitionId != null) 'competition_id': competitionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameCompetitionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String>? teamId,
    Value<String>? gameId,
    Value<String>? competitionId,
    Value<int>? rowid,
  }) {
    return GameCompetitionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      teamId: teamId ?? this.teamId,
      gameId: gameId ?? this.gameId,
      competitionId: competitionId ?? this.competitionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (competitionId.present) {
      map['competition_id'] = Variable<String>(competitionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameCompetitionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('competitionId: $competitionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineupSlotsTable extends LineupSlots
    with TableInfo<$LineupSlotsTable, LineupSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineupSlotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _battingOrderMeta = const VerificationMeta(
    'battingOrder',
  );
  @override
  late final GeneratedColumn<int> battingOrder = GeneratedColumn<int>(
    'batting_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<String> position = GeneratedColumn<String>(
    'position',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    gameId,
    playerId,
    battingOrder,
    position,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lineup_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<LineupSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('batting_order')) {
      context.handle(
        _battingOrderMeta,
        battingOrder.isAcceptableOrUnknown(
          data['batting_order']!,
          _battingOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_battingOrderMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LineupSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineupSlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      battingOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}batting_order'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}position'],
      ),
    );
  }

  @override
  $LineupSlotsTable createAlias(String alias) {
    return $LineupSlotsTable(attachedDatabase, alias);
  }
}

class LineupSlot extends DataClass implements Insertable<LineupSlot> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String? teamId;
  final String gameId;
  final String playerId;
  final int battingOrder;
  final String? position;
  const LineupSlot({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    this.teamId,
    required this.gameId,
    required this.playerId,
    required this.battingOrder,
    this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    map['game_id'] = Variable<String>(gameId);
    map['player_id'] = Variable<String>(playerId);
    map['batting_order'] = Variable<int>(battingOrder);
    if (!nullToAbsent || position != null) {
      map['position'] = Variable<String>(position);
    }
    return map;
  }

  LineupSlotsCompanion toCompanion(bool nullToAbsent) {
    return LineupSlotsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      gameId: Value(gameId),
      playerId: Value(playerId),
      battingOrder: Value(battingOrder),
      position: position == null && nullToAbsent
          ? const Value.absent()
          : Value(position),
    );
  }

  factory LineupSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineupSlot(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      gameId: serializer.fromJson<String>(json['gameId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      battingOrder: serializer.fromJson<int>(json['battingOrder']),
      position: serializer.fromJson<String?>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'teamId': serializer.toJson<String?>(teamId),
      'gameId': serializer.toJson<String>(gameId),
      'playerId': serializer.toJson<String>(playerId),
      'battingOrder': serializer.toJson<int>(battingOrder),
      'position': serializer.toJson<String?>(position),
    };
  }

  LineupSlot copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    Value<String?> teamId = const Value.absent(),
    String? gameId,
    String? playerId,
    int? battingOrder,
    Value<String?> position = const Value.absent(),
  }) => LineupSlot(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    teamId: teamId.present ? teamId.value : this.teamId,
    gameId: gameId ?? this.gameId,
    playerId: playerId ?? this.playerId,
    battingOrder: battingOrder ?? this.battingOrder,
    position: position.present ? position.value : this.position,
  );
  LineupSlot copyWithCompanion(LineupSlotsCompanion data) {
    return LineupSlot(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      battingOrder: data.battingOrder.present
          ? data.battingOrder.value
          : this.battingOrder,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineupSlot(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('battingOrder: $battingOrder, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    gameId,
    playerId,
    battingOrder,
    position,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineupSlot &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.teamId == this.teamId &&
          other.gameId == this.gameId &&
          other.playerId == this.playerId &&
          other.battingOrder == this.battingOrder &&
          other.position == this.position);
}

class LineupSlotsCompanion extends UpdateCompanion<LineupSlot> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String?> teamId;
  final Value<String> gameId;
  final Value<String> playerId;
  final Value<int> battingOrder;
  final Value<String?> position;
  final Value<int> rowid;
  const LineupSlotsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.battingOrder = const Value.absent(),
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LineupSlotsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    required String gameId,
    required String playerId,
    required int battingOrder,
    this.position = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       gameId = Value(gameId),
       playerId = Value(playerId),
       battingOrder = Value(battingOrder);
  static Insertable<LineupSlot> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? teamId,
    Expression<String>? gameId,
    Expression<String>? playerId,
    Expression<int>? battingOrder,
    Expression<String>? position,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (teamId != null) 'team_id': teamId,
      if (gameId != null) 'game_id': gameId,
      if (playerId != null) 'player_id': playerId,
      if (battingOrder != null) 'batting_order': battingOrder,
      if (position != null) 'position': position,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LineupSlotsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String?>? teamId,
    Value<String>? gameId,
    Value<String>? playerId,
    Value<int>? battingOrder,
    Value<String?>? position,
    Value<int>? rowid,
  }) {
    return LineupSlotsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      teamId: teamId ?? this.teamId,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      battingOrder: battingOrder ?? this.battingOrder,
      position: position ?? this.position,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (battingOrder.present) {
      map['batting_order'] = Variable<int>(battingOrder.value);
    }
    if (position.present) {
      map['position'] = Variable<String>(position.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineupSlotsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('battingOrder: $battingOrder, ')
          ..write('position: $position, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlateAppearancesTable extends PlateAppearances
    with TableInfo<$PlateAppearancesTable, PlateAppearance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlateAppearancesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _resolutionMeta = const VerificationMeta(
    'resolution',
  );
  @override
  late final GeneratedColumn<String> resolution = GeneratedColumn<String>(
    'resolution',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batterWasMaleMeta = const VerificationMeta(
    'batterWasMale',
  );
  @override
  late final GeneratedColumn<bool> batterWasMale = GeneratedColumn<bool>(
    'batter_was_male',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("batter_was_male" IN (0, 1))',
    ),
  );
  static const VerificationMeta _effectiveResultMeta = const VerificationMeta(
    'effectiveResult',
  );
  @override
  late final GeneratedColumn<String> effectiveResult = GeneratedColumn<String>(
    'effective_result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _playerIdMeta = const VerificationMeta(
    'playerId',
  );
  @override
  late final GeneratedColumn<String> playerId = GeneratedColumn<String>(
    'player_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personIdMeta = const VerificationMeta(
    'personId',
  );
  @override
  late final GeneratedColumn<String> personId = GeneratedColumn<String>(
    'person_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inningMeta = const VerificationMeta('inning');
  @override
  late final GeneratedColumn<int> inning = GeneratedColumn<int>(
    'inning',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inningHalfMeta = const VerificationMeta(
    'inningHalf',
  );
  @override
  late final GeneratedColumn<String> inningHalf = GeneratedColumn<String>(
    'inning_half',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rbiMeta = const VerificationMeta('rbi');
  @override
  late final GeneratedColumn<int> rbi = GeneratedColumn<int>(
    'rbi',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _runsScoredMeta = const VerificationMeta(
    'runsScored',
  );
  @override
  late final GeneratedColumn<int> runsScored = GeneratedColumn<int>(
    'runs_scored',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _outsRecordedMeta = const VerificationMeta(
    'outsRecorded',
  );
  @override
  late final GeneratedColumn<int> outsRecorded = GeneratedColumn<int>(
    'outs_recorded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _hitLocationMeta = const VerificationMeta(
    'hitLocation',
  );
  @override
  late final GeneratedColumn<String> hitLocation = GeneratedColumn<String>(
    'hit_location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualityOfContactMeta = const VerificationMeta(
    'qualityOfContact',
  );
  @override
  late final GeneratedColumn<String> qualityOfContact = GeneratedColumn<String>(
    'quality_of_contact',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fielderPlayerIdMeta = const VerificationMeta(
    'fielderPlayerId',
  );
  @override
  late final GeneratedColumn<String> fielderPlayerId = GeneratedColumn<String>(
    'fielder_player_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _runsOnPlayMeta = const VerificationMeta(
    'runsOnPlay',
  );
  @override
  late final GeneratedColumn<int> runsOnPlay = GeneratedColumn<int>(
    'runs_on_play',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batterScoredMeta = const VerificationMeta(
    'batterScored',
  );
  @override
  late final GeneratedColumn<bool> batterScored = GeneratedColumn<bool>(
    'batter_scored',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("batter_scored" IN (0, 1))',
    ),
  );
  static const VerificationMeta _outKindMeta = const VerificationMeta(
    'outKind',
  );
  @override
  late final GeneratedColumn<String> outKind = GeneratedColumn<String>(
    'out_kind',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    resolution,
    batterWasMale,
    effectiveResult,
    teamId,
    gameId,
    playerId,
    personId,
    sequence,
    inning,
    inningHalf,
    result,
    rbi,
    runsScored,
    outsRecorded,
    hitLocation,
    qualityOfContact,
    fielderPlayerId,
    runsOnPlay,
    batterScored,
    outKind,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plate_appearances';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlateAppearance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('resolution')) {
      context.handle(
        _resolutionMeta,
        resolution.isAcceptableOrUnknown(data['resolution']!, _resolutionMeta),
      );
    }
    if (data.containsKey('batter_was_male')) {
      context.handle(
        _batterWasMaleMeta,
        batterWasMale.isAcceptableOrUnknown(
          data['batter_was_male']!,
          _batterWasMaleMeta,
        ),
      );
    }
    if (data.containsKey('effective_result')) {
      context.handle(
        _effectiveResultMeta,
        effectiveResult.isAcceptableOrUnknown(
          data['effective_result']!,
          _effectiveResultMeta,
        ),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('player_id')) {
      context.handle(
        _playerIdMeta,
        playerId.isAcceptableOrUnknown(data['player_id']!, _playerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playerIdMeta);
    }
    if (data.containsKey('person_id')) {
      context.handle(
        _personIdMeta,
        personId.isAcceptableOrUnknown(data['person_id']!, _personIdMeta),
      );
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('inning')) {
      context.handle(
        _inningMeta,
        inning.isAcceptableOrUnknown(data['inning']!, _inningMeta),
      );
    } else if (isInserting) {
      context.missing(_inningMeta);
    }
    if (data.containsKey('inning_half')) {
      context.handle(
        _inningHalfMeta,
        inningHalf.isAcceptableOrUnknown(data['inning_half']!, _inningHalfMeta),
      );
    } else if (isInserting) {
      context.missing(_inningHalfMeta);
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    } else if (isInserting) {
      context.missing(_resultMeta);
    }
    if (data.containsKey('rbi')) {
      context.handle(
        _rbiMeta,
        rbi.isAcceptableOrUnknown(data['rbi']!, _rbiMeta),
      );
    }
    if (data.containsKey('runs_scored')) {
      context.handle(
        _runsScoredMeta,
        runsScored.isAcceptableOrUnknown(data['runs_scored']!, _runsScoredMeta),
      );
    }
    if (data.containsKey('outs_recorded')) {
      context.handle(
        _outsRecordedMeta,
        outsRecorded.isAcceptableOrUnknown(
          data['outs_recorded']!,
          _outsRecordedMeta,
        ),
      );
    }
    if (data.containsKey('hit_location')) {
      context.handle(
        _hitLocationMeta,
        hitLocation.isAcceptableOrUnknown(
          data['hit_location']!,
          _hitLocationMeta,
        ),
      );
    }
    if (data.containsKey('quality_of_contact')) {
      context.handle(
        _qualityOfContactMeta,
        qualityOfContact.isAcceptableOrUnknown(
          data['quality_of_contact']!,
          _qualityOfContactMeta,
        ),
      );
    }
    if (data.containsKey('fielder_player_id')) {
      context.handle(
        _fielderPlayerIdMeta,
        fielderPlayerId.isAcceptableOrUnknown(
          data['fielder_player_id']!,
          _fielderPlayerIdMeta,
        ),
      );
    }
    if (data.containsKey('runs_on_play')) {
      context.handle(
        _runsOnPlayMeta,
        runsOnPlay.isAcceptableOrUnknown(
          data['runs_on_play']!,
          _runsOnPlayMeta,
        ),
      );
    }
    if (data.containsKey('batter_scored')) {
      context.handle(
        _batterScoredMeta,
        batterScored.isAcceptableOrUnknown(
          data['batter_scored']!,
          _batterScoredMeta,
        ),
      );
    }
    if (data.containsKey('out_kind')) {
      context.handle(
        _outKindMeta,
        outKind.isAcceptableOrUnknown(data['out_kind']!, _outKindMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlateAppearance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlateAppearance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      resolution: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}resolution'],
      ),
      batterWasMale: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}batter_was_male'],
      ),
      effectiveResult: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_result'],
      ),
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      playerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}player_id'],
      )!,
      personId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_id'],
      ),
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      inning: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inning'],
      )!,
      inningHalf: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}inning_half'],
      )!,
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      )!,
      rbi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rbi'],
      )!,
      runsScored: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runs_scored'],
      )!,
      outsRecorded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}outs_recorded'],
      )!,
      hitLocation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hit_location'],
      ),
      qualityOfContact: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quality_of_contact'],
      ),
      fielderPlayerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fielder_player_id'],
      ),
      runsOnPlay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runs_on_play'],
      ),
      batterScored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}batter_scored'],
      ),
      outKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}out_kind'],
      ),
    );
  }

  @override
  $PlateAppearancesTable createAlias(String alias) {
    return $PlateAppearancesTable(attachedDatabase, alias);
  }
}

class PlateAppearance extends DataClass implements Insertable<PlateAppearance> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String? resolution;
  final bool? batterWasMale;

  /// Rebuildable scoring credit after applying the game rules.
  final String? effectiveResult;
  final String? teamId;
  final String gameId;
  final String playerId;
  final String? personId;
  final int sequence;
  final int inning;
  final String inningHalf;
  final String result;
  final int rbi;
  final int runsScored;
  final int outsRecorded;
  final String? hitLocation;
  final String? qualityOfContact;
  final String? fielderPlayerId;

  /// Scorer's correction to runs on the play (team) or RBI (personal).
  /// Null means the engine's own count stands.
  final int? runsOnPlay;

  /// Personal games: the batter came around to score later in the inning.
  final bool? batterScored;

  /// How an out was made: fly, ground or line. Null when nobody said.
  final String? outKind;
  const PlateAppearance({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    this.resolution,
    this.batterWasMale,
    this.effectiveResult,
    this.teamId,
    required this.gameId,
    required this.playerId,
    this.personId,
    required this.sequence,
    required this.inning,
    required this.inningHalf,
    required this.result,
    required this.rbi,
    required this.runsScored,
    required this.outsRecorded,
    this.hitLocation,
    this.qualityOfContact,
    this.fielderPlayerId,
    this.runsOnPlay,
    this.batterScored,
    this.outKind,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    if (!nullToAbsent || resolution != null) {
      map['resolution'] = Variable<String>(resolution);
    }
    if (!nullToAbsent || batterWasMale != null) {
      map['batter_was_male'] = Variable<bool>(batterWasMale);
    }
    if (!nullToAbsent || effectiveResult != null) {
      map['effective_result'] = Variable<String>(effectiveResult);
    }
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    map['game_id'] = Variable<String>(gameId);
    map['player_id'] = Variable<String>(playerId);
    if (!nullToAbsent || personId != null) {
      map['person_id'] = Variable<String>(personId);
    }
    map['sequence'] = Variable<int>(sequence);
    map['inning'] = Variable<int>(inning);
    map['inning_half'] = Variable<String>(inningHalf);
    map['result'] = Variable<String>(result);
    map['rbi'] = Variable<int>(rbi);
    map['runs_scored'] = Variable<int>(runsScored);
    map['outs_recorded'] = Variable<int>(outsRecorded);
    if (!nullToAbsent || hitLocation != null) {
      map['hit_location'] = Variable<String>(hitLocation);
    }
    if (!nullToAbsent || qualityOfContact != null) {
      map['quality_of_contact'] = Variable<String>(qualityOfContact);
    }
    if (!nullToAbsent || fielderPlayerId != null) {
      map['fielder_player_id'] = Variable<String>(fielderPlayerId);
    }
    if (!nullToAbsent || runsOnPlay != null) {
      map['runs_on_play'] = Variable<int>(runsOnPlay);
    }
    if (!nullToAbsent || batterScored != null) {
      map['batter_scored'] = Variable<bool>(batterScored);
    }
    if (!nullToAbsent || outKind != null) {
      map['out_kind'] = Variable<String>(outKind);
    }
    return map;
  }

  PlateAppearancesCompanion toCompanion(bool nullToAbsent) {
    return PlateAppearancesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      resolution: resolution == null && nullToAbsent
          ? const Value.absent()
          : Value(resolution),
      batterWasMale: batterWasMale == null && nullToAbsent
          ? const Value.absent()
          : Value(batterWasMale),
      effectiveResult: effectiveResult == null && nullToAbsent
          ? const Value.absent()
          : Value(effectiveResult),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      gameId: Value(gameId),
      playerId: Value(playerId),
      personId: personId == null && nullToAbsent
          ? const Value.absent()
          : Value(personId),
      sequence: Value(sequence),
      inning: Value(inning),
      inningHalf: Value(inningHalf),
      result: Value(result),
      rbi: Value(rbi),
      runsScored: Value(runsScored),
      outsRecorded: Value(outsRecorded),
      hitLocation: hitLocation == null && nullToAbsent
          ? const Value.absent()
          : Value(hitLocation),
      qualityOfContact: qualityOfContact == null && nullToAbsent
          ? const Value.absent()
          : Value(qualityOfContact),
      fielderPlayerId: fielderPlayerId == null && nullToAbsent
          ? const Value.absent()
          : Value(fielderPlayerId),
      runsOnPlay: runsOnPlay == null && nullToAbsent
          ? const Value.absent()
          : Value(runsOnPlay),
      batterScored: batterScored == null && nullToAbsent
          ? const Value.absent()
          : Value(batterScored),
      outKind: outKind == null && nullToAbsent
          ? const Value.absent()
          : Value(outKind),
    );
  }

  factory PlateAppearance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlateAppearance(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      resolution: serializer.fromJson<String?>(json['resolution']),
      batterWasMale: serializer.fromJson<bool?>(json['batterWasMale']),
      effectiveResult: serializer.fromJson<String?>(json['effectiveResult']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      gameId: serializer.fromJson<String>(json['gameId']),
      playerId: serializer.fromJson<String>(json['playerId']),
      personId: serializer.fromJson<String?>(json['personId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      inning: serializer.fromJson<int>(json['inning']),
      inningHalf: serializer.fromJson<String>(json['inningHalf']),
      result: serializer.fromJson<String>(json['result']),
      rbi: serializer.fromJson<int>(json['rbi']),
      runsScored: serializer.fromJson<int>(json['runsScored']),
      outsRecorded: serializer.fromJson<int>(json['outsRecorded']),
      hitLocation: serializer.fromJson<String?>(json['hitLocation']),
      qualityOfContact: serializer.fromJson<String?>(json['qualityOfContact']),
      fielderPlayerId: serializer.fromJson<String?>(json['fielderPlayerId']),
      runsOnPlay: serializer.fromJson<int?>(json['runsOnPlay']),
      batterScored: serializer.fromJson<bool?>(json['batterScored']),
      outKind: serializer.fromJson<String?>(json['outKind']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'resolution': serializer.toJson<String?>(resolution),
      'batterWasMale': serializer.toJson<bool?>(batterWasMale),
      'effectiveResult': serializer.toJson<String?>(effectiveResult),
      'teamId': serializer.toJson<String?>(teamId),
      'gameId': serializer.toJson<String>(gameId),
      'playerId': serializer.toJson<String>(playerId),
      'personId': serializer.toJson<String?>(personId),
      'sequence': serializer.toJson<int>(sequence),
      'inning': serializer.toJson<int>(inning),
      'inningHalf': serializer.toJson<String>(inningHalf),
      'result': serializer.toJson<String>(result),
      'rbi': serializer.toJson<int>(rbi),
      'runsScored': serializer.toJson<int>(runsScored),
      'outsRecorded': serializer.toJson<int>(outsRecorded),
      'hitLocation': serializer.toJson<String?>(hitLocation),
      'qualityOfContact': serializer.toJson<String?>(qualityOfContact),
      'fielderPlayerId': serializer.toJson<String?>(fielderPlayerId),
      'runsOnPlay': serializer.toJson<int?>(runsOnPlay),
      'batterScored': serializer.toJson<bool?>(batterScored),
      'outKind': serializer.toJson<String?>(outKind),
    };
  }

  PlateAppearance copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    Value<String?> resolution = const Value.absent(),
    Value<bool?> batterWasMale = const Value.absent(),
    Value<String?> effectiveResult = const Value.absent(),
    Value<String?> teamId = const Value.absent(),
    String? gameId,
    String? playerId,
    Value<String?> personId = const Value.absent(),
    int? sequence,
    int? inning,
    String? inningHalf,
    String? result,
    int? rbi,
    int? runsScored,
    int? outsRecorded,
    Value<String?> hitLocation = const Value.absent(),
    Value<String?> qualityOfContact = const Value.absent(),
    Value<String?> fielderPlayerId = const Value.absent(),
    Value<int?> runsOnPlay = const Value.absent(),
    Value<bool?> batterScored = const Value.absent(),
    Value<String?> outKind = const Value.absent(),
  }) => PlateAppearance(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    resolution: resolution.present ? resolution.value : this.resolution,
    batterWasMale: batterWasMale.present
        ? batterWasMale.value
        : this.batterWasMale,
    effectiveResult: effectiveResult.present
        ? effectiveResult.value
        : this.effectiveResult,
    teamId: teamId.present ? teamId.value : this.teamId,
    gameId: gameId ?? this.gameId,
    playerId: playerId ?? this.playerId,
    personId: personId.present ? personId.value : this.personId,
    sequence: sequence ?? this.sequence,
    inning: inning ?? this.inning,
    inningHalf: inningHalf ?? this.inningHalf,
    result: result ?? this.result,
    rbi: rbi ?? this.rbi,
    runsScored: runsScored ?? this.runsScored,
    outsRecorded: outsRecorded ?? this.outsRecorded,
    hitLocation: hitLocation.present ? hitLocation.value : this.hitLocation,
    qualityOfContact: qualityOfContact.present
        ? qualityOfContact.value
        : this.qualityOfContact,
    fielderPlayerId: fielderPlayerId.present
        ? fielderPlayerId.value
        : this.fielderPlayerId,
    runsOnPlay: runsOnPlay.present ? runsOnPlay.value : this.runsOnPlay,
    batterScored: batterScored.present ? batterScored.value : this.batterScored,
    outKind: outKind.present ? outKind.value : this.outKind,
  );
  PlateAppearance copyWithCompanion(PlateAppearancesCompanion data) {
    return PlateAppearance(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      resolution: data.resolution.present
          ? data.resolution.value
          : this.resolution,
      batterWasMale: data.batterWasMale.present
          ? data.batterWasMale.value
          : this.batterWasMale,
      effectiveResult: data.effectiveResult.present
          ? data.effectiveResult.value
          : this.effectiveResult,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      playerId: data.playerId.present ? data.playerId.value : this.playerId,
      personId: data.personId.present ? data.personId.value : this.personId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      inning: data.inning.present ? data.inning.value : this.inning,
      inningHalf: data.inningHalf.present
          ? data.inningHalf.value
          : this.inningHalf,
      result: data.result.present ? data.result.value : this.result,
      rbi: data.rbi.present ? data.rbi.value : this.rbi,
      runsScored: data.runsScored.present
          ? data.runsScored.value
          : this.runsScored,
      outsRecorded: data.outsRecorded.present
          ? data.outsRecorded.value
          : this.outsRecorded,
      hitLocation: data.hitLocation.present
          ? data.hitLocation.value
          : this.hitLocation,
      qualityOfContact: data.qualityOfContact.present
          ? data.qualityOfContact.value
          : this.qualityOfContact,
      fielderPlayerId: data.fielderPlayerId.present
          ? data.fielderPlayerId.value
          : this.fielderPlayerId,
      runsOnPlay: data.runsOnPlay.present
          ? data.runsOnPlay.value
          : this.runsOnPlay,
      batterScored: data.batterScored.present
          ? data.batterScored.value
          : this.batterScored,
      outKind: data.outKind.present ? data.outKind.value : this.outKind,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlateAppearance(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('resolution: $resolution, ')
          ..write('batterWasMale: $batterWasMale, ')
          ..write('effectiveResult: $effectiveResult, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('personId: $personId, ')
          ..write('sequence: $sequence, ')
          ..write('inning: $inning, ')
          ..write('inningHalf: $inningHalf, ')
          ..write('result: $result, ')
          ..write('rbi: $rbi, ')
          ..write('runsScored: $runsScored, ')
          ..write('outsRecorded: $outsRecorded, ')
          ..write('hitLocation: $hitLocation, ')
          ..write('qualityOfContact: $qualityOfContact, ')
          ..write('fielderPlayerId: $fielderPlayerId, ')
          ..write('runsOnPlay: $runsOnPlay, ')
          ..write('batterScored: $batterScored, ')
          ..write('outKind: $outKind')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    resolution,
    batterWasMale,
    effectiveResult,
    teamId,
    gameId,
    playerId,
    personId,
    sequence,
    inning,
    inningHalf,
    result,
    rbi,
    runsScored,
    outsRecorded,
    hitLocation,
    qualityOfContact,
    fielderPlayerId,
    runsOnPlay,
    batterScored,
    outKind,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlateAppearance &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.resolution == this.resolution &&
          other.batterWasMale == this.batterWasMale &&
          other.effectiveResult == this.effectiveResult &&
          other.teamId == this.teamId &&
          other.gameId == this.gameId &&
          other.playerId == this.playerId &&
          other.personId == this.personId &&
          other.sequence == this.sequence &&
          other.inning == this.inning &&
          other.inningHalf == this.inningHalf &&
          other.result == this.result &&
          other.rbi == this.rbi &&
          other.runsScored == this.runsScored &&
          other.outsRecorded == this.outsRecorded &&
          other.hitLocation == this.hitLocation &&
          other.qualityOfContact == this.qualityOfContact &&
          other.fielderPlayerId == this.fielderPlayerId &&
          other.runsOnPlay == this.runsOnPlay &&
          other.batterScored == this.batterScored &&
          other.outKind == this.outKind);
}

class PlateAppearancesCompanion extends UpdateCompanion<PlateAppearance> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String?> resolution;
  final Value<bool?> batterWasMale;
  final Value<String?> effectiveResult;
  final Value<String?> teamId;
  final Value<String> gameId;
  final Value<String> playerId;
  final Value<String?> personId;
  final Value<int> sequence;
  final Value<int> inning;
  final Value<String> inningHalf;
  final Value<String> result;
  final Value<int> rbi;
  final Value<int> runsScored;
  final Value<int> outsRecorded;
  final Value<String?> hitLocation;
  final Value<String?> qualityOfContact;
  final Value<String?> fielderPlayerId;
  final Value<int?> runsOnPlay;
  final Value<bool?> batterScored;
  final Value<String?> outKind;
  final Value<int> rowid;
  const PlateAppearancesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.resolution = const Value.absent(),
    this.batterWasMale = const Value.absent(),
    this.effectiveResult = const Value.absent(),
    this.teamId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.playerId = const Value.absent(),
    this.personId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.inning = const Value.absent(),
    this.inningHalf = const Value.absent(),
    this.result = const Value.absent(),
    this.rbi = const Value.absent(),
    this.runsScored = const Value.absent(),
    this.outsRecorded = const Value.absent(),
    this.hitLocation = const Value.absent(),
    this.qualityOfContact = const Value.absent(),
    this.fielderPlayerId = const Value.absent(),
    this.runsOnPlay = const Value.absent(),
    this.batterScored = const Value.absent(),
    this.outKind = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlateAppearancesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.resolution = const Value.absent(),
    this.batterWasMale = const Value.absent(),
    this.effectiveResult = const Value.absent(),
    this.teamId = const Value.absent(),
    required String gameId,
    required String playerId,
    this.personId = const Value.absent(),
    required int sequence,
    required int inning,
    required String inningHalf,
    required String result,
    this.rbi = const Value.absent(),
    this.runsScored = const Value.absent(),
    this.outsRecorded = const Value.absent(),
    this.hitLocation = const Value.absent(),
    this.qualityOfContact = const Value.absent(),
    this.fielderPlayerId = const Value.absent(),
    this.runsOnPlay = const Value.absent(),
    this.batterScored = const Value.absent(),
    this.outKind = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       gameId = Value(gameId),
       playerId = Value(playerId),
       sequence = Value(sequence),
       inning = Value(inning),
       inningHalf = Value(inningHalf),
       result = Value(result);
  static Insertable<PlateAppearance> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? resolution,
    Expression<bool>? batterWasMale,
    Expression<String>? effectiveResult,
    Expression<String>? teamId,
    Expression<String>? gameId,
    Expression<String>? playerId,
    Expression<String>? personId,
    Expression<int>? sequence,
    Expression<int>? inning,
    Expression<String>? inningHalf,
    Expression<String>? result,
    Expression<int>? rbi,
    Expression<int>? runsScored,
    Expression<int>? outsRecorded,
    Expression<String>? hitLocation,
    Expression<String>? qualityOfContact,
    Expression<String>? fielderPlayerId,
    Expression<int>? runsOnPlay,
    Expression<bool>? batterScored,
    Expression<String>? outKind,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (resolution != null) 'resolution': resolution,
      if (batterWasMale != null) 'batter_was_male': batterWasMale,
      if (effectiveResult != null) 'effective_result': effectiveResult,
      if (teamId != null) 'team_id': teamId,
      if (gameId != null) 'game_id': gameId,
      if (playerId != null) 'player_id': playerId,
      if (personId != null) 'person_id': personId,
      if (sequence != null) 'sequence': sequence,
      if (inning != null) 'inning': inning,
      if (inningHalf != null) 'inning_half': inningHalf,
      if (result != null) 'result': result,
      if (rbi != null) 'rbi': rbi,
      if (runsScored != null) 'runs_scored': runsScored,
      if (outsRecorded != null) 'outs_recorded': outsRecorded,
      if (hitLocation != null) 'hit_location': hitLocation,
      if (qualityOfContact != null) 'quality_of_contact': qualityOfContact,
      if (fielderPlayerId != null) 'fielder_player_id': fielderPlayerId,
      if (runsOnPlay != null) 'runs_on_play': runsOnPlay,
      if (batterScored != null) 'batter_scored': batterScored,
      if (outKind != null) 'out_kind': outKind,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlateAppearancesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String?>? resolution,
    Value<bool?>? batterWasMale,
    Value<String?>? effectiveResult,
    Value<String?>? teamId,
    Value<String>? gameId,
    Value<String>? playerId,
    Value<String?>? personId,
    Value<int>? sequence,
    Value<int>? inning,
    Value<String>? inningHalf,
    Value<String>? result,
    Value<int>? rbi,
    Value<int>? runsScored,
    Value<int>? outsRecorded,
    Value<String?>? hitLocation,
    Value<String?>? qualityOfContact,
    Value<String?>? fielderPlayerId,
    Value<int?>? runsOnPlay,
    Value<bool?>? batterScored,
    Value<String?>? outKind,
    Value<int>? rowid,
  }) {
    return PlateAppearancesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      resolution: resolution ?? this.resolution,
      batterWasMale: batterWasMale ?? this.batterWasMale,
      effectiveResult: effectiveResult ?? this.effectiveResult,
      teamId: teamId ?? this.teamId,
      gameId: gameId ?? this.gameId,
      playerId: playerId ?? this.playerId,
      personId: personId ?? this.personId,
      sequence: sequence ?? this.sequence,
      inning: inning ?? this.inning,
      inningHalf: inningHalf ?? this.inningHalf,
      result: result ?? this.result,
      rbi: rbi ?? this.rbi,
      runsScored: runsScored ?? this.runsScored,
      outsRecorded: outsRecorded ?? this.outsRecorded,
      hitLocation: hitLocation ?? this.hitLocation,
      qualityOfContact: qualityOfContact ?? this.qualityOfContact,
      fielderPlayerId: fielderPlayerId ?? this.fielderPlayerId,
      runsOnPlay: runsOnPlay ?? this.runsOnPlay,
      batterScored: batterScored ?? this.batterScored,
      outKind: outKind ?? this.outKind,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (resolution.present) {
      map['resolution'] = Variable<String>(resolution.value);
    }
    if (batterWasMale.present) {
      map['batter_was_male'] = Variable<bool>(batterWasMale.value);
    }
    if (effectiveResult.present) {
      map['effective_result'] = Variable<String>(effectiveResult.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (playerId.present) {
      map['player_id'] = Variable<String>(playerId.value);
    }
    if (personId.present) {
      map['person_id'] = Variable<String>(personId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (inning.present) {
      map['inning'] = Variable<int>(inning.value);
    }
    if (inningHalf.present) {
      map['inning_half'] = Variable<String>(inningHalf.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (rbi.present) {
      map['rbi'] = Variable<int>(rbi.value);
    }
    if (runsScored.present) {
      map['runs_scored'] = Variable<int>(runsScored.value);
    }
    if (outsRecorded.present) {
      map['outs_recorded'] = Variable<int>(outsRecorded.value);
    }
    if (hitLocation.present) {
      map['hit_location'] = Variable<String>(hitLocation.value);
    }
    if (qualityOfContact.present) {
      map['quality_of_contact'] = Variable<String>(qualityOfContact.value);
    }
    if (fielderPlayerId.present) {
      map['fielder_player_id'] = Variable<String>(fielderPlayerId.value);
    }
    if (runsOnPlay.present) {
      map['runs_on_play'] = Variable<int>(runsOnPlay.value);
    }
    if (batterScored.present) {
      map['batter_scored'] = Variable<bool>(batterScored.value);
    }
    if (outKind.present) {
      map['out_kind'] = Variable<String>(outKind.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlateAppearancesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('resolution: $resolution, ')
          ..write('batterWasMale: $batterWasMale, ')
          ..write('effectiveResult: $effectiveResult, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('playerId: $playerId, ')
          ..write('personId: $personId, ')
          ..write('sequence: $sequence, ')
          ..write('inning: $inning, ')
          ..write('inningHalf: $inningHalf, ')
          ..write('result: $result, ')
          ..write('rbi: $rbi, ')
          ..write('runsScored: $runsScored, ')
          ..write('outsRecorded: $outsRecorded, ')
          ..write('hitLocation: $hitLocation, ')
          ..write('qualityOfContact: $qualityOfContact, ')
          ..write('fielderPlayerId: $fielderPlayerId, ')
          ..write('runsOnPlay: $runsOnPlay, ')
          ..write('batterScored: $batterScored, ')
          ..write('outKind: $outKind, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameEventsTable extends GameEvents
    with TableInfo<$GameEventsTable, GameEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _runsMeta = const VerificationMeta('runs');
  @override
  late final GeneratedColumn<int> runs = GeneratedColumn<int>(
    'runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    payload,
    teamId,
    gameId,
    sequence,
    kind,
    runs,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    } else if (isInserting) {
      context.missing(_sequenceMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('runs')) {
      context.handle(
        _runsMeta,
        runs.isAcceptableOrUnknown(data['runs']!, _runsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      runs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}runs'],
      )!,
    );
  }

  @override
  $GameEventsTable createAlias(String alias) {
    return $GameEventsTable(attachedDatabase, alias);
  }
}

class GameEvent extends DataClass implements Insertable<GameEvent> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String? payload;
  final String? teamId;
  final String gameId;
  final int sequence;
  final String kind;
  final int runs;
  const GameEvent({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    this.payload,
    this.teamId,
    required this.gameId,
    required this.sequence,
    required this.kind,
    required this.runs,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    map['game_id'] = Variable<String>(gameId);
    map['sequence'] = Variable<int>(sequence);
    map['kind'] = Variable<String>(kind);
    map['runs'] = Variable<int>(runs);
    return map;
  }

  GameEventsCompanion toCompanion(bool nullToAbsent) {
    return GameEventsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      gameId: Value(gameId),
      sequence: Value(sequence),
      kind: Value(kind),
      runs: Value(runs),
    );
  }

  factory GameEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameEvent(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      payload: serializer.fromJson<String?>(json['payload']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      gameId: serializer.fromJson<String>(json['gameId']),
      sequence: serializer.fromJson<int>(json['sequence']),
      kind: serializer.fromJson<String>(json['kind']),
      runs: serializer.fromJson<int>(json['runs']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'payload': serializer.toJson<String?>(payload),
      'teamId': serializer.toJson<String?>(teamId),
      'gameId': serializer.toJson<String>(gameId),
      'sequence': serializer.toJson<int>(sequence),
      'kind': serializer.toJson<String>(kind),
      'runs': serializer.toJson<int>(runs),
    };
  }

  GameEvent copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    Value<String?> payload = const Value.absent(),
    Value<String?> teamId = const Value.absent(),
    String? gameId,
    int? sequence,
    String? kind,
    int? runs,
  }) => GameEvent(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    payload: payload.present ? payload.value : this.payload,
    teamId: teamId.present ? teamId.value : this.teamId,
    gameId: gameId ?? this.gameId,
    sequence: sequence ?? this.sequence,
    kind: kind ?? this.kind,
    runs: runs ?? this.runs,
  );
  GameEvent copyWithCompanion(GameEventsCompanion data) {
    return GameEvent(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      payload: data.payload.present ? data.payload.value : this.payload,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
      kind: data.kind.present ? data.kind.value : this.kind,
      runs: data.runs.present ? data.runs.value : this.runs,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameEvent(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('payload: $payload, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('sequence: $sequence, ')
          ..write('kind: $kind, ')
          ..write('runs: $runs')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    payload,
    teamId,
    gameId,
    sequence,
    kind,
    runs,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameEvent &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.payload == this.payload &&
          other.teamId == this.teamId &&
          other.gameId == this.gameId &&
          other.sequence == this.sequence &&
          other.kind == this.kind &&
          other.runs == this.runs);
}

class GameEventsCompanion extends UpdateCompanion<GameEvent> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String?> payload;
  final Value<String?> teamId;
  final Value<String> gameId;
  final Value<int> sequence;
  final Value<String> kind;
  final Value<int> runs;
  final Value<int> rowid;
  const GameEventsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.payload = const Value.absent(),
    this.teamId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.sequence = const Value.absent(),
    this.kind = const Value.absent(),
    this.runs = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameEventsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.payload = const Value.absent(),
    this.teamId = const Value.absent(),
    required String gameId,
    required int sequence,
    required String kind,
    this.runs = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       gameId = Value(gameId),
       sequence = Value(sequence),
       kind = Value(kind);
  static Insertable<GameEvent> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? payload,
    Expression<String>? teamId,
    Expression<String>? gameId,
    Expression<int>? sequence,
    Expression<String>? kind,
    Expression<int>? runs,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (payload != null) 'payload': payload,
      if (teamId != null) 'team_id': teamId,
      if (gameId != null) 'game_id': gameId,
      if (sequence != null) 'sequence': sequence,
      if (kind != null) 'kind': kind,
      if (runs != null) 'runs': runs,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameEventsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String?>? payload,
    Value<String?>? teamId,
    Value<String>? gameId,
    Value<int>? sequence,
    Value<String>? kind,
    Value<int>? runs,
    Value<int>? rowid,
  }) {
    return GameEventsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      payload: payload ?? this.payload,
      teamId: teamId ?? this.teamId,
      gameId: gameId ?? this.gameId,
      sequence: sequence ?? this.sequence,
      kind: kind ?? this.kind,
      runs: runs ?? this.runs,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (runs.present) {
      map['runs'] = Variable<int>(runs.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameEventsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('payload: $payload, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('sequence: $sequence, ')
          ..write('kind: $kind, ')
          ..write('runs: $runs, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GameInningsTable extends GameInnings
    with TableInfo<$GameInningsTable, GameInning> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameInningsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncStateMeta = const VerificationMeta(
    'syncState',
  );
  @override
  late final GeneratedColumn<int> syncState = GeneratedColumn<int>(
    'sync_state',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _teamIdMeta = const VerificationMeta('teamId');
  @override
  late final GeneratedColumn<String> teamId = GeneratedColumn<String>(
    'team_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _inningMeta = const VerificationMeta('inning');
  @override
  late final GeneratedColumn<int> inning = GeneratedColumn<int>(
    'inning',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ourRunsMeta = const VerificationMeta(
    'ourRuns',
  );
  @override
  late final GeneratedColumn<int> ourRuns = GeneratedColumn<int>(
    'our_runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _theirRunsMeta = const VerificationMeta(
    'theirRuns',
  );
  @override
  late final GeneratedColumn<int> theirRuns = GeneratedColumn<int>(
    'their_runs',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    gameId,
    inning,
    ourRuns,
    theirRuns,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_innings';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameInning> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('sync_state')) {
      context.handle(
        _syncStateMeta,
        syncState.isAcceptableOrUnknown(data['sync_state']!, _syncStateMeta),
      );
    }
    if (data.containsKey('team_id')) {
      context.handle(
        _teamIdMeta,
        teamId.isAcceptableOrUnknown(data['team_id']!, _teamIdMeta),
      );
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('inning')) {
      context.handle(
        _inningMeta,
        inning.isAcceptableOrUnknown(data['inning']!, _inningMeta),
      );
    } else if (isInserting) {
      context.missing(_inningMeta);
    }
    if (data.containsKey('our_runs')) {
      context.handle(
        _ourRunsMeta,
        ourRuns.isAcceptableOrUnknown(data['our_runs']!, _ourRunsMeta),
      );
    }
    if (data.containsKey('their_runs')) {
      context.handle(
        _theirRunsMeta,
        theirRuns.isAcceptableOrUnknown(data['their_runs']!, _theirRunsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GameInning map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameInning(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      syncState: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sync_state'],
      )!,
      teamId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}team_id'],
      ),
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      inning: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inning'],
      )!,
      ourRuns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}our_runs'],
      )!,
      theirRuns: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}their_runs'],
      )!,
    );
  }

  @override
  $GameInningsTable createAlias(String alias) {
    return $GameInningsTable(attachedDatabase, alias);
  }
}

class GameInning extends DataClass implements Insertable<GameInning> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int syncState;
  final String? teamId;
  final String gameId;
  final int inning;
  final int ourRuns;
  final int theirRuns;
  const GameInning({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.syncState,
    this.teamId,
    required this.gameId,
    required this.inning,
    required this.ourRuns,
    required this.theirRuns,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['sync_state'] = Variable<int>(syncState);
    if (!nullToAbsent || teamId != null) {
      map['team_id'] = Variable<String>(teamId);
    }
    map['game_id'] = Variable<String>(gameId);
    map['inning'] = Variable<int>(inning);
    map['our_runs'] = Variable<int>(ourRuns);
    map['their_runs'] = Variable<int>(theirRuns);
    return map;
  }

  GameInningsCompanion toCompanion(bool nullToAbsent) {
    return GameInningsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      syncState: Value(syncState),
      teamId: teamId == null && nullToAbsent
          ? const Value.absent()
          : Value(teamId),
      gameId: Value(gameId),
      inning: Value(inning),
      ourRuns: Value(ourRuns),
      theirRuns: Value(theirRuns),
    );
  }

  factory GameInning.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameInning(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      syncState: serializer.fromJson<int>(json['syncState']),
      teamId: serializer.fromJson<String?>(json['teamId']),
      gameId: serializer.fromJson<String>(json['gameId']),
      inning: serializer.fromJson<int>(json['inning']),
      ourRuns: serializer.fromJson<int>(json['ourRuns']),
      theirRuns: serializer.fromJson<int>(json['theirRuns']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'syncState': serializer.toJson<int>(syncState),
      'teamId': serializer.toJson<String?>(teamId),
      'gameId': serializer.toJson<String>(gameId),
      'inning': serializer.toJson<int>(inning),
      'ourRuns': serializer.toJson<int>(ourRuns),
      'theirRuns': serializer.toJson<int>(theirRuns),
    };
  }

  GameInning copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? syncState,
    Value<String?> teamId = const Value.absent(),
    String? gameId,
    int? inning,
    int? ourRuns,
    int? theirRuns,
  }) => GameInning(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    syncState: syncState ?? this.syncState,
    teamId: teamId.present ? teamId.value : this.teamId,
    gameId: gameId ?? this.gameId,
    inning: inning ?? this.inning,
    ourRuns: ourRuns ?? this.ourRuns,
    theirRuns: theirRuns ?? this.theirRuns,
  );
  GameInning copyWithCompanion(GameInningsCompanion data) {
    return GameInning(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      syncState: data.syncState.present ? data.syncState.value : this.syncState,
      teamId: data.teamId.present ? data.teamId.value : this.teamId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      inning: data.inning.present ? data.inning.value : this.inning,
      ourRuns: data.ourRuns.present ? data.ourRuns.value : this.ourRuns,
      theirRuns: data.theirRuns.present ? data.theirRuns.value : this.theirRuns,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameInning(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('inning: $inning, ')
          ..write('ourRuns: $ourRuns, ')
          ..write('theirRuns: $theirRuns')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    syncState,
    teamId,
    gameId,
    inning,
    ourRuns,
    theirRuns,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameInning &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.syncState == this.syncState &&
          other.teamId == this.teamId &&
          other.gameId == this.gameId &&
          other.inning == this.inning &&
          other.ourRuns == this.ourRuns &&
          other.theirRuns == this.theirRuns);
}

class GameInningsCompanion extends UpdateCompanion<GameInning> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> syncState;
  final Value<String?> teamId;
  final Value<String> gameId;
  final Value<int> inning;
  final Value<int> ourRuns;
  final Value<int> theirRuns;
  final Value<int> rowid;
  const GameInningsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.inning = const Value.absent(),
    this.ourRuns = const Value.absent(),
    this.theirRuns = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameInningsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.syncState = const Value.absent(),
    this.teamId = const Value.absent(),
    required String gameId,
    required int inning,
    this.ourRuns = const Value.absent(),
    this.theirRuns = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       gameId = Value(gameId),
       inning = Value(inning);
  static Insertable<GameInning> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? syncState,
    Expression<String>? teamId,
    Expression<String>? gameId,
    Expression<int>? inning,
    Expression<int>? ourRuns,
    Expression<int>? theirRuns,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (syncState != null) 'sync_state': syncState,
      if (teamId != null) 'team_id': teamId,
      if (gameId != null) 'game_id': gameId,
      if (inning != null) 'inning': inning,
      if (ourRuns != null) 'our_runs': ourRuns,
      if (theirRuns != null) 'their_runs': theirRuns,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameInningsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? syncState,
    Value<String?>? teamId,
    Value<String>? gameId,
    Value<int>? inning,
    Value<int>? ourRuns,
    Value<int>? theirRuns,
    Value<int>? rowid,
  }) {
    return GameInningsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      syncState: syncState ?? this.syncState,
      teamId: teamId ?? this.teamId,
      gameId: gameId ?? this.gameId,
      inning: inning ?? this.inning,
      ourRuns: ourRuns ?? this.ourRuns,
      theirRuns: theirRuns ?? this.theirRuns,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (syncState.present) {
      map['sync_state'] = Variable<int>(syncState.value);
    }
    if (teamId.present) {
      map['team_id'] = Variable<String>(teamId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (inning.present) {
      map['inning'] = Variable<int>(inning.value);
    }
    if (ourRuns.present) {
      map['our_runs'] = Variable<int>(ourRuns.value);
    }
    if (theirRuns.present) {
      map['their_runs'] = Variable<int>(theirRuns.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameInningsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('syncState: $syncState, ')
          ..write('teamId: $teamId, ')
          ..write('gameId: $gameId, ')
          ..write('inning: $inning, ')
          ..write('ourRuns: $ourRuns, ')
          ..write('theirRuns: $theirRuns, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalSyncCursorsTable extends LocalSyncCursors
    with TableInfo<$LocalSyncCursorsTable, LocalSyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalSyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _cursorTableMeta = const VerificationMeta(
    'cursorTable',
  );
  @override
  late final GeneratedColumn<String> cursorTable = GeneratedColumn<String>(
    'cursor_table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cursorMeta = const VerificationMeta('cursor');
  @override
  late final GeneratedColumn<DateTime> cursor = GeneratedColumn<DateTime>(
    'cursor',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [cursorTable, cursor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_sync_cursors';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalSyncCursor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('cursor_table')) {
      context.handle(
        _cursorTableMeta,
        cursorTable.isAcceptableOrUnknown(
          data['cursor_table']!,
          _cursorTableMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_cursorTableMeta);
    }
    if (data.containsKey('cursor')) {
      context.handle(
        _cursorMeta,
        cursor.isAcceptableOrUnknown(data['cursor']!, _cursorMeta),
      );
    } else if (isInserting) {
      context.missing(_cursorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {cursorTable};
  @override
  LocalSyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalSyncCursor(
      cursorTable: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cursor_table'],
      )!,
      cursor: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cursor'],
      )!,
    );
  }

  @override
  $LocalSyncCursorsTable createAlias(String alias) {
    return $LocalSyncCursorsTable(attachedDatabase, alias);
  }
}

class LocalSyncCursor extends DataClass implements Insertable<LocalSyncCursor> {
  final String cursorTable;
  final DateTime cursor;
  const LocalSyncCursor({required this.cursorTable, required this.cursor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['cursor_table'] = Variable<String>(cursorTable);
    map['cursor'] = Variable<DateTime>(cursor);
    return map;
  }

  LocalSyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return LocalSyncCursorsCompanion(
      cursorTable: Value(cursorTable),
      cursor: Value(cursor),
    );
  }

  factory LocalSyncCursor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalSyncCursor(
      cursorTable: serializer.fromJson<String>(json['cursorTable']),
      cursor: serializer.fromJson<DateTime>(json['cursor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'cursorTable': serializer.toJson<String>(cursorTable),
      'cursor': serializer.toJson<DateTime>(cursor),
    };
  }

  LocalSyncCursor copyWith({String? cursorTable, DateTime? cursor}) =>
      LocalSyncCursor(
        cursorTable: cursorTable ?? this.cursorTable,
        cursor: cursor ?? this.cursor,
      );
  LocalSyncCursor copyWithCompanion(LocalSyncCursorsCompanion data) {
    return LocalSyncCursor(
      cursorTable: data.cursorTable.present
          ? data.cursorTable.value
          : this.cursorTable,
      cursor: data.cursor.present ? data.cursor.value : this.cursor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncCursor(')
          ..write('cursorTable: $cursorTable, ')
          ..write('cursor: $cursor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(cursorTable, cursor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalSyncCursor &&
          other.cursorTable == this.cursorTable &&
          other.cursor == this.cursor);
}

class LocalSyncCursorsCompanion extends UpdateCompanion<LocalSyncCursor> {
  final Value<String> cursorTable;
  final Value<DateTime> cursor;
  final Value<int> rowid;
  const LocalSyncCursorsCompanion({
    this.cursorTable = const Value.absent(),
    this.cursor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalSyncCursorsCompanion.insert({
    required String cursorTable,
    required DateTime cursor,
    this.rowid = const Value.absent(),
  }) : cursorTable = Value(cursorTable),
       cursor = Value(cursor);
  static Insertable<LocalSyncCursor> custom({
    Expression<String>? cursorTable,
    Expression<DateTime>? cursor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (cursorTable != null) 'cursor_table': cursorTable,
      if (cursor != null) 'cursor': cursor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalSyncCursorsCompanion copyWith({
    Value<String>? cursorTable,
    Value<DateTime>? cursor,
    Value<int>? rowid,
  }) {
    return LocalSyncCursorsCompanion(
      cursorTable: cursorTable ?? this.cursorTable,
      cursor: cursor ?? this.cursor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (cursorTable.present) {
      map['cursor_table'] = Variable<String>(cursorTable.value);
    }
    if (cursor.present) {
      map['cursor'] = Variable<DateTime>(cursor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalSyncCursorsCompanion(')
          ..write('cursorTable: $cursorTable, ')
          ..write('cursor: $cursor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PeopleTable people = $PeopleTable(this);
  late final $PersonalTeamsTable personalTeams = $PersonalTeamsTable(this);
  late final $TeamsTable teams = $TeamsTable(this);
  late final $TeamMembersTable teamMembers = $TeamMembersTable(this);
  late final $InviteCodesTable inviteCodes = $InviteCodesTable(this);
  late final $PlayersTable players = $PlayersTable(this);
  late final $OpponentsTable opponents = $OpponentsTable(this);
  late final $CompetitionsTable competitions = $CompetitionsTable(this);
  late final $GamesTable games = $GamesTable(this);
  late final $GameCompetitionsTable gameCompetitions = $GameCompetitionsTable(
    this,
  );
  late final $LineupSlotsTable lineupSlots = $LineupSlotsTable(this);
  late final $PlateAppearancesTable plateAppearances = $PlateAppearancesTable(
    this,
  );
  late final $GameEventsTable gameEvents = $GameEventsTable(this);
  late final $GameInningsTable gameInnings = $GameInningsTable(this);
  late final $LocalSyncCursorsTable localSyncCursors = $LocalSyncCursorsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    people,
    personalTeams,
    teams,
    teamMembers,
    inviteCodes,
    players,
    opponents,
    competitions,
    games,
    gameCompetitions,
    lineupSlots,
    plateAppearances,
    gameEvents,
    gameInnings,
    localSyncCursors,
  ];
}

typedef $$PeopleTableCreateCompanionBuilder =
    PeopleCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> displayName,
      Value<String> firstName,
      Value<String> lastName,
      Value<String?> linkedUserId,
      Value<int> rowid,
    });
typedef $$PeopleTableUpdateCompanionBuilder =
    PeopleCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> displayName,
      Value<String> firstName,
      Value<String> lastName,
      Value<String?> linkedUserId,
      Value<int> rowid,
    });

class $$PeopleTableFilterComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get linkedUserId => $composableBuilder(
    column: $table.linkedUserId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PeopleTableOrderingComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get linkedUserId => $composableBuilder(
    column: $table.linkedUserId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PeopleTableAnnotationComposer
    extends Composer<_$AppDatabase, $PeopleTable> {
  $$PeopleTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get linkedUserId => $composableBuilder(
    column: $table.linkedUserId,
    builder: (column) => column,
  );
}

class $$PeopleTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PeopleTable,
          Person,
          $$PeopleTableFilterComposer,
          $$PeopleTableOrderingComposer,
          $$PeopleTableAnnotationComposer,
          $$PeopleTableCreateCompanionBuilder,
          $$PeopleTableUpdateCompanionBuilder,
          (Person, BaseReferences<_$AppDatabase, $PeopleTable, Person>),
          Person,
          PrefetchHooks Function()
        > {
  $$PeopleTableTableManager(_$AppDatabase db, $PeopleTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PeopleTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PeopleTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PeopleTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> linkedUserId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                displayName: displayName,
                firstName: firstName,
                lastName: lastName,
                linkedUserId: linkedUserId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> linkedUserId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PeopleCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                displayName: displayName,
                firstName: firstName,
                lastName: lastName,
                linkedUserId: linkedUserId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PeopleTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PeopleTable,
      Person,
      $$PeopleTableFilterComposer,
      $$PeopleTableOrderingComposer,
      $$PeopleTableAnnotationComposer,
      $$PeopleTableCreateCompanionBuilder,
      $$PeopleTableUpdateCompanionBuilder,
      (Person, BaseReferences<_$AppDatabase, $PeopleTable, Person>),
      Person,
      PrefetchHooks Function()
    >;
typedef $$PersonalTeamsTableCreateCompanionBuilder =
    PersonalTeamsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      required String personId,
      required String name,
      Value<int> rowid,
    });
typedef $$PersonalTeamsTableUpdateCompanionBuilder =
    PersonalTeamsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> personId,
      Value<String> name,
      Value<int> rowid,
    });

class $$PersonalTeamsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalTeamsTable> {
  $$PersonalTeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PersonalTeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalTeamsTable> {
  $$PersonalTeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PersonalTeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalTeamsTable> {
  $$PersonalTeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$PersonalTeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalTeamsTable,
          PersonalTeam,
          $$PersonalTeamsTableFilterComposer,
          $$PersonalTeamsTableOrderingComposer,
          $$PersonalTeamsTableAnnotationComposer,
          $$PersonalTeamsTableCreateCompanionBuilder,
          $$PersonalTeamsTableUpdateCompanionBuilder,
          (
            PersonalTeam,
            BaseReferences<_$AppDatabase, $PersonalTeamsTable, PersonalTeam>,
          ),
          PersonalTeam,
          PrefetchHooks Function()
        > {
  $$PersonalTeamsTableTableManager(_$AppDatabase db, $PersonalTeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalTeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalTeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalTeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> personId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalTeamsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                personId: personId,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                required String personId,
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => PersonalTeamsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                personId: personId,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PersonalTeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalTeamsTable,
      PersonalTeam,
      $$PersonalTeamsTableFilterComposer,
      $$PersonalTeamsTableOrderingComposer,
      $$PersonalTeamsTableAnnotationComposer,
      $$PersonalTeamsTableCreateCompanionBuilder,
      $$PersonalTeamsTableUpdateCompanionBuilder,
      (
        PersonalTeam,
        BaseReferences<_$AppDatabase, $PersonalTeamsTable, PersonalTeam>,
      ),
      PersonalTeam,
      PrefetchHooks Function()
    >;
typedef $$TeamsTableCreateCompanionBuilder =
    TeamsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      required String name,
      Value<String> type,
      Value<String> settings,
      Value<int> rowid,
    });
typedef $$TeamsTableUpdateCompanionBuilder =
    TeamsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> name,
      Value<String> type,
      Value<String> settings,
      Value<int> rowid,
    });

class $$TeamsTableFilterComposer extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamsTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settings => $composableBuilder(
    column: $table.settings,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamsTable> {
  $$TeamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get settings =>
      $composableBuilder(column: $table.settings, builder: (column) => column);
}

class $$TeamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamsTable,
          Team,
          $$TeamsTableFilterComposer,
          $$TeamsTableOrderingComposer,
          $$TeamsTableAnnotationComposer,
          $$TeamsTableCreateCompanionBuilder,
          $$TeamsTableUpdateCompanionBuilder,
          (Team, BaseReferences<_$AppDatabase, $TeamsTable, Team>),
          Team,
          PrefetchHooks Function()
        > {
  $$TeamsTableTableManager(_$AppDatabase db, $TeamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> settings = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                type: type,
                settings: settings,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                required String name,
                Value<String> type = const Value.absent(),
                Value<String> settings = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                name: name,
                type: type,
                settings: settings,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamsTable,
      Team,
      $$TeamsTableFilterComposer,
      $$TeamsTableOrderingComposer,
      $$TeamsTableAnnotationComposer,
      $$TeamsTableCreateCompanionBuilder,
      $$TeamsTableUpdateCompanionBuilder,
      (Team, BaseReferences<_$AppDatabase, $TeamsTable, Team>),
      Team,
      PrefetchHooks Function()
    >;
typedef $$TeamMembersTableCreateCompanionBuilder =
    TeamMembersCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      required String teamId,
      required String userId,
      required String role,
      Value<int> rowid,
    });
typedef $$TeamMembersTableUpdateCompanionBuilder =
    TeamMembersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> teamId,
      Value<String> userId,
      Value<String> role,
      Value<int> rowid,
    });

class $$TeamMembersTableFilterComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeamMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeamMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeamMembersTable> {
  $$TeamMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);
}

class $$TeamMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeamMembersTable,
          TeamMember,
          $$TeamMembersTableFilterComposer,
          $$TeamMembersTableOrderingComposer,
          $$TeamMembersTableAnnotationComposer,
          $$TeamMembersTableCreateCompanionBuilder,
          $$TeamMembersTableUpdateCompanionBuilder,
          (
            TeamMember,
            BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMember>,
          ),
          TeamMember,
          PrefetchHooks Function()
        > {
  $$TeamMembersTableTableManager(_$AppDatabase db, $TeamMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeamMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeamMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeamMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                userId: userId,
                role: role,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                required String teamId,
                required String userId,
                required String role,
                Value<int> rowid = const Value.absent(),
              }) => TeamMembersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                userId: userId,
                role: role,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeamMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeamMembersTable,
      TeamMember,
      $$TeamMembersTableFilterComposer,
      $$TeamMembersTableOrderingComposer,
      $$TeamMembersTableAnnotationComposer,
      $$TeamMembersTableCreateCompanionBuilder,
      $$TeamMembersTableUpdateCompanionBuilder,
      (
        TeamMember,
        BaseReferences<_$AppDatabase, $TeamMembersTable, TeamMember>,
      ),
      TeamMember,
      PrefetchHooks Function()
    >;
typedef $$InviteCodesTableCreateCompanionBuilder =
    InviteCodesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      required String teamId,
      required String code,
      required String role,
      Value<DateTime?> expiresAt,
      Value<int> rowid,
    });
typedef $$InviteCodesTableUpdateCompanionBuilder =
    InviteCodesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> teamId,
      Value<String> code,
      Value<String> role,
      Value<DateTime?> expiresAt,
      Value<int> rowid,
    });

class $$InviteCodesTableFilterComposer
    extends Composer<_$AppDatabase, $InviteCodesTable> {
  $$InviteCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InviteCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $InviteCodesTable> {
  $$InviteCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InviteCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InviteCodesTable> {
  $$InviteCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$InviteCodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InviteCodesTable,
          InviteCode,
          $$InviteCodesTableFilterComposer,
          $$InviteCodesTableOrderingComposer,
          $$InviteCodesTableAnnotationComposer,
          $$InviteCodesTableCreateCompanionBuilder,
          $$InviteCodesTableUpdateCompanionBuilder,
          (
            InviteCode,
            BaseReferences<_$AppDatabase, $InviteCodesTable, InviteCode>,
          ),
          InviteCode,
          PrefetchHooks Function()
        > {
  $$InviteCodesTableTableManager(_$AppDatabase db, $InviteCodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InviteCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InviteCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InviteCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InviteCodesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                code: code,
                role: role,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                required String teamId,
                required String code,
                required String role,
                Value<DateTime?> expiresAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InviteCodesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                code: code,
                role: role,
                expiresAt: expiresAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InviteCodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InviteCodesTable,
      InviteCode,
      $$InviteCodesTableFilterComposer,
      $$InviteCodesTableOrderingComposer,
      $$InviteCodesTableAnnotationComposer,
      $$InviteCodesTableCreateCompanionBuilder,
      $$InviteCodesTableUpdateCompanionBuilder,
      (
        InviteCode,
        BaseReferences<_$AppDatabase, $InviteCodesTable, InviteCode>,
      ),
      InviteCode,
      PrefetchHooks Function()
    >;
typedef $$PlayersTableCreateCompanionBuilder =
    PlayersCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> teamId,
      Value<String?> personId,
      required String firstName,
      Value<String> lastName,
      Value<String?> jerseyNumber,
      Value<String> bats,
      Value<String> throws_,
      Value<String> gender,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$PlayersTableUpdateCompanionBuilder =
    PlayersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> teamId,
      Value<String?> personId,
      Value<String> firstName,
      Value<String> lastName,
      Value<String?> jerseyNumber,
      Value<String> bats,
      Value<String> throws_,
      Value<String> gender,
      Value<String> status,
      Value<int> rowid,
    });

class $$PlayersTableFilterComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bats => $composableBuilder(
    column: $table.bats,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get throws_ => $composableBuilder(
    column: $table.throws_,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlayersTableOrderingComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bats => $composableBuilder(
    column: $table.bats,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get throws_ => $composableBuilder(
    column: $table.throws_,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlayersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlayersTable> {
  $$PlayersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get jerseyNumber => $composableBuilder(
    column: $table.jerseyNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bats =>
      $composableBuilder(column: $table.bats, builder: (column) => column);

  GeneratedColumn<String> get throws_ =>
      $composableBuilder(column: $table.throws_, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $$PlayersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlayersTable,
          Player,
          $$PlayersTableFilterComposer,
          $$PlayersTableOrderingComposer,
          $$PlayersTableAnnotationComposer,
          $$PlayersTableCreateCompanionBuilder,
          $$PlayersTableUpdateCompanionBuilder,
          (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
          Player,
          PrefetchHooks Function()
        > {
  $$PlayersTableTableManager(_$AppDatabase db, $PlayersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlayersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlayersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlayersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String> lastName = const Value.absent(),
                Value<String?> jerseyNumber = const Value.absent(),
                Value<String> bats = const Value.absent(),
                Value<String> throws_ = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                personId: personId,
                firstName: firstName,
                lastName: lastName,
                jerseyNumber: jerseyNumber,
                bats: bats,
                throws_: throws_,
                gender: gender,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                required String firstName,
                Value<String> lastName = const Value.absent(),
                Value<String?> jerseyNumber = const Value.absent(),
                Value<String> bats = const Value.absent(),
                Value<String> throws_ = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlayersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                personId: personId,
                firstName: firstName,
                lastName: lastName,
                jerseyNumber: jerseyNumber,
                bats: bats,
                throws_: throws_,
                gender: gender,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlayersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlayersTable,
      Player,
      $$PlayersTableFilterComposer,
      $$PlayersTableOrderingComposer,
      $$PlayersTableAnnotationComposer,
      $$PlayersTableCreateCompanionBuilder,
      $$PlayersTableUpdateCompanionBuilder,
      (Player, BaseReferences<_$AppDatabase, $PlayersTable, Player>),
      Player,
      PrefetchHooks Function()
    >;
typedef $$OpponentsTableCreateCompanionBuilder =
    OpponentsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      required String teamId,
      required String name,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$OpponentsTableUpdateCompanionBuilder =
    OpponentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> teamId,
      Value<String> name,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$OpponentsTableFilterComposer
    extends Composer<_$AppDatabase, $OpponentsTable> {
  $$OpponentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OpponentsTableOrderingComposer
    extends Composer<_$AppDatabase, $OpponentsTable> {
  $$OpponentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OpponentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpponentsTable> {
  $$OpponentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$OpponentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpponentsTable,
          Opponent,
          $$OpponentsTableFilterComposer,
          $$OpponentsTableOrderingComposer,
          $$OpponentsTableAnnotationComposer,
          $$OpponentsTableCreateCompanionBuilder,
          $$OpponentsTableUpdateCompanionBuilder,
          (Opponent, BaseReferences<_$AppDatabase, $OpponentsTable, Opponent>),
          Opponent,
          PrefetchHooks Function()
        > {
  $$OpponentsTableTableManager(_$AppDatabase db, $OpponentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpponentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpponentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpponentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OpponentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                name: name,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                required String teamId,
                required String name,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OpponentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                name: name,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OpponentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpponentsTable,
      Opponent,
      $$OpponentsTableFilterComposer,
      $$OpponentsTableOrderingComposer,
      $$OpponentsTableAnnotationComposer,
      $$OpponentsTableCreateCompanionBuilder,
      $$OpponentsTableUpdateCompanionBuilder,
      (Opponent, BaseReferences<_$AppDatabase, $OpponentsTable, Opponent>),
      Opponent,
      PrefetchHooks Function()
    >;
typedef $$CompetitionsTableCreateCompanionBuilder =
    CompetitionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      required String teamId,
      required String type,
      required String name,
      Value<String?> leagueName,
      Value<String?> location,
      Value<DateTime?> startsOn,
      Value<DateTime?> endsOn,
      Value<int> rowid,
    });
typedef $$CompetitionsTableUpdateCompanionBuilder =
    CompetitionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> teamId,
      Value<String> type,
      Value<String> name,
      Value<String?> leagueName,
      Value<String?> location,
      Value<DateTime?> startsOn,
      Value<DateTime?> endsOn,
      Value<int> rowid,
    });

class $$CompetitionsTableFilterComposer
    extends Composer<_$AppDatabase, $CompetitionsTable> {
  $$CompetitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get leagueName => $composableBuilder(
    column: $table.leagueName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CompetitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CompetitionsTable> {
  $$CompetitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get leagueName => $composableBuilder(
    column: $table.leagueName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CompetitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CompetitionsTable> {
  $$CompetitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get leagueName => $composableBuilder(
    column: $table.leagueName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<DateTime> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);
}

class $$CompetitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CompetitionsTable,
          Competition,
          $$CompetitionsTableFilterComposer,
          $$CompetitionsTableOrderingComposer,
          $$CompetitionsTableAnnotationComposer,
          $$CompetitionsTableCreateCompanionBuilder,
          $$CompetitionsTableUpdateCompanionBuilder,
          (
            Competition,
            BaseReferences<_$AppDatabase, $CompetitionsTable, Competition>,
          ),
          Competition,
          PrefetchHooks Function()
        > {
  $$CompetitionsTableTableManager(_$AppDatabase db, $CompetitionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CompetitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CompetitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CompetitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> leagueName = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime?> startsOn = const Value.absent(),
                Value<DateTime?> endsOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompetitionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                type: type,
                name: name,
                leagueName: leagueName,
                location: location,
                startsOn: startsOn,
                endsOn: endsOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                required String teamId,
                required String type,
                required String name,
                Value<String?> leagueName = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime?> startsOn = const Value.absent(),
                Value<DateTime?> endsOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CompetitionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                type: type,
                name: name,
                leagueName: leagueName,
                location: location,
                startsOn: startsOn,
                endsOn: endsOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CompetitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CompetitionsTable,
      Competition,
      $$CompetitionsTableFilterComposer,
      $$CompetitionsTableOrderingComposer,
      $$CompetitionsTableAnnotationComposer,
      $$CompetitionsTableCreateCompanionBuilder,
      $$CompetitionsTableUpdateCompanionBuilder,
      (
        Competition,
        BaseReferences<_$AppDatabase, $CompetitionsTable, Competition>,
      ),
      Competition,
      PrefetchHooks Function()
    >;
typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> scoringDraft,
      Value<String?> settingsSnapshot,
      Value<String?> teamId,
      Value<String> kind,
      Value<String?> opponentId,
      Value<String?> opponentName,
      Value<String?> playedForName,
      Value<String?> playedForTeamId,
      Value<String?> park,
      Value<DateTime?> startsAt,
      Value<String> homeAway,
      Value<String> status,
      Value<int> ourRuns,
      Value<int> theirRuns,
      Value<int> currentInning,
      Value<String> currentHalf,
      Value<int> outs,
      Value<String?> scorerUserId,
      Value<String?> notes,
      Value<String?> firstBaseId,
      Value<String?> secondBaseId,
      Value<String?> thirdBaseId,
      Value<int> currentBatterIndex,
      Value<int> theirHalfRuns,
      Value<int> ourHalfRuns,
      Value<String> scope,
      Value<int> rowid,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> scoringDraft,
      Value<String?> settingsSnapshot,
      Value<String?> teamId,
      Value<String> kind,
      Value<String?> opponentId,
      Value<String?> opponentName,
      Value<String?> playedForName,
      Value<String?> playedForTeamId,
      Value<String?> park,
      Value<DateTime?> startsAt,
      Value<String> homeAway,
      Value<String> status,
      Value<int> ourRuns,
      Value<int> theirRuns,
      Value<int> currentInning,
      Value<String> currentHalf,
      Value<int> outs,
      Value<String?> scorerUserId,
      Value<String?> notes,
      Value<String?> firstBaseId,
      Value<String?> secondBaseId,
      Value<String?> thirdBaseId,
      Value<int> currentBatterIndex,
      Value<int> theirHalfRuns,
      Value<int> ourHalfRuns,
      Value<String> scope,
      Value<int> rowid,
    });

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scoringDraft => $composableBuilder(
    column: $table.scoringDraft,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingsSnapshot => $composableBuilder(
    column: $table.settingsSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponentId => $composableBuilder(
    column: $table.opponentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playedForName => $composableBuilder(
    column: $table.playedForName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playedForTeamId => $composableBuilder(
    column: $table.playedForTeamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get park => $composableBuilder(
    column: $table.park,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get homeAway => $composableBuilder(
    column: $table.homeAway,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ourRuns => $composableBuilder(
    column: $table.ourRuns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get theirRuns => $composableBuilder(
    column: $table.theirRuns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentInning => $composableBuilder(
    column: $table.currentInning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentHalf => $composableBuilder(
    column: $table.currentHalf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outs => $composableBuilder(
    column: $table.outs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scorerUserId => $composableBuilder(
    column: $table.scorerUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstBaseId => $composableBuilder(
    column: $table.firstBaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondBaseId => $composableBuilder(
    column: $table.secondBaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thirdBaseId => $composableBuilder(
    column: $table.thirdBaseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentBatterIndex => $composableBuilder(
    column: $table.currentBatterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get theirHalfRuns => $composableBuilder(
    column: $table.theirHalfRuns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ourHalfRuns => $composableBuilder(
    column: $table.ourHalfRuns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scoringDraft => $composableBuilder(
    column: $table.scoringDraft,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingsSnapshot => $composableBuilder(
    column: $table.settingsSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponentId => $composableBuilder(
    column: $table.opponentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playedForName => $composableBuilder(
    column: $table.playedForName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playedForTeamId => $composableBuilder(
    column: $table.playedForTeamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get park => $composableBuilder(
    column: $table.park,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsAt => $composableBuilder(
    column: $table.startsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get homeAway => $composableBuilder(
    column: $table.homeAway,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ourRuns => $composableBuilder(
    column: $table.ourRuns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get theirRuns => $composableBuilder(
    column: $table.theirRuns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentInning => $composableBuilder(
    column: $table.currentInning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentHalf => $composableBuilder(
    column: $table.currentHalf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outs => $composableBuilder(
    column: $table.outs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scorerUserId => $composableBuilder(
    column: $table.scorerUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstBaseId => $composableBuilder(
    column: $table.firstBaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondBaseId => $composableBuilder(
    column: $table.secondBaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thirdBaseId => $composableBuilder(
    column: $table.thirdBaseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentBatterIndex => $composableBuilder(
    column: $table.currentBatterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get theirHalfRuns => $composableBuilder(
    column: $table.theirHalfRuns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ourHalfRuns => $composableBuilder(
    column: $table.ourHalfRuns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get scoringDraft => $composableBuilder(
    column: $table.scoringDraft,
    builder: (column) => column,
  );

  GeneratedColumn<String> get settingsSnapshot => $composableBuilder(
    column: $table.settingsSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get opponentId => $composableBuilder(
    column: $table.opponentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playedForName => $composableBuilder(
    column: $table.playedForName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playedForTeamId => $composableBuilder(
    column: $table.playedForTeamId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get park =>
      $composableBuilder(column: $table.park, builder: (column) => column);

  GeneratedColumn<DateTime> get startsAt =>
      $composableBuilder(column: $table.startsAt, builder: (column) => column);

  GeneratedColumn<String> get homeAway =>
      $composableBuilder(column: $table.homeAway, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get ourRuns =>
      $composableBuilder(column: $table.ourRuns, builder: (column) => column);

  GeneratedColumn<int> get theirRuns =>
      $composableBuilder(column: $table.theirRuns, builder: (column) => column);

  GeneratedColumn<int> get currentInning => $composableBuilder(
    column: $table.currentInning,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currentHalf => $composableBuilder(
    column: $table.currentHalf,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outs =>
      $composableBuilder(column: $table.outs, builder: (column) => column);

  GeneratedColumn<String> get scorerUserId => $composableBuilder(
    column: $table.scorerUserId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get firstBaseId => $composableBuilder(
    column: $table.firstBaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondBaseId => $composableBuilder(
    column: $table.secondBaseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thirdBaseId => $composableBuilder(
    column: $table.thirdBaseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentBatterIndex => $composableBuilder(
    column: $table.currentBatterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get theirHalfRuns => $composableBuilder(
    column: $table.theirHalfRuns,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ourHalfRuns => $composableBuilder(
    column: $table.ourHalfRuns,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, BaseReferences<_$AppDatabase, $GamesTable, Game>),
          Game,
          PrefetchHooks Function()
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> scoringDraft = const Value.absent(),
                Value<String?> settingsSnapshot = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> opponentId = const Value.absent(),
                Value<String?> opponentName = const Value.absent(),
                Value<String?> playedForName = const Value.absent(),
                Value<String?> playedForTeamId = const Value.absent(),
                Value<String?> park = const Value.absent(),
                Value<DateTime?> startsAt = const Value.absent(),
                Value<String> homeAway = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> ourRuns = const Value.absent(),
                Value<int> theirRuns = const Value.absent(),
                Value<int> currentInning = const Value.absent(),
                Value<String> currentHalf = const Value.absent(),
                Value<int> outs = const Value.absent(),
                Value<String?> scorerUserId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> firstBaseId = const Value.absent(),
                Value<String?> secondBaseId = const Value.absent(),
                Value<String?> thirdBaseId = const Value.absent(),
                Value<int> currentBatterIndex = const Value.absent(),
                Value<int> theirHalfRuns = const Value.absent(),
                Value<int> ourHalfRuns = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                scoringDraft: scoringDraft,
                settingsSnapshot: settingsSnapshot,
                teamId: teamId,
                kind: kind,
                opponentId: opponentId,
                opponentName: opponentName,
                playedForName: playedForName,
                playedForTeamId: playedForTeamId,
                park: park,
                startsAt: startsAt,
                homeAway: homeAway,
                status: status,
                ourRuns: ourRuns,
                theirRuns: theirRuns,
                currentInning: currentInning,
                currentHalf: currentHalf,
                outs: outs,
                scorerUserId: scorerUserId,
                notes: notes,
                firstBaseId: firstBaseId,
                secondBaseId: secondBaseId,
                thirdBaseId: thirdBaseId,
                currentBatterIndex: currentBatterIndex,
                theirHalfRuns: theirHalfRuns,
                ourHalfRuns: ourHalfRuns,
                scope: scope,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> scoringDraft = const Value.absent(),
                Value<String?> settingsSnapshot = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> opponentId = const Value.absent(),
                Value<String?> opponentName = const Value.absent(),
                Value<String?> playedForName = const Value.absent(),
                Value<String?> playedForTeamId = const Value.absent(),
                Value<String?> park = const Value.absent(),
                Value<DateTime?> startsAt = const Value.absent(),
                Value<String> homeAway = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> ourRuns = const Value.absent(),
                Value<int> theirRuns = const Value.absent(),
                Value<int> currentInning = const Value.absent(),
                Value<String> currentHalf = const Value.absent(),
                Value<int> outs = const Value.absent(),
                Value<String?> scorerUserId = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> firstBaseId = const Value.absent(),
                Value<String?> secondBaseId = const Value.absent(),
                Value<String?> thirdBaseId = const Value.absent(),
                Value<int> currentBatterIndex = const Value.absent(),
                Value<int> theirHalfRuns = const Value.absent(),
                Value<int> ourHalfRuns = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                scoringDraft: scoringDraft,
                settingsSnapshot: settingsSnapshot,
                teamId: teamId,
                kind: kind,
                opponentId: opponentId,
                opponentName: opponentName,
                playedForName: playedForName,
                playedForTeamId: playedForTeamId,
                park: park,
                startsAt: startsAt,
                homeAway: homeAway,
                status: status,
                ourRuns: ourRuns,
                theirRuns: theirRuns,
                currentInning: currentInning,
                currentHalf: currentHalf,
                outs: outs,
                scorerUserId: scorerUserId,
                notes: notes,
                firstBaseId: firstBaseId,
                secondBaseId: secondBaseId,
                thirdBaseId: thirdBaseId,
                currentBatterIndex: currentBatterIndex,
                theirHalfRuns: theirHalfRuns,
                ourHalfRuns: ourHalfRuns,
                scope: scope,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, BaseReferences<_$AppDatabase, $GamesTable, Game>),
      Game,
      PrefetchHooks Function()
    >;
typedef $$GameCompetitionsTableCreateCompanionBuilder =
    GameCompetitionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      required String teamId,
      required String gameId,
      required String competitionId,
      Value<int> rowid,
    });
typedef $$GameCompetitionsTableUpdateCompanionBuilder =
    GameCompetitionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String> teamId,
      Value<String> gameId,
      Value<String> competitionId,
      Value<int> rowid,
    });

class $$GameCompetitionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameCompetitionsTable> {
  $$GameCompetitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get competitionId => $composableBuilder(
    column: $table.competitionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameCompetitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameCompetitionsTable> {
  $$GameCompetitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get competitionId => $composableBuilder(
    column: $table.competitionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameCompetitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameCompetitionsTable> {
  $$GameCompetitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get competitionId => $composableBuilder(
    column: $table.competitionId,
    builder: (column) => column,
  );
}

class $$GameCompetitionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameCompetitionsTable,
          GameCompetition,
          $$GameCompetitionsTableFilterComposer,
          $$GameCompetitionsTableOrderingComposer,
          $$GameCompetitionsTableAnnotationComposer,
          $$GameCompetitionsTableCreateCompanionBuilder,
          $$GameCompetitionsTableUpdateCompanionBuilder,
          (
            GameCompetition,
            BaseReferences<
              _$AppDatabase,
              $GameCompetitionsTable,
              GameCompetition
            >,
          ),
          GameCompetition,
          PrefetchHooks Function()
        > {
  $$GameCompetitionsTableTableManager(
    _$AppDatabase db,
    $GameCompetitionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameCompetitionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameCompetitionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameCompetitionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String> teamId = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> competitionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameCompetitionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                gameId: gameId,
                competitionId: competitionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                required String teamId,
                required String gameId,
                required String competitionId,
                Value<int> rowid = const Value.absent(),
              }) => GameCompetitionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                gameId: gameId,
                competitionId: competitionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameCompetitionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameCompetitionsTable,
      GameCompetition,
      $$GameCompetitionsTableFilterComposer,
      $$GameCompetitionsTableOrderingComposer,
      $$GameCompetitionsTableAnnotationComposer,
      $$GameCompetitionsTableCreateCompanionBuilder,
      $$GameCompetitionsTableUpdateCompanionBuilder,
      (
        GameCompetition,
        BaseReferences<_$AppDatabase, $GameCompetitionsTable, GameCompetition>,
      ),
      GameCompetition,
      PrefetchHooks Function()
    >;
typedef $$LineupSlotsTableCreateCompanionBuilder =
    LineupSlotsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> teamId,
      required String gameId,
      required String playerId,
      required int battingOrder,
      Value<String?> position,
      Value<int> rowid,
    });
typedef $$LineupSlotsTableUpdateCompanionBuilder =
    LineupSlotsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> teamId,
      Value<String> gameId,
      Value<String> playerId,
      Value<int> battingOrder,
      Value<String?> position,
      Value<int> rowid,
    });

class $$LineupSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $LineupSlotsTable> {
  $$LineupSlotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get battingOrder => $composableBuilder(
    column: $table.battingOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LineupSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $LineupSlotsTable> {
  $$LineupSlotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get battingOrder => $composableBuilder(
    column: $table.battingOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LineupSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LineupSlotsTable> {
  $$LineupSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<int> get battingOrder => $composableBuilder(
    column: $table.battingOrder,
    builder: (column) => column,
  );

  GeneratedColumn<String> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$LineupSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LineupSlotsTable,
          LineupSlot,
          $$LineupSlotsTableFilterComposer,
          $$LineupSlotsTableOrderingComposer,
          $$LineupSlotsTableAnnotationComposer,
          $$LineupSlotsTableCreateCompanionBuilder,
          $$LineupSlotsTableUpdateCompanionBuilder,
          (
            LineupSlot,
            BaseReferences<_$AppDatabase, $LineupSlotsTable, LineupSlot>,
          ),
          LineupSlot,
          PrefetchHooks Function()
        > {
  $$LineupSlotsTableTableManager(_$AppDatabase db, $LineupSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineupSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineupSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineupSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<int> battingOrder = const Value.absent(),
                Value<String?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineupSlotsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                gameId: gameId,
                playerId: playerId,
                battingOrder: battingOrder,
                position: position,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                required String gameId,
                required String playerId,
                required int battingOrder,
                Value<String?> position = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LineupSlotsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                gameId: gameId,
                playerId: playerId,
                battingOrder: battingOrder,
                position: position,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LineupSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LineupSlotsTable,
      LineupSlot,
      $$LineupSlotsTableFilterComposer,
      $$LineupSlotsTableOrderingComposer,
      $$LineupSlotsTableAnnotationComposer,
      $$LineupSlotsTableCreateCompanionBuilder,
      $$LineupSlotsTableUpdateCompanionBuilder,
      (
        LineupSlot,
        BaseReferences<_$AppDatabase, $LineupSlotsTable, LineupSlot>,
      ),
      LineupSlot,
      PrefetchHooks Function()
    >;
typedef $$PlateAppearancesTableCreateCompanionBuilder =
    PlateAppearancesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> resolution,
      Value<bool?> batterWasMale,
      Value<String?> effectiveResult,
      Value<String?> teamId,
      required String gameId,
      required String playerId,
      Value<String?> personId,
      required int sequence,
      required int inning,
      required String inningHalf,
      required String result,
      Value<int> rbi,
      Value<int> runsScored,
      Value<int> outsRecorded,
      Value<String?> hitLocation,
      Value<String?> qualityOfContact,
      Value<String?> fielderPlayerId,
      Value<int?> runsOnPlay,
      Value<bool?> batterScored,
      Value<String?> outKind,
      Value<int> rowid,
    });
typedef $$PlateAppearancesTableUpdateCompanionBuilder =
    PlateAppearancesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> resolution,
      Value<bool?> batterWasMale,
      Value<String?> effectiveResult,
      Value<String?> teamId,
      Value<String> gameId,
      Value<String> playerId,
      Value<String?> personId,
      Value<int> sequence,
      Value<int> inning,
      Value<String> inningHalf,
      Value<String> result,
      Value<int> rbi,
      Value<int> runsScored,
      Value<int> outsRecorded,
      Value<String?> hitLocation,
      Value<String?> qualityOfContact,
      Value<String?> fielderPlayerId,
      Value<int?> runsOnPlay,
      Value<bool?> batterScored,
      Value<String?> outKind,
      Value<int> rowid,
    });

class $$PlateAppearancesTableFilterComposer
    extends Composer<_$AppDatabase, $PlateAppearancesTable> {
  $$PlateAppearancesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get batterWasMale => $composableBuilder(
    column: $table.batterWasMale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get effectiveResult => $composableBuilder(
    column: $table.effectiveResult,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inning => $composableBuilder(
    column: $table.inning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get inningHalf => $composableBuilder(
    column: $table.inningHalf,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rbi => $composableBuilder(
    column: $table.rbi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runsScored => $composableBuilder(
    column: $table.runsScored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outsRecorded => $composableBuilder(
    column: $table.outsRecorded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hitLocation => $composableBuilder(
    column: $table.hitLocation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualityOfContact => $composableBuilder(
    column: $table.qualityOfContact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fielderPlayerId => $composableBuilder(
    column: $table.fielderPlayerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runsOnPlay => $composableBuilder(
    column: $table.runsOnPlay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get batterScored => $composableBuilder(
    column: $table.batterScored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get outKind => $composableBuilder(
    column: $table.outKind,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlateAppearancesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlateAppearancesTable> {
  $$PlateAppearancesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get batterWasMale => $composableBuilder(
    column: $table.batterWasMale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get effectiveResult => $composableBuilder(
    column: $table.effectiveResult,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playerId => $composableBuilder(
    column: $table.playerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personId => $composableBuilder(
    column: $table.personId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inning => $composableBuilder(
    column: $table.inning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get inningHalf => $composableBuilder(
    column: $table.inningHalf,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rbi => $composableBuilder(
    column: $table.rbi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runsScored => $composableBuilder(
    column: $table.runsScored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outsRecorded => $composableBuilder(
    column: $table.outsRecorded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hitLocation => $composableBuilder(
    column: $table.hitLocation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualityOfContact => $composableBuilder(
    column: $table.qualityOfContact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fielderPlayerId => $composableBuilder(
    column: $table.fielderPlayerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runsOnPlay => $composableBuilder(
    column: $table.runsOnPlay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get batterScored => $composableBuilder(
    column: $table.batterScored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get outKind => $composableBuilder(
    column: $table.outKind,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlateAppearancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlateAppearancesTable> {
  $$PlateAppearancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get resolution => $composableBuilder(
    column: $table.resolution,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get batterWasMale => $composableBuilder(
    column: $table.batterWasMale,
    builder: (column) => column,
  );

  GeneratedColumn<String> get effectiveResult => $composableBuilder(
    column: $table.effectiveResult,
    builder: (column) => column,
  );

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<String> get playerId =>
      $composableBuilder(column: $table.playerId, builder: (column) => column);

  GeneratedColumn<String> get personId =>
      $composableBuilder(column: $table.personId, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<int> get inning =>
      $composableBuilder(column: $table.inning, builder: (column) => column);

  GeneratedColumn<String> get inningHalf => $composableBuilder(
    column: $table.inningHalf,
    builder: (column) => column,
  );

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<int> get rbi =>
      $composableBuilder(column: $table.rbi, builder: (column) => column);

  GeneratedColumn<int> get runsScored => $composableBuilder(
    column: $table.runsScored,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outsRecorded => $composableBuilder(
    column: $table.outsRecorded,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hitLocation => $composableBuilder(
    column: $table.hitLocation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qualityOfContact => $composableBuilder(
    column: $table.qualityOfContact,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fielderPlayerId => $composableBuilder(
    column: $table.fielderPlayerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get runsOnPlay => $composableBuilder(
    column: $table.runsOnPlay,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get batterScored => $composableBuilder(
    column: $table.batterScored,
    builder: (column) => column,
  );

  GeneratedColumn<String> get outKind =>
      $composableBuilder(column: $table.outKind, builder: (column) => column);
}

class $$PlateAppearancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlateAppearancesTable,
          PlateAppearance,
          $$PlateAppearancesTableFilterComposer,
          $$PlateAppearancesTableOrderingComposer,
          $$PlateAppearancesTableAnnotationComposer,
          $$PlateAppearancesTableCreateCompanionBuilder,
          $$PlateAppearancesTableUpdateCompanionBuilder,
          (
            PlateAppearance,
            BaseReferences<
              _$AppDatabase,
              $PlateAppearancesTable,
              PlateAppearance
            >,
          ),
          PlateAppearance,
          PrefetchHooks Function()
        > {
  $$PlateAppearancesTableTableManager(
    _$AppDatabase db,
    $PlateAppearancesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlateAppearancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlateAppearancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlateAppearancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<bool?> batterWasMale = const Value.absent(),
                Value<String?> effectiveResult = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> playerId = const Value.absent(),
                Value<String?> personId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<int> inning = const Value.absent(),
                Value<String> inningHalf = const Value.absent(),
                Value<String> result = const Value.absent(),
                Value<int> rbi = const Value.absent(),
                Value<int> runsScored = const Value.absent(),
                Value<int> outsRecorded = const Value.absent(),
                Value<String?> hitLocation = const Value.absent(),
                Value<String?> qualityOfContact = const Value.absent(),
                Value<String?> fielderPlayerId = const Value.absent(),
                Value<int?> runsOnPlay = const Value.absent(),
                Value<bool?> batterScored = const Value.absent(),
                Value<String?> outKind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlateAppearancesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                resolution: resolution,
                batterWasMale: batterWasMale,
                effectiveResult: effectiveResult,
                teamId: teamId,
                gameId: gameId,
                playerId: playerId,
                personId: personId,
                sequence: sequence,
                inning: inning,
                inningHalf: inningHalf,
                result: result,
                rbi: rbi,
                runsScored: runsScored,
                outsRecorded: outsRecorded,
                hitLocation: hitLocation,
                qualityOfContact: qualityOfContact,
                fielderPlayerId: fielderPlayerId,
                runsOnPlay: runsOnPlay,
                batterScored: batterScored,
                outKind: outKind,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> resolution = const Value.absent(),
                Value<bool?> batterWasMale = const Value.absent(),
                Value<String?> effectiveResult = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                required String gameId,
                required String playerId,
                Value<String?> personId = const Value.absent(),
                required int sequence,
                required int inning,
                required String inningHalf,
                required String result,
                Value<int> rbi = const Value.absent(),
                Value<int> runsScored = const Value.absent(),
                Value<int> outsRecorded = const Value.absent(),
                Value<String?> hitLocation = const Value.absent(),
                Value<String?> qualityOfContact = const Value.absent(),
                Value<String?> fielderPlayerId = const Value.absent(),
                Value<int?> runsOnPlay = const Value.absent(),
                Value<bool?> batterScored = const Value.absent(),
                Value<String?> outKind = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlateAppearancesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                resolution: resolution,
                batterWasMale: batterWasMale,
                effectiveResult: effectiveResult,
                teamId: teamId,
                gameId: gameId,
                playerId: playerId,
                personId: personId,
                sequence: sequence,
                inning: inning,
                inningHalf: inningHalf,
                result: result,
                rbi: rbi,
                runsScored: runsScored,
                outsRecorded: outsRecorded,
                hitLocation: hitLocation,
                qualityOfContact: qualityOfContact,
                fielderPlayerId: fielderPlayerId,
                runsOnPlay: runsOnPlay,
                batterScored: batterScored,
                outKind: outKind,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlateAppearancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlateAppearancesTable,
      PlateAppearance,
      $$PlateAppearancesTableFilterComposer,
      $$PlateAppearancesTableOrderingComposer,
      $$PlateAppearancesTableAnnotationComposer,
      $$PlateAppearancesTableCreateCompanionBuilder,
      $$PlateAppearancesTableUpdateCompanionBuilder,
      (
        PlateAppearance,
        BaseReferences<_$AppDatabase, $PlateAppearancesTable, PlateAppearance>,
      ),
      PlateAppearance,
      PrefetchHooks Function()
    >;
typedef $$GameEventsTableCreateCompanionBuilder =
    GameEventsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> payload,
      Value<String?> teamId,
      required String gameId,
      required int sequence,
      required String kind,
      Value<int> runs,
      Value<int> rowid,
    });
typedef $$GameEventsTableUpdateCompanionBuilder =
    GameEventsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> payload,
      Value<String?> teamId,
      Value<String> gameId,
      Value<int> sequence,
      Value<String> kind,
      Value<int> runs,
      Value<int> rowid,
    });

class $$GameEventsTableFilterComposer
    extends Composer<_$AppDatabase, $GameEventsTable> {
  $$GameEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get runs => $composableBuilder(
    column: $table.runs,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameEventsTable> {
  $$GameEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get runs => $composableBuilder(
    column: $table.runs,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameEventsTable> {
  $$GameEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get runs =>
      $composableBuilder(column: $table.runs, builder: (column) => column);
}

class $$GameEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameEventsTable,
          GameEvent,
          $$GameEventsTableFilterComposer,
          $$GameEventsTableOrderingComposer,
          $$GameEventsTableAnnotationComposer,
          $$GameEventsTableCreateCompanionBuilder,
          $$GameEventsTableUpdateCompanionBuilder,
          (
            GameEvent,
            BaseReferences<_$AppDatabase, $GameEventsTable, GameEvent>,
          ),
          GameEvent,
          PrefetchHooks Function()
        > {
  $$GameEventsTableTableManager(_$AppDatabase db, $GameEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<int> sequence = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int> runs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameEventsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                payload: payload,
                teamId: teamId,
                gameId: gameId,
                sequence: sequence,
                kind: kind,
                runs: runs,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                required String gameId,
                required int sequence,
                required String kind,
                Value<int> runs = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameEventsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                payload: payload,
                teamId: teamId,
                gameId: gameId,
                sequence: sequence,
                kind: kind,
                runs: runs,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameEventsTable,
      GameEvent,
      $$GameEventsTableFilterComposer,
      $$GameEventsTableOrderingComposer,
      $$GameEventsTableAnnotationComposer,
      $$GameEventsTableCreateCompanionBuilder,
      $$GameEventsTableUpdateCompanionBuilder,
      (GameEvent, BaseReferences<_$AppDatabase, $GameEventsTable, GameEvent>),
      GameEvent,
      PrefetchHooks Function()
    >;
typedef $$GameInningsTableCreateCompanionBuilder =
    GameInningsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> teamId,
      required String gameId,
      required int inning,
      Value<int> ourRuns,
      Value<int> theirRuns,
      Value<int> rowid,
    });
typedef $$GameInningsTableUpdateCompanionBuilder =
    GameInningsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> syncState,
      Value<String?> teamId,
      Value<String> gameId,
      Value<int> inning,
      Value<int> ourRuns,
      Value<int> theirRuns,
      Value<int> rowid,
    });

class $$GameInningsTableFilterComposer
    extends Composer<_$AppDatabase, $GameInningsTable> {
  $$GameInningsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inning => $composableBuilder(
    column: $table.inning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ourRuns => $composableBuilder(
    column: $table.ourRuns,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get theirRuns => $composableBuilder(
    column: $table.theirRuns,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameInningsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameInningsTable> {
  $$GameInningsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get syncState => $composableBuilder(
    column: $table.syncState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teamId => $composableBuilder(
    column: $table.teamId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameId => $composableBuilder(
    column: $table.gameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inning => $composableBuilder(
    column: $table.inning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ourRuns => $composableBuilder(
    column: $table.ourRuns,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get theirRuns => $composableBuilder(
    column: $table.theirRuns,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameInningsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameInningsTable> {
  $$GameInningsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get syncState =>
      $composableBuilder(column: $table.syncState, builder: (column) => column);

  GeneratedColumn<String> get teamId =>
      $composableBuilder(column: $table.teamId, builder: (column) => column);

  GeneratedColumn<String> get gameId =>
      $composableBuilder(column: $table.gameId, builder: (column) => column);

  GeneratedColumn<int> get inning =>
      $composableBuilder(column: $table.inning, builder: (column) => column);

  GeneratedColumn<int> get ourRuns =>
      $composableBuilder(column: $table.ourRuns, builder: (column) => column);

  GeneratedColumn<int> get theirRuns =>
      $composableBuilder(column: $table.theirRuns, builder: (column) => column);
}

class $$GameInningsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameInningsTable,
          GameInning,
          $$GameInningsTableFilterComposer,
          $$GameInningsTableOrderingComposer,
          $$GameInningsTableAnnotationComposer,
          $$GameInningsTableCreateCompanionBuilder,
          $$GameInningsTableUpdateCompanionBuilder,
          (
            GameInning,
            BaseReferences<_$AppDatabase, $GameInningsTable, GameInning>,
          ),
          GameInning,
          PrefetchHooks Function()
        > {
  $$GameInningsTableTableManager(_$AppDatabase db, $GameInningsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameInningsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameInningsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameInningsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<int> inning = const Value.absent(),
                Value<int> ourRuns = const Value.absent(),
                Value<int> theirRuns = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameInningsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                gameId: gameId,
                inning: inning,
                ourRuns: ourRuns,
                theirRuns: theirRuns,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> syncState = const Value.absent(),
                Value<String?> teamId = const Value.absent(),
                required String gameId,
                required int inning,
                Value<int> ourRuns = const Value.absent(),
                Value<int> theirRuns = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameInningsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                syncState: syncState,
                teamId: teamId,
                gameId: gameId,
                inning: inning,
                ourRuns: ourRuns,
                theirRuns: theirRuns,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameInningsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameInningsTable,
      GameInning,
      $$GameInningsTableFilterComposer,
      $$GameInningsTableOrderingComposer,
      $$GameInningsTableAnnotationComposer,
      $$GameInningsTableCreateCompanionBuilder,
      $$GameInningsTableUpdateCompanionBuilder,
      (
        GameInning,
        BaseReferences<_$AppDatabase, $GameInningsTable, GameInning>,
      ),
      GameInning,
      PrefetchHooks Function()
    >;
typedef $$LocalSyncCursorsTableCreateCompanionBuilder =
    LocalSyncCursorsCompanion Function({
      required String cursorTable,
      required DateTime cursor,
      Value<int> rowid,
    });
typedef $$LocalSyncCursorsTableUpdateCompanionBuilder =
    LocalSyncCursorsCompanion Function({
      Value<String> cursorTable,
      Value<DateTime> cursor,
      Value<int> rowid,
    });

class $$LocalSyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $LocalSyncCursorsTable> {
  $$LocalSyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cursorTable => $composableBuilder(
    column: $table.cursorTable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalSyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocalSyncCursorsTable> {
  $$LocalSyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cursorTable => $composableBuilder(
    column: $table.cursorTable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cursor => $composableBuilder(
    column: $table.cursor,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalSyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocalSyncCursorsTable> {
  $$LocalSyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cursorTable => $composableBuilder(
    column: $table.cursorTable,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cursor =>
      $composableBuilder(column: $table.cursor, builder: (column) => column);
}

class $$LocalSyncCursorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocalSyncCursorsTable,
          LocalSyncCursor,
          $$LocalSyncCursorsTableFilterComposer,
          $$LocalSyncCursorsTableOrderingComposer,
          $$LocalSyncCursorsTableAnnotationComposer,
          $$LocalSyncCursorsTableCreateCompanionBuilder,
          $$LocalSyncCursorsTableUpdateCompanionBuilder,
          (
            LocalSyncCursor,
            BaseReferences<
              _$AppDatabase,
              $LocalSyncCursorsTable,
              LocalSyncCursor
            >,
          ),
          LocalSyncCursor,
          PrefetchHooks Function()
        > {
  $$LocalSyncCursorsTableTableManager(
    _$AppDatabase db,
    $LocalSyncCursorsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalSyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalSyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalSyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> cursorTable = const Value.absent(),
                Value<DateTime> cursor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncCursorsCompanion(
                cursorTable: cursorTable,
                cursor: cursor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String cursorTable,
                required DateTime cursor,
                Value<int> rowid = const Value.absent(),
              }) => LocalSyncCursorsCompanion.insert(
                cursorTable: cursorTable,
                cursor: cursor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalSyncCursorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocalSyncCursorsTable,
      LocalSyncCursor,
      $$LocalSyncCursorsTableFilterComposer,
      $$LocalSyncCursorsTableOrderingComposer,
      $$LocalSyncCursorsTableAnnotationComposer,
      $$LocalSyncCursorsTableCreateCompanionBuilder,
      $$LocalSyncCursorsTableUpdateCompanionBuilder,
      (
        LocalSyncCursor,
        BaseReferences<_$AppDatabase, $LocalSyncCursorsTable, LocalSyncCursor>,
      ),
      LocalSyncCursor,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PeopleTableTableManager get people =>
      $$PeopleTableTableManager(_db, _db.people);
  $$PersonalTeamsTableTableManager get personalTeams =>
      $$PersonalTeamsTableTableManager(_db, _db.personalTeams);
  $$TeamsTableTableManager get teams =>
      $$TeamsTableTableManager(_db, _db.teams);
  $$TeamMembersTableTableManager get teamMembers =>
      $$TeamMembersTableTableManager(_db, _db.teamMembers);
  $$InviteCodesTableTableManager get inviteCodes =>
      $$InviteCodesTableTableManager(_db, _db.inviteCodes);
  $$PlayersTableTableManager get players =>
      $$PlayersTableTableManager(_db, _db.players);
  $$OpponentsTableTableManager get opponents =>
      $$OpponentsTableTableManager(_db, _db.opponents);
  $$CompetitionsTableTableManager get competitions =>
      $$CompetitionsTableTableManager(_db, _db.competitions);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$GameCompetitionsTableTableManager get gameCompetitions =>
      $$GameCompetitionsTableTableManager(_db, _db.gameCompetitions);
  $$LineupSlotsTableTableManager get lineupSlots =>
      $$LineupSlotsTableTableManager(_db, _db.lineupSlots);
  $$PlateAppearancesTableTableManager get plateAppearances =>
      $$PlateAppearancesTableTableManager(_db, _db.plateAppearances);
  $$GameEventsTableTableManager get gameEvents =>
      $$GameEventsTableTableManager(_db, _db.gameEvents);
  $$GameInningsTableTableManager get gameInnings =>
      $$GameInningsTableTableManager(_db, _db.gameInnings);
  $$LocalSyncCursorsTableTableManager get localSyncCursors =>
      $$LocalSyncCursorsTableTableManager(_db, _db.localSyncCursors);
}
