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
/// - [NavigationHelper]: Central utility for platform-aware navigation
/// - [RouteBuilder]: Consistent URL construction utilities
/// - [PlatformDetector]: Reliable platform detection
/// - [RouteValidator]: Route parameter validation
/// - [FallbackNavigator]: Error handling and fallback navigation

export 'helpers/context_aware_back_navigation.dart';
export 'helpers/context_aware_navigator.dart';
export 'helpers/fallback_navigator.dart';
export 'helpers/navigation_context_helper.dart';
export 'helpers/navigation_helper.dart';
export 'helpers/platform_detector.dart';
export 'helpers/route_builder.dart';
export 'helpers/route_validator.dart';
// Export all navigation utilities
export 'models/navigation_context.dart';
export 'models/navigation_context_type.dart';
export 'models/navigation_method.dart';
