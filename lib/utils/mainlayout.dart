// Main Layout with Bottom Navigation
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tionova/core/get_it/services_locator.dart';
import 'package:tionova/features/folder/presentation/bloc/folder/folder_cubit.dart';
import 'package:tionova/features/folder/presentation/view/screens/folder_screen.dart';
import 'package:tionova/features/home/presentation/view/screens/home_screen.dart';
import 'package:tionova/features/home/presentation/view/widgets/CustomHeaderDelegate.dart';
import 'package:tionova/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:tionova/utils/widgets/BottomNavItem.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // Lazy loaded screens
  final List<Widget?> _screens = List.filled(4, null);

  // Get screen by index - creates the widget only when needed
  Widget _getScreen(int index) {
    if (_screens[index] == null) {
      switch (index) {
        case 0:
          _screens[index] = const HomeScreen();
          break;
        case 1:
          _screens[index] = BlocProvider(
            create: (context) => getIt<FolderCubit>(),
            child: const FolderScreen(),
          );
          break;
        case 2:
          _screens[index] = const ChallengesScreen();
          break;
        case 3:
          _screens[index] = const ProfileScreen();
          break;
      }
    }
    return _screens[index]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: IndexedStack(
        index: _currentIndex,
        sizing: StackFit.expand,
        children: List.generate(
          _screens.length,
          (index) => _currentIndex == index || _screens[index] != null
              ? _getScreen(index)
              : Container(), // Empty container for screens not yet loaded
        ),
      ),
      bottomNavigationBar: _customBottomNavigationBar(context),
    );
  }

  Widget _customBottomNavigationBar(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.08, // More compact height
      decoration: const BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Color(0xFF1C1C1E), width: 0.5)),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.01,
          ),
          child: Material(
            // Add Material widget for better ripple effects
            color: Colors.transparent,
            child: FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  BottomNavItem(
                    icon: Icons.home,
                    label: "Home",
                    index: 0,
                    currentIndex: _currentIndex,
                    onTap: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.folder_outlined,
                    label: "Folders",
                    index: 1,
                    currentIndex: _currentIndex,
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.emoji_events_outlined,
                    label: "Challenges",
                    index: 2,
                    currentIndex: _currentIndex,
                    onTap: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                  ),
                  BottomNavItem(
                    icon: Icons.person_outline,
                    label: "Profile",
                    index: 3,
                    currentIndex: _currentIndex,
                    onTap: () {
                      setState(() {
                        _currentIndex = 3;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
