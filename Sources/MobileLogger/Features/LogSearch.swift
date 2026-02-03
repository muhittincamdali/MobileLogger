import Foundation

// MARK: - Log Search

/// A powerful search engine for querying and filtering log entries.
///
/// `LogSearch` provides full-text search, filtering, and query capabilities
/// for log entries with support for complex queries, regular expressions,
/// and field-specific searches.
///
/// ## Usage
///
/// ```swift
/// let search = LogSearch()
/// search.index(entries)
///
/// let results = search.search("error database", options: .init(
///     levels: [.error, .critical],
///     startDate: Date().addingTimeInterval(-3600)
/// ))
/// ```
public final class LogSearch: @unchecked Sendable {
    
    // MARK: - Search Options
    
    /// Options for configuring search behavior.
    public struct SearchOptions: Sendable {
        /// Log levels to include.
        public var levels: Set<LogLevel>?
        
        /// Start date filter.
        public var startDate: Date?
        
        /// End date filter.
        public var endDate: Date?
        
        /// Source file filter.
        public var sourceFiles: Set<String>?
        
        /// Function name filter.
        public var functions: Set<String>?
        
        /// Metadata key-value filters.
        public var metadata: [String: String]?
        
        /// Case-sensitive search.
        public var caseSensitive: Bool
        
        /// Use regular expressions.
        public var useRegex: Bool
        
        /// Maximum results to return.
        public var limit: Int?
        
        /// Offset for pagination.
        public var offset: Int
        
        /// Sort order.
        public var sortOrder: SortOrder
        
        /// Sort field.
        public var sortBy: SortField
        
        /// Highlight matching text.
        public var highlight: Bool
        
        /// Highlight prefix.
        public var highlightPrefix: String
        
        /// Highlight suffix.
        public var highlightSuffix: String
        
        /// Sort order options.
        public enum SortOrder: Sendable {
            case ascending
            case descending
        }
        
        /// Sort field options.
        public enum SortField: Sendable {
            case timestamp
            case level
            case message
            case relevance
        }
        
        /// Creates search options with default values.
        public init(
            levels: Set<LogLevel>? = nil,
            startDate: Date? = nil,
            endDate: Date? = nil,
            sourceFiles: Set<String>? = nil,
            functions: Set<String>? = nil,
            metadata: [String: String]? = nil,
            caseSensitive: Bool = false,
            useRegex: Bool = false,
            limit: Int? = nil,
            offset: Int = 0,
            sortOrder: SortOrder = .descending,
            sortBy: SortField = .timestamp,
            highlight: Bool = true,
            highlightPrefix: String = "**",
            highlightSuffix: String = "**"
        ) {
            self.levels = levels
            self.startDate = startDate
            self.endDate = endDate
            self.sourceFiles = sourceFiles
            self.functions = functions
            self.metadata = metadata
            self.caseSensitive = caseSensitive
            self.useRegex = useRegex
            self.limit = limit
            self.offset = offset
            self.sortOrder = sortOrder
            self.sortBy = sortBy
            self.highlight = highlight
            self.highlightPrefix = highlightPrefix
            self.highlightSuffix = highlightSuffix
        }
    }
    
    // MARK: - Search Result
    
    /// A search result containing matched entries and metadata.
    public struct SearchResult: Sendable {
        /// Matched log entries.
        public let entries: [MatchedEntry]
        
        /// Total count of matches (before pagination).
        public let totalCount: Int
        
        /// Search execution time in seconds.
        public let executionTime: TimeInterval
        
        /// The query that was executed.
        public let query: String
        
        /// Facets for result filtering.
        public let facets: Facets
        
        /// A matched entry with relevance score.
        public struct MatchedEntry: Sendable, Identifiable {
            /// The original log entry.
            public let entry: LogEntry
            
            /// Relevance score (0.0 to 1.0).
            public let score: Double
            
            /// Highlighted message with matches marked.
            public let highlightedMessage: String?
            
            /// Matched terms in the message.
            public let matchedTerms: [String]
            
            /// Unique identifier.
            public var id: UUID { entry.id }
        }
        
        /// Facets for filtering.
        public struct Facets: Sendable {
            /// Count by log level.
            public let levelCounts: [LogLevel: Int]
            
            /// Count by source file.
            public let sourceCounts: [String: Int]
            
            /// Count by hour.
            public let hourCounts: [Int: Int]
            
            /// Metadata key counts.
            public let metadataCounts: [String: Int]
        }
    }
    
    // MARK: - Query
    
    /// A parsed query with structured components.
    public struct Query: Sendable {
        /// Raw query string.
        public let raw: String
        
        /// Parsed terms.
        public let terms: [Term]
        
        /// Field-specific filters.
        public let fieldFilters: [FieldFilter]
        
        /// A search term.
        public struct Term: Sendable {
            /// The term text.
            public let text: String
            
            /// Whether this is a required term (+term).
            public let required: Bool
            
            /// Whether this is an excluded term (-term).
            public let excluded: Bool
            
            /// Whether this is a phrase ("exact phrase").
            public let isPhrase: Bool
        }
        
        /// A field-specific filter.
        public struct FieldFilter: Sendable {
            /// Field name.
            public let field: String
            
            /// Comparison operator.
            public let op: Operator
            
            /// Filter value.
            public let value: String
            
            /// Comparison operators.
            public enum Operator: Sendable {
                case equals
                case notEquals
                case contains
                case greaterThan
                case lessThan
                case greaterOrEqual
                case lessOrEqual
            }
        }
    }
    
    // MARK: - Saved Search
    
    /// A saved search query for reuse.
    public struct SavedSearch: Codable, Sendable, Identifiable {
        /// Unique identifier.
        public let id: UUID
        
        /// Display name.
        public var name: String
        
        /// Query string.
        public var query: String
        
        /// Search options serialized.
        public var optionsData: Data?
        
        /// Creation timestamp.
        public let createdAt: Date
        
        /// Last used timestamp.
        public var lastUsedAt: Date
        
        /// Usage count.
        public var usageCount: Int
        
        /// Creates a new saved search.
        public init(name: String, query: String) {
            self.id = UUID()
            self.name = name
            self.query = query
            self.optionsData = nil
            self.createdAt = Date()
            self.lastUsedAt = Date()
            self.usageCount = 0
        }
    }
    
    // MARK: - Properties
    
    /// Indexed log entries.
    private var entries: [LogEntry] = []
    
    /// Inverted index for fast term lookup.
    private var invertedIndex: [String: Set<UUID>] = [:]
    
    /// Saved searches.
    private var savedSearches: [UUID: SavedSearch] = [:]
    
    /// Search history.
    private var searchHistory: [SearchHistoryItem] = []
    
    /// Serial queue for thread safety.
    private let queue: DispatchQueue
    
    /// Maximum history items to keep.
    private let maxHistoryItems: Int
    
    /// Search history item.
    private struct SearchHistoryItem {
        let query: String
        let timestamp: Date
        let resultCount: Int
    }
    
    // MARK: - Initialization
    
    /// Creates a new log search instance.
    ///
    /// - Parameter maxHistoryItems: Maximum search history items to keep.
    public init(maxHistoryItems: Int = 100) {
        self.maxHistoryItems = maxHistoryItems
        self.queue = DispatchQueue(
            label: "com.mobilelogger.search",
            qos: .userInitiated
        )
    }
    
    // MARK: - Indexing
    
    /// Indexes log entries for searching.
    ///
    /// - Parameter entries: Entries to index.
    public func index(_ entries: [LogEntry]) {
        queue.async { [weak self] in
            for entry in entries {
                self?.indexEntry(entry)
            }
        }
    }
    
    /// Indexes a single log entry.
    ///
    /// - Parameter entry: Entry to index.
    public func index(_ entry: LogEntry) {
        queue.async { [weak self] in
            self?.indexEntry(entry)
        }
    }
    
    /// Clears the search index.
    public func clearIndex() {
        queue.async { [weak self] in
            self?.entries.removeAll()
            self?.invertedIndex.removeAll()
        }
    }
    
    /// Returns the number of indexed entries.
    public var indexedCount: Int {
        queue.sync { entries.count }
    }
    
    // MARK: - Searching
    
    /// Performs a search with the given query and options.
    ///
    /// - Parameters:
    ///   - query: Search query string.
    ///   - options: Search options.
    /// - Returns: Search results.
    public func search(_ query: String, options: SearchOptions = SearchOptions()) -> SearchResult {
        queue.sync {
            let startTime = Date()
            
            let parsedQuery = parseQuery(query)
            var matchedEntries: [SearchResult.MatchedEntry] = []
            
            // Pre-filter using inverted index if possible
            var candidateIds: Set<UUID>?
            
            for term in parsedQuery.terms where !term.excluded {
                let termLower = term.text.lowercased()
                
                if let ids = invertedIndex[termLower] {
                    if candidateIds == nil {
                        candidateIds = ids
                    } else if term.required {
                        candidateIds?.formIntersection(ids)
                    } else {
                        candidateIds?.formUnion(ids)
                    }
                }
            }
            
            // Search through entries
            let entriesToSearch: [LogEntry]
            if let ids = candidateIds {
                entriesToSearch = entries.filter { ids.contains($0.id) }
            } else if query.isEmpty {
                entriesToSearch = entries
            } else {
                entriesToSearch = entries
            }
            
            for entry in entriesToSearch {
                if let matched = matchEntry(entry, query: parsedQuery, options: options) {
                    matchedEntries.append(matched)
                }
            }
            
            // Sort results
            matchedEntries = sortResults(matchedEntries, options: options)
            
            // Calculate facets before pagination
            let facets = calculateFacets(matchedEntries)
            let totalCount = matchedEntries.count
            
            // Apply pagination
            if options.offset > 0 {
                matchedEntries = Array(matchedEntries.dropFirst(options.offset))
            }
            if let limit = options.limit {
                matchedEntries = Array(matchedEntries.prefix(limit))
            }
            
            let executionTime = Date().timeIntervalSince(startTime)
            
            // Record in history
            recordSearchHistory(query: query, resultCount: totalCount)
            
            return SearchResult(
                entries: matchedEntries,
                totalCount: totalCount,
                executionTime: executionTime,
                query: query,
                facets: facets
            )
        }
    }
    
    /// Performs an async search.
    ///
    /// - Parameters:
    ///   - query: Search query string.
    ///   - options: Search options.
    ///   - completion: Completion handler with results.
    public func searchAsync(
        _ query: String,
        options: SearchOptions = SearchOptions(),
        completion: @escaping (SearchResult) -> Void
    ) {
        queue.async { [weak self] in
            guard let self else { return }
            let result = self.search(query, options: options)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    /// Searches using a parsed query.
    ///
    /// - Parameters:
    ///   - query: Parsed query.
    ///   - options: Search options.
    /// - Returns: Search results.
    public func search(query: Query, options: SearchOptions = SearchOptions()) -> SearchResult {
        search(query.raw, options: options)
    }
    
    /// Parses a query string into a structured query.
    ///
    /// - Parameter queryString: Raw query string.
    /// - Returns: Parsed query.
    public func parseQuery(_ queryString: String) -> Query {
        var terms: [Query.Term] = []
        var fieldFilters: [Query.FieldFilter] = []
        
        // Parse the query string
        var remaining = queryString
        
        // Extract field filters (field:value or field:"value")
        let fieldPattern = #"(\w+):(["']?)([^"'\s]+)\2"#
        if let fieldRegex = try? NSRegularExpression(pattern: fieldPattern, options: []) {
            let matches = fieldRegex.matches(
                in: remaining,
                options: [],
                range: NSRange(remaining.startIndex..., in: remaining)
            )
            
            for match in matches.reversed() {
                if let fieldRange = Range(match.range(at: 1), in: remaining),
                   let valueRange = Range(match.range(at: 3), in: remaining) {
                    let field = String(remaining[fieldRange])
                    let value = String(remaining[valueRange])
                    
                    fieldFilters.append(Query.FieldFilter(
                        field: field,
                        op: .equals,
                        value: value
                    ))
                    
                    if let fullRange = Range(match.range, in: remaining) {
                        remaining.removeSubrange(fullRange)
                    }
                }
            }
        }
        
        // Extract quoted phrases
        let phrasePattern = #""([^"]+)""#
        if let phraseRegex = try? NSRegularExpression(pattern: phrasePattern, options: []) {
            let matches = phraseRegex.matches(
                in: remaining,
                options: [],
                range: NSRange(remaining.startIndex..., in: remaining)
            )
            
            for match in matches.reversed() {
                if let phraseRange = Range(match.range(at: 1), in: remaining) {
                    let phrase = String(remaining[phraseRange])
                    terms.append(Query.Term(
                        text: phrase,
                        required: false,
                        excluded: false,
                        isPhrase: true
                    ))
                    
                    if let fullRange = Range(match.range, in: remaining) {
                        remaining.removeSubrange(fullRange)
                    }
                }
            }
        }
        
        // Parse remaining terms
        let words = remaining.split(separator: " ")
        for word in words {
            let wordStr = String(word).trimmingCharacters(in: .whitespaces)
            guard !wordStr.isEmpty else { continue }
            
            var text = wordStr
            var required = false
            var excluded = false
            
            if text.hasPrefix("+") {
                required = true
                text = String(text.dropFirst())
            } else if text.hasPrefix("-") {
                excluded = true
                text = String(text.dropFirst())
            }
            
            guard !text.isEmpty else { continue }
            
            terms.append(Query.Term(
                text: text,
                required: required,
                excluded: excluded,
                isPhrase: false
            ))
        }
        
        return Query(raw: queryString, terms: terms, fieldFilters: fieldFilters)
    }
    
    // MARK: - Saved Searches
    
    /// Saves a search for later use.
    ///
    /// - Parameters:
    ///   - name: Display name.
    ///   - query: Search query.
    /// - Returns: The saved search.
    @discardableResult
    public func saveSearch(name: String, query: String) -> SavedSearch {
        let saved = SavedSearch(name: name, query: query)
        queue.async { [weak self] in
            self?.savedSearches[saved.id] = saved
        }
        return saved
    }
    
    /// Returns all saved searches.
    public var allSavedSearches: [SavedSearch] {
        queue.sync { Array(savedSearches.values) }
    }
    
    /// Deletes a saved search.
    ///
    /// - Parameter id: Search ID to delete.
    public func deleteSavedSearch(_ id: UUID) {
        queue.async { [weak self] in
            self?.savedSearches.removeValue(forKey: id)
        }
    }
    
    /// Executes a saved search.
    ///
    /// - Parameters:
    ///   - id: Saved search ID.
    ///   - options: Additional search options.
    /// - Returns: Search results or nil if not found.
    public func executeSavedSearch(_ id: UUID, options: SearchOptions = SearchOptions()) -> SearchResult? {
        guard var saved = queue.sync(execute: { savedSearches[id] }) else {
            return nil
        }
        
        saved.lastUsedAt = Date()
        saved.usageCount += 1
        
        queue.async { [weak self] in
            self?.savedSearches[id] = saved
        }
        
        return search(saved.query, options: options)
    }
    
    // MARK: - Search History
    
    /// Returns recent search history.
    ///
    /// - Parameter limit: Maximum items to return.
    /// - Returns: Array of recent queries.
    public func recentSearches(limit: Int = 10) -> [String] {
        queue.sync {
            Array(searchHistory.prefix(limit).map { $0.query })
        }
    }
    
    /// Clears search history.
    public func clearHistory() {
        queue.async { [weak self] in
            self?.searchHistory.removeAll()
        }
    }
    
    // MARK: - Suggestions
    
    /// Returns search suggestions based on input.
    ///
    /// - Parameter input: Partial query input.
    /// - Returns: Suggested completions.
    public func suggestions(for input: String) -> [String] {
        guard !input.isEmpty else { return [] }
        
        return queue.sync {
            var suggestions: [String] = []
            let inputLower = input.lowercased()
            
            // Suggest from history
            for item in searchHistory {
                if item.query.lowercased().hasPrefix(inputLower) &&
                   !suggestions.contains(item.query) {
                    suggestions.append(item.query)
                }
            }
            
            // Suggest from indexed terms
            let matchingTerms = invertedIndex.keys
                .filter { $0.hasPrefix(inputLower) }
                .sorted()
                .prefix(10)
            
            for term in matchingTerms {
                if !suggestions.contains(term) {
                    suggestions.append(term)
                }
            }
            
            return Array(suggestions.prefix(10))
        }
    }
    
    // MARK: - Private Methods
    
    private func indexEntry(_ entry: LogEntry) {
        entries.append(entry)
        
        // Tokenize and index message
        let tokens = tokenize(entry.message)
        for token in tokens {
            invertedIndex[token, default: Set()].insert(entry.id)
        }
        
        // Index metadata values
        if let metadata = entry.metadata {
            for value in metadata.values {
                let metaTokens = tokenize(value)
                for token in metaTokens {
                    invertedIndex[token, default: Set()].insert(entry.id)
                }
            }
        }
        
        // Index source file
        let fileName = (entry.file as NSString).lastPathComponent.lowercased()
        invertedIndex[fileName, default: Set()].insert(entry.id)
        
        // Index function name
        let funcName = entry.function.lowercased()
        invertedIndex[funcName, default: Set()].insert(entry.id)
    }
    
    private func tokenize(_ text: String) -> [String] {
        let lowercased = text.lowercased()
        
        // Split on non-alphanumeric characters
        let components = lowercased.components(separatedBy: CharacterSet.alphanumerics.inverted)
        
        return components
            .filter { !$0.isEmpty && $0.count >= 2 }
    }
    
    private func matchEntry(
        _ entry: LogEntry,
        query: Query,
        options: SearchOptions
    ) -> SearchResult.MatchedEntry? {
        // Apply filters
        if let levels = options.levels, !levels.contains(entry.level) {
            return nil
        }
        
        if let startDate = options.startDate, entry.timestamp < startDate {
            return nil
        }
        
        if let endDate = options.endDate, entry.timestamp > endDate {
            return nil
        }
        
        if let sources = options.sourceFiles {
            let fileName = (entry.file as NSString).lastPathComponent
            if !sources.contains(fileName) {
                return nil
            }
        }
        
        if let functions = options.functions {
            if !functions.contains(entry.function) {
                return nil
            }
        }
        
        if let metadataFilters = options.metadata {
            guard let entryMetadata = entry.metadata else {
                return nil
            }
            
            for (key, value) in metadataFilters {
                guard let entryValue = entryMetadata[key],
                      entryValue == value else {
                    return nil
                }
            }
        }
        
        // Apply field filters from query
        for filter in query.fieldFilters {
            if !matchFieldFilter(filter, entry: entry, options: options) {
                return nil
            }
        }
        
        // Check terms
        var matchedTerms: [String] = []
        var score: Double = 0.0
        let messageToSearch = options.caseSensitive ? entry.message : entry.message.lowercased()
        
        if query.terms.isEmpty {
            // No terms means match all (after filters)
            score = 1.0
        } else {
            for term in query.terms {
                let termText = options.caseSensitive ? term.text : term.text.lowercased()
                
                let matches: Bool
                if options.useRegex {
                    matches = matchesRegex(termText, in: messageToSearch)
                } else if term.isPhrase {
                    matches = messageToSearch.contains(termText)
                } else {
                    matches = messageToSearch.contains(termText)
                }
                
                if term.excluded {
                    if matches {
                        return nil // Excluded term found, no match
                    }
                } else if term.required {
                    if !matches {
                        return nil // Required term not found, no match
                    } else {
                        matchedTerms.append(term.text)
                        score += 1.0
                    }
                } else {
                    if matches {
                        matchedTerms.append(term.text)
                        score += 0.5
                    }
                }
            }
            
            // Normalize score
            let maxScore = Double(query.terms.filter { !$0.excluded }.count)
            score = maxScore > 0 ? score / maxScore : 0
        }
        
        // Must have at least one match (unless no terms)
        if !query.terms.isEmpty && matchedTerms.isEmpty {
            return nil
        }
        
        // Apply score boost for level
        if entry.level >= .error {
            score *= 1.2
        }
        
        // Clamp score
        score = min(1.0, score)
        
        // Highlight matches
        var highlightedMessage: String? = nil
        if options.highlight && !matchedTerms.isEmpty {
            highlightedMessage = highlightMatches(
                in: entry.message,
                terms: matchedTerms,
                prefix: options.highlightPrefix,
                suffix: options.highlightSuffix,
                caseSensitive: options.caseSensitive
            )
        }
        
        return SearchResult.MatchedEntry(
            entry: entry,
            score: score,
            highlightedMessage: highlightedMessage,
            matchedTerms: matchedTerms
        )
    }
    
    private func matchFieldFilter(
        _ filter: Query.FieldFilter,
        entry: LogEntry,
        options: SearchOptions
    ) -> Bool {
        let compareValue: String?
        
        switch filter.field.lowercased() {
        case "level":
            compareValue = entry.level.rawValue
        case "file", "source":
            compareValue = (entry.file as NSString).lastPathComponent
        case "function", "func":
            compareValue = entry.function
        case "line":
            compareValue = String(entry.line)
        default:
            // Check metadata
            compareValue = entry.metadata?[filter.field]
        }
        
        guard let value = compareValue else { return false }
        
        let filterValue = options.caseSensitive ? filter.value : filter.value.lowercased()
        let actualValue = options.caseSensitive ? value : value.lowercased()
        
        switch filter.op {
        case .equals:
            return actualValue == filterValue
        case .notEquals:
            return actualValue != filterValue
        case .contains:
            return actualValue.contains(filterValue)
        case .greaterThan:
            return actualValue > filterValue
        case .lessThan:
            return actualValue < filterValue
        case .greaterOrEqual:
            return actualValue >= filterValue
        case .lessOrEqual:
            return actualValue <= filterValue
        }
    }
    
    private func matchesRegex(_ pattern: String, in text: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        
        let range = NSRange(text.startIndex..., in: text)
        return regex.firstMatch(in: text, options: [], range: range) != nil
    }
    
    private func highlightMatches(
        in text: String,
        terms: [String],
        prefix: String,
        suffix: String,
        caseSensitive: Bool
    ) -> String {
        var result = text
        
        for term in terms.sorted(by: { $0.count > $1.count }) {
            let searchOptions: String.CompareOptions = caseSensitive ? [] : .caseInsensitive
            
            var searchRange = result.startIndex..<result.endIndex
            while let range = result.range(of: term, options: searchOptions, range: searchRange) {
                let matched = String(result[range])
                let replacement = "\(prefix)\(matched)\(suffix)"
                result.replaceSubrange(range, with: replacement)
                
                let newStart = result.index(range.lowerBound, offsetBy: replacement.count)
                searchRange = newStart..<result.endIndex
            }
        }
        
        return result
    }
    
    private func sortResults(
        _ results: [SearchResult.MatchedEntry],
        options: SearchOptions
    ) -> [SearchResult.MatchedEntry] {
        results.sorted { entry1, entry2 in
            let comparison: ComparisonResult
            
            switch options.sortBy {
            case .timestamp:
                comparison = entry1.entry.timestamp.compare(entry2.entry.timestamp)
            case .level:
                if entry1.entry.level.rawValue < entry2.entry.level.rawValue {
                    comparison = .orderedAscending
                } else if entry1.entry.level.rawValue > entry2.entry.level.rawValue {
                    comparison = .orderedDescending
                } else {
                    comparison = .orderedSame
                }
            case .message:
                comparison = entry1.entry.message.compare(entry2.entry.message)
            case .relevance:
                if entry1.score < entry2.score {
                    comparison = .orderedAscending
                } else if entry1.score > entry2.score {
                    comparison = .orderedDescending
                } else {
                    comparison = .orderedSame
                }
            }
            
            switch options.sortOrder {
            case .ascending:
                return comparison == .orderedAscending
            case .descending:
                return comparison == .orderedDescending
            }
        }
    }
    
    private func calculateFacets(_ entries: [SearchResult.MatchedEntry]) -> SearchResult.Facets {
        var levelCounts: [LogLevel: Int] = [:]
        var sourceCounts: [String: Int] = [:]
        var hourCounts: [Int: Int] = [:]
        var metadataCounts: [String: Int] = [:]
        
        let calendar = Calendar.current
        
        for matched in entries {
            let entry = matched.entry
            
            // Level counts
            levelCounts[entry.level, default: 0] += 1
            
            // Source counts
            let fileName = (entry.file as NSString).lastPathComponent
            sourceCounts[fileName, default: 0] += 1
            
            // Hour counts
            let hour = calendar.component(.hour, from: entry.timestamp)
            hourCounts[hour, default: 0] += 1
            
            // Metadata key counts
            if let metadata = entry.metadata {
                for key in metadata.keys {
                    metadataCounts[key, default: 0] += 1
                }
            }
        }
        
        return SearchResult.Facets(
            levelCounts: levelCounts,
            sourceCounts: sourceCounts,
            hourCounts: hourCounts,
            metadataCounts: metadataCounts
        )
    }
    
    private func recordSearchHistory(query: String, resultCount: Int) {
        guard !query.isEmpty else { return }
        
        // Remove duplicate if exists
        searchHistory.removeAll { $0.query == query }
        
        // Add to front
        searchHistory.insert(
            SearchHistoryItem(query: query, timestamp: Date(), resultCount: resultCount),
            at: 0
        )
        
        // Enforce limit
        if searchHistory.count > maxHistoryItems {
            searchHistory.removeLast(searchHistory.count - maxHistoryItems)
        }
    }
}

// MARK: - Query Builder

/// A fluent API for building complex search queries.
public final class QueryBuilder {
    
    private var terms: [String] = []
    private var requiredTerms: [String] = []
    private var excludedTerms: [String] = []
    private var phrases: [String] = []
    private var fieldFilters: [(field: String, value: String)] = []
    
    /// Adds a search term.
    @discardableResult
    public func term(_ text: String) -> QueryBuilder {
        terms.append(text)
        return self
    }
    
    /// Adds a required term.
    @discardableResult
    public func required(_ text: String) -> QueryBuilder {
        requiredTerms.append(text)
        return self
    }
    
    /// Adds an excluded term.
    @discardableResult
    public func exclude(_ text: String) -> QueryBuilder {
        excludedTerms.append(text)
        return self
    }
    
    /// Adds an exact phrase.
    @discardableResult
    public func phrase(_ text: String) -> QueryBuilder {
        phrases.append(text)
        return self
    }
    
    /// Adds a field filter.
    @discardableResult
    public func field(_ name: String, equals value: String) -> QueryBuilder {
        fieldFilters.append((field: name, value: value))
        return self
    }
    
    /// Adds a level filter.
    @discardableResult
    public func level(_ level: LogLevel) -> QueryBuilder {
        fieldFilters.append((field: "level", value: level.rawValue))
        return self
    }
    
    /// Builds the query string.
    public func build() -> String {
        var parts: [String] = []
        
        for term in requiredTerms {
            parts.append("+\(term)")
        }
        
        for term in excludedTerms {
            parts.append("-\(term)")
        }
        
        for phrase in phrases {
            parts.append("\"\(phrase)\"")
        }
        
        for term in terms {
            parts.append(term)
        }
        
        for (field, value) in fieldFilters {
            if value.contains(" ") {
                parts.append("\(field):\"\(value)\"")
            } else {
                parts.append("\(field):\(value)")
            }
        }
        
        return parts.joined(separator: " ")
    }
}
