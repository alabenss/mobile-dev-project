// lib/data/repo/activities_repo.dart

class ActivityItem {
  final String id;
  final String title;
  final String subtitle;
  final String asset;

  const ActivityItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.asset,
  });
}

/// Abstract repo (pattern from lectures)
abstract class AbstractActivitiesRepo {
  Future<List<ActivityItem>> getActivities();

  static AbstractActivitiesRepo? _instance;
  static AbstractActivitiesRepo getInstance() {
    _instance ??= ActivitiesRepoDummy();
    return _instance!;
  }
}

/// Dummy implementation (no DB, just static data)
class ActivitiesRepoDummy implements AbstractActivitiesRepo {
  @override
  Future<List<ActivityItem>> getActivities() async {
    // You can later load this from JSON/API/DB if needed
    return const [
      ActivityItem(
        id: 'breathing',
        title: 'Breathing',
        subtitle: 'Calm your mind with\ndeep breaths',
        asset: 'assets/images/breathing.png',
      ),
      ActivityItem(
        id: 'bubble_popper',
        title: 'Bubble Popper',
        subtitle: 'Find joy and calm in\nevery pop',
        asset: 'assets/images/popup.png',
      ),
      ActivityItem(
        id: 'painting',
        title: 'Painting',
        subtitle: 'Express your feelings\nthrough painting',
        asset: 'assets/images/painting.png',
      ),
      ActivityItem(
        id: 'puzzle',
        title: 'Puzzle',
        subtitle: 'Focus and have fun\nsolving puzzles',
        asset: 'assets/images/puzzle.png',
      ),
      ActivityItem(
        id: 'grow_plant',
        title: 'Grow the plant',
        subtitle: 'Watch your own little\nplant thrive',
        asset: 'assets/images/planting.png',
      ),
      ActivityItem(
        id: 'coloring',
        title: 'Coloring',
        subtitle: 'Relax with mindful\ncoloring',
        asset: 'assets/images/coloring.png',
      ),
    ];
  }
}
