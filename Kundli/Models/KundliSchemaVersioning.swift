import SwiftData

enum KundliSchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    static var models: [any PersistentModel.Type] {
        [SavedKundli.self, ChatConversation.self, CustomReminder.self]
    }
}

enum KundliMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [KundliSchemaV1.self]
    }
    static var stages: [MigrationStage] {
        []
    }
}
