import CoreData

final class PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        let model = Self.makeModel()
        container = NSPersistentContainer(name: "LocalYouTube", managedObjectModel: model)
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    static func makeModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()

        let entity = NSEntityDescription()
        entity.name = "DownloadEntity"
        entity.managedObjectClassName = NSStringFromClass(DownloadEntity.self)

        let idAttribute = NSAttributeDescription()
        idAttribute.name = "id"
        idAttribute.attributeType = .UUIDAttributeType
        idAttribute.isOptional = false

        let titleAttribute = NSAttributeDescription()
        titleAttribute.name = "title"
        titleAttribute.attributeType = .stringAttributeType
        titleAttribute.isOptional = false

        let thumbnailAttribute = NSAttributeDescription()
        thumbnailAttribute.name = "thumbnailURL"
        thumbnailAttribute.attributeType = .stringAttributeType
        thumbnailAttribute.isOptional = true

        let durationAttribute = NSAttributeDescription()
        durationAttribute.name = "duration"
        durationAttribute.attributeType = .doubleAttributeType
        durationAttribute.isOptional = false

        let filePathAttribute = NSAttributeDescription()
        filePathAttribute.name = "localFilePath"
        filePathAttribute.attributeType = .stringAttributeType
        filePathAttribute.isOptional = false

        let resolutionAttribute = NSAttributeDescription()
        resolutionAttribute.name = "resolution"
        resolutionAttribute.attributeType = .stringAttributeType
        resolutionAttribute.isOptional = false

        let createdAtAttribute = NSAttributeDescription()
        createdAtAttribute.name = "createdAt"
        createdAtAttribute.attributeType = .dateAttributeType
        createdAtAttribute.isOptional = false

        entity.properties = [
            idAttribute,
            titleAttribute,
            thumbnailAttribute,
            durationAttribute,
            filePathAttribute,
            resolutionAttribute,
            createdAtAttribute
        ]

        model.entities = [entity]
        return model
    }
}

@objc(DownloadEntity)
final class DownloadEntity: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var title: String
    @NSManaged var thumbnailURL: String?
    @NSManaged var duration: Double
    @NSManaged var localFilePath: String
    @NSManaged var resolution: String
    @NSManaged var createdAt: Date
}
