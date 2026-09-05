enum YouFilterKind { all, personal, team }

class YouFilter {
  const YouFilter.all() : kind = YouFilterKind.all, teamId = null;
  const YouFilter.personal() : kind = YouFilterKind.personal, teamId = null;
  const YouFilter.team(this.teamId) : kind = YouFilterKind.team;

  final YouFilterKind kind;
  final String? teamId;

  @override
  bool operator ==(Object other) {
    return other is YouFilter && other.kind == kind && other.teamId == teamId;
  }

  @override
  int get hashCode => Object.hash(kind, teamId);
}
