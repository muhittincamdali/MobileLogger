import Foundation
#if canImport(UIKit)
import UIKit
#endif
#if canImport(MachO)
import MachO
#endif

// MARK: - CrashReporterConfiguration

/// Configuration options for the crash reporter.
///
/// Use this structure to customize crash reporting behavior,
/// including what data to collect and where to send reports.
///
/// ```swift
/// var config = CrashReporterConfiguration()
/// config.collectDeviceInfo = true
/// config.collectAppInfo = true
/// config.maxStoredReports = 20
/// let reporter = AdvancedCrashReporter(configuration: config)
/// ```
public struct CrashReporterConfiguration: Sendable {

    /// Whether to collect device information (model, OS version, etc.).
    public var collectDeviceInfo: Bool

    /// Whether to collect application information (version, build, etc.).
    public var collectAppInfo: Bool

    /// Whether to collect memory statistics.
    public var collectMemoryInfo: Bool

    /// Whether to collect disk space information.
    public var collectDiskInfo: Bool

    /// Whether to collect battery status.
    public var collectBatteryInfo: Bool

    /// Whether to collect network reachability status.
    public var collectNetworkInfo: Bool

    /// Whether to symbolicate stack traces when possible.
    public var symbolicateStackTraces: Bool

    /// Maximum number of crash reports to store locally.
    public var maxStoredReports: Int

    /// Maximum age (in days) for stored crash reports.
    public var maxReportAgeDays: Int

    /// Directory for storing crash reports.
    public var storageDirectory: URL?

    /// Custom metadata to include in every crash report.
    public var customMetadata: [String: String]

    /// Whether to automatically send reports on next launch.
    public var autoSendOnLaunch: Bool

    /// Minimum time between automatic report submissions (seconds).
    public var minimumSubmissionInterval: TimeInterval

    /// Creates a new configuration with default values.
    public init() {
        self.collectDeviceInfo = true
        self.collectAppInfo = true
        self.collectMemoryInfo = true
        self.collectDiskInfo = false
        self.collectBatteryInfo = false
        self.collectNetworkInfo = false
        self.symbolicateStackTraces = true
        self.maxStoredReports = 10
        self.maxReportAgeDays = 30
        self.storageDirectory = nil
        self.customMetadata = [:]
        self.autoSendOnLaunch = true
        self.minimumSubmissionInterval = 60
    }
}

// MARK: - CrashType

/// The type of crash that occurred.
///
/// Different crash types require different handling and provide
/// different levels of diagnostic information.
public enum CrashType: String, Sendable, Codable, CaseIterable {

    /// An uncaught Objective-C/Swift exception.
    case exception

    /// A POSIX signal (SIGSEGV, SIGBUS, etc.).
    case signal

    /// A Mach exception.
    case machException

    /// Application terminated due to memory pressure.
    case outOfMemory

    /// Application terminated due to watchdog timeout.
    case watchdogTimeout

    /// Application terminated in background.
    case backgroundTermination

    /// CPU resource limit exceeded.
    case cpuResourceLimit

    /// Custom application-defined crash.
    case custom

    /// Human-readable description of the crash type.
    public var displayName: String {
        switch self {
        case .exception:
            return "Uncaught Exception"
        case .signal:
            return "Signal"
        case .machException:
            return "Mach Exception"
        case .outOfMemory:
            return "Out of Memory"
        case .watchdogTimeout:
            return "Watchdog Timeout"
        case .backgroundTermination:
            return "Background Termination"
        case .cpuResourceLimit:
            return "CPU Resource Limit"
        case .custom:
            return "Custom"
        }
    }
}

// MARK: - CrashSeverity

/// Severity level of the crash.
///
/// Helps prioritize crash reports during triage.
public enum CrashSeverity: Int, Sendable, Codable, Comparable {

    /// Low severity - minor issue, app may continue.
    case low = 1

    /// Medium severity - significant issue.
    case medium = 2

    /// High severity - critical issue causing termination.
    case high = 3

    /// Critical severity - system-level crash.
    case critical = 4

    public static func < (lhs: CrashSeverity, rhs: CrashSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Human-readable description.
    public var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .critical:
            return "Critical"
        }
    }
}

// MARK: - ThreadInfo

/// Information about a thread at the time of crash.
///
/// Captures the state of each thread including its stack trace,
/// making it easier to identify the source of the crash.
public struct ThreadInfo: Sendable, Codable, Identifiable {

    /// Unique identifier for this thread info.
    public let id: UUID

    /// The thread number.
    public let threadNumber: Int

    /// The thread name, if available.
    public let name: String?

    /// Whether this is the crashed thread.
    public let isCrashed: Bool

    /// Whether this is the main thread.
    public let isMainThread: Bool

    /// Stack frames for this thread.
    public let stackFrames: [StackFrame]

    /// Thread priority.
    public let priority: Int?

    /// Thread quality of service class.
    public let qosClass: String?

    /// CPU usage percentage at time of crash.
    public let cpuUsage: Double?

    /// Creates thread information.
    ///
    /// - Parameters:
    ///   - threadNumber: The thread number.
    ///   - name: Optional thread name.
    ///   - isCrashed: Whether this thread crashed.
    ///   - isMainThread: Whether this is the main thread.
    ///   - stackFrames: Stack frames for the thread.
    ///   - priority: Thread priority.
    ///   - qosClass: Quality of service class.
    ///   - cpuUsage: CPU usage percentage.
    public init(
        threadNumber: Int,
        name: String? = nil,
        isCrashed: Bool = false,
        isMainThread: Bool = false,
        stackFrames: [StackFrame] = [],
        priority: Int? = nil,
        qosClass: String? = nil,
        cpuUsage: Double? = nil
    ) {
        self.id = UUID()
        self.threadNumber = threadNumber
        self.name = name
        self.isCrashed = isCrashed
        self.isMainThread = isMainThread
        self.stackFrames = stackFrames
        self.priority = priority
        self.qosClass = qosClass
        self.cpuUsage = cpuUsage
    }
}

// MARK: - StackFrame

/// A single frame in a stack trace.
///
/// Contains both raw address information and symbolicated names
/// when available.
public struct StackFrame: Sendable, Codable, Identifiable {

    /// Unique identifier for this frame.
    public let id: UUID

    /// Frame index in the stack (0 = top).
    public let index: Int

    /// Binary image name (e.g., "MyApp", "UIKit").
    public let imageName: String

    /// Raw instruction address.
    public let address: UInt64

    /// Symbol name if available.
    public let symbolName: String?

    /// Offset from the symbol start.
    public let symbolOffset: UInt64?

    /// Source file name if available (debug builds).
    public let fileName: String?

    /// Line number if available (debug builds).
    public let lineNumber: Int?

    /// Whether this frame has been symbolicated.
    public let isSymbolicated: Bool

    /// Creates a stack frame.
    ///
    /// - Parameters:
    ///   - index: Frame index.
    ///   - imageName: Binary image name.
    ///   - address: Instruction address.
    ///   - symbolName: Symbol name.
    ///   - symbolOffset: Offset from symbol.
    ///   - fileName: Source file name.
    ///   - lineNumber: Source line number.
    public init(
        index: Int,
        imageName: String,
        address: UInt64,
        symbolName: String? = nil,
        symbolOffset: UInt64? = nil,
        fileName: String? = nil,
        lineNumber: Int? = nil
    ) {
        self.id = UUID()
        self.index = index
        self.imageName = imageName
        self.address = address
        self.symbolName = symbolName
        self.symbolOffset = symbolOffset
        self.fileName = fileName
        self.lineNumber = lineNumber
        self.isSymbolicated = symbolName != nil
    }

    /// Returns a formatted string representation.
    public var formattedDescription: String {
        var result = "\(index)   \(imageName)"

        if let symbol = symbolName {
            result += "    \(symbol)"
            if let offset = symbolOffset {
                result += " + \(offset)"
            }
        } else {
            result += "    0x\(String(address, radix: 16))"
        }

        if let file = fileName, let line = lineNumber {
            result += " (\(file):\(line))"
        }

        return result
    }
}

// MARK: - BinaryImage

/// Information about a loaded binary image.
///
/// Used for offline symbolication of crash reports.
public struct BinaryImage: Sendable, Codable, Identifiable {

    /// Unique identifier for this binary image.
    public let id: UUID

    /// The image name.
    public let name: String

    /// The image path.
    public let path: String

    /// The image UUID for symbolication.
    public let uuid: String

    /// Base load address.
    public let baseAddress: UInt64

    /// Image size in bytes.
    public let size: UInt64

    /// CPU architecture (arm64, x86_64, etc.).
    public let architecture: String

    /// The image version if available.
    public let version: String?

    /// Creates binary image information.
    ///
    /// - Parameters:
    ///   - name: Image name.
    ///   - path: Image path.
    ///   - uuid: Image UUID.
    ///   - baseAddress: Base load address.
    ///   - size: Image size.
    ///   - architecture: CPU architecture.
    ///   - version: Image version.
    public init(
        name: String,
        path: String,
        uuid: String,
        baseAddress: UInt64,
        size: UInt64,
        architecture: String,
        version: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.path = path
        self.uuid = uuid
        self.baseAddress = baseAddress
        self.size = size
        self.architecture = architecture
        self.version = version
    }
}

// MARK: - DeviceInfo

/// Device information captured at crash time.
///
/// Provides context about the device state when the crash occurred.
public struct DeviceInfo: Sendable, Codable {

    /// Device model identifier (e.g., "iPhone14,2").
    public let modelIdentifier: String

    /// Device model name (e.g., "iPhone 13 Pro").
    public let modelName: String

    /// Operating system name.
    public let osName: String

    /// Operating system version.
    public let osVersion: String

    /// Operating system build number.
    public let osBuild: String

    /// CPU architecture.
    public let architecture: String

    /// Number of CPU cores.
    public let cpuCores: Int

    /// Total physical memory in bytes.
    public let totalMemory: UInt64

    /// Available memory at crash time in bytes.
    public let availableMemory: UInt64?

    /// Total disk space in bytes.
    public let totalDiskSpace: UInt64?

    /// Available disk space in bytes.
    public let availableDiskSpace: UInt64?

    /// Battery level (0.0 to 1.0).
    public let batteryLevel: Float?

    /// Battery state (charging, full, unplugged).
    public let batteryState: String?

    /// Whether the device is jailbroken.
    public let isJailbroken: Bool

    /// Locale identifier.
    public let locale: String

    /// Timezone identifier.
    public let timezone: String

    /// Screen resolution.
    public let screenResolution: String?

    /// Screen scale factor.
    public let screenScale: Float?

    /// Creates device information.
    public init(
        modelIdentifier: String = "",
        modelName: String = "",
        osName: String = "",
        osVersion: String = "",
        osBuild: String = "",
        architecture: String = "",
        cpuCores: Int = 0,
        totalMemory: UInt64 = 0,
        availableMemory: UInt64? = nil,
        totalDiskSpace: UInt64? = nil,
        availableDiskSpace: UInt64? = nil,
        batteryLevel: Float? = nil,
        batteryState: String? = nil,
        isJailbroken: Bool = false,
        locale: String = "",
        timezone: String = "",
        screenResolution: String? = nil,
        screenScale: Float? = nil
    ) {
        self.modelIdentifier = modelIdentifier
        self.modelName = modelName
        self.osName = osName
        self.osVersion = osVersion
        self.osBuild = osBuild
        self.architecture = architecture
        self.cpuCores = cpuCores
        self.totalMemory = totalMemory
        self.availableMemory = availableMemory
        self.totalDiskSpace = totalDiskSpace
        self.availableDiskSpace = availableDiskSpace
        self.batteryLevel = batteryLevel
        self.batteryState = batteryState
        self.isJailbroken = isJailbroken
        self.locale = locale
        self.timezone = timezone
        self.screenResolution = screenResolution
        self.screenScale = screenScale
    }

    /// Collects current device information.
    ///
    /// - Returns: A populated DeviceInfo structure.
    public static func collect() -> DeviceInfo {
        var systemInfo = utsname()
        uname(&systemInfo)

        let machine = withUnsafePointer(to: &systemInfo.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                String(validatingUTF8: $0) ?? "unknown"
            }
        }

        let processInfo = ProcessInfo.processInfo

        #if canImport(UIKit) && !os(watchOS)
        let device = UIDevice.current
        let osName = device.systemName
        let osVersion = device.systemVersion
        #else
        let osName = "macOS"
        let osVersion = processInfo.operatingSystemVersionString
        #endif

        var osBuild = ""
        var size = 256
        var buffer = [CChar](repeating: 0, count: size)
        if sysctlbyname("kern.osversion", &buffer, &size, nil, 0) == 0 {
            osBuild = String(cString: buffer)
        }

        #if arch(arm64)
        let architecture = "arm64"
        #elseif arch(x86_64)
        let architecture = "x86_64"
        #else
        let architecture = "unknown"
        #endif

        return DeviceInfo(
            modelIdentifier: machine,
            modelName: modelNameFromIdentifier(machine),
            osName: osName,
            osVersion: osVersion,
            osBuild: osBuild,
            architecture: architecture,
            cpuCores: processInfo.processorCount,
            totalMemory: processInfo.physicalMemory,
            availableMemory: getAvailableMemory(),
            totalDiskSpace: getTotalDiskSpace(),
            availableDiskSpace: getAvailableDiskSpace(),
            batteryLevel: getBatteryLevel(),
            batteryState: getBatteryState(),
            isJailbroken: checkJailbroken(),
            locale: Locale.current.identifier,
            timezone: TimeZone.current.identifier,
            screenResolution: getScreenResolution(),
            screenScale: getScreenScale()
        )
    }

    private static func modelNameFromIdentifier(_ identifier: String) -> String {
        let mapping: [String: String] = [
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone14,4": "iPhone 13 mini",
            "iPhone14,5": "iPhone 13",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone15,4": "iPhone 14",
            "iPhone15,5": "iPhone 14 Plus",
            "iPhone16,1": "iPhone 15 Pro",
            "iPhone16,2": "iPhone 15 Pro Max",
            "iPad13,4": "iPad Pro 11-inch (3rd gen)",
            "iPad13,5": "iPad Pro 11-inch (3rd gen)",
            "iPad14,1": "iPad mini (6th gen)"
        ]
        return mapping[identifier] ?? identifier
    }

    private static func getAvailableMemory() -> UInt64? {
        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)

        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(
            MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size
        )

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return nil }

        let freeMemory = UInt64(stats.free_count) * UInt64(pageSize)
        return freeMemory
    }

    private static func getTotalDiskSpace() -> UInt64? {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
        ) else { return nil }
        return attributes[.systemSize] as? UInt64
    }

    private static func getAvailableDiskSpace() -> UInt64? {
        guard let attributes = try? FileManager.default.attributesOfFileSystem(
            forPath: NSHomeDirectory()
        ) else { return nil }
        return attributes[.systemFreeSize] as? UInt64
    }

    private static func getBatteryLevel() -> Float? {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        return level >= 0 ? level : nil
        #else
        return nil
        #endif
    }

    private static func getBatteryState() -> String? {
        #if canImport(UIKit) && !os(watchOS) && !os(tvOS)
        UIDevice.current.isBatteryMonitoringEnabled = true
        switch UIDevice.current.batteryState {
        case .unknown:
            return "unknown"
        case .unplugged:
            return "unplugged"
        case .charging:
            return "charging"
        case .full:
            return "full"
        @unknown default:
            return "unknown"
        }
        #else
        return nil
        #endif
    }

    private static func checkJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        let paths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/"
        ]

        for path in paths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }

        if let file = fopen("/bin/bash", "r") {
            fclose(file)
            return true
        }

        return false
        #endif
    }

    private static func getScreenResolution() -> String? {
        #if canImport(UIKit) && !os(watchOS)
        let screen = UIScreen.main
        let bounds = screen.bounds
        let scale = screen.scale
        let width = Int(bounds.width * scale)
        let height = Int(bounds.height * scale)
        return "\(width)x\(height)"
        #else
        return nil
        #endif
    }

    private static func getScreenScale() -> Float? {
        #if canImport(UIKit) && !os(watchOS)
        return Float(UIScreen.main.scale)
        #else
        return nil
        #endif
    }
}

// MARK: - AppInfo

/// Application information captured at crash time.
public struct AppInfo: Sendable, Codable {

    /// Application bundle identifier.
    public let bundleIdentifier: String

    /// Application name.
    public let appName: String

    /// Application version string.
    public let appVersion: String

    /// Build number.
    public let buildNumber: String

    /// Minimum OS version supported.
    public let minimumOSVersion: String?

    /// SDK version used to build.
    public let sdkVersion: String?

    /// Whether the app is a debug build.
    public let isDebugBuild: Bool

    /// Whether the app is running in TestFlight.
    public let isTestFlight: Bool

    /// App Store receipt URL if available.
    public let receiptURL: String?

    /// Process identifier.
    public let processId: Int32

    /// Process name.
    public let processName: String

    /// Parent process identifier.
    public let parentProcessId: Int32

    /// Application start time.
    public let startTime: Date

    /// Time running before crash.
    public let uptimeSeconds: TimeInterval

    /// Creates application information.
    public init(
        bundleIdentifier: String = "",
        appName: String = "",
        appVersion: String = "",
        buildNumber: String = "",
        minimumOSVersion: String? = nil,
        sdkVersion: String? = nil,
        isDebugBuild: Bool = false,
        isTestFlight: Bool = false,
        receiptURL: String? = nil,
        processId: Int32 = 0,
        processName: String = "",
        parentProcessId: Int32 = 0,
        startTime: Date = Date(),
        uptimeSeconds: TimeInterval = 0
    ) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.appVersion = appVersion
        self.buildNumber = buildNumber
        self.minimumOSVersion = minimumOSVersion
        self.sdkVersion = sdkVersion
        self.isDebugBuild = isDebugBuild
        self.isTestFlight = isTestFlight
        self.receiptURL = receiptURL
        self.processId = processId
        self.processName = processName
        self.parentProcessId = parentProcessId
        self.startTime = startTime
        self.uptimeSeconds = uptimeSeconds
    }

    /// Collects current application information.
    ///
    /// - Parameter startTime: The application start time.
    /// - Returns: A populated AppInfo structure.
    public static func collect(startTime: Date = Date()) -> AppInfo {
        let bundle = Bundle.main
        let infoDictionary = bundle.infoDictionary ?? [:]

        let bundleIdentifier = bundle.bundleIdentifier ?? "unknown"
        let appName = infoDictionary["CFBundleName"] as? String ?? "unknown"
        let appVersion = infoDictionary["CFBundleShortVersionString"] as? String ?? "0.0.0"
        let buildNumber = infoDictionary["CFBundleVersion"] as? String ?? "0"
        let minimumOSVersion = infoDictionary["MinimumOSVersion"] as? String
        let sdkVersion = infoDictionary["DTSDKName"] as? String

        #if DEBUG
        let isDebugBuild = true
        #else
        let isDebugBuild = false
        #endif

        let isTestFlight = bundle.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"

        let receiptURL = bundle.appStoreReceiptURL?.absoluteString

        let processInfo = ProcessInfo.processInfo
        let processId = processInfo.processIdentifier
        let processName = processInfo.processName
        let parentProcessId = getppid()

        let uptime = Date().timeIntervalSince(startTime)

        return AppInfo(
            bundleIdentifier: bundleIdentifier,
            appName: appName,
            appVersion: appVersion,
            buildNumber: buildNumber,
            minimumOSVersion: minimumOSVersion,
            sdkVersion: sdkVersion,
            isDebugBuild: isDebugBuild,
            isTestFlight: isTestFlight,
            receiptURL: receiptURL,
            processId: processId,
            processName: processName,
            parentProcessId: parentProcessId,
            startTime: startTime,
            uptimeSeconds: uptime
        )
    }
}

// MARK: - CrashReport

/// A complete crash report containing all diagnostic information.
///
/// Crash reports can be serialized to JSON for storage or transmission
/// to crash reporting services.
public struct CrashReport: Sendable, Codable, Identifiable {

    /// Unique identifier for this crash report.
    public let id: UUID

    /// When the crash occurred.
    public let timestamp: Date

    /// Type of crash.
    public let crashType: CrashType

    /// Crash severity.
    public let severity: CrashSeverity

    /// The exception name if applicable.
    public let exceptionType: String?

    /// The exception reason/message.
    public let exceptionMessage: String?

    /// Signal number if applicable.
    public let signalNumber: Int32?

    /// Signal name if applicable.
    public let signalName: String?

    /// Signal code.
    public let signalCode: Int32?

    /// Fault address if applicable.
    public let faultAddress: UInt64?

    /// All thread information.
    public let threads: [ThreadInfo]

    /// The crashed thread index.
    public let crashedThreadIndex: Int?

    /// Loaded binary images.
    public let binaryImages: [BinaryImage]

    /// Device information.
    public let deviceInfo: DeviceInfo?

    /// Application information.
    public let appInfo: AppInfo?

    /// Custom metadata.
    public let metadata: [String: String]

    /// User-provided context.
    public let userContext: [String: String]

    /// Breadcrumbs leading up to the crash.
    public let breadcrumbs: [Breadcrumb]

    /// Report format version.
    public let formatVersion: Int

    /// Creates a crash report.
    ///
    /// - Parameters:
    ///   - crashType: Type of crash.
    ///   - severity: Crash severity.
    ///   - exceptionType: Exception type name.
    ///   - exceptionMessage: Exception message.
    ///   - signalNumber: Signal number.
    ///   - signalName: Signal name.
    ///   - signalCode: Signal code.
    ///   - faultAddress: Fault address.
    ///   - threads: Thread information.
    ///   - crashedThreadIndex: Index of crashed thread.
    ///   - binaryImages: Loaded binary images.
    ///   - deviceInfo: Device information.
    ///   - appInfo: Application information.
    ///   - metadata: Custom metadata.
    ///   - userContext: User-provided context.
    ///   - breadcrumbs: Event breadcrumbs.
    public init(
        crashType: CrashType,
        severity: CrashSeverity = .high,
        exceptionType: String? = nil,
        exceptionMessage: String? = nil,
        signalNumber: Int32? = nil,
        signalName: String? = nil,
        signalCode: Int32? = nil,
        faultAddress: UInt64? = nil,
        threads: [ThreadInfo] = [],
        crashedThreadIndex: Int? = nil,
        binaryImages: [BinaryImage] = [],
        deviceInfo: DeviceInfo? = nil,
        appInfo: AppInfo? = nil,
        metadata: [String: String] = [:],
        userContext: [String: String] = [:],
        breadcrumbs: [Breadcrumb] = []
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.crashType = crashType
        self.severity = severity
        self.exceptionType = exceptionType
        self.exceptionMessage = exceptionMessage
        self.signalNumber = signalNumber
        self.signalName = signalName
        self.signalCode = signalCode
        self.faultAddress = faultAddress
        self.threads = threads
        self.crashedThreadIndex = crashedThreadIndex
        self.binaryImages = binaryImages
        self.deviceInfo = deviceInfo
        self.appInfo = appInfo
        self.metadata = metadata
        self.userContext = userContext
        self.breadcrumbs = breadcrumbs
        self.formatVersion = 1
    }

    /// Returns the report as JSON data.
    ///
    /// - Parameter prettyPrinted: Whether to format the JSON.
    /// - Returns: JSON data representation.
    public func toJSON(prettyPrinted: Bool = false) throws -> Data {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if prettyPrinted {
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        }
        return try encoder.encode(self)
    }

    /// Creates a report from JSON data.
    ///
    /// - Parameter data: JSON data.
    /// - Returns: A crash report.
    public static func fromJSON(_ data: Data) throws -> CrashReport {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(CrashReport.self, from: data)
    }
}

// MARK: - Breadcrumb

/// A breadcrumb event for tracking user actions before a crash.
///
/// Breadcrumbs provide context about what the user was doing
/// leading up to a crash.
public struct Breadcrumb: Sendable, Codable, Identifiable {

    /// Unique identifier.
    public let id: UUID

    /// When the breadcrumb was created.
    public let timestamp: Date

    /// Breadcrumb category.
    public let category: String

    /// Breadcrumb message.
    public let message: String

    /// Breadcrumb level.
    public let level: BreadcrumbLevel

    /// Additional data.
    public let data: [String: String]

    /// Creates a breadcrumb.
    ///
    /// - Parameters:
    ///   - category: The breadcrumb category.
    ///   - message: The breadcrumb message.
    ///   - level: The breadcrumb level.
    ///   - data: Additional data.
    public init(
        category: String,
        message: String,
        level: BreadcrumbLevel = .info,
        data: [String: String] = [:]
    ) {
        self.id = UUID()
        self.timestamp = Date()
        self.category = category
        self.message = message
        self.level = level
        self.data = data
    }
}

// MARK: - BreadcrumbLevel

/// Breadcrumb importance level.
public enum BreadcrumbLevel: String, Sendable, Codable {

    /// Debug information.
    case debug

    /// General information.
    case info

    /// Warning.
    case warning

    /// Error.
    case error

    /// Critical.
    case critical
}

// MARK: - CrashReportDelegate

/// Delegate protocol for crash reporter events.
///
/// Implement this protocol to receive notifications about crash events
/// and control report submission.
public protocol CrashReportDelegate: AnyObject, Sendable {

    /// Called when a crash is detected.
    ///
    /// - Parameter report: The crash report.
    func crashReporterDidDetectCrash(_ report: CrashReport)

    /// Called before submitting a crash report.
    ///
    /// - Parameter report: The crash report to submit.
    /// - Returns: Whether to proceed with submission.
    func crashReporterShouldSubmitReport(_ report: CrashReport) -> Bool

    /// Called after successfully submitting a crash report.
    ///
    /// - Parameter report: The submitted crash report.
    func crashReporterDidSubmitReport(_ report: CrashReport)

    /// Called when report submission fails.
    ///
    /// - Parameters:
    ///   - report: The crash report.
    ///   - error: The error that occurred.
    func crashReporterDidFailToSubmitReport(_ report: CrashReport, error: Error)
}

// MARK: - Default Delegate Implementation

extension CrashReportDelegate {

    public func crashReporterDidDetectCrash(_ report: CrashReport) {}

    public func crashReporterShouldSubmitReport(_ report: CrashReport) -> Bool {
        return true
    }

    public func crashReporterDidSubmitReport(_ report: CrashReport) {}

    public func crashReporterDidFailToSubmitReport(_ report: CrashReport, error: Error) {}
}

// MARK: - AdvancedCrashReporter

/// An advanced crash reporter with comprehensive diagnostic capabilities.
///
/// This crash reporter captures detailed information about crashes including
/// stack traces, device state, and application context. It supports local
/// storage of crash reports and integration with external crash reporting services.
///
/// ## Setup
///
/// ```swift
/// let config = CrashReporterConfiguration()
/// let reporter = AdvancedCrashReporter(configuration: config)
/// reporter.install()
/// ```
///
/// ## Breadcrumbs
///
/// Track user actions to provide context for crashes:
///
/// ```swift
/// reporter.addBreadcrumb(
///     category: "ui",
///     message: "User tapped submit button"
/// )
/// ```
///
/// ## Custom Metadata
///
/// Add custom data to all crash reports:
///
/// ```swift
/// reporter.setCustomValue("premium", forKey: "userType")
/// ```
public final class AdvancedCrashReporter: @unchecked Sendable {

    // MARK: - Properties

    /// The configuration for this reporter.
    public let configuration: CrashReporterConfiguration

    /// The logger instance for logging crash events.
    public let logger: Logger

    /// Delegate for crash events.
    public weak var delegate: CrashReportDelegate?

    /// Whether the reporter has been installed.
    public private(set) var isInstalled: Bool = false

    /// Application start time for uptime calculation.
    private let appStartTime: Date

    /// Serial queue for thread-safe operations.
    private let queue = DispatchQueue(label: "com.mobilelogger.crashreporter")

    /// Current breadcrumbs.
    private var breadcrumbs: [Breadcrumb] = []

    /// Maximum number of breadcrumbs to retain.
    private let maxBreadcrumbs: Int = 100

    /// Custom metadata to include in reports.
    private var customMetadata: [String: String] = [:]

    /// User context information.
    private var userContext: [String: String] = [:]

    /// Storage directory for crash reports.
    private let storageDirectory: URL

    /// Monitored signals.
    private let monitoredSignals: [Int32] = [
        SIGABRT,
        SIGSEGV,
        SIGBUS,
        SIGFPE,
        SIGILL,
        SIGTRAP,
        SIGQUIT,
        SIGSYS
    ]

    /// Previous signal handlers for chaining.
    private var previousHandlers: [Int32: (@convention(c) (Int32) -> Void)?] = [:]

    /// Static reference for C callback access.
    private static var current: AdvancedCrashReporter?

    // MARK: - Initialization

    /// Creates a new advanced crash reporter.
    ///
    /// - Parameters:
    ///   - configuration: Reporter configuration.
    ///   - logger: Logger instance for logging.
    public init(
        configuration: CrashReporterConfiguration = CrashReporterConfiguration(),
        logger: Logger = Logger.shared
    ) {
        self.configuration = configuration
        self.logger = logger
        self.appStartTime = Date()

        if let customDirectory = configuration.storageDirectory {
            self.storageDirectory = customDirectory
        } else {
            let caches = FileManager.default.urls(
                for: .cachesDirectory,
                in: .userDomainMask
            ).first!
            self.storageDirectory = caches.appendingPathComponent("CrashReports")
        }

        createStorageDirectoryIfNeeded()
    }

    // MARK: - Installation

    /// Installs the crash handlers.
    ///
    /// Call this as early as possible in your application lifecycle,
    /// ideally in `application(_:didFinishLaunchingWithOptions:)`.
    public func install() {
        queue.sync {
            guard !isInstalled else { return }
            isInstalled = true
            Self.current = self

            NSSetUncaughtExceptionHandler { exception in
                AdvancedCrashReporter.handleException(exception)
            }

            for sig in monitoredSignals {
                let previous = signal(sig, AdvancedCrashReporter.signalHandler)
                previousHandlers[sig] = previous
            }

            logger.info("Crash reporter installed")

            if configuration.autoSendOnLaunch {
                processPendingReports()
            }
        }
    }

    /// Uninstalls the crash handlers.
    public func uninstall() {
        queue.sync {
            guard isInstalled else { return }
            isInstalled = false

            NSSetUncaughtExceptionHandler(nil)

            for sig in monitoredSignals {
                if let previous = previousHandlers[sig] {
                    signal(sig, previous)
                } else {
                    signal(sig, SIG_DFL)
                }
            }

            previousHandlers.removeAll()
            Self.current = nil

            logger.info("Crash reporter uninstalled")
        }
    }

    // MARK: - Breadcrumbs

    /// Adds a breadcrumb for crash context.
    ///
    /// - Parameters:
    ///   - category: The breadcrumb category (e.g., "ui", "network").
    ///   - message: The breadcrumb message.
    ///   - level: The breadcrumb importance level.
    ///   - data: Additional key-value data.
    public func addBreadcrumb(
        category: String,
        message: String,
        level: BreadcrumbLevel = .info,
        data: [String: String] = [:]
    ) {
        let breadcrumb = Breadcrumb(
            category: category,
            message: message,
            level: level,
            data: data
        )

        queue.async { [weak self] in
            guard let self = self else { return }
            self.breadcrumbs.append(breadcrumb)
            if self.breadcrumbs.count > self.maxBreadcrumbs {
                self.breadcrumbs.removeFirst()
            }
        }
    }

    /// Clears all breadcrumbs.
    public func clearBreadcrumbs() {
        queue.async { [weak self] in
            self?.breadcrumbs.removeAll()
        }
    }

    // MARK: - Custom Metadata

    /// Sets a custom value to include in crash reports.
    ///
    /// - Parameters:
    ///   - value: The value to set.
    ///   - key: The key for the value.
    public func setCustomValue(_ value: String, forKey key: String) {
        queue.async { [weak self] in
            self?.customMetadata[key] = value
        }
    }

    /// Removes a custom value.
    ///
    /// - Parameter key: The key to remove.
    public func removeCustomValue(forKey key: String) {
        queue.async { [weak self] in
            self?.customMetadata.removeValue(forKey: key)
        }
    }

    /// Clears all custom metadata.
    public func clearCustomMetadata() {
        queue.async { [weak self] in
            self?.customMetadata.removeAll()
        }
    }

    // MARK: - User Context

    /// Sets user identification information.
    ///
    /// - Parameters:
    ///   - userId: The user's unique identifier.
    ///   - email: The user's email address.
    ///   - username: The user's display name.
    public func setUser(userId: String?, email: String? = nil, username: String? = nil) {
        queue.async { [weak self] in
            if let userId = userId {
                self?.userContext["userId"] = userId
            } else {
                self?.userContext.removeValue(forKey: "userId")
            }
            if let email = email {
                self?.userContext["email"] = email
            }
            if let username = username {
                self?.userContext["username"] = username
            }
        }
    }

    /// Clears user context.
    public func clearUser() {
        queue.async { [weak self] in
            self?.userContext.removeAll()
        }
    }

    // MARK: - Report Management

    /// Returns all stored crash reports.
    ///
    /// - Returns: Array of crash reports.
    public func getStoredReports() -> [CrashReport] {
        var reports: [CrashReport] = []

        queue.sync {
            let fileManager = FileManager.default
            guard let files = try? fileManager.contentsOfDirectory(
                at: storageDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: .skipsHiddenFiles
            ) else { return }

            for fileURL in files where fileURL.pathExtension == "json" {
                if let data = try? Data(contentsOf: fileURL),
                   let report = try? CrashReport.fromJSON(data) {
                    reports.append(report)
                }
            }
        }

        return reports.sorted { $0.timestamp > $1.timestamp }
    }

    /// Deletes a stored crash report.
    ///
    /// - Parameter reportId: The report ID to delete.
    public func deleteReport(_ reportId: UUID) {
        queue.async { [weak self] in
            guard let self = self else { return }
            let fileURL = self.storageDirectory.appendingPathComponent("\(reportId.uuidString).json")
            try? FileManager.default.removeItem(at: fileURL)
        }
    }

    /// Deletes all stored crash reports.
    public func deleteAllReports() {
        queue.async { [weak self] in
            guard let self = self else { return }
            let fileManager = FileManager.default
            if let files = try? fileManager.contentsOfDirectory(
                at: self.storageDirectory,
                includingPropertiesForKeys: nil
            ) {
                for file in files {
                    try? fileManager.removeItem(at: file)
                }
            }
        }
    }

    // MARK: - Manual Reporting

    /// Manually records a non-fatal error.
    ///
    /// - Parameters:
    ///   - error: The error to record.
    ///   - metadata: Additional metadata.
    public func recordError(_ error: Error, metadata: [String: String] = [:]) {
        let report = createReport(
            crashType: .custom,
            severity: .medium,
            exceptionType: String(describing: type(of: error)),
            exceptionMessage: error.localizedDescription,
            additionalMetadata: metadata
        )

        saveReport(report)
        logger.error("Recorded error: \(error.localizedDescription)")
    }

    /// Manually records a custom crash event.
    ///
    /// - Parameters:
    ///   - message: The crash message.
    ///   - metadata: Additional metadata.
    public func recordCrash(message: String, metadata: [String: String] = [:]) {
        let report = createReport(
            crashType: .custom,
            severity: .high,
            exceptionMessage: message,
            additionalMetadata: metadata
        )

        saveReport(report)
        logger.critical("Recorded crash: \(message)")
    }

    // MARK: - Private Helpers

    private func createStorageDirectoryIfNeeded() {
        let fileManager = FileManager.default
        if !fileManager.fileExists(atPath: storageDirectory.path) {
            try? fileManager.createDirectory(
                at: storageDirectory,
                withIntermediateDirectories: true
            )
        }
    }

    private func createReport(
        crashType: CrashType,
        severity: CrashSeverity,
        exceptionType: String? = nil,
        exceptionMessage: String? = nil,
        signalNumber: Int32? = nil,
        signalName: String? = nil,
        additionalMetadata: [String: String] = [:]
    ) -> CrashReport {
        var metadata = self.customMetadata
        for (key, value) in additionalMetadata {
            metadata[key] = value
        }
        for (key, value) in configuration.customMetadata {
            metadata[key] = value
        }

        let deviceInfo = configuration.collectDeviceInfo ? DeviceInfo.collect() : nil
        let appInfo = configuration.collectAppInfo ? AppInfo.collect(startTime: appStartTime) : nil

        return CrashReport(
            crashType: crashType,
            severity: severity,
            exceptionType: exceptionType,
            exceptionMessage: exceptionMessage,
            signalNumber: signalNumber,
            signalName: signalName,
            threads: captureThreads(),
            deviceInfo: deviceInfo,
            appInfo: appInfo,
            metadata: metadata,
            userContext: userContext,
            breadcrumbs: breadcrumbs
        )
    }

    private func captureThreads() -> [ThreadInfo] {
        let symbols = Thread.callStackSymbols
        let frames = symbols.enumerated().map { index, symbol in
            parseStackFrame(index: index, symbol: symbol)
        }

        return [
            ThreadInfo(
                threadNumber: 0,
                name: Thread.isMainThread ? "main" : nil,
                isCrashed: true,
                isMainThread: Thread.isMainThread,
                stackFrames: frames
            )
        ]
    }

    private func parseStackFrame(index: Int, symbol: String) -> StackFrame {
        let components = symbol.split(separator: " ", omittingEmptySubsequences: true)

        var imageName = "unknown"
        var address: UInt64 = 0
        var symbolName: String?

        if components.count >= 4 {
            imageName = String(components[1])

            if let addr = UInt64(String(components[2]).dropFirst(2), radix: 16) {
                address = addr
            }

            let remaining = components.dropFirst(3).joined(separator: " ")
            symbolName = remaining.isEmpty ? nil : remaining
        }

        return StackFrame(
            index: index,
            imageName: imageName,
            address: address,
            symbolName: symbolName
        )
    }

    private func saveReport(_ report: CrashReport) {
        queue.async { [weak self] in
            guard let self = self else { return }

            do {
                let data = try report.toJSON(prettyPrinted: true)
                let fileURL = self.storageDirectory.appendingPathComponent(
                    "\(report.id.uuidString).json"
                )
                try data.write(to: fileURL)
                self.cleanupOldReports()
                self.delegate?.crashReporterDidDetectCrash(report)
            } catch {
                self.logger.error("Failed to save crash report: \(error)")
            }
        }
    }

    private func cleanupOldReports() {
        let fileManager = FileManager.default
        guard let files = try? fileManager.contentsOfDirectory(
            at: storageDirectory,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        ) else { return }

        let jsonFiles = files.filter { $0.pathExtension == "json" }

        if jsonFiles.count > configuration.maxStoredReports {
            let sorted = jsonFiles.sorted { url1, url2 in
                let date1 = (try? url1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                let date2 = (try? url2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                return date1 < date2
            }

            let toDelete = sorted.prefix(jsonFiles.count - configuration.maxStoredReports)
            for file in toDelete {
                try? fileManager.removeItem(at: file)
            }
        }

        let cutoffDate = Calendar.current.date(
            byAdding: .day,
            value: -configuration.maxReportAgeDays,
            to: Date()
        )!

        for file in jsonFiles {
            if let values = try? file.resourceValues(forKeys: [.creationDateKey]),
               let date = values.creationDate,
               date < cutoffDate {
                try? fileManager.removeItem(at: file)
            }
        }
    }

    private func processPendingReports() {
        queue.async { [weak self] in
            self?.logger.debug("Checking for pending crash reports")
        }
    }

    // MARK: - Static Handlers

    private static func handleException(_ exception: NSException) {
        guard let reporter = current else { return }

        let symbols = exception.callStackSymbols.joined(separator: "\n")
        let message = "\(exception.reason ?? "Unknown reason")\n\nStack trace:\n\(symbols)"

        let report = reporter.createReport(
            crashType: .exception,
            severity: .critical,
            exceptionType: exception.name.rawValue,
            exceptionMessage: message
        )

        do {
            let data = try report.toJSON(prettyPrinted: true)
            let fileURL = reporter.storageDirectory.appendingPathComponent(
                "\(report.id.uuidString).json"
            )
            try data.write(to: fileURL)
        } catch {
            // Cannot use logger in crash handler safely
        }

        reporter.delegate?.crashReporterDidDetectCrash(report)
    }

    private static let signalHandler: @convention(c) (Int32) -> Void = { sig in
        guard let reporter = current else {
            signal(sig, SIG_DFL)
            raise(sig)
            return
        }

        let name = signalName(sig)

        let report = reporter.createReport(
            crashType: .signal,
            severity: .critical,
            signalNumber: sig,
            signalName: name
        )

        do {
            let data = try report.toJSON(prettyPrinted: true)
            let fileURL = reporter.storageDirectory.appendingPathComponent(
                "\(report.id.uuidString).json"
            )
            try data.write(to: fileURL)
        } catch {
            // Cannot use logger in crash handler safely
        }

        reporter.delegate?.crashReporterDidDetectCrash(report)

        signal(sig, SIG_DFL)
        raise(sig)
    }

    private static func signalName(_ sig: Int32) -> String {
        switch sig {
        case SIGABRT: return "SIGABRT"
        case SIGSEGV: return "SIGSEGV"
        case SIGBUS:  return "SIGBUS"
        case SIGFPE:  return "SIGFPE"
        case SIGILL:  return "SIGILL"
        case SIGTRAP: return "SIGTRAP"
        case SIGQUIT: return "SIGQUIT"
        case SIGSYS:  return "SIGSYS"
        default:      return "SIGNAL(\(sig))"
        }
    }
}
