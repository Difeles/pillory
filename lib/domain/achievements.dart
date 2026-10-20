/// Badges shown on the profile.
enum AppBadge {
  firstWeek('Первая неделя', '7 дней подряд без пропусков'),
  cabinetKeeper('Хозяин аптечки', '3 лекарства в аптечке'),
  noExpired('Без просрочки', 'Аптечка без просроченных');

  const AppBadge(this.title, this.hint);
  final String title;
  final String hint;
}

/// The badges earned from the current [streak], the number of cabinet
/// medicines and the number with an expired package.
Set<AppBadge> earnedBadges({
  required int streak,
  required int medicines,
  required int expired,
}) => {
  if (streak >= 7) AppBadge.firstWeek,
  if (medicines >= 3) AppBadge.cabinetKeeper,
  if (medicines > 0 && expired == 0) AppBadge.noExpired,
};
