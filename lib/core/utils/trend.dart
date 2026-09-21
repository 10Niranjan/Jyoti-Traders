/// Percentage change from [previous] to [current], or null when there is no
/// baseline to compare against (a percentage of zero is meaningless, and
/// showing "+∞%" on a quiet day is noise).
double? trendPercent(num current, num previous) =>
    previous <= 0 ? null : (current - previous) / previous * 100;
