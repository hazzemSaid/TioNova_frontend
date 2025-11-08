# GoRouter Navigation Error Fix

## Problem
Getting `GoError (GoError: There is nothing to pop)` when trying to go back from certain routes.

## Root Cause
The error occurs when using `context.pop()` on a route that has no previous route in the navigation stack. This happens when:

1. **Using `context.go()`**: This replaces the entire navigation stack
2. **Initial routes**: Routes that are the first in the app (like splash → theme-selection)
3. **Redirect logic**: When routes are replaced by redirect logic in GoRouter

## Solution Implemented

### 1. Created Safe Navigation Extension
Created `lib/core/utils/safe_navigation.dart` with helper methods:

```dart
// Safely pop or fallback to a route
context.safePop(fallback: '/auth');

// Check and pop, returns false if couldn't pop
context.maybePop();

// Pop or navigate to a specific route
context.popOrGo('/home');
```

### 2. Fixed Theme Selection Screen
Updated the back button to use safe navigation:
```dart
onPressed: () {
  context.safePop(fallback: '/auth');
}
```

## GoRouter Navigation Methods - When to Use What

### `context.go(route)` - **Replaces** entire stack
- ✅ Use for: Main navigation changes (login → home, logout → auth)
- ✅ Use for: Initial app navigation (splash → theme-selection)
- ❌ Don't use: When you want a back button to work
- **Example**: `context.go('/home')` - User can't go back

### `context.push(route)` - **Adds** to stack
- ✅ Use for: Detail screens, modals, sub-pages
- ✅ Use for: When you want back button to work
- ✅ Use for: Temporary navigation (viewing history, details)
- **Example**: `context.push('/quiz-history/123')` - User can go back

### `context.pop()` - **Removes** current route
- ✅ Use for: Back buttons on pushed routes
- ❌ Don't use: Without checking if you can pop
- **Better**: Use `context.safePop()` or check `context.canPop()` first

### `context.replace(route)` - **Replaces** current route only
- ✅ Use for: Replacing current screen without changing stack depth
- ✅ Use for: Flow navigation (step 1 → step 2 → step 3)
- **Example**: Registration flow, onboarding steps

## Best Practices

### 1. Always Check Before Popping
```dart
// ❌ BAD - Can cause error
onPressed: () => context.pop()

// ✅ GOOD - Check first
onPressed: () {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/fallback');
  }
}

// ✅ BETTER - Use safe navigation
onPressed: () => context.safePop(fallback: '/fallback')
```

### 2. Use Correct Navigation Method
```dart
// For main navigation (no back button needed)
context.go('/home');

// For sub-pages (back button should work)
context.push('/details');

// For replacing flow steps
context.replace('/next-step');
```

### 3. Handle Back Button in Routes
When defining routes that might be initial routes, consider:

```dart
// Option 1: Hide back button if can't pop
leading: context.canPop() 
  ? IconButton(icon: Icon(Icons.arrow_back), onPressed: () => context.pop())
  : null,

// Option 2: Use safe navigation
leading: IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () => context.safePop(fallback: '/home'),
),

// Option 3: Custom action if can't pop
leading: IconButton(
  icon: Icon(Icons.arrow_back),
  onPressed: () {
    if (context.canPop()) {
      context.pop();
    } else {
      // Show dialog or navigate to default route
      context.go('/home');
    }
  },
),
```

## Common Scenarios in TioNova

### Splash → Theme Selection → Onboarding → Auth
```dart
// In SplashScreen - Initial navigation (replace)
context.go('/theme-selection');

// In ThemeSelectionScreen - Move forward (replace)
context.go('/onboarding');
// Back button - safe pop
context.safePop(fallback: '/auth');

// In OnboardingScreen - Complete flow (replace)
context.go('/auth');
```

### Home → Folder → Chapter → Quiz
```dart
// From Home - View folder (push - can go back)
context.push('/folder/123', extra: {...});

// From Folder - View chapter (push - can go back)
context.push('/chapter/456', extra: {...});

// From Chapter - Start quiz (push - can go back)
context.push('/quiz/456', extra: {...});

// Back button in any of these - simple pop works
context.pop();
```

### Auth Flow
```dart
// Login success - go to home (replace entire stack)
context.go('/');

// Logout - go to auth (replace entire stack)
context.go('/auth');

// Within auth screens (login → register)
context.push('/auth/register'); // Can go back
```

## Files Updated

1. **lib/core/utils/safe_navigation.dart** - Created safe navigation extension
2. **lib/features/start/presentation/view/screens/theme_selection_screen.dart** - Fixed back button

## Testing Checklist

- [ ] Navigate from splash → theme selection → press back (should go to auth)
- [ ] Navigate to quiz history and press back (should go to chapter)
- [ ] Use back button in any detail screen (should work)
- [ ] Login and press back (should not go back to login)
- [ ] Logout and press back (should not go back to home)

## Future Recommendations

1. **Audit all `context.pop()` calls**: Replace with `context.safePop()` where appropriate
2. **Review navigation patterns**: Ensure `go` vs `push` is used correctly
3. **Add navigation tests**: Test navigation flows in integration tests
4. **Document route behavior**: Add comments in app_router.dart about expected navigation behavior

## Quick Reference

| Action | Method | Stack Behavior | Use When |
|--------|--------|----------------|----------|
| Replace all | `context.go()` | Clears stack | Main navigation |
| Add to stack | `context.push()` | Adds route | Sub-pages |
| Remove current | `context.pop()` | Removes top | Back navigation |
| Replace current | `context.replace()` | Swaps top | Flow steps |
| Safe pop | `context.safePop()` | Pops or fallback | Uncertain stack |

---

**Remember**: When in doubt, use `context.push()` for navigation and `context.safePop()` for going back!
