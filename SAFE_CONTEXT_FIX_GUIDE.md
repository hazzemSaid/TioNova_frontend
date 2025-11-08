# Fix: "Looking up a deactivated widget's ancestor is unsafe" Error

## Problem Explanation

This error occurs when you try to access `BuildContext` after a widget has been disposed or is being disposed. This commonly happens in these scenarios:

1. **After async operations** (Future.delayed, API calls, etc.)
2. **In callbacks** (Timer, Stream listeners, etc.)
3. **After navigation** (using context after Navigator.pop)
4. **In dispose() method** (accessing inherited widgets)

## Root Causes

### ❌ Common Anti-patterns:

```dart
// BAD: Using context after Future.delayed without proper checks
Future.delayed(Duration(seconds: 1), () {
  Navigator.of(context).pop(); // Widget might be disposed!
  context.read<MyCubit>().doSomething(); // UNSAFE!
});

// BAD: Using context after async operation
Future<void> loadData() async {
  await fetchFromApi();
  context.read<MyCubit>().updateData(); // Widget might be disposed!
}

// BAD: Checking mounted but still using context unsafely
if (mounted) {
  Future.delayed(Duration(seconds: 1), () {
    Navigator.of(context).pop(); // Still unsafe!
  });
}
```

## ✅ Solution: Use SafeContextMixin

We've created a `SafeContextMixin` utility that provides safe context access:

### Step 1: Add the mixin to your State class

```dart
import 'package:tionova/core/utils/safe_context_mixin.dart';

class _MyScreenState extends State<MyScreen> with SafeContextMixin {
  // Your state code
}
```

### Step 2: Use the safe context methods

#### Method 1: `safeContext()` - For synchronous operations

```dart
// ✅ CORRECT: Safe context after async
Future<void> loadData() async {
  await fetchFromApi();
  
  safeContext((ctx) {
    ctx.read<MyCubit>().updateData();
    Navigator.of(ctx).pop();
  });
}

// ✅ CORRECT: Safe context after delay
Future.delayed(Duration(seconds: 1), () {
  safeContext((ctx) {
    Navigator.of(ctx).pop();
    ctx.pop(true);
  });
});
```

#### Method 2: `safeContextAsync()` - For async operations

```dart
// ✅ CORRECT: Safe async context
await safeContextAsync((ctx) async {
  await Navigator.of(ctx).pushNamed('/route');
  await ctx.read<MyCubit>().loadData();
});
```

#### Method 3: `safeContextReturn()` - For operations that return values

```dart
// ✅ CORRECT: Safe context with return value
final colorScheme = safeContextReturn((ctx) {
  return Theme.of(ctx).colorScheme;
});

if (colorScheme != null) {
  // Use the color scheme
}
```

#### Method 4: `contextIsValid` - For simple checks

```dart
// ✅ CORRECT: Check before using context
if (contextIsValid) {
  Navigator.of(context).pop();
  context.read<MyCubit>().doSomething();
}
```

## Common Patterns to Fix

### Pattern 1: Navigation after success dialog

**❌ Before:**
```dart
CustomDialogs.showSuccessDialog(context, ...);

Future.delayed(Duration(seconds: 1), () {
  if (mounted) {
    Navigator.of(context).pop();
    context.pop(true);
  }
});
```

**✅ After:**
```dart
CustomDialogs.showSuccessDialog(context, ...);

Future.delayed(Duration(seconds: 1), () {
  safeContext((ctx) {
    Navigator.of(ctx).pop();
    ctx.pop(true);
  });
});
```

### Pattern 2: API call then navigation

**❌ Before:**
```dart
Future<void> submitForm() async {
  await apiService.submit(data);
  Navigator.of(context).pop();
  context.pushNamed('/success');
}
```

**✅ After:**
```dart
Future<void> submitForm() async {
  await apiService.submit(data);
  
  safeContext((ctx) {
    Navigator.of(ctx).pop();
    ctx.pushNamed('/success');
  });
}
```

### Pattern 3: Reading BLoC/Provider after async

**❌ Before:**
```dart
Future<void> loadData() async {
  await Future.delayed(Duration(seconds: 1));
  final cubit = context.read<MyCubit>();
  cubit.updateData();
}
```

**✅ After:**
```dart
Future<void> loadData() async {
  await Future.delayed(Duration(seconds: 1));
  
  safeContext((ctx) {
    final cubit = ctx.read<MyCubit>();
    cubit.updateData();
  });
}
```

### Pattern 4: Timer/Stream callbacks

**❌ Before:**
```dart
Timer.periodic(Duration(seconds: 1), (timer) {
  setState(() {
    _counter++;
  });
  context.read<MyCubit>().update(_counter);
});
```

**✅ After:**
```dart
Timer? _timer;

@override
void initState() {
  super.initState();
  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (contextIsValid) {
      setState(() {
        _counter++;
      });
      safeContext((ctx) {
        ctx.read<MyCubit>().update(_counter);
      });
    }
  });
}

@override
void dispose() {
  _timer?.cancel();
  super.dispose();
}
```

### Pattern 5: ShowDialog then navigate

**❌ Before:**
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);

await Future.delayed(Duration(seconds: 2));
Navigator.of(context).pop();
context.pushNamed('/next');
```

**✅ After:**
```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);

await Future.delayed(Duration(seconds: 2));

safeContext((ctx) {
  Navigator.of(ctx).pop();
  ctx.pushNamed('/next');
});
```

## Quick Fix Checklist

For each StatefulWidget screen, check:

1. ✅ **Import the mixin**: Add `import 'package:tionova/core/utils/safe_context_mixin.dart';`
2. ✅ **Add the mixin**: Change `State<Widget>` to `State<Widget> with SafeContextMixin`
3. ✅ **Find async operations**: Search for `Future`, `async`, `await`, `Future.delayed`, `Timer`
4. ✅ **Find context usage after async**: Look for `context.read`, `context.push`, `Navigator.of(context)` after async
5. ✅ **Wrap in safeContext()**: Wrap all context usage after async in `safeContext((ctx) { ... })`
6. ✅ **Clean up resources**: Ensure timers, streams, subscriptions are cancelled in dispose()

## Screens to Update

Based on the codebase analysis, these screens likely need the fix:

### High Priority (Heavy context usage after async):
- ✅ `create_chapter_screen.dart` - **FIXED**
- `chapter_detail_screen.dart` - Multiple async operations with context
- `folder_detail_screen.dart` - Navigation and cubit access after async
- `pdf_viewer_screen.dart` - PDF loading with context usage
- `notes_screen.dart` - Note operations with context
- `SummaryViewerScreen.dart` - Summary loading with context
- `EditFolderDialog.dart` - Folder updates with context

### Medium Priority:
- `theme_selection_screen.dart` - Theme changes with navigation
- `profile_screen.dart` - Auth operations with navigation
- `folder_screen.dart` - Folder operations with SSE

### Low Priority (Less likely but good to check):
- `onboarding_screen.dart` - Page navigation
- `quiz_review_answers.dart` - Quiz submission

## Testing After Fix

After applying the fix to each screen:

1. **Test async operations**: Try all features that involve API calls
2. **Test navigation**: Navigate between screens rapidly
3. **Test dialogs**: Open and close dialogs quickly
4. **Test hot reload**: Use hot reload frequently during development
5. **Test dispose**: Navigate away from screen before operations complete

## Prevention Tips

Going forward, always:

1. **Use SafeContextMixin** for any StatefulWidget that uses async operations
2. **Never use bare `context`** after `await`, `Future.delayed`, or callbacks
3. **Always cancel** Timers, Streams, and Subscriptions in dispose()
4. **Check mounted** before calling setState()
5. **Use safeContext()** for all context access after async operations

## Example: Complete Screen Fix

**Before:**
```dart
class _MyScreenState extends State<MyScreen> {
  Future<void> submitData() async {
    showDialog(context: context, builder: (_) => LoadingDialog());
    
    await apiService.submit();
    
    Navigator.of(context).pop(); // Close loading
    
    CustomDialogs.showSuccessDialog(context, ...);
    
    Future.delayed(Duration(seconds: 1), () {
      Navigator.of(context).pop(); // Close success
      context.pop(true); // Navigate back
    });
  }
}
```

**After:**
```dart
import 'package:tionova/core/utils/safe_context_mixin.dart';

class _MyScreenState extends State<MyScreen> with SafeContextMixin {
  Future<void> submitData() async {
    showDialog(context: context, builder: (_) => LoadingDialog());
    
    await apiService.submit();
    
    safeContext((ctx) {
      Navigator.of(ctx).pop(); // Close loading
      
      CustomDialogs.showSuccessDialog(ctx, ...);
      
      Future.delayed(Duration(seconds: 1), () {
        safeContext((innerCtx) {
          Navigator.of(innerCtx).pop(); // Close success
          innerCtx.pop(true); // Navigate back
        });
      });
    });
  }
}
```

## Summary

The `SafeContextMixin` provides a clean, reusable solution to prevent "deactivated widget" errors across your entire app. Apply it systematically to all screens with async operations, and you'll eliminate these errors permanently.

**Key Takeaway**: Never use `context` directly after `await` or in callbacks. Always wrap it in `safeContext()`.
