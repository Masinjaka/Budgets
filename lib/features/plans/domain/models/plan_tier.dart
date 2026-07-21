enum PlanTier {
  free,
  plus;

  String get title => switch (this) {
        PlanTier.free => 'Free',
        PlanTier.plus => 'Drala Plus',
      };
}
