import SwiftUI
import PhotosUI
import AppFactoryKit

// AI Homework / Math Solver — type or photograph an arithmetic problem; it's read
// with on-device OCR and solved locally. Step-by-step algebra and word problems
// are wired behind RemoteSolver (Pro / LLM).
struct ContentView: View {
    @EnvironmentObject private var factory: AppFactory
    private let solver: MathSolving = OnDeviceSolver()

    @State private var input = ""
    @State private var pickerItem: PhotosPickerItem?
    @State private var result: SolveResult?
    @State private var isProcessing = false
    @State private var errorText: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    HStack {
                        TextField("e.g. 12 × (3 + 4)", text: $input)
                            .textFieldStyle(.roundedBorder)
                            .keyboardType(.numbersAndPunctuation)
                            .onSubmit { solveTyped() }
                        Button("Solve") { solveTyped() }
                            .buttonStyle(.borderedProminent).tint(.blue)
                    }

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Scan a problem", systemImage: "text.viewfinder")
                            .frame(maxWidth: .infinity, minHeight: 50)
                    }
                    .buttonStyle(.bordered)

                    if isProcessing { ProgressView() }
                    if let result { resultCard(result) }
                    if let errorText { Text(errorText).font(.footnote).foregroundStyle(.red) }
                }
                .padding(20)
            }
            .navigationTitle("Math Solver")
        }
        .onChange(of: pickerItem) { _, item in
            guard let item else { return }
            Task { await solvePhoto(item) }
        }
    }

    private func resultCard(_ r: SolveResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(r.expression).font(.headline).foregroundStyle(.secondary)
            Text("= \(r.answer)").font(.system(size: 40, weight: .bold))
            Divider()
            if factory.subscriptions.isSubscribed {
                ForEach(r.steps, id: \.self) { Label($0, systemImage: "arrow.right").font(.callout) }
            } else {
                Button {
                    factory.presentPaywall(placement: "steps")
                } label: {
                    Label("Show step-by-step (Pro)", systemImage: "list.number")
                }
                .font(.callout)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(RoundedRectangle(cornerRadius: 16).fill(.blue.opacity(0.1)))
    }

    private func solveTyped() {
        errorText = nil; result = nil
        do { result = try solver.solve(text: input) }
        catch { errorText = "Couldn't read a solvable expression." }
    }

    private func solvePhoto(_ item: PhotosPickerItem) async {
        errorText = nil; result = nil
        guard let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) else {
            errorText = "Couldn't load that photo."; return
        }
        isProcessing = true
        defer { isProcessing = false }
        do {
            let r = try await solver.solve(image: img)
            result = r; input = r.expression
        } catch { errorText = "Couldn't find a solvable problem — try a clearer shot." }
    }
}
