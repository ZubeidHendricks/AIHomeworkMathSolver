# AIHomeworkMathSolver

Generated from niche `ai-tutor-solver` (AI Text, tier A, score 80).

**Utility:** Photo a problem, get step-by-step solution
**Primary ASO keyword:** `math solver`
**Also target:** `homework helper`, `ai tutor`, `solve math`, `answer scanner`
**Paywall hook:** Unlimited solves, step-by-step, all subjects

> Vision+LLM. Students/parents pay. Watch Apple's 'cheating' framing — position as a tutor.

## Build it

```bash
brew install xcodegen        # once
cd AIHomeworkMathSolver
xcodegen generate
open AIHomeworkMathSolver.xcodeproj
```

The app runs immediately on a MockPurchaseProvider (real paywall UI, fake
purchases). To go live:

1. Replace `revenueCatKey` in `Sources/App.swift` with your RevenueCat key.
2. In App Store Connect create products `ai-tutor-solver_yearly` and `ai-tutor-solver_weekly`,
   map them into a RevenueCat offering, entitlement id `premium`.
3. Build the real feature in `Sources/ContentView.swift`.
4. **Guideline 4.3:** make the function, UI, screenshots and keywords genuinely
   distinct from any sibling app. Re-niche, never reskin.

Bundle id: `com.zubeid.aitutorsolver`

## Ship to TestFlight

This app ships with a Fastlane lane + GitHub Actions workflow. One-time account
setup (API key, signing) is documented in the kit's `Tools/appgen/DEPLOYMENT.md`.
Once your GitHub secrets are set, trigger the **TestFlight** workflow (or push a
`v*` tag), or run locally:

```bash
bundle install
bundle exec fastlane beta
```
