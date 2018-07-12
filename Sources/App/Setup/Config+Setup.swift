import FluentProvider
import MongoProvider
import LeafProvider

extension Config {
    public func setup() throws {
        // allow fuzzy conversions for these types
        // (add your own types here)
        Node.fuzzy = [Row.self, JSON.self, Node.self]

        try setupProviders()
        try setupPreparations()
    }
    
    /// Configure providers
    private func setupProviders() throws {
        try addProvider(FluentProvider.Provider.self)
        try addProvider(MongoProvider.Provider.self)
        try addProvider(LeafProvider.Provider.self)

    }
    
    /// Add all models that should have their
    /// schemas prepared before the app boots
    private func setupPreparations() throws {
        preparations.append(Benutzer.self)
        preparations.append(Rezept.self)
        preparations.append(Produkt.self)
        preparations.append(Rohstoffanteil.self)

        
    }
    
}