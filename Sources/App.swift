import SwiftUI
import AppFactoryKit

// Math Solver — payments via native StoreKit 2 (no third-party SDK).
private enum Product {
    static let yearly = "mathsolver_pro_yearly"
    static let weekly = "mathsolver_pro_weekly"
}

@MainActor
enum MathSolverFactory {
    static func make() -> AppFactory {
        let config = AppFactoryConfiguration(
            appName: "Math Solver",
            purchaseProvider: StoreKit2PurchaseProvider(productIDs: [Product.yearly, Product.weekly]),
            onboarding: OnboardingConfiguration(
                slides: [
                    .init(systemImage: "camera.viewfinder",
                          title: "Snap or Type a Problem",
                          message: "Photograph any arithmetic problem — it's read and solved instantly, on-device."),
                    .init(systemImage: "list.number",
                          title: "Learn the Steps",
                          message: "See how each answer is reached, step by step.")
                ],
                presentsPaywallOnFinish: true,
                accent: .blue
            ),
            paywall: PaywallConfiguration(
                headline: "Unlock Math Solver Pro",
                subheadline: "Solve more, learn faster.",
                benefits: [
                    .init(systemImage: "list.number", title: "Step-by-step solutions"),
                    .init(systemImage: "infinity", title: "Unlimited solves"),
                    .init(systemImage: "text.viewfinder", title: "Photo scanning"),
                    .init(systemImage: "nosign", title: "No ads")
                ],
                productIDs: [Product.yearly, Product.weekly],
                highlightedProductID: Product.yearly,
                ctaTitle: "Continue",
                dismissButtonDelay: 4,
                isDismissable: true,
                termsURL: URL(string: "https://zubeidhendricks.github.io/AIHomeworkMathSolver/terms.html"),
                privacyURL: URL(string: "https://zubeidhendricks.github.io/AIHomeworkMathSolver/privacy.html"),
                style: PaywallStyle(accent: .blue, heroSystemImage: "x.squareroot")
            )
        )
        return AppFactory(config)
    }
}

@main
struct MathSolverApp: App {
    @StateObject private var factory = MathSolverFactory.make()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .appFactoryRoot(factory)
                .tint(.blue)
        }
    }
}
