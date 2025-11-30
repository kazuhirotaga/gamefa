import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:real_quest/screens/home_screen.dart';
import 'package:real_quest/screens/battle_screen.dart';
import 'package:real_quest/screens/collection_screen.dart';
import 'package:real_quest/screens/checkin_screen.dart';
import 'package:real_quest/screens/quest_screen.dart';
import 'package:real_quest/screens/inventory_screen.dart';
import 'package:real_quest/screens/scaffold_with_navbar.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return ScaffoldWithNavBar(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/battle',
            builder: (context, state) => const BattleScreen(),
          ),
          GoRoute(
            path: '/collection',
            builder: (context, state) => const CollectionScreen(),
          ),
          GoRoute(
            path: '/checkin',
            builder: (context, state) => const CheckinScreen(),
          ),
          GoRoute(
            path: '/quest',
            builder: (context, state) => const QuestScreen(),
          ),
          GoRoute(
            path: '/inventory',
            builder: (context, state) => const InventoryScreen(),
          ),
        ],
      ),
    ],
  );
});
