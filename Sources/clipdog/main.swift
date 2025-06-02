import SwiftUI
import AppKit

@main
struct ClipDogApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }
    
    var body: some Scene {
        WindowGroup {
            PopoverView()
                .frame(width: 320, height: 240)
        }
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 320, height: 240)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover: NSPopover!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "shield.dog.fill", accessibilityDescription: "ClipDog")
            button.imagePosition = .imageLeft
        }
        
        let contentView = PopoverView()
        popover = NSPopover()
        popover.contentSize = NSSize(width: 320, height: 240)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusItem.button?.action = #selector(togglePopover)
    }
    
    @objc func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }
}

struct PopoverView: View {
    @State private var clipboardText: String = "Sample text"
    @State private var showWarning: Bool = false
    @State private var showMemeMode: Bool = false
    @State private var isShaking: Bool = false
    
    var body: some View {
        VStack(spacing: 16) {
            if showWarning {
                HStack {
                    Image(systemName: "exclamationmark.shield.fill")
                        .foregroundStyle(.red)
                        .modifier(ShakeEffect(animatableData: isShaking ? 1 : 0))
                    Text("Suspicious address detected!")
                        .foregroundStyle(.red)
                }
                .padding()
                .background(.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onAppear {
                    withAnimation(.linear(duration: 0.5).repeatForever()) {
                        isShaking = true
                    }
                }
            }
            
            Text(clipboardText)
                .font(.system(.body))
                .padding()
                .frame(maxWidth: .infinity)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            
            HStack {
                Button(action: simulateClipboard) {
                    Label("Simulate Copy", systemImage: "doc.on.doc")
                }
                .buttonStyle(.borderedProminent)
                
                Button(action: { showMemeMode.toggle() }) {
                    Label("Meme Mode", systemImage: "face.smiling")
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
        .overlay {
            if showMemeMode {
                Text("ARE YOU CRAZY?")
                    .font(.system(size: 24, weight: .black))
                    .foregroundStyle(.red)
                    .rotationEffect(.degrees(-15))
                    .shadow(radius: 2)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring, value: showMemeMode)
        .animation(.spring, value: showWarning)
    }
    
    func simulateClipboard() {
        let samples = [
            "Hello, world!",
            "1BvBMSEYstWetqTFn5Au4m4GFg7xJaNVN2", // Mock BTC address
            "Just a regular note",
            "3J98t1WpEZ73CNmQviecrnyiWrnqRhWNLy" // Another mock BTC address
        ]
        
        clipboardText = samples.randomElement() ?? samples[0]
        showWarning = clipboardText.hasPrefix("1") || clipboardText.hasPrefix("3")
    }
}

struct ShakeEffect: GeometryEffect {
    var animatableData: Double
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 5 * sin(animatableData * .pi * 4), y: 0))
    }
} 