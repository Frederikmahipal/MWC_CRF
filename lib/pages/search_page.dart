import 'package:flutter/cupertino.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Search Restaurants'),
        backgroundColor: CupertinoColors.systemBackground,
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Search bar
            Container(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search restaurants or cuisines...',
                onChanged: (value) {
                  // Handle search
                },
              ),
            ),
            
            // Filter chips
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  'All',
                  'Open Now',
                  'Outdoor Seating',
                  'Wheelchair Accessible',
                  'Italian',
                  'Asian',
                  'Danish',
                ].map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: CupertinoButton(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      color: isSelected 
                          ? CupertinoColors.systemBlue 
                          : CupertinoColors.systemGrey5,
                      borderRadius: BorderRadius.circular(20),
                      onPressed: () {
                        setState(() {
                          _selectedFilter = filter;
                        });
                      },
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: isSelected 
                              ? CupertinoColors.white 
                              : CupertinoColors.label,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            
            // Search results
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: 15, // Placeholder count
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: CupertinoColors.systemBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: CupertinoColors.systemGrey.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: CupertinoListTile(
                      title: Text('Restaurant ${index + 1}'),
                      subtitle: const Text('Cuisine • Rating • Distance'),
                      trailing: const Icon(CupertinoIcons.chevron_right),
                      onTap: () {
                        // Navigate to restaurant details
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
