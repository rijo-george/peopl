import AppKit
import Foundation

// MARK: - Data model (stored as data.json)

struct NamedDate: Codable, Identifiable, Hashable {
    var id: String
    var label: String
    var date: String
}

struct PersonField: Codable, Identifiable, Hashable {
    var id: String
    var label: String
    var value: String
    var icon: String  // SF Symbol name
}

struct Person: Codable, Identifiable, Hashable {
    var id: String
    var name: String
    var company: String
    var email: String
    var phone: String
    var tags: [String]
    var notes: String
    var birthday: String
    var dates: [NamedDate]
    var created_at: String
    var archived: Bool
    var details: [PersonField]

    var displayInitials: String {
        let parts = name.split(separator: " ")
        if parts.count >= 2 {
            return String(parts[0].prefix(1) + parts[1].prefix(1)).uppercased()
        }
        return String(name.prefix(2)).uppercased()
    }

    init(id: String, name: String, company: String, email: String, phone: String,
         tags: [String], notes: String, birthday: String, dates: [NamedDate],
         created_at: String, archived: Bool, details: [PersonField] = []) {
        self.id = id; self.name = name; self.company = company; self.email = email
        self.phone = phone; self.tags = tags; self.notes = notes; self.birthday = birthday
        self.dates = dates; self.created_at = created_at; self.archived = archived
        self.details = details
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(String.self, forKey: .id)
        name = try c.decode(String.self, forKey: .name)
        company = try c.decode(String.self, forKey: .company)
        email = try c.decode(String.self, forKey: .email)
        phone = try c.decode(String.self, forKey: .phone)
        tags = try c.decode([String].self, forKey: .tags)
        notes = try c.decode(String.self, forKey: .notes)
        birthday = try c.decode(String.self, forKey: .birthday)
        dates = try c.decode([NamedDate].self, forKey: .dates)
        created_at = try c.decode(String.self, forKey: .created_at)
        archived = try c.decode(Bool.self, forKey: .archived)
        details = try c.decodeIfPresent([PersonField].self, forKey: .details) ?? []
    }
}

// MARK: - Suggested detail fields

enum SuggestedField: String, CaseIterable {
    case location, food, music, movies, books, hobbies
    case pets, languages, socialMedia, relationship, howWeMet
    case allergies, workplace, school, nickname, zodiac
    case favoriteColor, sports, travel, drinks, restaurants

    var label: String {
        switch self {
        case .location:     return "Location"
        case .food:         return "Favorite Food"
        case .music:        return "Music"
        case .movies:       return "Movies"
        case .books:        return "Books"
        case .hobbies:      return "Hobbies"
        case .pets:         return "Pets"
        case .languages:    return "Languages"
        case .socialMedia:  return "Social Media"
        case .relationship: return "Relationship"
        case .howWeMet:     return "How We Met"
        case .allergies:    return "Allergies"
        case .workplace:    return "Workplace"
        case .school:       return "School"
        case .nickname:     return "Nickname"
        case .zodiac:       return "Zodiac Sign"
        case .favoriteColor:return "Favorite Color"
        case .sports:       return "Sports"
        case .travel:       return "Travel"
        case .drinks:       return "Drinks"
        case .restaurants:  return "Restaurants"
        }
    }

    var icon: String {
        switch self {
        case .location:     return "mappin.circle.fill"
        case .food:         return "fork.knife"
        case .music:        return "music.note"
        case .movies:       return "film.fill"
        case .books:        return "book.fill"
        case .hobbies:      return "star.fill"
        case .pets:         return "pawprint.fill"
        case .languages:    return "globe"
        case .socialMedia:  return "at"
        case .relationship: return "heart.fill"
        case .howWeMet:     return "figure.2"
        case .allergies:    return "exclamationmark.triangle.fill"
        case .workplace:    return "building.2.fill"
        case .school:       return "graduationcap.fill"
        case .nickname:     return "person.text.rectangle.fill"
        case .zodiac:       return "sparkles"
        case .favoriteColor:return "paintpalette.fill"
        case .sports:       return "sportscourt.fill"
        case .travel:       return "airplane"
        case .drinks:       return "cup.and.saucer.fill"
        case .restaurants:  return "menucard.fill"
        }
    }
}

struct Interaction: Codable, Identifiable, Hashable {
    var id: String
    var person_id: String
    var date: String
    var channel: String
    var note: String

    var dateDisplay: String {
        guard let d = ISO8601Flexible.date(from: date) else { return "-" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: d)
    }

    var shortDateDisplay: String {
        guard let d = ISO8601Flexible.date(from: date) else { return "-" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt.string(from: d)
    }
}

// MARK: - Memory

struct Memory: Codable, Identifiable, Hashable {
    var id: String
    var person_id: String
    var type: String            // "text", "voice", "image"
    var text: String            // content for text, caption for voice/image
    var media_filename: String  // "memories/abc.m4a" or ".jpg", empty for text
    var created_at: String
    var color: String           // "yellow", "pink", "blue", "green", "plain"

    var relativeTime: String {
        guard let d = ISO8601Flexible.date(from: created_at) else { return "" }
        let seconds = Date().timeIntervalSince(d)
        if seconds < 60 { return "just now" }
        if seconds < 3600 { return "\(Int(seconds / 60))m ago" }
        if seconds < 86400 { return "\(Int(seconds / 3600))h ago" }
        let days = Int(seconds / 86400)
        if days == 1 { return "yesterday" }
        if days < 30 { return "\(days)d ago" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d"
        return fmt.string(from: d)
    }

    var dateDisplay: String {
        guard let d = ISO8601Flexible.date(from: created_at) else { return "-" }
        let fmt = DateFormatter()
        fmt.dateFormat = "MMM d, yyyy"
        return fmt.string(from: d)
    }
}

// MARK: - Top-level data container

struct PeoplData: Codable {
    var people: [Person]
    var interactions: [Interaction]
    var memories: [Memory]

    init(people: [Person] = [], interactions: [Interaction] = [], memories: [Memory] = []) {
        self.people = people
        self.interactions = interactions
        self.memories = memories
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        people = try container.decode([Person].self, forKey: .people)
        interactions = try container.decode([Interaction].self, forKey: .interactions)
        memories = try container.decodeIfPresent([Memory].self, forKey: .memories) ?? []
    }
}

// MARK: - Channel helpers

enum Channel: String, CaseIterable, Identifiable {
    case coffee, call, email, text, meeting, other

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .coffee:  return "Coffee"
        case .call:    return "Call"
        case .email:   return "Email"
        case .text:    return "Text"
        case .meeting: return "Meeting"
        case .other:   return "Other"
        }
    }

    var icon: String {
        switch self {
        case .coffee:  return "cup.and.saucer.fill"
        case .call:    return "phone.fill"
        case .email:   return "envelope.fill"
        case .text:    return "message.fill"
        case .meeting: return "person.2.fill"
        case .other:   return "ellipsis.circle.fill"
        }
    }

    static func from(_ string: String) -> Channel {
        Channel(rawValue: string) ?? .other
    }
}

// MARK: - Relationship Weather

enum Weather: Comparable {
    case sunny, partlyCloudy, cloudy, rainy, stormy

    var icon: String {
        switch self {
        case .sunny:        return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy:       return "cloud.fill"
        case .rainy:        return "cloud.rain.fill"
        case .stormy:       return "cloud.bolt.fill"
        }
    }

    var label: String {
        switch self {
        case .sunny:        return "Sunny"
        case .partlyCloudy: return "Partly Cloudy"
        case .cloudy:       return "Cloudy"
        case .rainy:        return "Rainy"
        case .stormy:       return "Stormy"
        }
    }

    var colorRGB: (r: Double, g: Double, b: Double) {
        switch self {
        case .sunny:        return (1.00, 0.85, 0.20)
        case .partlyCloudy: return (0.70, 0.70, 0.60)
        case .cloudy:       return (0.55, 0.60, 0.70)
        case .rainy:        return (0.30, 0.55, 0.85)
        case .stormy:       return (0.55, 0.30, 0.75)
        }
    }

    static func from(daysSinceLastInteraction days: Int?) -> Weather {
        guard let days else { return .stormy }
        if days <= 14 { return .sunny }
        if days <= 30 { return .partlyCloudy }
        if days <= 60 { return .cloudy }
        if days <= 90 { return .rainy }
        return .stormy
    }
}

// MARK: - Memory color helpers

enum MemoryColor: String, CaseIterable, Identifiable {
    case yellow, pink, blue, green, plain

    var id: String { rawValue }

    var displayColor: (r: Double, g: Double, b: Double, a: Double) {
        switch self {
        case .yellow: return (1.00, 0.95, 0.75, 0.6)
        case .pink:   return (1.00, 0.85, 0.88, 0.6)
        case .blue:   return (0.82, 0.90, 1.00, 0.6)
        case .green:  return (0.85, 0.96, 0.85, 0.6)
        case .plain:  return (0.0, 0.0, 0.0, 0.0)
        }
    }
}

// MARK: - Upcoming dates helper

struct UpcomingEvent: Identifiable {
    var id: String { "\(personID)-\(label)-\(monthDay)" }
    var personID: String
    var personName: String
    var label: String
    var monthDay: String
    var daysUntil: Int
    var isBirthday: Bool
}

// MARK: - Stable random from ID

func stableRandom(from id: String, range: ClosedRange<Double> = -2.0...2.0) -> Double {
    let hash = abs(id.hashValue)
    let normalized = Double(hash % 10000) / 10000.0
    return range.lowerBound + normalized * (range.upperBound - range.lowerBound)
}

// MARK: - Flexible ISO parser

enum ISO8601Flexible {
    private static let fullFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    private static let basicFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    private static let dateOnly: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func date(from string: String) -> Date? {
        let cleaned = string.count > 26 ? String(string.prefix(26)) : string
        if let d = fullFormatter.date(from: cleaned + "+00:00") { return d }
        if let d = fullFormatter.date(from: string + "+00:00") { return d }
        if let d = basicFormatter.date(from: string + "+00:00") { return d }
        if let d = basicFormatter.date(from: string) { return d }
        if let d = dateOnly.date(from: string) { return d }
        let df = DateFormatter()
        df.locale = Locale(identifier: "en_US_POSIX")
        for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS", "yyyy-MM-dd'T'HH:mm:ss.SSS", "yyyy-MM-dd'T'HH:mm:ss", "yyyy-MM-dd"] {
            df.dateFormat = fmt
            if let d = df.date(from: string) { return d }
        }
        return nil
    }
}

// MARK: - Storage location (iCloud Drive with local fallback)

enum StorageLocation {
    static let iCloudDir: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home
            .appendingPathComponent("Library/Mobile Documents/iCloud~com~rijo~peopl")
            .appendingPathComponent("Documents")
    }()

    static let localDir: URL = {
        let home = FileManager.default.homeDirectoryForCurrentUser
        return home.appendingPathComponent(".peopl")
    }()

    static func resolve() -> URL {
        let fm = FileManager.default
        let iCloudRoot = fm.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Mobile Documents")
        let iCloudAvailable = fm.fileExists(atPath: iCloudRoot.path)

        if iCloudAvailable {
            try? fm.createDirectory(at: iCloudDir, withIntermediateDirectories: true)
            setupSymlink(fm: fm, target: iCloudDir)
            return iCloudDir
        }

        try? fm.createDirectory(at: localDir, withIntermediateDirectories: true)
        return localDir
    }

    private static func setupSymlink(fm: FileManager, target: URL) {
        let linkPath = localDir.path
        let targetPath = target.path
        if let dest = try? fm.destinationOfSymbolicLink(atPath: linkPath), dest == targetPath { return }
        if fm.fileExists(atPath: linkPath) {
            let attrs = try? fm.attributesOfItem(atPath: linkPath)
            if attrs?[.type] as? FileAttributeType == .typeSymbolicLink {
                try? fm.removeItem(atPath: linkPath)
            }
        }
        if !fm.fileExists(atPath: linkPath) {
            try? fm.createSymbolicLink(atPath: linkPath, withDestinationPath: targetPath)
        }
    }
}

// MARK: - Store

class PeoplStore: ObservableObject {
    @Published var data: PeoplData

    let dataDir: URL
    private let dataFile: URL
    private var fileMonitor: DispatchSourceFileSystemObject?
    private var fileDescriptor: Int32 = -1

    var memoriesDir: URL { dataDir.appendingPathComponent("memories") }

    init() {
        dataDir = StorageLocation.resolve()
        dataFile = dataDir.appendingPathComponent("data.json")
        data = PeoplData()
        try? FileManager.default.createDirectory(at: dataDir.appendingPathComponent("memories"),
                                                  withIntermediateDirectories: true)
        coordinatedLoad()
        startFileMonitor()

        NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main
        ) { [weak self] _ in
            self?.coordinatedLoad()
        }
    }

    deinit {
        fileMonitor?.cancel()
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Coordinated Load / Save

    func load() { coordinatedLoad() }

    func coordinatedLoad() {
        try? FileManager.default.createDirectory(at: dataDir, withIntermediateDirectories: true)
        let coordinator = NSFileCoordinator()
        var coordError: NSError?
        var needsSave = false
        coordinator.coordinate(readingItemAt: dataFile, options: [], error: &coordError) { url in
            guard let raw = try? Data(contentsOf: url),
                  let disk = try? JSONDecoder().decode(PeoplData.self, from: raw)
            else { return }
            let merged = Self.merge(local: self.data, remote: disk)
            needsSave = !Self.dataEqual(merged, disk)
            DispatchQueue.main.async {
                self.data = merged
            }
        }
        if needsSave { save() }
    }

    func save() {
        let coordinator = NSFileCoordinator()
        var coordError: NSError?
        coordinator.coordinate(readingItemAt: dataFile, options: [],
                               writingItemAt: dataFile, options: .forReplacing,
                               error: &coordError) { readURL, writeURL in
            var merged = self.data
            if let raw = try? Data(contentsOf: readURL),
               let disk = try? JSONDecoder().decode(PeoplData.self, from: raw) {
                merged = Self.merge(local: self.data, remote: disk)
            }
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            guard let raw = try? encoder.encode(merged) else { return }
            try? raw.write(to: writeURL, options: .atomic)
            DispatchQueue.main.async {
                self.data = merged
            }
        }
    }

    // MARK: - Merge logic

    private static func merge(local: PeoplData, remote: PeoplData) -> PeoplData {
        PeoplData(
            people: mergeByID(local: local.people, remote: remote.people),
            interactions: mergeByID(local: local.interactions, remote: remote.interactions),
            memories: mergeByID(local: local.memories, remote: remote.memories)
        )
    }

    private static func mergeByID<T: Identifiable & Codable>(local: [T], remote: [T]) -> [T] where T.ID == String {
        var byID: [String: T] = [:]
        for item in remote { byID[item.id] = item }
        for item in local { byID[item.id] = item }
        var result: [T] = []
        var seen = Set<String>()
        for item in local {
            if seen.insert(item.id).inserted { result.append(byID[item.id]!) }
        }
        for item in remote {
            if seen.insert(item.id).inserted { result.append(byID[item.id]!) }
        }
        return result
    }

    private static func dataEqual(_ a: PeoplData, _ b: PeoplData) -> Bool {
        let ids = { (d: PeoplData) in
            Set(d.people.map(\.id) + d.interactions.map(\.id) + d.memories.map(\.id))
        }
        return ids(a) == ids(b)
    }

    // MARK: - File monitoring

    private func startFileMonitor() {
        fileMonitor?.cancel()
        fileMonitor = nil
        let fd = open(dataFile.path, O_EVTONLY)
        guard fd >= 0 else { return }
        fileDescriptor = fd
        let source = DispatchSource.makeFileSystemObjectSource(
            fileDescriptor: fd, eventMask: [.write, .rename], queue: .main)
        source.setEventHandler { [weak self] in
            guard let self else { return }
            self.coordinatedLoad()
            self.startFileMonitor()
        }
        source.setCancelHandler { close(fd) }
        source.resume()
        fileMonitor = source
    }

    // MARK: - Person actions

    func addPerson(name: String, company: String, email: String, phone: String,
                   tags: [String], notes: String, birthday: String, dates: [NamedDate]) {
        let person = Person(
            id: UUID().uuidString, name: name, company: company, email: email, phone: phone,
            tags: tags, notes: notes, birthday: birthday, dates: dates,
            created_at: pythonISO(), archived: false
        )
        data.people.append(person)
        save()
    }

    func updatePerson(_ person: Person) {
        if let idx = data.people.firstIndex(where: { $0.id == person.id }) {
            data.people[idx] = person
            save()
        }
    }

    func archivePerson(_ person: Person) {
        if let idx = data.people.firstIndex(where: { $0.id == person.id }) {
            data.people[idx].archived = true
            save()
        }
    }

    func unarchivePerson(_ person: Person) {
        if let idx = data.people.firstIndex(where: { $0.id == person.id }) {
            data.people[idx].archived = false
            save()
        }
    }

    // MARK: - Interaction actions

    func addInteraction(personID: String, channel: String, note: String, date: Date = Date()) {
        let interaction = Interaction(
            id: UUID().uuidString, person_id: personID,
            date: pythonISO(date), channel: channel, note: note
        )
        data.interactions.append(interaction)
        save()
    }

    func deleteInteraction(_ interaction: Interaction) {
        data.interactions.removeAll { $0.id == interaction.id }
        save()
    }

    // MARK: - Memory actions

    func addTextMemory(personID: String, text: String, color: String) {
        let memory = Memory(
            id: UUID().uuidString, person_id: personID, type: "text",
            text: text, media_filename: "", created_at: pythonISO(), color: color
        )
        data.memories.append(memory)
        save()
    }

    func saveImageMemory(personID: String, image: NSImage, caption: String, color: String) {
        let memID = UUID().uuidString
        let filename = "memories/\(memID).jpg"
        let fileURL = dataDir.appendingPathComponent(filename)

        guard let tiffData = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiffData),
              let jpegData = rep.representation(using: .jpeg, properties: [.compressionFactor: 0.85])
        else { return }

        try? jpegData.write(to: fileURL, options: .atomic)

        let memory = Memory(
            id: memID, person_id: personID, type: "image",
            text: caption, media_filename: filename, created_at: pythonISO(), color: color
        )
        data.memories.append(memory)
        save()
    }

    func saveVoiceMemory(personID: String, audioURL: URL, caption: String, color: String) {
        let memID = UUID().uuidString
        let filename = "memories/\(memID).m4a"
        let destURL = dataDir.appendingPathComponent(filename)

        try? FileManager.default.copyItem(at: audioURL, to: destURL)

        let memory = Memory(
            id: memID, person_id: personID, type: "voice",
            text: caption, media_filename: filename, created_at: pythonISO(), color: color
        )
        data.memories.append(memory)
        save()
    }

    func deleteMemory(_ memory: Memory) {
        if !memory.media_filename.isEmpty {
            let fileURL = dataDir.appendingPathComponent(memory.media_filename)
            try? FileManager.default.removeItem(at: fileURL)
        }
        data.memories.removeAll { $0.id == memory.id }
        save()
    }

    func mediaURL(for memory: Memory) -> URL? {
        guard !memory.media_filename.isEmpty else { return nil }
        let url = dataDir.appendingPathComponent(memory.media_filename)
        return FileManager.default.fileExists(atPath: url.path) ? url : nil
    }

    // MARK: - Queries

    func memories(for personID: String) -> [Memory] {
        data.memories
            .filter { $0.person_id == personID }
            .sorted { $0.created_at > $1.created_at }
    }

    func latestMemorySnippet(for personID: String) -> String? {
        let mems = memories(for: personID)
        if let textMem = mems.first(where: { $0.type == "text" }) {
            return String(textMem.text.prefix(80))
        }
        if let captionMem = mems.first(where: { !$0.text.isEmpty }) {
            return String(captionMem.text.prefix(80))
        }
        return nil
    }

    func interactions(for personID: String) -> [Interaction] {
        data.interactions
            .filter { $0.person_id == personID }
            .sorted { $0.date > $1.date }
    }

    func lastInteraction(for personID: String) -> Interaction? {
        interactions(for: personID).first
    }

    func daysSinceLastInteraction(for personID: String) -> Int? {
        guard let last = lastInteraction(for: personID),
              let d = ISO8601Flexible.date(from: last.date) else { return nil }
        return Calendar.current.dateComponents([.day], from: d, to: Date()).day
    }

    func weather(for personID: String) -> Weather {
        Weather.from(daysSinceLastInteraction: daysSinceLastInteraction(for: personID))
    }

    var activePeople: [Person] {
        data.people.filter { !$0.archived }
    }

    var archivedPeople: [Person] {
        data.people.filter { $0.archived }
    }

    // MARK: - Upcoming events

    func upcomingEvents(withinDays: Int = 14) -> [UpcomingEvent] {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let todayComponents = cal.dateComponents([.month, .day], from: today)
        let todayDayOfYear = cal.ordinality(of: .day, in: .year, for: today) ?? 1
        let daysInYear = cal.range(of: .day, in: .year, for: today)?.count ?? 365

        var events: [UpcomingEvent] = []
        for person in activePeople {
            if !person.birthday.isEmpty, let md = parseMonthDay(person.birthday) {
                if let daysUntil = daysUntilDate(month: md.month, day: md.day,
                                                   todayComponents: todayComponents,
                                                   todayDayOfYear: todayDayOfYear,
                                                   daysInYear: daysInYear),
                   daysUntil <= withinDays {
                    events.append(UpcomingEvent(
                        personID: person.id, personName: person.name,
                        label: "Birthday", monthDay: person.birthday,
                        daysUntil: daysUntil, isBirthday: true
                    ))
                }
            }
            for nd in person.dates {
                if let md = parseMonthDay(nd.date),
                   let daysUntil = daysUntilDate(month: md.month, day: md.day,
                                                   todayComponents: todayComponents,
                                                   todayDayOfYear: todayDayOfYear,
                                                   daysInYear: daysInYear),
                   daysUntil <= withinDays {
                    events.append(UpcomingEvent(
                        personID: person.id, personName: person.name,
                        label: nd.label, monthDay: nd.date,
                        daysUntil: daysUntil, isBirthday: false
                    ))
                }
            }
        }
        return events.sorted { $0.daysUntil < $1.daysUntil }
    }

    private func parseMonthDay(_ string: String) -> (month: Int, day: Int)? {
        let parts = string.split(separator: "-")
        if parts.count == 2, let m = Int(parts[0]), let d = Int(parts[1]) { return (m, d) }
        if parts.count == 3, let m = Int(parts[1]), let d = Int(parts[2]) { return (m, d) }
        return nil
    }

    private func daysUntilDate(month: Int, day: Int,
                                todayComponents: DateComponents,
                                todayDayOfYear: Int,
                                daysInYear: Int) -> Int? {
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        var comps = DateComponents()
        comps.year = cal.component(.year, from: today)
        comps.month = month
        comps.day = day
        guard let targetThisYear = cal.date(from: comps) else { return nil }
        let targetDay = cal.ordinality(of: .day, in: .year, for: targetThisYear) ?? 1
        var diff = targetDay - todayDayOfYear
        if diff < 0 { diff += daysInYear }
        return diff
    }

    // MARK: - Nudge & Surfacing

    func nudgePerson() -> (person: Person, daysSince: Int, lastSnippet: String?)? {
        let candidates: [(Person, Int, Double)] = activePeople.compactMap { person in
            guard let days = daysSinceLastInteraction(for: person.id), days >= 7 else { return nil }
            let interactionCount = Double(interactions(for: person.id).count)
            let memoryCount = Double(memories(for: person.id).count)
            let score = Double(days) * sqrt(interactionCount + memoryCount + 1)
            return (person, days, score)
        }
        guard let best = candidates.max(by: { $0.2 < $1.2 }) else { return nil }
        let snippet: String? = latestMemorySnippet(for: best.0.id)
            ?? lastInteraction(for: best.0.id).map { String($0.note.prefix(80)) }
        return (person: best.0, daysSince: best.1, lastSnippet: snippet)
    }

    func surfaceMemory() -> (memory: Memory, person: Person, timeAgo: String)? {
        let cal = Calendar.current
        let todaySeed = cal.startOfDay(for: Date()).hashValue
        var rng = SeededRNG(seed: UInt64(bitPattern: Int64(todaySeed)))

        // 60% chance of returning nil
        guard Double.random(in: 0...1, using: &rng) < 0.4 else { return nil }

        let thirtyDaysAgo = cal.date(byAdding: .day, value: -30, to: Date())!
        let oldMemories = data.memories.filter { mem in
            guard let d = ISO8601Flexible.date(from: mem.created_at) else { return false }
            return d < thirtyDaysAgo
        }
        guard !oldMemories.isEmpty else { return nil }

        let idx = Int.random(in: 0..<oldMemories.count, using: &rng)
        let memory = oldMemories[idx]
        guard let person = data.people.first(where: { $0.id == memory.person_id }),
              let memDate = ISO8601Flexible.date(from: memory.created_at) else { return nil }

        let components = cal.dateComponents([.year, .month], from: memDate, to: Date())
        let timeAgo: String
        if let years = components.year, years >= 1 {
            timeAgo = years == 1 ? "1 year ago" : "\(years) years ago"
        } else if let months = components.month, months >= 1 {
            timeAgo = months == 1 ? "1 month ago" : "\(months) months ago"
        } else {
            timeAgo = "a while ago"
        }

        return (memory: memory, person: person, timeAgo: timeAgo)
    }

    func fuzzyMatchPerson(query: String) -> Person? {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return nil }
        // Prefix match
        if let match = activePeople.first(where: { $0.name.lowercased().hasPrefix(q) }) { return match }
        // Substring match
        if let match = activePeople.first(where: { $0.name.lowercased().contains(q) }) { return match }
        // First name match
        if let match = activePeople.first(where: {
            $0.name.split(separator: " ").first?.lowercased().hasPrefix(q) == true
        }) { return match }
        return nil
    }

    func parseQuickCapture(input: String) -> (personQuery: String?, text: String) {
        if let range = input.range(of: " - ") {
            let personQuery = String(input[input.startIndex..<range.lowerBound])
            let text = String(input[range.upperBound...])
            return (personQuery.isEmpty ? nil : personQuery, text)
        }
        return (nil, input)
    }

    // MARK: - Unified Timeline

    enum TimelineItem: Identifiable {
        case memory(Memory)
        case interaction(Interaction)

        var id: String {
            switch self {
            case .memory(let m): return "mem-\(m.id)"
            case .interaction(let i): return "int-\(i.id)"
            }
        }

        var sortDate: Date {
            switch self {
            case .memory(let m): return ISO8601Flexible.date(from: m.created_at) ?? Date.distantPast
            case .interaction(let i): return ISO8601Flexible.date(from: i.date) ?? Date.distantPast
            }
        }
    }

    func interleaveTimeline(for personID: String) -> [TimelineItem] {
        let mems = memories(for: personID).map { TimelineItem.memory($0) }
        let ints = interactions(for: personID).map { TimelineItem.interaction($0) }
        return (mems + ints).sorted { $0.sortDate > $1.sortDate }
    }

    // MARK: Helpers

    func pythonISO(_ date: Date = Date()) -> String {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        return f.string(from: date)
    }
}

// MARK: - Seeded RNG for deterministic daily randomness

struct SeededRNG: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
}
