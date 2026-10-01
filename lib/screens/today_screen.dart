import 'package:flutter/material.dart';

import '../data/memories_repository.dart';
import '../models/memory.dart';
import '../models/memory_folder.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_button.dart';
import '../widgets/app_search_field.dart';
import '../widgets/avatar_stack.dart';
import '../widgets/collection_folder_tile.dart';
import '../widgets/memory_card.dart';
import '../widgets/memory_thumbnail.dart';
import 'folder_detail_screen.dart';
import 'memory_preview_screen.dart';
import 'on_this_day_expanded_screen.dart';

/// Screen 2 of 6 — the Today / "On This Day" tab. Loads the signed-in
/// couple's real folders and memories from Supabase (MemoriesRepository),
/// and shows an empty-state prompt for each section instead of sample
/// data when nothing's been saved yet.
class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  bool _isLoading = true;
  String? _loadError;
  List<MemoryFolder> _folders = [];
  List<Memory> _memories = [];
  String _searchQuery = '';

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  List<Memory> get _searchResults {
    final query = _searchQuery.trim().toLowerCase();
    return _memories.where((m) {
      if (m.title.toLowerCase().contains(query)) return true;
      // Also matches on the date — a full month name ("october"), just
      // the day, or just the year, so "2023" or "oct" both work.
      final month = _monthNames[m.date.month - 1].toLowerCase();
      final dateText = '$month ${m.date.day} ${m.date.year}';
      return dateText.contains(query);
    }).toList();
  }

  /// Memories taken on today's month+day in a past year — the actual
  /// "On This Day" set, the same idea as Google Photos' memories feature.
  /// Most recent year first.
  List<Memory> get _onThisDayMemories {
    final now = DateTime.now();
    final matches = _memories
        .where((m) => m.date.month == now.month && m.date.day == now.day)
        .toList();
    matches.sort((a, b) => b.date.compareTo(a.date));
    return matches;
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _loadError = null;
    });
    try {
      await MemoriesRepository.getOrCreateCoupleId();
      final folders = await MemoriesRepository.fetchFolders();
      final memories = await MemoriesRepository.fetchMemories();
      if (!mounted) return;
      setState(() {
        _folders = folders;
        _memories = memories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadError = 'Couldn\'t load your memories.';
      });
    }
  }

  /// Shared by the on-this-day cards and search results — both show
  /// memories out of the same _memories list, so both just need to
  /// update that one list; _onThisDayMemories/_searchResults recompute
  /// from it automatically since they're getters, not cached fields.
  void _toggleMemoryFavorite(Memory memory) {
    final updated = memory.copyWith(isFavorite: !memory.isFavorite);
    setState(() {
      _memories = [for (final m in _memories) m.id == memory.id ? updated : m];
    });
    MemoriesRepository.setFavorite(memoryId: memory.id, isFavorite: updated.isFavorite);
  }

  void _removeMemory(Memory memory) {
    setState(() => _memories = _memories.where((m) => m.id != memory.id).toList());
  }

  Future<void> _createFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Folder'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Folder name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    try {
      final coupleId = await MemoriesRepository.getOrCreateCoupleId();
      final folder = await MemoriesRepository.createFolder(coupleId: coupleId, title: name);
      if (!mounted) return;
      setState(() => _folders = [..._folders, folder]);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Couldn\'t create that folder.')),
      );
    }
  }

  Widget _emptyStateCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? action,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderPink),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: AppColors.textMuted),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: textTheme.bodyMedium, textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(subtitle, style: textTheme.labelSmall, textAlign: TextAlign.center),
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action,
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppSearchField(
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                AvatarStack(
                  avatarLabels: const ['J', 'A'],
                  onFavoriteTap: () {},
                ),
              ],
            ),
            if (_loadError != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(_loadError!, style: textTheme.bodySmall?.copyWith(color: AppColors.error)),
            ],
            const SizedBox(height: AppSpacing.lg),
            if (_searchQuery.trim().isNotEmpty)
              _buildSearchResults(textTheme)
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('On this day!', style: textTheme.headlineLarge),
                  if (_onThisDayMemories.length > 1)
                    TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const OnThisDayExpandedScreen()),
                      ),
                      child: const Text('See all'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              if (_onThisDayMemories.isEmpty)
                _emptyStateCard(
                  icon: Icons.photo_outlined,
                  title: 'No memories from this day yet',
                  subtitle: 'Add one today, and it\'ll show up here next year.',
                )
              else if (_onThisDayMemories.length == 1)
                _OnThisDayCard(
                  memory: _onThisDayMemories.first,
                  onFavoriteTap: () => _toggleMemoryFavorite(_onThisDayMemories.first),
                  onDeleted: () => _removeMemory(_onThisDayMemories.first),
                )
              else
                SizedBox(
                  height: 260,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _onThisDayMemories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final memory = _onThisDayMemories[index];
                      return SizedBox(
                        width: 260,
                        child: _OnThisDayCard(
                          memory: memory,
                          onFavoriteTap: () => _toggleMemoryFavorite(memory),
                          onDeleted: () => _removeMemory(memory),
                        ),
                      );
                    },
                  ),
                ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Memory Collections', style: textTheme.headlineSmall),
                  IconButton(
                    onPressed: _createFolder,
                    icon: const Icon(Icons.add_circle_outline),
                    tooltip: 'Add a folder',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              if (_folders.isEmpty)
                _emptyStateCard(
                  icon: Icons.folder_open_outlined,
                  title: 'No folders yet',
                  subtitle: 'Press the button below to add your first folder.',
                  action: AppButton(
                    label: 'Add a Folder',
                    style: AppButtonStyle.secondary,
                    onPressed: _createFolder,
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final folder in _folders) ...[
                        CollectionFolderTile(
                          title: folder.title,
                          itemCount: _memories.where((m) => m.folderId == folder.id).length,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => FolderDetailScreen(folder: folder)),
                          ).then((changed) {
                            if (changed == true) _load();
                          }),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                      ],
                    ],
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(TextTheme textTheme) {
    final results = _searchResults;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Search results', style: textTheme.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        if (results.isEmpty)
          _emptyStateCard(
            icon: Icons.search_off,
            title: 'No memories match "${_searchQuery.trim()}"',
            subtitle: 'Try a different title, or clear the search to see everything.',
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisSpacing: AppSpacing.sm,
            ),
            itemBuilder: (context, index) {
              final memory = results[index];
              return MemoryThumbnail(
                memory: memory,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MemoryPreviewScreen(
                      memory: memory,
                      onFavoriteToggled: () => _toggleMemoryFavorite(memory),
                      onDeleted: () => _removeMemory(memory),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class _OnThisDayCard extends StatelessWidget {
  const _OnThisDayCard({
    required this.memory,
    required this.onFavoriteTap,
    required this.onDeleted,
  });

  final Memory memory;
  final VoidCallback onFavoriteTap;
  final VoidCallback onDeleted;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MemoryPreviewScreen(
            memory: memory,
            onFavoriteToggled: onFavoriteTap,
            onDeleted: onDeleted,
          ),
        ),
      ),
      child: MemoryCard(memory: memory, onFavoriteTap: onFavoriteTap),
    );
  }
}
