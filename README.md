# smart-library-ios #

SmartLibrary - это демонстрационное iOS приложение для доступа к контенту, созданного с помощью диджитал-платформы StoryCLM https://storyclm.com/

### ContentComponent

В основе работы SmartLibrary лежит фреймворк ContentComponent, отвечающий за синхронизацию и доступ к данным.
ContentComponent состоит из следующих модулей:

* SCLMAuthService - аутентификация
* SCLMSyncService - доступ к RESTful API StoryCLM
* SCLMSyncManager - менеджер синхронизации
* SCLMBridge - мост

### Сборка

Для сборки и успешого запуска приложения необходим файл AuthCredentials.plist, который содержит в себе все необходимы данные для работы SCLMAuthService.

Файл AuthCredentials.plist необходимо добавить в проект SmartLibrary

Запросите этот файл у менеджера StoryCLM.

### Настройка

Для работы с ContentComponent необходимо установить SCLMAuthService и SCLMSyncService с данными из AuthCredentials.plist

```swift
SCLMAuthService.shared.setClientId(clientId)
SCLMAuthService.shared.setClientSecret(clientSecret)
SCLMAuthService.shared.setAppId(appId)
SCLMAuthService.shared.setAppSecret(appSecret)
SCLMAuthService.shared.setAuthEndpoint(authEndpoint)
```

### Логин

Для авторизации от имени пользователя необходимо вызвать следующий метод

```swift
SCLMAuthService.shared.login(username: username, password: password, success: {
success()

}) { (error) in
failure(error)

}
```

При успешной аутентификации будет получен token, который в дальнейшем будет использован SCLMSyncService для доступа к RESTful API

Для авторизации от имени приложения необходимо вызвать следующий метод

```swift
func authAsApplication(clientId: String,
secret: String,
username: String,
password: String,
success: @escaping (SCLMToken?) -> Void,
failure: @escaping (Error) -> Void) {}
```

Для авторизации от имени клиента необходимо вызвать следующий метод

```swift
func authAsService(clientId: String,
secret: String,
success: @escaping (SCLMToken?) -> Void,
failure: @escaping (Error) -> Void) {}
```

### Синхронизация Клиентов

После успешного логина необходим выполнить синхронизацию клиентов

```swift
SCLMSyncManager.shared.synchronizeClients { (error) in

}
```

Данный метод загрузит всех доступных клиентов и презентации для каждого клиента

### Доступ к данным

Доступ к данным предоставляет NSFetchedResultsController<NSFetchRequestResult> 

Можно использовать существующий NSFetchedResultsController с sectionNameKeyPath: "client.name"
```swift
var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult> {
return SCLMSyncManager.shared.fetchedResultsController
}
```

Можно инициализировать свой
```swift
public lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in

let fetchResult = self.fetchRequest(for: Presentation.entityName(), batchSize: 100, sortKey: "client.name", context: syncManager.context)
let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchResult, managedObjectContext: syncManager.context, sectionNameKeyPath: "client.name", cacheName: nil)


do {
try fetchedResultsController.performFetch()
} catch {
print("FetchedResultsController performFetch error")
}

return fetchedResultsController

}()
```

или так
```swift
public lazy var fetchedResultsControllerSectionLess: NSFetchedResultsController = { () -> NSFetchedResultsController<NSFetchRequestResult> in

let fetchResult = self.fetchRequest(for: Presentation.entityName(), batchSize: 100, sortKey: "client.name", context: syncManager.context)
let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchResult, managedObjectContext: syncManager.context, sectionNameKeyPath: nil, cacheName: nil)


do {
try fetchedResultsController.performFetch()
} catch {
print("FetchedResultsController performFetch error")
}

return fetchedResultsController

}()
```



По умолчанию количество Клиентов (Client) - это количество секций для UITableViewDataSource или UICollectionViewDataSource

```swift
func numberOfSections(in collectionView: UICollectionView) -> Int {

if let sections = viewModel.fetchedResultsController.sections {
return sections.count
}
return 0

}
```

Количество объектов секции (Presentation) - это презентации Клиентов.

```swift
func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

if let sections = viewModel.fetchedResultsController.sections {
if sections.count > section {
return sections[section].numberOfObjects
}
}
return 0

}
```

Доступ к презентации осуществляется через

```swift
let presentation = fetchedResultsController.object(at: indexPath) as! Presentation
```

### Синхронизация презентаций

При синхронизации клиентов синхронизируются только модели презентаций. Для синхронизации контента презентации неодходимо вызвать

```swift
SCLMSyncManager.shared.synchronizePresentation(presentation, completionHandler: { (error) in
completionHandler(error)

}) { (progress) in
progressHandler(progress)

}
```

Для восстановления прогреса синхронизации при обновлении данных необходимо воспользоваться следующими инструментами:

```swift
let presentationSynchronizingNow = SCLMSyncManager.shared.isPresentationSynchronizingNow(presentation: presentation)
```

Если контент загружается в настоящий момент, то метод SCLMSyncManager.shared.isPresentationSynchronizingNow вернет объект, у которого есть следующие свойства

```swift
public weak var downloadRequest: DownloadRequest?
public var progress = Progress() {
didSet {
progressHandler?(presentationId.intValue, progress)
}
}
public var progressHandler: ((_ presentationId: Int?, _ progress: Progress) -> Void)?
public var completionHandler: ((_ presentationId: Int?) -> Void)?
```

Соответственно, для downloadRequest может быть вызван cancel() для отмены, progress - передает текущий прогресс, progressHandler и completionHandler можно использовать для упраления процессом и обновления интерфейса

Для удаления контента необходимо вызвать

```swift
SyncManager.shared.deletePresentationContentPackage(presentation)
```

Для обновления презентации необходимо вызвать

```swift
SCLMSyncManager.shared.updatePresentation(presentation) { (error) in
completionHandler(error)
}
```


### Аналитика

Аналитика реализована в библиотеке StoryIot, подклучение которой осуществляется через CocoaPods

```swift
pod 'StoryIoT', :git => 'https://github.com/storyclm/story-iot-ios.git', :tag => ‘develop’
```

SLSessionsSyncManager инициализируется в AppDelegate через

```swift
SLSessionsSyncManager.shared.startTimer()
```

и слушает все события добавленные хранилище и при обнаружении отправляет их на сервер.
