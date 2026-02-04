import CoreData

final class DownloadRepository {
    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() -> [DownloadRecord] {
        let request = NSFetchRequest<DownloadEntity>(entityName: "DownloadEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]

        do {
            return try context.fetch(request).map { entity in
                DownloadRecord(
                    id: entity.id,
                    title: entity.title,
                    thumbnailURL: entity.thumbnailURL,
                    duration: entity.duration,
                    localFilePath: entity.localFilePath,
                    resolution: entity.resolution,
                    createdAt: entity.createdAt
                )
            }
        } catch {
            return []
        }
    }

    func save(record: DownloadRecord) {
        let entity = DownloadEntity(context: context)
        entity.id = record.id
        entity.title = record.title
        entity.thumbnailURL = record.thumbnailURL
        entity.duration = record.duration
        entity.localFilePath = record.localFilePath
        entity.resolution = record.resolution
        entity.createdAt = record.createdAt

        do {
            try context.save()
        } catch {
            context.rollback()
        }
    }

    static var preview: DownloadRepository {
        let controller = PersistenceController(inMemory: true)
        return DownloadRepository(context: controller.container.viewContext)
    }
}
