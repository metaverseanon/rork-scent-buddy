import SwiftUI
import SwiftData
import AVFoundation
import Vision

struct PhotoScanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = PhotoScanViewModel()
    @State private var showingAddPerfume: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                scanHeader
                cameraSection
                if !viewModel.recognizedTexts.isEmpty {
                    recognizedTextSection
                }
                if !viewModel.matchedPerfumes.isEmpty {
                    matchedPerfumesSection
                }
                scanTips
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
        .navigationTitle("Scan Perfume")
        .sheet(isPresented: $showingAddPerfume) {
            AddPerfumeView()
        }
    }

    private var scanHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: "camera.viewfinder")
                    .font(.title2)
                    .foregroundStyle(.tint)
                Text("Photo Scanner")
                    .font(.title3.bold())
            }
            Text("Point your camera at a perfume bottle or box to identify it and add it to your collection.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.blue.opacity(0.1), .purple.opacity(0.06)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(.rect(cornerRadius: 16))
        .padding(.top, 8)
    }

    private var cameraSection: some View {
        VStack(spacing: 14) {
            CameraProxyView(onImageCaptured: { image in
                viewModel.processImage(image)
            })
            .frame(height: 320)
            .clipShape(.rect(cornerRadius: 20))

            if viewModel.isProcessing || viewModel.isSearching {
                HStack(spacing: 8) {
                    ProgressView()
                    Text(viewModel.searchStatus.isEmpty ? "Analyzing image..." : viewModel.searchStatus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            } else if !viewModel.searchStatus.isEmpty {
                HStack(spacing: 6) {
                    Image(systemName: viewModel.matchedPerfumes.isEmpty ? "magnifyingglass" : "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(viewModel.matchedPerfumes.isEmpty ? .secondary : .green)
                    Text(viewModel.searchStatus)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var recognizedTextSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "text.viewfinder")
                    .foregroundStyle(.orange)
                Text("Recognized Text")
                    .font(.headline)
                Spacer()
                Button {
                    withAnimation(.snappy) { viewModel.clearResults() }
                } label: {
                    Text("Clear")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                }
            }

            Text("Tap a word to search for it")
                .font(.caption2)
                .foregroundStyle(.tertiary)

            FlowLayout(spacing: 6) {
                ForEach(viewModel.recognizedTexts, id: \.self) { text in
                    Button {
                        Task { await viewModel.searchWithText(text) }
                    } label: {
                        Text(text)
                            .font(.caption)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(.orange.opacity(0.12))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var matchedPerfumesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkle.magnifyingglass")
                    .foregroundStyle(.green)
                Text("Matches Found")
                    .font(.headline)
            }

            ForEach(viewModel.matchedPerfumes) { entry in
                ScanMatchCard(entry: entry) {
                    addToCollection(entry)
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var scanTips: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Scan Tips")
                .font(.subheadline.bold())

            ScanTipRow(icon: "light.max", text: "Good lighting helps recognition")
            ScanTipRow(icon: "textformat.size", text: "Focus on the brand name & perfume name")
            ScanTipRow(icon: "rectangle.portrait.rotate", text: "Hold steady for best results")
            ScanTipRow(icon: "plus.circle", text: "Can't find it? Add manually")

            Button {
                showingAddPerfume = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Manually")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(.tint.opacity(0.12))
                .foregroundStyle(.tint)
                .clipShape(.rect(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func addToCollection(_ entry: PerfumeEntry) {
        let perfume = Perfume(
            name: entry.name,
            brand: entry.brand,
            concentration: PerfumeConstants.concentrations.contains(entry.concentration)
                ? entry.concentration : "Eau de Parfum",
            topNotes: entry.topNotes,
            heartNotes: entry.heartNotes,
            baseNotes: entry.baseNotes
        )
        modelContext.insert(perfume)
        withAnimation(.snappy) {
            viewModel.matchedPerfumes.removeAll { $0.id == entry.id }
        }
    }
}

struct ScanMatchCard: View {
    let entry: PerfumeEntry
    let onAdd: () -> Void
    @State private var added: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(cardGradient)
                .frame(width: 50, height: 50)
                .overlay {
                    Image(systemName: "drop.fill")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.5))
                }

            VStack(alignment: .leading, spacing: 3) {
                Text(entry.name)
                    .font(.subheadline.bold())
                Text(entry.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(entry.concentration)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()

            if added {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.green)
            } else {
                Button {
                    onAdd()
                    withAnimation(.snappy) { added = true }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.tint)
                }
            }
        }
        .padding(12)
        .background(AppearanceManager.shared.theme.chipColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var cardGradient: LinearGradient {
        let hash = abs(entry.name.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple.opacity(0.7), .indigo.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink.opacity(0.6), .orange.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.6), .teal.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.7), .red.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}

struct ScanTipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(width: 20)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

struct CameraProxyView: View {
    let onImageCaptured: (UIImage) -> Void

    var body: some View {
        #if targetEnvironment(simulator)
        CameraPlaceholderView(onImageCaptured: onImageCaptured)
        #else
        if AVCaptureDevice.default(for: .video) != nil {
            LiveCameraView(onImageCaptured: onImageCaptured)
        } else {
            CameraPlaceholderView(onImageCaptured: onImageCaptured)
        }
        #endif
    }
}

struct CameraPlaceholderView: View {
    let onImageCaptured: (UIImage) -> Void

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("Camera Preview")
                .font(.title3.bold())
            Text("Install this app on your device\nvia the Rork App to use the camera.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.secondarySystemBackground))
    }
}

struct LiveCameraView: UIViewControllerRepresentable {
    let onImageCaptured: (UIImage) -> Void

    func makeUIViewController(context: Context) -> LiveCameraViewController {
        let vc = LiveCameraViewController()
        vc.onImageCaptured = onImageCaptured
        return vc
    }

    func updateUIViewController(_ uiViewController: LiveCameraViewController, context: Context) {}
}

class LiveCameraViewController: UIViewController {
    var onImageCaptured: ((UIImage) -> Void)?
    nonisolated(unsafe) private let captureSession = AVCaptureSession()
    nonisolated(unsafe) private let photoOutput = AVCapturePhotoOutput()
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private let sessionQueue = DispatchQueue(label: "cameraSessionQueue")

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        addCaptureButton()
    }

    private func setupCamera() {
        let session = captureSession
        let output = photoOutput
        sessionQueue.async { [weak self] in
            session.beginConfiguration()
            session.sessionPreset = .photo

            guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back),
                  let input = try? AVCaptureDeviceInput(device: camera),
                  session.canAddInput(input) else { return }
            session.addInput(input)

            if session.canAddOutput(output) {
                session.addOutput(output)
            }

            session.commitConfiguration()
            session.startRunning()

            DispatchQueue.main.async {
                guard let self else { return }
                let layer = AVCaptureVideoPreviewLayer(session: session)
                layer.videoGravity = .resizeAspectFill
                layer.frame = self.view.bounds
                self.view.layer.insertSublayer(layer, at: 0)
                self.previewLayer = layer
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.bounds
    }

    private func addCaptureButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.circle.fill"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)

        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        blurView.layer.cornerRadius = 32
        blurView.clipsToBounds = true
        blurView.isUserInteractionEnabled = false

        view.addSubview(blurView)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20),
            button.widthAnchor.constraint(equalToConstant: 64),
            button.heightAnchor.constraint(equalToConstant: 64),

            blurView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            blurView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            blurView.widthAnchor.constraint(equalToConstant: 64),
            blurView.heightAnchor.constraint(equalToConstant: 64),
        ])
    }

    @objc private func capturePhoto() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        let session = captureSession
        sessionQueue.async {
            session.stopRunning()
        }
    }
}

extension LiveCameraViewController: AVCapturePhotoCaptureDelegate {
    nonisolated func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let data = photo.fileDataRepresentation(),
              let image = UIImage(data: data) else { return }
        Task { @MainActor in
            self.onImageCaptured?(image)
        }
    }
}
