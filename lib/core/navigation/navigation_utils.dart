/// Navigation utilities for context-aware navigation in TioNova
///
/// This library provides utilities for preserving navigation context
/// when navigating between chapter detail screens and their sub-screens.
///
/// Key classes:
/// - [NavigationContext]: Represents the current navigation context
/// - [NavigationContextHelper]: Detects navigation context from current route
/// - [ContextAwareNavigator]: Navigates while preserving context
/// - [ContextAwareBackNavigation]: Handles context-aware back navigation

library navigation_utils;

// Export all navigation utilities
export 'models/navigation_context.dart';
export 'models/navigation_context_type.dart';
export 'helpers/navigation_context_helper.dart';
export 'helpers/context_aware_navigator.dart';
export 'helpers/context_aware_back_navigation.dart';
